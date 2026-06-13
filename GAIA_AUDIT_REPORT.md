# GAIA Audit Report

## Summary
This audit covers the MARK XL code copied into `F:\GAIA_CORE\vendor_mark_xl` and the existing dashboard GAIA module in the current workspace.

## Main Findings
- MARK XL runtime entry point: `F:\GAIA_CORE\vendor_mark_xl\main.py`
- MARK XL UI entry point: `F:\GAIA_CORE\vendor_mark_xl\ui.py`
- LLM integration: `F:\GAIA_CORE\vendor_mark_xl\core\llm_client.py`
- STT engine: `F:\GAIA_CORE\vendor_mark_xl\core\stt.py`
- TTS engine: `F:\GAIA_CORE\vendor_mark_xl\core\tts.py`
- Memory system: `F:\GAIA_CORE\vendor_mark_xl\memory\memory_manager.py`
- Config loader: `F:\GAIA_CORE\vendor_mark_xl\config\__init__.py`
- Prompt/system persona: `F:\GAIA_CORE\vendor_mark_xl\core\prompt.txt`
- Tool registry and actions: `F:\GAIA_CORE\vendor_mark_xl\main.py` + `F:\GAIA_CORE\vendor_mark_xl\actions\*.py`
- Existing dashboard bridge: `modules\gaia_voice_assistant\dashboard_bridge\gaia_bridge.py`
- Existing permission gateway: `modules\gaia_voice_assistant\permissions\permission_gateway.py`

## Current MARK XL Entry Points
- `F:\GAIA_CORE\vendor_mark_xl\main.py`: primary application boot.
- `JarvisLocal` class in `main.py`: orchestrates STT → LLM → TTS and tool execution.
- `ui.py` creates the desktop interface and binds event callbacks.

## UI Entry Points
- `F:\GAIA_CORE\vendor_mark_xl\ui.py`: entire UI layer.
- `JarvisUI` class referenced by `main.py`.
- `main.py` starts UI with `JarvisUI("face.png")` and `JarvisLocal(ui)`.

## Ollama Integration Files
- `F:\GAIA_CORE\vendor_mark_xl\core\llm_client.py`
- Default LLM URL: `http://localhost:11434`
- Default model: `llama3.2` in `llm_client.py`
- Uses Ollama `/api/chat` and `/api/tags` endpoints.
- `main.py` calls `ensure_ollama_running()` and `warmup_model()`.

## STT Engine Files
- `F:\GAIA_CORE\vendor_mark_xl\core\stt.py`
- Supports `WhisperSTT` and `VoskSTT`.
- Uses `faster_whisper` and `vosk` packages.
- `main.py` dynamically loads STT based on config.

## TTS Engine Files
- `F:\GAIA_CORE\vendor_mark_xl\core\tts.py`
- Supports `EdgeTTSEngine`, `KokoroTTSEngine`, and ElevenLabs.
- Includes auto-upgrade logic for `kokoro`.
- Uses `sounddevice` and `miniaudio` for playback.

## Tool Registry Files
- `F:\GAIA_CORE\vendor_mark_xl\main.py`: `TOOL_DECLARATIONS` and conversion to Ollama tool spec.
- Action modules:
  - `actions\browser_control.py`
  - `actions\code_helper.py`
  - `actions\computer_control.py`
  - `actions\computer_settings.py`
  - `actions\desktop.py`
  - `actions\file_controller.py`
  - `actions\file_processor.py`
  - `actions\flight_finder.py`
  - `actions\game_updater.py`
  - `actions\open_app.py`
  - `actions\reminder.py`
  - `actions\screen_processor.py`
  - `actions\send_message.py`
  - `actions\weather_report.py`
  - `actions\web_search.py`
  - `actions\youtube_video.py`

## Memory System Files
- `F:\GAIA_CORE\vendor_mark_xl\memory\memory_manager.py`
- `F:\GAIA_CORE\vendor_mark_xl\memory\config_manager.py`
- Memory file path currently hardcoded to `BASE_DIR / "memory" / "long_term.json"`.

## Configuration Files
- `F:\GAIA_CORE\vendor_mark_xl\config\__init__.py`
- `F:\GAIA_CORE\vendor_mark_xl\core\prompt.txt`
- `F:\GAIA_CORE\vendor_mark_xl\main.py` loads `config/api_keys.json` via `API_CONFIG_PATH`
- Current repo dashboard config: `modules\gaia_voice_assistant\config\gaia_config.json`

## API Endpoints
- MARK XL core currently has no HTTP runtime API implemented.
- Dashboard module has a client-side bridge at `modules\gaia_voice_assistant\dashboard_bridge\gaia_bridge.py` expecting endpoints like `/health` and `/command`.
- No server runtime in `F:\GAIA_CORE\vendor_mark_xl` yet.

## Dashboard Integration Opportunities
- Use existing dashboard bridge and permission module.
- Implement a lightweight HTTP runtime in GAIA_CORE to satisfy `GET /health`, `POST /command`, etc.
- Connect dashboard to GAIA via `modules\gaia_voice_assistant\dashboard_bridge\gaia_bridge.py`.
- Leverage `modules\gaia_voice_assistant\permissions\permission_gateway.py` for guarded tool execution.

## Hardcoded Paths Found
- `Path.home() / ".jarvis_profiles"` in `actions\browser_control.py`.
- `Path.home() / "Desktop" / "jarvis_screenshot.png"` in `actions\browser_control.py` and `computer_control.py`.
- `Path.home() / "Desktop" / "jarvis_debug_<ts>.png"` in `actions\code_helper.py`.
- `Path.home() / "Desktop" / "JarvisProjects"` in `actions\dev_agent.py`.
- `Path.home() / ".jarvis" / "reminders"` in `actions\reminder.py`.
- macOS launch agent names and plist paths in `actions\game_updater.py`.
- Windows Task Scheduler task names containing `JARVIS_GameUpdater` and `JARVISReminder_*`.
- Hardcoded `api_keys.json` and `prompt.txt` relative to runtime base directory.

## Hardcoded JARVIS / MARK XL Branding
- `main.py` top-level branding, logs, prompt text, and `JarvisLocal` class.
- `ui.py`: window title `J.A.R.V.I.S — MARK XL`, labels, file dialog titles, log tags.
- `actions` modules: several messages and file paths include `JARVIS` or `MARK XL`.
- `core\prompt.txt`: explicit `JARVIS CORE PROTOCOL` and `You are Jarvis.` identity.
- `readme.md` and `requirements.txt` mention MARK XL branding.

## Risky Tools and Permission Gating Candidates
### Sensitive actions
- `send_message` (`actions\send_message.py`)
- `file_controller` (`actions\file_controller.py`)
- `computer_settings` (`actions\computer_settings.py`)
- `computer_control` (`actions\computer_control.py`)
- `desktop` execution (`actions\desktop.py`, `exec` sandbox)
- `open_app` (`actions\open_app.py`)
- `reminder` (`actions\reminder.py`)
- `game_updater` (`actions\game_updater.py`)
- `browser_control` (`actions\browser_control.py`)
- `file_processor` (`actions\file_processor.py`)
- `screen_processor` (`actions\screen_processor.py`)
- `dev_agent` (`actions\dev_agent.py`)

### Risky infrastructure
- `core\llm_client.py` can auto-launch `ollama serve` via `subprocess.Popen`.
- `main.py` auto-installs packages on first run via `pip install` and restarts itself.
- `core\tts.py` may connect to internet for EdgeTTS / ElevenLabs and may auto-upgrade Kokoro.
- `core\stt.py` may download Whisper models from HuggingFace on first run.
- `actions\desktop.py` uses `exec`, which is inherently risky.

## Cloud Dependencies and External APIs
- Ollama backend may be local, but current code expects `http://localhost:11434`.
- `core\tts.py` supports EdgeTTS and ElevenLabs, which are internet/cloud dependencies.
- `core\stt.py` supports faster-whisper and may download models via HuggingFace on first use.
- Many actions rely on system apps and web services indirectly.

## Notes
- No `F:\04_CONFIG`, `F:\03_MEMORY`, or other GAIA USB folders exist in the scanned `F:\GAIA_CORE` tree yet.
- The existing New Earth dashboard module already contains a bridge and permission gateway, making integration easier.
- The current MARK XL implementation is desktop-first and not yet packaged as a portable headless runtime.
