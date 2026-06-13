"""Dashboard-side bridge for GAIA.

This file is intentionally small and safe. The dashboard should call this bridge,
not allow the AI runtime to directly touch internal modules.
"""
from __future__ import annotations

import json
import urllib.request
from dataclasses import dataclass, asdict
from typing import Any, Dict


@dataclass
class GaiaCommand:
    source: str = "gaia"
    intent: str = ""
    module: str = ""
    action: str = ""
    payload: Dict[str, Any] | None = None
    requires_confirmation: bool = False
    sensitivity: str = "low"

    def to_dict(self) -> Dict[str, Any]:
        data = asdict(self)
        data["payload"] = data["payload"] or {}
        return data


class GaiaBridge:
    def __init__(self, runtime_url: str = "http://localhost:8765") -> None:
        self.runtime_url = runtime_url.rstrip("/")

    def health(self) -> Dict[str, Any]:
        return self._get("/health")

    def send_command(self, command: GaiaCommand) -> Dict[str, Any]:
        return self._post("/command", command.to_dict())

    def send_conversation(
        self,
        query: str,
        transcript: str = "",
        context: Dict[str, Any] | None = None,
    ) -> Dict[str, Any]:
        return self._post(
            "/conversation",
            {
                "query": query,
                "transcript": transcript,
                "context": context or {},
            },
        )

    def _get(self, path: str) -> Dict[str, Any]:
        with urllib.request.urlopen(self.runtime_url + path, timeout=5) as response:
            return json.loads(response.read().decode("utf-8"))

    def _post(self, path: str, payload: Dict[str, Any]) -> Dict[str, Any]:
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            self.runtime_url + path,
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
