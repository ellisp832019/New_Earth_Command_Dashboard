# Getting Started

New Earth Command Dashboard is a local-first app for turning a large mission into a calmer working day.

The current V0.1 flow is:

1. Open the Dashboard.
2. Set today's focus.
3. Choose the Top 3 tasks.
4. Work from Projects, Tasks, or Planner.
5. Review the day in the Planner.
6. Carry forward what still matters.
7. Capture tomorrow's likely focus before closing the day.

## Current App State

The current build now includes:

- Dashboard-first launch
- Bottom navigation for Dashboard, Projects, Tasks, Planner, and More
- Drift and SQLite local storage
- Seeded default New Earth projects
- Automatic blank DailyPlan creation for today
- Live Dashboard cards for focus, Top 3 tasks, active projects, and evening review entry
- Live Projects and Tasks screens
- Project detail, add/edit, archive, and linked journal surfacing
- Task create/edit flows
- Task status actions for Move To Today, Mark Done, Park, and Archive
- Task status and project filters
- Task search by title and notes
- Journal list, create-entry, and edit-entry flow
- Learning list and add-topic flow
- Content list and add-idea flow
- Business list and add-opportunity flow
- Wellbeing list and check-in flow
- Planner editing for:
  - Morning Intention
  - Main Focus
  - Why It Matters
  - Top 3 Tasks
  - Evening Review
  - Carry Forward
  - Tomorrow's Focus

Still intentionally early:

- Supporting modules beyond navigation scaffolds
- Quick Capture to real Inbox flow

## Main Navigation

Use the bottom navigation for the five primary areas:

- Dashboard: today's focus, Top 3, active projects, and quick access to evening review
- Projects: seeded project list and project status overview
- Tasks: current tasks and Top 3 toggles
- Planner: morning planning, evening review, carry forward, and tomorrow focus
- More: supporting modules and parked voice assistant work

## Daily Use Flow

### Morning

Start on the Dashboard or Planner.

Recommended rhythm:

1. Set `Main Focus`
2. Add `Why It Matters`
3. Add a `Morning Intention`
4. Choose up to 3 priority tasks

### During the Day

Use:

- `Projects` to stay oriented around the wider mission
- `Project Detail` to review a single project, add a linked task, edit it, or archive it when it should leave the active build view
- `Project Detail` to also see recent linked journal history and reopen project notes from the build trail
- `Tasks` to create tasks, edit them, search them, move them into Today, mark them Done, park them, archive older work, and manage Top 3 status
- `Dashboard` to stay anchored on today's focus

### End of Day

From the Dashboard:

1. Tap `Start Evening Review`
2. The app opens the Planner and scrolls to the review section
3. Record:
   - what moved forward
   - what was completed
   - what was learned
   - what blocked progress
4. Save `Carry Forward`
5. Save `Tomorrow's Focus`

## Supporting Modules

The More screen keeps the app calm by holding secondary areas:

- Journal
- Learning
- Content
- Business
- Wellbeing
- Inbox
- Voice Assistant
- Settings

Some of these are still scaffolded for later MVP slices, but Learning now has its first real local flow.

## Journal Flow

From `More`:

1. Open `Journal`
2. Tap `Add Entry`
3. Add a title
4. Optionally link a related project and task
5. Choose a category
6. Capture what you worked on, learned, and what should happen next
7. Reopen any saved entry from the list to update it later

Each entry is stored locally, appears in the Journal list after saving, and can be reopened for editing.

## Learning Flow

From `More`:

1. Open `Learning`
2. Tap `Add Learning Topic`
3. Add the topic you want to build skill in
4. Optionally link it to a related project
5. Add why it matters, a resource link, notes, confidence, and the next step
6. Save it back into the local list

Each learning item is stored locally and appears in the Learning list with its project, status, confidence, and next step.

## Content Flow

From `More`:

1. Open `Content`
2. Tap `Add Content Idea`
3. Add the title for the post, draft, or update
4. Optionally link it to a project
5. Choose the platform, content type, and status
6. Add draft text, image-needed context, and notes
7. Save it back into the local list

Each content item is stored locally and appears in the Content list with its platform, project, type, status, and image-needed state.

## Business Flow

From `More`:

1. Open `Business`
2. Tap `Add Opportunity`
3. Add the opportunity or practical action name
4. Optionally link it to a project
5. Choose the type and status
6. Add company/contact, next step, follow-up details, supporting link, and notes
7. Save it back into the local list

Each business item is stored locally and appears in the Business list with its type, project, status, deadline, next step, and follow-up date.

## Wellbeing Flow

From `More`:

1. Open `Wellbeing`
2. Tap `Add Check-In`
3. Record energy, mood, sleep quality, and stress
4. Mark movement, food and water, and reflection if they happened
5. Add any notes that help explain the day
6. Save it back into the local list

Each wellbeing check-in is stored locally and appears in the Wellbeing list with its energy, mood, stress, and suggested workload.

## Visual References

Useful assets:

- `assets/user_guide/35_getting_started_quick_start.png`
- `assets/user_guide/36_dashboard_user_manual_page.png`
- `assets/screenshots/27_mobile_app_screens_overview.png`

These remain useful references for future documentation and screenshots.
