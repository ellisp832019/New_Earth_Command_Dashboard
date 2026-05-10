# TASK - Voice Bridge Wizard Mode

## Goal

Make the Voice Assistant feel like a fast-moving AI command surface by adding a voice wizard mode, briefing layer, reusable starters, quick review, wake phrase detection, smarter command macros, project capture, thread memory, a handsfree wake listener that can bring the assistant forward when Gaia is open, and a direct in-dock follow-up loop.

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
2. Add smart voice starter commands that preload common voice workflows, including project capture and day-review macros.
3. Let saved voice history be reused quickly from the Voice Assistant screen.
4. Add a voice briefing card that summarizes the command and suggests the next sequence of actions.
5. Add a wizard mode that asks one question at a time and assembles the draft from answers.
6. Keep transcript editing, Codex prompts, and local saves working.
7. Let projects be created and reviewed from voice as a first-class capture type.
8. Recognize wake phrases like `Hey Gaia` and strip them before intent parsing.
9. Preserve the existing dashboard and quick capture flows.
10. Add a remembered thread card so the assistant can continue a voice conversation across multiple entries.
11. Add a Windows startup gate that waits for a connected headset or headset microphone before the app fully opens.
12. Add a lightweight handsfree wake listener so `Hey Gaia` can open Voice Assistant while the app is running.
13. Make the wake-triggered assistant speak back immediately so it feels conversational and responsive.
14. Add a stronger local desktop speech bridge on Windows so one-shot microphone capture can use local Whisper transcription before falling back to system dictation.
15. Surface a dashboard conversation dock when wake capture lands there so the assistant has a visible fallback if the route handoff is delayed, let that dock speak the captured reply through the configured voice output, and offer quick follow-up chips that reopen the assistant with a preselected intent.
16. Run `flutter analyze`, `flutter test`, and a Windows build if possible.

## Expected Result

The user can open Voice Assistant, start from a smart template or a previous command, review a briefing that explains the command and its next steps, continue a remembered thread across entries, or step through a wizard that builds the draft one answer at a time, then save the result into the right local dashboard module with minimal friction.
