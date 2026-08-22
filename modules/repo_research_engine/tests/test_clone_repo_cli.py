from __future__ import annotations

import io
import json
import re
import threading
from dataclasses import dataclass
from datetime import timedelta
from pathlib import Path
from subprocess import CompletedProcess

import pytest

from sources import (
    RepositoryCloneLifecycleError,
    RepositoryCloneLifecycleKind,
    RepositoryCloneRequest,
    RepositoryCloneResult,
)

from scripts import clone_repo


@dataclass
class FakeRuntime:
    manager: object


class RecordingManager:
    def __init__(self, *, result: RepositoryCloneResult | None = None, mode: str = "success") -> None:
        self.result = result
        self.mode = mode
        self.calls: list[dict[str, object]] = []

    def clone_repository(
        self,
        request: RepositoryCloneRequest,
        *,
        timeout: timedelta,
        cancellation_event: threading.Event | None = None,
        process_terminator=None,
        operation_id: str | None = None,
    ) -> RepositoryCloneResult:
        call = {
            "request": request,
            "timeout": timeout.total_seconds(),
            "cancellation_event": cancellation_event,
            "operation_id": operation_id,
        }
        self.calls.append(call)
        if self.mode == "cancel_if_set" and cancellation_event is not None:
            cancellation_event.wait(0.2)
            if cancellation_event.is_set():
                raise RepositoryCloneLifecycleError(
                    kind=RepositoryCloneLifecycleKind.cancelled,
                    message="Clone was cancelled.",
                    command=[],
                    stdout="cancelled stdout",
                    stderr="cancelled stderr",
                    primary_cause=RepositoryCloneLifecycleKind.cancelled,
                )
        if self.mode == "failure":
            raise RepositoryCloneLifecycleError(
                kind=RepositoryCloneLifecycleKind.git_failure,
                message="Git clone failed.",
                command=["git", "clone"],
                stdout="git stdout",
                stderr="git stderr",
                primary_cause=RepositoryCloneLifecycleKind.git_failure,
            )
        if self.result is None:
            raise AssertionError("A success result was not provided.")
        return self.result


def _make_result(tmp_path: Path) -> RepositoryCloneResult:
    repository_root = tmp_path / "workspace" / "github.com" / "NewEarth" / "StructuredClone" / "20260822-061500"
    return RepositoryCloneResult(
        success=True,
        source="https://github.com/NewEarth/StructuredClone.git",
        workspace_root=str(tmp_path / "workspace"),
        repository_root=str(repository_root),
        source_root=str(repository_root / "source"),
        provider="github.com",
        owner_path="NewEarth",
        repo_name="StructuredClone",
        branch="main",
        commit="abc12345",
        manifest_path=str(repository_root / "clone_manifest.json"),
        workspace_manifest_path=str(repository_root / "workspace_manifest.json"),
        command=[
            "git",
            "clone",
            "--no-tags",
            "--single-branch",
            "https://github.com/NewEarth/StructuredClone.git",
            str(repository_root / "source"),
        ],
        stdout="clone ok",
        stderr="",
        message="Cloned https://github.com/NewEarth/StructuredClone.git into source",
    )


def _invoke_cli(argv: list[str], manager: RecordingManager, stdin=None):
    stdout = io.StringIO()
    stderr = io.StringIO()
    exit_code = clone_repo.execute_clone_cli(
        argv,
        runtime_factory=lambda: FakeRuntime(manager),
        stdin=stdin,
        stdout=stdout,
        stderr=stderr,
    )
    return exit_code, stdout.getvalue(), stderr.getvalue(), manager.calls


def test_legacy_invocation_preserves_success_json_and_defaults(tmp_path):
    manager = RecordingManager(result=_make_result(tmp_path))
    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
        ],
        manager,
    )

    assert exit_code == 0
    assert stderr == ""
    payload = json.loads(stdout)
    assert list(payload) == [
        "exitCode",
        "source",
        "workspaceRoot",
        "repositoryRoot",
        "sourceRoot",
        "provider",
        "ownerPath",
        "repoName",
        "branch",
        "commit",
        "manifestPath",
        "workspaceManifestPath",
        "command",
        "stdout",
        "stderr",
    ]
    assert payload["exitCode"] == 0
    assert payload["source"] == "https://github.com/NewEarth/StructuredClone.git"
    assert payload["workspaceRoot"] == str(tmp_path / "workspace")
    assert payload["repositoryRoot"] == manager.result.repository_root
    assert payload["sourceRoot"] == manager.result.source_root
    assert payload["provider"] == "github.com"
    assert payload["ownerPath"] == "NewEarth"
    assert payload["repoName"] == "StructuredClone"
    assert payload["branch"] == "main"
    assert payload["commit"] == "abc12345"
    assert payload["manifestPath"] == manager.result.manifest_path
    assert payload["workspaceManifestPath"] == manager.result.workspace_manifest_path
    assert payload["command"] == manager.result.command
    assert payload["stdout"] == "clone ok"
    assert payload["stderr"] == ""
    assert calls[0]["cancellation_event"] is None
    assert calls[0]["timeout"] == 600.0
    assert clone_repo.OPERATION_ID_PATTERN.fullmatch(str(calls[0]["operation_id"]))


def test_explicit_operation_id_is_accepted(tmp_path):
    manager = RecordingManager(result=_make_result(tmp_path))
    operation_id = "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771"
    exit_code, _, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
            "--operation-id",
            operation_id,
        ],
        manager,
    )

    assert exit_code == 0
    assert stderr == ""
    assert calls[0]["operation_id"] == operation_id


def test_invalid_operation_id_is_rejected(tmp_path):
    manager = RecordingManager(result=_make_result(tmp_path))
    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
            "--operation-id",
            "../bad",
        ],
        manager,
    )

    assert exit_code == 10
    assert stdout == ""
    payload = json.loads(stderr)
    assert payload["failure_kind"] == "validation_failed"
    assert payload["kind"] == "clone_failure"
    assert calls == []


def test_invalid_operation_id_variants_are_rejected(tmp_path):
    invalid_values = [
        "clone_v1_20260822T061500Z_ABCDEF",
        "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771/extra",
        "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771 path",
    ]
    for value in invalid_values:
        manager = RecordingManager(result=_make_result(tmp_path))
        exit_code, stdout, stderr, calls = _invoke_cli(
            [
                "--source",
                "https://github.com/NewEarth/StructuredClone.git",
                "--workspace-root",
                str(tmp_path / "workspace"),
                "--operation-id",
                value,
            ],
            manager,
        )
        assert exit_code == 10
        assert stdout == ""
        assert json.loads(stderr)["failure_kind"] == "validation_failed"
        assert calls == []


def test_protocol_version_and_timeout_validation(tmp_path):
    manager = RecordingManager(result=_make_result(tmp_path))

    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
            "--protocol-version",
            "ds05-c4b1-clone-protocol-v0",
        ],
        manager,
    )
    assert exit_code == 10
    assert stdout == ""
    assert json.loads(stderr)["failure_kind"] == "validation_failed"
    assert calls == []

    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
            "--timeout-seconds",
            "12.5",
        ],
        manager,
    )
    assert exit_code == 0
    assert stdout
    assert stderr == ""
    assert calls[-1]["timeout"] == 12.5

    for timeout_value in ("0", "-1", "nan", "inf", "abc"):
        manager = RecordingManager(result=_make_result(tmp_path))
        exit_code, stdout, stderr, calls = _invoke_cli(
            [
                "--source",
                "https://github.com/NewEarth/StructuredClone.git",
                "--workspace-root",
                str(tmp_path / "workspace"),
                "--timeout-seconds",
                timeout_value,
            ],
            manager,
        )
        assert exit_code == 10
        assert stdout == ""
        assert json.loads(stderr)["failure_kind"] == "validation_failed"
        assert calls == []


def test_unknown_argument_produces_structured_failure(tmp_path):
    manager = RecordingManager(result=_make_result(tmp_path))
    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
            "--bogus",
        ],
        manager,
    )

    assert exit_code == 10
    assert stdout == ""
    assert json.loads(stderr)["failure_kind"] == "validation_failed"
    assert calls == []


def test_help_exits_cleanly_without_cloning(tmp_path):
    manager = RecordingManager(result=_make_result(tmp_path))
    exit_code, stdout, stderr, calls = _invoke_cli(["--help"], manager)

    assert exit_code == 0
    assert stderr == ""
    assert "usage:" in stdout.lower()
    assert "clone a repository into a structured workspace" in stdout.lower()
    assert calls == []


def test_listener_absent_without_control_stdin(tmp_path):
    manager = RecordingManager(result=_make_result(tmp_path))
    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
        ],
        manager,
    )

    assert exit_code == 0
    assert stderr == ""
    assert calls[0]["cancellation_event"] is None


def test_control_listener_is_daemon_and_eof_is_harmless():
    state = clone_repo._CloneProtocolState("clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771")
    thread = clone_repo._build_protocol_listener(io.BytesIO(b""), state)
    assert thread.daemon is True
    thread.start()
    thread.join(timeout=1)
    assert not thread.is_alive()
    assert not state.cancellation_event.is_set()
    assert state.protocol_error_message is None


def test_valid_cancellation_selects_cancelled(tmp_path):
    manager = RecordingManager(mode="cancel_if_set", result=_make_result(tmp_path))
    cancel_frame = json.dumps(
        {
            "protocol_version": clone_repo.PROTOCOL_VERSION,
            "kind": "cancel",
            "operation_id": "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
            "reason": "user_cancelled",
        }
    ).encode("utf-8") + b"\n"
    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
            "--control-stdin",
            "--operation-id",
            "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
        ],
        manager,
        stdin=io.BytesIO(cancel_frame),
    )

    assert exit_code == 14
    assert stdout == ""
    payload = json.loads(stderr)
    assert payload["failure_kind"] == "cancelled"
    assert payload["kind"] == "clone_failure"
    assert calls[0]["cancellation_event"].is_set()


@pytest.mark.parametrize(
    "frame, expected_kind",
    [
        (
            {
                "protocol_version": "ds05-c4b1-clone-protocol-v0",
                "kind": "cancel",
                "operation_id": "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
                "reason": "user_cancelled",
            },
            "protocol_error",
        ),
        (
            {
                "protocol_version": clone_repo.PROTOCOL_VERSION,
                "kind": "abort",
                "operation_id": "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
                "reason": "user_cancelled",
            },
            "protocol_error",
        ),
        (
            {
                "protocol_version": clone_repo.PROTOCOL_VERSION,
                "kind": "cancel",
                "operation_id": "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771-mismatch",
                "reason": "user_cancelled",
            },
            "protocol_error",
        ),
        (
            {
                "protocol_version": clone_repo.PROTOCOL_VERSION,
                "kind": "cancel",
                "operation_id": "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
                "reason": "maybe_later",
            },
            "protocol_error",
        ),
        (
            {
                "protocol_version": clone_repo.PROTOCOL_VERSION,
                "kind": "cancel",
                "operation_id": "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
                "reason": "user_cancelled",
                "unexpected": "field",
            },
            "protocol_error",
        ),
    ],
)
def test_invalid_control_frames_select_protocol_error(tmp_path, frame, expected_kind):
    manager = RecordingManager(mode="cancel_if_set", result=_make_result(tmp_path))
    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
            "--control-stdin",
            "--operation-id",
            "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
        ],
        manager,
        stdin=io.BytesIO(json.dumps(frame).encode("utf-8") + b"\n"),
    )

    assert exit_code == 16
    assert stdout == ""
    payload = json.loads(stderr)
    assert payload["failure_kind"] == expected_kind
    assert payload["kind"] == "clone_failure"
    assert calls[0]["cancellation_event"].is_set()


def test_malformed_control_frames_select_protocol_error(tmp_path):
    malformed_inputs = [
        b"{not-json}\n",
        b"\xff\xfe",
        b"{" + b"a" * 5000 + b"}\n",
    ]
    for frame in malformed_inputs:
        manager = RecordingManager(mode="cancel_if_set", result=_make_result(tmp_path))
        exit_code, stdout, stderr, calls = _invoke_cli(
            [
                "--source",
                "https://github.com/NewEarth/StructuredClone.git",
                "--workspace-root",
                str(tmp_path / "workspace"),
                "--control-stdin",
                "--operation-id",
                "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
            ],
            manager,
            stdin=io.BytesIO(frame),
        )
        assert exit_code == 16
        assert stdout == ""
        payload = json.loads(stderr)
        assert payload["failure_kind"] == "protocol_error"
        assert payload["kind"] == "clone_failure"


def test_duplicate_cancellation_is_idempotent(tmp_path):
    manager = RecordingManager(mode="cancel_if_set", result=_make_result(tmp_path))
    frame = json.dumps(
        {
            "protocol_version": clone_repo.PROTOCOL_VERSION,
            "kind": "cancel",
            "operation_id": "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
            "reason": "caller_shutdown",
        }
    ).encode("utf-8")
    exit_code, stdout, stderr, calls = _invoke_cli(
        [
            "--source",
            "https://github.com/NewEarth/StructuredClone.git",
            "--workspace-root",
            str(tmp_path / "workspace"),
            "--control-stdin",
            "--operation-id",
            "clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
        ],
        manager,
        stdin=io.BytesIO(frame + b"\n" + frame + b"\n"),
    )

    assert exit_code == 14
    assert stdout == ""
    assert json.loads(stderr)["failure_kind"] == "cancelled"
    assert calls[0]["cancellation_event"].is_set()


def test_cancellation_after_success_does_not_replace_success():
    state = clone_repo._CloneProtocolState("clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771")
    state.mark_terminal()
    thread = clone_repo._build_protocol_listener(
        io.BytesIO(
            json.dumps(
                {
                    "protocol_version": clone_repo.PROTOCOL_VERSION,
                    "kind": "cancel",
                    "operation_id": state.operation_id,
                    "reason": "user_cancelled",
                }
            ).encode("utf-8")
            + b"\n",
        ),
        state,
    )
    thread.start()
    thread.join(timeout=1)
    assert not state.cancellation_event.is_set()
    assert state.protocol_error_message is None


@pytest.mark.parametrize(
    "text",
    [
        "https://user:token@example.com/repo.git",
        "https://example.com/repo.git?token=abc123",
        "https://example.com/repo.git?access_token=abc123",
        "authorization: Bearer secret-value",
        "https://user%3Atoken@example.com/repo.git",
    ],
)
def test_failure_payload_sanitizes_credentials(text):
    failure = clone_repo._build_failure(
        failure_kind="git_failed",
        message="Git clone failed.",
        operation_id="clone_v1_20260822T061500Z_6f1a4d90c25b4ea6aaf31aa188ab2771",
        exit_code=12,
        stdout=text,
        stderr=text,
        cleanup_state="completed",
    )
    payload = failure.payload

    assert text not in payload["stdout"]
    assert text not in payload["stderr"]
    assert "***" in payload["stdout"] or "***" in payload["stderr"]
