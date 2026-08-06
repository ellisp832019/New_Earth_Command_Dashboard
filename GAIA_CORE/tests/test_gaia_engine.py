from __future__ import annotations

import os
import sys
import tempfile
import urllib.error
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

GAIA_CORE_ROOT = ROOT / "GAIA_CORE"
if str(GAIA_CORE_ROOT) not in sys.path:
    sys.path.insert(0, str(GAIA_CORE_ROOT))


class GaiaConversationEngineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = Path(tempfile.mkdtemp())
        os.environ["GAIA_USB_ROOT"] = str(self.temp_dir)

        for module_name in ("gaia_runtime", "gaia_engine"):
            sys.modules.pop(module_name, None)

        global gaia_engine
        import gaia_engine

        self.gaia_engine = gaia_engine

    def tearDown(self) -> None:
        os.environ.pop("GAIA_USB_ROOT", None)
        for module_name in ("gaia_runtime", "gaia_engine"):
            sys.modules.pop(module_name, None)

    def test_engine_returns_mocked_ollama_reply(self) -> None:
        class StubEngine(self.gaia_engine.GaiaConversationEngine):
            def _chat(self, messages: list[dict[str, str]]) -> str:  # type: ignore[override]
                self.captured_messages = messages
                return "Local Ollama reply."

        engine = StubEngine()
        response = engine.handle(
            {
                "query": "Continue the conversation",
                "context": {"project": "Gaia", "mode": "conversation"},
            }
        )

        self.assertEqual(response["status"], "ok")
        self.assertEqual(response["provider"], "ollama")
        self.assertEqual(response["reply"], "Local Ollama reply.")
        self.assertIn("project=Gaia", response["context_summary"])
        self.assertTrue((self.temp_dir / "03_MEMORY" / "gaia_conversation_memory.json").exists())
        self.assertGreaterEqual(len(engine.captured_messages), 2)

    def test_engine_falls_back_when_chat_is_unavailable(self) -> None:
        class FailingEngine(self.gaia_engine.GaiaConversationEngine):
            def _chat(self, messages: list[dict[str, str]]) -> str:  # type: ignore[override]
                raise urllib.error.URLError("offline")

        engine = FailingEngine()
        response = engine.handle({"query": "Say hello"})

        self.assertEqual(response["status"], "fallback")
        self.assertEqual(response["provider"], "ollama")
        self.assertIn("GAIA is ready offline", response["reply"])
        self.assertIn("Say hello", response["reply"])


if __name__ == "__main__":
    unittest.main()
