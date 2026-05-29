# CODEX TASK 31 — Voice AI Briefing Wire-up

## Goal

Connect the new optional AI assist seam into the Voice Assistant briefing flow so Gaia can show review-first AI suggestions without changing the local-first save path.

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

1. Keep AI optional and review-first.
2. Route Voice Assistant briefing requests through the AI adapter seam.
3. Keep the local NoOp provider as the safe default.
4. Surface the AI assist result in the Voice Assistant briefing card.
5. Show a useful AI summary, next step, and hints without changing save behavior.
6. Add tests for the provider routing and visible briefing output.
7. Run `flutter analyze` and the voice-focused tests after the change.

## Expected Result

Voice Assistant has a visible optional AI assist layer inside the briefing card. Hayley can see AI suggestions for the current capture or thread, but the app still stays calm, review-first, and local-first by default.
