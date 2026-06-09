from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from html.parser import HTMLParser
from pathlib import Path
import re
from urllib.parse import urlparse
from urllib.request import url2pathname
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


class _TextCollector(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self._parts: list[str] = []

    def handle_data(self, data: str) -> None:
        text = data.strip()
        if text:
            self._parts.append(text)

    def text(self) -> str:
        return " ".join(self._parts)


class _LocalFilesystemResearchSourceAdapter(ReadOnlyResearchSourceAdapter):
    SOURCE_KIND = "unknown"
    DISCOVERY_PATTERNS: tuple[str, ...] = ()

    def __init__(self, source_root: str | Path | None = None) -> None:
        self.source_root = Path(source_root).expanduser().resolve() if source_root else None

    def discover_sources(self, root: str | Path) -> list[ResearchSourceRef]:
        root_path = Path(root).expanduser().resolve()
        if not root_path.exists():
            return []
        if root_path.is_file():
            return self._build_sources([root_path], base_root=root_path.parent)
        candidates = self._candidate_files(root_path)
        return self._build_sources(candidates, base_root=root_path)

    def load_document(self, source: ResearchSourceRef) -> ResearchDocument:
        local_path = self._resolve_local_path(source)
        text = self._load_text(local_path)
        return ResearchDocument(
            source=source,
            text=text,
            local_path=str(local_path),
        )

    def summarize_source(self, source: ResearchSourceRef) -> str:
        document = self.load_document(source)
        lines = [line.strip() for line in document.text.splitlines() if line.strip()]
        if not lines:
            return f"{source.title or source.identifier}: empty source"
        for line in lines:
            if line.startswith("#"):
                return line.lstrip("# ").strip()
        return " ".join(lines[:3])[:240]

    def _build_sources(self, candidates: list[Path], *, base_root: Path) -> list[ResearchSourceRef]:
        sources: list[ResearchSourceRef] = []
        seen: set[Path] = set()
        for candidate in sorted(candidates):
            candidate = candidate.resolve()
            if candidate in seen:
                continue
            seen.add(candidate)
            metadata = {
                "local_path": str(candidate),
                "size_bytes": candidate.stat().st_size,
                "suffix": candidate.suffix.lower(),
                "source_kind": self.SOURCE_KIND,
            }
            sources.append(
                ResearchSourceRef(
                    source_kind=self.SOURCE_KIND,
                    identifier=candidate.relative_to(base_root).as_posix(),
                    uri=candidate.as_uri(),
                    title=self._title_for_path(candidate),
                    metadata=metadata,
                )
            )
        return sources

    def _candidate_files(self, root_path: Path) -> list[Path]:
        candidates: list[Path] = []
        patterns = self.DISCOVERY_PATTERNS or ("*",)
        for pattern in patterns:
            for candidate in root_path.rglob(pattern):
                if candidate.is_file():
                    candidates.append(candidate)
        return candidates

    def _resolve_local_path(self, source: ResearchSourceRef) -> Path:
        metadata_path = source.metadata.get("local_path")
        if metadata_path:
            return Path(str(metadata_path)).expanduser().resolve()
        if source.uri.startswith("file://"):
            parsed = urlparse(source.uri)
            return Path(url2pathname(parsed.path)).expanduser().resolve()
        raise FileNotFoundError(f"No local path recorded for source {source.identifier}")

    def _title_for_path(self, candidate: Path) -> str:
        return candidate.stem.replace("_", " ").replace("-", " ").title()

    def _load_text(self, local_path: Path) -> str:
        return local_path.read_text(encoding="utf-8", errors="replace")


class LocalPdfResearchSourceAdapter(_LocalFilesystemResearchSourceAdapter):
    SOURCE_KIND = "pdf"
    DISCOVERY_PATTERNS = ("*.pdf",)

    def _load_text(self, local_path: Path) -> str:
        try:
            from pypdf import PdfReader  # type: ignore
        except Exception:
            PdfReader = None  # type: ignore[assignment]

        if PdfReader is not None:
            try:
                reader = PdfReader(str(local_path))
                extracted = "\n".join(page.extract_text() or "" for page in reader.pages).strip()
                if extracted:
                    return extracted
            except Exception:
                pass

        for sidecar_suffix in (".txt", ".md"):
            sidecar = local_path.with_suffix(sidecar_suffix)
            if sidecar.exists():
                return sidecar.read_text(encoding="utf-8", errors="replace")
        raise ValueError(f"Unable to extract PDF text from {local_path}")


class WebsiteResearchSourceAdapter(_LocalFilesystemResearchSourceAdapter):
    SOURCE_KIND = "website"
    REQUIRES_NETWORK_OPT_IN = True
    DISCOVERY_PATTERNS = ("*.html", "*.htm")

    def _load_text(self, local_path: Path) -> str:
        if local_path.suffix.lower() in {".html", ".htm"}:
            parser = _TextCollector()
            parser.feed(local_path.read_text(encoding="utf-8", errors="replace"))
            return re.sub(r"\s+", " ", parser.text()).strip()
        return super()._load_text(local_path)


class TranscriptResearchSourceAdapter(_LocalFilesystemResearchSourceAdapter):
    SOURCE_KIND = "transcript"
    DISCOVERY_PATTERNS = ("*.vtt", "*.srt")


class DocumentationResearchSourceAdapter(_LocalFilesystemResearchSourceAdapter):
    SOURCE_KIND = "documentation"
    DISCOVERY_PATTERNS = ("README*", "*.md", "*.markdown", "*.rst", "*.adoc", "*.txt")
