from __future__ import annotations

import json
import os
import re
import subprocess
import stat
import signal
import threading
import time
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from pathlib import Path
from shutil import rmtree
from subprocess import CompletedProcess, Popen, TimeoutExpired, run
from typing import Any, Protocol
from urllib.parse import urlparse
from uuid import uuid4


DEFAULT_CLONE_TIMEOUT = timedelta(minutes=10)
DEFAULT_TERMINATION_GRACE = timedelta(seconds=20)
DEFAULT_CLEANUP_ALLOWANCE = timedelta(seconds=60)
OPERATION_ID_PATTERN = re.compile(r"^clone_v1_[0-9]{8}T[0-9]{6}Z_[0-9a-f]{32}$")
OWNERSHIP_SENTINEL_NAME = "clone_ownership.json"


@dataclass(frozen=True)
class RepositoryIdentity:
    provider: str
    owner_path: str
    repo_name: str
    source: str
    is_remote: bool = False


@dataclass(frozen=True)
class RepositoryWorkspaceLayout:
    workspace_root: Path
    repository_root: Path
    source_root: Path
    analysis_root: Path
    reports_root: Path
    exports_root: Path
    prompts_root: Path
    metadata_root: Path


@dataclass(frozen=True)
class RepositoryGitState:
    commit: str
    branch: str


@dataclass(frozen=True)
class RepositoryCloneRequest:
    source: str
    workspace_root: str
    branch: str = ""


@dataclass(frozen=True)
class RepositoryCloneResult:
    success: bool
    source: str
    workspace_root: str
    repository_root: str
    source_root: str
    provider: str
    owner_path: str
    repo_name: str
    branch: str
    commit: str
    manifest_path: str
    workspace_manifest_path: str
    command: list[str] = field(default_factory=list)
    stdout: str = ""
    stderr: str = ""
    message: str = ""

    def as_dict(self) -> dict[str, Any]:
        return {
            "success": self.success,
            "source": self.source,
            "workspace_root": self.workspace_root,
            "repository_root": self.repository_root,
            "source_root": self.source_root,
            "provider": self.provider,
            "owner_path": self.owner_path,
            "repo_name": self.repo_name,
            "branch": self.branch,
            "commit": self.commit,
            "manifest_path": self.manifest_path,
            "workspace_manifest_path": self.workspace_manifest_path,
            "command": self.command,
            "stdout": self.stdout,
            "stderr": self.stderr,
            "message": self.message,
        }


class RepositoryCloneLifecycleKind:
    success = "success"
    launch_failure = "launch_failure"
    git_failure = "git_failure"
    timed_out = "timed_out"
    cancelled = "cancelled"
    termination_failure = "termination_failure"
    cleanup_failed = "cleanup_failed"


@dataclass(frozen=True)
class RepositoryCloneLifecycleContext:
    workspace_root: Path
    repository_root: Path
    ownership_sentinel_path: Path
    operation_id: str
    timeout: timedelta = DEFAULT_CLONE_TIMEOUT
    cancellation_event: threading.Event | None = None
    process_terminator: Any | None = None


class RepositoryCloneLifecycleError(RuntimeError):
    def __init__(
        self,
        *,
        kind: str,
        message: str,
        command: list[str],
        stdout: str = "",
        stderr: str = "",
        details: str = "",
        primary_cause: str | None = None,
    ) -> None:
        super().__init__(message)
        self.kind = kind
        self.message = message
        self.command = command
        self.stdout = stdout
        self.stderr = stderr
        self.details = details
        self.primary_cause = primary_cause or kind

    def __str__(self) -> str:
        parts = [self.message]
        if self.stderr.strip():
            parts.append(self.stderr.strip())
        elif self.details.strip():
            parts.append(self.details.strip())
        return "\n".join(parts)


class RepositoryWorkspaceProvider(Protocol):
    def resolve_identity(self, source: str) -> RepositoryIdentity: ...

    def build_layout(
        self,
        workspace_root: Path,
        identity: RepositoryIdentity,
        timestamp: str,
    ) -> RepositoryWorkspaceLayout: ...

    def prepare_workspace(self, layout: RepositoryWorkspaceLayout) -> None: ...

    def build_clone_command(
        self,
        source: str,
        source_root: Path,
        branch: str,
    ) -> list[str]: ...

    def clone_source(
        self,
        command: list[str],
        *,
        cwd: Path | None = None,
        timeout: timedelta = DEFAULT_CLONE_TIMEOUT,
        cancellation_event: threading.Event | None = None,
        lifecycle: RepositoryCloneLifecycleContext | None = None,
    ) -> CompletedProcess[str]: ...

    def read_git_state(
        self,
        source_root: Path,
        *,
        requested_branch: str,
    ) -> RepositoryGitState: ...

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
    ) -> None: ...

    def cleanup_workspace(
        self,
        repository_root: Path,
        *,
        workspace_root: Path | None = None,
        ownership_sentinel_path: Path | None = None,
        operation_id: str | None = None,
    ) -> None: ...


class LocalRepositoryWorkspaceProvider:
    def __init__(
        self,
        *,
        command_runner=run,
        remove_tree=rmtree,
        process_launcher=Popen,
    ) -> None:
        self._command_runner = command_runner
        self._remove_tree = remove_tree
        self._process_launcher = process_launcher

    def resolve_identity(self, source: str) -> RepositoryIdentity:
        local_path = Path(source).expanduser()
        if local_path.exists():
            remote_url = self._git_remote_url(local_path)
            if remote_url:
                parsed = self._parse_remote_source(remote_url)
                if parsed is not None:
                    return parsed
            owner_path = local_path.parent.name if local_path.parent.name else "local"
            return RepositoryIdentity(
                provider="local",
                owner_path=self._safe_segment(owner_path),
                repo_name=self._safe_segment(local_path.name or "repository"),
                source=str(local_path),
                is_remote=False,
            )

        parsed = self._parse_remote_source(source)
        if parsed is not None:
            return parsed

        raise ValueError(f"Unable to resolve repository identity from: {source}")

    def build_layout(
        self,
        workspace_root: Path,
        identity: RepositoryIdentity,
        timestamp: str,
    ) -> RepositoryWorkspaceLayout:
        repository_root = (
            workspace_root
            / identity.provider
            / Path(identity.owner_path)
            / identity.repo_name
            / timestamp
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
        command = [
            "git",
            "clone",
            "--no-tags",
            "--single-branch",
        ]
        if branch.strip():
            command.extend(["--branch", branch.strip()])
        command.extend([source, str(source_root)])
        return command

    def clone_source(
        self,
        command: list[str],
        *,
        cwd: Path | None = None,
        timeout: timedelta = DEFAULT_CLONE_TIMEOUT,
        cancellation_event: threading.Event | None = None,
        lifecycle: RepositoryCloneLifecycleContext | None = None,
    ) -> CompletedProcess[str]:
        active_lifecycle = lifecycle or self._build_lifecycle_context(
            command,
            cwd=cwd,
            timeout=timeout,
            cancellation_event=cancellation_event,
        )
        try:
            self._validate_clone_target(active_lifecycle)
            self._write_ownership_sentinel(active_lifecycle)
            process = self._launch_clone_process(command, cwd=cwd)
            stdout, stderr, exit_code = self._await_clone_process(
                process,
                timeout=active_lifecycle.timeout,
                cancellation_event=active_lifecycle.cancellation_event,
                terminator=active_lifecycle.process_terminator,
                lifecycle=active_lifecycle,
            )
            if exit_code != 0:
                self._cleanup_owned_workspace(
                    active_lifecycle,
                    primary_cause=RepositoryCloneLifecycleKind.git_failure,
                )
                raise RepositoryCloneLifecycleError(
                    kind=RepositoryCloneLifecycleKind.git_failure,
                    message="Git clone failed.",
                    command=command,
                    stdout=stdout,
                    stderr=stderr,
                )

            return CompletedProcess(command, exit_code, stdout=stdout, stderr=stderr)
        except RepositoryCloneLifecycleError:
            raise
        except Exception as error:
            self._cleanup_owned_workspace(
                active_lifecycle,
                primary_cause=RepositoryCloneLifecycleKind.launch_failure,
            )
            raise RepositoryCloneLifecycleError(
                kind=RepositoryCloneLifecycleKind.launch_failure,
                message="Unable to clone repository.",
                command=command,
                details=str(error),
            ) from error

    def read_git_state(
        self,
        source_root: Path,
        *,
        requested_branch: str,
    ) -> RepositoryGitState:
        commit = self._git_output(
            ["git", "-C", str(source_root), "rev-parse", "HEAD"],
        )
        branch = self._git_output(
            ["git", "-C", str(source_root), "branch", "--show-current"],
        )
        if not branch.strip():
            branch = requested_branch.strip() or "detached"
        return RepositoryGitState(commit=commit, branch=branch)

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
        manifest = {
            "source": source,
            "provider": identity.provider,
            "owner_path": identity.owner_path,
            "repo_name": identity.repo_name,
            "workspace_root": str(workspace_root),
            "repository_root": str(layout.repository_root),
            "source_root": str(layout.source_root),
            "analysis_root": str(layout.analysis_root),
            "reports_root": str(layout.reports_root),
            "exports_root": str(layout.exports_root),
            "prompts_root": str(layout.prompts_root),
            "metadata_root": str(layout.metadata_root),
            "clone_timestamp": timestamp,
            "branch": branch,
            "commit": commit,
            "command": command,
        }
        manifest_path = layout.repository_root / "clone_manifest.json"
        workspace_manifest_path = layout.repository_root / "workspace_manifest.json"
        manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        workspace_manifest_path.write_text(
            json.dumps(self._workspace_manifest(layout, identity, timestamp), indent=2),
            encoding="utf-8",
        )

    def cleanup_workspace(
        self,
        repository_root: Path,
        *,
        workspace_root: Path | None = None,
        ownership_sentinel_path: Path | None = None,
        operation_id: str | None = None,
    ) -> None:
        _validate_cleanup_target(
            repository_root,
            workspace_root=workspace_root,
            ownership_sentinel_path=ownership_sentinel_path,
            operation_id=operation_id,
        )
        if repository_root.exists():
            self._remove_tree(repository_root, ignore_errors=True)

    def _parse_remote_source(self, source: str) -> RepositoryIdentity | None:
        source = source.strip()
        if not source:
            return None

        scp_match = re.match(
            r"^(?P<user>[^@]+)@(?P<host>[^:]+):(?P<path>.+)$",
            source,
        )
        if scp_match:
            host = scp_match.group("host")
            path_value = scp_match.group("path")
            return self._identity_from_host_path(host, path_value, source)

        parsed = urlparse(source)
        if parsed.scheme and parsed.netloc:
            host = parsed.netloc
            path_value = parsed.path
            return self._identity_from_host_path(host, path_value, source)

        return None

    def _identity_from_host_path(
        self,
        host: str,
        path_value: str,
        source: str,
    ) -> RepositoryIdentity:
        clean_path = path_value.strip().lstrip("/")
        clean_path = clean_path[:-4] if clean_path.lower().endswith(".git") else clean_path
        segments = [segment for segment in clean_path.split("/") if segment]
        if not segments:
            raise ValueError(f"Could not parse repository path from source: {source}")

        repo_name = self._safe_segment(segments[-1])
        owner_path = "/".join(self._safe_segment(segment) for segment in segments[:-1])
        if not owner_path:
            owner_path = "root"

        return RepositoryIdentity(
            provider=self._safe_segment(host.lower()),
            owner_path=owner_path,
            repo_name=repo_name,
            source=source,
            is_remote=True,
        )

    def _workspace_manifest(
        self,
        layout: RepositoryWorkspaceLayout,
        identity: RepositoryIdentity,
        timestamp: str,
    ) -> dict[str, Any]:
        return {
            "provider": identity.provider,
            "owner_path": identity.owner_path,
            "repo_name": identity.repo_name,
            "workspace_root": str(layout.workspace_root),
            "repository_root": str(layout.repository_root),
            "source_root": str(layout.source_root),
            "analysis_root": str(layout.analysis_root),
            "reports_root": str(layout.reports_root),
            "exports_root": str(layout.exports_root),
            "prompts_root": str(layout.prompts_root),
            "metadata_root": str(layout.metadata_root),
            "clone_timestamp": timestamp,
            "folders": {
                "source": "source",
                "analysis": "analysis",
                "reports": "reports",
                "exports": "exports",
                "prompts": "prompts",
                "metadata": "metadata",
            },
        }

    def _run_command(
        self,
        command: list[str],
        *,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        return self._command_runner(
            command,
            cwd=str(cwd) if cwd is not None else None,
            capture_output=True,
            text=True,
            check=False,
        )

    def _git_output(self, command: list[str]) -> str:
        process = self._run_command(command)
        if process.returncode != 0:
            return ""
        return process.stdout.strip()

    def _git_remote_url(self, local_path: Path) -> str:
        process = self._run_command(
            ["git", "-C", str(local_path), "remote", "get-url", "origin"],
        )
        if process.returncode != 0:
            return ""
        return process.stdout.strip()

    def _safe_segment(self, value: str) -> str:
        cleaned = re.sub(r"[^A-Za-z0-9._-]+", "-", value.strip())
        cleaned = cleaned.strip("-._")
        return cleaned or "local"

    def _build_lifecycle_context(
        self,
        command: list[str],
        *,
        cwd: Path | None,
        timeout: timedelta,
        cancellation_event: threading.Event | None,
    ) -> RepositoryCloneLifecycleContext:
        repository_root = Path(command[-1]).expanduser().resolve().parent
        workspace_root = repository_root
        if len(repository_root.parents) >= 4:
            workspace_root = repository_root.parents[3]
        return RepositoryCloneLifecycleContext(
            workspace_root=workspace_root,
            repository_root=repository_root,
            ownership_sentinel_path=repository_root / OWNERSHIP_SENTINEL_NAME,
            operation_id=_generate_clone_operation_id(),
            timeout=timeout,
            cancellation_event=cancellation_event,
            process_terminator=None,
        )

    def _validate_clone_target(
        self,
        lifecycle: RepositoryCloneLifecycleContext,
    ) -> None:
        _validate_operation_id(lifecycle.operation_id)
        if lifecycle.repository_root.resolve(strict=False) == Path(
            lifecycle.repository_root.anchor,
        ).resolve(strict=False):
            raise RepositoryCloneLifecycleError(
                kind=RepositoryCloneLifecycleKind.launch_failure,
                message="Refusing to clone into a filesystem root.",
                command=[str(lifecycle.repository_root)],
            )
        if not lifecycle.ownership_sentinel_path.parent.exists():
            raise RepositoryCloneLifecycleError(
                kind=RepositoryCloneLifecycleKind.launch_failure,
                message="Clone workspace metadata directory is unavailable.",
                command=[str(lifecycle.repository_root)],
            )

    def _write_ownership_sentinel(
        self,
        lifecycle: RepositoryCloneLifecycleContext,
    ) -> None:
        sentinel = lifecycle.ownership_sentinel_path
        sentinel.parent.mkdir(parents=True, exist_ok=True)
        payload = {
            "protocol_version": "clone_v1",
            "operation_id": lifecycle.operation_id,
            "workspace_root": str(lifecycle.workspace_root.resolve(strict=False)),
            "repository_root": str(lifecycle.repository_root.resolve(strict=False)),
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        sentinel.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    def _finalize_ownership_sentinel(
        self,
        lifecycle: RepositoryCloneLifecycleContext,
    ) -> None:
        _remove_clone_ownership_sentinel(lifecycle.ownership_sentinel_path)

    def _launch_clone_process(
        self,
        command: list[str],
        *,
        cwd: Path | None,
    ) -> Popen[str]:
        launcher_kwargs: dict[str, Any] = {
            "cwd": str(cwd) if cwd is not None else None,
            "stdout": subprocess.PIPE,
            "stderr": subprocess.PIPE,
            "text": True,
            "shell": False,
        }
        if os.name == "nt":
            launcher_kwargs["creationflags"] = getattr(
                subprocess,
                "CREATE_NEW_PROCESS_GROUP",
                0,
            )
        else:
            launcher_kwargs["start_new_session"] = True
        return self._process_launcher(command, **launcher_kwargs)

    def _await_clone_process(
        self,
        process: Popen[str],
        *,
        timeout: timedelta,
        cancellation_event: threading.Event | None,
        terminator: Any | None,
        lifecycle: RepositoryCloneLifecycleContext,
    ) -> tuple[str, str, int]:
        deadline = time.monotonic() + max(timeout.total_seconds(), 0.0)
        while True:
            if cancellation_event is not None and cancellation_event.is_set():
                return self._interrupt_clone_process(
                    process,
                    lifecycle=lifecycle,
                    outcome=RepositoryCloneLifecycleKind.cancelled,
                    terminator=terminator,
                )

            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return self._interrupt_clone_process(
                    process,
                    lifecycle=lifecycle,
                    outcome=RepositoryCloneLifecycleKind.timed_out,
                    terminator=terminator,
                )

            try:
                stdout, stderr = process.communicate(
                    timeout=min(0.25, remaining),
                )
                return (
                    stdout or "",
                    stderr or "",
                    process.returncode if process.returncode is not None else 0,
                )
            except TimeoutExpired:
                continue

    def _interrupt_clone_process(
        self,
        process: Popen[str],
        *,
        lifecycle: RepositoryCloneLifecycleContext,
        outcome: str,
        terminator: Any | None,
    ) -> tuple[str, str, int]:
        terminated = self._terminate_owned_process(process, terminator=terminator)
        stdout, stderr = self._drain_clone_output(process)
        if not terminated and process.poll() is None:
            self._cleanup_owned_workspace(
                lifecycle,
                primary_cause=outcome,
            )
            raise RepositoryCloneLifecycleError(
                kind=RepositoryCloneLifecycleKind.termination_failure,
                message="Unable to terminate the owned clone process.",
                command=[],
                stdout=stdout,
                stderr=stderr,
                primary_cause=outcome,
        )
        self._cleanup_owned_workspace(
            lifecycle,
            primary_cause=outcome,
        )
        raise RepositoryCloneLifecycleError(
            kind=outcome,
            message=(
                "Timed out while cloning the repository."
                if outcome == RepositoryCloneLifecycleKind.timed_out
                else "Clone was cancelled."
            ),
            command=[],
            stdout=stdout,
            stderr=stderr,
            primary_cause=outcome,
        )

    def _terminate_owned_process(
        self,
        process: Popen[str],
        *,
        terminator: Any | None,
    ) -> bool:
        if process.poll() is not None:
            return True

        try:
            if terminator is not None:
                terminator(process)
            else:
                self._default_terminate_owned_process(process)
        except Exception:
            return False

        if process.poll() is not None:
            return True

        try:
            process.wait(timeout=DEFAULT_TERMINATION_GRACE.total_seconds())
        except TimeoutExpired:
            try:
                self._force_terminate_owned_process(process)
            except Exception:
                return False
            try:
                process.wait(timeout=DEFAULT_CLEANUP_ALLOWANCE.total_seconds())
            except TimeoutExpired:
                return False

        return process.poll() is not None

    def _default_terminate_owned_process(self, process: Popen[str]) -> None:
        if os.name == "nt":
            subprocess.run(
                ["taskkill", "/PID", str(process.pid), "/T"],
                check=False,
                capture_output=True,
                text=True,
                shell=False,
            )
            return

        os.killpg(process.pid, signal.SIGTERM)

    def _force_terminate_owned_process(self, process: Popen[str]) -> None:
        if os.name == "nt":
            subprocess.run(
                ["taskkill", "/PID", str(process.pid), "/T", "/F"],
                check=False,
                capture_output=True,
                text=True,
                shell=False,
            )
            return

        os.killpg(process.pid, signal.SIGKILL)

    def _drain_clone_output(self, process: Popen[str]) -> tuple[str, str]:
        try:
            stdout, stderr = process.communicate(
                timeout=DEFAULT_CLEANUP_ALLOWANCE.total_seconds(),
            )
        except TimeoutExpired:
            stdout, stderr = process.communicate()
        return stdout or "", stderr or ""

    def _cleanup_owned_workspace(
        self,
        lifecycle: RepositoryCloneLifecycleContext,
        *,
        primary_cause: str,
    ) -> None:
        try:
            self.cleanup_workspace(
                lifecycle.repository_root,
                workspace_root=lifecycle.workspace_root,
                ownership_sentinel_path=lifecycle.ownership_sentinel_path,
                operation_id=lifecycle.operation_id,
            )
        except Exception as error:
            raise RepositoryCloneLifecycleError(
                kind=RepositoryCloneLifecycleKind.cleanup_failed,
                message="Cleanup of the owned clone workspace failed.",
                command=[],
                details=str(error),
                primary_cause=primary_cause,
            ) from error


class RepositoryWorkspaceRuntime:
    def __init__(
        self,
        provider: RepositoryWorkspaceProvider | None = None,
        manager: "RepositoryWorkspaceManager" | None = None,
    ) -> None:
        self.provider = provider or LocalRepositoryWorkspaceProvider()
        self.manager = manager or RepositoryWorkspaceManager(provider=self.provider)


class RepositoryWorkspaceManager:
    def __init__(self, provider: RepositoryWorkspaceProvider | None = None) -> None:
        self._provider = provider or LocalRepositoryWorkspaceProvider()

    def clone_repository(
        self,
        request: RepositoryCloneRequest,
        *,
        timeout: timedelta = DEFAULT_CLONE_TIMEOUT,
        cancellation_event: threading.Event | None = None,
        process_terminator: Any | None = None,
        operation_id: str | None = None,
    ) -> RepositoryCloneResult:
        source = request.source.strip()
        if not source:
            raise ValueError("A source repository path or URL is required.")
        if operation_id is not None:
            _validate_operation_id(operation_id)

        workspace_root = Path(request.workspace_root).expanduser().resolve()
        identity = self._provider.resolve_identity(source)
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
        layout = self._provider.build_layout(workspace_root, identity, timestamp)
        if layout.repository_root.exists() or layout.source_root.exists():
            raise RepositoryCloneLifecycleError(
                kind=RepositoryCloneLifecycleKind.launch_failure,
                message="Repository workspace already exists.",
                command=[source],
            )
        self._provider.prepare_workspace(layout)
        operation_id = operation_id or _generate_clone_operation_id()
        ownership_sentinel_path = layout.metadata_root / OWNERSHIP_SENTINEL_NAME
        lifecycle = RepositoryCloneLifecycleContext(
            workspace_root=workspace_root,
            repository_root=layout.repository_root,
            ownership_sentinel_path=ownership_sentinel_path,
            operation_id=operation_id,
            timeout=timeout,
            cancellation_event=cancellation_event,
            process_terminator=process_terminator,
        )

        clone_command = self._provider.build_clone_command(
            source,
            layout.source_root,
            request.branch,
        )
        try:
            process = self._provider.clone_source(
                clone_command,
                cwd=layout.repository_root.parent,
                timeout=timeout,
                cancellation_event=cancellation_event,
                lifecycle=lifecycle,
            )
            if process.returncode != 0:
                try:
                    self._provider.cleanup_workspace(
                        layout.repository_root,
                        workspace_root=workspace_root,
                        ownership_sentinel_path=ownership_sentinel_path,
                        operation_id=operation_id,
                    )
                except Exception as cleanup_error:
                    raise RepositoryCloneLifecycleError(
                        kind=RepositoryCloneLifecycleKind.cleanup_failed,
                        message="Repository clone finalization failed.",
                        command=clone_command,
                        details=str(cleanup_error),
                        primary_cause=RepositoryCloneLifecycleKind.git_failure,
                    ) from cleanup_error
                raise RepositoryCloneLifecycleError(
                    kind=RepositoryCloneLifecycleKind.git_failure,
                    message="Git clone failed.",
                    command=clone_command,
                    stdout=process.stdout,
                    stderr=process.stderr,
                    primary_cause=RepositoryCloneLifecycleKind.git_failure,
                )
            git_state = self._provider.read_git_state(
                layout.source_root,
                requested_branch=request.branch,
            )
            self._provider.write_manifests(
                source=source,
                workspace_root=workspace_root,
                layout=layout,
                identity=identity,
                timestamp=timestamp,
                branch=git_state.branch,
                commit=git_state.commit,
                command=clone_command,
            )
            _validate_clone_artifacts(layout)
            _remove_clone_ownership_sentinel(ownership_sentinel_path)
            return RepositoryCloneResult(
                success=True,
                source=source,
                workspace_root=str(workspace_root),
                repository_root=str(layout.repository_root),
                source_root=str(layout.source_root),
                provider=identity.provider,
                owner_path=identity.owner_path,
                repo_name=identity.repo_name,
                branch=git_state.branch,
                commit=git_state.commit,
                manifest_path=str(layout.repository_root / "clone_manifest.json"),
                workspace_manifest_path=str(
                    layout.repository_root / "workspace_manifest.json",
                ),
                command=clone_command,
                stdout=process.stdout,
                stderr=process.stderr,
                message=f"Cloned {source} into {layout.source_root}",
            )
        except RepositoryCloneLifecycleError as error:
            if error.kind == RepositoryCloneLifecycleKind.launch_failure and (
                error.primary_cause == error.kind
            ):
                raise
            raise
        except Exception as error:
            try:
                self._provider.cleanup_workspace(
                    layout.repository_root,
                    workspace_root=workspace_root,
                    ownership_sentinel_path=ownership_sentinel_path,
                    operation_id=operation_id,
                )
            except Exception as cleanup_error:
                raise RepositoryCloneLifecycleError(
                    kind=RepositoryCloneLifecycleKind.cleanup_failed,
                    message="Repository clone finalization failed.",
                    command=clone_command,
                    details=str(cleanup_error),
                    primary_cause=RepositoryCloneLifecycleKind.git_failure,
                ) from cleanup_error
            raise RepositoryCloneLifecycleError(
                kind=RepositoryCloneLifecycleKind.cleanup_failed,
                message="Repository clone finalization failed.",
                command=clone_command,
                details=str(error),
                primary_cause=RepositoryCloneLifecycleKind.git_failure,
            ) from error


def _generate_clone_operation_id(
    now: datetime | None = None,
    token: str | None = None,
) -> str:
    timestamp = (now or datetime.now(timezone.utc)).strftime("%Y%m%dT%H%M%SZ")
    uuid_hex = (token or uuid4().hex).lower()
    operation_id = f"clone_v1_{timestamp}_{uuid_hex}"
    _validate_operation_id(operation_id)
    return operation_id


def _validate_operation_id(operation_id: str) -> None:
    if not OPERATION_ID_PATTERN.fullmatch(operation_id):
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.launch_failure,
            message="Invalid clone operation identifier.",
            command=[],
            details=operation_id,
        )


def _remove_clone_ownership_sentinel(sentinel_path: Path) -> None:
    if sentinel_path.exists():
        sentinel_path.unlink()


def _validate_clone_artifacts(layout: RepositoryWorkspaceLayout) -> None:
    manifest_path = layout.repository_root / "clone_manifest.json"
    workspace_manifest_path = layout.repository_root / "workspace_manifest.json"
    if not manifest_path.exists() or not workspace_manifest_path.exists():
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Clone manifest validation failed.",
            command=[],
        )


def _is_reparse_point(path: Path) -> bool:
    try:
        stat_result = os.lstat(path)
    except FileNotFoundError:
        return False

    file_attributes = getattr(stat_result, "st_file_attributes", 0)
    reparse_flag = getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0)
    return bool(file_attributes & reparse_flag) or path.is_symlink()


def _path_is_descendant(candidate: Path, root: Path) -> bool:
    try:
        candidate_resolved = candidate.resolve(strict=False)
        root_resolved = root.resolve(strict=False)
    except Exception:
        return False
    return candidate_resolved == root_resolved or root_resolved in candidate_resolved.parents


def _has_reparse_or_symlink_ancestor(path: Path, stop_at: Path | None = None) -> bool:
    resolved_stop = stop_at.resolve(strict=False) if stop_at is not None else None
    current = path
    while True:
        if current.exists() and _is_reparse_point(current):
            return True
        if resolved_stop is not None and current == resolved_stop:
            break
        parent = current.parent
        if parent == current:
            break
        current = parent
    return False


def _validate_cleanup_target(
    repository_root: Path,
    *,
    workspace_root: Path | None,
    ownership_sentinel_path: Path | None,
    operation_id: str | None,
) -> None:
    if ownership_sentinel_path is None or not ownership_sentinel_path.exists():
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup ownership sentinel is missing.",
            command=[],
        )

    try:
        sentinel_data = json.loads(ownership_sentinel_path.read_text(encoding="utf-8"))
    except Exception as error:
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup ownership sentinel could not be read.",
            command=[],
            details=str(error),
        ) from error

    if not isinstance(sentinel_data, dict):
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup ownership sentinel is malformed.",
            command=[],
        )

    sentinel_operation_id = str(sentinel_data.get("operation_id", ""))
    if operation_id is not None and sentinel_operation_id != operation_id:
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup ownership sentinel does not match the active operation.",
            command=[],
        )
    _validate_operation_id(sentinel_operation_id)

    resolved_repository_root = repository_root.resolve(strict=False)
    resolved_workspace_root = (
        workspace_root.resolve(strict=False) if workspace_root is not None else None
    )
    sentinel_workspace_root = Path(
        str(sentinel_data.get("workspace_root", "")),
    ).expanduser().resolve(strict=False)
    sentinel_repository_root = Path(
        str(sentinel_data.get("repository_root", "")),
    ).expanduser().resolve(strict=False)

    if resolved_workspace_root is not None and sentinel_workspace_root != resolved_workspace_root:
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup ownership sentinel workspace root mismatch.",
            command=[],
        )
    if sentinel_repository_root != resolved_repository_root:
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup ownership sentinel repository root mismatch.",
            command=[],
        )
    if resolved_workspace_root is not None and resolved_repository_root == resolved_workspace_root:
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Refusing to delete the workspace root.",
            command=[],
        )

    if resolved_repository_root == Path(resolved_repository_root.anchor).resolve(
        strict=False,
    ):
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Refusing to delete a drive root.",
            command=[],
        )

    home_root = Path.home().resolve(strict=False)
    user_profile_value = os.environ.get("USERPROFILE", "").strip()
    user_profile_root = (
        Path(user_profile_value).expanduser().resolve(strict=False)
        if user_profile_value
        else None
    )

    if resolved_repository_root == home_root or (
        user_profile_root and resolved_repository_root == user_profile_root
    ):
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Refusing to delete a user profile root.",
            command=[],
        )

    dashboard_root = Path.cwd().resolve(strict=False)
    if resolved_repository_root == dashboard_root:
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Refusing to delete the Dashboard repository root.",
            command=[],
        )

    if workspace_root is not None and not _path_is_descendant(
        resolved_repository_root,
        workspace_root,
    ):
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup target is outside the configured workspace root.",
            command=[],
        )

    if (resolved_repository_root / ".git").exists():
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup target appears to be a pre-existing repository.",
            command=[],
        )

    if _has_reparse_or_symlink_ancestor(resolved_repository_root, stop_at=workspace_root):
        raise RepositoryCloneLifecycleError(
            kind=RepositoryCloneLifecycleKind.cleanup_failed,
            message="Cleanup target has a symlink or reparse-point ancestor.",
            command=[],
        )


def _format_failure(process: CompletedProcess[str]) -> str:
    parts = ["Git clone failed."]
    if process.stdout.strip():
        parts.append(process.stdout.strip())
    if process.stderr.strip():
        parts.append(process.stderr.strip())
    return "\n".join(parts)
