# TASK - Voice Bridge Wizard Mode

## Goal

Make the Voice Assistant feel more like a smart, guided command surface by adding a voice wizard mode, briefing layer, reusable starters, faster review, and richer command recall.

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
4. Add a voice briefing card that summarizes the command and suggests the next sequence of actions.
5. Add a wizard mode that asks one question at a time and assembles the draft from answers.
6. Keep transcript editing, Codex prompts, and local saves working.
7. Preserve the existing dashboard and quick capture flows.
8. Run `flutter analyze`, `flutter test`, and a Windows build if possible.

## Expected Result

The user can open Voice Assistant, start from a smart template or a previous command, review a briefing that explains the command and its next steps, or step through a wizard that builds the draft one answer at a time, then save the result into the right local dashboard module with minimal friction.
