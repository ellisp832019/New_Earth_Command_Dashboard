#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$MODULE_ROOT/obsidian_sync_config.json"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for this script."
  exit 1
fi

PROJECT_NAME=$(python3 -c "import json;print(json.load(open('$CONFIG'))['project_name'])")
VAULT_PATH=$(python3 -c "import json;print(json.load(open('$CONFIG'))['obsidian_vault_path'])")
PROJECT_FOLDER=$(python3 -c "import json;print(json.load(open('$CONFIG'))['obsidian_project_folder'])")
DESTINATION="$VAULT_PATH/$PROJECT_FOLDER"
SOURCE="$MODULE_ROOT/exports"

mkdir -p "$DESTINATION"

python3 - <<PY
import json, shutil
from pathlib import Path
config = json.load(open('$CONFIG'))
source = Path('$SOURCE')
destination = Path('$DESTINATION')
for doc in config['export_docs']:
    src = source / doc
    dst = destination / doc
    if src.exists():
        shutil.copy2(src, dst)
        print(f'Synced {doc} to {destination}')
    else:
        print(f'Missing export file: {doc}')
print(f'\nObsidian sync complete for {config["project_name"]}')
print(f'Destination: {destination}')
PY
