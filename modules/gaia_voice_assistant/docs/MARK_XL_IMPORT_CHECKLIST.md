# MARK XL Import Checklist

Place the MARK XL repo here:

```text
modules/gaia_voice_assistant/gaia_core/vendor_mark_xl/PUT_MARK_XL_REPO_HERE
```

Then rename user-facing identity:

```text
JARVIS -> GAIA
Jarvis -> Gaia
jarvis -> gaia
MARK XL -> GAIA Local AI Assistant
Mark-XL -> GAIA
```

Do not blindly replace internal filenames until imports/tests are checked.

## Keep

- STT logic
- Ollama client logic
- TTS logic
- Streaming response logic
- Config UI concepts
- File drop concepts

## Wrap behind permissions

- Browser control
- File controller
- Desktop control
- Messaging
- MicroGrow control
- Finance control
- System settings
