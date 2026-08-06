# Codex Task 04 — Tracker Files and Backups

## Goal
Implement tracker files safely.

## Files
- `dashboard_state.json`
- `receipt_index.csv`
- `project_spend_tracker.csv`
- `subscription_tracker.csv`
- `decisions_register.csv`

## Safety
Before writing:
1. Check file exists.
2. Create `.bak` copy.
3. Write new content.
4. If write fails, keep backup.

## Never
- Never delete user files.
- Never overwrite without backup.
- Never assume all files exist.
