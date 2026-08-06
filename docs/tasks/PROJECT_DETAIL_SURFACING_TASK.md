# Codex Task - Project Detail Linked Module Surfacing

## Task Title

Make Project Detail the central home for linked work on a project.

---

## Context

Project Detail already shows the project header, tasks, and journal trail. The next improvement is to surface the other project-linked modules so the page feels like the home base for a project rather than just a summary card.

---

## Current Objective

Update Project Detail so it shows:

1. Recent Journal Entries
2. Recent Learning Items
3. Recent Content Ideas
4. Recent Business Opportunities

Also add project-aware create shortcuts for those linked modules.

---

## Safety Requirements

- Keep the layout calm and readable.
- Do not remove existing task or journal links.
- Keep local-first behavior.
- Avoid wide layout regressions on Windows.

---

## Acceptance Criteria

- Project Detail shows the linked module lists.
- Project Detail has create shortcuts for Journal, Learning, Content, and Business.
- Linked items open their edit screens when tapped.
- `flutter analyze` passes.
- `flutter test` passes.
- Windows build still works if possible.
