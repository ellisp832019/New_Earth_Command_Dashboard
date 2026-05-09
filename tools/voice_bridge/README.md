# New Earth Dashboard Voice Bridge

This folder contains the local bridge for spoken or typed commands.

## What It Does Now

The bridge can:

1. Capture one desktop microphone utterance.
2. Transcribe it locally with Whisper.
3. Format a transcript as a Codex-safe prompt.
4. Save the result to `logs/voice_commands.log`.

## Setup

Install the Python dependencies:

```bash
pip install -r tools/voice_bridge/requirements.txt
```

The first Whisper run may download a model the first time you use it.

## Run

From the dashboard repo root:

```bash
python tools/voice_bridge/voice_bridge.py listen-once --json
```

For a prompt-only run:

```bash
python tools/voice_bridge/voice_bridge.py prompt "Summarize today"
```

If you only want to review the scaffold, you can also open:

`tools/voice_bridge/voice_bridge.py.txt`

## Safety

The bridge does not automatically run Codex.

Review every prompt before sending it to Codex.

Do not use this bridge to directly control MicroGrow hardware, relays, pumps, fans, heaters, or lights.

## Review Reminder

Every Codex prompt should be reviewed by a human before execution.
