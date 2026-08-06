# Functional Specification Document
# New Earth Dashboard Voice Intelligence Module

## 1. Purpose

The Voice Intelligence Module adds a spoken AI interface to the New Earth Dashboard. It allows the user to speak notes, ask questions, create tasks, summarise meetings, and interact with approved dashboard modules.

The long-term vision is a calm, local-first AI voice layer across New Earth, MicroGrow, New Earth Living, Omega OS, meetings, and the Command Deck.

## 2. V1 Scope

V1 must focus on safe, useful, low-risk voice features:

- voice note capture
- speech-to-text transcription
- meeting transcription import
- AI meeting summary generation
- task extraction from voice notes
- MicroGrow read-only status queries
- dashboard assistant text/voice response
- audit logging of voice sessions

## 3. Out of Scope for V1

The following must not be enabled in V1 unless deliberately gated behind a disabled feature flag:

- direct relay control
- mist driver control
- heater control
- pump control
- any mains-voltage control
- automatic actions without confirmation
- always-on wake-word recording
- cloud syncing of private voice logs without user consent

## 4. User Stories

### 4.1 Voice Notes

As Peter, I want to press a voice button, speak an idea, and have it saved as a structured note in the dashboard and Omega OS.

Acceptance criteria:

- user can start/stop recording
- audio is transcribed
- transcript is shown for review
- note can be saved to project, meeting, journal, or inbox
- note is timestamped

### 4.2 Meeting Summary

As Peter, I want meeting audio or transcripts to be turned into decisions, actions, risks, and next steps.

Acceptance criteria:

- transcript can be pasted or uploaded
- AI summary separates decisions, actions, risks, and follow-ups
- output can be saved to meeting folder
- action items can become dashboard tasks

### 4.3 MicroGrow Read-Only Voice Status

As Peter, I want to ask the dashboard what is happening with MicroGrow without manually opening every screen.

Example commands:

- What is the temperature?
- Is the node online?
- What relays are currently on?
- Are there any warnings?

Acceptance criteria:

- V1 only reads status
- no hardware action is executed
- unavailable node returns a clear error
- all queries are logged

### 4.4 Future Voice Control

As Peter, I want future voice commands to control approved local systems, but only through safety checks and confirmation.

Acceptance criteria:

- command gateway exists
- default mode is read-only
- action commands are blocked unless feature flag is enabled
- high-risk actions require confirmation
- every action is audit logged

## 5. Module Areas

```text
voice_intelligence/
  src/dashboard_voice_assistant
  src/voice_notes
  src/meeting_transcriber
  src/microgrow_voice_status
  src/safety_command_gateway
  src/shared
```

## 6. Data Objects

### VoiceSession

```json
{
  "id": "voice_session_2026_06_08_001",
  "startedAt": "2026-06-08T10:00:00+01:00",
  "endedAt": "2026-06-08T10:02:00+01:00",
  "mode": "voice_note",
  "transcript": "Today I worked on MicroGrow...",
  "summary": "Progress note for MicroGrow.",
  "linkedProject": "microgrow",
  "savedTo": "omega_os/meetings_or_logs",
  "status": "saved"
}
```

### VoiceIntent

```json
{
  "intent": "microgrow.read_status",
  "confidence": 0.94,
  "rawText": "What is the temperature in the grow box?",
  "requiresAction": false,
  "requiresConfirmation": false
}
```

### SafetyCommand

```json
{
  "commandId": "cmd_001",
  "intent": "microgrow.relay.set",
  "riskLevel": "high",
  "requiresConfirmation": true,
  "allowed": false,
  "reason": "Voice hardware control disabled in V1"
}
```

## 7. Permissions

Suggested roles:

- owner
- trusted_local_user
- viewer
- child_safe_mode
- demo_mode

V1 should assume owner-only for voice capture and assistant actions.

## 8. Feature Flags

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

## 9. Privacy Requirements

- Show clear recording state.
- Never silently record.
- Save transcripts locally by default.
- Allow deletion of voice sessions.
- Mark cloud/API processed content clearly.
- Do not send Omega OS content to external APIs unless the user initiates it.

## 10. V1 Definition of Done

- module appears in dashboard navigation
- voice notes page works
- transcript review panel works
- meeting summary page works
- MicroGrow read-only status bridge works against mock API
- safety gateway blocks all hardware write commands by default
- audit log generated
- tests pass
