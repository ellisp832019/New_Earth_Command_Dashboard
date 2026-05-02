# TASK - Dashboard Data Foundation

## Goal

Connect the Dashboard screen to startup data without adding edit actions yet.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/08_technical_architecture.md`

## Requirements

1. Add dashboard data loading for today's DailyPlan.
2. Load selected Top 3 task titles.
3. Load the active project count.
4. Expose dashboard data through Riverpod.
5. Update the Dashboard screen to show real startup data and calm blank states.
6. Do not add editing, task creation, or project detail navigation yet.

## Expected Result

The Dashboard should reflect the seeded projects, today's blank DailyPlan, and selected Top 3 tasks.

When no Top 3 tasks are selected, the Dashboard should show a clear empty state.
