# Test Plan

## Purpose

This document is a practical guide for testing the New Earth Command Dashboard thoroughly.

Use it when you want to verify the current build by hand, not just trust automated tests. The goal is to catch real app feel issues, broken flows, missing refreshes, and navigation problems before they become habits.

## Before You Start

1. Open the project in VS Code or your editor of choice.
2. Run `flutter pub get` if dependencies are not installed yet.
3. Make sure the current branch is the one you want to validate.
4. Run the baseline checks:
   - `flutter analyze`
   - `flutter test`
5. Start the app locally:
   - `flutter run -d windows`
   - or run on another supported device if you are checking a different platform.

## Testing Mindset

Test in this order:

1. App launches and navigation.
2. Core data creation and editing.
3. Refresh and persistence after leaving a screen.
4. Voice capture and inbox processing.
5. Edge cases, fallback states, and awkward layouts.

When something feels off, note:

- which screen you were on
- what you clicked
- what you expected
- what actually happened
- whether it was a visual issue, a data issue, or a navigation issue

## Quick Smoke Pass

Do this first every time you test a new build.

- [ ] App launches without errors.
- [ ] Dashboard opens as the landing screen.
- [ ] Bottom navigation works.
- [ ] More screen opens and closes normally.
- [ ] Projects screen opens.
- [ ] Tasks screen opens.
- [ ] Planner screen opens.
- [ ] Each supporting screen under More loads cleanly.
- [ ] Back buttons return you to the previous screen.

If any of those fail, stop and fix the issue before doing a deeper pass.

## Full Manual Checklist

### Dashboard

- [ ] Dashboard shows the current day, top focus, and summary cards.
- [ ] Top 3 tasks are visible when present.
- [ ] Quick capture buttons open the right flow.
- [ ] Voice Capture opens the Voice Assistant.
- [ ] Dashboard links to projects, tasks, planner, and More work.
- [ ] Remove or update a Top 3 task from the dashboard if the control is available.
- [ ] Dashboard layout stays calm and readable at normal window size.
- [ ] Dashboard still looks usable after resizing the window narrower.

### Projects

- [ ] Projects list loads.
- [ ] A project card can be opened.
- [ ] Add project works if the screen exposes it.
- [ ] Edit project loads existing values.
- [ ] Project detail shows purpose, status, progress, next action, and notes.
- [ ] Project detail shows active and blocked tasks.
- [ ] Project detail now surfaces recent linked Journal entries, Learning items, Content ideas, and Business opportunities.
- [ ] Project-aware create shortcuts open the correct create screen with the project preselected.
- [ ] Archive flow prompts for confirmation and behaves correctly.
- [ ] Returning to Projects after an edit or archive keeps the list in sync.

### Tasks

- [ ] Tasks list loads local items.
- [ ] Add task creates a new task.
- [ ] Edit task loads the saved values.
- [ ] Save updates are reflected after returning to the list.
- [ ] Status changes persist.
- [ ] Project assignment persists.
- [ ] Top 3 task controls work.
- [ ] A fourth Top 3 task is blocked if that rule is enforced.
- [ ] Move to Today works.
- [ ] Parked and Done states work.
- [ ] Archive flow prompts for confirmation.
- [ ] Search works.
- [ ] Search combines correctly with filters.
- [ ] Status filter works.
- [ ] Project filter works.

### Planner

- [ ] Planner loads the daily plan.
- [ ] Today's focus and planning fields display correctly.
- [ ] Top 3 tasks are shown in the planner where expected.
- [ ] Save actions update the dashboard.
- [ ] Evening review fields save correctly.
- [ ] Carry forward notes persist.
- [ ] Tomorrow focus persists.

### More Menu

- [ ] More screen opens.
- [ ] Each supporting area is reachable.
- [ ] Each screen title is correct.
- [ ] Each screen has a sensible empty state if there is no data.
- [ ] Back navigation returns to More or the previous screen.

### Journal

- [ ] Journal list opens.
- [ ] A new journal entry can be created.
- [ ] A linked journal entry can be created from Project Detail.
- [ ] Editing an existing journal entry loads the current values.
- [ ] Saving updates the list.
- [ ] Journal entries keep their project link after save.

### Learning

- [ ] Learning list opens.
- [ ] A new learning item can be created.
- [ ] A linked learning item can be created from Project Detail.
- [ ] Editing an existing learning item works.
- [ ] Save updates the list.
- [ ] Project link persists.

### Content

- [ ] Content list opens.
- [ ] A new content item can be created.
- [ ] A linked content item can be created from Project Detail.
- [ ] Editing an existing content item works.
- [ ] Save updates the list.
- [ ] Project link persists.

### Business

- [ ] Business list opens.
- [ ] Add business opportunity works.
- [ ] Edit opportunity loads current values.
- [ ] The current business types and statuses match the app spec.
- [ ] Project link persists.
- [ ] Save updates are reflected in the list.
- [ ] Archive or blocked states behave as expected if available.

### Inbox

- [ ] Inbox opens.
- [ ] Only unprocessed items are shown.
- [ ] Parked items remain visible with parked status.
- [ ] Convert a task-like item into a Task.
- [ ] Convert a note into Journal, Content, Learning, or Business where appropriate.
- [ ] Converted items disappear from Inbox.
- [ ] Inbox records keep processed metadata.

### Voice Assistant

- [ ] Voice Assistant opens from Dashboard or More.
- [ ] Windows voice typing opens without forcing the app out of fullscreen.
- [ ] Transcript preview can be edited with the keyboard.
- [ ] Backspace works normally inside the transcript field.
- [ ] Start, Stop, and Cancel behave sensibly.
- [ ] Mock transcript and paste transcript fallback work.
- [ ] The assistant suggests a type when the transcript clearly implies one.
- [ ] The assistant suggests a title when the transcript has a clear headline.
- [ ] The assistant suggests a project when the transcript names one.
- [ ] Structured fields can be edited before save.
- [ ] Saving as Task creates the correct local record.
- [ ] Saving as Journal creates the correct local record.
- [ ] Saving as Content creates the correct local record.
- [ ] Saving as Business creates the correct local record.
- [ ] Saving as Inbox Idea stores the item correctly.
- [ ] Codex Prompt remains a review-only action.

### Settings

- [ ] Settings screen opens.
- [ ] Any toggles or stored values load correctly.
- [ ] Settings changes persist after leaving and returning.

## Deep Validation Pass

After the smoke pass, do this longer walk-through:

1. Create a project.
2. Add a task to that project.
3. Open Project Detail and confirm the task appears in the linked area.
4. Add a journal entry from Project Detail.
5. Add a learning item from Project Detail.
6. Add a content item from Project Detail.
7. Add a business opportunity from Project Detail.
8. Open Inbox and convert one item into a Task.
9. Use Voice Assistant to create one Task and one Journal entry.
10. Close the app.
11. Reopen the app.
12. Confirm the saved data is still there.

This pass catches the most important thing for a local-first app: the flows need to connect, and the data needs to survive restart.

## Edge Cases Worth Checking

- [ ] Resize the window narrower and wider while on Project Detail.
- [ ] Resize the window while on Voice Assistant.
- [ ] Try empty fields in add/edit forms.
- [ ] Try very long project names and task titles.
- [ ] Try a voice transcript with no obvious type.
- [ ] Try a voice transcript with multiple likely destinations.
- [ ] Try saving and then immediately reopening the same item.
- [ ] Try backing out of a dialog without confirming.
- [ ] Try repeated navigation into the same screen from different entry points.

## Recommended Command List

Run these during or after manual testing:

- `flutter analyze`
- `flutter test`
- `flutter test test/widget_test.dart -r expanded`
- `flutter build windows`
- `flutter run -d windows`

## What to Record

When you find a problem, record:

- screen name
- exact action
- exact text if relevant
- whether it happened once or every time
- whether it was a UI issue, a data issue, or a route issue
- whether it still happens after restarting the app

## Acceptance Criteria

The build is in good shape when:

- the app launches cleanly
- navigation feels stable
- create/edit flows save correctly
- project-linked items appear where expected
- inbox conversion works
- voice capture works on the supported path
- the app survives close and reopen with data intact
- automated tests and analyzer checks pass

## Final Note

This guide is meant to be used with the app open beside it. Keep the checklist close, go screen by screen, and mark anything that feels rough enough to slow down a real person.
