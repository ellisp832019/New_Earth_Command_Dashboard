# CODEX TASK 24 - Treasury First-Time Setup Reset to Suggested Values

## Goal

Add a one-tap reset action to the Treasury first-time setup wizard so Hayley can return every editable target back to the suggested values without leaving the flow.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/treasury/00_TREASURY_TAB_MASTER_FSD.md`
- `docs/fsd/treasury/04_SCREENS_AND_COMPONENTS.md`
- `docs/fsd/treasury/05_AUTOMATION_WORKFLOWS.md`
- `docs/fsd/treasury/06_ACCEPTANCE_CRITERIA.md`
- `TASK.md`

## Requirements

1. Keep the reset action inside Treasury Budget Pots.
2. Add a calm `Reset to suggested values` action in the first-time setup wizard review step.
3. Reset editable pot targets back to the starter suggestions without changing any existing saved pots.
4. Keep the setup flow backup-safe and local-first.
5. Keep the wizard calm and easy for Hayley to use.
6. After implementation, run `flutter analyze` and Treasury tests if possible.

## Expected Result

Hayley can open the first-time setup wizard, edit targets, and if needed tap one calm reset action to restore the suggested starting values before creating her personal, your personal, and shared household pots.
