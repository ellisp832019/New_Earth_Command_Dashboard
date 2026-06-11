from __future__ import annotations

import datetime as dt
import os
import sqlite3
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
        with patch.object(
            gateway,
            "dashboard_call",
            return_value="MicroGrow mock status: node online.",
        ) as dashboard_call_mock:
            response = gateway.route_voice_command(
                self._request("microgrow.status.read", "GetMicroGrowStatusIntent"),
                x_gateway_secret="test-secret",
            )

        self.assertEqual(response.decision, "allowed")
        self.assertEqual(response.command, "microgrow.status.read")
        self.assertEqual(response.speech, "MicroGrow mock status: node online.")
        dashboard_call_mock.assert_called_once_with(
            "microgrow.status.read",
            {},
        )

    def test_dashboard_failure_returns_safe_message(self) -> None:
        with patch(
            "src.voice_gateway.app.requests.post",
            side_effect=RuntimeError("sensitive backend detail"),
        ), patch.object(gateway.LOGGER, "exception") as log_exception_mock:
            speech = gateway.dashboard_call("dashboard.summary.today", {})

        self.assertIn("could not reach the dashboard safely", speech.lower())
        self.assertNotIn("sensitive backend detail", speech)
        log_exception_mock.assert_called_once()

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

    def test_sqlite_dashboard_summary_reads_real_data(self) -> None:
        db_path = _create_temp_dashboard_db()
        original_dashboard = dict(gateway.CONFIG["dashboard"])
        gateway.CONFIG["dashboard"] = {
            **original_dashboard,
            "mode": "sqlite",
            "sqlite_db_path": str(db_path),
        }
        try:
            response = gateway.route_voice_command(
                self._request("dashboard.summary.today", "GetTodaySummaryIntent"),
                x_gateway_secret="test-secret",
            )
        finally:
            gateway.CONFIG["dashboard"] = original_dashboard
            _cleanup_temp_db(db_path)

        self.assertEqual(response.decision, "allowed")
        self.assertIn("Today's main focus is Finish the safe voice bridge", response.speech)
        self.assertIn("Top 3 tasks are Test the real Alexa adapter", response.speech)

    def test_sqlite_project_status_reads_real_data(self) -> None:
        db_path = _create_temp_dashboard_db()
        original_dashboard = dict(gateway.CONFIG["dashboard"])
        gateway.CONFIG["dashboard"] = {
            **original_dashboard,
            "mode": "sqlite",
            "sqlite_db_path": str(db_path),
        }
        try:
            response = gateway.route_voice_command(
                self._request(
                    "dashboard.project.status.read",
                    "GetProjectStatusIntent",
                    {"project": "New Earth Command Dashboard"},
                ),
                x_gateway_secret="test-secret",
            )
        finally:
            gateway.CONFIG["dashboard"] = original_dashboard
            _cleanup_temp_db(db_path)

        self.assertEqual(response.decision, "allowed")
        self.assertIn("New Earth Command Dashboard", response.speech)
        self.assertIn("65 percent", response.speech)

    def test_sqlite_next_tasks_reads_real_data(self) -> None:
        db_path = _create_temp_dashboard_db()
        original_dashboard = dict(gateway.CONFIG["dashboard"])
        gateway.CONFIG["dashboard"] = {
            **original_dashboard,
            "mode": "sqlite",
            "sqlite_db_path": str(db_path),
        }
        try:
            response = gateway.route_voice_command(
                self._request("dashboard.tasks.next", "ListNextTasksIntent"),
                x_gateway_secret="test-secret",
            )
        finally:
            gateway.CONFIG["dashboard"] = original_dashboard
            _cleanup_temp_db(db_path)

        self.assertEqual(response.decision, "allowed")
        self.assertIn("Test the real Alexa adapter", response.speech)
        self.assertIn("Review the launcher health flow", response.speech)

    def test_sqlite_microgrow_status_reads_real_data(self) -> None:
        db_path = _create_temp_dashboard_db()
        original_dashboard = dict(gateway.CONFIG["dashboard"])
        gateway.CONFIG["dashboard"] = {
            **original_dashboard,
            "mode": "sqlite",
            "sqlite_db_path": str(db_path),
        }
        try:
            response = gateway.route_voice_command(
                self._request("microgrow.status.read", "GetMicroGrowStatusIntent"),
                x_gateway_secret="test-secret",
            )
        finally:
            gateway.CONFIG["dashboard"] = original_dashboard
            _cleanup_temp_db(db_path)

        self.assertEqual(response.decision, "allowed")
        self.assertIn("MicroGrow project status is Active at 40 percent", response.speech)
        self.assertIn("Keep MicroGrow read-only for the first release", response.speech)
        self.assertIn("Live sensor readings are not stored", response.speech)


if __name__ == "__main__":
    unittest.main()


def _create_temp_dashboard_db() -> Path:
    fd, raw_path = tempfile.mkstemp(suffix=".db")
    os.close(fd)
    db_path = Path(raw_path)
    _seed_dashboard_db(db_path)
    return db_path


def _cleanup_temp_db(db_path: Path) -> None:
    if db_path.exists():
        try:
            db_path.unlink()
        except PermissionError:
            pass


def _seed_dashboard_db(db_path: Path) -> None:
    with sqlite3.connect(db_path) as connection:
        connection.execute(
            """
            CREATE TABLE projects (
              project_id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              status TEXT NOT NULL,
              priority TEXT NOT NULL,
              progress_percentage INTEGER NOT NULL,
              current_milestone TEXT,
              next_action TEXT,
              updated_at INTEGER NOT NULL,
              is_archived INTEGER NOT NULL DEFAULT 0
            )
            """
        )
        connection.execute(
            """
            CREATE TABLE tasks (
              task_id TEXT PRIMARY KEY,
              project_id TEXT,
              title TEXT NOT NULL,
              priority TEXT NOT NULL,
              status TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              is_top_three INTEGER NOT NULL DEFAULT 0,
              is_archived INTEGER NOT NULL DEFAULT 0
            )
            """
        )
        connection.execute(
            """
            CREATE TABLE daily_plans (
              daily_plan_id TEXT PRIMARY KEY,
              date INTEGER NOT NULL UNIQUE,
              main_focus TEXT,
              top_task_1_id TEXT,
              top_task_2_id TEXT,
              top_task_3_id TEXT
            )
            """
        )

        now = int(dt.datetime.now().timestamp())
        start_of_day = dt.datetime.now()
        today = int(dt.datetime(start_of_day.year, start_of_day.month, start_of_day.day).timestamp())

        connection.execute(
            """
            INSERT INTO projects (
              project_id, name, status, priority, progress_percentage,
              current_milestone, next_action, updated_at, is_archived
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)
            """,
            (
                "project-1",
                "New Earth Command Dashboard",
                "Active",
                "High",
                65,
                "Real adapter bridge",
                "Wire read-only Alexa commands to live dashboard data",
                now,
            ),
        )
        connection.execute(
            """
            INSERT INTO projects (
              project_id, name, status, priority, progress_percentage,
              current_milestone, next_action, updated_at, is_archived
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)
            """,
            (
                "project-2",
                "MicroGrow",
                "Active",
                "Medium",
                40,
                "Status-only bridge",
                "Keep MicroGrow read-only for the first release",
                now - 120,
            ),
        )

        tasks = [
            (
                "task-1",
                "project-1",
                "Test the real Alexa adapter",
                "High",
                "Doing",
                now - 300,
                1,
            ),
            (
                "task-2",
                "project-1",
                "Review the launcher health flow",
                "High",
                "Inbox",
                now - 200,
                1,
            ),
            (
                "task-3",
                "project-2",
                "Keep MicroGrow read-only",
                "Medium",
                "Next",
                now - 100,
                1,
            ),
        ]
        connection.executemany(
            """
            INSERT INTO tasks (
              task_id, project_id, title, priority, status, created_at, is_top_three, is_archived
            ) VALUES (?, ?, ?, ?, ?, ?, ?, 0)
            """,
            tasks,
        )
        connection.execute(
            """
            INSERT INTO daily_plans (
              daily_plan_id, date, main_focus, top_task_1_id, top_task_2_id, top_task_3_id
            ) VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                "daily-plan-today",
                today,
                "Finish the safe voice bridge",
                "task-1",
                "task-2",
                "task-3",
            ),
        )
        connection.commit()
