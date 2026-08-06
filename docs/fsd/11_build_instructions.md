# Build Instructions

FSD Part 11 — Final MVP Summary, Build Instructions & First Coding Tasks
Project Name
New Earth Command Dashboard
Document Version
V0.1 — Final MVP Build Summary
________________________________________
1. Purpose of This Section
This section turns the full FSD into a practical starting point for development.
It defines:
1. Final MVP summary
2. Recommended repo structure
3. Flutter packages
4. First setup commands
5. First folder structure
6. First coding tasks
7. Codex-ready task list
8. Initial README content
9. First development sprint
This section is the bridge between planning and building.
________________________________________
2. Final MVP Product Summary
The New Earth Command Dashboard is a local-first Flutter app designed to help manage the daily building of New Earth.
It helps Peter organise:
Projects
Tasks
Daily focus
Top 3 priorities
Learning
Business actions
Content ideas
Build journal
Wellbeing
Quick captured ideas
The first version should answer one question every day:
What matters today, and what moves New Earth forward?
________________________________________
3. MVP Core Loop
The MVP must support this daily loop:
Open app
↓
View Dashboard
↓
Set today’s focus
↓
Choose top 3 tasks
↓
Work from projects/tasks
↓
Capture notes and progress
↓
Complete evening review
↓
Carry useful actions forward
This is the heart of the app.
Everything else should support this loop.
________________________________________
4. MVP Screens
The first build should include these screens:
Dashboard
Projects
Project Detail
Tasks
Add/Edit Task
Daily Planner
Journal
Journal Entry
Learning
Content
Business
Wellbeing
Inbox
More
Settings
Mobile bottom navigation:
Dashboard
Projects
Tasks
Planner
More
The More screen links to:
Journal
Learning
Content
Business
Wellbeing
Inbox
Settings
________________________________________
5. MVP Data Entities
The app should store:
Project
Task
DailyPlan
JournalEntry
LearningItem
ContentItem
BusinessOpportunity
WellbeingCheckIn
InboxItem
AppSettings
The most important relationship:
Most things should link back to a Project where possible.
The second most important relationship:
DailyPlan controls what appears on the Dashboard each day.
________________________________________
6. Recommended Tech Stack
Frontend
Flutter
Dart
Material 3
Local Database
SQLite with Drift
State Management
Riverpod
Routing
go_router
First Platform
Android first
Later:
Windows
Linux
iOS
Web
________________________________________
7. Flutter Packages
Add these packages first:
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod: ^2.6.1
  go_router: ^14.6.2
  drift: ^2.22.1
  sqlite3: ^3.3.1
  path_provider: ^2.1.5
  path: ^1.9.0
  uuid: ^4.5.1
  intl: ^0.20.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  drift_dev: ^2.22.1
  build_runner: ^2.4.13
  flutter_lints: ^5.0.0
Package versions can be updated when the project is created, but this is a good starting point.
________________________________________
8. Repo Name
Recommended repo name:
new_earth_command_dashboard
Alternative names:
new_earth_dashboard
new_earth_os_dashboard
new_earth_command_app
Best choice:
new_earth_command_dashboard
Reason:
It clearly describes the purpose.
It fits the FSD.
It can grow into the wider New Earth operating system later.
________________________________________
9. Recommended Repo Structure
new_earth_command_dashboard/
  README.md
  pubspec.yaml

  docs/
    fsd/
      new_earth_command_dashboard_fsd.md
    architecture/
      architecture_decisions.md
    roadmap/
      mvp_roadmap.md
    testing/
      test_plan.md

  lib/
    main.dart
    app.dart

    core/
      constants/
      database/
      routing/
      theme/
      utils/
      widgets/

    features/
      dashboard/
      projects/
      tasks/
      planner/
      journal/
      learning/
      content/
      business/
      wellbeing/
      inbox/
      settings/

  test/
    unit/
    widget/
________________________________________
10. Flutter Folder Structure
Create this inside lib/:
lib/
  main.dart
  app.dart

  core/
    constants/
      app_constants.dart
      default_seed_data.dart

    database/
      app_database.dart
      tables/
        projects_table.dart
        tasks_table.dart
        daily_plans_table.dart
        journal_entries_table.dart
        learning_items_table.dart
        content_items_table.dart
        business_opportunities_table.dart
        wellbeing_checkins_table.dart
        inbox_items_table.dart
        app_settings_table.dart

    routing/
      app_router.dart
      route_names.dart

    theme/
      app_theme.dart
      app_colours.dart
      app_text_styles.dart

    utils/
      date_utils.dart
      id_utils.dart
      validation_utils.dart

    widgets/
      dashboard_card.dart
      empty_state.dart
      status_badge.dart
      priority_badge.dart
      section_header.dart
      quick_capture_button.dart

  features/
    dashboard/
      presentation/
        dashboard_screen.dart
        widgets/
          todays_focus_card.dart
          top_three_tasks_card.dart
          active_projects_card.dart
          wellbeing_summary_card.dart
      application/
        dashboard_controller.dart

    projects/
      data/
        project_repository.dart
      domain/
        project_model.dart
      presentation/
        projects_screen.dart
        project_detail_screen.dart
        add_edit_project_screen.dart
        widgets/
          project_card.dart

    tasks/
      data/
        task_repository.dart
      domain/
        task_model.dart
      presentation/
        tasks_screen.dart
        add_edit_task_screen.dart
        widgets/
          task_card.dart
          task_filter_bar.dart

    planner/
      data/
        daily_plan_repository.dart
      domain/
        daily_plan_model.dart
      presentation/
        planner_screen.dart

    journal/
      data/
        journal_repository.dart
      domain/
        journal_entry_model.dart
      presentation/
        journal_screen.dart
        journal_entry_screen.dart

    learning/
      data/
        learning_repository.dart
      domain/
        learning_item_model.dart
      presentation/
        learning_screen.dart

    content/
      data/
        content_repository.dart
      domain/
        content_item_model.dart
      presentation/
        content_screen.dart

    business/
      data/
        business_repository.dart
      domain/
        business_opportunity_model.dart
      presentation/
        business_screen.dart

    wellbeing/
      data/
        wellbeing_repository.dart
      domain/
        wellbeing_checkin_model.dart
      presentation/
        wellbeing_screen.dart

    inbox/
      data/
        inbox_repository.dart
      domain/
        inbox_item_model.dart
      presentation/
        inbox_screen.dart
        quick_capture_dialog.dart

    settings/
      data/
        settings_repository.dart
      domain/
        app_settings_model.dart
      presentation/
        settings_screen.dart
________________________________________
11. First Setup Commands
From the folder where you want the project:
flutter create new_earth_command_dashboard
cd new_earth_command_dashboard
Then add packages:
flutter pub add flutter_riverpod go_router drift sqlite3 path_provider path uuid intl
flutter pub add --dev drift_dev build_runner flutter_lints
Then run:
flutter pub get
Check the app runs:
flutter run
________________________________________
12. First Build Sprint
Sprint 1 Goal
Create the clickable app shell.
The first sprint should not build the database yet.
It should create:
App theme
Routing
Bottom navigation
Placeholder screens
More screen links
Basic dashboard layout
Sprint 1 success means:
The app opens, shows the Dashboard, and all main navigation works.
________________________________________
13. First Coding Tasks
TASK-001 — Create Flutter Project
Create the Flutter project:
flutter create new_earth_command_dashboard
________________________________________
TASK-002 — Add Packages
Add:
flutter_riverpod
go_router
drift
sqlite3
path_provider
path
uuid
intl
________________________________________
TASK-003 — Create Folder Structure
Create:
core
features
docs
test folders
________________________________________
TASK-004 — Create App Theme
Create:
lib/core/theme/app_colours.dart
lib/core/theme/app_text_styles.dart
lib/core/theme/app_theme.dart
Theme direction:
Calm
Clean
Natural
Soft green accents
Rounded cards
Readable text
________________________________________
TASK-005 — Create App Router
Create:
lib/core/routing/route_names.dart
lib/core/routing/app_router.dart
Routes:
/dashboard
/projects
/tasks
/planner
/more
/journal
/learning
/content
/business
/wellbeing
/inbox
/settings
________________________________________
TASK-006 — Create Placeholder Screens
Create placeholder screens for:
DashboardScreen
ProjectsScreen
TasksScreen
PlannerScreen
MoreScreen
JournalScreen
LearningScreen
ContentScreen
BusinessScreen
WellbeingScreen
InboxScreen
SettingsScreen
________________________________________
TASK-007 — Create Bottom Navigation
Bottom tabs:
Dashboard
Projects
Tasks
Planner
More
The app should always allow quick return to the Dashboard.
________________________________________
TASK-008 — Build More Screen
More screen links:
Journal
Learning
Content
Business
Wellbeing
Inbox
Settings
Each item should show:
Icon
Title
Short description
________________________________________
TASK-009 — Build Dashboard Placeholder
The first Dashboard should show placeholder cards:
Today’s Focus
Top 3 Tasks
Active Projects
Learning Focus
Content Focus
Business Reminder
Wellbeing
Quick Capture
Evening Review
No database required yet.
________________________________________
TASK-010 — Confirm App Shell Works
Test:
App launches
Dashboard opens first
Bottom navigation works
More screen links work
No route crashes
________________________________________
14. Codex-Ready First Task
Use this as the first task for Codex or your AI coding assistant:
# TASK — Build New Earth Command Dashboard App Shell

## Goal

Create the initial Flutter app shell for the New Earth Command Dashboard.

## Context

This is a local-first Flutter app for managing New Earth projects, tasks, daily focus, learning, content, business actions, wellbeing, and build progress.

The first task is only to create the clickable app shell. Do not build the database yet.

## Requirements

1. Use Flutter and Material 3.
2. Add a clean New Earth style theme.
3. Create bottom navigation with:
   - Dashboard
   - Projects
   - Tasks
   - Planner
   - More

4. Create placeholder screens:
   - DashboardScreen
   - ProjectsScreen
   - TasksScreen
   - PlannerScreen
   - MoreScreen
   - JournalScreen
   - LearningScreen
   - ContentScreen
   - BusinessScreen
   - WellbeingScreen
   - InboxScreen
   - SettingsScreen

5. The More screen must link to:
   - Journal
   - Learning
   - Content
   - Business
   - Wellbeing
   - Inbox
   - Settings

6. Dashboard screen should show placeholder cards for:
   - Today’s Focus
   - Top 3 Tasks
   - Active Projects
   - Learning Focus
   - Content Focus
   - Business Reminder
   - Wellbeing
   - Quick Capture
   - Evening Review

7. Use a feature-based folder structure:
   - core/
   - features/dashboard/
   - features/projects/
   - features/tasks/
   - features/planner/
   - features/journal/
   - features/learning/
   - features/content/
   - features/business/
   - features/wellbeing/
   - features/inbox/
   - features/settings/

8. Use go_router for routing.
9. Use clear file names and clean structure.
10. Do not add database logic in this task.

## Expected Result

The app should launch to the Dashboard.  
Bottom navigation should work.  
The More screen should navigate to all supporting screens.  
All screens can be placeholders but should have clear titles and descriptions.
________________________________________
15. Codex-Ready Second Task
After the app shell works:
# TASK — Add Local Database Foundation with Drift

## Goal

Add the local SQLite database foundation using Drift.

## Requirements

1. Add Drift database setup.
2. Create app_database.dart.
3. Create initial tables:
   - projects
   - tasks
   - daily_plans
   - journal_entries
   - learning_items
   - content_items
   - business_opportunities
   - wellbeing_checkins
   - inbox_items
   - app_settings

4. Create database provider.
5. Ensure the database opens on app launch.
6. Do not fully build repositories yet.
7. Do not connect all screens to data yet.

## Expected Result

The app still launches normally.  
The Drift database is configured.  
Tables are defined.  
The app can generate database code using build_runner.
Build runner command:
dart run build_runner build --delete-conflicting-outputs
________________________________________
16. Codex-Ready Third Task
# TASK — Add Seed Data for Default New Earth Projects

## Goal

Create default New Earth projects on first launch.

## Default Projects

- MicroGrow
- MicroGrow Field Scanner
- New Earth Website
- New Earth Living App
- Smart Growing Systems Book
- LinkedIn / Public Awareness
- Business & Funding
- Learning & Skills
- Future Ideas

## Requirements

1. Create SeedDataService.
2. On first launch, check if projects already exist.
3. If no projects exist, insert the default projects.
4. Prevent duplicates.
5. Show seeded projects on the Projects screen.
6. Projects should persist after app restart.

## Expected Result

The Projects screen displays the default New Earth project list.  
Closing and reopening the app does not duplicate the projects.
________________________________________
17. Initial README Content
Create this as README.md:
# New Earth Command Dashboard

New Earth Command Dashboard is a local-first Flutter app for managing the daily build of New Earth.

It helps organise projects, tasks, daily focus, learning, content, business actions, wellbeing, and build progress from one calm command centre.

## Purpose

The app exists to answer one question every day:

> What should I focus on today to move New Earth forward?

## Core MVP Features

- Daily Dashboard
- Today’s main focus
- Top 3 priority tasks
- Project tracking
- Task management
- Daily Planner
- Evening Review
- Build Journal
- Learning tracker
- Content planner
- Business opportunity tracker
- Wellbeing check-in
- Quick Capture and Inbox
- Local-first storage

## Tech Stack

- Flutter
- Dart
- Material 3
- Riverpod
- go_router
- Drift
- SQLite

## MVP Principle

Clarity first. Complexity later.

The first version should make the working day easier, not heavier.

## First Build Goal

Create a working local-first dashboard where Peter can:

1. Open the app.
2. See today’s focus.
3. Choose top 3 tasks.
4. Track active projects.
5. Record progress.
6. Review the day.
7. Reopen the app without losing data.

## Status

Version: V0.1 planning/build stage.
________________________________________
18. Initial Architecture Decision File
Create:
docs/architecture/architecture_decisions.md
Content:
# Architecture Decisions

## ADR-001 — Flutter

Decision: Use Flutter for the New Earth Command Dashboard.

Reason:
Flutter allows the app to target Android first, then expand to desktop, iOS, and web later.

## ADR-002 — Local-First MVP

Decision: Store data locally for V0.1.

Reason:
The first version should work offline, require no login, and keep private project data on the device.

## ADR-003 — Drift and SQLite

Decision: Use Drift with SQLite.

Reason:
The app has structured data and relationships between projects, tasks, daily plans, journal entries, learning items, content items, business items, and wellbeing check-ins.

## ADR-004 — Riverpod

Decision: Use Riverpod for state management.

Reason:
Riverpod supports clean feature-based architecture and works well with repositories and providers.

## ADR-005 — Manual First, AI Later

Decision: Do not depend on AI for V0.1.

Reason:
The app must be useful as a manual dashboard first. AI can be added later to suggest plans, summarise progress, and draft content.
________________________________________
19. Initial MVP Roadmap File
Create:
docs/roadmap/mvp_roadmap.md
Content:
# MVP Roadmap

## V0.1 Core Command Dashboard

### Sprint 1 — App Shell

- Flutter project
- Theme
- Routing
- Bottom navigation
- Placeholder screens
- Dashboard placeholder cards

### Sprint 2 — Database

- Drift setup
- SQLite database
- Core tables
- Database provider

### Sprint 3 — Projects

- Project model
- Project repository
- Seed default projects
- Projects screen
- Project detail screen
- Add/edit project

### Sprint 4 — Tasks

- Task model
- Task repository
- Tasks screen
- Add/edit task
- Link task to project
- Mark task done
- Filter tasks

### Sprint 5 — Dashboard and Daily Plan

- DailyPlan model
- Auto-create today’s plan
- Today’s focus
- Top 3 tasks
- Active projects card
- Evening review button

### Sprint 6 — Planner and Journal

- Daily Planner screen
- Morning intention
- Evening review
- Journal entries
- Link journal to project/task

### Sprint 7 — Supporting Modules

- Learning
- Content
- Business
- Wellbeing
- Inbox
- Quick Capture

### Sprint 8 — Testing and Polish

- Manual test plan
- Empty states
- Error messages
- Data persistence checks
- V0.1 release notes
________________________________________
20. First Database Build Order
Do not build every module in full at once.
Build tables in this order:
1. projects
2. tasks
3. daily_plans
4. journal_entries
5. learning_items
6. content_items
7. business_opportunities
8. wellbeing_checkins
9. inbox_items
10. app_settings
Reason:
Projects give structure.
Tasks create action.
DailyPlans power the Dashboard.
Journal captures progress.
The other modules extend the system.
________________________________________
21. First UI Build Order
Build UI in this order:
1. App shell
2. Dashboard placeholder
3. Projects placeholder
4. Tasks placeholder
5. Planner placeholder
6. More screen
7. Project cards
8. Task cards
9. Real Dashboard cards
10. Journal entry form
________________________________________
22. First Working Version Target
The first meaningful build target is:
New Earth Command Dashboard V0.1-alpha
It should include:
Clickable navigation
Dashboard placeholder
Seeded projects
Basic project list
Basic task list
Local database
Today’s DailyPlan created automatically
This is not the full MVP yet, but it proves the app foundation works.
________________________________________
23. V0.1-alpha Acceptance Criteria
V0.1-alpha is ready when:
[ ] App launches.
[ ] Dashboard opens first.
[ ] Bottom navigation works.
[ ] More screen links work.
[ ] Database opens.
[ ] Default projects are seeded.
[ ] Projects screen displays seeded projects.
[ ] App can restart without duplicating projects.
[ ] No login required.
[ ] App works offline.
________________________________________
24. Full V0.1 Acceptance Criteria
Full V0.1 is ready when:
[ ] User can set today’s focus.
[ ] User can create projects.
[ ] User can edit projects.
[ ] User can create tasks.
[ ] User can link tasks to projects.
[ ] User can select top 3 tasks.
[ ] App prevents a fourth top task.
[ ] User can complete tasks.
[ ] User can use Daily Planner.
[ ] User can complete Evening Review.
[ ] User can create journal entries.
[ ] User can create learning items.
[ ] User can create content ideas.
[ ] User can create business opportunities.
[ ] User can complete wellbeing check-in.
[ ] User can quick capture inbox items.
[ ] Data persists after restart.
________________________________________
25. First Real Development Day Plan
For the first actual coding session, do only this:
1. Create Flutter project.
2. Add packages.
3. Create folder structure.
4. Create app theme.
5. Create route names.
6. Create app router.
7. Create bottom navigation.
8. Create placeholder screens.
9. Build More screen links.
10. Run app.
Do not touch database on day one unless the app shell is already working.
Goal:
Get a clean clickable shell working first.
________________________________________
26. First Git Commit Plan
Suggested commits:
commit 1: Create Flutter project
commit 2: Add core packages
commit 3: Add feature folder structure
commit 4: Add app theme
commit 5: Add routing and bottom navigation
commit 6: Add placeholder screens
commit 7: Add dashboard placeholder cards
This keeps the repo history clean.
________________________________________
27. Suggested Branches
Start with:
main
develop
feature/app-shell
Flow:
main = stable
develop = current integration branch
feature/app-shell = first build branch
When app shell works:
merge feature/app-shell into develop
Then create:
feature/database-foundation
feature/projects-module
feature/tasks-module
feature/dashboard-daily-plan
________________________________________
28. First App Theme Direction
Use a calm New Earth style.
Suggested theme values:
Background: warm off-white
Primary accent: soft green
Secondary accent: muted earth brown
Text: deep charcoal
Cards: white or very light cream
Corners: rounded
Buttons: clear and calm
Design feel:
Mission control
Natural
Grounded
Clean
Focused
Not corporate
Not cluttered
________________________________________
29. First Dashboard Placeholder Text
Use this for the first Dashboard:
New Earth Command Dashboard

What moves the mission forward today?

Today’s Focus
Set one main focus for the day.

Top 3 Tasks
Choose three useful actions, not a huge list.

Active Projects
See the New Earth projects currently moving.

Learning Focus
Track the skill that supports today’s build.

Content Focus
Turn progress into public awareness.

Business Reminder
Keep funding and opportunity actions visible.

Wellbeing
Build New Earth without burning out.

Quick Capture
Capture a task, idea, note, or content seed.

Evening Review
Record what moved forward before the day ends.
________________________________________
30. First More Screen Text
Use this for More:
Journal
Capture build progress, lessons, decisions, and reflections.

Learning
Track skills that help build New Earth.

Content
Plan LinkedIn posts, website updates, videos, and book ideas.

Business
Track funding, job applications, partnerships, and opportunities.

Wellbeing
Check energy, mood, stress, and balance.

Inbox
Process quick captured ideas and notes.

Settings
Configure the dashboard.
________________________________________
31. Development Rules
Follow these rules while building:
1. Do not overbuild.
2. Keep screens simple.
3. Get navigation working first.
4. Add database after app shell works.
5. Build Projects before Tasks.
6. Build Tasks before full Dashboard.
7. Make Dashboard useful before adding AI.
8. Archive instead of delete.
9. Link records back to projects.
10. Keep the Top 3 rule protected.
________________________________________
32. What Not to Build Yet
Do not build these in the first coding sprint:
AI assistant
Cloud sync
Login
Calendar integration
GitHub integration
WordPress integration
MicroGrow live data
Push notifications
Advanced analytics
PDF export
Team collaboration
These are future features.
The first job is to make a calm, useful, local command dashboard.
________________________________________
33. Final MVP Statement
The V0.1 MVP is complete when Peter can use the app to:
Open the dashboard
Set today’s focus
Choose three tasks
See active projects
Track project and task progress
Record a build journal entry
Review the day
Capture new ideas
Reopen the app without losing anything
That is the first working New Earth command system.
________________________________________
34. Part 11 Summary
The build should now move from FSD to code.
Start with:
Flutter app shell
Theme
Routing
Bottom navigation
Placeholder screens
More screen
Dashboard cards
Then add:
Drift database
Seed projects
Projects module
Tasks module
DailyPlan
Dashboard real data
Planner
Journal
Supporting modules
Quick Capture
Testing
The key instruction for the first build is:
Do not try to build everything at once. Build the command centre foundation first.
