# Codex Task - AI Assistant Phase 5: Make Wizard Mode Truly Helpful

## Status

Complete.

This task makes wizard mode feel like a calm guided conversation instead of a form.

---

## Task Title

Make wizard mode ask one question at a time, show clear progress, and keep the next step obvious.

---

## Current Objective

Refine the wizard flow so the user always knows which question is being asked, how far they are through the draft, and what happens after each answer.

This means:

1. The current step is visible.
2. The progress through the wizard is visible.
3. The prompt stays one-question-at-a-time.
4. The spoken handoff matches the current step.
5. The review stage remains the final stop before save.

---

## Scope

### In Scope

- Add explicit wizard progress cues.
- Keep per-step prompts calm and specific.
- Keep the draft assembled as answers arrive.
- Keep the review step before save.
- Make the wizard surface feel simpler and more guided.

### Out of Scope

- New AI provider routing.
- New memory model work.
- Auto-save.
- Realtime voice changes.
- New dashboard modules.

---

## Acceptance Criteria

This phase is complete when:

- the user can see which wizard step is active
- the user can see that the wizard is moving forward
- each wizard prompt asks only for the next needed answer
- the spoken guidance matches the new step
- the wizard reply surface stays calm and uncluttered
- `flutter analyze` passes
- targeted voice tests pass
- Windows build verification passes if the platform path is touched

---

## Safety Requirements

- Do not remove the local fallback.
- Do not add auto-save.
- Do not let wizard mode bypass review.
- Do not hide the draft before save.
- Do not add competing wizard flows.
