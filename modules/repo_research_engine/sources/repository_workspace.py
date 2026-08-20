from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from shutil import rmtree
from subprocess import CompletedProcess, run
from typing import Any, Protocol
from urllib.parse import urlparse


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

    def cleanup_workspace(self, repository_root: Path) -> None: ...


class LocalRepositoryWorkspaceProvider:
    def __init__(
        self,
        *,
        command_runner=run,
        remove_tree=rmtree,
    ) -> None:
        self._command_runner = command_runner
        self._remove_tree = remove_tree

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
    ) -> CompletedProcess[str]:
        return self._run_command(command, cwd=cwd)

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

    def cleanup_workspace(self, repository_root: Path) -> None:
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

    def clone_repository(self, request: RepositoryCloneRequest) -> RepositoryCloneResult:
        source = request.source.strip()
        if not source:
            raise ValueError("A source repository path or URL is required.")

        workspace_root = Path(request.workspace_root).expanduser().resolve()
        identity = self._provider.resolve_identity(source)
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        layout = self._provider.build_layout(workspace_root, identity, timestamp)
        self._provider.prepare_workspace(layout)

        clone_command = self._provider.build_clone_command(
            source,
            layout.source_root,
            request.branch,
        )
        process = self._provider.clone_source(
            clone_command,
            cwd=layout.repository_root.parent,
        )
        if process.returncode != 0:
            self._provider.cleanup_workspace(layout.repository_root)
            raise RuntimeError(_format_failure(process))

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
            workspace_manifest_path=str(layout.repository_root / "workspace_manifest.json"),
            command=clone_command,
            stdout=process.stdout,
            stderr=process.stderr,
            message=f"Cloned {source} into {layout.source_root}",
        )


def _format_failure(process: CompletedProcess[str]) -> str:
    parts = ["Git clone failed."]
    if process.stdout.strip():
        parts.append(process.stdout.strip())
    if process.stderr.strip():
        parts.append(process.stderr.strip())
    return "\n".join(parts)
