# Codex Task - AI Assistant Phase 4: Build The Review-First Briefing Flow

## Status

Complete.

Historical task record. This slice is complete and kept here for reference.

This task makes the visible briefing surface the primary review point for the assistant.

---

## Task Title

Build a review-first briefing flow that explains the transcript, shows the next move, and keeps the raw input visible.

---

## Current Objective

Refine the assistant UI so the user gets one calm briefing surface that makes the next move obvious before anything is saved.

This means:

1. The briefing card is the primary visible review surface.
2. The raw transcript stays visible alongside the summary.
3. The next step is obvious and calm.
4. The spoken briefing matches the visual briefing.

---

## Scope

### In Scope

- Improve the briefing card copy and layout.
- Keep the raw transcript visible in the briefing flow.
- Keep the briefing and spoken reply aligned.
- Keep the review-first save boundary intact.

### Out of Scope

- New AI provider routing.
- New memory model work.
- Auto-save.
- New wizard logic.
- Realtime voice changes.

---

## Acceptance Criteria

This phase is complete when:

- the briefing surface clearly explains what the transcript means
- the next move is shown in the same place the user reviews the capture
- the raw transcript remains visible during review
- the spoken briefing matches the visible briefing
- `flutter analyze` passes
- targeted voice tests pass
- Windows build verification passes if the platform path is touched

---

## Safety Requirements

- Do not remove the local fallback.
- Do not add auto-save.
- Do not hide the raw transcript.
- Do not add competing briefing surfaces.
