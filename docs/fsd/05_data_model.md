# Data Model

FSD Part 5 — Data Model, Entities, Fields & Relationships
Project Name
New Earth Command Dashboard
Document Version
V0.1 — Data Model Draft
________________________________________
1. Purpose of This Section
This section defines the main data structure of the app.
The data model explains what information the app needs to store and how each part connects together.
For the MVP, the app needs data for:
Projects
Tasks
Daily Plans
Journal Entries
Learning Items
Content Items
Business Opportunities
Wellbeing Check-Ins
Inbox Items
Settings
This section will later help when building the local database in Flutter.
________________________________________
2. Data Model Principle
The app should be built around one main idea:
Most things should connect back to a project.
A task can belong to a project.
A journal entry can belong to a project.
A learning item can support a project.
A content idea can come from a project.
A business opportunity can fund or support a project.
This makes the whole New Earth system easier to understand.
________________________________________
3. Main Entities
The main entities for V0.1 are:
1. Project
2. Task
3. DailyPlan
4. JournalEntry
5. LearningItem
6. ContentItem
7. BusinessOpportunity
8. WellbeingCheckIn
9. InboxItem
10. AppSettings
________________________________________
4. Entity 1 — Project
4.1 Purpose
A Project represents one major area of New Earth.
Examples:
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
4.2 Project Fields
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
4.3 Field Descriptions
Field	Type	Description
project_id	String / UUID	Unique project identifier
name	Text	Project name
short_description	Text	Short summary shown on project cards
long_description	Text	Deeper explanation of the project
vision	Text	Why the project matters
status	Enum	Idea, Active, Paused, Blocked, Completed, Archived
priority	Enum	High, Medium, Low, Someday
progress_percentage	Integer	0 to 100 progress value
current_milestone	Text	Current project milestone
next_action	Text	Next clear action
start_date	Date	When project started
target_date	Date	Optional target date
created_at	DateTime	Date created
updated_at	DateTime	Last updated
notes	Text	General notes
is_archived	Boolean	Hides old projects from active view
________________________________________
4.4 Project Status Options
Idea
Active
Paused
Blocked
Completed
Archived
________________________________________
4.5 Project Priority Options
High
Medium
Low
Someday
________________________________________
5. Entity 2 — Task
5.1 Purpose
A Task represents a specific action that needs doing.
Examples:
Build dashboard wireframe
Write LinkedIn post
Test ESP32 sensor reading
Update New Earth website homepage
Create MicroGrow wiring diagram
Study Flutter navigation
________________________________________
5.2 Task Fields
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
5.3 Field Descriptions
Field	Type	Description
task_id	String / UUID	Unique task identifier
project_id	String / UUID	Linked project, optional
title	Text	Task title
description	Text	More detail about the task
category	Enum	Build, Design, Research, Business, Learning, Content, Admin, Wellbeing
priority	Enum	High, Medium, Low, Someday
status	Enum	Inbox, Planned, Today, In Progress, Blocked, Done, Parked
due_date	Date	Optional due date
energy_level	Enum	Low, Medium, High
estimated_minutes	Integer	Estimated time needed
actual_minutes	Integer	Optional time actually spent
created_at	DateTime	Date created
updated_at	DateTime	Last updated
completed_at	DateTime	Completion date
notes	Text	Task notes
is_top_three	Boolean	Marks task as one of today’s top 3
is_archived	Boolean	Hides old tasks from normal views
________________________________________
5.4 Task Status Options
Inbox
Planned
Today
In Progress
Blocked
Done
Parked
________________________________________
5.5 Task Category Options
Build
Design
Research
Business
Learning
Content
Admin
Wellbeing
________________________________________
5.6 Task Priority Options
High
Medium
Low
Someday
________________________________________
5.7 Energy Level Options
Low
Medium
High
________________________________________
6. Entity 3 — DailyPlan
6.1 Purpose
A DailyPlan represents the user’s plan and review for one day.
It controls the Dashboard view.
Each day should have one DailyPlan record.
________________________________________
6.2 DailyPlan Fields
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
6.3 Field Descriptions
Field	Type	Description
daily_plan_id	String / UUID	Unique daily plan identifier
date	Date	The day this plan belongs to
main_focus	Text	Main focus for the day
focus_reason	Text	Why this focus matters
morning_intention	Text	Morning planning note
top_task_1_id	String / UUID	Linked task
top_task_2_id	String / UUID	Linked task
top_task_3_id	String / UUID	Linked task
learning_focus_id	String / UUID	Linked learning item
content_focus_id	String / UUID	Linked content item
business_focus_id	String / UUID	Linked business item
wellbeing_checkin_id	String / UUID	Linked wellbeing record
evening_review	Text	General end-of-day review
what_moved_forward	Text	Progress summary
what_was_completed	Text	Completed work
what_was_learned	Text	Learning summary
blockers	Text	Problems or blockers
carry_forward_notes	Text	What needs moving forward
tomorrow_focus	Text	Possible next-day focus
created_at	DateTime	Date created
updated_at	DateTime	Last updated
________________________________________
6.4 DailyPlan Rule
There should only be one DailyPlan per date.
If the user opens the dashboard and no plan exists for today, the app should create a blank DailyPlan automatically.
________________________________________
7. Entity 4 — JournalEntry
7.1 Purpose
A JournalEntry stores daily build notes, reflections, decisions, lessons, and progress.
The journal is important because it can later become:
LinkedIn posts
Website journal entries
Book content
Project documentation
Decision logs
Founder journey notes
________________________________________
7.2 JournalEntry Fields
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
7.3 Field Descriptions
Field	Type	Description
journal_entry_id	String / UUID	Unique journal entry ID
project_id	String / UUID	Linked project, optional
task_id	String / UUID	Linked task, optional
date	Date	Entry date
title	Text	Entry title
category	Enum	Build Log, Learning Note, Project Update, Founder Journey, Problem / Fix, Decision Log, Content Seed, Reflection
what_i_worked_on	Text	Work completed or attempted
what_i_built	Text	Practical output
what_i_learned	Text	Lessons learned
problems_encountered	Text	Issues or blockers
decisions_made	Text	Decisions recorded
next_actions	Text	Follow-up actions
possible_linkedin_post	Boolean	Can become a LinkedIn post
possible_website_entry	Boolean	Can become website journal entry
tags	Text/List	Search tags
created_at	DateTime	Date created
updated_at	DateTime	Last updated
is_archived	Boolean	Archive flag
________________________________________
7.4 Journal Categories
Build Log
Learning Note
Project Update
Founder Journey
Problem / Fix
Decision Log
Content Seed
Reflection
________________________________________
8. Entity 5 — LearningItem
8.1 Purpose
A LearningItem stores a skill, subject, or topic the user is learning.
Learning should be linked to practical building.
Examples:
Flutter navigation
SQLite local storage
ESP32 WiFi diagnostics
STM32 firmware architecture
WordPress child themes
AI-assisted documentation
Cybersecurity basics
________________________________________
8.2 LearningItem Fields
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
8.3 Field Descriptions
Field	Type	Description
learning_item_id	String / UUID	Unique learning item ID
project_id	String / UUID	Linked project, optional
topic	Text	Learning topic
reason_for_learning	Text	Why this learning matters
resource_link	Text	Link to course, video, book, page, etc.
status	Enum	To Learn, Learning, Practicing, Applied, Paused, Archived
notes	Text	Learning notes
practice_task_id	String / UUID	Linked practice task
next_step	Text	Next learning action
skill_confidence	Enum	Low, Medium, High
date_started	Date	Date learning started
date_applied	Date	Date knowledge was applied
created_at	DateTime	Date created
updated_at	DateTime	Last updated
is_archived	Boolean	Archive flag
________________________________________
8.4 Learning Status Options
To Learn
Learning
Practicing
Applied
Paused
Archived
________________________________________
8.5 Skill Confidence Options
Low
Medium
High
________________________________________
9. Entity 6 — ContentItem
9.1 Purpose
A ContentItem stores public communication ideas and drafts.
This helps turn New Earth progress into awareness.
Examples:
LinkedIn post about MicroGrow Field Scanner
Website journal update about New Earth build
Video script for dashboard app
Founder journey post
Book section idea
Image prompt for website visual
________________________________________
9.2 ContentItem Fields
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
9.3 Field Descriptions
Field	Type	Description
content_item_id	String / UUID	Unique content item ID
project_id	String / UUID	Linked project, optional
journal_entry_id	String / UUID	Linked journal entry, optional
title	Text	Content title
platform	Enum	LinkedIn, Website, YouTube, Book, Newsletter, Other
content_type	Enum	LinkedIn Post, Website Journal, Video Script, Image Prompt, Book Section, Project Update, Founder Journey, Technical Update, Awareness Post
status	Enum	Idea, Drafting, Ready, Published, Archived
draft_text	Text	Draft content
image_needed	Boolean	Whether image is needed
image_prompt	Text	Prompt or description for image
publish_date	Date	Planned or actual publish date
published_link	Text	Link after publishing
notes	Text	Extra notes
created_at	DateTime	Date created
updated_at	DateTime	Last updated
is_archived	Boolean	Archive flag
________________________________________
9.4 Platform Options
LinkedIn
Website
YouTube
Book
Newsletter
Other
________________________________________
9.5 Content Type Options
LinkedIn Post
Website Journal
Video Script
Image Prompt
Book Section
Project Update
Founder Journey
Technical Update
Awareness Post
________________________________________
9.6 Content Status Options
Idea
Drafting
Ready
Published
Archived
________________________________________
10. Entity 7 — BusinessOpportunity
10.1 Purpose
A BusinessOpportunity stores anything related to income, funding, partnerships, job applications, contracts, or business growth.
Examples:
AI Architect job application
Grant opportunity
Potential MicroGrow partner
Local council contact
LinkedIn collaboration
Business offer idea
Funding lead
________________________________________
10.2 BusinessOpportunity Fields
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
10.3 Field Descriptions
Field	Type	Description
business_opportunity_id	String / UUID	Unique business item ID
project_id	String / UUID	Linked project, optional
name	Text	Opportunity name
type	Enum	Job, Contract, Grant, Partnership, Client, Funding, Mentor, Investor, Collaboration, Business Idea
company_or_contact	Text	Company, person, or organisation
status	Enum	Researching, Preparing, Applied, Waiting, Follow-up Needed, Accepted, Rejected, Paused, Archived
deadline	Date	Deadline if applicable
next_action	Text	Next step
follow_up_date	Date	Date to follow up
related_document_link	Text	CV, proposal, website, file, etc.
notes	Text	Extra notes
created_at	DateTime	Date created
updated_at	DateTime	Last updated
is_archived	Boolean	Archive flag
________________________________________
10.4 Opportunity Type Options
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
10.5 Business Status Options
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
11. Entity 8 — WellbeingCheckIn
11.1 Purpose
A WellbeingCheckIn records the user’s energy, mood, and balance for the day.
This helps the app support sustainable building.
________________________________________
11.2 WellbeingCheckIn Fields
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
11.3 Field Descriptions
Field	Type	Description
wellbeing_checkin_id	String / UUID	Unique wellbeing record ID
date	Date	Check-in date
energy_level	Enum	Low, Medium, High
mood	Enum/Text	Focused, Calm, Scattered, Tired, Motivated, Stressed, Inspired, etc.
sleep_quality	Enum	Low, Medium, High
stress_level	Enum	Low, Medium, High
movement_done	Boolean	Whether movement/exercise happened
food_water_ok	Boolean	Whether food/water needs are okay
meditation_reflection_done	Boolean	Whether reflection/meditation happened
notes	Text	Extra wellbeing notes
suggested_workload	Enum	Light, Normal, Deep Work
created_at	DateTime	Date created
updated_at	DateTime	Last updated
________________________________________
11.4 Mood Options
Focused
Calm
Scattered
Tired
Motivated
Stressed
Inspired
Low
Balanced
Overwhelmed
________________________________________
11.5 Suggested Workload Options
Light
Normal
Deep Work
________________________________________
12. Entity 9 — InboxItem
12.1 Purpose
An InboxItem stores anything captured quickly before it is processed.
This prevents ideas from being lost without forcing the user to organise them immediately.
Examples:
Quick task idea
Future project idea
Content thought
Learning note
Business lead
Journal note
Random reminder
________________________________________
12.2 InboxItem Fields
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
12.3 Field Descriptions
Field	Type	Description
inbox_item_id	String / UUID	Unique inbox item ID
title	Text	Short title
body	Text	Main note
type	Enum	Task, Idea, Journal Note, Content Idea, Learning Note, Business Opportunity, Future Idea
project_id	String / UUID	Optional linked project
status	Enum	New, Processed, Parked, Deleted
created_at	DateTime	Date created
processed_at	DateTime	When it was processed
converted_to_type	Text	Task, JournalEntry, ContentItem, etc.
converted_to_id	String / UUID	ID of created record
is_archived	Boolean	Archive flag
________________________________________
12.4 Inbox Type Options
Task
Idea
Journal Note
Content Idea
Learning Note
Business Opportunity
Future Idea
________________________________________
12.5 Inbox Status Options
New
Processed
Parked
Deleted
________________________________________
13. Entity 10 — AppSettings
13.1 Purpose
AppSettings stores simple configuration for the app.
________________________________________
13.2 AppSettings Fields
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
13.3 Field Descriptions
Field	Type	Description
settings_id	String / UUID	Unique settings ID
theme_mode	Enum	Light, Dark, System
default_dashboard_view	Text	Default dashboard layout
show_wellbeing_card	Boolean	Whether wellbeing card appears
show_business_card	Boolean	Whether business card appears
show_learning_card	Boolean	Whether learning card appears
show_content_card	Boolean	Whether content card appears
daily_top_task_limit	Integer	Default should be 3
created_at	DateTime	Date created
updated_at	DateTime	Last updated
________________________________________
14. Entity Relationships
14.1 Project Relationships
Project has many Tasks
Project has many JournalEntries
Project has many LearningItems
Project has many ContentItems
Project has many BusinessOpportunities
________________________________________
14.2 Task Relationships
Task belongs to one Project, optional
Task can be linked to one DailyPlan as a Top 3 task
Task can have one or more JournalEntries
Task can be created from an InboxItem
Task can be created from a LearningItem practice task
________________________________________
14.3 DailyPlan Relationships
DailyPlan links to up to 3 Tasks
DailyPlan can link to one LearningItem
DailyPlan can link to one ContentItem
DailyPlan can link to one BusinessOpportunity
DailyPlan can link to one WellbeingCheckIn
________________________________________
14.4 Journal Relationships
JournalEntry can belong to one Project
JournalEntry can link to one Task
JournalEntry can create one or more ContentItems
JournalEntry can create one or more Tasks
________________________________________
14.5 Content Relationships
ContentItem can belong to one Project
ContentItem can be created from one JournalEntry
ContentItem can support one Website, LinkedIn, Book, or Video output
________________________________________
14.6 Inbox Relationships
InboxItem can convert into Task
InboxItem can convert into JournalEntry
InboxItem can convert into ContentItem
InboxItem can convert into LearningItem
InboxItem can convert into BusinessOpportunity
________________________________________
15. Simple Relationship Diagram
Project
 ├── Tasks
 ├── Journal Entries
 ├── Learning Items
 ├── Content Items
 └── Business Opportunities

Daily Plan
 ├── Top Task 1
 ├── Top Task 2
 ├── Top Task 3
 ├── Learning Focus
 ├── Content Focus
 ├── Business Focus
 └── Wellbeing Check-In

Journal Entry
 ├── Related Project
 ├── Related Task
 └── Possible Content Item

Inbox Item
 ├── Convert to Task
 ├── Convert to Journal Entry
 ├── Convert to Content Item
 ├── Convert to Learning Item
 └── Convert to Business Opportunity
________________________________________
16. MVP Database Tables
For the first local database, create these tables:
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
17. Suggested Local Storage Approach
For the Flutter MVP, use one of these:
Option 1: SQLite with Drift
Option 2: SQLite with sqflite
Option 3: Hive for simpler object storage
Recommended choice:
SQLite with Drift
Reason:
It is structured.
It works well for relational data.
It supports queries.
It is good for future scaling.
It suits projects, tasks, journals, and relationships.
For the very first prototype, Hive would be quicker.
For the proper MVP, Drift is better.
________________________________________
18. Default Seed Data
When the app first opens, it should create default projects.
18.1 Default Projects
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
18.2 Default Task Categories
Build
Design
Research
Business
Learning
Content
Admin
Wellbeing
________________________________________
18.3 Default Task Statuses
Inbox
Planned
Today
In Progress
Blocked
Done
Parked
________________________________________
19. Data Rules
19.1 Daily Plan Rule
Only one DailyPlan should exist for each date.
________________________________________
19.2 Top 3 Rule
A DailyPlan should link to no more than three top tasks.
________________________________________
19.3 Completed Task Rule
When a task is marked Done:
status = Done
completed_at = current date/time
updated_at = current date/time
________________________________________
19.4 Archived Item Rule
Items should not be deleted by default.
Instead:
is_archived = true
Permanent delete can be added later.
________________________________________
19.5 Inbox Processing Rule
When an InboxItem is converted:
status = Processed
processed_at = current date/time
converted_to_type = target entity type
converted_to_id = new record ID
________________________________________
19.6 Project Progress Rule
For MVP, project progress can be manually set.
Later, progress could be calculated from completed tasks.
________________________________________
20. Future Data Entities
These are not needed for V0.1, but may be added later.
User
TeamMember
CalendarEvent
Notification
FileAttachment
GitHubIssue
WebsitePage
MicroGrowDevice
MicroGrowSensorReading
AIConversation
VoiceNote
FundingTransaction
Contact
BlueprintPillar
________________________________________
21. Future Blueprint Pillar Model
Later, the app can link tasks and projects to the New Earth Blueprint.
Possible future table:
blueprint_pillars
Fields:
pillar_id
name
description
core_principle
created_at
updated_at
Then projects and tasks could include:
pillar_id
alignment_score
impact_notes
This would allow the app to answer:
Which New Earth pillar does this task support?
Is today’s work aligned with the wider mission?
Which parts of the vision are being neglected?
________________________________________
22. Future AI Memory Model
Later, an AI layer could use the data model to generate useful summaries.
Possible AI outputs:
Daily plan suggestion
Weekly review
Project progress summary
Content draft
Learning recommendation
Overwhelm reduction plan
Next action suggestion
AI would use:
Projects
Tasks
Daily Plans
Journal Entries
Learning Items
Content Items
Business Opportunities
Wellbeing Check-Ins
________________________________________
23. Part 5 Summary
The app should be structured around a simple but powerful data model.
Core data entities:
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
The most important relationship is:
Everything should connect back to a Project where possible.
The second most important relationship is:
DailyPlan controls what appears on the Dashboard each day.
The third most important relationship is:
JournalEntry captures progress and can generate content, tasks, and documentation.
This data model gives the New Earth Command Dashboard a strong foundation for the Flutter build.
