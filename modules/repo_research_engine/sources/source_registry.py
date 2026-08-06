from __future__ import annotations

from dataclasses import dataclass
from typing import Type

from .source_adapters import (
    BitbucketSourceAdapter,
    GitHubSourceAdapter,
    GitLabSourceAdapter,
    ReadOnlyRepositorySourceAdapter,
)


@dataclass(frozen=True)
class RepositorySourceProviderSpec:
    name: str
    adapter_class: Type[ReadOnlyRepositorySourceAdapter]
    description: str
    read_only: bool = True
    requires_network_opt_in: bool = False


class RepositorySourceAdapterRegistry:
    def __init__(self) -> None:
        self._providers = {
            "bitbucket": RepositorySourceProviderSpec(
                name="Bitbucket",
                adapter_class=BitbucketSourceAdapter,
                description="Read-only repository snapshots for Bitbucket-style repository layouts.",
            ),
            "github": RepositorySourceProviderSpec(
                name="GitHub",
                adapter_class=GitHubSourceAdapter,
                description="Read-only repository snapshots for GitHub-style repository layouts.",
            ),
            "gitlab": RepositorySourceProviderSpec(
                name="GitLab",
                adapter_class=GitLabSourceAdapter,
                description="Read-only repository snapshots for GitLab-style repository layouts.",
            ),
        }

    def list_supported_providers(self) -> list[RepositorySourceProviderSpec]:
        return [self._providers[key] for key in sorted(self._providers)]

    def get_provider(self, provider_name: str) -> RepositorySourceProviderSpec:
        normalized = self._normalize(provider_name)
        if normalized not in self._providers:
            available = ", ".join(spec.name for spec in self.list_supported_providers())
            raise ValueError(
                f"Unsupported repository source provider: {provider_name}. Available providers: {available}",
            )
        return self._providers[normalized]

    def create_adapter(
        self,
        provider_name: str,
        snapshot_root: str | None = None,
    ) -> ReadOnlyRepositorySourceAdapter:
        provider = self.get_provider(provider_name)
        return provider.adapter_class(snapshot_root)

    def describe_providers(self) -> list[dict[str, str | bool]]:
        return [
            {
                "name": spec.name,
                "description": spec.description,
                "read_only": spec.read_only,
                "requires_network_opt_in": spec.requires_network_opt_in,
            }
            for spec in self.list_supported_providers()
        ]

    def _normalize(self, provider_name: str) -> str:
        return provider_name.strip().lower()
