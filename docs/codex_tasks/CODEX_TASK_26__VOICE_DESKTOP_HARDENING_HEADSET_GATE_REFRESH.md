# CODEX TASK 26 - Voice Desktop Hardening: Headset Gate Refresh

## Goal

Harden the Windows voice startup gate so Gaia keeps rechecking for a connected headset while the gate screen is open, making it easier to plug in the device and continue without restarting the app.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/roadmap/voice_10_task_roadmap.md`
- `docs/user_guide/voice_assistant_guide.md`
- `docs/user_guide/app_function_reference.md`
- `TASK.md`

## Requirements

1. Keep the change inside the voice startup gate.
2. Auto-refresh the headset check while the gate is visible.
3. Keep the screen calm and local-first.
4. Keep the current Retry and Continue without Voice actions.
5. Update the voice guide if the user-facing behavior changes.
6. After implementation, run `flutter analyze` and voice tests if possible.

## Expected Result

If Hayley connects her headset after opening Gaia, the gate should notice automatically and move on without requiring a full app restart.
