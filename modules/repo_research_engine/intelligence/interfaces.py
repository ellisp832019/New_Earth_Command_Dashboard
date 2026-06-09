from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Any, Mapping, Sequence


@dataclass(frozen=True)
class AiGenerationRequest:
    prompt: str
    system_message: str = ""
    context: tuple[str, ...] = ()
    temperature: float = 0.2
    max_tokens: int = 2048


@dataclass(frozen=True)
class AiGenerationResponse:
    text: str
    model_name: str = ""
    provider_name: str = ""
    metadata: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class KnowledgeChunk:
    chunk_id: str
    source_uri: str
    text: str
    title: str = ""
    metadata: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class RagSearchHit:
    chunk_id: str
    score: float
    snippet: str
    source_uri: str
    metadata: Mapping[str, Any] = field(default_factory=dict)


class LocalAiProvider(ABC):
    REQUIRES_NETWORK = False

    @property
    @abstractmethod
    def provider_name(self) -> str:
        raise NotImplementedError

    @abstractmethod
    def generate(self, request: AiGenerationRequest) -> AiGenerationResponse:
        raise NotImplementedError

    @abstractmethod
    def embed(self, texts: Sequence[str]) -> list[list[float]]:
        raise NotImplementedError


class RagSearchIndex(ABC):
    REQUIRES_NETWORK = False

    @abstractmethod
    def index_documents(self, chunks: Sequence[KnowledgeChunk]) -> None:
        raise NotImplementedError

    @abstractmethod
    def search(self, query: str, *, limit: int = 10) -> list[RagSearchHit]:
        raise NotImplementedError

    @abstractmethod
    def clear(self) -> None:
        raise NotImplementedError

