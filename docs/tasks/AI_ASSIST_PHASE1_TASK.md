# Codex Task - AI Assistant Phase 1: Freeze The Core Turn Model

## Status

Complete.

Historical task record. This slice is complete and kept here for reference.

This is the first implementation task for the full AI assistant roadmap.

## Task Title

Freeze the core assistant turn model so the dashboard behaves like one calm, coordinated assistant instead of several competing voice surfaces.

---

## Context

New Earth Command Dashboard is a local-first workflow app. The assistant must help Hayley move through the app without adding noise, confusion, or hidden automation.

The current voice work already includes:

- wake phrase handling
- the voice assistant screen
- a dashboard conversation dock
- a handsfree wake layer
- a shared voice session state machine
- local speech output with an optional realtime path
- review-first transcript and save flows

The next step is not to add more features first.
The next step is to make the assistant architecture feel unified, calm, and reliable.

---

## Current Objective

Build the first phase of the long-range AI assistant roadmap by freezing the core turn model.

This means:

1. One assistant coordinator owns the active turn.
2. One response contract feeds wake, dock, wizard, and screen flows.
3. One speech path is used consistently across surfaces.
4. One memory model carries the current thread.
5. One review-first save path remains the source of truth.

The result should feel like a single assistant with multiple surfaces, not multiple partial assistants.

---

## Scope

### In Scope

- Formalize a shared assistant turn contract.
- Keep wake, assistant screen, and dashboard dock on one shared turn model.
- Keep one speech entry point for all assistant output.
- Keep one response shape for summary, next step, title, type, wizard answer, and hints.
- Keep memory context local-first and review-first.
- Reduce duplicate speak logic and duplicated voice decisions.
- Make assistant state transitions easier to test.

### Out of Scope

- New assistant features beyond the turn model.
- Auto-save behavior.
- Hidden agent actions.
- Cloud sync.
- Always-listening behavior.
- Hardware control.
- A fully autonomous agent.

---

## Build Goals

The assistant should behave like a standard modern workflow assistant:

- it hears a request
- it shapes a short response
- it keeps the next step clear
- it speaks once, not repeatedly
- it hands off cleanly between wake, dock, and assistant screen
- it keeps the user in control

The assistant should never feel like it is switching personalities between surfaces.

---

## Required Architecture

### 1. Turn Coordinator

Create or refine a single coordinator that owns:

- listening state
- speaking state
- processing state
- handoff state
- idle state

The coordinator should enforce:

- only one active speaker
- only one active listener
- clean handoff between surfaces
- clear ownership of the current turn

### 2. Shared Response Contract

Standardize the response object that powers every assistant surface.

The contract should carry:

- summary
- next step
- suggested title
- suggested type
- suggested wizard answer
- thread context
- project context
- hints

### 3. Shared Speech Entry Point

Keep one speech service path for all assistant output.

It should support:

- wake acknowledgment
- briefing narration
- wizard guidance
- dock responses
- save confirmation

The speech path should not branch into competing logic per screen.

### 4. Memory and Thread Context

Thread memory should stay small and useful.

It should keep:

- the current remembered thread
- the latest visible summary
- the active project context
- the current mode
- the last useful assistant reply

### 5. Review-First Save Boundary

The assistant may help draft, suggest, and guide.

It should not:

- save silently
- overwrite transcript text silently
- replace the local review step
- bypass manual confirmation

---

## Files Most Likely To Change

These are the likely touch points for Phase 1:

- [lib/features/voice_assistant/application/voice_session_controller.dart](/d:/Dev/Projects/New%20Earth%20-%20Command%20Dashboard/lib/features/voice_assistant/application/voice_session_controller.dart)
- [lib/features/voice_assistant/application/voice_ai_assist_controller.dart](/d:/Dev/Projects/New%20Earth%20-%20Command%20Dashboard/lib/features/voice_assistant/application/voice_ai_assist_controller.dart)
- [lib/features/voice_assistant/voice_speech_service.dart](/d:/Dev/Projects/New%20Earth%20-%20Command%20Dashboard/lib/features/voice_assistant/voice_speech_service.dart)
- [lib/features/voice_assistant/voice_command_service.dart](/d:/Dev/Projects/New%20Earth%20-%20Command%20Dashboard/lib/features/voice_assistant/voice_command_service.dart)
- [lib/features/voice_assistant/voice_assistant_screen.dart](/d:/Dev/Projects/New%20Earth%20-%20Command%20Dashboard/lib/features/voice_assistant/voice_assistant_screen.dart)
- [lib/features/voice_assistant/widgets/voice_conversation_dock.dart](/d:/Dev/Projects/New%20Earth%20-%20Command%20Dashboard/lib/features/voice_assistant/widgets/voice_conversation_dock.dart)
- [lib/features/voice_assistant/widgets/voice_handsfree_layer.dart](/d:/Dev/Projects/New%20Earth%20-%20Command%20Dashboard/lib/features/voice_assistant/widgets/voice_handsfree_layer.dart)

---

## Recommended Implementation Order

1. Tighten the shared session state machine.
2. Standardize the response contract.
3. Centralize speech output into one predictable path.
4. Make wake, dock, and assistant screen use the same response flow.
5. Keep thread memory and follow-up context consistent.
6. Remove duplicate or competing speech decisions.
7. Add or update tests for ownership, routing, and response shape.

---

## Acceptance Criteria

This phase is complete when:

- only one assistant turn can own speech or listening at a time
- wake, dock, and assistant screen all use the same assistant turn model
- all assistant replies flow through one speech entry point
- the response contract is consistent across all assistant surfaces
- thread context stays visible and local-first
- the review-first save boundary is still intact
- the assistant feels calmer and more unified than before
- `flutter analyze` passes
- targeted voice tests pass
- Windows build verification passes if the platform path is touched

---

## Safety Requirements

- Do not remove the local fallback.
- Do not add auto-save.
- Do not add background always-on recording.
- Do not hide the raw transcript.
- Do not let AI own the data layer.
- Do not let multiple speech paths compete.

---

## Final Codex Response Required

When this task is eventually completed, report:

1. Files created.
2. Files modified.
3. What was changed in the assistant turn model.
4. What speech paths were unified.
5. What tests and build checks passed.
