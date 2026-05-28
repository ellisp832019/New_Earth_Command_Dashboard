# Treasury Roadmap

This roadmap breaks the Treasury tab into 20 small, reviewable steps so Hayley can enter everything through the Dashboard front end in a calm, guided way.

Source of truth:
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## 20 Tasks

1. Lock the Treasury lane inside Dashboard navigation and keep it visually contained for Hayley.
2. Finish the Treasury Home screen as the calm landing place with Safe, Watch, Pause, and Decision cards.
3. Keep the external Omega OS finance folder as the source of truth and read its path from `config/local_paths.json`.
4. Build the folder health and setup state so Treasury shows a calm setup screen when the path or folders are missing.
5. Add a shared local draft store so Treasury wizard entries can resume inside the app without touching finance files yet.
6. Turn the Weekly Finance Ritual into the first full wizard flow with one question per step and a final review screen.
7. Add the Treasury Home draft card so Hayley can continue or mark a draft saved from the Dashboard front end.
8. Implement safe local draft persistence and save state for the Weekly Ritual flow.
9. Add backup handling before any overwrite path is allowed for Treasury file writes.
10. Create the dashboard state file layer for `dashboard_state.json`.
11. Create the receipts inbox layer for `receipt_index.csv` and the Receipts Inbox screen.
12. Create the project spend tracker layer for `project_spend_tracker.csv` and the Project Spend screen.
13. Create the subscription tracker layer for `subscription_tracker.csv` and the Subscriptions screen.
14. Create the decisions register layer for `decisions_register.csv` and the Decisions board.
15. Add calm CRUD helpers for templates so missing Treasury files can be created without overwriting existing ones.
16. Build the weekly review note generator so completing the ritual writes a Markdown summary into the finance folder.
17. Add Safe / Watch / Pause / Needs Decision state summaries across Treasury screens and dashboards.
18. Add monthly summary surfacing so Hayley can review finance at a higher level without losing the calm tone.
19. Add folder-link settings and health feedback so the path, missing files, and readiness state are always visible.
20. Add verification coverage for Treasury flows with `flutter analyze`, `flutter test`, and the relevant local-first file path checks.

## Delivery Rule

Implement these in order. Do not jump ahead to advanced file writes before the home, wizard, draft, and safety layers are working.

