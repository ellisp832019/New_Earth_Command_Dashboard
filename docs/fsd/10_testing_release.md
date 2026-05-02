# Testing and Release

FSD Part 10 — Testing Plan, Acceptance Criteria & Release Checklist
Project Name
New Earth Command Dashboard
Document Version
V0.1 — Testing and Release Draft
________________________________________
1. Purpose of This Section
This section defines how to prove the app works before calling V0.1 complete.
Testing should confirm that the app can reliably support the core New Earth daily workflow:
Open the app
See today’s dashboard
Set focus
Choose top 3 tasks
Track projects
Complete tasks
Capture progress
Review the day
Reopen the app without losing data
The goal is not perfection for V0.1.
The goal is a stable, usable first version that can become part of the daily New Earth build process.
________________________________________
2. Testing Principle
The main testing principle is:
The app is ready when it helps Peter manage a real working day without confusion, crashes, or lost data.
Testing should focus on real use, not just technical checks.
________________________________________
3. Testing Levels
The MVP should be tested at these levels:
1. Manual user testing
2. Functional testing
3. Database persistence testing
4. Navigation testing
5. Form validation testing
6. Dashboard workflow testing
7. Regression testing
8. Release checklist testing
Unit tests and automated widget tests can be added later, but manual testing is enough for the first private build if done carefully.
________________________________________
4. Core MVP Acceptance Criteria
The MVP is acceptable when the user can:
1. Open the app successfully.
2. View the Dashboard.
3. See seeded New Earth projects.
4. Create, edit, and archive projects.
5. Create, edit, complete, park, and filter tasks.
6. Link tasks to projects.
7. Set today’s main focus.
8. Choose up to 3 priority tasks.
9. Be prevented from choosing more than 3 priority tasks.
10. Complete top tasks from the Dashboard.
11. Create and save a Daily Plan.
12. Complete an Evening Review.
13. Create and edit Journal entries.
14. Create Learning, Content, Business, and Wellbeing records.
15. Use Quick Capture to save an idea.
16. Close and reopen the app without losing data.
17. Navigate between all major screens.
18. Use the app without internet access.
________________________________________
5. Manual Test Plan Overview
Manual testing should be done in stages.
Stage 1 — First Launch Test
Purpose:
Confirm the app starts correctly and creates default data.
Stage 2 — Navigation Test
Purpose:
Confirm all screens open correctly.
Stage 3 — Project Test
Purpose:
Confirm projects can be managed.
Stage 4 — Task Test
Purpose:
Confirm tasks can be managed and linked to projects.
Stage 5 — Dashboard Test
Purpose:
Confirm the Dashboard reflects today’s plan.
Stage 6 — Daily Planner Test
Purpose:
Confirm morning planning and evening review work.
Stage 7 — Journal Test
Purpose:
Confirm build progress can be captured.
Stage 8 — Supporting Module Test
Purpose:
Confirm Learning, Content, Business, and Wellbeing modules work.
Stage 9 — Quick Capture Test
Purpose:
Confirm loose thoughts can be captured quickly.
Stage 10 — Persistence Test
Purpose:
Confirm data remains after closing and reopening the app.
________________________________________
6. Test Case Format
Each test case should follow this structure:
Test ID
Test Name
Purpose
Precondition
Steps
Expected Result
Pass / Fail
Notes
Example:
Test ID: TC-TASK-001
Test Name: Create Task
Purpose: Confirm the user can create a task.
Precondition: App is open.
Steps:
1. Open Tasks screen.
2. Tap Add Task.
3. Enter title.
4. Save task.

Expected Result:
The task appears in the task list.
________________________________________
7. First Launch Test Cases
TC-START-001 — App Opens Successfully
Purpose: Confirm the app launches.
Steps:
1. Install the app.
2. Open the app.
Expected result:
The app opens without crashing.
The Dashboard screen appears.
________________________________________
TC-START-002 — Default Projects Are Created
Purpose: Confirm seed data works.
Steps:
1. Open the app for the first time.
2. Go to Projects.
Expected result:
Default New Earth projects appear.
Default projects should include:
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
TC-START-003 — Seed Data Does Not Duplicate
Purpose: Confirm default projects are not recreated every launch.
Steps:
1. Open app.
2. Check Projects list.
3. Close app.
4. Reopen app.
5. Check Projects list again.
Expected result:
Default projects appear only once.
No duplicate project cards are created.
________________________________________
TC-START-004 — Today’s DailyPlan Is Created
Purpose: Confirm one DailyPlan exists for today.
Steps:
1. Open app.
2. Go to Dashboard.
3. Go to Planner.
Expected result:
A blank DailyPlan exists for today.
The Planner can be edited.
________________________________________
8. Navigation Test Cases
TC-NAV-001 — Bottom Navigation Works
Steps:
1. Open app.
2. Tap Dashboard.
3. Tap Projects.
4. Tap Tasks.
5. Tap Planner.
6. Tap More.
Expected result:
Each tab opens the correct screen.
No navigation crash occurs.
________________________________________
TC-NAV-002 — More Screen Links Work
Steps:
1. Open More screen.
2. Tap Journal.
3. Return to More.
4. Tap Learning.
5. Return to More.
6. Tap Content.
7. Return to More.
8. Tap Business.
9. Return to More.
10. Tap Wellbeing.
11. Return to More.
12. Tap Settings.
Expected result:
Each screen opens correctly.
Back navigation works.
________________________________________
TC-NAV-003 — Return to Dashboard
Steps:
1. Open any screen.
2. Tap Dashboard.
Expected result:
The user returns to the Dashboard.
________________________________________
9. Project Test Cases
TC-PROJ-001 — View Projects
Steps:
1. Open Projects screen.
Expected result:
Project list is visible.
Each project card shows name, status, priority, progress, and next action where available.
________________________________________
TC-PROJ-002 — Create Project
Steps:
1. Open Projects screen.
2. Tap Add Project.
3. Enter project name: Test Project.
4. Add short description.
5. Save.
Expected result:
Test Project appears in the project list.
________________________________________
TC-PROJ-003 — Edit Project
Steps:
1. Open Test Project.
2. Tap Edit.
3. Change project status to Active.
4. Set progress to 25%.
5. Save.
Expected result:
Project updates are saved.
Project card shows updated status and progress.
________________________________________
TC-PROJ-004 — Archive Project
Steps:
1. Open Test Project.
2. Tap Archive.
3. Confirm archive.
Expected result:
Project no longer appears in active project list.
Project is not permanently deleted.
________________________________________
TC-PROJ-005 — Open Project Detail
Steps:
1. Open Projects screen.
2. Tap MicroGrow.
Expected result:
MicroGrow Project Detail screen opens.
Project information is shown.
________________________________________
10. Task Test Cases
TC-TASK-001 — Create Task
Steps:
1. Open Tasks screen.
2. Tap Add Task.
3. Enter title: Build dashboard card.
4. Select project: New Earth Command Dashboard, if available.
5. Save.
Expected result:
Task appears in task list.
Task status defaults to Inbox or selected status.
________________________________________
TC-TASK-002 — Edit Task
Steps:
1. Open created task.
2. Change priority to High.
3. Change status to Planned.
4. Save.
Expected result:
Task updates are saved.
Task card shows updated priority and status.
________________________________________
TC-TASK-003 — Link Task to Project
Steps:
1. Open a task.
2. Select related project: MicroGrow.
3. Save.
4. Open MicroGrow project.
Expected result:
Task appears under MicroGrow related tasks.
________________________________________
TC-TASK-004 — Mark Task Done
Steps:
1. Open Tasks screen.
2. Tap checkbox on a task.
Expected result:
Task status changes to Done.
completed_at is set.
Task appears in Done filter.
________________________________________
TC-TASK-005 — Move Task to Today
Steps:
1. Open a task.
2. Change status to Today.
3. Save.
Expected result:
Task appears under Today filter.
________________________________________
TC-TASK-006 — Park Task
Steps:
1. Open a task.
2. Select Park.
Expected result:
Task status changes to Parked.
Task is removed from active focus views.
________________________________________
TC-TASK-007 — Filter Tasks by Status
Steps:
1. Open Tasks screen.
2. Select Today filter.
3. Select Done filter.
4. Select Parked filter.
Expected result:
Only tasks matching selected status are shown.
________________________________________
TC-TASK-008 — Filter Tasks by Project
Steps:
1. Open Tasks screen.
2. Select project filter: MicroGrow.
Expected result:
Only MicroGrow tasks are shown.
________________________________________
11. Top 3 Priority Test Cases
TC-TOP3-001 — Select First Top Task
Steps:
1. Open Tasks screen.
2. Select a task.
3. Mark as Top 3 / Today priority.
4. Open Dashboard.
Expected result:
Task appears in Top 3 Tasks card.
________________________________________
TC-TOP3-002 — Select Three Top Tasks
Steps:
1. Create or select three tasks.
2. Mark all three as top tasks.
3. Open Dashboard.
Expected result:
All three tasks appear in Top 3 Tasks card.
________________________________________
TC-TOP3-003 — Prevent Fourth Top Task
Steps:
1. Ensure three top tasks already exist for today.
2. Try to add a fourth top task.
Expected result:
App prevents fourth top task.
User sees clear message explaining the top 3 limit.
Suggested message:
You already have 3 priority tasks for today. Complete, remove, or carry one forward first.
________________________________________
TC-TOP3-004 — Remove Task from Top 3
Steps:
1. Open Dashboard or Planner.
2. Remove one task from Top 3.
Expected result:
Task is removed from Top 3.
Task still exists in task list.
________________________________________
TC-TOP3-005 — Complete Top Task from Dashboard
Steps:
1. Open Dashboard.
2. Tap checkbox on a top task.
Expected result:
Task status changes to Done.
Top 3 card updates.
________________________________________
12. Dashboard Test Cases
TC-DASH-001 — Dashboard Shows Today’s Date
Steps:
1. Open Dashboard.
Expected result:
Today’s date is shown correctly.
________________________________________
TC-DASH-002 — Set Today’s Focus
Steps:
1. Open Dashboard.
2. Tap Set Focus.
3. Enter: Build New Earth Command Dashboard MVP.
4. Add reason.
5. Save.
Expected result:
Focus appears on Dashboard.
Focus also appears in Planner.
________________________________________
TC-DASH-003 — Dashboard Shows Active Projects
Steps:
1. Open Dashboard.
Expected result:
Active projects are shown.
Archived projects are not shown by default.
________________________________________
TC-DASH-004 — Dashboard Updates After Task Completion
Steps:
1. Complete a top task from Dashboard.
2. View Top 3 card.
Expected result:
Task appears completed or is removed depending on chosen UI behaviour.
Task status is saved as Done.
________________________________________
TC-DASH-005 — Start Evening Review
Steps:
1. Open Dashboard.
2. Tap Start Evening Review.
Expected result:
Planner opens at Evening Review section.
________________________________________
13. Daily Planner Test Cases
TC-PLAN-001 — Edit Morning Intention
Steps:
1. Open Planner.
2. Enter morning intention.
3. Save.
4. Leave screen and return.
Expected result:
Morning intention remains saved.
________________________________________
TC-PLAN-002 — Set Main Focus from Planner
Steps:
1. Open Planner.
2. Enter main focus.
3. Save.
4. Open Dashboard.
Expected result:
Main focus appears on Dashboard.
________________________________________
TC-PLAN-003 — Save Evening Review
Steps:
1. Open Planner.
2. Fill in evening review fields.
3. Save.
4. Leave screen and return.
Expected result:
Review remains saved.
________________________________________
TC-PLAN-004 — Add Tomorrow Focus
Steps:
1. Open Planner.
2. Enter tomorrow’s possible focus.
3. Save.
Expected result:
Tomorrow focus is stored in DailyPlan.
________________________________________
TC-PLAN-005 — Carry Forward Task Placeholder
For V0.1, this can be a placeholder if not fully built.
Expected result:
Unfinished tasks can either be manually moved to tomorrow or marked for future carry-forward.
________________________________________
14. Journal Test Cases
TC-JOUR-001 — Create Journal Entry
Steps:
1. Open Journal.
2. Tap Add Entry.
3. Enter title: First Dashboard Build Log.
4. Add body notes.
5. Save.
Expected result:
Entry appears in Journal list.
________________________________________
TC-JOUR-002 — Edit Journal Entry
Steps:
1. Open journal entry.
2. Add more text.
3. Save.
4. Reopen entry.
Expected result:
Updated text remains saved.
________________________________________
TC-JOUR-003 — Link Journal Entry to Project
Steps:
1. Open journal entry.
2. Select related project: New Earth Command Dashboard.
3. Save.
Expected result:
Journal entry shows linked project.
Project detail can show linked journal entries if built.
________________________________________
TC-JOUR-004 — Mark Journal Entry as Possible LinkedIn Post
Steps:
1. Open journal entry.
2. Tick Possible LinkedIn Post.
3. Save.
Expected result:
Entry stores possible_linkedin_post = true.
________________________________________
TC-JOUR-005 — Mark Journal Entry as Possible Website Entry
Steps:
1. Open journal entry.
2. Tick Possible Website Entry.
3. Save.
Expected result:
Entry stores possible_website_entry = true.
________________________________________
15. Learning Test Cases
TC-LEARN-001 — Create Learning Item
Steps:
1. Open Learning.
2. Tap Add Learning Topic.
3. Enter topic: Flutter Drift Database.
4. Link to project.
5. Save.
Expected result:
Learning item appears in Learning list.
________________________________________
TC-LEARN-002 — Update Learning Status
Steps:
1. Open learning item.
2. Change status from To Learn to Learning.
3. Save.
Expected result:
Updated status appears on learning card.
________________________________________
TC-LEARN-003 — Add Resource Link
Steps:
1. Open learning item.
2. Add resource link.
3. Save.
Expected result:
Resource link remains saved.
________________________________________
16. Content Test Cases
TC-CONT-001 — Create Content Item
Steps:
1. Open Content.
2. Tap Add Content Idea.
3. Enter title: Building the New Earth Command Dashboard.
4. Select platform: LinkedIn.
5. Save.
Expected result:
Content item appears in Content list.
________________________________________
TC-CONT-002 — Mark Content as Drafting
Steps:
1. Open content item.
2. Change status to Drafting.
3. Add draft text.
4. Save.
Expected result:
Content item saves status and draft text.
________________________________________
TC-CONT-003 — Mark Image Needed
Steps:
1. Open content item.
2. Toggle Image Needed.
3. Add image prompt.
4. Save.
Expected result:
Image requirement and prompt are saved.
________________________________________
TC-CONT-004 — Mark Content Published
Steps:
1. Open content item.
2. Change status to Published.
3. Add published link if available.
4. Save.
Expected result:
Content item status is Published.
________________________________________
17. Business Test Cases
TC-BUS-001 — Create Business Opportunity
Steps:
1. Open Business.
2. Tap Add Opportunity.
3. Enter name: AI Architect Role.
4. Set type: Job.
5. Save.
Expected result:
Business opportunity appears in Business list.
________________________________________
TC-BUS-002 — Set Follow-Up Date
Steps:
1. Open business item.
2. Add follow-up date.
3. Save.
Expected result:
Follow-up date appears on business card.
________________________________________
TC-BUS-003 — Update Opportunity Status
Steps:
1. Open business item.
2. Change status to Applied.
3. Save.
Expected result:
Business opportunity status updates correctly.
________________________________________
18. Wellbeing Test Cases
TC-WELL-001 — Create Wellbeing Check-In
Steps:
1. Open Wellbeing.
2. Select energy level.
3. Select mood.
4. Select stress level.
5. Add notes.
6. Save.
Expected result:
Wellbeing check-in is saved for today.
________________________________________
TC-WELL-002 — Dashboard Shows Wellbeing Summary
Steps:
1. Create wellbeing check-in.
2. Open Dashboard.
Expected result:
Dashboard shows energy, mood, stress, and suggested workload.
________________________________________
TC-WELL-003 — Low Energy Suggests Light Workload
Steps:
1. Create wellbeing check-in with energy = Low.
2. Save.
Expected result:
Suggested workload = Light.
Suggested message:
Energy is low today. Choose one important task and keep the rest light.
________________________________________
19. Inbox and Quick Capture Test Cases
TC-INBOX-001 — Open Quick Capture
Steps:
1. Open Dashboard.
2. Tap Quick Capture.
Expected result:
Quick Capture dialog opens.
________________________________________
TC-INBOX-002 — Save Quick Capture Item
Steps:
1. Open Quick Capture.
2. Enter: Check Flutter navigation package.
3. Select type: Learning Note.
4. Save.
Expected result:
Item is saved to Inbox.
________________________________________
TC-INBOX-003 — View Inbox Item
Steps:
1. Open Inbox.
Expected result:
Captured item appears in Inbox list.
________________________________________
TC-INBOX-004 — Park Inbox Item
Steps:
1. Open Inbox.
2. Select inbox item.
3. Park item.
Expected result:
Inbox item status changes to Parked.
________________________________________
TC-INBOX-005 — Convert Inbox Item to Task
Steps:
1. Open Inbox.
2. Select inbox item.
3. Convert to Task.
4. Save.
5. Open Tasks.
Expected result:
New task appears in Tasks list.
Inbox item status changes to Processed.
________________________________________
20. Persistence Test Cases
TC-PERSIST-001 — Tasks Persist After Restart
Steps:
1. Create a task.
2. Close app fully.
3. Reopen app.
4. Open Tasks.
Expected result:
Created task is still present.
________________________________________
TC-PERSIST-002 — Projects Persist After Restart
Steps:
1. Create or edit a project.
2. Close app.
3. Reopen app.
4. Open Projects.
Expected result:
Project changes remain saved.
________________________________________
TC-PERSIST-003 — DailyPlan Persists After Restart
Steps:
1. Set today’s focus.
2. Add morning intention.
3. Close app.
4. Reopen app.
5. Open Dashboard and Planner.
Expected result:
Today’s focus and morning intention remain saved.
________________________________________
TC-PERSIST-004 — Journal Persists After Restart
Steps:
1. Create journal entry.
2. Close app.
3. Reopen app.
4. Open Journal.
Expected result:
Journal entry remains saved.
________________________________________
21. Offline Test Cases
TC-OFF-001 — App Works Without Internet
Steps:
1. Turn device internet off.
2. Open app.
3. Create task.
4. Create journal entry.
5. Edit project.
Expected result:
Core app functions work without internet.
________________________________________
TC-OFF-002 — No Login Required
Steps:
1. Install and open app.
Expected result:
No login is required for MVP.
User can use the app immediately.
________________________________________
22. Error Handling Test Cases
TC-ERR-001 — Required Task Title
Steps:
1. Open Add Task.
2. Leave title empty.
3. Tap Save.
Expected result:
App does not save empty task.
User sees a clear message.
Suggested message:
Please enter a task title.
________________________________________
TC-ERR-002 — Required Project Name
Steps:
1. Open Add Project.
2. Leave name empty.
3. Tap Save.
Expected result:
App does not save empty project.
User sees a clear message.
Suggested message:
Please enter a project name.
________________________________________
TC-ERR-003 — Archive Confirmation
Steps:
1. Tap Archive on a project or task.
Expected result:
App asks for confirmation before archiving.
Suggested message:
Archive this item? You can restore it later.
________________________________________
23. Empty State Acceptance Criteria
Every main screen should have a helpful empty state.
Tasks Empty State
No tasks yet.
Add your first task to start moving New Earth forward.
Journal Empty State
No journal entries yet.
Capture today’s progress so the journey is not lost.
Content Empty State
No content ideas yet.
Turn a build update into your first post idea.
Business Empty State
No business opportunities yet.
Add a job, funding idea, grant, contact, or partnership lead.
Learning Empty State
No learning topics yet.
Add a skill that will help you build New Earth.
________________________________________
24. Visual Acceptance Criteria
The app does not need final polish in V0.1, but it should meet basic usability standards.
Visual Criteria
Text is readable.
Buttons are easy to tap.
Cards have enough spacing.
Dashboard is not overcrowded.
Status badges are clear.
Forms are understandable.
Navigation labels are clear.
Dashboard Visual Criteria
The Dashboard should show:
Today’s date
Main focus
Top 3 tasks
Active projects
Wellbeing summary
Quick Capture
Evening Review
without feeling overloaded.
________________________________________
25. Performance Acceptance Criteria
For V0.1:
App opens without long delay.
Dashboard loads quickly.
Task creation feels instant.
Project list opens quickly.
Journal list opens quickly.
Navigation does not visibly lag.
Target performance:
Dashboard visible within roughly 2 seconds.
Most local actions complete within roughly 1 second.
________________________________________
26. Privacy and Security Acceptance Criteria
For V0.1:
No account required.
No data uploaded to cloud.
No public sharing.
All data stored locally.
Wellbeing data remains private.
No external integrations enabled by default.
Future versions can add sync, login, and encryption, but V0.1 should remain private and local-first.
________________________________________
27. Release Checklist
Before calling V0.1 complete, check:
[ ] App launches successfully.
[ ] Dashboard opens first.
[ ] Bottom navigation works.
[ ] More screen links work.
[ ] Default projects are seeded.
[ ] Seed projects do not duplicate.
[ ] Projects can be created.
[ ] Projects can be edited.
[ ] Projects can be archived.
[ ] Tasks can be created.
[ ] Tasks can be edited.
[ ] Tasks can be linked to projects.
[ ] Tasks can be marked Done.
[ ] Tasks can be moved to Today.
[ ] Tasks can be parked.
[ ] Tasks can be filtered.
[ ] Today’s DailyPlan is created automatically.
[ ] Today’s focus can be set.
[ ] Top 3 tasks can be selected.
[ ] Fourth top task is prevented.
[ ] Top tasks appear on Dashboard.
[ ] Top tasks can be completed from Dashboard.
[ ] Planner saves morning intention.
[ ] Planner saves evening review.
[ ] Journal entries can be created.
[ ] Journal entries can be edited.
[ ] Learning items can be created.
[ ] Content items can be created.
[ ] Business items can be created.
[ ] Wellbeing check-in can be created.
[ ] Quick Capture saves to Inbox.
[ ] Data persists after app restart.
[ ] App works offline.
[ ] Empty states exist.
[ ] Basic error messages exist.
[ ] Archive actions ask for confirmation.
[ ] No major crash found in daily workflow.
________________________________________
28. MVP Release Definition
The MVP can be released as V0.1 when the following daily workflow works from start to finish:
1. Open the app.
2. See today’s Dashboard.
3. Set today’s focus.
4. Create or choose tasks.
5. Select top 3 tasks.
6. Work from those tasks.
7. Mark tasks done.
8. Add a journal entry.
9. Complete evening review.
10. Close and reopen the app.
11. Confirm everything is still saved.
This is the core release test.
________________________________________
29. Known Limitations for V0.1
V0.1 may intentionally not include:
Cloud sync
User accounts
AI assistant
Calendar integration
GitHub integration
WordPress integration
MicroGrow live device data
Advanced analytics
Push notifications
PDF export
Team collaboration
Advanced search
These limitations are acceptable because V0.1 is a private local-first command dashboard.
________________________________________
30. Bug Severity Levels
Critical
A critical bug prevents basic use.
Examples:
App will not open.
Database fails to load.
Tasks cannot be saved.
Data disappears after restart.
Dashboard crashes.
Critical bugs must be fixed before release.
________________________________________
High
A high bug affects an important workflow.
Examples:
Top 3 tasks do not appear on Dashboard.
Projects cannot be edited.
Journal entries fail to save.
Planner review does not persist.
High bugs should be fixed before release.
________________________________________
Medium
A medium bug is annoying but does not stop core use.
Examples:
Wrong spacing on a card.
Filter does not refresh instantly.
Status badge alignment issue.
Empty state text missing.
Medium bugs can be fixed before or shortly after V0.1.
________________________________________
Low
A low bug is cosmetic or minor.
Examples:
Icon not final.
Text label could be improved.
Minor layout spacing issue.
Low bugs can be fixed later.
________________________________________
31. Release Notes Template
# New Earth Command Dashboard V0.1

Initial private MVP release.

## Purpose

This version creates a local-first command dashboard for managing the daily build of New Earth.

## Included

- Daily Dashboard
- Today’s main focus
- Top 3 priority tasks
- Project tracking
- Task management
- Daily Planner
- Evening Review
- Journal entries
- Learning tracker
- Content planner
- Business opportunity tracker
- Wellbeing check-in
- Quick Capture and Inbox
- Local SQLite storage
- Default New Earth project seed data

## Known Limitations

- No cloud sync yet
- No AI assistant yet
- No calendar integration yet
- No GitHub integration yet
- No WordPress integration yet
- No MicroGrow live data yet
- Basic visual polish only

## Main Goal

Help Peter open the app each morning, know what matters, choose three useful tasks, and record what moved New Earth forward.
________________________________________
32. Post-Release Review Questions
After using V0.1 for a few days, review:
Did the app reduce overwhelm?
Did the Dashboard help decide what to do?
Was the Top 3 system useful?
Was Quick Capture fast enough?
Was the Journal easy to use?
Were any screens ignored?
Were any fields unnecessary?
What felt confusing?
What should be simplified?
What should be added next?
This review should guide V0.2.
________________________________________
33. V0.2 Improvement Candidates
After V0.1, possible improvements include:
Better dashboard layout
Search
Export to Markdown
Weekly review screen
Better project progress view
Journal-to-content workflow
Content calendar
Business follow-up reminders
Learning progress dashboard
Wellbeing trends
Simple notifications
AI planning assistant prototype
The best V0.2 direction should be chosen only after using V0.1 in real life.
________________________________________
34. Part 10 Summary
V0.1 is ready when the app can support a real New Earth working day.
The key acceptance test is:
Can Peter open the app, choose today’s focus, work from three tasks, record progress, review the day, and reopen the app without losing anything?
If yes, the first version has succeeded.
