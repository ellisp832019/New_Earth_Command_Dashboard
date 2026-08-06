# Codex Task - AI Assistant Phase 3: Unify The Response Contract

## Status

Complete.

Historical task record. This slice is complete and kept here for reference.

This task standardizes the response shape used by the local assistant and the AI assist layer.

---

## Task Title

Unify the assistant response contract so local review, AI assist, memory, and spoken replies all use the same shape.

---

## Current Objective

Create one shared assistant response contract that powers:

1. Review cards.
2. Spoken replies.
3. Wizard guidance.
4. Memory summaries.
5. Local and AI assist fallback behavior.

---

## Scope

### In Scope

- Introduce a shared assistant response base class.
- Keep local and AI responses on the same field set.
- Preserve local-first and review-first behavior.
- Add tests to prove the contract is shared.

### Out of Scope

- New AI provider routing.
- Realtime voice work.
- Auto-save.
- New assistant features beyond the contract shape.

---

## Acceptance Criteria

This phase is complete when:

- the local and AI response paths share the same contract
- summary, next step, title, type, hints, and thread/project context are represented consistently
- existing voice flows still work
- `flutter analyze` passes
- targeted voice tests pass
- Windows build verification passes if the platform path is touched

---

## Safety Requirements

- Do not remove the local fallback.
- Do not add auto-save.
- Do not let multiple response shapes drift apart again.
