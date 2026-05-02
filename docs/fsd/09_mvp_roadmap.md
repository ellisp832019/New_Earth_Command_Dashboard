# MVP Roadmap

FSD Part 9 — MVP Development Roadmap, Milestones & Build Tasks
Project Name
New Earth Command Dashboard
Document Version
V0.1 — MVP Roadmap Draft
________________________________________
1. Purpose of This Section
This section turns the FSD into a practical development roadmap.
It defines:
1. Build phases
2. Milestones
3. Development order
4. Screen build order
5. Database build order
6. Testing checkpoints
7. MVP completion criteria
The aim is to move from idea and specification into a real working Flutter app.
________________________________________
2. MVP Development Principle
The MVP should follow this rule:
Build the smallest useful command centre first.
The first version does not need every feature polished.
It needs to prove the core loop works:
Open app
↓
See today’s focus
↓
Choose top 3 tasks
↓
Track projects
↓
Record progress
↓
Review the day
________________________________________
3. MVP Build Strategy
The build should happen in layers.
Do not build every screen fully at once.
Recommended approach:
1. Create app shell
2. Add navigation
3. Add placeholder screens
4. Add local database
5. Seed default New Earth projects
6. Build projects system
7. Build task system
8. Build daily dashboard
9. Build daily planner
10. Add journal
11. Add learning/content/business/wellbeing
12. Test the full daily workflow
This prevents the app from becoming too complex too early.
________________________________________
4. Main MVP Milestones
Milestone 1 — App Foundation
Goal:
Create the basic Flutter app structure.
Includes:
Flutter project created
App name set
Theme added
Folder structure created
Routing added
Bottom navigation added
Placeholder screens created
Success result:
The app opens and the user can move between main screens.
________________________________________
Milestone 2 — Local Database Foundation
Goal:
Create the local storage system.
Includes:
Drift installed
SQLite database configured
Core tables created
Database opens on app launch
Seed data service created
Default projects inserted on first launch
Success result:
The app has persistent local data and remembers default projects after restart.
________________________________________
Milestone 3 — Projects Module
Goal:
Create the project tracking system.
Includes:
Project model
Project table
Project repository
Projects screen
Project cards
Project detail screen
Add/edit project form
Manual progress update
Project status and priority labels
Success result:
The user can view, create, edit, and track New Earth projects.
________________________________________
Milestone 4 — Tasks Module
Goal:
Create the practical task system.
Includes:
Task model
Task table
Task repository
Tasks screen
Task cards
Add/edit task form
Task status update
Mark task done
Move task to Today
Park task
Filter tasks by status
Filter tasks by project
Success result:
The user can create tasks, link them to projects, and manage their status.
________________________________________
Milestone 5 — Daily Plan and Dashboard
Goal:
Create the daily command centre.
Includes:
DailyPlan model
DailyPlan table
DailyPlan repository
Auto-create today’s DailyPlan
Dashboard screen with real data
Today’s focus card
Top 3 tasks card
Active projects card
Wellbeing summary placeholder
Quick capture placeholder
Evening review button
Success result:
The app opens to a useful daily dashboard showing today’s focus and priority tasks.
________________________________________
Milestone 6 — Top 3 Priority System
Goal:
Protect daily focus.
Includes:
Select top 3 tasks
Show selected tasks on Dashboard
Prevent more than 3 top tasks
Remove task from top 3
Complete top task from Dashboard
Carry task forward later
Success result:
The user can choose only three priority tasks and work from them.
________________________________________
Milestone 7 — Daily Planner
Goal:
Create the morning planning and evening review loop.
Includes:
Daily Planner screen
Morning intention
Main focus
Top 3 tasks display
Learning focus placeholder
Content focus placeholder
Business focus placeholder
Wellbeing action placeholder
Evening review fields
Tomorrow’s focus field
Save review
Success result:
The user can plan the day in the morning and review progress at the end of the day.
________________________________________
Milestone 8 — Journal Module
Goal:
Capture the New Earth build journey.
Includes:
JournalEntry model
Journal table
Journal repository
Journal screen
Journal entry form
Link entry to project
Link entry to task
Journal categories
Search/filter later
Success result:
The user can record what was built, learned, fixed, or decided.
________________________________________
Milestone 9 — Supporting Modules
Goal:
Add learning, content, business, and wellbeing tracking.
Includes:
Learning module
Content module
Business module
Wellbeing module
Basic list screens
Basic add/edit forms
Link items to projects
Show summaries on Dashboard where useful
Success result:
The app supports the wider New Earth working day beyond tasks alone.
________________________________________
Milestone 10 — Quick Capture and Inbox
Goal:
Capture ideas quickly without breaking focus.
Includes:
InboxItem model
Inbox table
Quick Capture dialog
Capture task/idea/note/content/learning/business item
Inbox screen
Process inbox item later
Success result:
The user can capture ideas quickly and organise them later.
________________________________________
Milestone 11 — Polish, Testing and MVP Release
Goal:
Make the app stable enough for daily use.
Includes:
Test all core flows
Fix bugs
Improve empty states
Improve visual spacing
Check local data persistence
Check navigation
Check add/edit forms
Check dashboard refresh
Add basic app icon later
Prepare V0.1 release notes
Success result:
The app is usable as Peter’s daily New Earth command dashboard.
________________________________________
5. Recommended Build Order
The best build order is:
1. Flutter project setup
2. Folder structure
3. Theme
4. Routing
5. Bottom navigation
6. Placeholder screens
7. Database setup
8. Seed default projects
9. Projects module
10. Tasks module
11. DailyPlan module
12. Dashboard real data
13. Top 3 system
14. Planner screen
15. Journal module
16. Learning module
17. Content module
18. Business module
19. Wellbeing module
20. Inbox / Quick Capture
21. Testing and polish
________________________________________
6. Phase 1 — Flutter App Foundation
Goal
Create the skeleton app.
Build Tasks
TASK-001 Create Flutter project
TASK-002 Set app name to New Earth Command Dashboard
TASK-003 Create lib folder structure
TASK-004 Add core folders
TASK-005 Add feature folders
TASK-006 Add app.dart
TASK-007 Add app theme
TASK-008 Add route names
TASK-009 Add go_router
TASK-010 Add bottom navigation shell
TASK-011 Create placeholder Dashboard screen
TASK-012 Create placeholder Projects screen
TASK-013 Create placeholder Tasks screen
TASK-014 Create placeholder Planner screen
TASK-015 Create placeholder More screen
TASK-016 Add More screen links
Completion Criteria
App launches
Dashboard opens first
Bottom navigation works
User can move between Dashboard, Projects, Tasks, Planner, and More
More screen links to Journal, Learning, Content, Business, Wellbeing, Settings
________________________________________
7. Phase 2 — Database Foundation
Goal
Create local storage.
Build Tasks
TASK-017 Add Drift package
TASK-018 Add sqlite3_flutter_libs
TASK-019 Add path_provider
TASK-020 Add path package
TASK-021 Create app_database.dart
TASK-022 Create projects table
TASK-023 Create tasks table
TASK-024 Create daily_plans table
TASK-025 Create journal_entries table
TASK-026 Create learning_items table
TASK-027 Create content_items table
TASK-028 Create business_opportunities table
TASK-029 Create wellbeing_checkins table
TASK-030 Create inbox_items table
TASK-031 Create app_settings table
TASK-032 Create database provider
TASK-033 Test database opens
Completion Criteria
Database opens on app launch
Tables exist
App does not crash on restart
Database file persists locally
________________________________________
8. Phase 3 — Seed Data
Goal
Create default New Earth data on first launch.
Build Tasks
TASK-034 Create SeedDataService
TASK-035 Check if first launch
TASK-036 Insert default projects
TASK-037 Insert default settings
TASK-038 Prevent duplicate seed data
TASK-039 Display seeded projects on Projects screen
Default Projects
MicroGrow
MicroGrow Field Scanner
New Earth Website
New Earth Living App
Smart Growing Systems Book
LinkedIn / Public Awareness
Business & Funding
Learning & Skills
Future Ideas
Completion Criteria
Default projects appear on first launch
Default projects do not duplicate after restarting app
Projects persist after app closes
________________________________________
9. Phase 4 — Projects Module Build
Goal
Build the project management foundation.
Build Tasks
TASK-040 Create ProjectModel
TASK-041 Create ProjectRepository
TASK-042 Create projectsProvider
TASK-043 Build ProjectsScreen
TASK-044 Build ProjectCard widget
TASK-045 Show project name, status, priority, progress, next action
TASK-046 Build ProjectDetailScreen
TASK-047 Build AddEditProjectScreen
TASK-048 Add create project function
TASK-049 Add edit project function
TASK-050 Add archive project function
TASK-051 Add manual progress update
TASK-052 Add project status badge
TASK-053 Add project priority badge
Completion Criteria
User can view all projects
User can open a project detail screen
User can create a project
User can edit a project
User can update progress
User can archive a project
________________________________________
10. Phase 5 — Tasks Module Build
Goal
Build the task system.
Build Tasks
TASK-054 Create TaskModel
TASK-055 Create TaskRepository
TASK-056 Create tasksProvider
TASK-057 Build TasksScreen
TASK-058 Build TaskCard widget
TASK-059 Build AddEditTaskScreen
TASK-060 Create task
TASK-061 Edit task
TASK-062 Mark task done
TASK-063 Move task to Today
TASK-064 Park task
TASK-065 Archive task
TASK-066 Filter task by status
TASK-067 Filter task by project
TASK-068 Show project label on task card
Completion Criteria
User can create tasks
User can link tasks to projects
User can mark tasks done
User can move tasks to Today
User can park tasks
User can filter tasks
Tasks persist after restart
________________________________________
11. Phase 6 — DailyPlan and Dashboard Build
Goal
Make the Dashboard useful.
Build Tasks
TASK-069 Create DailyPlanModel
TASK-070 Create DailyPlanRepository
TASK-071 Create DailyPlanService
TASK-072 Auto-create today’s DailyPlan
TASK-073 Build DashboardController
TASK-074 Load today’s DailyPlan
TASK-075 Load active projects
TASK-076 Load top 3 tasks
TASK-077 Build TodayFocusCard
TASK-078 Build TopThreeTasksCard
TASK-079 Build ActiveProjectsCard
TASK-080 Build Dashboard Quick Capture placeholder
TASK-081 Build Evening Review button
TASK-082 Add dashboard refresh after updates
Completion Criteria
Dashboard loads today’s DailyPlan
Dashboard shows today’s focus
Dashboard shows top 3 tasks
Dashboard shows active projects
Dashboard updates when tasks are completed
________________________________________
12. Phase 7 — Top 3 Task System
Goal
Create the focus-protection system.
Build Tasks
TASK-083 Create TaskSelectionService
TASK-084 Add task to today’s top 3
TASK-085 Remove task from today’s top 3
TASK-086 Prevent more than three top tasks
TASK-087 Show gentle warning when fourth task is selected
TASK-088 Show top 3 on Dashboard
TASK-089 Show top 3 on Planner
TASK-090 Complete top task from Dashboard
Completion Criteria
User can select up to 3 tasks
User cannot select a fourth top task
Top tasks display on Dashboard
Top tasks display in Planner
Top task can be completed from Dashboard
________________________________________
13. Phase 8 — Daily Planner Build
Goal
Create the daily rhythm.
Build Tasks
TASK-091 Build PlannerScreen
TASK-092 Show today’s date
TASK-093 Add morning intention field
TASK-094 Add main focus field
TASK-095 Show top 3 tasks
TASK-096 Add learning focus field
TASK-097 Add content focus field
TASK-098 Add business focus field
TASK-099 Add wellbeing action field
TASK-100 Add evening review fields
TASK-101 Add tomorrow focus field
TASK-102 Save DailyPlan updates
TASK-103 Add carry-forward placeholder
Completion Criteria
User can write morning intention
User can set main focus
User can view top 3 tasks
User can complete evening review
User can set tomorrow’s likely focus
Daily plan persists after restart
________________________________________
14. Phase 9 — Journal Build
Goal
Capture the build history.
Build Tasks
TASK-104 Create JournalEntryModel
TASK-105 Create JournalRepository
TASK-106 Create journalProvider
TASK-107 Build JournalScreen
TASK-108 Build JournalEntryCard
TASK-109 Build JournalEntryScreen
TASK-110 Create journal entry
TASK-111 Edit journal entry
TASK-112 Link journal entry to project
TASK-113 Link journal entry to task
TASK-114 Add journal categories
TASK-115 Add possible LinkedIn post checkbox
TASK-116 Add possible website entry checkbox
Completion Criteria
User can create journal entries
User can link journal entries to projects
User can link journal entries to tasks
User can view journal list
User can edit journal entries
________________________________________
15. Phase 10 — Learning Module Build
Goal
Track learning connected to projects.
Build Tasks
TASK-117 Create LearningItemModel
TASK-118 Create LearningRepository
TASK-119 Create learningProvider
TASK-120 Build LearningScreen
TASK-121 Build LearningItemCard
TASK-122 Add learning item
TASK-123 Edit learning item
TASK-124 Link learning item to project
TASK-125 Add status options
TASK-126 Add confidence level
TASK-127 Add resource link
TASK-128 Add next step
Completion Criteria
User can create learning items
User can link learning to projects
User can track status
User can add next learning step
________________________________________
16. Phase 11 — Content Module Build
Goal
Track content ideas and public updates.
Build Tasks
TASK-129 Create ContentItemModel
TASK-130 Create ContentRepository
TASK-131 Create contentProvider
TASK-132 Build ContentScreen
TASK-133 Build ContentItemCard
TASK-134 Add content item
TASK-135 Edit content item
TASK-136 Link content item to project
TASK-137 Link content item to journal entry later
TASK-138 Add platform field
TASK-139 Add content type field
TASK-140 Add status field
TASK-141 Add image needed field
TASK-142 Add draft text field
Completion Criteria
User can create content ideas
User can link content to projects
User can mark content as Drafting, Ready, or Published
User can note if an image is needed
________________________________________
17. Phase 12 — Business Module Build
Goal
Track funding, income, opportunities, and outreach.
Build Tasks
TASK-143 Create BusinessOpportunityModel
TASK-144 Create BusinessRepository
TASK-145 Create businessProvider
TASK-146 Build BusinessScreen
TASK-147 Build BusinessOpportunityCard
TASK-148 Add business opportunity
TASK-149 Edit business opportunity
TASK-150 Link opportunity to project
TASK-151 Add opportunity type
TASK-152 Add status field
TASK-153 Add deadline
TASK-154 Add follow-up date
TASK-155 Add next action
Completion Criteria
User can track job, grant, partnership, funding, and business ideas
User can set next action
User can set follow-up date
User can update opportunity status
________________________________________
18. Phase 13 — Wellbeing Module Build
Goal
Support sustainable building.
Build Tasks
TASK-156 Create WellbeingCheckInModel
TASK-157 Create WellbeingRepository
TASK-158 Create wellbeingProvider
TASK-159 Build WellbeingScreen
TASK-160 Add daily check-in form
TASK-161 Add energy level
TASK-162 Add mood
TASK-163 Add sleep quality
TASK-164 Add stress level
TASK-165 Add movement checkbox
TASK-166 Add food/water checkbox
TASK-167 Add reflection checkbox
TASK-168 Add notes
TASK-169 Add suggested workload logic
TASK-170 Show wellbeing summary on Dashboard
Completion Criteria
User can complete daily wellbeing check-in
Dashboard shows energy, mood, stress, and suggested workload
Low energy produces a lighter workload suggestion
________________________________________
19. Phase 14 — Inbox and Quick Capture Build
Goal
Capture loose ideas fast.
Build Tasks
TASK-171 Create InboxItemModel
TASK-172 Create InboxRepository
TASK-173 Create QuickCaptureService
TASK-174 Build QuickCaptureDialog
TASK-175 Add capture type selector
TASK-176 Save quick capture to Inbox
TASK-177 Build InboxScreen
TASK-178 Show new inbox items
TASK-179 Park inbox item
TASK-180 Convert inbox item to task
TASK-181 Convert inbox item to journal entry
TASK-182 Convert inbox item to content item
TASK-183 Convert inbox item to learning item
TASK-184 Convert inbox item to business opportunity
Completion Criteria
User can quickly capture ideas
Captured items appear in Inbox
User can process Inbox items later
Quick Capture does not interrupt workflow
________________________________________
20. Phase 15 — Settings Build
Goal
Add basic configuration.
Build Tasks
TASK-185 Create AppSettingsModel
TASK-186 Create SettingsRepository
TASK-187 Create settingsProvider
TASK-188 Build SettingsScreen
TASK-189 Add theme mode placeholder
TASK-190 Add dashboard card visibility toggles
TASK-191 Show app version
TASK-192 Add reset data warning placeholder
Completion Criteria
User can open Settings
App settings are stored locally
Dashboard card visibility can be configured later
________________________________________
21. Phase 16 — Testing and Polish
Goal
Make V0.1 reliable enough for daily use.
Build Tasks
TASK-193 Test first app launch
TASK-194 Test seed data
TASK-195 Test project creation
TASK-196 Test task creation
TASK-197 Test top 3 selection
TASK-198 Test fourth top task prevention
TASK-199 Test task completion
TASK-200 Test DailyPlan creation
TASK-201 Test evening review save
TASK-202 Test journal entry creation
TASK-203 Test wellbeing check-in
TASK-204 Test app restart persistence
TASK-205 Test bottom navigation
TASK-206 Test More screen navigation
TASK-207 Fix broken UI layouts
TASK-208 Add empty states
TASK-209 Add basic error messages
TASK-210 Prepare MVP release notes
Completion Criteria
Core user flows work
Data persists after restart
No major navigation bugs
Dashboard is usable
Tasks and projects work
Daily review works
Journal works
________________________________________
22. MVP Release Definition
Version 0.1 can be called complete when the user can:
1. Open the app.
2. See the Dashboard.
3. View default New Earth projects.
4. Create and edit projects.
5. Create and edit tasks.
6. Link tasks to projects.
7. Choose top 3 tasks.
8. Mark tasks done.
9. Set today’s main focus.
10. Complete a daily review.
11. Create journal entries.
12. Track learning items.
13. Track content ideas.
14. Track business opportunities.
15. Complete wellbeing check-in.
16. Capture quick ideas into Inbox.
17. Close and reopen the app without losing data.
________________________________________
23. MVP Build Priority
If time is limited, build in this order of importance:
1. Dashboard
2. Projects
3. Tasks
4. DailyPlan
5. Top 3 system
6. Journal
7. Quick Capture
8. Learning
9. Content
10. Business
11. Wellbeing
12. Settings
The absolute core is:
Dashboard
Projects
Tasks
DailyPlan
Top 3
Journal
Everything else supports the wider system.
________________________________________
24. Suggested Version Releases
V0.1 — Core Command Dashboard
Includes:
Dashboard
Projects
Tasks
Daily Planner
Top 3 priorities
Journal
Local database
Seed projects
________________________________________
V0.2 — Full Personal Operating System
Adds:
Learning
Content
Business
Wellbeing
Quick Capture
Inbox
Better filters
Better empty states
________________________________________
V0.3 — Polish and Daily Use
Adds:
Improved UI
Search
Better dashboard cards
Better project detail pages
Export basic data
App icon
Release notes
________________________________________
V0.4 — AI Assistant Preparation
Adds:
AI-ready data summaries
Weekly review generator structure
Journal-to-content workflow
Overwhelm detection logic
Suggested top 3 placeholder
________________________________________
V0.5 — Integrations Planning
Adds planning for:
Calendar
GitHub
WordPress
MicroGrow data
Cloud sync
Local AI server
________________________________________
25. Development Sprint Plan
Sprint 1 — App Shell
Focus:
Flutter project
Folder structure
Theme
Routing
Bottom navigation
Placeholder screens
Output:
Clickable app skeleton
________________________________________
Sprint 2 — Database and Projects
Focus:
Drift database
Seed data
Projects table
Projects screen
Project detail
Add/edit project
Output:
Project management works
________________________________________
Sprint 3 — Tasks
Focus:
Tasks table
Task model
Task repository
Tasks screen
Add/edit task
Task status updates
Project linking
Output:
Task management works
________________________________________
Sprint 4 — Dashboard and DailyPlan
Focus:
DailyPlan table
Auto-create today’s plan
Dashboard cards
Top 3 display
Active projects display
Set focus
Output:
Dashboard becomes useful
________________________________________
Sprint 5 — Top 3 and Planner
Focus:
Select top 3
Prevent fourth task
Daily Planner screen
Morning intention
Evening review
Tomorrow focus
Output:
Daily planning loop works
________________________________________
Sprint 6 — Journal
Focus:
Journal table
Journal list
Journal entry form
Project linking
Task linking
Categories
Output:
Build history can be captured
________________________________________
Sprint 7 — Supporting Modules
Focus:
Learning
Content
Business
Wellbeing
Basic add/edit/list flows
Output:
Wider New Earth day can be managed
________________________________________
Sprint 8 — Quick Capture and Inbox
Focus:
Quick Capture dialog
Inbox table
Inbox screen
Convert inbox items
Park inbox items
Output:
Ideas can be captured quickly
________________________________________
Sprint 9 — Polish and MVP Testing
Focus:
Bug fixing
Empty states
Error messages
Visual polish
Data persistence testing
MVP release notes
Output:
V0.1 ready for daily personal use
________________________________________
26. First Real Build Checklist
Before writing feature code, prepare:
Flutter installed
Android Studio or VS Code ready
Android emulator or physical Android device ready
Git repo created
README.md created
FSD saved in docs
Basic folder structure created
pubspec.yaml packages selected
________________________________________
27. Suggested Repository Structure
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

  lib/
    main.dart
    app.dart
    core/
    features/

  test/
    unit/
    widget/
________________________________________
28. Initial README Purpose
The README should explain:
What the app is
Why it exists
MVP scope
Tech stack
How to run it
Development roadmap
Current version
Suggested one-line description:
New Earth Command Dashboard is a local-first Flutter app for managing daily projects, tasks, learning, business actions, content, wellbeing, and build progress across the New Earth mission.
________________________________________
29. Suggested Git Branches
For a clean build process:
main
develop
feature/app-shell
feature/database
feature/projects
feature/tasks
feature/dashboard
feature/planner
feature/journal
Branch rule:
main = stable release
develop = current working version
feature branches = specific build tasks
________________________________________
30. Development Risk List
Risk 1 — App Becomes Too Big Too Early
Mitigation:
Build Dashboard, Projects, Tasks, DailyPlan first.
Delay advanced AI, integrations, and analytics.
________________________________________
Risk 2 — Too Many Screens Before Core Works
Mitigation:
Use placeholder screens first.
Only fully build screens in priority order.
________________________________________
Risk 3 — Database Complexity Slows Build
Mitigation:
Start with Projects, Tasks, DailyPlan only.
Add other tables after core loop works.
________________________________________
Risk 4 — Dashboard Gets Overloaded
Mitigation:
Dashboard only shows today’s essentials.
Detailed lists stay on module screens.
________________________________________
Risk 5 — User Stops Using App Because It Feels Heavy
Mitigation:
Keep morning planning simple.
Use Top 3 rule.
Make Quick Capture fast.
Make Journal easy to start.
________________________________________
31. MVP Testing Checklist
First Launch
App opens
Database opens
Seed projects appear
Today’s DailyPlan is created
Dashboard loads
Projects
View projects
Open project
Create project
Edit project
Update progress
Archive project
Tasks
Create task
Edit task
Link to project
Move to Today
Mark Done
Park task
Filter by status
Filter by project
Dashboard
Set focus
View top 3 tasks
Complete top task
View active projects
Start evening review
Planner
Write morning intention
View top 3
Complete evening review
Set tomorrow focus
Save plan
Journal
Create entry
Edit entry
Link to project
Link to task
Mark possible LinkedIn post
Mark possible website entry
Persistence
Close app
Reopen app
Projects still exist
Tasks still exist
DailyPlan still exists
Journal entries still exist
________________________________________
32. Done Definition for Each Feature
A feature should only be considered done when:
UI exists
Data saves
Data loads again
User can edit it
Empty state exists
Basic error handling exists
Navigation works
No obvious crash
________________________________________
33. MVP Release Notes Template
When V0.1 is ready, release notes could look like this:
# New Earth Command Dashboard V0.1

Initial local-first MVP release.

Included:
- Daily Dashboard
- Project tracking
- Task management
- Top 3 daily priorities
- Daily Planner
- Evening Review
- Journal entries
- Local SQLite storage
- Default New Earth project seed data

Purpose:
This version helps manage the daily build of New Earth by turning projects, tasks, and progress into a clear command dashboard.

Known limitations:
- No cloud sync yet
- No AI assistant yet
- No calendar integration yet
- No GitHub integration yet
- Basic UI polish only
________________________________________
34. Part 9 Summary
The MVP should be built in this order:
App shell
Database
Seed projects
Projects
Tasks
DailyPlan
Dashboard
Top 3
Planner
Journal
Supporting modules
Quick Capture
Testing
The first real success point is:
Peter can open the app in the morning, see today’s New Earth focus, choose three tasks, work from them, and record what moved forward.
That is the heart of the New Earth Command Dashboard.

