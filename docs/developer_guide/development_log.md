# Development Log

## 2026-05-06 - Live Voice Capture

Added explicit microphone transcription to the Voice Assistant:

- Added `speech_to_text` for press-to-listen speech recognition
- Added Start Listening, Stop, and Cancel controls
- Recognized speech now fills the transcript preview for review/editing
- Kept Paste Transcript and mock transcript fallbacks
- Added Android microphone/speech-service configuration
- Added iOS/macOS microphone and speech-recognition usage descriptions
- Added macOS audio-input entitlement
- Vendored the beta Windows recognizer as a safe no-op because its native startup path broke `flutter run` debug attachment
- Added a Windows runner channel so `Start Listening` opens native Windows voice typing in the transcript field
- Kept Windows Paste Transcript and mock capture as stable fallbacks
- Added local voice parsing so transcripts can suggest a destination type, a cleaner title, and a related project before saving
- Structured voice saves now reuse the suggested title when it improves the saved record
- Starting Windows voice typing now preserves fullscreen instead of restoring the window
- Added structured field extraction for task category/priority, journal sections, content platform/type, and business contact/status hints
- Added editable review fields so extracted voice details can be corrected before saving

Verification:

```powershell
flutter analyze
flutter test
flutter build windows
```

## 2026-05-06 - Business Status Alignment

Aligned Business Hub dropdown language with the FSD:

- Replaced older business type labels with the FSD opportunity type set
- Replaced older business status labels with the FSD business status set
- Updated user-facing docs and the current task file to match

Verification:

```powershell
flutter analyze
flutter test
```

## 2026-05-06 - Voice Capture Integration

Integrated the safe Voice Assistant scaffold into the live local dashboard flow:

- Added a Dashboard Voice Capture entry point
- Added paste/dictation-friendly transcript capture
- Expanded voice destinations to Task, Journal Entry, Inbox Idea, Content Idea, Business Opportunity, and Codex Prompt
- Kept Codex prompts manual-review only
- Refreshed related providers after voice saves so lists update cleanly
- Added focused tests for voice-created content and business records
- Updated the current task and testing/user docs for the voice slice

Verification:

```powershell
flutter analyze
flutter test
```

## 2026-05-02 - App Shell

Added the initial V0.1 app shell:

- Material 3 New Earth theme
- `go_router` navigation
- Bottom navigation
- Dashboard placeholder cards
- Placeholder feature screens
- More screen links
- Widget smoke tests

Verification:

```powershell
flutter analyze
flutter test
```

## 2026-05-02 - Database Foundation

Added the local Drift/SQLite database foundation:

- Drift, SQLite, path, and build runner packages
- `AppDatabase`
- MVP tables for Projects, Tasks, DailyPlans, JournalEntries, LearningItems, ContentItems, BusinessOpportunities, WellbeingCheckins, InboxItems, and AppSettings
- Riverpod database provider
- Startup readiness check
- Generated Drift database code
- In-memory database smoke test

Intentionally not included yet:

- Seed data
- Repositories
- Screen data wiring
- Project/task CRUD
- AI, cloud sync, login, or external integrations

Verification:

```powershell
flutter analyze
flutter test
```

Next recommended slice:

```text
Add Seed Data for Default New Earth Projects
```

## 2026-05-02 - Documentation Foundation

Added the first asset-led documentation foundation:

- Documentation home page
- Visual direction guide
- Asset index for the PNG library
- Expanded getting started, roadmap, and architecture decision pages
- README banner and documentation links

Verification:

```powershell
flutter analyze
```

## 2026-05-02 - Default Seed Data

Added first-launch seed data:

- Default New Earth project seed definitions
- `SeedDataService`
- Startup readiness now ensures seed data exists
- Default app settings with Top 3 task limit
- Database tests for idempotent seeding and preserving custom projects

Verification:

```powershell
flutter analyze
flutter test
```

Next recommended slice:

```text
Wire Projects screen to local data
```

## 2026-05-02 - Live Dashboard, Projects, Tasks, and Parked Voice Bridge

Moved the app from placeholder shell into a working local-first flow:

- Startup now ensures default seed data and today's blank DailyPlan exist
- Dashboard reads today's plan, active project count, and Top 3 tasks
- Projects screen reads seeded local projects as calm cards
- Tasks screen reads local tasks with project labels, status, and priority
- Voice Assistant v0.1 scaffold is present, routed from `More`, and can safely save reviewed commands into local dashboard data
- Python voice bridge scaffold is present under `tools/voice_bridge`

Intentionally still parked or read-only:

- Planner screen live data
- Project detail navigation
- Task creation and editing UI
- Persistent voice history
- Real microphone capture

Verification:

```powershell
flutter analyze
flutter test
flutter build windows
python -m py_compile tools/voice_bridge/voice_bridge.py
```

Next recommended slice:

```text
Wire Planner screen to today's DailyPlan
```

## 2026-05-02 - Planner Carry Forward and Tomorrow Focus

Moved the planner one step closer to a real daily loop:

- Added a living MVP execution tracker in [docs/roadmap/mvp_execution_plan.md](../roadmap/mvp_execution_plan.md)
- Shifted `TASK.md` into a rolling one-slice workflow
- Added local save support for `carryForwardNotes`
- Added local save support for `tomorrowFocus`
- Made `Carry Forward` editable from the Planner
- Made `Tomorrow's Focus` editable from the Planner
- Added focused repository and widget coverage for both fields

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add the first Evening Review fields and save flow
```

## 2026-05-02 - Task Archive Foundation

Added the first safe archive flow for tasks:

- Added repository support to archive a task with `isArchived = true`
- Added controller support to keep `DailyPlan` and Top 3 selections in sync when archiving
- Added an archive confirmation flow from the Tasks screen
- Archived tasks now disappear from active task and related project task views by default
- Updated README and getting started docs to reflect the live Tasks workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add task search foundation
```

## 2026-05-02 - Task Search Foundation

Added the first local task search flow:

- Added task search query state in the Tasks module
- Added calm task search input with clear action
- Search now matches task title and notes
- Search combines with the existing status and project filters
- Added focused widget coverage for title search, notes search, clear search, and combined filter search
- Updated README and getting started docs to reflect the live search flow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add project archive foundation
```

## 2026-05-02 - Journal Foundation

Added the first real journal flow:

- Added `JournalRepository` for local create and list operations
- Added Riverpod journal providers and action controller
- Replaced the Journal placeholder with a real local list screen
- Added a first `AddEditJournalEntryScreen` for creating entries
- Added project and task linking support for new journal entries
- Added focused repository and widget coverage for journal create/list behaviour
- Updated README and getting started docs to reflect the live journal workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add journal edit foundation
```

## 2026-05-03 - Journal Edit Foundation

Made the Journal a living editable flow:

- Added repository support to load and update an existing journal entry
- Added `journalEntryProvider` and journal controller update actions
- Extended `AddEditJournalEntryScreen` to support both create and edit modes
- Made journal list cards open the edit screen
- Added focused repository and widget coverage for reopening and editing entries
- Updated README and getting started docs to reflect the live editable journal workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Show linked journal entries on Project Detail
```

## 2026-05-03 - Project Journal Surfacing

Made Project Detail feel more like a real build home:

- Extended the project detail snapshot to load recent linked journal entries
- Added a calm read-only `Recent Journal Entries` section on Project Detail
- Kept journal counts while avoiding a heavy timeline-style view
- Made project-linked journal items open the existing journal edit screen
- Added focused repository and widget coverage for linked journal surfacing
- Updated README and getting started docs to reflect the richer Project Detail flow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add learning foundation
```

## 2026-05-03 - Learning Foundation

Added the first real local learning flow:

- Added `LearningRepository` for local create and list operations
- Added Riverpod learning providers and action controller
- Replaced the Learning placeholder with a real local list screen
- Added a first `AddLearningItemScreen` for creating learning topics
- Added project linking, status, notes, confidence, resource link, and next-step support
- Added focused repository and widget coverage for learning create/list behaviour
- Updated README and getting started docs to reflect the live Learning workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add content foundation
```

## 2026-05-03 - Content Foundation

Added the first real local content flow:

- Added `ContentRepository` for local create and list operations
- Added Riverpod content providers and action controller
- Replaced the Content placeholder with a real local list screen
- Added a first `AddContentItemScreen` for creating content ideas
- Added project linking, platform, content type, status, draft text, image-needed, image prompt, and notes support
- Added focused repository and widget coverage for content create/list behaviour
- Updated README and getting started docs to reflect the live Content workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add business foundation
```

## 2026-05-03 - Business Foundation

Added the first real local business flow:

- Added `BusinessRepository` for local create and list operations
- Added Riverpod business providers and action controller
- Replaced the Business placeholder with a real local list screen
- Added a first `AddBusinessOpportunityScreen` for creating opportunities and practical actions
- Added project linking, type, status, company/contact, deadline, next step, follow-up date, related link, and notes support
- Added focused repository and widget coverage for business create/list behaviour
- Updated README and getting started docs to reflect the live Business workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add wellbeing foundation
```

## 2026-05-03 - Wellbeing Foundation

Added the first real local wellbeing flow:

- Added `WellbeingRepository` for local create and list operations
- Added Riverpod wellbeing providers and action controller
- Replaced the Wellbeing placeholder with a real local list screen
- Added a first `AddWellbeingCheckinScreen` for creating daily check-ins
- Added energy, mood, sleep quality, stress, movement, food/water, reflection, notes, and suggested workload support
- Added focused repository and widget coverage for wellbeing create/list behaviour
- Updated README and getting started docs to reflect the live Wellbeing workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add inbox foundation
```

## 2026-05-03 - Inbox Foundation

Added the first real local inbox flow:

- Added `InboxRepository` for local create and list operations
- Added Riverpod inbox providers and action controller
- Replaced the Inbox placeholder with a real local list screen
- Added a first `AddInboxItemScreen` for creating captured items
- Added title, body, type, project link, and status support
- Added focused repository and widget coverage for inbox create/list behaviour
- Updated README and getting started docs to reflect the live Inbox workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add dashboard quick capture to inbox
```

## 2026-05-03 - Dashboard Quick Capture Foundation

Connected the Dashboard to the new Inbox flow:

- Replaced the Dashboard Quick Capture placeholder with a real action
- Added a simple quick capture dialog for title, body, and type
- Reused the existing local inbox repository and controller
- Saved quick captures directly into Inbox with default status `New`
- Added focused widget coverage for dashboard-to-inbox capture
- Updated README and getting started docs to reflect the live fast-capture flow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add settings foundation
```

## 2026-05-03 - Settings Foundation

Added the first real local settings flow:

- Added `SettingsRepository` for local settings read and card-visibility updates
- Added Riverpod settings providers and action controller
- Replaced the Settings placeholder with a real local settings screen
- Exposed the current Top 3 task limit as a stable read-only MVP rule
- Added Dashboard card visibility toggles for Wellbeing, Business, Learning, and Content
- Added app version display for the current local build
- Wired the Dashboard to respect saved card visibility settings
- Added focused repository and widget coverage for settings load/save behaviour
- Updated README and getting started docs to reflect the live Settings workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add learning edit foundation
```

## 2026-05-03 - Learning Edit Foundation

Added the first safe edit flow for Learning:

- Added repository support to load and update an existing learning item
- Added `learningItemProvider` and learning controller update actions
- Extended `AddLearningItemScreen` to support both create and edit modes
- Made learning list cards open the edit screen
- Added focused repository and widget coverage for reopening and editing learning topics
- Updated README and getting started docs to reflect the live editable Learning workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add content edit foundation
```

## 2026-05-03 - Content Edit Foundation

Added the first safe edit flow for Content:

- Added repository support to load and update an existing content item
- Added `contentItemProvider` and content controller update actions
- Extended `AddContentItemScreen` to support both create and edit modes
- Made content list cards open the edit screen
- Added focused repository and widget coverage for reopening and editing content ideas
- Updated README and getting started docs to reflect the live editable Content workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add business edit foundation
```

## 2026-05-03 - Inbox Foundation

Added the first real local inbox flow:

- Added `InboxRepository` for local create and list operations
- Added Riverpod inbox providers and action controller
- Replaced the Inbox placeholder with a real local list screen
- Added a first `AddInboxItemScreen` for creating captured items
- Added title, body, type, project link, and status support
- Added focused repository and widget coverage for inbox create/list behaviour
- Updated README and getting started docs to reflect the live Inbox workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add dashboard quick capture to inbox
```

## 2026-05-02 - Project Archive Foundation

Added the first safe archive flow for projects:

- Added repository support to archive a project with `isArchived = true`
- Added controller support so project list and dashboard active project counts refresh after archiving
- Added archive confirmation from the Project Detail screen
- Archived projects now leave the active Projects screen and dashboard counts by default
- Related task history stays linked locally after a project is archived
- Updated README and getting started docs to reflect the live Projects workflow

Verification:

```powershell
flutter test
flutter analyze
flutter build windows
```

Next recommended slice:

```text
Add journal foundation
```
