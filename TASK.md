# TASK - Inbox Processing Foundation

## Goal

Turn Inbox into the triage layer of the app so captured items can be converted into Tasks, Journal Entries, Content Ideas, Learning Items, and Business Opportunities.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/10_testing_release.md`
- `docs/roadmap/mvp_execution_plan.md`

## Requirements

1. Keep existing dashboard, projects, tasks, planner, journal, business, wellbeing, and voice flows working.
2. Show unprocessed Inbox items only.
3. Add explicit item actions for Park and Convert.
4. Convert Inbox items into:
   - Task
   - Journal Entry
   - Content Idea
   - Learning Item
   - Business Opportunity
5. Preserve the original capture text by mapping it into the most useful target fields.
6. Mark converted Inbox items as processed and store the converted record metadata.
7. Keep Dashboard quick capture saving into Inbox.
8. Keep the flow local-first and review-first.
9. Run `flutter analyze`, `flutter test`, and a Windows build if possible.

## Expected Result

The user can open Inbox, see the items that still need processing, convert them into the right module, or park them for later without losing the original capture.
