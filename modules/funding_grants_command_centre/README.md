# Funding & Grants Command Centre

Dashboard module for tracking innovation grants and funding applications across New Earth, MicroGrow and related projects.

## Design rule

The module should not become the only place where grant data lives.

It should read and write to Omega OS:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\17_FINANCE_AND_TREASURY\09_GRANTS_DONATIONS_AND_FUNDING
```

## Minimum viable module

- Grant pipeline view
- Grant cards by status
- Grant detail view
- Add/edit grant form
- Readiness score panel
- Deadline list
- Funding totals
- Omega OS folder links
- JSON/CSV storage

## Storage files

```text
00_GRANT_TRACKER_MASTER/grant_tracker.json
00_GRANT_TRACKER_MASTER/grant_tracker.csv
```

## Later integrations

- Calendar reminders
- Email support letter capture
- Obsidian sync
- AI grant drafting
- Evidence auto-packer
- Finance ledger connection
