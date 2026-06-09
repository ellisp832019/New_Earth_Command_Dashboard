# New Earth Dashboard Voice Bridge

This folder contains the local bridge for spoken or typed commands.

## What It Does Now

The bridge can:

1. Capture one desktop microphone utterance.
2. Transcribe it locally with Whisper.
3. Transcribe a local audio or video file with Whisper.
4. Format a transcript as a Codex-safe prompt.
5. Speak a reply through OpenAI Realtime and play it locally on Windows.
6. Save the result to `logs/voice_commands.log`.

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

To transcribe a recording file:

```bash
python tools/voice_bridge/voice_bridge.py transcribe-file --json path/to/recording.mp4
```

For a prompt-only run:

```bash
python tools/voice_bridge/voice_bridge.py prompt "Summarize today"
```

To speak a reply through GPT Realtime and play the audio locally:

```bash
python tools/voice_bridge/voice_bridge.py realtime-speak --json "I am here. Say task, project, summary, or continue thread."
```

If you want the Flutter app to use this path, set:

```bash
VOICE_SPEECH_PROVIDER=openai_realtime
OPENAI_API_KEY=your-key
```

Optional realtime voice settings:

```bash
OPENAI_VOICE_MODEL=gpt-realtime-2
OPENAI_REALTIME_VOICE=marin
```

If you only want to review the scaffold, you can also open:

`tools/voice_bridge/voice_bridge.py.txt`

## Safety

The bridge does not automatically run Codex.

Review every prompt before sending it to Codex.

The realtime speech path is still opt-in. If the OpenAI bridge is unavailable, the app falls back to local Windows TTS.

Do not use this bridge to directly control MicroGrow hardware, relays, pumps, fans, heaters, or lights.

## Review Reminder

Every Codex prompt should be reviewed by a human before execution.
