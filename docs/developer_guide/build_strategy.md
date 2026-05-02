# Build Strategy

This document is now a short companion to the living execution tracker:

- [MVP Execution Plan](../roadmap/mvp_execution_plan.md)

Use that file for the current route through the FSDs.

This page keeps the core build principles in one place.

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

## Working Rule

We build in two layers:

1. `docs/roadmap/mvp_execution_plan.md` tracks the wider MVP route.
2. `TASK.md` tracks the one slice that is active right now.

When a slice is complete:

1. verify it
2. update the execution plan if priorities changed
3. rewrite `TASK.md`
4. move to the next slice

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

## Strategic Direction

Finish the core daily loop before widening the app:

1. Planner completion
2. Project CRUD completion
3. Task CRUD and filters completion
4. Journal foundation
5. Quick Capture and Inbox
6. Supporting modules
7. Testing and polish

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
