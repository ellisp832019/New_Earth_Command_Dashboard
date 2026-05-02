# Technical Architecture

FSD Part 8 — Technical Architecture, Flutter Structure & Storage Plan
Project Name
New Earth Command Dashboard
Document Version
V0.1 — Technical Architecture Draft
________________________________________
1. Purpose of This Section
This section defines how the app should be built technically.
It covers:
1. Recommended technology stack
2. Flutter app architecture
3. Folder structure
4. Local database approach
5. Data flow
6. State management
7. Models
8. Repositories
9. Services
10. Future expansion path
The aim is to create a clean foundation that can grow without becoming messy.
________________________________________
2. Technical Direction
The New Earth Command Dashboard should start as a:
Flutter app
Offline-first
Single-user
Local database
Mobile-first
Expandable to desktop later
The first build should avoid unnecessary complexity.
The app should work well even without internet access.
Cloud sync, AI, calendar, GitHub, WordPress, and MicroGrow integration can be added later.
________________________________________
3. Recommended Technology Stack
3.1 Frontend
Flutter
Dart
Material 3 UI
Reason:
Flutter supports Android, iOS, Windows, Linux, macOS, and web.
The user is already working with Flutter.
One codebase can eventually support phone, tablet, and desktop.
________________________________________
3.2 Local Database
Recommended:
SQLite with Drift
Reason:
Good for structured data
Good for relationships
Works offline
Reliable for local storage
Scales better than simple key-value storage
Supports future sync/export
Alternative for quick prototype:
Hive
Hive is easier to start with, but Drift is better for the proper MVP.
________________________________________
3.3 State Management
Recommended:
Riverpod
Reason:
Clean structure
Good for medium-to-large Flutter apps
Works well with repositories and services
Easier to test than simple global state
Good for future app growth
Alternative:
Provider
Provider is simpler, but Riverpod is more scalable.
________________________________________
3.4 Routing
Recommended:
go_router
Reason:
Clean route management
Works well with nested navigation
Good for mobile and desktop layouts
Supports named routes
________________________________________
3.5 App Platforms
MVP target:
Android first
Next targets:
Windows desktop
Linux desktop
iOS later
Web later
Best direction:
Build Android first, but structure the app so desktop can be added later.
________________________________________
4. Architecture Style
The app should use a simple layered architecture.
UI Layer
↓
State / Controller Layer
↓
Repository Layer
↓
Database Layer
This keeps the app clean.
________________________________________
5. Layer Responsibilities
5.1 UI Layer
The UI layer contains:
Screens
Cards
Buttons
Forms
Lists
Dialogs
Navigation
Examples:
DashboardScreen
ProjectsScreen
TaskCard
ProjectCard
QuickCaptureDialog
The UI should not directly handle database queries.
________________________________________
5.2 State / Controller Layer
This layer manages screen state and user actions.
Examples:
DashboardController
TaskController
ProjectController
DailyPlannerController
Responsibilities:
Load data from repositories
Handle button actions
Update screen state
Validate simple input
Trigger saves/updates
________________________________________
5.3 Repository Layer
The repository layer acts as the bridge between the app and the database.
Examples:
ProjectRepository
TaskRepository
DailyPlanRepository
JournalRepository
Responsibilities:
Create records
Read records
Update records
Archive records
Run database queries
Return clean data to controllers
________________________________________
5.4 Database Layer
The database layer stores the actual data.
It contains:
Drift database setup
Tables
DAOs
Database migrations
Local persistence logic
________________________________________
6. Recommended Flutter Folder Structure
Use a feature-based structure.
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
________________________________________
7. Expanded Folder Structure
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
8. Main App Entry Points
8.1 main.dart
Purpose:
Start Flutter
Initialise database
Load app providers
Run the app
________________________________________
8.2 app.dart
Purpose:
Set app theme
Set routing
Set app shell
Configure MaterialApp
________________________________________
8.3 app_router.dart
Purpose:
Define routes
Handle navigation
Support bottom navigation
Support future desktop side navigation
________________________________________
9. App Navigation Architecture
For mobile MVP, use bottom navigation.
Main tabs:
Dashboard
Projects
Tasks
Planner
More
Routes:
/dashboard
/projects
/projects/:id
/tasks
/tasks/add
/tasks/:id
/planner
/more
/journal
/learning
/content
/business
/wellbeing
/settings
________________________________________
10. Responsive Layout Plan
The app should be mobile-first, but future-ready.
10.1 Mobile Layout
Use:
Bottom navigation
Single-column screens
Scrollable cards
Floating quick capture button
________________________________________
10.2 Tablet Layout
Future improvement:
Navigation rail
Two-column dashboard
Larger project cards
Split list/detail views
________________________________________
10.3 Desktop Layout
Future improvement:
Side navigation menu
Dashboard grid layout
Resizable panels
Keyboard shortcuts
Wider forms
________________________________________
11. Local Database Plan
11.1 Database Name
new_earth_command_dashboard.db
________________________________________
11.2 MVP Tables
projects
tasks
daily_plans
journal_entries
learning_items
content_items
business_opportunities
wellbeing_checkins
inbox_items
app_settings
________________________________________
12. Database Table Summary
12.1 projects
Stores New Earth projects.
project_id
name
short_description
long_description
vision
status
priority
progress_percentage
current_milestone
next_action
start_date
target_date
created_at
updated_at
notes
is_archived
________________________________________
12.2 tasks
Stores practical tasks.
task_id
project_id
title
description
category
priority
status
due_date
energy_level
estimated_minutes
actual_minutes
created_at
updated_at
completed_at
notes
is_top_three
is_archived
________________________________________
12.3 daily_plans
Stores one plan per day.
daily_plan_id
date
main_focus
focus_reason
morning_intention
top_task_1_id
top_task_2_id
top_task_3_id
learning_focus_id
content_focus_id
business_focus_id
wellbeing_checkin_id
evening_review
what_moved_forward
what_was_completed
what_was_learned
blockers
carry_forward_notes
tomorrow_focus
created_at
updated_at
________________________________________
12.4 journal_entries
Stores build logs and reflections.
journal_entry_id
project_id
task_id
date
title
category
what_i_worked_on
what_i_built
what_i_learned
problems_encountered
decisions_made
next_actions
possible_linkedin_post
possible_website_entry
tags
created_at
updated_at
is_archived
________________________________________
12.5 learning_items
Stores learning topics.
learning_item_id
project_id
topic
reason_for_learning
resource_link
status
notes
practice_task_id
next_step
skill_confidence
date_started
date_applied
created_at
updated_at
is_archived
________________________________________
12.6 content_items
Stores content ideas and drafts.
content_item_id
project_id
journal_entry_id
title
platform
content_type
status
draft_text
image_needed
image_prompt
publish_date
published_link
notes
created_at
updated_at
is_archived
________________________________________
12.7 business_opportunities
Stores funding, income, and partnership actions.
business_opportunity_id
project_id
name
type
company_or_contact
status
deadline
next_action
follow_up_date
related_document_link
notes
created_at
updated_at
is_archived
________________________________________
12.8 wellbeing_checkins
Stores wellbeing check-ins.
wellbeing_checkin_id
date
energy_level
mood
sleep_quality
stress_level
movement_done
food_water_ok
meditation_reflection_done
notes
suggested_workload
created_at
updated_at
________________________________________
12.9 inbox_items
Stores quick captures.
inbox_item_id
title
body
type
project_id
status
created_at
processed_at
converted_to_type
converted_to_id
is_archived
________________________________________
12.10 app_settings
Stores user settings.
settings_id
theme_mode
default_dashboard_view
show_wellbeing_card
show_business_card
show_learning_card
show_content_card
daily_top_task_limit
created_at
updated_at
________________________________________
13. Data Flow
13.1 Example — Creating a Task
User taps + Add Task
↓
AddEditTaskScreen opens
↓
User enters task details
↓
TaskController validates input
↓
TaskRepository saves task
↓
Database inserts record
↓
Task list refreshes
↓
Dashboard updates if needed
________________________________________
13.2 Example — Marking Task Done
User taps task checkbox
↓
TaskController receives action
↓
TaskRepository updates task
↓
status = Done
completed_at = current time
updated_at = current time
↓
Database saves update
↓
Dashboard and task list refresh
________________________________________
13.3 Example — Opening Dashboard
App opens
↓
DashboardController checks today’s date
↓
DailyPlanRepository looks for today’s DailyPlan
↓
If none exists, create blank DailyPlan
↓
Load top 3 tasks
↓
Load active projects
↓
Load wellbeing check-in
↓
Render Dashboard
________________________________________
14. State Management Plan
Use Riverpod providers for each major feature.
Examples:
dashboardProvider
projectsProvider
tasksProvider
dailyPlanProvider
journalProvider
learningProvider
contentProvider
businessProvider
wellbeingProvider
inboxProvider
settingsProvider
________________________________________
15. Provider Responsibilities
15.1 dashboardProvider
Responsible for:
Loading today’s DailyPlan
Loading top 3 tasks
Loading active projects
Loading today’s wellbeing check-in
Updating dashboard data
________________________________________
15.2 tasksProvider
Responsible for:
Loading task list
Filtering tasks
Creating tasks
Updating tasks
Marking tasks done
Parking tasks
Moving tasks to Today
________________________________________
15.3 projectsProvider
Responsible for:
Loading projects
Creating projects
Editing projects
Archiving projects
Updating progress
Loading project detail data
________________________________________
15.4 plannerProvider
Responsible for:
Creating daily plan
Editing morning intention
Setting main focus
Saving evening review
Carrying tasks forward
________________________________________
16. Repository Plan
Create one repository per major entity.
ProjectRepository
TaskRepository
DailyPlanRepository
JournalRepository
LearningRepository
ContentRepository
BusinessRepository
WellbeingRepository
InboxRepository
SettingsRepository
Each repository should provide:
create
getById
getAll
update
archive
delete only if absolutely needed
________________________________________
17. Model Plan
Each data entity should have a model.
ProjectModel
TaskModel
DailyPlanModel
JournalEntryModel
LearningItemModel
ContentItemModel
BusinessOpportunityModel
WellbeingCheckInModel
InboxItemModel
AppSettingsModel
Each model should support:
fromDatabase
toDatabase
copyWith
This makes editing and updating records easier.
________________________________________
18. Services
Services should handle shared logic that does not belong to one screen.
Recommended services:
DailyPlanService
SeedDataService
QuickCaptureService
TaskSelectionService
ArchiveService
ExportService future
NotificationService future
AIPlanningService future
________________________________________
19. Key Services Explained
19.1 DailyPlanService
Purpose:
Ensure one DailyPlan exists per date
Load today’s plan
Carry tasks forward
Update top 3 tasks
________________________________________
19.2 SeedDataService
Purpose:
Create default New Earth projects on first launch
Create default app settings
Create default categories/statuses if needed
________________________________________
19.3 QuickCaptureService
Purpose:
Save quick capture items
Route captures into Inbox
Convert Inbox items into tasks, content, journal entries, learning items, or business items
________________________________________
19.4 TaskSelectionService
Purpose:
Enforce Top 3 task limit
Add task to today’s priorities
Remove task from today’s priorities
Prevent fourth top task
________________________________________
19.5 ArchiveService
Purpose:
Archive records instead of deleting them
Restore archived items later
________________________________________
20. Seed Data Plan
On first launch, the app should create default projects.
20.1 Default Projects
MicroGrow
MicroGrow Field Scanner
New Earth Website
New Earth Living App
Smart Growing Systems Book
LinkedIn / Public Awareness
Business & Funding
Learning & Skills
Future Ideas
________________________________________
20.2 Default Settings
theme_mode = System
show_wellbeing_card = true
show_business_card = true
show_learning_card = true
show_content_card = true
daily_top_task_limit = 3
________________________________________
20.3 Default Project Statuses
Idea
Active
Paused
Blocked
Completed
Archived
________________________________________
20.4 Default Task Statuses
Inbox
Planned
Today
In Progress
Blocked
Done
Parked
________________________________________
21. App Startup Sequence
When the app starts:
1. Initialise Flutter binding.
2. Open local database.
3. Check if app has launched before.
4. If first launch, run SeedDataService.
5. Check or create today’s DailyPlan.
6. Load app settings.
7. Open Dashboard.
________________________________________
22. MVP Build Order
Build the technical system in this order:
1. Create Flutter project
2. Add app theme
3. Add routing
4. Add bottom navigation
5. Create placeholder screens
6. Add Drift database
7. Create Project table/model/repository
8. Seed default projects
9. Create Tasks table/model/repository
10. Create DailyPlan table/model/repository
11. Build Dashboard with real data
12. Build Projects screen
13. Build Tasks screen
14. Build Planner screen
15. Add Journal
16. Add Learning
17. Add Content
18. Add Business
19. Add Wellbeing
20. Add Quick Capture
________________________________________
23. Suggested Flutter Packages
For MVP:
flutter_riverpod
go_router
drift
sqlite3_flutter_libs
path_provider
path
uuid
intl
Useful later:
flutter_local_notifications
file_picker
share_plus
pdf
csv
supabase_flutter
firebase_core
________________________________________
24. Package Purpose
Package	Purpose
flutter_riverpod	State management
go_router	Navigation and routes
drift	Local SQLite database
sqlite3_flutter_libs	SQLite support
path_provider	Find local storage path
path	Build database file path
uuid	Generate unique IDs
intl	Date formatting
________________________________________
25. MVP Technical Decisions
25.1 Local-First
Decision:
The MVP stores all data locally.
Reason:
No login required.
Works offline.
Faster to build.
Protects privacy.
Good for personal command dashboard.
________________________________________
25.2 Flutter
Decision:
Use Flutter for the app.
Reason:
Cross-platform.
Matches existing New Earth app direction.
Good for Android first.
Can later support desktop.
________________________________________
25.3 Drift
Decision:
Use Drift with SQLite for structured local storage.
Reason:
The app has many related entities.
SQLite handles relationships better than simple local storage.
It is suitable for future export and sync.
________________________________________
25.4 Riverpod
Decision:
Use Riverpod for state management.
Reason:
Clean structure.
Good with repositories.
Scales well.
Makes feature modules easier to manage.
________________________________________
25.5 Manual Planning First
Decision:
Do not depend on AI for the MVP.
Reason:
The app must be useful manually first.
AI can be added later as an assistant layer.
________________________________________
26. Future Technical Expansion
26.1 Cloud Sync
Possible future options:
Supabase
Firebase
Custom local server
Self-hosted database
Best future direction for New Earth:
Local-first with optional sync
This keeps the user in control.
________________________________________
26.2 AI Assistant
Future AI could connect to:
Projects
Tasks
DailyPlans
JournalEntries
LearningItems
ContentItems
BusinessOpportunities
WellbeingCheckIns
AI features:
Suggest top 3 tasks
Summarise project progress
Turn journal entries into LinkedIn posts
Create weekly reviews
Detect overwhelm
Suggest learning next steps
________________________________________
26.3 Calendar Integration
Future calendar features:
Show meetings
Create focus blocks
Schedule learning
Schedule evening review
Set business follow-up reminders
________________________________________
26.4 GitHub Integration
Useful for MicroGrow and app development.
Future features:
Show open issues
Show active branches
Show latest commits
Link tasks to issues
Track release progress
________________________________________
26.5 WordPress / Website Integration
Future features:
Draft website journal posts
Track page updates
Manage website content tasks
Link content items to website pages
________________________________________
26.6 MicroGrow Integration
Future features:
Show MicroGrow node status
Show sensor data summaries
Show firmware version
Show device alerts
Connect field scanner diagnostics
This would eventually turn the app from a planning dashboard into a real New Earth operations dashboard.
________________________________________
27. Testing Plan Direction
Technical testing should include:
Unit tests for repositories
Unit tests for services
Widget tests for screens
Database tests for table operations
Navigation tests for routes
Manual testing for user flows
Important MVP test areas:
First launch seed data
Create project
Create task
Select top 3 tasks
Prevent fourth top task
Create DailyPlan
Save evening review
Create journal entry
Persist data after restart
________________________________________
28. Backup and Export Direction
Backup/export is not required for the first MVP, but the architecture should allow it.
Future export types:
Full JSON backup
Tasks CSV
Journal Markdown
Project summary PDF
Weekly review PDF
Best future backup direction:
Export all local data as JSON
Allow re-import later
________________________________________
29. Error Handling Direction
The app should handle errors calmly.
Examples:
Task could not be saved. Please try again.
Project could not be loaded.
Daily plan could not be created.
Database could not be opened.
Avoid technical messages in the UI.
Technical errors can be logged internally.
________________________________________
30. Security Direction
For MVP:
Local-only data
No login
No server
No public sharing
Future security:
Optional app lock
Encrypted local database
Encrypted backups
Secure cloud sync
User authentication
________________________________________
31. Architecture Summary Diagram
Flutter UI
  ↓
Screens and Widgets
  ↓
Riverpod Controllers / Providers
  ↓
Repositories
  ↓
Drift DAOs
  ↓
SQLite Local Database
________________________________________
32. Feature Module Example
Example: Tasks module.
features/tasks/
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
Task flow:
TaskCard checkbox tapped
↓
tasksProvider calls markTaskDone()
↓
TaskRepository updates database
↓
TasksScreen refreshes
↓
Dashboard updates if task is top 3
________________________________________
33. MVP Technical Summary
The first technical build should be:
Flutter app
Android first
Offline-first
Local SQLite database
Drift for storage
Riverpod for state
go_router for navigation
Feature-based folder structure
Seeded New Earth projects
Dashboard-driven user flow
________________________________________
34. Part 8 Summary
The New Earth Command Dashboard should be built as a clean, local-first Flutter app.
The technical foundation should support:
Daily clarity
Project tracking
Task management
Build journaling
Learning tracking
Content planning
Business actions
Wellbeing check-ins
Future AI
Future sync
Future MicroGrow integration
The architecture should stay simple enough to build now, but strong enough to grow later.
The key technical principle is:
Build a stable local command centre first. Add intelligence and integrations later.
