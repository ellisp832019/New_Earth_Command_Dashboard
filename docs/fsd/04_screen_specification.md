# Screen Specification

FSD Part 4 — Screen-by-Screen Functional Specification
Project Name
New Earth Command Dashboard
Document Version
V0.1 — Screen Specification Draft
________________________________________
1. Purpose of This Section
This section defines each main screen of the app.
For each screen, we will define:
Screen purpose
Main information shown
User actions
Buttons
Fields
Navigation links
MVP requirements
Future improvements
This section will later help when building the Flutter app because each screen can become its own Flutter page/widget.
________________________________________
2. Screen List for MVP
The MVP should include these screens:
1. Dashboard Screen
2. Projects Screen
3. Project Detail Screen
4. Tasks Screen
5. Task Detail / Add Task Screen
6. Daily Planner Screen
7. Journal Screen
8. Journal Entry Screen
9. Learning Screen
10. Content Planner Screen
11. Business Hub Screen
12. Wellbeing Screen
13. More Screen
14. Settings Screen
________________________________________
3. Dashboard Screen
3.1 Screen Purpose
The Dashboard is the main home screen.
It should give Peter a calm, clear view of today.
The user should be able to open the app and immediately understand:
What am I focusing on today?
What are my top 3 tasks?
Which projects are active?
What do I need to learn?
What content should I create?
How is my energy today?
What needs reviewing at the end of the day?
________________________________________
3.2 Dashboard Layout
Recommended layout:
Top Header
Today’s Focus Card
Top 3 Tasks Card
Active Projects Card
Learning Focus Card
Content Focus Card
Business Reminder Card
Wellbeing Check Card
Quick Capture Button
Evening Review Button
________________________________________
3.3 Header Area
The top of the screen should show:
New Earth Command Dashboard
Today’s date
Small greeting or intention
Example:
New Earth Command Dashboard
Friday 1 May 2026

What moves the mission forward today?
________________________________________
3.4 Today’s Focus Card
Fields shown:
Main focus title
Short reason / intention
Related project
Example:
Main Focus:
Build MicroGrow Field Scanner diagnostics screen

Why it matters:
This moves the field maintenance tool closer to a usable prototype.

Related Project:
MicroGrow Field Scanner
Buttons:
Set Focus
Edit Focus
Clear Focus
MVP requirement:
The user must be able to set one main focus per day.
________________________________________
3.5 Top 3 Tasks Card
Fields shown:
Task 1
Task 2
Task 3
Task status
Related project
Each task should have:
Checkbox
Task title
Project label
Priority label
Buttons:
Choose Top 3
Add Task
View All Tasks
Rules:
Only 3 priority tasks should be shown.
User can complete tasks from the dashboard.
Unfinished tasks can be carried forward.
________________________________________
3.6 Active Projects Card
Fields shown:
Project name
Current milestone
Progress percentage
Next action
Example:
MicroGrow
Progress: 65%
Next Action: Stabilise diagnostics screen

New Earth Website
Progress: 40%
Next Action: Add founder journey page
Buttons:
Open Project
View All Projects
________________________________________
3.7 Learning Focus Card
Fields shown:
Learning topic
Related project
Reason for learning
Next learning action
Example:
Learning Focus:
Flutter navigation structure

Related Project:
New Earth Command Dashboard

Next Step:
Build bottom navigation prototype
Buttons:
Set Learning Focus
Open Learning
________________________________________
3.8 Content Focus Card
Fields shown:
Content idea
Platform
Related project
Status
Example:
Content Focus:
LinkedIn post about building New Earth Command Dashboard

Platform:
LinkedIn

Status:
Drafting
Buttons:
Add Content Idea
Open Content Planner
________________________________________
3.9 Business Reminder Card
Fields shown:
Opportunity
Deadline / follow-up date
Next action
Status
Example:
Business Reminder:
AI Architect CV application

Next Action:
Review final CV

Status:
Preparing
Buttons:
Open Business Hub
Add Opportunity
________________________________________
3.10 Wellbeing Check Card
Fields shown:
Energy level
Mood
Stress level
Today’s wellbeing action
Example:
Energy:
Medium

Mood:
Focused

Today’s Wellbeing Action:
Take a walk before evening review
Buttons:
Check In
Open Wellbeing
________________________________________
3.11 Quick Capture Button
The Quick Capture button should be visible from the Dashboard.
Button label:
+ Quick Capture
Quick Capture types:
Task
Idea
Journal note
Content idea
Learning note
Business opportunity
Future idea
MVP rule:
Anything captured without a category should go to the Inbox.
________________________________________
3.12 Evening Review Button
Button label:
Start Evening Review
This should open the Daily Planner review section.
Review questions:
What moved forward today?
What got completed?
What blocked progress?
What did I learn?
What should move to tomorrow?
________________________________________
4. Projects Screen
4.1 Screen Purpose
The Projects Screen shows all New Earth projects in one place.
It helps the user see the full system without becoming overwhelmed.
________________________________________
4.2 Project List Layout
Each project should appear as a card.
Project card fields:
Project name
Short description
Status
Priority
Progress percentage
Current milestone
Next action
Open task count
Example:
MicroGrow
Smart grow automation platform

Status: Active
Priority: High
Progress: 65%

Current Milestone:
Stabilise diagnostics and v1.0.x

Next Action:
Test sensor reporting
________________________________________
4.3 Project Filters
Filters:
All Projects
Active
Paused
Blocked
Completed
Future Ideas
Sort options:
Priority
Progress
Recently updated
Alphabetical
________________________________________
4.4 Project Screen Buttons
Buttons:
+ Add Project
Open Project
Add Task
Update Progress
Park Project
________________________________________
4.5 Initial Project Cards
The MVP should start with these default projects:
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
5. Project Detail Screen
5.1 Screen Purpose
The Project Detail Screen gives one project its own home.
This screen should answer:
What is this project?
Why does it matter?
What is the current status?
What is the next action?
What tasks are active?
What has been done recently?
________________________________________
5.2 Project Detail Layout
Recommended layout:
Project Header
Vision / Purpose Card
Current Status Card
Progress Card
Next Action Card
Active Tasks
Blocked Tasks
Linked Journal Entries
Linked Learning
Linked Content
Notes
________________________________________
5.3 Project Fields
Each project should include:
Project name
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
5.4 Project Detail Buttons
Buttons:
Edit Project
Add Task
Add Journal Entry
Add Learning Item
Add Content Idea
Update Progress
Mark Blocked
Park Project
________________________________________
5.5 Project Status Options
Idea
Active
Paused
Blocked
Completed
Archived
________________________________________
5.6 Project Priority Options
High
Medium
Low
Someday
________________________________________
6. Tasks Screen
6.1 Screen Purpose
The Tasks Screen manages all actions across all projects.
It should be simple and filterable.
________________________________________
6.2 Task List Layout
Each task should appear as a list item or card.
Task card fields:
Checkbox
Task title
Project
Priority
Status
Due date
Energy level
Example:
[ ] Build dashboard wireframe
Project: New Earth Command Dashboard
Priority: High
Status: Planned
Energy: Medium
________________________________________
6.3 Task Filters
Filters:
All
Inbox
Today
Planned
In Progress
Blocked
Done
Parked
Additional filters:
By project
By priority
By category
By due date
By energy level
________________________________________
6.4 Task Screen Buttons
Buttons:
+ Add Task
Filter
Sort
Move to Today
Mark Done
Park
Delete
________________________________________
6.5 Task Statuses
Inbox
Planned
Today
In Progress
Blocked
Done
Parked
________________________________________
7. Add / Edit Task Screen
7.1 Screen Purpose
This screen allows the user to create or edit a task.
________________________________________
7.2 Task Fields
Task title
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
7.3 Required Fields for MVP
Required:
Task title
Status
Optional:
Project
Category
Priority
Due date
Energy level
Notes
This keeps quick task entry simple.
________________________________________
7.4 Task Categories
Build
Design
Research
Business
Learning
Content
Admin
Wellbeing
________________________________________
7.5 Energy Level Options
Low
Medium
High
This helps the app suggest suitable tasks depending on the user’s energy.
________________________________________
7.6 Task Buttons
Save Task
Cancel
Mark Done
Delete Task
________________________________________
8. Daily Planner Screen
8.1 Screen Purpose
The Daily Planner is where the user creates and reviews the day plan.
The Dashboard shows the summary.
The Planner holds the full structure.
________________________________________
8.2 Daily Planner Layout
Recommended layout:
Date Header
Morning Intention
Main Focus
Top 3 Tasks
Time Blocks
Learning Block
Content Block
Business Block
Wellbeing Block
Evening Review
Tomorrow’s Focus
________________________________________
8.3 Daily Planner Fields
Date
Morning intention
Main focus
Top 3 tasks
Time blocks
Learning focus
Content focus
Business focus
Wellbeing action
Evening review
Tomorrow’s possible focus
________________________________________
8.4 Morning Planning Questions
What matters most today?
Which project needs attention?
What are the top 3 tasks?
What should I avoid getting distracted by?
What is one small wellbeing action?
________________________________________
8.5 Evening Review Questions
What moved forward today?
What did I complete?
What did I learn?
What blocked me?
What needs to carry forward?
What is tomorrow’s likely focus?
________________________________________
8.6 Daily Planner Buttons
Create Today’s Plan
Choose Top 3 Tasks
Add Time Block
Start Evening Review
Carry Forward Tasks
Save Review
________________________________________
9. Journal Screen
9.1 Screen Purpose
The Journal captures the daily build history of New Earth.
This is one of the most valuable parts of the app because it can feed:
LinkedIn posts
Website journal entries
Book chapters
Documentation
Decision logs
Progress reviews
________________________________________
9.2 Journal List Layout
Each journal entry should show:
Date
Title
Related project
Category
Short preview
Tags
Example:
1 May 2026
Started New Earth Command Dashboard FSD

Project:
New Earth Command Dashboard

Category:
Build Log
________________________________________
9.3 Journal Filters
All Entries
Build Logs
Learning Notes
Project Updates
Founder Journey
Problem / Fix
Decision Logs
Content Seeds
Reflections
________________________________________
9.4 Journal Buttons
+ Add Entry
Open Entry
Filter
Search
Convert to Content Idea
Create Task from Entry
________________________________________
10. Journal Entry Screen
10.1 Screen Purpose
This screen is used to write or edit one journal entry.
________________________________________
10.2 Journal Entry Fields
Date
Title
Related project
Category
What I worked on
What I built
What I learned
Problems encountered
Decisions made
Next actions
Possible LinkedIn post
Possible website journal entry
Tags
________________________________________
10.3 Journal Categories
Build Log
Learning Note
Project Update
Founder Journey
Problem / Fix
Decision Log
Content Seed
Reflection
________________________________________
10.4 Journal Entry Buttons
Save Entry
Create Task
Create Content Idea
Link to Project
Delete Entry
________________________________________
11. Learning Screen
11.1 Screen Purpose
The Learning Screen tracks skills and study areas that support New Earth.
The key rule is:
Learning should connect to building.
________________________________________
11.2 Learning List Layout
Each learning item should show:
Topic
Related project
Status
Confidence level
Next step
Example:
Flutter Navigation
Project: New Earth Command Dashboard
Status: Learning
Confidence: Medium
Next Step: Build bottom navigation
________________________________________
11.3 Learning Fields
Topic
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
11.4 Learning Statuses
To Learn
Learning
Practicing
Applied
Paused
Archived
________________________________________
11.5 Learning Buttons
+ Add Learning Topic
Add Resource
Add Note
Create Practice Task
Mark Applied
Archive
________________________________________
12. Content Planner Screen
12.1 Screen Purpose
The Content Planner helps turn the New Earth build journey into public communication.
It should help manage:
LinkedIn posts
Website journal updates
Videos
Image ideas
Book content
Founder journey posts
MicroGrow updates
New Earth philosophy posts
________________________________________
12.2 Content List Layout
Each content item should show:
Title
Platform
Related project
Content type
Status
Publish date
Image needed
Example:
Building the New Earth Command Dashboard
Platform: LinkedIn
Type: Build-in-public update
Status: Drafting
Image Needed: Yes
________________________________________
12.3 Content Fields
Title
Platform
Related project
Content type
Status
Draft text
Image needed
Publish date
Published link
Notes
________________________________________
12.4 Platforms
LinkedIn
Website
YouTube
Book
Newsletter
Other
________________________________________
12.5 Content Statuses
Idea
Drafting
Ready
Published
Archived
________________________________________
12.6 Content Buttons
+ Add Content Idea
Create Draft
Link Journal Entry
Mark Image Needed
Mark Ready
Mark Published
Archive
________________________________________
13. Business Hub Screen
13.1 Screen Purpose
The Business Hub manages practical funding, money, partnership, and opportunity actions.
It keeps New Earth financially grounded.
________________________________________
13.2 Business List Layout
Each business item should show:
Opportunity name
Type
Status
Deadline
Next action
Follow-up date
Example:
AI Architect Role
Type: Job
Status: Preparing
Deadline: Not set
Next Action: Finalise CV
________________________________________
13.3 Business Fields
Opportunity name
Type
Company / contact
Status
Deadline
Next action
Related project
Notes
Link / document reference
Follow-up date
________________________________________
13.4 Opportunity Types
Job
Contract
Grant
Partnership
Client
Funding
Mentor
Investor
Collaboration
Business Idea
________________________________________
13.5 Business Statuses
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
13.6 Business Buttons
+ Add Opportunity
Set Follow-Up
Add Notes
Mark Applied
Mark Follow-Up Needed
Archive
________________________________________
14. Wellbeing Screen
14.1 Screen Purpose
The Wellbeing Screen helps the user build sustainably.
The app should not push endless productivity.
It should support balance, energy, and long-term consistency.
________________________________________
14.2 Wellbeing Layout
Recommended layout:
Today’s Check-In
Energy
Mood
Stress
Sleep
Movement
Food / Water
Reflection
Recent Trend
Suggested Workload
________________________________________
14.3 Wellbeing Fields
Date
Energy level
Mood
Sleep quality
Stress level
Movement
Food / water
Meditation / reflection
Notes
________________________________________
14.4 Rating Options
Simple rating:
Low
Medium
High
Optional mood labels:
Focused
Calm
Scattered
Tired
Motivated
Stressed
Inspired
________________________________________
14.5 Wellbeing Buttons
Save Check-In
Add Reflection
View Trend
Adjust Today’s Plan
________________________________________
14.6 Wellbeing Logic
If energy is low, the app should suggest:
Choose 1 main task instead of 3.
Do a small build action.
Avoid heavy context switching.
Move non-urgent work to parked.
Add rest or recovery time.
If energy is high, the app can suggest:
Tackle a high-focus build task.
Work on coding or system design.
Record progress before switching tasks.
________________________________________
15. More Screen
15.1 Screen Purpose
The More Screen keeps the bottom navigation clean.
On mobile, the bottom navigation should not show too many tabs.
________________________________________
15.2 More Screen Items
The More Screen should contain links to:
Journal
Learning
Content
Business
Wellbeing
Settings
Each item should have:
Icon
Title
Short description
Example:
Journal
Capture build progress and reflections.

Learning
Track skills needed to build New Earth.

Business
Manage funding, jobs, partnerships, and opportunities.
________________________________________
16. Settings Screen
16.1 Screen Purpose
The Settings Screen allows basic app configuration.
________________________________________
16.2 MVP Settings
Project categories
Task categories
Priority labels
Status labels
Theme
Backup / export
Data reset
App information
________________________________________
16.3 Future Settings
AI assistant settings
Calendar connection
Cloud sync
GitHub integration
Website integration
Notification preferences
Security settings
User profile
________________________________________
17. Global App Elements
These elements should be available across the app.
17.1 Bottom Navigation
Mobile tabs:
Dashboard
Projects
Tasks
Planner
More
________________________________________
17.2 Floating Quick Capture Button
Recommended icon:
+
Recommended label:
Quick Capture
Available from:
Dashboard
Projects
Tasks
Planner
Journal
Learning
Content
Business
________________________________________
17.3 Search
Search should eventually work across:
Tasks
Projects
Journal
Learning
Content
Business
For MVP, search can start in Journal and Tasks only.
________________________________________
17.4 Empty States
Every screen should have a helpful empty state.
Example:
No tasks yet.
Add your first task to start building New Earth today.
Example:
No journal entries yet.
Capture today’s progress so the journey is not lost.
________________________________________
18. MVP Screen Priority
Build the screens in this order:
1. Dashboard Screen
2. Projects Screen
3. Project Detail Screen
4. Tasks Screen
5. Add / Edit Task Screen
6. Daily Planner Screen
7. Journal Screen
8. Journal Entry Screen
9. Learning Screen
10. Content Planner Screen
11. Business Hub Screen
12. Wellbeing Screen
13. More Screen
14. Settings Screen
________________________________________
19. First Version Screen Rule
For V0.1, every screen should follow this design rule:
Show only what helps the user take the next useful action.
Do not overload screens with advanced features too early.
________________________________________
20. Part 4 Summary
The MVP app should be built around a calm daily flow:
Open Dashboard
Choose focus
Pick top 3 tasks
Work from Projects or Tasks
Capture progress in Journal
Review the day
Plan the next step
The most important screens are:
Dashboard
Projects
Tasks
Daily Planner
Journal
The supporting screens are:
Learning
Content
Business
Wellbeing
Settings
The goal is not to build another complex productivity system.
The goal is to build a New Earth command centre that makes the mission easier to manage every day.
