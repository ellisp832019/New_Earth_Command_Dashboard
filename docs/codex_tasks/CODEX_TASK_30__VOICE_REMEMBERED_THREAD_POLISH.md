# CODEX TASK 30 — Voice Remembered Thread Polish

## Goal

Make the Voice Assistant remembered-thread card easier to pick back up from by clarifying the resume state, the latest capture, and the saved entry count.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/VOICE_BRIDGE_FSD.md`
- `docs/tasks/VOICE_BRIDGE_TASK.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/10_testing_release.md`

## Requirements

1. Keep the current remembered-thread state local-first and review-first.
2. Make the thread card read more like a resume surface than a generic status block.
3. Show the latest capture and saved entry count more clearly.
4. Keep the current thread behavior and save flow unchanged.
5. Add or update tests for the remembered-thread card wording and visibility.
6. Run `flutter analyze` and voice-focused tests after the change.

## Expected Result

Hayley can open Voice Assistant, see the remembered thread clearly, and understand that she can resume the latest saved step or start fresh without losing the current conversation context.
