from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
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


class GitHubSourceAdapter(ReadOnlyRepositorySourceAdapter):
    @property
    def provider_name(self) -> str:
        return "GitHub"


class GitLabSourceAdapter(ReadOnlyRepositorySourceAdapter):
    @property
    def provider_name(self) -> str:
        return "GitLab"


class BitbucketSourceAdapter(ReadOnlyRepositorySourceAdapter):
    @property
    def provider_name(self) -> str:
        return "Bitbucket"

