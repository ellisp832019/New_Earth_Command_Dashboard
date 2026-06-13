# Dashboard Integration Guide

## Step 1 — Add the module

Copy:

```text
modules/gaia_voice_assistant
```

into your New Earth Dashboard repo under:

```text
modules/gaia_voice_assistant
```

## Step 2 — Keep your existing voice work

Do not remove your existing voice module. Put it behind GAIA:

```text
existing voice input -> transcript -> GAIA bridge -> permission gateway -> dashboard action
```

For conversation mode, the same bridge can send the transcript to `POST /conversation`
so GAIA can answer locally through Ollama and keep the thread memory on the USB runtime.

## Step 3 — Add GAIA panel

Create a dashboard tab/panel:

```text
AI / GAIA
```

Panel sections:

- Runtime status
- Ollama status
- Current model
- Voice status
- Last command
- Permission decisions
- Logs
- USB runtime path

## Step 4 — Connect to USB runtime

Default local endpoints:

```text
GAIA runtime: http://localhost:8765
Ollama:       http://localhost:11434
```

The dashboard module talks to GAIA runtime, not directly to Ollama.

For runtime startup and USB path layout, see `GAIA_CORE/README.md`.

## Step 5 — Sensitive actions

Require approval for:

- Finance
- File deletion
- Messaging
- MicroGrow controls
- System settings
- Publishing

GAIA can read and summarise first. Execution must pass through dashboard confirmation.
