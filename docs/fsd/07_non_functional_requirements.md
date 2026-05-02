# Non Functional Requirements

FSD Part 7 — Non-Functional Requirements, UX Principles & Design Rules
Project Name
New Earth Command Dashboard
Document Version
V0.1 — Non-Functional Requirements and UX Draft
________________________________________
1. Purpose of This Section
This section defines how the app should behave, feel, perform, and support the user.
Functional requirements describe what the app does.
Non-functional requirements describe how well the app does it.
This includes:
Performance
Usability
Offline access
Privacy
Security
Reliability
Accessibility
Visual design
Emotional experience
Simplicity
Scalability
The New Earth Command Dashboard should not only work technically. It should feel calm, focused, supportive, and aligned with the New Earth mission.
________________________________________
2. Core Non-Functional Principle
The app should follow this principle:
The dashboard must reduce overwhelm, not create more of it.
Every screen, button, feature, and notification should support clarity.
If a feature makes the app feel heavier, more confusing, or more distracting, it should be simplified or delayed.
________________________________________
3. Non-Functional Requirement Groups
The non-functional requirements are grouped into:
1. Usability Requirements
2. Performance Requirements
3. Offline Requirements
4. Reliability Requirements
5. Privacy Requirements
6. Security Requirements
7. Accessibility Requirements
8. Visual Design Requirements
9. Data Requirements
10. Scalability Requirements
11. Maintainability Requirements
12. Emotional UX Requirements
13. Future AI Requirements
________________________________________
4. Usability Requirements
NFR-USE-001 — Simple Daily Start
Priority: MUST
The user must be able to open the app and understand the day’s focus within a few seconds.
The Dashboard should clearly show:
Today’s main focus
Top 3 tasks
Active project
Wellbeing state
Quick capture
The user should not need to search through multiple screens to know what matters today.
________________________________________
NFR-USE-002 — Minimal Morning Friction
Priority: MUST
Creating a daily plan should be quick.
The morning planning flow should not feel like filling in a large form.
Minimum daily plan fields:
Main focus
Top 3 tasks
Optional intention
Optional wellbeing check
Everything else should be optional.
________________________________________
NFR-USE-003 — Fast Task Capture
Priority: MUST
The user must be able to capture a task or idea quickly.
The Quick Capture flow should take no more than a few taps.
Required input should be minimal:
Title or note
Optional fields can be added later.
________________________________________
NFR-USE-004 — Calm Navigation
Priority: MUST
Navigation should be predictable and simple.
The user should always know:
Where they are
How to return to the Dashboard
How to add a task
How to view projects
How to review the day
________________________________________
NFR-USE-005 — No Overloaded Screens
Priority: MUST
Screens should not display too much at once.
Each screen should focus on the next useful action.
For example:
Dashboard = today’s clarity
Projects = project overview
Tasks = practical actions
Planner = daily structure
Journal = progress capture
________________________________________
NFR-USE-006 — Beginner-Friendly Wording
Priority: MUST
The app should use plain, human wording.
Avoid overly technical or corporate language.
Use labels such as:
Today’s Focus
Top 3 Tasks
Next Action
What moved forward?
Park for Later
Quick Capture
Avoid labels such as:
Operational KPI Cluster
Task Execution Matrix
Performance Objective Stack
________________________________________
5. Performance Requirements
NFR-PERF-001 — Fast App Launch
Priority: MUST
The app should open quickly and load the Dashboard without delay.
Target:
Dashboard visible within 2 seconds on a normal device.
________________________________________
NFR-PERF-002 — Fast Local Actions
Priority: MUST
Common actions should feel instant.
Examples:
Add task
Mark task done
Open project
Save journal entry
Set daily focus
Target:
Most local actions should complete in under 1 second.
________________________________________
NFR-PERF-003 — Smooth Scrolling
Priority: SHOULD
Lists should scroll smoothly.
This applies to:
Tasks
Projects
Journal entries
Learning items
Content items
Business opportunities
________________________________________
NFR-PERF-004 — Local-First Speed
Priority: MUST
Because the MVP stores data locally, the app should not depend on internet access for normal use.
The user should be able to use the core app even with no connection.
________________________________________
6. Offline Requirements
NFR-OFF-001 — Offline-First MVP
Priority: MUST
The MVP must work offline.
The user must be able to:
Open the app
View dashboard
Create tasks
Edit tasks
View projects
Create journal entries
Create daily plans
Create learning items
Create content ideas
Create business items
Complete wellbeing check-ins
without internet access.
________________________________________
NFR-OFF-002 — No Login Required for MVP
Priority: MUST
The first version should not require login.
The app should work as a private local tool.
This reduces friction and makes the first build easier.
________________________________________
NFR-OFF-003 — Future Sync Ready
Priority: SHOULD
Even though the MVP is local-first, the data structure should be designed so cloud sync can be added later.
This means each record should have:
Unique ID
created_at
updated_at
is_archived
________________________________________
7. Reliability Requirements
NFR-REL-001 — Data Must Save Correctly
Priority: MUST
When the user saves a task, project, journal entry, or plan, the data must persist.
The user should not lose data after closing and reopening the app.
________________________________________
NFR-REL-002 — Avoid Accidental Data Loss
Priority: MUST
The app should avoid destructive actions.
For V0.1:
Archive should be preferred over delete.
Delete should require confirmation.
________________________________________
NFR-REL-003 — Safe Editing
Priority: SHOULD
If the user edits a long journal entry or content draft, the app should reduce the risk of losing unsaved work.
Future improvement:
Autosave drafts
Unsaved changes warning
________________________________________
NFR-REL-004 — Stable DailyPlan Creation
Priority: MUST
The app must not create duplicate DailyPlan records for the same date.
Rule:
One DailyPlan per date.
________________________________________
8. Privacy Requirements
NFR-PRIV-001 — Private by Default
Priority: MUST
All user data should be private by default.
The app will contain personal notes, business plans, project plans, wellbeing check-ins, and founder journey reflections.
Nothing should be shared publicly unless the user manually chooses to export or publish it.
________________________________________
NFR-PRIV-002 — Local Storage for MVP
Priority: MUST
For V0.1, all data should be stored locally on the device.
No cloud account should be required.
________________________________________
NFR-PRIV-003 — Clear Future Cloud Consent
Priority: SHOULD
If cloud sync is added later, the app must clearly explain:
What data is synced
Where it is stored
What account is used
How to disable sync
How to delete cloud data
________________________________________
NFR-PRIV-004 — Wellbeing Data Sensitivity
Priority: MUST
Wellbeing data should be treated as sensitive personal information.
It should not be used for public content suggestions unless the user explicitly chooses to include it.
________________________________________
9. Security Requirements
NFR-SEC-001 — Secure Local Data Direction
Priority: SHOULD
For early MVP, normal local database storage is acceptable.
For later versions, consider:
Encrypted local database
Device lock integration
Optional app PIN
Backup encryption
________________________________________
NFR-SEC-002 — No Public Exposure
Priority: MUST
The MVP must not expose user data to a server, API, or public website.
________________________________________
NFR-SEC-003 — Future Authentication
Priority: COULD
If cloud sync or multi-device use is added later, authentication will be needed.
Possible options:
Email login
Google login
Apple login
Supabase auth
Firebase auth
Local-only PIN
________________________________________
NFR-SEC-004 — Safe Export
Priority: SHOULD
When export is added, the app should warn the user that exported files may contain private information.
Possible export types:
JSON
CSV
Markdown
PDF
________________________________________
10. Accessibility Requirements
NFR-ACC-001 — Readable Text
Priority: MUST
Text should be clear and easy to read.
The app should avoid tiny fonts.
Recommended minimums:
Body text: 14–16px equivalent
Card titles: 16–20px equivalent
Main headings: 22px+
________________________________________
NFR-ACC-002 — Clear Contrast
Priority: MUST
Text should have enough contrast against the background.
The app should avoid pale text on pale backgrounds.
________________________________________
NFR-ACC-003 — Large Tap Targets
Priority: MUST
Buttons and interactive elements should be easy to tap on mobile.
Recommended minimum tap target:
44px by 44px
________________________________________
NFR-ACC-004 — Simple Icons with Labels
Priority: SHOULD
Icons should usually include text labels, especially in the MVP.
Example:
+ Task
+ Journal
+ Capture
Avoid relying on icons alone.
________________________________________
NFR-ACC-005 — Support Light and Dark Mode
Priority: SHOULD
The app should eventually support:
Light mode
Dark mode
System mode
For MVP, one clean theme is enough, but the code should allow theming later.
________________________________________
11. Visual Design Requirements
NFR-VIS-001 — Calm Command Centre Feel
Priority: MUST
The app should feel calm, grounded, and focused.
It should not feel like a noisy corporate productivity app.
The visual direction should be:
Clean
Spacious
Soft
Natural
Focused
Purposeful
________________________________________
NFR-VIS-002 — New Earth Identity
Priority: SHOULD
The design should subtly reflect the New Earth identity.
Possible design cues:
Earth-inspired colour palette
Soft green accents
Natural tones
Rounded cards
Calm backgrounds
Light, spacious layout
Simple iconography
Avoid making the interface too decorative.
The app is a working dashboard first.
________________________________________
NFR-VIS-003 — Card-Based Layout
Priority: MUST
The Dashboard should use clear cards.
Recommended cards:
Today’s Focus
Top 3 Tasks
Active Projects
Learning Focus
Content Focus
Business Reminder
Wellbeing
Quick Capture
Evening Review
Cards should make the app easier to scan.
________________________________________
NFR-VIS-004 — Progress Indicators
Priority: SHOULD
Project cards should show simple progress indicators.
Examples:
Progress bar
Percentage
Status badge
________________________________________
NFR-VIS-005 — Status Badges
Priority: SHOULD
Use clear badges for statuses.
Examples:
Active
Blocked
Today
Done
Parked
Learning
Published
Follow-up Needed
This helps the user scan quickly.
________________________________________
12. Data Requirements
NFR-DATA-001 — Structured Data
Priority: MUST
The data should be structured clearly enough to support future features.
This means using proper tables/entities for:
Projects
Tasks
DailyPlans
JournalEntries
LearningItems
ContentItems
BusinessOpportunities
WellbeingCheckIns
InboxItems
Settings
________________________________________
NFR-DATA-002 — Unique Identifiers
Priority: MUST
Every record must have a unique ID.
This supports future sync, linking, export, and AI features.
________________________________________
NFR-DATA-003 — Timestamp Tracking
Priority: MUST
Every important record should track:
created_at
updated_at
Some records should also track:
completed_at
archived_at
processed_at
________________________________________
NFR-DATA-004 — Export-Ready Structure
Priority: SHOULD
The data model should be designed so future export is easy.
Useful export formats:
Markdown for journal entries
CSV for task lists
JSON for full backup
PDF for reports
________________________________________
13. Scalability Requirements
NFR-SCALE-001 — Start Simple, Grow Later
Priority: MUST
The MVP should be small enough to build and use quickly.
Do not overbuild.
The app should start as:
Personal local dashboard
Single-user
Offline-first
Manual planning
Manual progress tracking
Then later expand into:
AI-assisted dashboard
Cloud sync
Multi-device
Calendar integration
GitHub integration
MicroGrow system integration
________________________________________
NFR-SCALE-002 — Modular Code Structure
Priority: SHOULD
The Flutter app should be organised by feature/module.
Suggested structure:
features/dashboard
features/projects
features/tasks
features/planner
features/journal
features/learning
features/content
features/business
features/wellbeing
features/settings
This keeps the code easier to maintain.
________________________________________
NFR-SCALE-003 — Future Integration Ready
Priority: SHOULD
The app should be designed so later integrations are possible.
Future integrations:
Calendar
GitHub
WordPress
LinkedIn workflow
MicroGrow device data
AI assistant
Cloud database
________________________________________
14. Maintainability Requirements
NFR-MAINT-001 — Clear Code Organisation
Priority: SHOULD
The codebase should be easy to understand.
Use consistent naming for:
Screens
Models
Repositories
Services
Widgets
State providers
Database tables
Example:
ProjectModel
TaskModel
DailyPlanModel
ProjectRepository
TaskRepository
DashboardScreen
TaskCard
________________________________________
NFR-MAINT-002 — Reusable Widgets
Priority: SHOULD
Common UI elements should be reusable.
Examples:
ProjectCard
TaskCard
StatusBadge
PriorityBadge
DashboardCard
EmptyState
QuickCaptureButton
SectionHeader
________________________________________
NFR-MAINT-003 — Separate UI from Data Logic
Priority: SHOULD
The app should not mix database logic directly into UI widgets.
Better structure:
UI Screen
State Provider / Controller
Repository
Database
This makes the app easier to test and expand.
________________________________________
NFR-MAINT-004 — Document Key Decisions
Priority: SHOULD
Important technical decisions should be recorded.
Examples:
Why Drift was chosen
Why local-first was chosen
Why top 3 task limit exists
Why archive is preferred over delete
These can later become architecture decision records.
________________________________________
15. Emotional UX Requirements
This app is not only for productivity.
It should support the emotional reality of building a big vision.
NFR-EMO-001 — Reduce Overwhelm
Priority: MUST
The app should help the user feel:
Clearer
Calmer
More focused
Less scattered
More in control
It should not make the user feel behind, guilty, or overloaded.
________________________________________
NFR-EMO-002 — Encourage Small Progress
Priority: MUST
The app should treat small progress as meaningful.
Example messages:
One clear step moves the mission forward.
Small build actions compound over time.
Capture the progress before it is lost.
________________________________________
NFR-EMO-003 — Support Low-Energy Days
Priority: SHOULD
The app should support days when energy is low.
If energy is low, it should suggest:
Choose one task.
Park non-urgent work.
Capture notes instead of forcing deep work.
Do a lighter planning/review session.
________________________________________
NFR-EMO-004 — Avoid Shame-Based Productivity
Priority: MUST
The app should not use guilt-based language.
Avoid:
You failed.
You are behind.
You missed your target.
You did not do enough.
Use:
What can move forward next?
What needs carrying forward?
What did today teach you?
What is the next useful step?
________________________________________
NFR-EMO-005 — Mission Alignment
Priority: SHOULD
The app should remind the user that daily tasks connect to the wider New Earth mission.
Example prompt:
How does this task support New Earth?
Future version:
Which Blueprint pillar does this support?
________________________________________
16. UX Principles
These are the design principles for the app.
UX Principle 1 — Clarity First
Every screen should answer:
What is this screen for?
What matters here?
What is the next action?
________________________________________
UX Principle 2 — Fewer Choices, Better Focus
The app should avoid overwhelming the user with too many choices at once.
Example:
Show Top 3 tasks, not 50 tasks.
Show active projects first, not archived projects.
Show next action, not every possible action.
________________________________________
UX Principle 3 — Capture Quickly, Organise Later
The user should be able to capture ideas fast.
The Inbox exists so ideas can be saved without interrupting deep work.
________________________________________
UX Principle 4 — Project-Centred Thinking
Most work should connect back to a project.
This helps the user understand where their energy is going.
________________________________________
UX Principle 5 — Daily Rhythm
The app should support a simple rhythm:
Morning plan
Focused work
Quick capture
Progress journal
Evening review
Carry forward
________________________________________
UX Principle 6 — Build History Matters
The app should treat the journal as important.
The build journey can become:
Website updates
LinkedIn posts
Book content
Documentation
Lessons learned
Future strategy
________________________________________
UX Principle 7 — Balance Is Part of the System
Wellbeing is not separate from productivity.
The app should help the user build without burning out.
________________________________________
17. Design Rules
Design Rule 1 — Dashboard Must Stay Clean
The Dashboard must not become a dumping ground.
Only show:
Today’s focus
Top 3 tasks
Active signals
Helpful shortcuts
Detailed lists belong on other screens.
________________________________________
Design Rule 2 — Top 3 Means Top 3
The app should protect the user from overload.
Do not allow 10 “priority” tasks.
The power of the system comes from choosing what matters most.
________________________________________
Design Rule 3 — Use “Parked” Instead of “Failed”
Unfinished or non-urgent work should be parked or carried forward.
This keeps the language constructive.
________________________________________
Design Rule 4 — Every Project Needs a Next Action
A project should not just sit as an idea.
Each active project should have:
Current milestone
Next action
Status
________________________________________
Design Rule 5 — The Journal Should Be Easy to Start
A journal entry should not require a full essay.
The user should be able to write a simple entry like:
Today I worked on the dashboard FSD and finished the data model.
Then add more detail if needed.
________________________________________
Design Rule 6 — Wellbeing Should Influence Workload
The app should not ignore the user’s energy.
Low energy should produce a lighter plan.
High energy can support deep work.
________________________________________
Design Rule 7 — Manual First, AI Later
Do not depend on AI for the MVP.
The app must be useful manually first.
AI should later enhance the system, not replace the core structure.
________________________________________
18. Suggested Visual Style
18.1 Overall Feel
Calm
Focused
Natural
Clean
Purposeful
Founder-friendly
Mission-led
________________________________________
18.2 Colour Direction
Possible palette direction:
Soft green
Earth brown
Warm off-white
Deep charcoal
Muted gold
Sky blue accents
The colours should support clarity, not distract.
________________________________________
18.3 Component Style
Recommended UI components:
Rounded cards
Soft shadows
Simple icons
Status badges
Progress bars
Clean forms
Large buttons
Spacious layouts
________________________________________
18.4 Typography Direction
Typography should feel modern and readable.
Use:
Clear headings
Readable body text
Strong card titles
Good spacing
Avoid overly decorative fonts inside the app.
________________________________________
19. Suggested Dashboard Layout Feel
Example dashboard structure:
------------------------------------------------
New Earth Command Dashboard
Friday 1 May 2026

What moves the mission forward today?
------------------------------------------------

[ Today’s Focus ]
Build the Dashboard MVP

[ Top 3 Tasks ]
□ Create Flutter app shell
□ Add project cards
□ Create task model

[ Active Projects ]
MicroGrow
New Earth Website
Dashboard App

[ Quick Capture ]
+ Add task, note, idea, content seed

[ Wellbeing ]
Energy: Medium
Suggested workload: Normal

[ Evening Review ]
Start Review
------------------------------------------------
________________________________________
20. Error Handling Requirements
NFR-ERR-001 — Clear Error Messages
Priority: SHOULD
Error messages should explain the issue in plain language.
Example:
This task could not be saved. Please try again.
Avoid:
Database exception 4392 failed transaction object null.
________________________________________
NFR-ERR-002 — Helpful Empty States
Priority: MUST
Empty screens should guide the user.
Examples:
No tasks yet. Add your first task to start moving New Earth forward.

No journal entries yet. Capture today’s progress so the journey is not lost.

No content ideas yet. Turn a build update into your first post idea.
________________________________________
NFR-ERR-003 — Confirm Risky Actions
Priority: MUST
Actions that remove or archive data should ask for confirmation.
Example:
Archive this task?
You can restore it later.
________________________________________
21. Future AI Experience Requirements
AI should feel like a supportive planning assistant, not a controlling manager.
NFR-AI-001 — AI Should Suggest, Not Command
Priority: COULD
AI outputs should be framed as suggestions.
Example:
Suggested focus for today:
MicroGrow Field Scanner

Reason:
It has active tasks and recent progress.
________________________________________
NFR-AI-002 — AI Should Explain Why
Priority: COULD
When AI suggests a plan, it should explain its reasoning in simple terms.
Example:
I chose this because it connects to your active project, has a clear next action, and matches your current energy level.
________________________________________
NFR-AI-003 — AI Should Respect Wellbeing
Priority: COULD
AI should take wellbeing check-ins into account.
Example:
Energy is low today, so I suggest one build task and one light admin task.
________________________________________
NFR-AI-004 — AI Should Use Project Context
Priority: COULD
Future AI should use:
Projects
Tasks
Journal entries
Learning items
Content items
Business opportunities
Wellbeing check-ins
to make useful suggestions.
________________________________________
22. MVP Non-Functional Requirement Summary
For V0.1, the most important non-functional requirements are:
1. The app must feel simple and calm.
2. The Dashboard must load quickly.
3. The app must work offline.
4. Data must persist locally.
5. No login should be required.
6. The user must not lose work easily.
7. Screens must not be overloaded.
8. Quick Capture must be fast.
9. The Top 3 system must protect focus.
10. The app should support low-energy days.
11. The app must be private by default.
12. The visual design should support the New Earth identity.
________________________________________
23. Part 7 Summary
The New Earth Command Dashboard should not feel like another demanding productivity app.
It should feel like a calm command centre that helps Peter:
See clearly
Choose wisely
Build steadily
Capture progress
Stay aligned
Protect energy
Move New Earth forward
The key design truth is:
The app succeeds when Peter feels less lost, less scattered, and more able to take the next useful step.
