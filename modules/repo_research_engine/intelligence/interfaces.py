from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
import hashlib
import math
import re
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


class DeterministicLocalAiProvider(LocalAiProvider):
    VECTOR_SIZE = 64

    @property
    def provider_name(self) -> str:
        return "DeterministicLocal"

    def generate(self, request: AiGenerationRequest) -> AiGenerationResponse:
        context_text = "\n".join(request.context).strip()
        summary_source = context_text or request.prompt
        summary = self._summarize(summary_source)
        sections = [
            f"Provider: {self.provider_name}",
            f"Model: local-rule-based",
        ]
        if request.system_message:
            sections.append(f"System: {self._compact(request.system_message)}")
        if request.context:
            sections.append("Context:")
            sections.extend(f"- {self._compact(item)}" for item in request.context[:5])
        sections.append(f"Prompt: {self._compact(request.prompt)}")
        sections.append(f"Response: {summary}")
        return AiGenerationResponse(
            text="\n".join(sections).strip(),
            model_name="local-rule-based",
            provider_name=self.provider_name,
            metadata={
                "temperature": request.temperature,
                "max_tokens": request.max_tokens,
                "context_count": len(request.context),
            },
        )

    def embed(self, texts: Sequence[str]) -> list[list[float]]:
        vectors: list[list[float]] = []
        for text in texts:
            vector = [0.0] * self.VECTOR_SIZE
            for token in self._tokens(text):
                bucket = int(hashlib.sha256(token.encode("utf-8")).hexdigest(), 16) % self.VECTOR_SIZE
                vector[bucket] += 1.0
            magnitude = math.sqrt(sum(value * value for value in vector))
            if magnitude:
                vector = [value / magnitude for value in vector]
            vectors.append(vector)
        return vectors

    def _tokens(self, text: str) -> list[str]:
        return re.findall(r"[a-z0-9]+", text.lower())

    def _compact(self, text: str) -> str:
        return re.sub(r"\s+", " ", text).strip()

    def _summarize(self, text: str) -> str:
        compact = self._compact(text)
        if not compact:
            return "No content available."
        sentence_parts = re.split(r"(?<=[.!?])\s+", compact)
        return " ".join(sentence_parts[:3])[:400]


class InMemoryRagSearchIndex(RagSearchIndex):
    def __init__(self, embedding_provider: LocalAiProvider | None = None) -> None:
        self.embedding_provider = embedding_provider or DeterministicLocalAiProvider()
        self._chunks: list[KnowledgeChunk] = []
        self._embeddings: list[list[float]] = []

    def index_documents(self, chunks: Sequence[KnowledgeChunk]) -> None:
        self._chunks = list(chunks)
        self._embeddings = self.embedding_provider.embed([chunk.text for chunk in self._chunks]) if self._chunks else []

    def search(self, query: str, *, limit: int = 10) -> list[RagSearchHit]:
        compact_query = query.strip()
        if not compact_query or not self._chunks:
            return []

        query_embedding = self.embedding_provider.embed([compact_query])[0]
        scored_hits: list[tuple[float, int, RagSearchHit]] = []
        for index, (chunk, embedding) in enumerate(zip(self._chunks, self._embeddings)):
            score = self._cosine_similarity(query_embedding, embedding)
            if score <= 0:
                continue
            scored_hits.append(
                (
                    score,
                    index,
                    RagSearchHit(
                        chunk_id=chunk.chunk_id,
                        score=score,
                        snippet=self._snippet(chunk.text),
                        source_uri=chunk.source_uri,
                        metadata={**dict(chunk.metadata), "title": chunk.title},
                    ),
                )
            )

        scored_hits.sort(key=lambda item: (-item[0], item[1]))
        return [hit for _, _, hit in scored_hits[:limit]]

    def clear(self) -> None:
        self._chunks.clear()
        self._embeddings.clear()

    def _cosine_similarity(self, left: Sequence[float], right: Sequence[float]) -> float:
        if not left or not right:
            return 0.0
        return sum(l * r for l, r in zip(left, right))

    def _snippet(self, text: str, length: int = 200) -> str:
        compact = re.sub(r"\s+", " ", text).strip()
        return compact[:length]
