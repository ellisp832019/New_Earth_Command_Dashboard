from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Type

from .research_sources import (
    DocumentationResearchSourceAdapter,
    LocalPdfResearchSourceAdapter,
    ReadOnlyResearchSourceAdapter,
    TranscriptResearchSourceAdapter,
    WebsiteResearchSourceAdapter,
)


@dataclass(frozen=True)
class ResearchSourceProviderSpec:
    name: str
    adapter_class: Type[ReadOnlyResearchSourceAdapter]
    description: str
    source_kind: str
    requires_network_opt_in: bool


class ResearchSourceAdapterRegistry:
    def __init__(self) -> None:
        self._providers = {
            "documentation": ResearchSourceProviderSpec(
                name="Documentation",
                adapter_class=DocumentationResearchSourceAdapter,
                description="Local documentation and note ingestion for markdown-style sources.",
                source_kind="documentation",
                requires_network_opt_in=False,
            ),
            "pdf": ResearchSourceProviderSpec(
                name="PDF",
                adapter_class=LocalPdfResearchSourceAdapter,
                description="Local PDF ingestion with optional text sidecars for safe offline extraction.",
                source_kind="pdf",
                requires_network_opt_in=False,
            ),
            "transcript": ResearchSourceProviderSpec(
                name="Transcript",
                adapter_class=TranscriptResearchSourceAdapter,
                description="Local transcript ingestion for VTT and SRT files.",
                source_kind="transcript",
                requires_network_opt_in=False,
            ),
            "website": ResearchSourceProviderSpec(
                name="Website",
                adapter_class=WebsiteResearchSourceAdapter,
                description="Local HTML snapshot ingestion with explicit network opt-in for future live fetch work.",
                source_kind="website",
                requires_network_opt_in=True,
            ),
        }

    def list_supported_sources(self) -> list[ResearchSourceProviderSpec]:
        return [self._providers[key] for key in sorted(self._providers)]

    def get_provider(self, source_kind: str) -> ResearchSourceProviderSpec:
        normalized = self._normalize(source_kind)
        if normalized not in self._providers:
            available = ", ".join(spec.name for spec in self.list_supported_sources())
            raise ValueError(
                f"Unsupported research source kind: {source_kind}. Available sources: {available}",
            )
        return self._providers[normalized]

    def create_adapter(
        self,
        source_kind: str,
        source_root: str | Path | None = None,
    ) -> ReadOnlyResearchSourceAdapter:
        provider = self.get_provider(source_kind)
        return provider.adapter_class(source_root)

    def describe_sources(self) -> list[dict[str, str | bool]]:
        return [
            {
                "name": spec.name,
                "source_kind": spec.source_kind,
                "description": spec.description,
                "requires_network_opt_in": spec.requires_network_opt_in,
            }
            for spec in self.list_supported_sources()
        ]

    def _normalize(self, source_kind: str) -> str:
        return source_kind.strip().lower()
