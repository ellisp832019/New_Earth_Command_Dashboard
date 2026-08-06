# Omega OS Integration

## Source path

```text
D:\NEW_EARTH_OMEGA_OS_PACK\17_FINANCE_AND_TREASURY\09_GRANTS_DONATIONS_AND_FUNDING
```

## Dashboard path

```text
modules/funding_grants_command_centre
```

## Read/write flow

```text
Dashboard opens
→ reads grant_tracker.json
→ displays pipeline
→ user edits card
→ dashboard writes grant_tracker.json
→ optional CSV export updates grant_tracker.csv
```

## Folder creation flow

When the user creates a new grant, the dashboard should:

1. Create a tracker record.
2. Create a folder under `01_ACTIVE_APPLICATIONS`.
3. Copy the grant folder template.
4. Link `folder_path` to the new folder.
5. Set status to `Researching` or `Drafting`.

## Movement rules

- Submitted grants move to `02_SUBMITTED_APPLICATIONS`
- Approved grants move to `03_APPROVED_GRANTS`
- Rejected grants move to `04_REJECTED_OR_PAUSED`
- Final frozen copy goes to `13_SUBMISSION_ARCHIVE`

Do not delete anything.
