# Codex Task 07 - Treasury Receipts Flow

## Goal
Build a calm, guided Receipts flow so Hayley can add a receipt or invoice from the Dashboard front end and write it into the external Omega OS finance pack.

## Source of truth
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## Build order
1. Add a Receipts wizard path inside Treasury.
2. Keep the language calm and simple.
3. Capture one receipt at a time.
4. Write the receipt entry into the external `receipt_index.csv`.
5. Back up the CSV before overwriting it.
6. Keep the finance folder outside the Dashboard repo.

## Suggested wizard steps
- Item
- Supplier
- Amount
- Personal or New Earth
- Project
- File location
- Note

## Output file
Append to:

`05_RECEIPTS_AND_INVOICES/receipt_index.csv`

## Safety rules
- Never delete receipt files.
- Never mirror the finance pack into the repo.
- Back up the CSV before each overwrite.
- If the finance folder is not linked, show the calm Treasury setup state.

## Acceptance criteria
- Hayley can open a guided Receipts flow from Treasury.
- Hayley can save a receipt entry from the front end.
- The app appends the entry into the external receipt index.
- The app keeps working in a local-first, privacy-focused way.

