# Build Strategy

This document condenses the FSD files into a practical build path for the current repository.

## FSD Source Map

- `docs/fsd/01_product_vision.md`: Build a calm personal mission-control app that answers, "What should I focus on today to move New Earth forward?"
- `docs/fsd/02_scope_and_mvp.md`: Keep V0.1 focused on daily clarity, project momentum, Top 3 tasks, planning, journaling, learning, content, business, wellbeing, and quick capture.
- `docs/fsd/03_user_roles_navigation.md`: Single-user local-first app with bottom navigation: Dashboard, Projects, Tasks, Planner, More.
- `docs/fsd/04_screen_specification.md`: Screen layouts, placeholder content, and expected user actions for each module.
- `docs/fsd/05_data_model.md`: Core entities and relationships. Most records should link back to a Project where possible.
- `docs/fsd/06_functional_requirements.md`: MVP behaviours such as seed projects, one DailyPlan per date, Top 3 enforcement, archive over delete, and local persistence.
- `docs/fsd/07_non_functional_requirements.md`: Calm UX, fast local actions, no login, offline-first, privacy by default, and no overloaded screens.
- `docs/fsd/08_technical_architecture.md`: Flutter, Material 3, Riverpod, go_router, Drift, SQLite, feature-based structure, and layered UI -> controller/provider -> repository -> database.
- `docs/fsd/09_mvp_roadmap.md`: Build order from app shell to database, projects, tasks, DailyPlan, Dashboard, Top 3, Planner, Journal, supporting modules, Quick Capture, and polish.
- `docs/fsd/10_testing_release.md`: Acceptance tests and release checklist for V0.1.
- `docs/fsd/11_build_instructions.md`: Codex-ready task order and first build instructions.

## Current Repo State

Completed:

- Flutter app shell
- Material 3 New Earth theme
- go_router app routing
- Bottom navigation
- Placeholder screens
- More screen links
- Dashboard placeholder cards
- Widget tests for app-shell navigation
- Local build documentation
- Drift/SQLite database foundation
- MVP table definitions
- Riverpod database provider
- Database smoke test

Not started yet:

- Seed data service
- Real Projects, Tasks, DailyPlan, Journal, Learning, Content, Business, Wellbeing, Inbox, or Settings data flows

## Core Build Rule

Build the smallest useful command centre first.

Do not fill every module deeply before the core loop works:

1. Dashboard
2. Projects
3. Tasks
4. DailyPlan
5. Top 3
6. Planner
7. Journal
8. Quick Capture and Inbox
9. Supporting modules

## Best Technical Direction

Use vertical slices after the database foundation.

Each slice should include only the pieces needed for that behaviour:

- Drift table
- Domain model if useful beyond generated Drift row types
- Repository
- Riverpod provider/controller
- Screen or widget update
- Focused tests

Keep UI separate from data logic. Screens should call providers/controllers, not Drift directly.

## Immediate Next Build Task

The next task should be:

```text
TASK - Add Seed Data for Default New Earth Projects
```

Scope:

- Create `SeedDataService`.
- Insert default New Earth projects once.
- Insert default app settings once.
- Prevent duplicate seed data.
- Add the first Projects repository/provider needed to read seeded projects.
- Show seeded projects on the Projects screen.
- Verify projects persist after restart and do not duplicate.

Do not build full project create/edit/detail flows in the same task unless `TASK.md` explicitly asks for them.

## Recommended Next Sprint Order

1. Database foundation
2. Seed default projects and app settings
3. Projects list, cards, details, add/edit, archive
4. Tasks list, add/edit, status changes, filters, project linking
5. DailyPlan auto-create and real Dashboard cards
6. Top 3 task selection and enforcement
7. Planner morning intention and evening review
8. Journal list and entry form
9. Learning, Content, Business, and Wellbeing basic CRUD
10. Quick Capture and Inbox processing
11. Empty states, error handling, manual test pass, V0.1 release notes

## Non-Negotiable Product Rules

- Local-first and offline-first.
- No login for V0.1.
- No cloud sync for V0.1.
- No AI assistant for V0.1.
- No calendar, GitHub, WordPress, or MicroGrow live integrations yet.
- Top 3 really means a maximum of three priority tasks for a day.
- Prefer Parked or Carry Forward language over failure language.
- Archive instead of deleting by default.
- Keep Dashboard calm and focused.
- Treat wellbeing data as private and sensitive.

## Data Model Priorities

Start persistence in this order:

1. `projects`
2. `tasks`
3. `daily_plans`
4. `journal_entries`
5. `learning_items`
6. `content_items`
7. `business_opportunities`
8. `wellbeing_checkins`
9. `inbox_items`
10. `app_settings`

Important rules:

- Every main entity needs a unique ID.
- Every main entity needs `created_at` and `updated_at`.
- Archive flags should exist where records can be hidden instead of deleted.
- `daily_plans.date` should be unique.
- A DailyPlan should link to no more than three top tasks.

## Testing Strategy

Every task should keep these passing:

```powershell
flutter analyze
flutter test
```

When database work begins, add tests around:

- Database opens
- Tables exist through generated Drift database
- Default projects seed once
- One DailyPlan per date
- Top 3 limit enforcement

Manual testing should follow `docs/fsd/10_testing_release.md` before calling V0.1 complete.
