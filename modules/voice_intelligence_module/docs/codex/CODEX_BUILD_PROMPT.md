# Codex Build Prompt

You are working inside the New Earth Dashboard repo.

A new module pack has been added for:

```text
modules/voice_intelligence
```

Your job is to integrate the Voice Intelligence Module safely into the existing dashboard.

## Non-negotiable safety rules

1. Do not give AI direct hardware control.
2. Do not enable MicroGrow relay/mist/pump/heater commands in V1.
3. All hardware write commands must be blocked by the Safety Command Gateway.
4. MicroGrow V1 voice integration is read-only status only.
5. Always show when recording is active.
6. Do not silently record.
7. The dashboard must run even if no OpenAI API key is configured.
8. Implement mock mode first.

## Build V1 features

Create a dashboard module with these pages/components:

```text
Voice Home
Voice Notes
Meeting Transcriber
Dashboard Assistant
MicroGrow Voice Status
Voice Audit Log
Voice Settings
```

## Suggested route names

```text
/voice
/voice/notes
/voice/meetings
/voice/assistant
/voice/microgrow
/voice/audit
/voice/settings
```

## Implement services

```text
VoiceTranscriptionService
VoiceAssistantService
MeetingSummaryService
MicroGrowVoiceStatusService
SafetyCommandGateway
VoiceAuditLogger
```

## Implement feature flags

```json
{
  "voiceNotesEnabled": true,
  "meetingTranscriberEnabled": true,
  "dashboardAssistantEnabled": true,
  "microgrowReadOnlyEnabled": true,
  "microgrowVoiceControlEnabled": false,
  "alwaysOnWakeWordEnabled": false,
  "cloudSyncVoiceLogsEnabled": false
}
```

## OpenAI integration guidance

Add provider abstraction so the module can run in:

```text
mock mode
OpenAI transcription mode
OpenAI realtime mode later
```

Do not hard-code API keys. Use environment/config values only.

Suggested environment variables:

```text
OPENAI_API_KEY
VOICE_PROVIDER=mock|openai
VOICE_TRANSCRIPTION_MODEL
VOICE_REALTIME_MODEL
VOICE_TTS_MODEL
```

## Expected first implementation

1. Add module navigation entry.
2. Add module routes/pages.
3. Add mock transcription and assistant responses.
4. Add safety gateway with blocked hardware writes.
5. Add MicroGrow status mock adapter.
6. Add API contracts or local service layer matching docs/contracts/VOICE_MODULE_API_CONTRACTS.md.
7. Add tests from docs/testing/TEST_PLAN.md.
8. Update README/module index.

## Acceptance checklist

- Dashboard builds successfully.
- Voice tab appears.
- Voice note mock flow works.
- Meeting summary mock flow works.
- MicroGrow status read-only mock works.
- Relay/mist commands are blocked.
- Audit log records every voice intent.
- No secret keys are committed.
