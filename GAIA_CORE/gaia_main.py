from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any

from gaia_runtime import CONFIG_FILE, get_log_path, load_config

LOG_FILE = get_log_path("gaia_runtime.log")

logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)


def init_runtime() -> dict[str, Any]:
    config = load_config()
    logging.info("GAIA runtime initialized")
    logging.info(f"Config loaded: {json.dumps(config, indent=2)}")
    return config


if __name__ == "__main__":
    config = init_runtime()
    print("GAIA runtime initialised")
    print(f"Config: {json.dumps(config, indent=2)}")
