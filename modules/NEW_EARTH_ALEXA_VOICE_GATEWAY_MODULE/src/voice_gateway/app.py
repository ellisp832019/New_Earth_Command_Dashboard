from __future__ import annotations

import datetime as dt
import json
import logging
import os
from pathlib import Path
from typing import Any, Dict, Optional

import requests
import yaml
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel, Field

ROOT = Path(__file__).resolve().parents[2]
PERMISSIONS_PATH = ROOT / "config" / "voice_permissions.yaml"
CONFIG_PATH = ROOT / "config" / "gateway_config.local.yaml"
CONFIG_EXAMPLE_PATH = ROOT / "config" / "gateway_config.example.yaml"
KILL_SWITCH_ENV = "ALEXA_GATEWAY_ENABLED"


def load_yaml(path: Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def load_config() -> Dict[str, Any]:
    if CONFIG_PATH.exists():
        return load_yaml(CONFIG_PATH)
    return load_yaml(CONFIG_EXAMPLE_PATH)


CONFIG = load_config()
PERMISSIONS = load_yaml(PERMISSIONS_PATH)
LOGGER = logging.getLogger("new_earth.alexa_voice_gateway")

app = FastAPI(title="New Earth Alexa Voice Gateway", version="0.1.0")


class VoiceCommandRequest(BaseModel):
    source: str = Field(default="alexa")
    intent: str
    command: str
    slots: Dict[str, Any] = Field(default_factory=dict)
    spoken_text: Optional[str] = None
    session_id: Optional[str] = None


class VoiceCommandResponse(BaseModel):
    decision: str
    speech: str
    command: str
    permission_level: Optional[int] = None
    requires_confirmation: bool = False


def now_iso() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def parse_bool(value: Optional[str]) -> Optional[bool]:
    if value is None:
        return None

    normalized = value.strip().lower()
    if normalized in {"1", "true", "yes", "on"}:
        return True
    if normalized in {"0", "false", "no", "off"}:
        return False
    return None


def is_gateway_enabled() -> bool:
    env_value = parse_bool(os.getenv(KILL_SWITCH_ENV))
    if env_value is not None:
        return env_value
    return bool(CONFIG.get("gateway", {}).get("enabled", True))


def audit_path() -> Path:
    configured = CONFIG.get("logging", {}).get("audit_log_path", "audit/voice_audit.jsonl")
    return ROOT / configured


def audit(record: Dict[str, Any]) -> None:
    path = audit_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {"timestamp": now_iso(), **record}
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(payload, ensure_ascii=False) + "\n")


def require_gateway_secret(x_gateway_secret: Optional[str]) -> None:
    gw_cfg = CONFIG.get("gateway", {})
    if not gw_cfg.get("require_shared_secret", True):
        return

    env_name = gw_cfg.get("shared_secret_env", "NEW_EARTH_VOICE_GATEWAY_SECRET")
    expected = os.getenv(env_name)
    if not expected:
        raise HTTPException(
            status_code=401,
            detail="Gateway secret is not configured",
        )
    if x_gateway_secret != expected:
        raise HTTPException(status_code=401, detail="Invalid or missing gateway secret")


def permission_for(command: str) -> Optional[Dict[str, Any]]:
    allowed = PERMISSIONS.get("allowed_commands", {})
    protected = PERMISSIONS.get("protected_commands", {})
    blocked = PERMISSIONS.get("blocked_commands", [])

    if command in allowed:
        return {"state": "allowed", **allowed[command]}
    if command in protected:
        item = protected[command]
        if item.get("default_state") == "blocked":
            return {"state": "blocked", **item}
        return {"state": "protected", **item}
    if command in blocked:
        return {"state": "blocked", "level": 4, "requires_confirmation": False}
    return None


def dashboard_call(command: str, slots: Dict[str, Any]) -> str:
    base_url = CONFIG.get("dashboard", {}).get("base_url", "http://127.0.0.1:8099")
    timeout = CONFIG.get("dashboard", {}).get("timeout_seconds", 5)
    try:
        resp = requests.post(
            f"{base_url}/voice/command",
            json={"command": command, "slots": slots},
            timeout=timeout,
        )
        resp.raise_for_status()
        data = resp.json()
        return data.get("speech", "Dashboard command completed.")
    except Exception as exc:
        LOGGER.exception("Dashboard adapter call failed for command %s", command, exc_info=exc)
        return (
            "I could not reach the dashboard safely just now. "
            "Please check the local gateway logs and try again."
        )


@app.get("/health")
def health() -> Dict[str, Any]:
    return {
        "ok": True,
        "service": "new-earth-alexa-voice-gateway",
        "time": now_iso(),
        "enabled": is_gateway_enabled(),
    }


@app.post("/voice/command", response_model=VoiceCommandResponse)
def route_voice_command(
    req: VoiceCommandRequest,
    x_gateway_secret: Optional[str] = Header(default=None),
):
    if not is_gateway_enabled():
        audit(
            {
                "source": req.source,
                "intent": req.intent,
                "command": req.command,
                "decision": "disabled",
                "permission_level": None,
                "action_taken": "rejected_by_kill_switch",
                "blocked_reason": "ALEXA_GATEWAY_ENABLED=false",
            }
        )
        raise HTTPException(
            status_code=503,
            detail="Alexa Voice Gateway is disabled",
        )

    require_gateway_secret(x_gateway_secret)
    rule = permission_for(req.command)

    if rule is None:
        audit(
            {
                "source": req.source,
                "intent": req.intent,
                "command": req.command,
                "decision": "denied_unknown_command",
                "permission_level": None,
                "action_taken": "rejected_unknown_command",
                "blocked_reason": "command_not_registered",
            }
        )
        return VoiceCommandResponse(
            decision="denied",
            speech="That command is not registered in the New Earth voice gateway.",
            command=req.command,
        )

    if rule.get("state") == "blocked":
        audit(
            {
                "source": req.source,
                "intent": req.intent,
                "command": req.command,
                "decision": "blocked",
                "permission_level": rule.get("level"),
                "action_taken": "rejected_by_permission_layer",
                "blocked_reason": rule.get(
                    "blocked_reason",
                    "blocked_by_policy",
                ),
            }
        )
        return VoiceCommandResponse(
            decision="blocked",
            speech="That action is blocked from Alexa for safety and privacy.",
            command=req.command,
            permission_level=rule.get("level"),
            requires_confirmation=rule.get("requires_confirmation", False),
        )

    speech = dashboard_call(req.command, req.slots)
    audit(
        {
            "source": req.source,
            "intent": req.intent,
            "command": req.command,
            "decision": "allowed",
            "permission_level": rule.get("level"),
            "requires_confirmation": rule.get("requires_confirmation", False),
            "action_taken": "forwarded_to_dashboard_adapter",
            "blocked_reason": None,
        }
    )
    return VoiceCommandResponse(
        decision="allowed",
        speech=speech,
        command=req.command,
        permission_level=rule.get("level"),
        requires_confirmation=rule.get("requires_confirmation", False),
    )


if __name__ == "__main__":
    import uvicorn

    gw = CONFIG.get("gateway", {})
    uvicorn.run(app, host=gw.get("host", "127.0.0.1"), port=int(gw.get("port", 8088)))
