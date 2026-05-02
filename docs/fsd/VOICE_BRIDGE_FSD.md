# New Earth Dashboard Voice Bridge — Functional Specification v0.1

## 1. Purpose

The New Earth Dashboard Voice Bridge allows the user to speak commands into the dashboard and convert those spoken commands into useful actions.

The first version is intentionally safe and simple:

- Record or type a command.
- Convert speech into text later.
- Show the transcript for review.
- Let the user choose what to do with it.
- Save the command as a dashboard task, journal entry, idea, or Codex prompt.
- Optionally send the reviewed prompt to Codex CLI in a later version.

This feature turns the New Earth Dashboard into a more natural command centre for building New Earth, MicroGrow, the website, learning plans, documentation, and future project work.

---

## 2. Core Vision

The dashboard should eventually allow natural spoken commands such as:

- “Start my build day.”
- “Add a task to test the DHT22 and AHT10 sensors.”
- “Create a journal entry for what I built today.”
- “Ask Codex to review the dashboard folder structure.”
- “Create a Flutter screen for project details.”
- “Open the MicroGrow project plan.”
- “Summarise today’s progress.”

The first release does not need full automation. The first release should focus on safe capture, review, and logging.

---

## 3. v0.1 Scope

### Included in v0.1

- Voice Assistant screen in the dashboard.
- Microphone record button placeholder.
- Transcript preview field.
- Manual transcript editing.
- Command type selector:
  - Task
  - Journal Entry
  - Codex Prompt
  - Idea
- Command history list.
- Local Python bridge scaffold.
- Codex prompt formatting rules.

### Not included in v0.1

- Always-listening wake word.
- Direct automatic code modification without approval.
- Direct control of MicroGrow relays or hardware.
- Cloud sync.
- Full AI memory system.
- Production speech recognition pipeline.
- Background automation.

---

## 4. Safety Rules

The bridge must not automatically run destructive commands.

The user must always review the transcript before sending it to Codex.

The bridge must clearly separate:

1. Dashboard actions.
2. Documentation actions.
3. Codex code actions.
4. Hardware/MicroGrow actions.

MicroGrow hardware control must remain disabled in v0.1.

Any command related to relays, pumps, fans, heaters, lights, or electrical control should be saved as a task for review, not executed automatically.

---

## 5. User Flow

1. User opens the dashboard.
2. User opens the Voice Assistant screen.
3. User presses “Record Command” or types a transcript.
4. The transcript appears on screen.
5. User edits the transcript if needed.
6. User selects a command type.
7. User presses one of:
   - Save as Task
   - Save as Journal Entry
   - Send to Codex
   - Save as Idea
8. The dashboard stores the command in history.

---

## 6. Command Types

### Save as Task

Used for actionable work.

Example:

> Test the DHT11, DHT22, AHT10, and SHT sensor on the ESP32 and compare readings.

Suggested saved fields:

- title
- description
- project
- priority
- status
- created_at
- source = voice

### Save as Journal Entry

Used for progress logging.

Example:

> Today I set up the first idea for the New Earth Dashboard Voice Bridge.

Suggested saved fields:

- title
- body
- project
- reflection tag
- created_at
- source = voice

### Send to Codex

Used when the user wants Codex to inspect or modify the repo.

Suggested prompt wrapper:

```text
You are working inside the New Earth Dashboard repo.

User voice command:
[TRANSCRIPT HERE]

Rules:
- Make minimal, high-confidence changes.
- Explain what files you changed.
- Do not delete existing work.
- Do not make destructive changes.
- Ask for approval before major rewrites.
```

### Save as Idea

Used for future visions, concepts, or roadmap items.

Example:

> Future idea: allow the dashboard to start my morning planning flow by voice.

---

## 7. Suggested Repo Locations

```text
docs/fsd/VOICE_BRIDGE_FSD.md
docs/tasks/VOICE_BRIDGE_TASK.md
tools/voice_bridge/
lib/features/voice_assistant/
```

---

## 8. Flutter Feature Structure

```text
lib/features/voice_assistant/
├── voice_assistant_screen.dart
├── voice_command_model.dart
├── voice_command_service.dart
└── widgets/
    ├── voice_record_button.dart
    ├── transcript_preview_card.dart
    ├── command_type_selector.dart
    └── command_history_list.dart
```

---

## 9. Python Bridge Structure

```text
tools/voice_bridge/
├── voice_bridge.py
├── requirements.txt
├── README.md
├── logs/
└── output/
```

The Python bridge should eventually handle:

- microphone recording
- speech-to-text
- transcript cleanup
- Codex CLI prompt handoff
- local command logging

---

## 10. v0.1 Acceptance Criteria

The v0.1 feature is complete when:

- The repo contains this Voice Bridge FSD.
- The repo contains the Voice Bridge Codex task file.
- The dashboard has a placeholder Voice Assistant screen.
- The screen has:
  - transcript box
  - command type selector
  - action buttons
  - command history section
- No commands are executed automatically.
- All Codex prompts require user review first.
- Captured commands can be saved locally or displayed in the dashboard.

---

## 11. Future Versions

### v0.2

- Real microphone recording.
- Local transcript saving.
- Basic speech-to-text connection.
- “Copy prompt for Codex” button.

### v0.3

- Run Codex CLI from the bridge.
- Save Codex responses.
- Add project selector.

### v0.4

- Add text-to-speech reply.
- Add daily planning commands.
- Add “start build day” workflow.

### v0.5

- Dashboard-integrated AI assistant.
- Local-first memory.
- Voice-driven project navigation.
- Optional wake phrase.
