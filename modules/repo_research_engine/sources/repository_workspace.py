from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from shutil import rmtree
from subprocess import CompletedProcess, run
from typing import Any, Mapping
import json
import re
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


class RepositoryWorkspaceManager:
    def clone_repository(self, request: RepositoryCloneRequest) -> RepositoryCloneResult:
        source = request.source.strip()
        if not source:
            raise ValueError("A source repository path or URL is required.")

        workspace_root = Path(request.workspace_root).expanduser().resolve()
        identity = self._resolve_identity(source)
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        layout = self._build_layout(workspace_root, identity, timestamp)
        layout.repository_root.parent.mkdir(parents=True, exist_ok=True)

        clone_command = self._build_clone_command(source, layout.source_root, request.branch)
        process = self._run_command(clone_command, cwd=layout.repository_root.parent)
        if process.returncode != 0:
            if layout.repository_root.exists():
                rmtree(layout.repository_root, ignore_errors=True)
            raise RuntimeError(self._format_failure(process))

        commit = self._git_output(
            ["git", "-C", str(layout.source_root), "rev-parse", "HEAD"],
        )
        branch = self._git_output(
            ["git", "-C", str(layout.source_root), "branch", "--show-current"],
        )
        if not branch.strip():
            branch = request.branch.strip() or "detached"

        layout.analysis_root.mkdir(parents=True, exist_ok=True)
        layout.reports_root.mkdir(parents=True, exist_ok=True)
        layout.exports_root.mkdir(parents=True, exist_ok=True)
        layout.prompts_root.mkdir(parents=True, exist_ok=True)
        layout.metadata_root.mkdir(parents=True, exist_ok=True)

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
            "command": clone_command,
        }
        manifest_path = layout.repository_root / "clone_manifest.json"
        workspace_manifest_path = layout.repository_root / "workspace_manifest.json"
        manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
        workspace_manifest_path.write_text(
            json.dumps(self._workspace_manifest(layout, identity, timestamp), indent=2),
            encoding="utf-8",
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
            branch=branch,
            commit=commit,
            manifest_path=str(manifest_path),
            workspace_manifest_path=str(workspace_manifest_path),
            command=clone_command,
            stdout=process.stdout,
            stderr=process.stderr,
            message=f"Cloned {source} into {layout.source_root}",
        )

    def _resolve_identity(self, source: str) -> RepositoryIdentity:
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

    def _build_layout(
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

    def _build_clone_command(
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

    def _run_command(
        self,
        command: list[str],
        *,
        cwd: Path | None = None,
    ) -> CompletedProcess[str]:
        return run(
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

    def _format_failure(self, process: CompletedProcess[str]) -> str:
        parts = ["Git clone failed."]
        if process.stdout.strip():
            parts.append(process.stdout.strip())
        if process.stderr.strip():
            parts.append(process.stderr.strip())
        return "\n".join(parts)

    def _safe_segment(self, value: str) -> str:
        cleaned = re.sub(r"[^A-Za-z0-9._-]+", "-", value.strip())
        cleaned = cleaned.strip("-._")
        return cleaned or "local"
