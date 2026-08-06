# Codex Task 12 - Treasury Settings and Health

## Goal
Build the Treasury settings and folder health screen so Hayley can see the linked finance path, understand missing folders/files, open the external pack, and create missing templates from one calm place.

## Source of truth
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/02_LOCAL_FIRST_FILE_ARCHITECTURE.md`
- `docs/fsd/treasury/03_DATA_MODEL_AND_FILE_FORMATS.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`

## Build order
1. Add a Treasury settings screen.
2. Show the configured finance folder path and config file source.
3. Show the current folder health state and missing items.
4. Add an open-folder action for the external Omega OS pack.
5. Add a reload action for rechecking Treasury health.
6. Add a create-missing-templates action that only fills gaps.
7. Link the settings screen from Treasury Home.

## Acceptance criteria
- Hayley can open a calm Treasury settings screen.
- The screen shows the linked finance path and folder health.
- The screen can open the external finance folder.
- The screen can create missing templates without overwriting existing finance data.
- The work stays local-first and reusable for other businesses later.
