from __future__ import annotations

from dataclasses import dataclass
from typing import Callable

from .interfaces import (
    DeterministicLocalAiProvider,
    InMemoryRagSearchIndex,
    LocalAiProvider,
    RagSearchIndex,
)


@dataclass(frozen=True)
class LocalAiProviderSpec:
    name: str
    provider_factory: Callable[[], LocalAiProvider]
    description: str
    model_name: str
    deterministic: bool = True
    requires_network_opt_in: bool = False


@dataclass(frozen=True)
class RagSearchIndexSpec:
    name: str
    index_factory: Callable[[LocalAiProvider | None], RagSearchIndex]
    description: str
    deterministic: bool = True
    requires_network_opt_in: bool = False


class LocalAiProviderRegistry:
    def __init__(self) -> None:
        self._providers: dict[str, LocalAiProviderSpec] = {}
        self.register_provider(
            LocalAiProviderSpec(
                name="DeterministicLocal",
                provider_factory=DeterministicLocalAiProvider,
                description="Rule-based local AI provider for offline-safe summarisation and embeddings.",
                model_name="local-rule-based",
            ),
        )

    def register_provider(self, spec: LocalAiProviderSpec) -> None:
        self._providers[self._normalize(spec.name)] = spec

    def list_supported_providers(self) -> list[LocalAiProviderSpec]:
        return [self._providers[key] for key in sorted(self._providers)]

    def get_provider(self, provider_name: str) -> LocalAiProviderSpec:
        normalized = self._normalize(provider_name)
        if normalized not in self._providers:
            available = ", ".join(spec.name for spec in self.list_supported_providers())
            raise ValueError(
                f"Unsupported local AI provider: {provider_name}. Available providers: {available}",
            )
        return self._providers[normalized]

    def create_provider(self, provider_name: str) -> LocalAiProvider:
        provider = self.get_provider(provider_name)
        return provider.provider_factory()

    def describe_providers(self) -> list[dict[str, str | bool]]:
        return [
            {
                "name": spec.name,
                "model_name": spec.model_name,
                "description": spec.description,
                "deterministic": spec.deterministic,
                "requires_network_opt_in": spec.requires_network_opt_in,
            }
            for spec in self.list_supported_providers()
        ]

    def _normalize(self, provider_name: str) -> str:
        return provider_name.strip().lower()


class RagSearchIndexRegistry:
    def __init__(self) -> None:
        self._indexes: dict[str, RagSearchIndexSpec] = {}
        self.register_index(
            RagSearchIndexSpec(
                name="InMemoryLocal",
                index_factory=lambda embedding_provider=None: InMemoryRagSearchIndex(embedding_provider),
                description="Local in-memory RAG index with deterministic embeddings by default.",
            ),
        )

    def register_index(self, spec: RagSearchIndexSpec) -> None:
        self._indexes[self._normalize(spec.name)] = spec

    def list_supported_indexes(self) -> list[RagSearchIndexSpec]:
        return [self._indexes[key] for key in sorted(self._indexes)]

    def get_index(self, index_name: str) -> RagSearchIndexSpec:
        normalized = self._normalize(index_name)
        if normalized not in self._indexes:
            available = ", ".join(spec.name for spec in self.list_supported_indexes())
            raise ValueError(
                f"Unsupported RAG index: {index_name}. Available indexes: {available}",
            )
        return self._indexes[normalized]

    def create_index(self, index_name: str, embedding_provider: LocalAiProvider | None = None) -> RagSearchIndex:
        index = self.get_index(index_name)
        return index.index_factory(embedding_provider)

    def describe_indexes(self) -> list[dict[str, str | bool]]:
        return [
            {
                "name": spec.name,
                "description": spec.description,
                "deterministic": spec.deterministic,
                "requires_network_opt_in": spec.requires_network_opt_in,
            }
            for spec in self.list_supported_indexes()
        ]

    def _normalize(self, index_name: str) -> str:
        return index_name.strip().lower()
