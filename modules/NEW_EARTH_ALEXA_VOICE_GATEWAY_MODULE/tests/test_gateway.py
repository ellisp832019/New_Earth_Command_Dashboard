from __future__ import annotations

import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from fastapi import HTTPException

from src.voice_gateway import app as gateway


class VoiceGatewayTests(unittest.TestCase):
    def setUp(self) -> None:
        self._env_patch = patch.dict(
            os.environ,
            {
                "NEW_EARTH_VOICE_GATEWAY_SECRET": "test-secret",
                "ALEXA_GATEWAY_ENABLED": "true",
            },
            clear=False,
        )
        self._env_patch.start()
        self.addCleanup(self._env_patch.stop)

    def _request(self, command: str, intent: str = "TestIntent", slots=None):
        return gateway.VoiceCommandRequest(
            source="local-test",
            intent=intent,
            command=command,
            slots=slots or {},
        )

    def test_allowed_command_succeeds(self) -> None:
        with patch.object(gateway, "dashboard_call", return_value="Dashboard handled it"):
            response = gateway.route_voice_command(
                self._request("dashboard.summary.today", "GetTodaySummaryIntent"),
                x_gateway_secret="test-secret",
            )

        self.assertEqual(response.decision, "allowed")
        self.assertEqual(response.speech, "Dashboard handled it")

    def test_blocked_command_is_rejected(self) -> None:
        response = gateway.route_voice_command(
            self._request("filesystem.delete", "DeleteFileIntent"),
            x_gateway_secret="test-secret",
        )

        self.assertEqual(response.decision, "blocked")
        self.assertIn("blocked from Alexa", response.speech)

    def test_unknown_command_is_rejected(self) -> None:
        response = gateway.route_voice_command(
            self._request("unknown.command", "UnknownIntent"),
            x_gateway_secret="test-secret",
        )

        self.assertEqual(response.decision, "denied")
        self.assertIn("not registered", response.speech)

    def test_missing_token_is_rejected(self) -> None:
        with self.assertRaises(HTTPException) as exc_info:
            gateway.route_voice_command(
                self._request("dashboard.summary.today", "GetTodaySummaryIntent"),
                x_gateway_secret=None,
            )

        self.assertEqual(exc_info.exception.status_code, 401)

    def test_audit_log_is_written(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            audit_file = Path(temp_dir) / "voice_audit.jsonl"
            original_audit_path = gateway.CONFIG["logging"]["audit_log_path"]
            gateway.CONFIG["logging"]["audit_log_path"] = str(audit_file)
            try:
                with patch.object(
                    gateway,
                    "dashboard_call",
                    return_value="Dashboard handled it",
                ):
                    gateway.route_voice_command(
                        self._request(
                            "microgrow.status.read",
                            "GetMicroGrowStatusIntent",
                        ),
                        x_gateway_secret="test-secret",
                    )

                self.assertTrue(audit_file.exists())
                contents = audit_file.read_text(encoding="utf-8").strip().splitlines()
                self.assertGreaterEqual(len(contents), 1)
                self.assertIn("forwarded_to_dashboard_adapter", contents[-1])
                self.assertIn("microgrow.status.read", contents[-1])
            finally:
                gateway.CONFIG["logging"]["audit_log_path"] = original_audit_path

    def test_microgrow_status_is_read_only(self) -> None:
        response = gateway.route_voice_command(
            self._request("microgrow.status.read", "GetMicroGrowStatusIntent"),
            x_gateway_secret="test-secret",
        )

        self.assertEqual(response.decision, "allowed")
        self.assertEqual(response.command, "microgrow.status.read")

    def test_dangerous_action_cannot_pass_through(self) -> None:
        response = gateway.route_voice_command(
            self._request("hardware.dangerous.control", "DangerousHardwareIntent"),
            x_gateway_secret="test-secret",
        )

        self.assertEqual(response.decision, "blocked")
        self.assertEqual(response.command, "hardware.dangerous.control")

    def test_kill_switch_rejects_requests(self) -> None:
        with patch.dict(os.environ, {"ALEXA_GATEWAY_ENABLED": "false"}, clear=False):
            with self.assertRaises(HTTPException) as exc_info:
                gateway.route_voice_command(
                    self._request("dashboard.summary.today", "GetTodaySummaryIntent"),
                    x_gateway_secret="test-secret",
                )

        self.assertEqual(exc_info.exception.status_code, 503)


if __name__ == "__main__":
    unittest.main()
