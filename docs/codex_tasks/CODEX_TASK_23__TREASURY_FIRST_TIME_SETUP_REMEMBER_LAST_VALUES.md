# CODEX TASK 23 — Treasury First-Time Setup Remember Last Values

## Goal

Make the Treasury first-time setup wizard remember the last saved pot targets by preloading the current Treasury pot values when the wizard opens.

## Source of Truth

- `docs/fsd/00_master_index.md`
- `docs/fsd/03_user_roles_navigation.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/07_non_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/treasury/`
- `TASK.md`

## Scope

1. Keep the first-time setup wizard in Budget Pots.
2. Read existing Treasury budget pot targets when the wizard opens.
3. Use those saved values as the starting point for the editable target fields.
4. Keep local-first, backup-safe writes unchanged.

## Expected Result

If Hayley opens the setup wizard again, it starts from the last saved Treasury pot targets instead of the base defaults, making the flow feel like it remembers the household rather than resetting it.
