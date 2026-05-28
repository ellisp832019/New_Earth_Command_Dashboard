# Codex Master Task — Build Treasury Tab

## Goal

Build a calm, local-first Treasury tab inside the New Earth Dashboard for Hayley.

## Locked finance source path

```text
D:\NEW_EARTH_OMEGA_OS_PACK\17_FINANCE_AND_TREASURY
```

## Critical instruction

Do **not** copy, mirror, or move the finance folder into the Dashboard repo.

The Dashboard app must point to the external Omega OS finance folder using:

```text
config/local_paths.json
```

## Build phases

### Phase 1 — Repo setup
- Add `config/local_paths.example.json`.
- Add `config/local_paths.json` to `.gitignore`.
- Create Treasury feature folder.
- Add docs from this FSD pack.

### Phase 2 — Navigation
- Add a `Treasury` tab to the main Dashboard navigation.
- Optional subtitle: `Hayley's Finance Centre`.

### Phase 3 — Folder path service
Create a service that:
- reads local config
- validates finance folder exists
- validates required subfolders
- shows a calm setup screen if missing

### Phase 4 — Treasury home UI
Build:
- 🟢 Safe card
- 🟡 Watch card
- 🔴 Pause card
- 🔵 Decisions card
- Receipts to sort card
- Weekly ritual button

### Phase 5 — Tracker files
Support:
- `dashboard_state.json`
- `receipt_index.csv`
- `project_spend_tracker.csv`
- `subscription_tracker.csv`
- `decisions_register.csv`

### Phase 6 — Weekly ritual
Build guided flow:
1. Check balances
2. Sort receipts
3. Review subscriptions
4. Review project spend
5. Mark safe/watch/stop/decision
6. Save weekly note

### Phase 7 — Safety
- Backup files before writing.
- Never delete finance files.
- Create missing files from templates only.
- Use calm, clear errors.

## UX rule

This is not corporate finance software.  
It should feel calm, warm, safe, simple, and empowering for Hayley.
