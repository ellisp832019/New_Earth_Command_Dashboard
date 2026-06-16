# Architecture

## High-level architecture

```text
Dashboard UI
  ↓
Experiment API / Service Layer
  ↓
Experiment Registry JSON
  ↓
Evidence Vault + Omega OS + Obsidian + GitHub
```

## Main components

### Dashboard module

Provides screens, cards, routes and views.

### Automation scripts

Python scripts create experiments, generate notes, import CSV files and export reports.

### Schemas

JSON schemas define valid experiment records, evidence records and results records.

### Storage

Local-first file storage. No cloud dependency required.

### Integration layer

Maps experiments to common tools:

- Proteus
- KiCad
- Fusion 360
- PlatformIO
- GitHub
- Obsidian
- CSV / Excel-compatible tools

## Data flow

```text
Create Experiment
  → create folder
  → create experiment.json
  → create test plan
  → create Obsidian note
  → optional GitHub issue body
  → attach evidence
  → import results
  → generate report
  → extract lesson learned
```

## Omega OS folder map

See `omega_os/OMEGA_OS_FOLDER_MAP.md`.
