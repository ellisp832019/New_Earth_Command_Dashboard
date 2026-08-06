# Codex Task 16 - Treasury Budget Pots Actions

## Goal
Turn Budget Pots into a real editable Treasury surface so Hayley can add pots, adjust balances, and move money between pots from the Dashboard front end.

## Source of truth
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## Build order
1. Add a local Budget Pots JSON file to Treasury.
2. Create calm pot management actions for add, adjust, and move.
3. Keep all writes local-first with backup-before-overwrite handling.
4. Show the saved file and movement count on the Budget Pots screen.

## Acceptance criteria
- Hayley can create a budget pot.
- Hayley can adjust a pot balance.
- Hayley can move money between pots.
- Treasury writes the pot file safely into the external Omega OS finance folder.
- The screen stays calm and readable for daily use.
