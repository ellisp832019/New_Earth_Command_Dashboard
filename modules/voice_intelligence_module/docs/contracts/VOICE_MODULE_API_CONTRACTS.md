# Voice Module API Contracts

These are internal dashboard contracts for Codex to implement or adapt to the existing codebase.

## POST /api/voice/transcribe

Request:

```json
{
  "audioFileId": "local_upload_001",
  "mode": "voice_note"
}
```

Response:

```json
{
  "transcript": "Today I finished the voice module plan.",
  "durationSeconds": 42,
  "status": "ok"
}
```

## POST /api/voice/assistant

Request:

```json
{
  "message": "Create a MicroGrow task to test the SHT22 sensor tomorrow.",
  "context": {
    "activeProject": "microgrow"
  }
}
```

Response:

```json
{
  "reply": "I created a draft task for MicroGrow sensor testing.",
  "intents": ["dashboard.task.create"],
  "actions": [
    {
      "type": "task.create",
      "status": "draft"
    }
  ]
}
```

## POST /api/voice/meeting-summary

Request:

```json
{
  "transcript": "Meeting transcript here...",
  "meetingTitle": "MicroGrow planning call"
}
```

Response:

```json
{
  "summary": "Summary text",
  "decisions": [],
  "actions": [],
  "risks": [],
  "followUps": []
}
```

## GET /api/voice/microgrow/status

Response:

```json
{
  "nodeOnline": true,
  "temperatureC": 23.4,
  "humidityPercent": 51.2,
  "relays": {
    "ch1": false,
    "ch2": false,
    "ch3": true
  },
  "warnings": []
}
```

## POST /api/voice/command/evaluate

Request:

```json
{
  "rawText": "Turn relay one on",
  "intent": "microgrow.relay.set",
  "parameters": {
    "relay": "ch1",
    "state": true
  }
}
```

Response:

```json
{
  "allowed": false,
  "riskLevel": "high",
  "requiresConfirmation": true,
  "reason": "Hardware voice control disabled in V1"
}
```
