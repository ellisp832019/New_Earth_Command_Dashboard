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
