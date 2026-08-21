from __future__ import annotations

import json
import subprocess
import threading
from datetime import timedelta
from pathlib import Path

from sources import (
    DEFAULT_CLONE_TIMEOUT,
    LocalRepositoryWorkspaceProvider,
    RepositoryCloneLifecycleError,
    RepositoryCloneLifecycleKind,
    RepositoryCloneRequest,
    RepositoryWorkspaceManager,
)


def _git(*args: str, cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=str(cwd),
        check=True,
        capture_output=True,
        text=True,
    )


class FakeOwnedProcess:
    def __init__(self, *, stdout: str = "", stderr: str = "") -> None:
        self.stdout_text = stdout
        self.stderr_text = stderr
        self.returncode: int | None = None
        self.pid = 4242
        self.communicate_calls: list[float | None] = []
        self.wait_calls: list[float | None] = []

    def poll(self) -> int | None:
        return self.returncode

    def communicate(self, timeout: float | None = None):
        self.communicate_calls.append(timeout)
        if self.returncode is None:
            raise subprocess.TimeoutExpired(cmd=["git"], timeout=timeout)
        return self.stdout_text, self.stderr_text

    def wait(self, timeout: float | None = None) -> int:
        self.wait_calls.append(timeout)
        if self.returncode is None:
            raise subprocess.TimeoutExpired(cmd=["git"], timeout=timeout)
        return self.returncode

    def complete(self, code: int) -> None:
        self.returncode = code


class RecordingLauncher:
    def __init__(self, process: FakeOwnedProcess) -> None:
        self.process = process
        self.calls: list[tuple[list[str], dict[str, object]]] = []

    def __call__(self, args, **kwargs):
        self.calls.append((list(args), dict(kwargs)))
        return self.process


def _command_runner_for_git_state(commit: str = "abc12345", branch: str = "main"):
    def runner(command, **kwargs):
        if command[-2:] == ["rev-parse", "HEAD"]:
            return subprocess.CompletedProcess(command, 0, stdout=f"{commit}\n", stderr="")
        if command[-2:] == ["branch", "--show-current"]:
            return subprocess.CompletedProcess(command, 0, stdout=f"{branch}\n", stderr="")
        return subprocess.CompletedProcess(command, 0, stdout="", stderr="")

    return runner


def test_clone_repository_into_structured_workspace(tmp_path):
    source_repo = tmp_path / "seed_repo"
    source_repo.mkdir()

    _git("init", cwd=source_repo)
    _git("config", "user.email", "test@example.com", cwd=source_repo)
    _git("config", "user.name", "Test User", cwd=source_repo)
    _git("remote", "add", "origin", "https://github.com/NewEarth/StructuredClone.git", cwd=source_repo)
    (source_repo / "README.md").write_text("# Seed Repo\n", encoding="utf-8")
    _git("add", "README.md", cwd=source_repo)
    _git("commit", "-m", "Initial commit", cwd=source_repo)

    workspace_root = tmp_path / "workspace"
    result = RepositoryWorkspaceManager().clone_repository(
        RepositoryCloneRequest(
            source=str(source_repo),
            workspace_root=str(workspace_root),
        )
    )

    assert result.success is True
    assert result.provider == "github.com"
    assert result.owner_path == "NewEarth"
    assert result.repo_name == "StructuredClone"

    source_root = Path(result.source_root)
    assert source_root.exists()
    assert (source_root / "README.md").exists()

    repository_root = Path(result.repository_root)
    assert (repository_root / "analysis").exists()
    assert (repository_root / "reports").exists()
    assert (repository_root / "exports").exists()
    assert (repository_root / "prompts").exists()
    assert (repository_root / "metadata").exists()

    manifest = json.loads((repository_root / "clone_manifest.json").read_text(encoding="utf-8"))
    assert manifest["source"] == str(source_repo)
    assert manifest["repository_root"] == str(repository_root)
    assert manifest["source_root"] == str(source_root)


def test_workspace_manager_rejects_empty_source(tmp_path):
    manager = RepositoryWorkspaceManager()
    try:
        manager.clone_repository(
            RepositoryCloneRequest(
                source="",
                workspace_root=str(tmp_path / "workspace"),
            ),
        )
    except ValueError as error:
        assert "required" in str(error)
    else:
        raise AssertionError("Expected clone_repository to reject an empty source")


def test_default_clone_timeout_is_ten_minutes():
    assert DEFAULT_CLONE_TIMEOUT == timedelta(minutes=10)


def test_clone_repository_uses_injected_process_and_preserves_result_shape(tmp_path):
    process = FakeOwnedProcess(stdout="clone ok\n", stderr="")
    process.complete(0)
    launcher = RecordingLauncher(process)
    provider = LocalRepositoryWorkspaceProvider(
        command_runner=_command_runner_for_git_state(),
        process_launcher=launcher,
    )
    manager = RepositoryWorkspaceManager(provider=provider)

    result = manager.clone_repository(
        RepositoryCloneRequest(
            source="https://github.com/NewEarth/StructuredClone.git",
            workspace_root=str(tmp_path / "workspace"),
        ),
    )

    assert result.success is True
    assert result.provider == "github.com"
    assert result.owner_path == "NewEarth"
    assert result.repo_name == "StructuredClone"
    assert result.branch == "main"
    assert result.commit == "abc12345"
    assert result.stdout == "clone ok\n"
    assert result.stderr == ""
    assert result.command == [
        "git",
        "clone",
        "--no-tags",
        "--single-branch",
        "https://github.com/NewEarth/StructuredClone.git",
        result.source_root,
    ]
    assert launcher.calls[0][0] == [
        "git",
        "clone",
        "--no-tags",
        "--single-branch",
        "https://github.com/NewEarth/StructuredClone.git",
        result.source_root,
    ]
    assert launcher.calls[0][1]["shell"] is False
    assert launcher.calls[0][1]["stdout"] == subprocess.PIPE
    assert launcher.calls[0][1]["stderr"] == subprocess.PIPE
    assert launcher.calls[0][1]["text"] is True
    assert Path(result.manifest_path).exists()
    assert Path(result.workspace_manifest_path).exists()
    assert not any(
        candidate.name == "clone_ownership.json"
        for candidate in Path(result.repository_root).rglob("clone_ownership.json")
    )


def test_timeout_is_injectable_and_selects_timed_out(tmp_path):
    process = FakeOwnedProcess(stdout="partial stdout", stderr="partial stderr")
    launcher = RecordingLauncher(process)
    cleanup_calls: list[Path] = []
    terminate_calls: list[int] = []

    def remove_tree(path: Path, ignore_errors: bool = False) -> None:
        cleanup_calls.append(path)

    def terminator(owned_process: FakeOwnedProcess) -> None:
        terminate_calls.append(owned_process.pid)
        owned_process.complete(124)

    provider = LocalRepositoryWorkspaceProvider(
        command_runner=_command_runner_for_git_state(),
        process_launcher=launcher,
        remove_tree=remove_tree,
    )
    manager = RepositoryWorkspaceManager(provider=provider)

    try:
        manager.clone_repository(
            RepositoryCloneRequest(
                source="https://github.com/NewEarth/StructuredClone.git",
                workspace_root=str(tmp_path / "workspace"),
            ),
            timeout=timedelta(milliseconds=1),
            process_terminator=terminator,
        )
    except RepositoryCloneLifecycleError as error:
        assert error.kind == RepositoryCloneLifecycleKind.timed_out
        assert error.primary_cause == RepositoryCloneLifecycleKind.timed_out
        assert error.stdout == "partial stdout"
        assert error.stderr == "partial stderr"
    else:
        raise AssertionError("Expected clone_repository to time out")

    assert terminate_calls == [4242]
    assert cleanup_calls
    assert len(process.communicate_calls) >= 2


def test_cancellation_is_optional_and_selects_cancelled(tmp_path):
    process = FakeOwnedProcess(stdout="partial stdout", stderr="partial stderr")
    launcher = RecordingLauncher(process)
    cleanup_calls: list[Path] = []
    terminate_calls: list[int] = []

    def remove_tree(path: Path, ignore_errors: bool = False) -> None:
        cleanup_calls.append(path)

    def terminator(owned_process: FakeOwnedProcess) -> None:
        terminate_calls.append(owned_process.pid)
        owned_process.complete(125)

    provider = LocalRepositoryWorkspaceProvider(
        command_runner=_command_runner_for_git_state(),
        process_launcher=launcher,
        remove_tree=remove_tree,
    )
    manager = RepositoryWorkspaceManager(provider=provider)
    cancel = threading.Event()
    cancel.set()

    try:
        manager.clone_repository(
            RepositoryCloneRequest(
                source="https://github.com/NewEarth/StructuredClone.git",
                workspace_root=str(tmp_path / "workspace"),
            ),
            cancellation_event=cancel,
            process_terminator=terminator,
        )
    except RepositoryCloneLifecycleError as error:
        assert error.kind == RepositoryCloneLifecycleKind.cancelled
        assert error.primary_cause == RepositoryCloneLifecycleKind.cancelled
        assert error.stdout == "partial stdout"
        assert error.stderr == "partial stderr"
    else:
        raise AssertionError("Expected clone_repository to be cancelled")

    assert terminate_calls == [4242]
    assert cleanup_calls


def test_git_failure_cleans_owned_partial_workspace(tmp_path):
    process = FakeOwnedProcess(stdout="stdout", stderr="stderr")
    process.complete(17)
    launcher = RecordingLauncher(process)
    cleanup_calls: list[Path] = []

    def remove_tree(path: Path, ignore_errors: bool = False) -> None:
        cleanup_calls.append(path)

    provider = LocalRepositoryWorkspaceProvider(
        command_runner=_command_runner_for_git_state(),
        process_launcher=launcher,
        remove_tree=remove_tree,
    )
    manager = RepositoryWorkspaceManager(provider=provider)

    try:
        manager.clone_repository(
            RepositoryCloneRequest(
                source="https://github.com/NewEarth/StructuredClone.git",
                workspace_root=str(tmp_path / "workspace"),
            ),
        )
    except RepositoryCloneLifecycleError as error:
        assert error.kind == RepositoryCloneLifecycleKind.git_failure
        assert error.primary_cause == RepositoryCloneLifecycleKind.git_failure
        assert error.stdout == "stdout"
        assert error.stderr == "stderr"
    else:
        raise AssertionError("Expected clone_repository to fail on non-zero git exit")

    assert cleanup_calls


def test_cleanup_failure_becomes_cleanup_failed(tmp_path):
    process = FakeOwnedProcess(stdout="stdout", stderr="stderr")
    process.complete(17)
    launcher = RecordingLauncher(process)

    def remove_tree(path: Path, ignore_errors: bool = False) -> None:
        raise OSError("cleanup boom")

    provider = LocalRepositoryWorkspaceProvider(
        command_runner=_command_runner_for_git_state(),
        process_launcher=launcher,
        remove_tree=remove_tree,
    )
    manager = RepositoryWorkspaceManager(provider=provider)

    try:
        manager.clone_repository(
            RepositoryCloneRequest(
                source="https://github.com/NewEarth/StructuredClone.git",
                workspace_root=str(tmp_path / "workspace"),
            ),
        )
    except RepositoryCloneLifecycleError as error:
        assert error.kind == RepositoryCloneLifecycleKind.cleanup_failed
        assert error.primary_cause == RepositoryCloneLifecycleKind.git_failure
    else:
        raise AssertionError("Expected clone_repository to report cleanup failure")


def test_cleanup_lifecycle_error_preserves_primary_cause(tmp_path):
    process = FakeOwnedProcess(stdout="stdout", stderr="stderr")
    process.complete(17)
    launcher = RecordingLauncher(process)

    def cleanup_workspace(
        repository_root: Path,
        *,
        workspace_root: Path | None = None,
        ownership_sentinel_path: Path | None = None,
        operation_id: str | None = None,
    ) -> None:
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="cleanup guard failed",
            command=[],
        )

    provider = LocalRepositoryWorkspaceProvider(
        command_runner=_command_runner_for_git_state(),
        process_launcher=launcher,
    )
    provider.cleanup_workspace = cleanup_workspace  # type: ignore[method-assign]
    manager = RepositoryWorkspaceManager(provider=provider)

    try:
        manager.clone_repository(
            RepositoryCloneRequest(
                source="https://github.com/NewEarth/StructuredClone.git",
                workspace_root=str(tmp_path / "workspace"),
            ),
        )
    except RepositoryCloneLifecycleError as error:
        assert error.kind == RepositoryCloneLifecycleKind.cleanup_failed
        assert error.primary_cause == RepositoryCloneLifecycleKind.git_failure
    else:
        raise AssertionError("Expected cleanup lifecycle error to preserve cause")


def test_cleanup_workspace_rejects_missing_sentinel(tmp_path):
    removed: list[Path] = []

    def remove_tree(path: Path, ignore_errors: bool = False) -> None:
        removed.append(path)

    provider = LocalRepositoryWorkspaceProvider(remove_tree=remove_tree)
    workspace_root = tmp_path / "workspace"
    repository_root = workspace_root / "github.com" / "owner" / "repo" / "stamp"
    repository_root.mkdir(parents=True)
    sentinel = repository_root / "clone_ownership.json"

    try:
        provider.cleanup_workspace(
            repository_root,
            workspace_root=workspace_root,
            ownership_sentinel_path=sentinel,
            operation_id="clone_v1_20260821T104500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
        )
    except RepositoryCloneLifecycleError as error:
        assert error.kind == RepositoryCloneLifecycleKind.cleanup_failed
    else:
        raise AssertionError("Expected cleanup to reject a missing sentinel")

    assert removed == []


def test_cleanup_workspace_rejects_workspace_root(tmp_path):
    removed: list[Path] = []

    def remove_tree(path: Path, ignore_errors: bool = False) -> None:
        removed.append(path)

    provider = LocalRepositoryWorkspaceProvider(remove_tree=remove_tree)
    workspace_root = tmp_path / "workspace"
    workspace_root.mkdir(parents=True)
    sentinel = workspace_root / "clone_ownership.json"
    sentinel.write_text(
        json.dumps(
            {
                "protocol_version": "clone_v1",
                "operation_id": "clone_v1_20260821T104500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
                "workspace_root": str(workspace_root.resolve()),
                "repository_root": str(workspace_root.resolve()),
            },
        ),
        encoding="utf-8",
    )

    try:
        provider.cleanup_workspace(
            workspace_root,
            workspace_root=workspace_root,
            ownership_sentinel_path=sentinel,
            operation_id="clone_v1_20260821T104500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
        )
    except RepositoryCloneLifecycleError as error:
        assert error.kind == RepositoryCloneLifecycleKind.cleanup_failed
    else:
        raise AssertionError("Expected cleanup to reject the workspace root")

    assert removed == []
