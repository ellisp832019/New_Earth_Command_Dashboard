# GAIA Migration Plan

## Overview
This migration plan converts MARK XL into GAIA, preserving the core assistant while securing it behind a dashboard bridge and permission gateway.

## Phase 1: Rename JARVIS to GAIA
- Replace user-facing branding in:
  - `F:\GAIA_CORE\vendor_mark_xl\main.py`
  - `F:\GAIA_CORE\vendor_mark_xl\ui.py`
  - `F:\GAIA_CORE\vendor_mark_xl\actions\*.py`
  - `F:\GAIA_CORE\vendor_mark_xl\core\prompt.txt`
  - `F:\GAIA_CORE\vendor_mark_xl\readme.md`
- Rename runtime classes and variables where appropriate:
  - `JarvisLocal` → `GaiaLocal`
  - `JarvisUI` → `GaiaUI`
  - `shutdown_jarvis` → `shutdown_gaia`
- Keep internal logic intact while preserving existing execution flow.

## Phase 2: Move configuration to `F:\04_CONFIG`
- Add a new config loader in GAIA_CORE to read `F:\04_CONFIG\gaia_config.json`.
- Keep `vendor_mark_xl\config\__init__.py` as fallback or legacy.
- Update LLM client and runtime to use the new portable GAIA config path.
- Ensure `gaia_config.json` supports:
  - `llm_url`
  - `llm_model`
  - `llm_provider`
  - `stt_engine`
  - `tts_engine`
  - `ollama_models_path`
  - `permission_mode`

## Phase 3: Move memory to `F:\03_MEMORY`
- Update `memory_manager.py` to store `long_term.json` in `F:\03_MEMORY`.
- Ensure memory load/save works even if the path does not exist yet.
- Keep a fallback to the legacy `memory/long_term.json` during transition.

## Phase 4: Create dashboard bridge
- Implement a lightweight HTTP server in `F:\GAIA_CORE` exposing endpoints:
  - `GET /health`
  - `GET /status`
  - `POST /chat`
  - `POST /voice-command`
  - `POST /dashboard-command`
  - `GET /logs`
  - `GET /models`
  - `POST /shutdown`
- Use `modules\gaia_voice_assistant\dashboard_bridge\gaia_bridge.py` client-side to call this runtime.
- Do not expose raw tool execution or system internals.

## Phase 5: Create permission gateway
- Implement a permission layer between the dashboard bridge and tool execution.
- Use existing dashboard-side rules in `modules\gaia_voice_assistant\permissions\permission_gateway.py`.
- Define default allowed actions as read-only.
- Require explicit confirmation for sensitive actions:
  - delete files
  - edit finance data
  - send messages
  - control MicroGrow relays
  - change system settings
  - run shell commands
  - publish content
  - modify repo files
- Block dangerous actions unless explicitly enabled by a trusted operator.

## Phase 6: Connect dashboard module
- Integrate `modules\gaia_voice_assistant\dashboard_bridge\gaia_bridge.py` with the runtime.
- Ensure the dashboard only sends structured commands, not raw prompts.
- Route voice transcripts from existing dashboard voice work into the GAIA bridge.
- Maintain New Earth dashboard as the permission authority.

## Notes and Dependencies
- Preserve MARK XL files in `F:\GAIA_CORE\_legacy_mark_xl_backup` after refactoring.
- Do not delete current dashboard or existing voice work.
- The dashboard module already has the key pieces for bridge/permissions; use them.
- Manual setup required for Ollama and potentially first-run STT/TTS model caching.

## Next Steps
1. Create `GAIA_USB` folder structure on the USB root.
2. Add startup scripts under `00_START_GAIA`.
3. Implement the HTTP runtime bridge in GAIA_CORE.
4. Add config/memory/log path abstraction in MARK XL engine.
5. Apply branding rename and safe wrapper changes.
6. Test startup on Windows and Linux with Ollama.
