# New Earth Dashboard Voice Bridge

This folder contains the local bridge for spoken or typed commands.

## v0.1

This first version is a safe text-input prototype.

It does not use the microphone yet.

It allows you to:

1. Type or paste a transcript.
2. Review the transcript.
3. Format it as a Codex-safe prompt.
4. Save the result to `logs/voice_commands.log`.

## Run

From the dashboard repo root:

```bash
python tools/voice_bridge/voice_bridge.py
```

If you only want to review the scaffold, you can also open:

`tools/voice_bridge/voice_bridge.py.txt`

## Safety

v0.1 does not automatically run Codex.

Review every prompt before sending it to Codex.

Do not use this bridge to directly control MicroGrow hardware, relays, pumps, fans, heaters, or lights.

## Future Plan

- Add microphone recording.
- Add speech-to-text.
- Add dashboard integration.
- Add project selector.
- Add optional text-to-speech replies.

## Review Reminder

Every Codex prompt should be reviewed by a human before execution.
