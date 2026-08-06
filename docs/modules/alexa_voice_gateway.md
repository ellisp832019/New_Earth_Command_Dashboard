# Alexa Voice Gateway

## Where it lives

```text
modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE/
```

## Dashboard entry

- `More` hub
- Sidebar quick link
- Route: `/more/alexa-voice-gateway`

## What it does

The Alexa Voice Gateway is a guarded voice doorway. Alexa can only request approved dashboard actions through the gateway permission layer. It does not get direct access to files, finance, Obsidian, shell commands, AI agents, raw databases, or dangerous hardware controls.

## Local run

1. Open `modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE/config/gateway_config.example.yaml`.
2. Set local values in `config/gateway_config.local.yaml` if needed.
3. Create a local `.venv` and install `requirements.txt`.
4. Set `NEW_EARTH_VOICE_GATEWAY_SECRET`.
5. Optionally set `ALEXA_GATEWAY_ENABLED=false` to disable the module instantly.
6. Run the mock dashboard API.
7. Run `python -m src.voice_gateway.app` from the module folder.
8. Open the dashboard page and use the `Launch helper` card to copy the start commands if you do not want to type them manually.
9. On Windows, you can run the trusted launcher directly:

```text
scripts\launch_voice_gateway.cmd
```

To stop the local services again, use:

```text
scripts\stop_voice_gateway.cmd
```

If `.cmd` files are awkward on your machine, you can use:

```text
scripts\launch_voice_gateway.bat
```

And for stopping:

```text
scripts\stop_voice_gateway.bat
```

## Mock testing

- Run `scripts/test_gateway.sh`.
- If `NEW_EARTH_VOICE_GATEWAY_SECRET` is set in your shell, the script includes the secure header automatically.
- Post mock JSON to `/voice/command`.
- Use the mock dashboard API in `examples/dashboard_mock/mock_dashboard_api.py`.

## Validated runtime

- Python `3.14` validated locally with the current dependency pins
- Windows launcher flow validated locally:
  - start helper
  - local health checks
  - safe smoke requests
  - stop helper

## Real local adapter

The gateway now supports a real read-only SQLite-backed adapter mode for:

- `dashboard.summary.today`
- `dashboard.project.status.read`
- `dashboard.tasks.next`
- `microgrow.status.read`

Enable it by setting either:

- `dashboard.mode: sqlite` with `dashboard.sqlite_db_path`
- or `NEW_EARTH_DASHBOARD_DB_PATH`

This keeps the permission layer as the only gate and avoids exposing write actions or dangerous commands.
For now, `microgrow.status.read` reports the real MicroGrow project status already stored in the dashboard database, rather than claiming live sensor data that the schema does not store yet.

## Allowed

- Dashboard summary
- Project status
- MicroGrow status
- Add dashboard note
- Start focus mode
- List next tasks

## Blocked

- Delete files
- Open private Obsidian notes directly
- Access finance data
- Run terminal commands
- Trigger AI agents
- Permanently control relays
- Control dangerous hardware
- Access raw local databases

## Disable fast

Set:

```text
ALEXA_GATEWAY_ENABLED=false
```

When disabled, the gateway rejects all Alexa Voice Gateway requests.

## Dashboard helper

The dashboard now includes a launch helper card with:

- copyable Windows startup commands
- a direct `Start gateway now` button on Windows
- a direct `Stop gateway` button on Windows
- a copyable gateway test command
- copyable env lines
- a copyable trusted launcher command
- a double-click `launch_voice_gateway.cmd` wrapper
- a double-click `launch_voice_gateway.bat` wrapper
- a double-click `stop_voice_gateway.cmd` wrapper
- a double-click `stop_voice_gateway.bat` wrapper
- an `Open launcher folder` button in the dashboard
- local health checks for the gateway and mock dashboard
- automatic health refresh while the page is open
- a last-checked status summary so it is easier to tell when services come online
