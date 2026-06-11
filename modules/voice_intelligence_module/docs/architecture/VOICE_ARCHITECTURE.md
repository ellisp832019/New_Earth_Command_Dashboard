# Voice Intelligence Architecture

## Layered Design

```text
User microphone
  ↓
Voice Capture UI
  ↓
Transcription / Realtime Voice Layer
  ↓
Intent Router
  ↓
Dashboard Tool Registry
  ↓
Module Adapters
  ↓
Safety Command Gateway
  ↓
Approved local APIs / logs / project stores
```

## Main Components

### 1. Voice Capture UI

Handles:

- microphone permissions
- start/stop recording
- recording indicator
- audio upload or stream
- transcript display

### 2. Transcription Service

Handles:

- speech-to-text
- transcript cleanup
- speaker labels later
- timestamps later

### 3. Assistant Orchestrator

Handles:

- user message
- conversation context
- model call
- tool/function calling
- response formatting
- optional spoken reply

### 4. Intent Router

Maps spoken commands into safe internal intents:

```text
create_task
create_note
summarise_meeting
read_microgrow_status
search_omega_os
open_dashboard_module
blocked_hardware_action
```

### 5. Tool Registry

A dashboard-side registry of approved actions the AI can request.

Example tools:

```json
[
  "dashboard.task.create",
  "dashboard.note.save",
  "meeting.summary.create",
  "microgrow.status.read",
  "omega_os.path.open"
]
```

### 6. Safety Command Gateway

Every action goes through the gateway. V1 blocks hardware writes.

### 7. Audit Logger

Logs:

- timestamp
- transcript
- intent
- tool request
- safety decision
- action result

## Recommended V1 Flow: Voice Note

```text
Record audio
  ↓
Transcribe
  ↓
Show transcript
  ↓
AI cleans and summarises
  ↓
User chooses project/location
  ↓
Save note
  ↓
Create optional tasks
```

## Recommended V1 Flow: MicroGrow Status

```text
User asks: Is MicroGrow online?
  ↓
Transcribe
  ↓
Intent: microgrow.status.read
  ↓
Safety gateway: read-only allowed
  ↓
Call local MicroGrow hub API
  ↓
Return answer
  ↓
Log query
```

## Future Flow: Controlled Hardware Command

```text
User says: Turn relay 1 on
  ↓
Intent: microgrow.relay.set
  ↓
Safety gateway checks feature flag
  ↓
Check role, node, relay, risk, sensor conditions
  ↓
Ask confirmation
  ↓
Execute local command
  ↓
Verify result
  ↓
Log action
```

## Integration Points

### Dashboard

- navigation tab: Voice
- sidebar module: Voice Intelligence
- task creation bridge
- project log bridge
- meeting module bridge

### Omega OS

Suggested save targets:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES
D:/NEW_EARTH_OMEGA_OS_PACK/09_KNOWLEDGE_VAULT_OBSIDIAN
D:/NEW_EARTH_OMEGA_OS_PACK/23_AI_AND_AUTOMATION
```

### MicroGrow

V1 read-only endpoints:

```text
GET /info
GET /data
GET /status
```

Write endpoints must be blocked until a later phase.
