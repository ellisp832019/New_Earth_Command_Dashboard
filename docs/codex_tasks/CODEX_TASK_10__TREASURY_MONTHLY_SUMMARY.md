# Codex Task 10 - Treasury Monthly Summary

## Goal
Build a calm Monthly Summary screen so Hayley can review the bigger finance picture from the Treasury tab without opening the individual tracker files.

## Source of truth
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## Build order
1. Add a Treasury Monthly Summary screen.
2. Keep the screen calm, readable, and low-pressure.
3. Read the existing Treasury trackers and dashboard state files.
4. Summarise Safe / Watch / Pause / Decision counts.
5. Show project spend totals and the top project spend groups.
6. Show recurring cost totals and upcoming subscriptions.
7. Show recent decisions and the latest weekly ritual note.
8. Keep the finance folder external and local-first.

## Summary inputs
- `00_FINANCE_DASHBOARD/dashboard_state.json`
- `00_FINANCE_DASHBOARD/weekly_status.json`
- `04_PROJECT_SPEND_TRACKERS/project_spend_tracker.csv`
- `05_RECEIPTS_AND_INVOICES/receipt_index.csv`
- `06_SUBSCRIPTIONS_AND_RECURRING_COSTS/subscription_tracker.csv`
- `10_FINANCE_MEETING_NOTES/decisions_register.csv`

## Acceptance criteria
- Hayley can open a calm Monthly Summary screen from Treasury.
- The screen shows a high-level finance picture without exposing raw folders.
- The screen reuses the existing local-first tracker files.
- The screen stays safe to use when the setup state is still incomplete.
