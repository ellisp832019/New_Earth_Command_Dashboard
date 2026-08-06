# CODEX TASK 29 - Voice AI Adapter Contract

## Goal

Add a small provider-based AI adapter contract for the Voice Assistant so future AI help can plug into briefing, wizard, history, and follow-up surfaces without replacing the current review-first flow.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/roadmap/ai_10_task_roadmap.md`
- `docs/user_guide/voice_assistant_guide.md`
- `docs/user_guide/app_function_reference.md`
- `TASK.md`

## Requirements

1. Keep the adapter separate from the UI.
2. Provide a local-safe stub implementation first.
3. Make the adapter provider-based so future implementations can be swapped cleanly.
4. Keep the current Voice Assistant working without any real AI backend.
5. Keep the review-first rule intact.
6. After implementation, run `flutter analyze` and voice tests if possible.

## Expected Result

The Voice Assistant has a stable AI seam that can be wired into future suggestions and summaries without changing the current local-first capture flow.
