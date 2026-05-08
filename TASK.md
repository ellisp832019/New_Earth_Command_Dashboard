# TASK - Voice Bridge Smart Capture

## Goal

Make the Voice Assistant feel more like a smart, guided command surface by adding reusable voice starters, faster review, and richer command recall.

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

1. Keep capture review-first and local-first.
2. Add smart voice starter commands that preload common voice workflows.
3. Let saved voice history be reused quickly from the Voice Assistant screen.
4. Keep transcript editing, Codex prompts, and local saves working.
5. Preserve the existing dashboard and quick capture flows.
6. Run `flutter analyze`, `flutter test`, and a Windows build if possible.

## Expected Result

The user can open Voice Assistant, start from a smart template or a previous command, edit the transcript, review the suggested structure, and save the result into the right local dashboard module with minimal friction.
