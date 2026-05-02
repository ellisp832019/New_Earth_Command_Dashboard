# TASK - Seed Default New Earth Projects

## Goal

Add first-launch seed data for the New Earth Command Dashboard.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/08_technical_architecture.md`

## Requirements

1. Create default seed data for the nine New Earth projects:
   - MicroGrow
   - MicroGrow Field Scanner
   - New Earth Website
   - New Earth Living App
   - Smart Growing Systems Book
   - LinkedIn / Public Awareness
   - Business & Funding
   - Learning & Skills
   - Future Ideas
2. Add a seed data service that creates default projects on first launch.
3. Add default app settings:
   - `theme_mode = System`
   - dashboard cards visible for wellbeing, business, learning, and content
   - `daily_top_task_limit = 3`
4. Keep the seed operation idempotent so records are not duplicated.
5. Add focused tests for the seed data.
6. Do not wire the Projects screen to live data yet.

## Expected Result

The database should contain the default projects and app settings after startup readiness runs.

Running the seed operation multiple times should not duplicate records.
