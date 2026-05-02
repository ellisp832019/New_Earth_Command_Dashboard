# Functional Requirements

FSD Part 6 — Functional Requirements
Project Name
New Earth Command Dashboard
Document Version
V0.1 — Functional Requirements Draft
________________________________________
1. Purpose of This Section
This section defines what the app must actually do.
A functional requirement describes a specific behaviour, action, or rule inside the app.
For example:
The user must be able to create a task.
The user must be able to choose today’s top 3 tasks.
The user must be able to mark a task as done.
The app must create one DailyPlan per day.
This section will later help when building and testing the Flutter app.
________________________________________
2. Requirement Priority Levels
Each requirement should have a priority.
MUST = Required for MVP
SHOULD = Important, but can come after core MVP
COULD = Useful future feature
WON'T = Not planned for current version
For V0.1, focus mainly on MUST requirements.
________________________________________
3. Functional Requirement Groups
The requirements are grouped into these areas:
1. Dashboard Requirements
2. Project Requirements
3. Task Requirements
4. Daily Planner Requirements
5. Journal Requirements
6. Learning Requirements
7. Content Requirements
8. Business Requirements
9. Wellbeing Requirements
10. Inbox / Quick Capture Requirements
11. Navigation Requirements
12. Settings Requirements
13. Data / Storage Requirements
14. Search and Filtering Requirements
15. Future AI Requirements
________________________________________
4. Dashboard Requirements
FR-DASH-001 — Display Today’s Dashboard
Priority: MUST
The app must display a Dashboard screen when opened.
The Dashboard must show:
Today’s date
Today’s main focus
Top 3 tasks
Active projects
Learning focus
Content focus
Business reminder
Wellbeing check-in
Quick capture button
Evening review button
________________________________________
FR-DASH-002 — Create Today’s Daily Plan Automatically
Priority: MUST
If the user opens the app and no DailyPlan exists for the current date, the app must create a blank DailyPlan automatically.
Rule:
One DailyPlan per date.
________________________________________
FR-DASH-003 — Set Today’s Main Focus
Priority: MUST
The user must be able to set or edit today’s main focus.
The main focus should include:
Focus title
Focus reason
Related project
Example:
Main Focus:
Build New Earth Command Dashboard MVP

Reason:
This creates the control system for managing New Earth.
________________________________________
FR-DASH-004 — Display Top 3 Tasks
Priority: MUST
The Dashboard must display up to three priority tasks for the current day.
Each task should show:
Task title
Project
Priority
Status
Checkbox
________________________________________
FR-DASH-005 — Complete Task from Dashboard
Priority: MUST
The user must be able to mark a top 3 task as completed directly from the Dashboard.
When completed:
Task status changes to Done
completed_at is set
Dashboard updates
________________________________________
FR-DASH-006 — Open Linked Project from Dashboard
Priority: SHOULD
The user should be able to tap an active project on the Dashboard and open the Project Detail Screen.
________________________________________
FR-DASH-007 — Start Evening Review from Dashboard
Priority: MUST
The user must be able to start the Evening Review from the Dashboard.
This should open the Daily Planner review section.
________________________________________
5. Project Requirements
FR-PROJ-001 — View Project List
Priority: MUST
The user must be able to view a list of all projects.
Each project card must show:
Project name
Short description
Status
Priority
Progress percentage
Current milestone
Next action
________________________________________
FR-PROJ-002 — Create Project
Priority: MUST
The user must be able to create a new project.
Required field:
Project name
Optional fields:
Short description
Long description
Vision
Status
Priority
Progress percentage
Current milestone
Next action
Start date
Target date
Notes
________________________________________
FR-PROJ-003 — Edit Project
Priority: MUST
The user must be able to edit an existing project.
Editable fields:
Name
Description
Vision
Status
Priority
Progress
Current milestone
Next action
Dates
Notes
________________________________________
FR-PROJ-004 — Archive Project
Priority: SHOULD
The user should be able to archive a project instead of permanently deleting it.
Archived projects should not appear in the active project list by default.
________________________________________
FR-PROJ-005 — View Project Detail
Priority: MUST
The user must be able to open a project detail page.
The page must show:
Project information
Current status
Progress
Current milestone
Next action
Active tasks
Blocked tasks
Linked journal entries
Linked learning items
Linked content ideas
Notes
________________________________________
FR-PROJ-006 — Add Task from Project
Priority: MUST
The user must be able to add a task directly from a Project Detail Screen.
The new task should automatically link to that project.
________________________________________
FR-PROJ-007 — Update Project Progress
Priority: MUST
The user must be able to manually update project progress from 0% to 100%.
Future version may calculate progress from tasks, but V0.1 should allow manual entry.
________________________________________
FR-PROJ-008 — Filter Projects by Status
Priority: SHOULD
The user should be able to filter projects by:
All
Active
Paused
Blocked
Completed
Future Ideas
Archived
________________________________________
6. Task Requirements
FR-TASK-001 — View Task List
Priority: MUST
The user must be able to view all tasks.
Each task must show:
Task title
Project
Status
Priority
Category
Due date
Energy level
________________________________________
FR-TASK-002 — Create Task
Priority: MUST
The user must be able to create a task.
Required field:
Task title
Optional fields:
Description
Project
Category
Priority
Status
Due date
Energy level
Estimated time
Notes
Default status:
Inbox
________________________________________
FR-TASK-003 — Edit Task
Priority: MUST
The user must be able to edit a task.
Editable fields:
Title
Description
Project
Category
Priority
Status
Due date
Energy level
Estimated time
Notes
________________________________________
FR-TASK-004 — Mark Task as Done
Priority: MUST
The user must be able to mark a task as done.
When marked done:
status = Done
completed_at = current date/time
updated_at = current date/time
________________________________________
FR-TASK-005 — Move Task to Today
Priority: MUST
The user must be able to move a task to Today.
When moved:
status = Today
updated_at = current date/time
________________________________________
FR-TASK-006 — Park Task
Priority: MUST
The user must be able to park a task for later.
When parked:
status = Parked
updated_at = current date/time
Purpose:
Parked tasks are not deleted.
They are removed from the current focus.
________________________________________
FR-TASK-007 — Block Task
Priority: SHOULD
The user should be able to mark a task as Blocked.
Blocked task should include optional blocker notes.
Example:
Blocked because I need the correct sensor module.
________________________________________
FR-TASK-008 — Delete Task
Priority: SHOULD
The user should be able to delete a task, but archive should be preferred.
For MVP, safer option:
is_archived = true
________________________________________
FR-TASK-009 — Filter Tasks
Priority: MUST
The user must be able to filter tasks by:
All
Inbox
Today
Planned
In Progress
Blocked
Done
Parked
________________________________________
FR-TASK-010 — Filter Tasks by Project
Priority: MUST
The user must be able to view tasks belonging to a specific project.
________________________________________
FR-TASK-011 — Filter Tasks by Category
Priority: SHOULD
The user should be able to filter tasks by category:
Build
Design
Research
Business
Learning
Content
Admin
Wellbeing
________________________________________
FR-TASK-012 — Filter Tasks by Energy Level
Priority: COULD
The user could filter tasks by energy level:
Low
Medium
High
This is useful when the user feels tired and wants lighter work.
________________________________________
7. Top 3 Daily Task Requirements
FR-TOP3-001 — Select Top 3 Tasks
Priority: MUST
The user must be able to select up to three tasks as today’s priority tasks.
These tasks will appear on the Dashboard and Daily Planner.
________________________________________
FR-TOP3-002 — Limit Top Tasks to Three
Priority: MUST
The app must prevent more than three tasks being selected as top tasks for one day.
If the user tries to add a fourth, the app should show a gentle message:
You already have 3 priority tasks for today. Complete, remove, or carry one forward first.
________________________________________
FR-TOP3-003 — Remove Task from Top 3
Priority: MUST
The user must be able to remove a task from today’s top 3 without deleting the task.
________________________________________
FR-TOP3-004 — Carry Forward Unfinished Top Tasks
Priority: SHOULD
During evening review, the user should be able to carry unfinished top tasks forward to tomorrow.
________________________________________
8. Daily Planner Requirements
FR-PLAN-001 — View Daily Planner
Priority: MUST
The user must be able to open the Daily Planner for the current date.
The Planner must show:
Date
Morning intention
Main focus
Top 3 tasks
Learning focus
Content focus
Business focus
Wellbeing action
Evening review
Tomorrow’s focus
________________________________________
FR-PLAN-002 — Edit Morning Intention
Priority: MUST
The user must be able to write or edit a morning intention.
Example:
Today I will focus on one useful build step instead of jumping between everything.
________________________________________
FR-PLAN-003 — Set Main Focus
Priority: MUST
The user must be able to set the main focus from the Planner as well as the Dashboard.
________________________________________
FR-PLAN-004 — Add Time Blocks
Priority: SHOULD
The user should be able to create basic time blocks.
Example:
09:00–10:30 — MicroGrow build
11:00–12:00 — Website update
14:00–15:00 — Learning Flutter
For V0.1, this can be simple text rather than a complex calendar.
________________________________________
FR-PLAN-005 — Complete Evening Review
Priority: MUST
The user must be able to complete an evening review.
Review fields:
What moved forward today?
What did I complete?
What did I learn?
What blocked me?
What needs to carry forward?
What is tomorrow’s likely focus?
________________________________________
FR-PLAN-006 — Carry Forward Tasks
Priority: SHOULD
The user should be able to carry unfinished tasks into tomorrow’s DailyPlan.
________________________________________
FR-PLAN-007 — Create Journal Entry from Review
Priority: SHOULD
The user should be able to turn an evening review into a JournalEntry.
This helps preserve the build journey.
________________________________________
9. Journal Requirements
FR-JOUR-001 — View Journal Entries
Priority: MUST
The user must be able to view a list of journal entries.
Each journal entry should show:
Date
Title
Related project
Category
Preview text
Tags
________________________________________
FR-JOUR-002 — Create Journal Entry
Priority: MUST
The user must be able to create a journal entry.
Required fields:
Title
Date
Optional fields:
Related project
Related task
Category
What I worked on
What I built
What I learned
Problems encountered
Decisions made
Next actions
Tags
Possible LinkedIn post
Possible website entry
________________________________________
FR-JOUR-003 — Edit Journal Entry
Priority: MUST
The user must be able to edit a journal entry.
________________________________________
FR-JOUR-004 — Link Journal Entry to Project
Priority: MUST
The user must be able to link a journal entry to a project.
________________________________________
FR-JOUR-005 — Link Journal Entry to Task
Priority: SHOULD
The user should be able to link a journal entry to a task.
________________________________________
FR-JOUR-006 — Convert Journal Entry to Content Idea
Priority: SHOULD
The user should be able to create a ContentItem from a JournalEntry.
Example:
Journal Entry:
Built first dashboard FSD

Convert to:
LinkedIn post idea
________________________________________
FR-JOUR-007 — Create Task from Journal Entry
Priority: SHOULD
The user should be able to create a task from a journal entry.
Example:
Next action:
Build dashboard wireframe

Create task:
Build dashboard wireframe
________________________________________
FR-JOUR-008 — Filter Journal Entries
Priority: SHOULD
The user should be able to filter journal entries by:
Project
Category
Date
Tag
________________________________________
10. Learning Requirements
FR-LEARN-001 — View Learning Items
Priority: MUST
The user must be able to view learning items.
Each item should show:
Topic
Related project
Status
Confidence
Next step
________________________________________
FR-LEARN-002 — Create Learning Item
Priority: MUST
The user must be able to create a learning item.
Required field:
Topic
Optional fields:
Related project
Reason for learning
Resource link
Status
Notes
Practice task
Next step
Skill confidence
Date started
Date applied
________________________________________
FR-LEARN-003 — Edit Learning Item
Priority: MUST
The user must be able to edit a learning item.
________________________________________
FR-LEARN-004 — Link Learning Item to Project
Priority: MUST
The user must be able to link learning to a project.
Example:
Learning Topic:
Flutter local database

Related Project:
New Earth Command Dashboard
________________________________________
FR-LEARN-005 — Create Practice Task from Learning Item
Priority: SHOULD
The user should be able to create a practical task from a learning item.
Example:
Learning:
Flutter navigation

Practice Task:
Build bottom navigation prototype
________________________________________
FR-LEARN-006 — Mark Learning as Applied
Priority: SHOULD
The user should be able to mark a learning item as Applied when it has been used in a project.
________________________________________
11. Content Requirements
FR-CONT-001 — View Content Items
Priority: MUST
The user must be able to view content ideas and drafts.
Each item should show:
Title
Platform
Type
Related project
Status
Publish date
Image needed
________________________________________
FR-CONT-002 — Create Content Item
Priority: MUST
The user must be able to create a content item.
Required field:
Title
Optional fields:
Platform
Related project
Content type
Status
Draft text
Image needed
Image prompt
Publish date
Published link
Notes
________________________________________
FR-CONT-003 — Edit Content Item
Priority: MUST
The user must be able to edit a content item.
________________________________________
FR-CONT-004 — Link Content to Project
Priority: MUST
The user must be able to link a content item to a project.
________________________________________
FR-CONT-005 — Link Content to Journal Entry
Priority: SHOULD
The user should be able to link content to a journal entry.
This allows progress to become public updates.
________________________________________
FR-CONT-006 — Mark Content as Published
Priority: MUST
The user must be able to mark content as Published.
When published, the user may optionally add:
Published date
Published link
________________________________________
FR-CONT-007 — Track Image Requirement
Priority: SHOULD
The user should be able to mark whether a content item needs an image.
Fields:
image_needed
image_prompt
________________________________________
12. Business Requirements
FR-BUS-001 — View Business Opportunities
Priority: MUST
The user must be able to view business and funding opportunities.
Each item should show:
Opportunity name
Type
Status
Deadline
Next action
Follow-up date
________________________________________
FR-BUS-002 — Create Business Opportunity
Priority: MUST
The user must be able to create a business opportunity.
Required field:
Opportunity name
Optional fields:
Type
Company/contact
Status
Deadline
Next action
Follow-up date
Related project
Related document link
Notes
________________________________________
FR-BUS-003 — Edit Business Opportunity
Priority: MUST
The user must be able to edit a business opportunity.
________________________________________
FR-BUS-004 — Set Follow-Up Date
Priority: SHOULD
The user should be able to set a follow-up date for a business item.
________________________________________
FR-BUS-005 — Mark Opportunity Status
Priority: MUST
The user must be able to update opportunity status:
Researching
Preparing
Applied
Waiting
Follow-up Needed
Accepted
Rejected
Paused
Archived
________________________________________
FR-BUS-006 — Link Business Item to Project
Priority: SHOULD
The user should be able to link a business opportunity to a project.
Example:
Grant opportunity linked to MicroGrow
________________________________________
13. Wellbeing Requirements
FR-WELL-001 — Create Daily Wellbeing Check-In
Priority: MUST
The user must be able to create a wellbeing check-in for the day.
Fields:
Energy level
Mood
Sleep quality
Stress level
Movement done
Food/water ok
Meditation/reflection done
Notes
________________________________________
FR-WELL-002 — Show Wellbeing on Dashboard
Priority: MUST
The Dashboard must show the day’s wellbeing check-in summary.
At minimum:
Energy level
Mood
Stress level
Suggested workload
________________________________________
FR-WELL-003 — Suggest Workload Based on Energy
Priority: SHOULD
The app should suggest workload based on energy level.
Example rules:
Low energy = Light workload
Medium energy = Normal workload
High energy = Deep work possible
________________________________________
FR-WELL-004 — Low Energy Focus Rule
Priority: SHOULD
If energy is low, the app should encourage a lighter plan.
Suggested message:
Energy is low today. Choose one important task and keep the rest light.
________________________________________
14. Inbox and Quick Capture Requirements
FR-INBOX-001 — Open Quick Capture
Priority: MUST
The user must be able to open Quick Capture from the Dashboard.
Future version should allow Quick Capture from every screen.
________________________________________
FR-INBOX-002 — Capture Inbox Item
Priority: MUST
The user must be able to quickly capture:
Task
Idea
Journal note
Content idea
Learning note
Business opportunity
Future idea
Required field:
Title or body text
________________________________________
FR-INBOX-003 — Save Unprocessed Items to Inbox
Priority: MUST
Any quick capture item that is not fully assigned must be saved to the Inbox.
Default status:
New
________________________________________
FR-INBOX-004 — View Inbox
Priority: SHOULD
The user should be able to view unprocessed Inbox items.
________________________________________
FR-INBOX-005 — Convert Inbox Item
Priority: SHOULD
The user should be able to convert an Inbox item into:
Task
Journal Entry
Content Item
Learning Item
Business Opportunity
When converted:
Inbox status = Processed
converted_to_type = chosen entity
converted_to_id = new item ID
processed_at = current date/time
________________________________________
FR-INBOX-006 — Park Inbox Item
Priority: SHOULD
The user should be able to park an Inbox item for later.
________________________________________
15. Navigation Requirements
FR-NAV-001 — Bottom Navigation
Priority: MUST
The mobile app must include bottom navigation with these tabs:
Dashboard
Projects
Tasks
Planner
More
________________________________________
FR-NAV-002 — More Screen Navigation
Priority: MUST
The More screen must link to:
Journal
Learning
Content
Business
Wellbeing
Settings
________________________________________
FR-NAV-003 — Return to Dashboard
Priority: MUST
The user must always be able to return to the Dashboard easily.
________________________________________
FR-NAV-004 — Project-to-Task Navigation
Priority: MUST
From a project, the user must be able to view related tasks.
________________________________________
FR-NAV-005 — Journal-to-Content Navigation
Priority: SHOULD
From a journal entry, the user should be able to create or open a related content item.
________________________________________
16. Settings Requirements
FR-SET-001 — View Settings
Priority: MUST
The user must be able to open the Settings screen.
________________________________________
FR-SET-002 — Theme Mode
Priority: SHOULD
The user should be able to choose:
Light
Dark
System
________________________________________
FR-SET-003 — Dashboard Card Visibility
Priority: SHOULD
The user should be able to show or hide dashboard cards:
Wellbeing
Business
Learning
Content
________________________________________
FR-SET-004 — Top Task Limit
Priority: COULD
Future version could allow the user to change the top task limit.
For MVP, the default should remain:
3
________________________________________
FR-SET-005 — Backup / Export
Priority: COULD
Future version could export data to:
JSON
CSV
Markdown
________________________________________
17. Data and Storage Requirements
FR-DATA-001 — Store Data Locally
Priority: MUST
The MVP must store app data locally on the device.
Recommended:
SQLite with Drift
________________________________________
FR-DATA-002 — Persist Data Between App Sessions
Priority: MUST
Data must remain available after the app closes and reopens.
________________________________________
FR-DATA-003 — Seed Default Projects
Priority: MUST
On first launch, the app must create default New Earth projects:
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
FR-DATA-004 — Use Unique IDs
Priority: MUST
Every main entity must have a unique ID.
Entities:
Project
Task
DailyPlan
JournalEntry
LearningItem
ContentItem
BusinessOpportunity
WellbeingCheckIn
InboxItem
________________________________________
FR-DATA-005 — Track Created and Updated Dates
Priority: MUST
Every main entity should include:
created_at
updated_at
________________________________________
FR-DATA-006 — Prefer Archive Over Delete
Priority: SHOULD
Where possible, items should be archived rather than permanently deleted.
________________________________________
18. Search and Filtering Requirements
FR-SEARCH-001 — Search Tasks
Priority: SHOULD
The user should be able to search tasks by title and notes.
________________________________________
FR-SEARCH-002 — Search Journal
Priority: SHOULD
The user should be able to search journal entries by:
Title
Project
Tags
Body text
________________________________________
FR-SEARCH-003 — Filter Projects
Priority: SHOULD
The user should be able to filter projects by status and priority.
________________________________________
FR-SEARCH-004 — Filter Content
Priority: COULD
The user could filter content by:
Platform
Status
Project
Content type
________________________________________
19. Notification Requirements
Notifications are not required for the earliest MVP, but they are useful later.
FR-NOTIF-001 — Daily Planning Reminder
Priority: COULD
The app could remind the user to plan the day.
Example:
What moves New Earth forward today?
________________________________________
FR-NOTIF-002 — Evening Review Reminder
Priority: COULD
The app could remind the user to complete an evening review.
Example:
Capture today’s progress before it is lost.
________________________________________
FR-NOTIF-003 — Follow-Up Reminder
Priority: COULD
The app could remind the user about business follow-ups.
________________________________________
20. Future AI Requirements
AI is not required for V0.1, but should be planned for later.
FR-AI-001 — Suggest Daily Plan
Priority: COULD
The AI assistant could suggest a daily plan based on:
Active projects
Open tasks
Deadlines
Energy level
Recent progress
________________________________________
FR-AI-002 — Suggest Top 3 Tasks
Priority: COULD
The AI assistant could recommend the best top 3 tasks for today.
________________________________________
FR-AI-003 — Summarise Project Progress
Priority: COULD
The AI assistant could summarise project progress from tasks and journal entries.
________________________________________
FR-AI-004 — Generate LinkedIn Draft
Priority: COULD
The AI assistant could turn a journal entry into a LinkedIn post draft.
________________________________________
FR-AI-005 — Detect Overwhelm
Priority: COULD
The AI assistant could detect when the user has too many active tasks and suggest simplifying the day.
________________________________________
21. MVP Functional Requirement Summary
For the first real build, these are the most important requirements:
1. Show Dashboard.
2. Create today’s DailyPlan automatically.
3. Set today’s main focus.
4. Create and manage projects.
5. Create and manage tasks.
6. Select top 3 daily tasks.
7. Mark tasks as done.
8. Create daily plan.
9. Complete evening review.
10. Create journal entries.
11. Track learning items.
12. Track content ideas.
13. Track business opportunities.
14. Create wellbeing check-in.
15. Quick capture ideas into Inbox.
16. Store all data locally.
17. Seed default New Earth projects.
________________________________________
22. Acceptance Test Examples
These are simple tests to prove the app works.
Test 1 — First Launch
Given the app is opened for the first time
When the Dashboard loads
Then default New Earth projects should exist
And a blank DailyPlan should exist for today
________________________________________
Test 2 — Create Task
Given the user is on the Tasks screen
When the user creates a task called "Build Dashboard Wireframe"
Then the task should appear in the task list
And the task status should default to Inbox
________________________________________
Test 3 — Select Top 3 Task
Given the user has created tasks
When the user selects a task as a top 3 task
Then the task should appear on the Dashboard
And the DailyPlan should store the task ID
________________________________________
Test 4 — Prevent Fourth Top Task
Given the user already has 3 top tasks for today
When the user tries to add a fourth top task
Then the app should prevent it
And show a message explaining the top 3 limit
________________________________________
Test 5 — Complete Task
Given a task appears on the Dashboard
When the user ticks the checkbox
Then the task status should change to Done
And completed_at should be set
________________________________________
Test 6 — Create Journal Entry
Given the user is on the Journal screen
When the user creates a journal entry
Then it should appear in the Journal list
And it should link to the selected project if one was chosen
________________________________________
Test 7 — Evening Review
Given the user has a DailyPlan for today
When the user completes the evening review
Then the review text should be saved
And the Dashboard should show the day as reviewed
________________________________________
23. Part 6 Summary
The New Earth Command Dashboard must help the user:
Plan the day
Choose focus
Track projects
Manage tasks
Capture learning
Record progress
Plan content
Manage business actions
Check wellbeing
Review the day
The most important behaviour is:
Open the app, know what matters, and move New Earth forward without overwhelm.
