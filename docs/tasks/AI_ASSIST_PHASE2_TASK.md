# Codex Task - AI Assistant Phase 2: Make The Voice Calm And Consistent

## Status

Complete.

Historical task record. This slice is complete and kept here for reference.

This task refines the voice layer so the dashboard assistant sounds steady, brief, and dependable across wake, dock, and assistant surfaces.

---

## Task Title

Make the assistant voice feel calm and consistent by stabilizing cadence, shortening spoken replies, and keeping one stable speech profile.

---

## Current Objective

Refine the shared speech path so assistant output sounds even and useful instead of varied or dramatic.

This means:

1. One speech queue.
2. One stable voice profile.
3. Tone-aware wording only.
4. Shorter spoken replies.
5. No competing TTS behavior during the same turn.

---

## Scope

### In Scope

- Stabilize rate and pitch handling.
- Keep the assistant's spoken phrasing short and calm.
- Keep wake, briefing, save confirmation, and follow-up speech even in tone.
- Avoid drastic voice variation between surfaces.
- Add tests for the stable speech rules.

### Out of Scope

- New assistant features.
- New AI provider routing.
- New memory behavior.
- Auto-save.
- Always-listening behavior.

---

## Acceptance Criteria

This phase is complete when:

- wake does not sound louder than briefing
- save does not sound more urgent than planning
- spoken replies stay brief and calm
- the assistant voice feels steady across surfaces
- `flutter analyze` passes
- targeted voice tests pass
- Windows build verification passes if the platform path is touched

---

## Safety Requirements

- Do not remove the local fallback.
- Do not add auto-save.
- Do not add background always-on recording.
- Do not let multiple speech paths compete.
