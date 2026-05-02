# User Roles and Navigation

FSD Part 3 — User Roles, Core Modules & App Navigation Structure
Project Name
New Earth Command Dashboard
Document Version
V0.1 — User Roles and Navigation Draft
________________________________________
1. Purpose of This Section
This section defines:
1. Who will use the app
2. What the main app modules are
3. How the app is structured
4. How the user moves between screens
5. What the first navigation layout should look like
The aim is to keep the app simple, clear, and easy to use every day.
________________________________________
2. User Roles
For Version 0.1, the app only needs one main user role.
2.1 Primary User — Founder / Builder
The primary user is:
Peter Ellis
Founder of New Earth Projects
Builder of MicroGrow
Developer of New Earth Living
Creator of the New Earth website and awareness platform
This user needs to manage:
Projects
Tasks
Learning
Business actions
Content
Build logs
Wellbeing
Vision alignment
The app should be designed around one person building a large mission from the ground up.
________________________________________
3. Future User Roles
Future versions may support more roles.
These are not needed for V0.1, but should be considered later.
3.1 Collaborator
A collaborator could help with:
Design
Development
Writing
Marketing
Testing
Community work
Possible permissions:
View selected projects
Add comments
Complete assigned tasks
Upload files
Add notes
________________________________________
3.2 Mentor / Advisor
A mentor or advisor could review progress and give guidance.
Possible access:
View roadmap
View project summaries
View business plans
View selected journal entries
Add feedback
________________________________________
3.3 Community Member
A future community member could interact with public-facing New Earth tasks, updates, or learning paths.
Possible access:
View public project updates
Join learning challenges
Follow project progress
Submit ideas
Join local actions
________________________________________
3.4 Admin
If the app grows beyond personal use, an admin role may manage:
Users
Settings
Permissions
Backups
System configuration
Project templates
________________________________________
4. Version 0.1 Role Decision
For the MVP, the app should use:
Single-user mode only
No login required at first
Local-first storage
Private personal dashboard
This keeps the first build simple.
Login, cloud sync, user accounts, and permissions can come later.
________________________________________
5. Core Modules
The app should be divided into clear modules.
Each module represents a major part of the New Earth working day.
The core MVP modules are:
1. Dashboard
2. Projects
3. Tasks
4. Daily Planner
5. Journal
6. Learning
7. Content
8. Business
9. Wellbeing
10. Settings
________________________________________
6. Module 1 — Dashboard
Purpose
The Dashboard is the main home screen.
It should show the most important information for today.
Main Content
Today’s date
Today’s main focus
Top 3 priority tasks
Active projects
Learning focus
Content focus
Business reminder
Wellbeing status
Quick capture button
End-of-day review shortcut
Main Actions
Set today’s focus
Choose top 3 tasks
Mark task as done
Add quick note
Open active project
Start daily review
Design Principle
The Dashboard should be calm, simple, and not overloaded.
It should feel like a command centre, not a messy task list.
________________________________________
7. Module 2 — Projects
Purpose
The Projects module stores and tracks all active New Earth projects.
Initial Projects
MicroGrow
MicroGrow Field Scanner
New Earth Website
New Earth Living App
Smart Growing Systems Book
LinkedIn / Public Awareness
Business & Funding
Learning & Skills
Future Ideas
Project Page Content
Each project should show:
Project name
Project description
Vision
Current status
Priority
Progress percentage
Current milestone
Next action
Active tasks
Blocked tasks
Linked notes
Linked journal entries
Main Actions
Create project
Edit project
Add project task
Update milestone
Update progress
Add note
View project journal
Park project
Project Statuses
Idea
Active
Paused
Blocked
Completed
Archived
________________________________________
8. Module 3 — Tasks
Purpose
The Tasks module manages all practical actions.
Task Fields
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
Created date
Completed date
Task Statuses
Inbox
Planned
Today
In Progress
Blocked
Done
Parked
Task Priorities
High
Medium
Low
Someday
Task Categories
Build
Design
Research
Business
Learning
Content
Admin
Wellbeing
Main Actions
Add task
Edit task
Assign task to project
Move task to today
Mark task done
Park task
Delete task
Filter by project
Filter by category
Filter by status
________________________________________
9. Module 4 — Daily Planner
Purpose
The Daily Planner helps structure each working day.
It is slightly deeper than the Dashboard.
The Dashboard shows the summary.
The Daily Planner is where the day is planned and reviewed.
Daily Planner Fields
Date
Morning intention
Main focus
Top 3 tasks
Time blocks
Learning focus
Content focus
Business focus
Wellbeing focus
Evening review
Tomorrow’s possible focus
Main Actions
Create daily plan
Select top 3 tasks
Add time block
Add learning block
Add content block
Complete evening review
Carry unfinished tasks forward
Daily Planning Rule
The Daily Planner should encourage focus.
The user should not be pushed to overload the day.
A good day plan may only contain:
1 main focus
3 priority tasks
1 learning block
1 content action
1 wellbeing action
________________________________________
10. Module 5 — Journal
Purpose
The Journal captures the journey of building New Earth.
This module is important because the build history can later become:
Website journal posts
LinkedIn updates
Book content
Project documentation
Lessons learned
Progress reviews
Journal Entry Fields
Date
Title
Related project
What I worked on
What I built
What I learned
Problems encountered
Decisions made
Next actions
Possible LinkedIn post
Possible website journal entry
Tags
Main Actions
Create journal entry
Link entry to project
Link entry to task
Mark entry as content idea
Search journal
View entries by project
View entries by date
Journal Categories
Build Log
Learning Note
Project Update
Founder Journey
Problem / Fix
Decision Log
Content Seed
Reflection
________________________________________
11. Module 6 — Learning
Purpose
The Learning module tracks skills and knowledge needed to build New Earth.
It prevents learning from becoming random by linking it to projects.
Learning Item Fields
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
Learning Statuses
To Learn
Learning
Practicing
Applied
Paused
Archived
Initial Learning Areas
Flutter
Dart
ESP32
STM32
WordPress
Cybersecurity
AI
Electronics
Product design
Business
Marketing
Writing
Main Actions
Add learning topic
Link topic to project
Add notes
Add resource
Create practice task
Mark as applied
Review learning progress
________________________________________
12. Module 7 — Content
Purpose
The Content module helps turn progress into public awareness.
It supports:
LinkedIn posts
Website journal entries
Videos
Images
Book sections
Founder journey updates
MicroGrow updates
New Earth philosophy posts
Content Item Fields
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
Content Statuses
Idea
Drafting
Ready
Published
Archived
Content Types
LinkedIn Post
Website Journal
Video Script
Image Prompt
Book Section
Project Update
Founder Journey
Technical Update
Awareness Post
Main Actions
Add content idea
Create draft
Link to journal entry
Mark image needed
Schedule publish date
Mark as published
Archive content
________________________________________
13. Module 8 — Business
Purpose
The Business module manages funding, income, outreach, and opportunities.
It helps make New Earth financially sustainable.
Business Areas
Job applications
CV versions
Funding opportunities
Grant ideas
Partnership contacts
Business offers
Revenue streams
Follow-ups
Meetings
Potential clients
Business Item Fields
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
Opportunity Types
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
Business Statuses
Researching
Preparing
Applied
Waiting
Follow-up Needed
Accepted
Rejected
Paused
Archived
Main Actions
Add opportunity
Set deadline
Set follow-up
Link CV or document
Track application status
Add meeting notes
Mark outcome
________________________________________
14. Module 9 — Wellbeing
Purpose
The Wellbeing module supports sustainable building.
New Earth should not be built through burnout.
The app should help the user check energy, focus, and balance.
Wellbeing Fields
Date
Energy level
Mood
Sleep quality
Stress level
Movement
Food / water
Meditation / reflection
Notes
Simple Rating Options
Low
Medium
High
Main Actions
Add daily check-in
View recent wellbeing trend
Add reflection
Link wellbeing to daily review
Adjust workload based on energy
Wellbeing Rule
If energy is low, the app should encourage a lighter plan.
Example:
Choose 1 main task instead of 3.
Focus on small progress.
Park non-urgent work.
________________________________________
15. Module 10 — Settings
Purpose
The Settings module allows the user to configure the app.
Settings Areas
Project categories
Task categories
Priority labels
Status labels
Theme
Backup / export
Data reset
App info
Future Settings
AI settings
Calendar connection
Cloud sync
Notification preferences
GitHub connection
Website connection
User profile
Security settings
________________________________________
16. Main Navigation Structure
The MVP should use simple bottom navigation or side navigation.
For mobile, use bottom navigation.
For desktop/tablet, use side navigation.
________________________________________
16.1 Mobile Navigation
Recommended bottom tabs:
Dashboard
Projects
Tasks
Planner
More
The More tab opens:
Journal
Learning
Content
Business
Wellbeing
Settings
This avoids putting too many icons across the bottom of the screen.
________________________________________
16.2 Desktop / Tablet Navigation
Recommended side menu:
Dashboard
Projects
Tasks
Daily Planner
Journal
Learning
Content
Business
Wellbeing
Settings
The side menu is better on larger screens because there is more space.
________________________________________
17. Recommended MVP Navigation
For Version 0.1, use this structure:
Bottom Navigation:
1. Dashboard
2. Projects
3. Tasks
4. Planner
5. More
Inside More:
Journal
Learning
Content
Business
Wellbeing
Settings
This is the cleanest starting point.
________________________________________
18. App Flow Map
The basic app flow should work like this:
Open App
   ↓
Dashboard
   ↓
Choose Today’s Focus
   ↓
Select Top 3 Tasks
   ↓
Open Project or Task
   ↓
Work / Add Notes / Complete Task
   ↓
Add Journal Entry
   ↓
Evening Review
   ↓
Plan Tomorrow
________________________________________
19. Screen Relationship Map
Dashboard
 ├── Today’s Tasks → Tasks
 ├── Active Projects → Projects
 ├── Learning Focus → Learning
 ├── Content Focus → Content
 ├── Business Reminder → Business
 ├── Wellbeing Check → Wellbeing
 └── Evening Review → Daily Planner / Journal

Projects
 ├── Project Tasks → Tasks
 ├── Project Notes → Journal
 ├── Project Learning → Learning
 └── Project Content → Content

Tasks
 ├── Linked Project → Projects
 ├── Linked Journal Entry → Journal
 └── Linked Learning Item → Learning

Journal
 ├── Related Project → Projects
 ├── Possible Content → Content
 └── Next Actions → Tasks
________________________________________
20. Quick Capture System
The app should include a quick capture button that is always easy to access.
Purpose
To capture thoughts quickly without disrupting the working flow.
Quick Capture Types
Task
Idea
Journal note
Content idea
Learning note
Business opportunity
Future idea
Quick Capture Flow
Tap Quick Capture
Choose type
Write quick note
Assign project if needed
Save
Return to previous screen
Default Behaviour
If the user does not choose a category, the item should go to:
Inbox
Later, the user can process the inbox and move items to the correct place.
________________________________________
21. Inbox System
The Inbox stores unprocessed items.
Inbox Can Contain
Loose tasks
Ideas
Notes
Content ideas
Learning topics
Business opportunities
Future concepts
Inbox Actions
Convert to task
Convert to journal entry
Convert to content idea
Convert to learning item
Assign to project
Park for later
Delete
Purpose
The Inbox prevents scattered ideas from being lost while keeping the dashboard clean.
________________________________________
22. Project-Centred Design
Most things in the app should be able to connect back to a project.
Examples:
A task belongs to a project.
A journal entry can belong to a project.
A learning topic can support a project.
A content idea can come from a project.
A business opportunity can fund a project.
This makes New Earth easier to understand as a connected system.
________________________________________
23. Vision-Centred Design
Some tasks should also connect to the wider New Earth vision.
Future fields may include:
New Earth pillar
Purpose
Impact
People helped
Long-term value
Alignment score
For V0.1, this can start simple:
Does this support New Earth?
Yes / No / Unsure
Later this can expand into full Blueprint pillar tagging.
________________________________________
24. MVP Navigation Rules
The app should follow these rules:
1. The user should always be able to return to the Dashboard quickly.
2. Adding a task should never take more than a few taps.
3. The Daily Dashboard should not show too much information.
4. Projects should show next action clearly.
5. Tasks should be filterable by project and status.
6. The Journal should link progress back to projects.
7. The app should support focus, not create more noise.
________________________________________
25. First Build Navigation Summary
For the first Flutter build, create these screens:
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
SettingsScreen
Recommended route names:
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
/settings
________________________________________
26. Module Priority for Development
Build the modules in this order:
1. Dashboard
2. Projects
3. Tasks
4. Planner
5. Journal
6. Learning
7. Content
8. Business
9. Wellbeing
10. Settings
Reason:
Dashboard gives the app a home.
Projects give structure.
Tasks create action.
Planner creates daily rhythm.
Journal captures progress.
Learning, content, business, and wellbeing expand the system.
________________________________________
27. Part 3 Summary
The New Earth Command Dashboard should start as a single-user app with a simple module structure.
The core modules are:
Dashboard
Projects
Tasks
Planner
Journal
Learning
Content
Business
Wellbeing
Settings
The navigation should stay simple:
Dashboard
Projects
Tasks
Planner
More
The design should keep one purpose at the centre:
Make New Earth easier to manage and build every day.
