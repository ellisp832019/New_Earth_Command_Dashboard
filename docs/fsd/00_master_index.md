# New Earth Command Dashboard - FSD Master Index

This folder contains the full Functional Specification Document for the New Earth Command Dashboard.

## Source of Truth

Codex must treat these files as the source of truth for the project.

## FSD Files

1. `01_product_vision.md`
   - Product vision, purpose, problem statement, goals.

2. `02_scope_and_mvp.md`
   - MVP scope, future features, user journeys.

3. `03_user_roles_navigation.md`
   - User roles, modules, navigation structure.

4. `04_screen_specification.md`
   - Screen-by-screen layout, fields, buttons, actions.

5. `05_data_model.md`
   - Entities, fields, relationships, database table direction.

6. `06_functional_requirements.md`
   - Exact behaviours the app must perform.

7. `07_non_functional_requirements.md`
   - UX, privacy, performance, offline, emotional design rules.

8. `08_technical_architecture.md`
   - Flutter structure, Drift, Riverpod, routing, folder structure.

9. `09_mvp_roadmap.md`
   - Build phases, milestones, task order.

10. `10_testing_release.md`
   - Test cases, acceptance criteria, release checklist.

11. `11_build_instructions.md`
   - First coding tasks, Codex prompts, repo setup.

12. `12_major_upgrade_plan.md`
   - Repo-wide upgrade order, cross-module priorities, release gates, and parked work.

## Roadmaps

- [App Roadmap](../roadmap/app_roadmap.md)
- [MVP Roadmap](../roadmap/mvp_roadmap.md)
- [MVP Execution Plan](../roadmap/mvp_execution_plan.md)
- [Voice Roadmap](../roadmap/voice_10_task_roadmap.md)
- [AI Roadmap](../roadmap/ai_10_task_roadmap.md)
- [Treasury Roadmap](../roadmap/treasury_20_task_roadmap.md)

## Build Rule

Do not build the whole app at once.

Always work from `TASK.md`.

Use the FSD files for context, but implement only the current task.
