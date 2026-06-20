# Architecture

```text
Omega Dashboard
    |
    |-- Module Hub
          |
          |-- 00_COMPANY_COMMAND_CENTRE
                    |
                    |-- UI Pages
                    |-- Services
                    |-- JSON Indexes
                    |-- Markdown Templates
                    |-- Omega OS Bridge
                              |
                              |-- D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY
```

## Data flow

```text
Markdown company files -> Index scanner -> Generated JSON indexes -> Dashboard services -> UI cards/tables/pipelines
```

## Safety model

```text
Read-only first -> Backup before edit -> Write staged change -> Audit log entry -> Refresh generated index
```
