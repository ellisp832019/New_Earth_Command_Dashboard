# Backup Architecture

## Source

```text
D:\
```

## Target

```text
E:\NEW_EARTH_BACKUP
```

## Backup target structure

```text
E:\NEW_EARTH_BACKUP
├── mirror
├── daily
├── weekly
├── monthly
├── manifests
├── reports
├── restore_tests
└── latest_status.json
```

## Phase 1

Manual, safe, simple:

- Dry Run
- Backup Now
- Verify Latest
- Restore Dry Run

## Phase 2

Dashboard-controlled scheduling:

- Daily backup
- Weekly snapshot
- Monthly archive
- Backup history
- Retention rules

## Phase 3

Disaster recovery:

- Multiple drives
- Off-site copy
- Encrypted archive
- Full restore wizard
- Health warnings
