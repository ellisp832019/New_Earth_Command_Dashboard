from __future__ import annotations

import importlib.util
import json
import logging
import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any

from gaia_engine import handle_conversation_request
from gaia_runtime import get_log_path, load_config

LOG_FILE = get_log_path("gaia_bridge_server.log")
logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)

PERMISSION_GATEWAY_MODULE = None
PERMISSION_GATEWAY_PATH = (
    Path(__file__).resolve().parent.parent
    / "modules"
    / "gaia_voice_assistant"
    / "permissions"
    / "permission_gateway.py"
)


def load_permission_gateway() -> Any:
    global PERMISSION_GATEWAY_MODULE
    if PERMISSION_GATEWAY_MODULE is not None:
        return PERMISSION_GATEWAY_MODULE

    if not PERMISSION_GATEWAY_PATH.exists():
        raise FileNotFoundError(f"Permission gateway not found at {PERMISSION_GATEWAY_PATH}")

    spec = importlib.util.spec_from_file_location("gaia_permission_gateway", PERMISSION_GATEWAY_PATH)
    if spec is None or spec.loader is None:
        raise ImportError(f"Unable to load permission gateway from {PERMISSION_GATEWAY_PATH}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    PERMISSION_GATEWAY_MODULE = module
    return module


def json_response(handler: BaseHTTPRequestHandler, payload: dict[str, Any], status: int = 200) -> None:
    body = json.dumps(payload).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


def read_json(handler: BaseHTTPRequestHandler) -> dict[str, Any]:
    length = int(handler.headers.get("Content-Length", "0"))
    if length <= 0:
        return {}
    raw = handler.rfile.read(length)
    try:
        return json.loads(raw.decode("utf-8"))
    except Exception as exc:
        raise ValueError(f"Invalid JSON body: {exc}") from exc


class GaiaBridgeHandler(BaseHTTPRequestHandler):
    server_version = "GAIA-Bridge/1.0"

    def log_message(self, format: str, *args: object) -> None:
        logging.info("%s - %s" % (self.address_string(), format % args))

    def do_GET(self) -> None:
        if self.path == "/health":
            self.handle_health()
            return
        self.send_error(404, "Not Found")

    def do_POST(self) -> None:
        if self.path == "/command":
            self.handle_command()
            return
        if self.path == "/conversation":
            self.handle_conversation()
            return
        if self.path == "/shutdown":
            self.handle_shutdown()
            return
        self.send_error(404, "Not Found")

    def handle_health(self) -> None:
        logging.info("Health check received from %s", self.client_address)
        config = load_config()
        json_response(self, {"status": "ok", "runtime": "gaia", "config": {"permission_mode": config.get("permission_mode", "guarded")}})

    def handle_command(self) -> None:
        try:
            payload = read_json(self)
        except ValueError as exc:
            logging.warning("Invalid command payload: %s", exc)
            json_response(self, {"error": str(exc)}, status=400)
            return

        logging.info("Command received: %s", json.dumps(payload, ensure_ascii=False))
        try:
            gateway = load_permission_gateway()
            decision = gateway.evaluate_command(payload)
        except Exception as exc:
            logging.exception("Permission gateway failed")
            decision = {"decision": "blocked", "reason": "Permission gateway unavailable."}

        response = {"command": payload, **decision}
        json_response(self, response)

    def handle_conversation(self) -> None:
        try:
            payload = read_json(self)
        except ValueError as exc:
            logging.warning("Invalid conversation payload: %s", exc)
            json_response(self, {"error": str(exc)}, status=400)
            return

        logging.info("Conversation request received: %s", json.dumps(payload, ensure_ascii=False))
        try:
            conversation_response = handle_conversation_request(payload)
        except Exception as exc:
            logging.exception("Conversation handler failed")
            conversation_response = {
                "reply": "GAIA conversation unavailable.",
                "status": "error",
                "reason": str(exc),
            }

        json_response(self, {"conversation": conversation_response})

    def handle_shutdown(self) -> None:
        logging.info("Shutdown request received from %s", self.client_address)
        json_response(self, {"status": "shutting_down"})
        def stop_server() -> None:
            self.server.shutdown()
        import threading
        threading.Thread(target=stop_server, daemon=True).start()


def create_server(host: str = "127.0.0.1", port: int = 8765) -> ThreadingHTTPServer:
    return ThreadingHTTPServer((host, port), GaiaBridgeHandler)


def run_server(host: str = "0.0.0.0", port: int | None = None) -> None:
    config = load_config()
    runtime_url = config.get("gaia_runtime_url", "http://localhost:8765")
    if port is None:
        port = int(runtime_url.rsplit(":", 1)[-1]) if ":" in runtime_url else 8765

    server = create_server(host, port)
    logging.info("Starting GAIA bridge server on %s:%s", host, port)
    print(f"GAIA bridge server listening on http://{host}:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logging.info("GAIA bridge server stopped by keyboard interrupt")
    finally:
        server.server_close()
        logging.info("GAIA bridge server closed")


if __name__ == "__main__":
    run_server()
