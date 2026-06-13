import json
import os
import sys
import tempfile
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from modules.gaia_voice_assistant.permissions.permission_gateway import evaluate_command


class PermissionGatewayTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = Path(tempfile.mkdtemp())
        self.mock_rules_path = self.temp_dir / "permission_rules.json"
        self.mock_rules_path.write_text(
            json.dumps(
                {
                    "confirmation_required": ["edit_file"],
                    "blocked_by_default": ["format_drive"],
                    "finance_rules": {"payments": "block"},
                    "microgrow_rules": {"relay_control": "confirm"},
                },
                indent=2,
            ),
            encoding="utf-8",
        )
        os.environ["PERMISSION_RULES_PATH"] = str(self.mock_rules_path)

    def tearDown(self) -> None:
        os.environ.pop("PERMISSION_RULES_PATH", None)

    def test_low_risk_command_allows(self) -> None:
        decision = evaluate_command({"module": "notes", "action": "search_notes"})
        self.assertEqual(decision["decision"], "allow")

    def test_requires_confirmation_for_edit_file(self) -> None:
        decision = evaluate_command({"module": "notes", "action": "edit_file"})
        self.assertEqual(decision["decision"], "confirm")

    def test_blocked_action_is_blocked(self) -> None:
        decision = evaluate_command({"module": "files", "action": "format_drive"})
        self.assertEqual(decision["decision"], "blocked")

    def test_module_rule_blocks_payments(self) -> None:
        decision = evaluate_command({"module": "finance", "action": "payments"})
        self.assertEqual(decision["decision"], "blocked")

    def test_module_rule_confirms_relay_control(self) -> None:
        decision = evaluate_command({"module": "microgrow", "action": "relay_control"})
        self.assertEqual(decision["decision"], "confirm")


if __name__ == "__main__":
    unittest.main()
