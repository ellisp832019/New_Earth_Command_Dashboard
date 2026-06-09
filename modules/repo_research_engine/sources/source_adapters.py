from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from hashlib import sha256
import json
from pathlib import Path
import re
from typing import Any, Mapping, Sequence


@dataclass(frozen=True)
class RemoteRepositoryRef:
    provider: str
    owner: str
    name: str
    url: str
    default_branch: str = "main"


@dataclass(frozen=True)
class RemoteFileRef:
    path: str
    sha: str = ""
    size_bytes: int = 0
    language: str = "Unknown"
    kind: str = "file"


@dataclass(frozen=True)
class RemoteRepositorySnapshot:
    repository: RemoteRepositoryRef
    files: tuple[RemoteFileRef, ...] = ()
    metadata: Mapping[str, Any] = field(default_factory=dict)
    retrieved_at: str = ""
    source_type: str = "read-only"


class ReadOnlyRepositorySourceAdapter(ABC):
    REQUIRES_NETWORK = False

    @property
    @abstractmethod
    def provider_name(self) -> str:
        raise NotImplementedError

    @abstractmethod
    def search_repositories(self, query: str, *, limit: int = 20) -> list[RemoteRepositoryRef]:
        raise NotImplementedError

    @abstractmethod
    def fetch_repository_snapshot(self, repository: RemoteRepositoryRef) -> RemoteRepositorySnapshot:
        raise NotImplementedError

    @abstractmethod
    def fetch_file_tree(self, repository: RemoteRepositoryRef, *, path: str = "") -> list[RemoteFileRef]:
        raise NotImplementedError

    @abstractmethod
    def fetch_file_text(self, repository: RemoteRepositoryRef, path: str) -> str:
        raise NotImplementedError


class _LocalSnapshotRepositorySourceAdapter(ReadOnlyRepositorySourceAdapter):
    _METADATA_FILENAMES = ("repo.json", "repository.json", "snapshot.json", "export_manifest.json")
    _TEXT_EXTENSIONS = {
        ".c",
        ".cpp",
        ".css",
        ".dart",
        ".go",
        ".h",
        ".hpp",
        ".html",
        ".ini",
        ".json",
        ".js",
        ".kt",
        ".md",
        ".mmd",
        ".puml",
        ".py",
        ".rb",
        ".rs",
        ".sh",
        ".toml",
        ".tsx",
        ".txt",
        ".yaml",
        ".yml",
    }

    def __init__(self, snapshot_root: str | Path | None = None) -> None:
        self.snapshot_root = Path(snapshot_root).expanduser().resolve() if snapshot_root else None

    def search_repositories(self, query: str, *, limit: int = 20) -> list[RemoteRepositoryRef]:
        if not query or self.snapshot_root is None or not self.snapshot_root.exists():
            return []

        query_tokens = [token for token in re.split(r"\s+", query.lower()) if token]
        matches: list[tuple[int, RemoteRepositoryRef]] = []
        for repo_root in self._iter_repository_roots():
            repository = self._build_repository_ref(repo_root)
            if repository.provider.lower() != self.provider_name.lower():
                continue
            haystack = " ".join(
                [
                    repository.provider,
                    repository.owner,
                    repository.name,
                    repository.url,
                    str(repo_root),
                    json.dumps(self._load_metadata(repo_root), sort_keys=True),
                ]
            ).lower()
            score = sum(haystack.count(token) for token in query_tokens)
            if score:
                matches.append((score, repository))

        matches.sort(key=lambda item: (-item[0], item[1].owner.lower(), item[1].name.lower()))
        return [repository for _, repository in matches[:limit]]

    def fetch_repository_snapshot(self, repository: RemoteRepositoryRef) -> RemoteRepositorySnapshot:
        repo_root = self._resolve_repository_root(repository)
        files = tuple(self._collect_files(repo_root))
        metadata = {
            "snapshot_root": str(self.snapshot_root) if self.snapshot_root else "",
            "repository_root": str(repo_root),
            "metadata": self._load_metadata(repo_root),
            "provider": repository.provider,
        }
        return RemoteRepositorySnapshot(
            repository=repository,
            files=files,
            metadata=metadata,
            source_type="local-read-only-snapshot",
        )

    def fetch_file_tree(self, repository: RemoteRepositoryRef, *, path: str = "") -> list[RemoteFileRef]:
        repo_root = self._resolve_repository_root(repository)
        return self._collect_files(repo_root, path=path)

    def fetch_file_text(self, repository: RemoteRepositoryRef, path: str) -> str:
        repo_root = self._resolve_repository_root(repository)
        file_path = self._safe_path_join(repo_root, path)
        if not file_path.exists() or not file_path.is_file():
            raise FileNotFoundError(path)
        return file_path.read_text(encoding="utf-8", errors="replace")

    def _iter_repository_roots(self) -> Sequence[Path]:
        assert self.snapshot_root is not None
        discovered: list[Path] = []
        seen: set[Path] = set()
        for marker in ("**/.git", *[f"**/{name}" for name in self._METADATA_FILENAMES]):
            for marker_path in self.snapshot_root.glob(marker):
                repo_root = marker_path.parent if marker_path.name != ".git" else marker_path.parent
                if repo_root not in seen and repo_root.is_dir():
                    seen.add(repo_root)
                    discovered.append(repo_root)
        return discovered

    def _resolve_repository_root(self, repository: RemoteRepositoryRef) -> Path:
        if self.snapshot_root is None:
            raise FileNotFoundError("Snapshot root has not been configured.")

        matches: list[Path] = []
        for repo_root in self._iter_repository_roots():
            candidate = self._build_repository_ref(repo_root)
            if (
                candidate.provider.lower() == repository.provider.lower()
                and candidate.owner.lower() == repository.owner.lower()
                and candidate.name.lower() == repository.name.lower()
            ):
                matches.append(repo_root)
        if not matches:
            raise FileNotFoundError(f"Unable to locate local snapshot for {repository.provider}/{repository.owner}/{repository.name}")
        return matches[0]

    def _build_repository_ref(self, repo_root: Path) -> RemoteRepositoryRef:
        metadata = self._load_metadata(repo_root)
        relative_parts = repo_root.relative_to(self.snapshot_root).parts if self.snapshot_root else repo_root.parts
        provider = metadata.get("provider") or self.provider_name
        owner = metadata.get("owner") or (relative_parts[-2] if len(relative_parts) >= 2 else "local")
        name = metadata.get("name") or repo_root.name
        url = metadata.get("url") or f"local://{provider.lower()}/{owner}/{name}"
        default_branch = metadata.get("default_branch") or metadata.get("branch") or "main"
        return RemoteRepositoryRef(
            provider=str(provider),
            owner=str(owner),
            name=str(name),
            url=str(url),
            default_branch=str(default_branch),
        )

    def _load_metadata(self, repo_root: Path) -> dict[str, Any]:
        for metadata_filename in self._METADATA_FILENAMES:
            metadata_path = repo_root / metadata_filename
            if metadata_path.exists():
                try:
                    loaded = json.loads(metadata_path.read_text(encoding="utf-8"))
                except (OSError, json.JSONDecodeError):
                    return {}
                return loaded if isinstance(loaded, dict) else {}
        return {}

    def _collect_files(self, repo_root: Path, path: str = "") -> list[RemoteFileRef]:
        root = self._safe_path_join(repo_root, path) if path else repo_root
        if not root.exists():
            return []

        files: list[RemoteFileRef] = []
        for item in sorted(root.rglob("*")):
            if item.is_dir():
                continue
            relative_path = item.relative_to(repo_root).as_posix()
            if path and not relative_path.startswith(Path(path).as_posix().rstrip("/") + "/") and relative_path != Path(path).as_posix():
                continue
            files.append(
                RemoteFileRef(
                    path=relative_path,
                    sha=self._file_sha(item),
                    size_bytes=item.stat().st_size,
                    language=self._language_for_path(item),
                    kind="file",
                )
            )
        return files

    def _safe_path_join(self, repo_root: Path, path: str) -> Path:
        target = (repo_root / path).resolve()
        if repo_root not in target.parents and target != repo_root:
            raise ValueError(f"Path escapes repository root: {path}")
        return target

    def _language_for_path(self, file_path: Path) -> str:
        suffix = file_path.suffix.lower()
        if suffix in {".md", ".markdown"}:
            return "Markdown"
        if suffix in {".yaml", ".yml"}:
            return "YAML"
        if suffix == ".json":
            return "JSON"
        if suffix == ".dart":
            return "Dart"
        if suffix == ".py":
            return "Python"
        if suffix == ".sh":
            return "Shell"
        if suffix == ".js":
            return "JavaScript"
        if suffix == ".ts":
            return "TypeScript"
        if suffix == ".html":
            return "HTML"
        if suffix == ".css":
            return "CSS"
        if suffix == ".toml":
            return "TOML"
        if suffix == ".ini":
            return "INI"
        if suffix == ".mmd":
            return "Mermaid"
        if suffix == ".puml":
            return "PlantUML"
        return "Unknown"

    def _file_sha(self, file_path: Path) -> str:
        digest = sha256()
        with file_path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(8192), b""):
                digest.update(chunk)
        return digest.hexdigest()


class GitHubSourceAdapter(_LocalSnapshotRepositorySourceAdapter):
    @property
    def provider_name(self) -> str:
        return "GitHub"


class GitLabSourceAdapter(_LocalSnapshotRepositorySourceAdapter):
    @property
    def provider_name(self) -> str:
        return "GitLab"


class BitbucketSourceAdapter(_LocalSnapshotRepositorySourceAdapter):
    @property
    def provider_name(self) -> str:
        return "Bitbucket"
