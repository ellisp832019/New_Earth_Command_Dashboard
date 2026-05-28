# Codex Task 06 - Treasury Folder Health and File Write Layer

## Goal
Build the Treasury folder-health check and safe file-write layer so the Dashboard can verify the external Omega OS finance pack before any Treasury flow writes data.

## Source of truth
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## Build order
1. Read `config/local_paths.json`.
2. Resolve the external Omega OS finance root.
3. Validate the finance root exists.
4. Validate the required Treasury folders exist.
5. Validate the required tracker files exist or can be created from templates.
6. Add calm setup state output for missing or invalid paths.
7. Add a safe write helper that backs up existing files before overwrite.
8. Keep finance data outside the Dashboard repo at all times.

## Required folders
- `00_FINANCE_DASHBOARD`
- `01_HAYLEY_FINANCE_QUEEN_GUIDE`
- `04_PROJECT_SPEND_TRACKERS`
- `05_RECEIPTS_AND_INVOICES`
- `06_SUBSCRIPTIONS_AND_RECURRING_COSTS`
- `10_FINANCE_MEETING_NOTES`
- `15_TEMPLATES`

## Required files
- `00_FINANCE_DASHBOARD/dashboard_state.json`
- `00_FINANCE_DASHBOARD/weekly_status.json`
- `04_PROJECT_SPEND_TRACKERS/project_spend_tracker.csv`
- `05_RECEIPTS_AND_INVOICES/receipt_index.csv`
- `06_SUBSCRIPTIONS_AND_RECURRING_COSTS/subscription_tracker.csv`
- `10_FINANCE_MEETING_NOTES/decisions_register.csv`

## Safety rules
- Never copy the finance pack into the repo.
- Never delete finance files.
- Never overwrite without a backup.
- Only create missing files from templates.
- If the path is invalid, show a calm setup screen instead of failing loudly.

## Acceptance criteria
- Treasury can detect whether the external finance folder is linked.
- Treasury can report missing folders and missing files clearly.
- Treasury can create missing files from templates only.
- Treasury can create `.bak` backups before overwriting an existing file.
- Treasury file-write helpers stay local-first and privacy-focused.
- The feature is ready for Weekly Ritual, Receipts, Decisions, Project Spend, and Subscriptions to build on top of it.

