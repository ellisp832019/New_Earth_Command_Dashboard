# Codex Task — Build New Earth Dashboard Voice Bridge v0.1

## Task Title

Build the first safe version of the New Earth Dashboard Voice Bridge.

---

## Context

This repo is the New Earth Dashboard. The dashboard is intended to become the user's command centre for:

- New Earth project management
- MicroGrow planning
- Website work
- learning tasks
- daily build planning
- journal entries
- future ideas
- Codex-assisted development

The Voice Bridge will allow the user to speak commands and decide whether to save them as tasks, journal entries, ideas, or Codex prompts.

Do not build dangerous automation. Do not directly control MicroGrow hardware. Do not run destructive commands.

---

## Current Objective

Make the Voice Assistant feel smarter and faster to start from by adding a voice wizard mode, a voice briefing layer, reusable voice starters, tap-to-reuse command history, and thread memory that keeps a conversation going across entries.

This now includes:

1. Dashboard access to Voice Capture.
2. Reviewed transcript entry with live microphone, paste, and mock transcript support.
3. Smart voice starter templates for common capture flows.
4. Tap-to-reuse saved command history.
5. A voice briefing card that explains the command and suggests the next sequence of actions.
6. A wizard mode that asks one question at a time and assembles the draft from answers.
7. A current thread card that keeps remembered voice context visible.
8. A continue-thread action that resumes the current voice conversation in Wizard mode.
9. Project linking.
10. Local save actions for projects, tasks, journal entries, inbox ideas, content ideas, and business opportunities.
11. Wake phrase detection and smart command macros for review, planning, and next-step prompts.
12. Manual-review Codex prompt generation.
13. Spoken assistant replies and briefings on Windows with selectable local voices.
14. Windows startup gating that waits for a connected headset or headset microphone before the app fully opens.
15. Focused tests for local persistence.
16. Stronger Windows desktop speech capture that can use a local Whisper bridge before falling back to system dictation.
17. A route-independent conversation dock that can surface the wake response on the dashboard when the assistant screen is still settling.

---

## Required Repo Structure

Create or update the following:

```text
lib/features/voice_assistant/
├── voice_assistant_screen.dart
├── voice_command_model.dart
├── voice_command_service.dart
└── widgets/
    ├── transcript_preview_card.dart
    ├── command_type_selector.dart
    └── command_history_list.dart
```

Also create:

```text
tools/voice_bridge/
├── voice_bridge.py
├── requirements.txt
└── README.md
```

---

## Flutter Screen Requirements

Create a `VoiceAssistantScreen` that includes:

- Page title: `Voice Assistant`
- Subtitle: `Speak, review, and turn your words into dashboard actions.`
- A large local capture area.
- Press-to-listen microphone controls: Start Listening, Stop, Cancel.
- A paste transcript action.
- A transcript preview text area.
- Smart starter commands that can preload common voice workflows.
- A voice briefing card that turns the current command into a numbered suggested sequence.
- A wizard mode that steps through a conversation one answer at a time.
- A command type selector with:
  - Task
  - Journal Entry
  - Content Idea
  - Business Opportunity
  - Codex Prompt
  - Idea
- One save/prepare action that follows the selected command type.
- Command history section.
- Command history items that can be tapped to restore a previous capture.

Live microphone capture must be explicit and review-first. Do not add always-listening recording.

Do not connect cloud microphone transcription.

If the project adds a local desktop speech bridge, it must still stay review-first and local-first.

---

## Voice Command Model

Create a simple model with fields such as:

```dart
class VoiceCommand {
  final String id;
  final String transcript;
  final VoiceCommandType type;
  final DateTime createdAt;
}
```

Create an enum:

```dart
enum VoiceCommandType {
  task,
  journalEntry,
  contentIdea,
  businessOpportunity,
  codexPrompt,
  idea,
}
```

---

## Voice Command Service

Create a simple service that can:

- store commands in memory
- return command history
- create a Codex-safe prompt wrapper
- save reviewed commands into existing local dashboard repositories/data

The Codex-safe prompt wrapper should include:

```text
You are working inside the New Earth Dashboard repo.

User voice command:
[TRANSCRIPT]

Rules:
- Make minimal, high-confidence changes.
- Explain what files you changed.
- Do not delete existing work.
- Do not make destructive changes.
- Ask for approval before major rewrites.
```

---

## Python Bridge Scaffold

Create `tools/voice_bridge/voice_bridge.py`.

For v0.1 this can be a placeholder command-line program that:

1. Asks the user to type or paste a transcript.
2. Shows the transcript back.
3. Asks whether to format it as a Codex prompt.
4. Prints the final prompt.
5. Saves it to a local `logs/voice_commands.log` file.

Do not require live microphone recording in v0.1.
If the stronger desktop bridge is added, it should still degrade safely when dependencies are missing.

---

## Python README

Create `tools/voice_bridge/README.md` explaining:

- what the bridge is
- how to run it
- that v0.1 was text-input only
- that the bridge can now use local desktop speech capture when dependencies are installed
- safety note that Codex prompts should be reviewed before execution

---

## Safety Requirements

- Do not automatically execute Codex.
- Do not automatically change files outside the requested feature folders.
- Do not delete existing dashboard files.
- Do not add hardware control.
- Do not add always-listening background audio.
- Keep the feature local-first.
- Review before saving or preparing prompts.

---

## Acceptance Criteria

This task is complete when:

- Voice Capture opens from Dashboard and More.
- Voice Capture supports explicit live microphone transcription.
- Voice Capture includes reusable smart starter commands.
- Voice Capture includes a voice briefing card with a suggested sequence of actions.
- Voice Capture includes a wizard mode that assembles the draft from guided answers.
- Voice Capture includes remembered thread context and a continue-thread action.
- A reviewed transcript can save as a Task.
- A reviewed transcript can save as a Journal Entry.
- A reviewed transcript can save as an Inbox Idea.
- A reviewed transcript can save as a Content Idea.
- A reviewed transcript can save as a Business Opportunity.
- Codex prompts are generated for manual review only.
- Saved voice history can be reused from the Voice Assistant screen.
- Gaia can surface a visible conversation dock on the dashboard when wake capture lands there before the full route opens, that dock can speak the captured reply through the configured voice output, and it can offer quick follow-up chips that reopen the assistant with a preselected intent.
- `flutter analyze` passes.
- `flutter test` passes.
- Windows startup blocks until a headset or headset microphone is connected.

---

## Final Codex Response Required

When finished, report:

1. Files created.
2. Files modified.
3. How to open the new screen.
4. Any package dependencies added.
5. Any manual wiring still required.
