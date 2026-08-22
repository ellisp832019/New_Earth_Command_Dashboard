from __future__ import annotations

import argparse
import io
import json
import math
import re
import sys
import threading
from dataclasses import dataclass
from datetime import timedelta
from pathlib import Path
from typing import Any, TextIO

MODULE_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(MODULE_ROOT))

from sources import (  # noqa: E402
    RepositoryCloneLifecycleError,
    RepositoryCloneLifecycleKind,
    RepositoryCloneRequest,
    RepositoryCloneResult,
    RepositoryWorkspaceRuntime,
)
from sources.repository_workspace import (  # noqa: E402
    DEFAULT_CLONE_TIMEOUT,
    OPERATION_ID_PATTERN,
    _generate_clone_operation_id,
)


PROTOCOL_VERSION = "ds05-c4b1-clone-protocol-v1"
DEFAULT_TIMEOUT_SECONDS = int(DEFAULT_CLONE_TIMEOUT.total_seconds())
MAX_CONTROL_FRAME_BYTES = 4096
ALLOWED_CANCEL_REASONS = frozenset({"user_cancelled", "caller_shutdown"})
PUBLIC_FAILURE_EXIT_CODES = {
    "validation_failed": 10,
    "launch_failed": 11,
    "git_failed": 12,
    "timed_out": 13,
    "cancelled": 14,
    "cleanup_failed": 15,
    "protocol_error": 16,
}

_URL_CREDENTIAL_PATTERN = re.compile(
    r"(?P<scheme>[A-Za-z][A-Za-z0-9+.-]*://)(?P<creds>[^/@\s]+@)",
)
_TOKEN_PATTERN = re.compile(
    r"(?i)\b(access[_-]?token|token|password|passwd|secret|authorization)\b\s*[:=]\s*([^\s,;]+)",
)


class CloneArgumentError(Exception):
    def __init__(self, message: str) -> None:
        super().__init__(message)
        self.message = message


class CloneCliFailure(Exception):
    def __init__(self, exit_code: int, payload: dict[str, Any]) -> None:
        super().__init__(payload.get("message", "clone failure"))
        self.exit_code = exit_code
        self.payload = payload


class CloneArgumentParser(argparse.ArgumentParser):
    def error(self, message: str) -> None:
        raise CloneArgumentError(message)


@dataclass(frozen=True)
class CloneInvocation:
    source: str
    workspace_root: str
    branch: str
    protocol_version: str
    operation_id: str | None
    timeout_seconds: float
    control_stdin: bool


class _CloneProtocolState:
    def __init__(self, operation_id: str) -> None:
        self.operation_id = operation_id
        self.cancellation_event = threading.Event()
        self.terminal_event = threading.Event()
        self.protocol_error_message: str | None = None
        self.protocol_error_details: str = ""
        self._lock = threading.Lock()

    def mark_protocol_error(self, message: str, *, details: str = "") -> bool:
        with self._lock:
            if self.terminal_event.is_set() or self.protocol_error_message is not None:
                return False
            self.protocol_error_message = message
            self.protocol_error_details = details
            self.cancellation_event.set()
            return True

    def mark_cancelled(self) -> bool:
        with self._lock:
            if self.terminal_event.is_set() or self.cancellation_event.is_set():
                return False
            self.cancellation_event.set()
            return True

    def mark_terminal(self) -> None:
        self.terminal_event.set()


def _build_parser() -> CloneArgumentParser:
    parser = CloneArgumentParser(
        description="Clone a repository into a structured workspace",
        allow_abbrev=False,
        add_help=False,
    )
    parser.add_argument("-h", "--help", action="store_true", help="Show this help message and exit")
    parser.add_argument("--protocol-version", default=PROTOCOL_VERSION, type=_parse_protocol_version)
    parser.add_argument("--operation-id", default=None, type=_parse_operation_id)
    parser.add_argument("--timeout-seconds", default=DEFAULT_TIMEOUT_SECONDS, type=_parse_timeout_seconds)
    parser.add_argument(
        "--control-stdin",
        action="store_true",
        help="Listen for newline-delimited JSON control frames on stdin",
    )
    parser.add_argument("--source", required=True, help="Local repository path or remote Git URL")
    parser.add_argument(
        "--workspace-root",
        required=True,
        help="Workspace root that will contain the structured clone folders",
    )
    parser.add_argument(
        "--branch",
        default="",
        help="Optional branch to clone when the source is remote or branch-capable",
    )
    return parser


def _parse_protocol_version(value: str) -> str:
    if value != PROTOCOL_VERSION:
        raise argparse.ArgumentTypeError(
            f"Unsupported protocol version: {value}",
        )
    return value


def _parse_operation_id(value: str) -> str:
    if not OPERATION_ID_PATTERN.fullmatch(value):
        raise argparse.ArgumentTypeError(
            "Operation ID must match clone_v1_<UTC compact timestamp>_<UUID hex>.",
        )
    return value


def _parse_timeout_seconds(value: str) -> float:
    try:
        timeout_seconds = float(value)
    except ValueError as error:
        raise argparse.ArgumentTypeError("Timeout seconds must be numeric.") from error

    if not math.isfinite(timeout_seconds) or timeout_seconds <= 0:
        raise argparse.ArgumentTypeError("Timeout seconds must be finite and positive.")
    return timeout_seconds


def _build_help_text() -> str:
    return _build_parser().format_help()


def _looks_like_help(argv: list[str]) -> bool:
    return any(token in ("-h", "--help") for token in argv)


def _parse_invocation(argv: list[str], *, fallback_operation_id: str) -> CloneInvocation:
    parser = _build_parser()
    try:
        namespace = parser.parse_args(argv)
    except CloneArgumentError as error:
        raise _build_failure(
            failure_kind="validation_failed",
            message=error.message,
            operation_id=fallback_operation_id,
            exit_code=PUBLIC_FAILURE_EXIT_CODES["validation_failed"],
            cleanup_state="not_started",
        ) from error

    operation_id = namespace.operation_id or fallback_operation_id
    return CloneInvocation(
        source=namespace.source,
        workspace_root=namespace.workspace_root,
        branch=namespace.branch,
        protocol_version=namespace.protocol_version,
        operation_id=operation_id,
        timeout_seconds=float(namespace.timeout_seconds),
        control_stdin=bool(namespace.control_stdin),
    )


def _clone_success_payload(result: RepositoryCloneResult) -> dict[str, Any]:
    return {
        "exitCode": 0,
        "source": result.source,
        "workspaceRoot": result.workspace_root,
        "repositoryRoot": result.repository_root,
        "sourceRoot": result.source_root,
        "provider": result.provider,
        "ownerPath": result.owner_path,
        "repoName": result.repo_name,
        "branch": result.branch,
        "commit": result.commit,
        "manifestPath": result.manifest_path,
        "workspaceManifestPath": result.workspace_manifest_path,
        "command": list(result.command),
        "stdout": result.stdout,
        "stderr": result.stderr,
    }


def _sanitize_text(value: str) -> str:
    if not value:
        return ""
    sanitized = _URL_CREDENTIAL_PATTERN.sub(r"\g<scheme>***@", value)
    sanitized = _TOKEN_PATTERN.sub(lambda match: f"{match.group(1)}=***", sanitized)
    return sanitized


def _map_internal_failure_kind(kind: str) -> str:
    if kind == RepositoryCloneLifecycleKind.launch_failure:
        return "launch_failed"
    if kind == RepositoryCloneLifecycleKind.git_failure:
        return "git_failed"
    if kind == RepositoryCloneLifecycleKind.timed_out:
        return "timed_out"
    if kind == RepositoryCloneLifecycleKind.cancelled:
        return "cancelled"
    if kind in (RepositoryCloneLifecycleKind.cleanup_failed, RepositoryCloneLifecycleKind.termination_failure):
        return "cleanup_failed"
    return "protocol_error"


def _map_primary_cause(kind: str | None) -> str | None:
    if kind is None:
        return None
    if kind == RepositoryCloneLifecycleKind.launch_failure:
        return "launch_failed"
    if kind == RepositoryCloneLifecycleKind.git_failure:
        return "git_failed"
    if kind == RepositoryCloneLifecycleKind.timed_out:
        return "timed_out"
    if kind == RepositoryCloneLifecycleKind.cancelled:
        return "cancelled"
    if kind in (RepositoryCloneLifecycleKind.cleanup_failed, RepositoryCloneLifecycleKind.termination_failure):
        return "cleanup_failed"
    return "protocol_error"


def _build_failure(
    *,
    failure_kind: str,
    message: str,
    operation_id: str,
    exit_code: int,
    stdout: str = "",
    stderr: str = "",
    cleanup_state: str,
    primary_cause: str | None = None,
) -> CloneCliFailure:
    payload = {
        "protocol_version": PROTOCOL_VERSION,
        "operation_id": operation_id,
        "kind": "clone_failure",
        "failure_kind": failure_kind,
        "message": message,
        "exit_code": exit_code,
        "stdout": _sanitize_text(stdout),
        "stderr": _sanitize_text(stderr),
        "cleanup_state": cleanup_state,
        "primary_cause": primary_cause,
    }
    return CloneCliFailure(exit_code, payload)


def _build_protocol_listener(stdin: Any, state: _CloneProtocolState) -> threading.Thread:
    control_stream = getattr(stdin, "buffer", stdin)

    def _consume_frames() -> None:
        while not state.terminal_event.is_set():
            try:
                raw = control_stream.readline(MAX_CONTROL_FRAME_BYTES + 1)
            except Exception as error:
                state.mark_protocol_error(
                    "Control frame stream failed.",
                    details=_sanitize_text(str(error)),
                )
                return

            if not raw:
                return

            if len(raw) > MAX_CONTROL_FRAME_BYTES:
                state.mark_protocol_error("Control frame exceeded the maximum size.")
                return

            try:
                text = raw.decode("utf-8")
            except UnicodeDecodeError:
                state.mark_protocol_error("Control frame was not valid UTF-8.")
                return

            frame_text = text.strip()
            if not frame_text:
                continue

            try:
                frame = json.loads(frame_text)
            except json.JSONDecodeError:
                state.mark_protocol_error("Control frame was not valid JSON.")
                return

            if not isinstance(frame, dict):
                state.mark_protocol_error("Control frame must be a JSON object.")
                return

            expected_keys = {"protocol_version", "kind", "operation_id", "reason"}
            if set(frame) != expected_keys:
                state.mark_protocol_error("Control frame contained unexpected fields.")
                return

            if frame.get("protocol_version") != PROTOCOL_VERSION:
                state.mark_protocol_error("Unsupported control protocol version.")
                return

            if frame.get("kind") != "cancel":
                state.mark_protocol_error("Unknown control kind.")
                return

            if frame.get("operation_id") != state.operation_id:
                state.mark_protocol_error("Control frame operation ID did not match.")
                return

            if frame.get("reason") not in ALLOWED_CANCEL_REASONS:
                state.mark_protocol_error("Cancellation reason was not allowed.")
                return

            if not state.mark_cancelled():
                return
            return

    thread = threading.Thread(
        target=_consume_frames,
        name="clone-protocol-control",
        daemon=True,
    )
    return thread


def _resolve_stdin_stream(stdin: TextIO | Any | None) -> Any:
    if stdin is None:
        return sys.stdin
    return stdin


def _run_invocation(
    invocation: CloneInvocation,
    *,
    runtime_factory=RepositoryWorkspaceRuntime,
    stdin: TextIO | Any | None = None,
) -> dict[str, Any]:
    runtime = runtime_factory()
    manager = runtime.manager
    protocol_state: _CloneProtocolState | None = None
    listener: threading.Thread | None = None
    if invocation.control_stdin:
        protocol_state = _CloneProtocolState(invocation.operation_id or "")
        listener = _build_protocol_listener(_resolve_stdin_stream(stdin), protocol_state)
        listener.start()

    try:
        result = manager.clone_repository(
            RepositoryCloneRequest(
                source=invocation.source,
                workspace_root=invocation.workspace_root,
                branch=invocation.branch,
            ),
            timeout=timedelta(seconds=invocation.timeout_seconds),
            cancellation_event=protocol_state.cancellation_event if protocol_state else None,
            operation_id=invocation.operation_id,
        )

        if protocol_state is not None:
            with protocol_state._lock:
                if protocol_state.protocol_error_message is not None:
                    failure_kind = "protocol_error"
                    cleanup_state = "completed"
                    if protocol_state.protocol_error_message:
                        raise _build_failure(
                            failure_kind=failure_kind,
                            message=protocol_state.protocol_error_message,
                            operation_id=invocation.operation_id,
                            exit_code=PUBLIC_FAILURE_EXIT_CODES[failure_kind],
                            cleanup_state=cleanup_state,
                        )
                protocol_state.mark_terminal()

        return _clone_success_payload(result)
    except CloneCliFailure:
        raise
    except RepositoryCloneLifecycleError as error:
        if protocol_state is not None:
            with protocol_state._lock:
                protocol_error = protocol_state.protocol_error_message is not None
                if protocol_error and error.kind != RepositoryCloneLifecycleKind.cleanup_failed:
                    protocol_state.mark_terminal()
                    raise _build_failure(
                        failure_kind="protocol_error",
                        message=protocol_state.protocol_error_message or "Protocol control failed.",
                        operation_id=invocation.operation_id,
                        exit_code=PUBLIC_FAILURE_EXIT_CODES["protocol_error"],
                        stdout=error.stdout,
                        stderr=error.stderr,
                        cleanup_state="completed",
                    ) from error

                failure_kind = _map_internal_failure_kind(error.kind)
                cleanup_state = "failed" if failure_kind == "cleanup_failed" else "completed"
                primary_cause = _map_primary_cause(error.primary_cause) if failure_kind == "cleanup_failed" else None
                protocol_state.mark_terminal()
                raise _build_failure(
                    failure_kind=failure_kind,
                    message=error.message,
                    operation_id=invocation.operation_id,
                    exit_code=PUBLIC_FAILURE_EXIT_CODES[failure_kind],
                    stdout=error.stdout,
                    stderr=error.stderr,
                    cleanup_state=cleanup_state,
                    primary_cause=primary_cause,
                ) from error

        failure_kind = _map_internal_failure_kind(error.kind)
        cleanup_state = "failed" if failure_kind == "cleanup_failed" else "completed"
        primary_cause = _map_primary_cause(error.primary_cause) if failure_kind == "cleanup_failed" else None
        raise _build_failure(
            failure_kind=failure_kind,
            message=error.message,
            operation_id=invocation.operation_id or _generate_clone_operation_id(),
            exit_code=PUBLIC_FAILURE_EXIT_CODES[failure_kind],
            stdout=error.stdout,
            stderr=error.stderr,
            cleanup_state=cleanup_state,
            primary_cause=primary_cause,
        ) from error
    except ValueError as error:
        raise _build_failure(
            failure_kind="validation_failed",
            message=str(error),
            operation_id=invocation.operation_id or _generate_clone_operation_id(),
            exit_code=PUBLIC_FAILURE_EXIT_CODES["validation_failed"],
            cleanup_state="not_started",
        ) from error
    except Exception as error:
        raise _build_failure(
            failure_kind="protocol_error",
            message="Unexpected clone CLI failure.",
            operation_id=invocation.operation_id or _generate_clone_operation_id(),
            exit_code=PUBLIC_FAILURE_EXIT_CODES["protocol_error"],
            stderr=str(error),
            cleanup_state="not_started",
        ) from error
    finally:
        if protocol_state is not None:
            protocol_state.mark_terminal()
            if listener is not None and listener.is_alive():
                listener.join(timeout=0.2)


def execute_clone_cli(
    argv: list[str] | None = None,
    *,
    runtime_factory=RepositoryWorkspaceRuntime,
    stdin: TextIO | Any | None = None,
    stdout: TextIO | None = None,
    stderr: TextIO | None = None,
) -> int:
    stdout_stream = stdout or sys.stdout
    stderr_stream = stderr or sys.stderr
    raw_argv = list(sys.argv[1:] if argv is None else argv)

    if _looks_like_help(raw_argv):
        stdout_stream.write(_build_help_text())
        return 0

    fallback_operation_id = _generate_clone_operation_id()
    try:
        invocation = _parse_invocation(raw_argv, fallback_operation_id=fallback_operation_id)
        payload = _run_invocation(
            invocation,
            runtime_factory=runtime_factory,
            stdin=stdin,
        )
    except CloneCliFailure as failure:
        stderr_stream.write(json.dumps(failure.payload, ensure_ascii=False) + "\n")
        return failure.exit_code

    stdout_stream.write(json.dumps(payload, indent=2, ensure_ascii=False) + "\n")
    return 0


def main(argv: list[str] | None = None) -> int:
    return execute_clone_cli(argv=argv)


if __name__ == "__main__":
    raise SystemExit(main())
