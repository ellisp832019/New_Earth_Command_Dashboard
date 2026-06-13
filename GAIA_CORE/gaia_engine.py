from __future__ import annotations

import json
import logging
import os
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from gaia_runtime import get_memory_path, get_log_path, load_config

LOG_FILE = get_log_path("gaia_engine.log")
logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)

DEFAULT_MODEL = "qwen2.5:7b"
DEFAULT_CHAT_URL = "http://localhost:11434/v1"
DEFAULT_HISTORY_LIMIT = 12


@dataclass
class GaiaConversationTurn:
    role: str
    content: str


@dataclass
class GaiaConversationEngine:
    config: dict[str, Any] = field(default_factory=load_config)

    def __post_init__(self) -> None:
        self.model = self._string_config(
            "default_model",
            env_keys=("GAIA_OLLAMA_MODEL", "OLLAMA_MODEL"),
            default=DEFAULT_MODEL,
        )
        self.chat_base_url = self._normalize_chat_base_url(
            self._string_config(
                "ollama_url",
                env_keys=("GAIA_OLLAMA_URL", "OLLAMA_URL"),
                default=DEFAULT_CHAT_URL,
            )
        )
        self.history_limit = self._int_config(
            "conversation_history_limit",
            default=DEFAULT_HISTORY_LIMIT,
        )
        self.memory_file = get_memory_path("gaia_conversation_memory.json")
        self.history = self._load_history()

    def handle(self, request: dict[str, Any]) -> dict[str, Any]:
        query = self._normalize_text(
            request.get("query")
            or request.get("transcript")
            or request.get("text")
            or ""
        )
        context = request.get("context")
        context_summary = self._format_context(context if isinstance(context, dict) else {})

        if not query:
            return {
                "reply": "GAIA is ready offline. Say what you want help with, and I’ll keep it local.",
                "status": "ok",
                "provider": "ollama",
                "model": self.model,
                "context_summary": context_summary,
            }

        messages = self._build_messages(query=query, context_summary=context_summary)
        try:
            reply = self._chat(messages)
            status = "ok"
        except Exception as exc:
            logging.exception("GAIA conversation failed; using fallback response")
            reply = self._fallback_reply(query=query, context_summary=context_summary, reason=str(exc))
            status = "fallback"
        else:
            try:
                self._append_turns(query=query, reply=reply)
            except Exception:
                logging.exception("GAIA conversation history could not be saved")

        return {
            "reply": reply,
            "status": status,
            "provider": "ollama",
            "model": self.model,
            "echo": query,
            "context_summary": context_summary,
        }

    def _build_messages(self, query: str, context_summary: str) -> list[dict[str, str]]:
        messages: list[dict[str, str]] = [
            {"role": "system", "content": self._system_prompt()},
        ]

        for turn in self.history[-self.history_limit :]:
            messages.append({"role": turn.role, "content": turn.content})

        user_lines = [
            f"User request: {query}",
            f"Context: {context_summary or 'none'}",
            "Keep the reply short, practical, and calm.",
            "If the request is conversational, continue naturally.",
            "If the request sounds like a command, summarize the safest next step.",
        ]
        messages.append({"role": "user", "content": "\n".join(user_lines)})
        return messages

    def _chat(self, messages: list[dict[str, str]]) -> str:
        uri = f"{self.chat_base_url}/chat/completions"
        payload = json.dumps(
            {
                "model": self.model,
                "messages": messages,
                "temperature": 0.35,
                "stream": False,
            }
        ).encode("utf-8")

        request = urllib.request.Request(
            uri,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )

        with urllib.request.urlopen(request, timeout=30) as response:
            body = response.read().decode("utf-8")

        decoded = json.loads(body)
        if not isinstance(decoded, dict):
            raise ValueError("Unexpected Ollama response format.")

        choices = decoded.get("choices")
        if not isinstance(choices, list) or not choices:
            raise ValueError("Ollama response did not include choices.")

        first_choice = choices[0]
        if not isinstance(first_choice, dict):
            raise ValueError("Ollama choice payload was malformed.")

        message = first_choice.get("message")
        if not isinstance(message, dict):
            raise ValueError("Ollama message payload was malformed.")

        content = message.get("content")
        if isinstance(content, str) and content.strip():
            return self._normalize_text(content)

        raise ValueError("Ollama response content was empty.")

    def _append_turns(self, query: str, reply: str) -> None:
        self.history.extend(
            [
                GaiaConversationTurn(role="user", content=query),
                GaiaConversationTurn(role="assistant", content=reply),
            ]
        )
        self.history = self.history[-self.history_limit * 2 :]
        self._save_history()

    def _load_history(self) -> list[GaiaConversationTurn]:
        if not self.memory_file.exists():
            return []

        try:
            raw = json.loads(self.memory_file.read_text(encoding="utf-8"))
        except Exception:
            return []

        turns: list[GaiaConversationTurn] = []
        if isinstance(raw, dict):
            raw_turns = raw.get("history", [])
        else:
            raw_turns = raw

        if not isinstance(raw_turns, list):
            return []

        for item in raw_turns:
            if not isinstance(item, dict):
                continue
            role = self._normalize_text(str(item.get("role", "")))
            content = self._normalize_text(str(item.get("content", "")))
            if role in {"user", "assistant"} and content:
                turns.append(GaiaConversationTurn(role=role, content=content))

        return turns[-self.history_limit * 2 :]

    def _save_history(self) -> None:
        payload = {
            "history": [turn.__dict__ for turn in self.history[-self.history_limit * 2 :]],
        }
        self.memory_file.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    def _fallback_reply(self, query: str, context_summary: str, reason: str) -> str:
        context_note = f" Context: {context_summary}." if context_summary else ""
        logging.info("GAIA fallback reason: %s", reason)
        return (
            "GAIA is ready offline. "
            f"I heard: {query}.{context_note} "
            "I can keep talking, summarize the thread, or shape the next local step."
        ).replace("  ", " ").strip()

    def _system_prompt(self) -> str:
        return "\n".join(
            [
                "You are GAIA, Guardian AI Assistant for the New Earth Command Dashboard.",
                "Stay local-first and offline-first.",
                "Keep replies short, warm, and practical.",
                "Prefer calm New Earth wording.",
                "Do not mention internal policies unless the user asks.",
                "Do not invent external access or cloud dependencies.",
                "If the user is asking for a command, summarize the safest next action.",
                "If the user is having a conversation, continue naturally and keep state across turns.",
            ]
        )

    def _format_context(self, context: dict[str, Any]) -> str:
        if not context:
            return ""

        parts: list[str] = []
        for key in ("mode", "project", "thread", "intent", "module", "action", "summary", "notes"):
            value = context.get(key)
            if isinstance(value, str) and value.strip():
                parts.append(f"{key}={self._normalize_text(value)}")
            elif value is not None and not isinstance(value, (dict, list)):
                parts.append(f"{key}={value}")

        extras = context.get("extras")
        if isinstance(extras, dict):
            for key, value in extras.items():
                if isinstance(value, str) and value.strip():
                    parts.append(f"{key}={self._normalize_text(value)}")
                elif value is not None and not isinstance(value, (dict, list)):
                    parts.append(f"{key}={value}")

        return " | ".join(parts)

    def _string_config(self, key: str, env_keys: tuple[str, ...], default: str) -> str:
        for env_key in env_keys:
            value = os.environ.get(env_key, "").strip()
            if value:
                return value

        value = self.config.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()

        return default

    def _int_config(self, key: str, default: int) -> int:
        value = self.config.get(key)
        if isinstance(value, int) and value > 0:
            return value
        if isinstance(value, str):
            try:
                parsed = int(value.strip())
            except ValueError:
                return default
            if parsed > 0:
                return parsed
        return default

    @staticmethod
    def _normalize_chat_base_url(raw: str) -> str:
        trimmed = raw.strip()
        if not trimmed:
            return DEFAULT_CHAT_URL

        without_trailing = trimmed[:-1] if trimmed.endswith("/") else trimmed
        if without_trailing.endswith("/v1"):
            return without_trailing
        return f"{without_trailing}/v1"

    @staticmethod
    def _normalize_text(value: str) -> str:
        return " ".join(value.strip().split())


_ENGINE: GaiaConversationEngine | None = None


def get_engine() -> GaiaConversationEngine:
    global _ENGINE
    if _ENGINE is None:
        _ENGINE = GaiaConversationEngine()
    return _ENGINE


def initialize_runtime() -> None:
    config = load_config()
    logging.info("GAIA engine initialized with config: %s", config)
    print("GAIA engine initialized.")


def run() -> None:
    initialize_runtime()
    print("GAIA engine running. Use gaia_bridge_server.py to expose commands.")


def handle_conversation_request(request: dict[str, Any]) -> dict[str, Any]:
    return get_engine().handle(request)


if __name__ == "__main__":
    run()
