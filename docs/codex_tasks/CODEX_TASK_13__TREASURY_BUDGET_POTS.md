# Codex Task 13 - Treasury Budget Pots

## Goal
Build a calm Budget Pots screen so Hayley can think about Treasury allocations, buffers, and future intentions without opening raw finance files.

## Source of truth
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## Build order
1. Add a Budget Pots screen inside Treasury.
2. Keep the screen calm and reusable.
3. Derive the pots from the existing Treasury summary data.
4. Show the pots as a planning layer, not a noisy finance ledger.
5. Link the screen from Treasury Home and the Treasury route tree.

## Acceptance criteria
- Hayley can open Budget Pots from Treasury.
- The screen shows a calm view of the current Treasury pots.
- The screen stays local-first and does not mirror finance files into the repo.
- The screen can be expanded later into a fuller pot management flow if needed.
