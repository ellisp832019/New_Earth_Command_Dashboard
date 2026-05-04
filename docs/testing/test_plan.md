# Test Plan

## Purpose

This document describes how to test the current New Earth Command Dashboard app and how to use it in its current state.

It is intended for manual testers, developers doing exploratory validation, and anyone who wants a quick walkthrough of the app's core flows.

## Setup

1. Open the project in VS Code.
2. Run `flutter pub get` if dependencies are not already installed.
3. Use the following commands to validate the codebase:
   - `flutter analyze`
   - `flutter test`
4. To run the app locally in debug mode:
   - `flutter run -d windows`
   - or use an emulator/device of your choice.

## General Testing Approach

Focus on the core local-first workflow first. The app is built around capturing work, planning daily progress, and tracking projects and business opportunities.

Test the following levels:

- **Static validation**: `flutter analyze`
- **Automated unit/widget tests**: `flutter test`
- **Manual flows**: navigation, create/update items, persistence, and UI responses.

## How to Use the App

The app is a calm command dashboard for daily work and projects.

### Core workflow

1. Open the app and land on the **Dashboard**.
2. Review the day’s top focus and quick status cards.
3. Use the **Projects** screen to capture or inspect active projects.
4. Use the **Tasks** screen to manage immediate work and top tasks.
5. Use the **More** menu to access supporting areas:
   - Journal
   - Learning
   - Content
   - Business
   - Wellbeing
   - Inbox
   - Voice Assistant
   - Settings
6. The **Business** screen is currently a key workflow for capturing opportunities, partnerships, and leads.

### Core app behavior

- The app should start on the dashboard.
- Navigation should work from the bottom bar and the More screen.
- New items should be saved locally and appear in the relevant list.
- Edit screens should prefill existing data and update items correctly.
- The app should remain responsive during loading and error states.

## Recommended Manual Test Flows

### Dashboard

- Confirm the dashboard opens successfully.
- Verify the top cards display the current plan, focus, energy, and available categories.
- Tap through to the linked project, tasks, planner, or More screen.

### Projects

- Open the Projects screen.
- Create a new project if the flow is available.
- Verify project details display correctly.
- Archive or update a project if those controls exist.

### Tasks

- Open the Tasks screen.
- Add a new task and verify it appears in the list.
- Edit a task and save changes.
- Mark a task complete if available.

### Planner

- Open the Planner screen.
- Inspect the daily plan details.
- Confirm the plan shows the correct date and any seeded tasks or focus.

### More menu

- Open the More screen.
- Navigate to each supporting area and confirm the screen loads.
- Use the back button to return from each screen.

### Business

This page is especially important for the current app state.

#### Add new opportunity

1. Open the Business screen.
2. Tap the add button.
3. Fill in an opportunity name.
4. Select a related project if available.
5. Choose a type and status.
6. Enter optional fields such as company/contact, next step, deadline, follow-up date, document link, and notes.
7. Save the opportunity.
8. Confirm the item appears in the business list.

#### Edit existing opportunity

1. Tap a business opportunity card.
2. Verify the edit screen title reads `Edit Opportunity`.
3. Confirm the form fields are prefilled.
4. Change the opportunity name or status.
5. Save the change.
6. Confirm the updated name appears in the list.

### Business add/edit coverage

- Confirm the add flow can create a new opportunity and return to the Business list.
- Confirm the edit flow loads the existing opportunity data and saves updates.
- This path is covered by focused widget tests in `test/features/business/business_edit_widget_test.dart`.

### Wellbeing, Inbox, Journal, Learning, Content, Voice Assistant, Settings

- Open each screen.
- Ensure the screen title and content are visible.
- If any input or add flow exists, exercise it briefly.
- If there are menu or settings toggles, verify they update the app state.

## Test Commands

- `flutter analyze`
- `flutter test`
- `flutter test test/features/business/business_edit_widget_test.dart`
- `flutter run -d windows`

## Acceptance Criteria

- The app launches and renders the dashboard without errors.
- Navigation works for the bottom bar and More menu.
- Projects, Tasks, and Business screens load and show their lists.
- Business add/edit flows work and persist data.
- No analyzer issues remain.
- Focused widget tests for business edit flow pass.

## Notes for Testers

- The app is local-first, so all saved data is kept in the device/emulator storage.
- Use the current date and flows as the baseline for daily planning.
- Prioritize the core dashboard, project tracking, and business opportunity flows.
- Document any broken flows, missing buttons, or unexpected navigation behavior.

## Current Priority Areas

- Dashboard usability and navigation
- Business opportunity add/edit flow
- Data persistence and list refreshing
- Basic project and task creation flows

---

This test plan reflects the current state of the app and is a practical guide for validating the whole experience. If you want, I can also add a second doc with a concise quick-start guide for new users.