# TASK - Live Voice Capture

## Goal

Make Voice Capture more powerful by adding press-to-listen microphone transcription inside the app while keeping review-before-save.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/tasks/VOICE_BRIDGE_TASK.md`

## Requirements

1. Keep existing dashboard, projects, tasks, planner, journal, inbox, business, and voice save flows working.
2. Add live microphone capture to the Voice Assistant screen where the platform recognizer is stable.
3. Listening must be explicit: start, stop, or cancel. Do not add always-listening behaviour.
4. Put recognized speech into the transcript preview field so it can be edited before saving.
5. Keep paste transcript and mock transcript fallbacks.
6. Save reviewed transcripts into the existing local destinations only after user action.
7. Keep Codex prompts manual-review only.
8. Add required platform permission text/configuration.
9. Keep Windows app launch/debug stable by using native Windows voice typing from inside the app instead of the unstable beta recognizer.
10. Run `flutter analyze`, `flutter test`, and a Windows build if possible.

## Expected Result

The user can open Voice Capture, capture speech or dictated text into the transcript box, review/edit the captured transcript, and save it as a task, journal entry, inbox idea, content idea, or business opportunity.
