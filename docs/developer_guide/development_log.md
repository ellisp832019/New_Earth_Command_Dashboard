# Development Log

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
