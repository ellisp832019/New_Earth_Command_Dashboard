from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

DEFAULT_SENSITIVE_MODULES = {"finance", "microgrow", "files", "messaging", "system", "publishing"}
DEFAULT_BLOCKED_ACTIONS = {"format_drive", "delete_all", "move_money", "disable_security", "exfiltrate_data"}
DEFAULT_CONFIRMATION_ACTIONS = {"create_task", "edit_file", "send_message", "microgrow_control", "change_settings", "publish_content"}


def get_rules_file_path() -> Path:
    override_path = os.environ.get("PERMISSION_RULES_PATH")
    if override_path:
        return Path(override_path)
    return Path(__file__).resolve().parent / "permission_rules.json"


def load_permission_rules() -> dict[str, Any]:
    rules_file = get_rules_file_path()
    if not rules_file.exists():
        return {
            "low_risk": [],
            "confirmation_required": list(DEFAULT_CONFIRMATION_ACTIONS),
            "blocked_by_default": list(DEFAULT_BLOCKED_ACTIONS),
            "finance_rules": {},
            "microgrow_rules": {},
        }
    try:
        with rules_file.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    except Exception:
        return {
            "low_risk": [],
            "confirmation_required": list(DEFAULT_CONFIRMATION_ACTIONS),
            "blocked_by_default": list(DEFAULT_BLOCKED_ACTIONS),
            "finance_rules": {},
            "microgrow_rules": {},
        }


def evaluate_command(command: dict[str, Any]) -> dict[str, str]:
    rules = load_permission_rules()
    module = str(command.get("module", "")).lower()
    action = str(command.get("action", "")).lower()
    intent = str(command.get("intent", "")).lower()
    requires_confirmation = bool(command.get("requires_confirmation"))

    blocked_actions = set(str(item).lower() for item in rules.get("blocked_by_default", [])) | DEFAULT_BLOCKED_ACTIONS
    confirmation_actions = set(str(item).lower() for item in rules.get("confirmation_required", [])) | DEFAULT_CONFIRMATION_ACTIONS
    sensitive_modules = set(str(item).lower() for item in rules.get("sensitive_modules", [])) | DEFAULT_SENSITIVE_MODULES

    if action in blocked_actions or intent in blocked_actions:
        return {"decision": "blocked", "reason": "Action is blocked by GAIA safety policy."}

    module_rules = rules.get(f"{module}_rules", {}) if module else {}
    module_intent_decision = module_rules.get(action) or module_rules.get(intent)
    if module_intent_decision == "block":
        return {"decision": "blocked", "reason": "Blocked by module safety rule."}
    if module_intent_decision == "confirm":
        return {"decision": "confirm", "reason": "Sensitive module action requires confirmation."}
    if module_intent_decision == "allow":
        return {"decision": "allow", "reason": "Allowed by module rule."}

    if requires_confirmation or action in confirmation_actions or intent in confirmation_actions:
        return {"decision": "confirm", "reason": "Command requires user confirmation."}

    if module in sensitive_modules:
        return {"decision": "confirm", "reason": "Sensitive module requires confirmation."}

    return {"decision": "allow", "reason": "Low-risk command."}
