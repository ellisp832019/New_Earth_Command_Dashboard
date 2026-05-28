# FSD — Local-First File Architecture

## Architecture rule
Dashboard repo contains code only.

Finance data lives here:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\17_FINANCE_AND_TREASURY
```

## App config
Use:

```text
config/local_paths.json
```

## Preferred app-managed files
```text
00_FINANCE_DASHBOARD/dashboard_state.json
00_FINANCE_DASHBOARD/weekly_status.json
05_RECEIPTS_AND_INVOICES/receipt_index.csv
06_SUBSCRIPTIONS_AND_RECURRING_COSTS/subscription_tracker.csv
04_PROJECT_SPEND_TRACKERS/project_spend_tracker.csv
10_FINANCE_MEETING_NOTES/decisions_register.csv
```

## Safety rules
- Backup before writing.
- Never delete user files.
- Never overwrite without preserving previous content.
- If a file is missing, create from template.
- If config path is invalid, show calm setup screen.
