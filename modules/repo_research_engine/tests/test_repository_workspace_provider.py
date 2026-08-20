from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from subprocess import CompletedProcess

from sources import (
    LocalRepositoryWorkspaceProvider,
    RepositoryCloneRequest,
    RepositoryGitState,
    RepositoryIdentity,
    RepositoryWorkspaceLayout,
    RepositoryWorkspaceManager,
    RepositoryWorkspaceRuntime,
)


@dataclass
class RecordingWorkspaceProvider:
    root: Path

    def __post_init__(self) -> None:
        self.calls: list[str] = []

    def resolve_identity(self, source: str) -> RepositoryIdentity:
        self.calls.append(f"resolve_identity:{source}")
        return RepositoryIdentity(
            provider="github.com",
            owner_path="NewEarth",
            repo_name="StructuredClone",
            source=source,
            is_remote=True,
        )

    def build_layout(
        self,
        workspace_root: Path,
        identity: RepositoryIdentity,
        timestamp: str,
    ) -> RepositoryWorkspaceLayout:
        self.calls.append(f"build_layout:{timestamp}")
        repository_root = (
            workspace_root / identity.provider / identity.owner_path / identity.repo_name / timestamp
        )
        return RepositoryWorkspaceLayout(
            workspace_root=workspace_root,
            repository_root=repository_root,
            source_root=repository_root / "source",
            analysis_root=repository_root / "analysis",
            reports_root=repository_root / "reports",
            exports_root=repository_root / "exports",
            prompts_root=repository_root / "prompts",
            metadata_root=repository_root / "metadata",
        )

    def prepare_workspace(self, layout: RepositoryWorkspaceLayout) -> None:
        self.calls.append("prepare_workspace")
        layout.repository_root.parent.mkdir(parents=True, exist_ok=True)
        layout.analysis_root.mkdir(parents=True, exist_ok=True)
        layout.reports_root.mkdir(parents=True, exist_ok=True)
        layout.exports_root.mkdir(parents=True, exist_ok=True)
        layout.prompts_root.mkdir(parents=True, exist_ok=True)
        layout.metadata_root.mkdir(parents=True, exist_ok=True)

    def build_clone_command(
        self,
        source: str,
        source_root: Path,
        branch: str,
    ) -> list[str]:
        self.calls.append("build_clone_command")
        command = ["git", "clone", "--no-tags", "--single-branch"]
        if branch.strip():
            command.extend(["--branch", branch.strip()])
        command.extend([source, str(source_root)])
        return command

    def clone_source(
        self,
        command: list[str],
        *,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        self.calls.append(f"clone_source:{cwd}")
        return CompletedProcess(command, 0, stdout="clone ok", stderr="")

    def read_git_state(
        self,
        source_root: Path,
        *,
        requested_branch: str,
    ) -> RepositoryGitState:
        self.calls.append(f"read_git_state:{requested_branch}")
        return RepositoryGitState(commit="abc12345", branch="main")

    def write_manifests(
        self,
        *,
        source: str,
        workspace_root: Path,
        layout: RepositoryWorkspaceLayout,
        identity: RepositoryIdentity,
        timestamp: str,
        branch: str,
        commit: str,
        command: list[str],
    ) -> None:
        self.calls.append(f"write_manifests:{branch}:{commit}")
        layout.repository_root.mkdir(parents=True, exist_ok=True)
        (layout.repository_root / "clone_manifest.json").write_text(
            "{}",
            encoding="utf-8",
        )
        (layout.repository_root / "workspace_manifest.json").write_text(
            "{}",
            encoding="utf-8",
        )

    def cleanup_workspace(self, repository_root: Path) -> None:
        self.calls.append(f"cleanup_workspace:{repository_root}")


def test_runtime_is_single_composition_owner(tmp_path):
    provider = RecordingWorkspaceProvider(tmp_path)
    runtime = RepositoryWorkspaceRuntime(provider=provider)

    result = runtime.manager.clone_repository(
        RepositoryCloneRequest(
            source="https://github.com/NewEarth/StructuredClone.git",
            workspace_root=str(tmp_path / "workspace"),
        )
    )

    assert runtime.provider is provider
    assert result.provider == "github.com"
    assert provider.calls[0].startswith("resolve_identity:")
    assert any(call.startswith("build_layout:") for call in provider.calls)
    assert provider.calls.count("prepare_workspace") == 1
    assert provider.calls.count("build_clone_command") == 1
    assert provider.calls.count(f"clone_source:{Path(result.repository_root).parent}") == 1
    assert any(call.startswith("read_git_state:") for call in provider.calls)
    assert provider.calls.count("write_manifests:main:abc12345") == 1
    assert Path(result.manifest_path).exists()
    assert Path(result.workspace_manifest_path).exists()


def test_manager_delegates_each_repository_workspace_step_once(tmp_path):
    provider = RecordingWorkspaceProvider(tmp_path)
    manager = RepositoryWorkspaceManager(provider=provider)

    result = manager.clone_repository(
        RepositoryCloneRequest(
            source="https://github.com/NewEarth/StructuredClone.git",
            workspace_root=str(tmp_path / "workspace"),
            branch="feature/test",
        )
    )

    assert result.success is True
    assert result.provider == "github.com"
    assert result.owner_path == "NewEarth"
    assert result.repo_name == "StructuredClone"
    assert result.branch == "main"
    assert result.commit == "abc12345"
    assert provider.calls[0] == "resolve_identity:https://github.com/NewEarth/StructuredClone.git"
    assert provider.calls[1].startswith("build_layout:")
    assert provider.calls[2] == "prepare_workspace"
    assert provider.calls[3] == "build_clone_command"
    assert provider.calls[4] == f"clone_source:{Path(result.repository_root).parent}"
    assert provider.calls[5] == "read_git_state:feature/test"
    assert provider.calls[6] == "write_manifests:main:abc12345"
    assert len(provider.calls) == 7


def test_local_provider_has_no_generic_command_or_filesystem_api():
    assert not hasattr(LocalRepositoryWorkspaceProvider, "run_command")
    assert not hasattr(LocalRepositoryWorkspaceProvider, "execute_shell")
    assert not hasattr(LocalRepositoryWorkspaceProvider, "run_git")
    assert not hasattr(LocalRepositoryWorkspaceProvider, "read_any_file")
    assert not hasattr(LocalRepositoryWorkspaceProvider, "write_any_file")
    assert not hasattr(LocalRepositoryWorkspaceProvider, "delete_any_path")


def test_local_provider_resolves_identity_and_git_state(tmp_path):
    repo_root = tmp_path / "seed_repo"
    repo_root.mkdir()
    source_root = repo_root / "source"
    source_root.mkdir()

    responses = {
        ("git", "-C", str(repo_root), "remote", "get-url", "origin"): "https://github.com/NewEarth/StructuredClone.git\n",
        ("git", "-C", str(source_root), "rev-parse", "HEAD"): "abc12345\n",
        ("git", "-C", str(source_root), "branch", "--show-current"): "\n",
    }

    def runner(command, **kwargs):
        key = tuple(command)
        output = responses.get(key, "")
        return CompletedProcess(command, 0, stdout=output, stderr="")

    provider = LocalRepositoryWorkspaceProvider(command_runner=runner)

    identity = provider.resolve_identity(str(repo_root))
    git_state = provider.read_git_state(source_root, requested_branch="feature/test")

    assert identity.provider == "github.com"
    assert identity.owner_path == "NewEarth"
    assert identity.repo_name == "StructuredClone"
    assert git_state.commit == "abc12345"
    assert git_state.branch == "feature/test"


def test_errors_propagate_deterministically(tmp_path):
    class FailingProvider(RecordingWorkspaceProvider):
        def clone_source(self, command: list[str], *, cwd: Path | None = None):
            self.calls.append("clone_source_fail")
            return CompletedProcess(command, 1, stdout="stdout", stderr="stderr")

    provider = FailingProvider(tmp_path)
    manager = RepositoryWorkspaceManager(provider=provider)

    try:
        manager.clone_repository(
            RepositoryCloneRequest(
                source="https://github.com/NewEarth/StructuredClone.git",
                workspace_root=str(tmp_path / "workspace"),
            )
        )
    except RuntimeError as error:
        assert "Git clone failed." in str(error)
        assert "stderr" in str(error)
    else:
        raise AssertionError("Expected clone_repository to raise on clone failure")

    assert any(call.startswith("cleanup_workspace:") for call in provider.calls)
