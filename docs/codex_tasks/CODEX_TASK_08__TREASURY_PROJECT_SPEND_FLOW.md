# Codex Task 08 - Treasury Project Spend Flow

## Goal
Build a calm Project Spend flow so Hayley can record project spending from the Dashboard front end and write it into the external Omega OS finance pack.

## Source of truth
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## Build order
1. Add a Project Spend wizard path inside Treasury.
2. Keep the language calm and simple.
3. Capture one project spend at a time.
4. Write the spend entry into the external `project_spend_tracker.csv`.
5. Back up the CSV before overwriting it.
6. Keep the finance folder outside the Dashboard repo.

## Suggested wizard steps
- Project
- Item
- Supplier
- Amount
- Category
- Receipt saved
- Status
- Note

## Output file
Append to:

`04_PROJECT_SPEND_TRACKERS/project_spend_tracker.csv`

## Safety rules
- Never delete project spend files.
- Never mirror the finance pack into the repo.
- Back up the CSV before each overwrite.
- If the finance folder is not linked, show the calm Treasury setup state.

## Acceptance criteria
- Hayley can open a guided Project Spend flow from Treasury.
- Hayley can save a project spend entry from the front end.
- The app appends the entry into the external project spend tracker.
- The app keeps working in a local-first, privacy-focused way.

