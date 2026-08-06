# CODEX TASK 25 - Treasury First-Time Setup Household Onboarding

## Goal

Make the Treasury first-time setup wizard ask who the pots are for in a more explicit way, so Hayley can quickly choose the personal, shared, and business lanes she wants to seed.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/01_HAYLEY_CALM_UX_SPEC.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `TASK.md`

## Requirements

1. Keep the change inside Treasury Budget Pots.
2. Make the first-time setup selection step read like a household onboarding question.
3. Surface the owner groups more clearly before the pack cards.
4. Keep the wizard calm, local-first, and backup-safe.
5. Do not overwrite existing pots.
6. After implementation, run `flutter analyze` and Treasury tests if possible.

## Expected Result

Hayley sees a more obvious `Who is this for?` step, can choose the people or groups she wants to set up, and still continues through the same calm wizard into the editable review step and final create action.
