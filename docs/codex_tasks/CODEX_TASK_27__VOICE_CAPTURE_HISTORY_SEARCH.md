# CODEX TASK 27 - Voice Capture History Search

## Goal

Make the Voice Assistant command history searchable so Hayley can find and reuse recent captures without scrolling through the full list.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/roadmap/voice_10_task_roadmap.md`
- `docs/user_guide/voice_assistant_guide.md`
- `docs/user_guide/app_function_reference.md`
- `TASK.md`

## Requirements

1. Keep the change inside the Voice Assistant history area.
2. Add a calm search field to the command history list.
3. Filter by transcript and command type.
4. Keep the history review-first and reusable.
5. Keep the current tap-to-restore behavior.
6. After implementation, run `flutter analyze` and voice tests if possible.

## Expected Result

Hayley can search recent voice captures by phrase or type, quickly restore a useful command, and keep moving without hunting through the full history list.
