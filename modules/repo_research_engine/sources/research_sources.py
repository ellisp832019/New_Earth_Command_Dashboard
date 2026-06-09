from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Mapping


@dataclass(frozen=True)
class ResearchSourceRef:
    source_kind: str
    identifier: str
    uri: str
    title: str = ""
    metadata: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class ResearchDocument:
    source: ResearchSourceRef
    text: str
    extracted_at: str = ""
    local_path: str = ""


class ReadOnlyResearchSourceAdapter(ABC):
    SOURCE_KIND = "unknown"
    REQUIRES_NETWORK_OPT_IN = False

    @abstractmethod
    def discover_sources(self, root: str | Path) -> list[ResearchSourceRef]:
        raise NotImplementedError

    @abstractmethod
    def load_document(self, source: ResearchSourceRef) -> ResearchDocument:
        raise NotImplementedError

    @abstractmethod
    def summarize_source(self, source: ResearchSourceRef) -> str:
        raise NotImplementedError


class LocalPdfResearchSourceAdapter(ReadOnlyResearchSourceAdapter):
    SOURCE_KIND = "pdf"


class WebsiteResearchSourceAdapter(ReadOnlyResearchSourceAdapter):
    SOURCE_KIND = "website"
    REQUIRES_NETWORK_OPT_IN = True


class TranscriptResearchSourceAdapter(ReadOnlyResearchSourceAdapter):
    SOURCE_KIND = "transcript"


class DocumentationResearchSourceAdapter(ReadOnlyResearchSourceAdapter):
    SOURCE_KIND = "documentation"

