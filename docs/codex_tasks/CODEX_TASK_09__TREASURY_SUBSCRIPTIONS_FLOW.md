# Codex Task 09 - Treasury Subscriptions Flow

## Goal
Build a calm Subscriptions flow so Hayley can review recurring costs from the Dashboard front end and write them into the external Omega OS finance pack.

## Source of truth
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## Build order
1. Add a Subscriptions wizard path inside Treasury.
2. Keep the language calm and simple.
3. Capture one subscription at a time.
4. Write the subscription entry into the external `subscription_tracker.csv`.
5. Back up the CSV before overwriting it.
6. Keep the finance folder outside the Dashboard repo.

## Suggested wizard steps
- Service
- Purpose
- Cost
- Renewal date
- Payment source
- Keep / Cancel / Review
- Note

## Output file
Append to:

`06_SUBSCRIPTIONS_AND_RECURRING_COSTS/subscription_tracker.csv`

## Safety rules
- Never delete subscription files.
- Never mirror the finance pack into the repo.
- Back up the CSV before each overwrite.
- If the finance folder is not linked, show the calm Treasury setup state.

## Acceptance criteria
- Hayley can open a guided Subscriptions flow from Treasury.
- Hayley can save a subscription entry from the front end.
- The app appends the entry into the external subscription tracker.
- The app keeps working in a local-first, privacy-focused way.

