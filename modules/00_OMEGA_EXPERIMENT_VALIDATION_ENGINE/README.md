# 00_OMEGA_EXPERIMENT_VALIDATION_ENGINE

Omega-level experiment, evidence, validation and engineering knowledge module for the New Earth Dashboard.

This module turns every test into reusable knowledge:

- sensor comparisons
- circuit block development
- Proteus simulations
- KiCad PCB validation
- Fusion 360 enclosure tests
- firmware logs
- CSV data analysis
- photos, videos, scope captures and bench evidence
- lessons learned and design rules

## Core idea

Projects are long-term builds. Experiments belong to projects. This module manages experiments across all projects.

Example:

```text
MicroGrow Project
└── EXP-0001 Sensor Comparison
└── EXP-0002 Mist Driver Stage 2 Simulation
└── EXP-0003 PCB V0.1 Bring-up
```

## First install location

Drop this folder into your dashboard modules area, for example:

```text
<dashboard_repo>/modules/00_OMEGA_EXPERIMENT_VALIDATION_ENGINE
```

Then map its Omega OS outputs to:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\21_PROJECTS_AND_PROGRAMMES\_EXPERIMENTS
D:\NEW_EARTH_OMEGA_OS_PACK\22_KNOWLEDGE_AND_LEARNING\EXPERIMENT_KNOWLEDGE_BASE
D:\NEW_EARTH_OMEGA_OS_PACK\23_AI_AND_AUTOMATION\OMEGA_EXPERIMENT_ENGINE
D:\NEW_EARTH_OMEGA_OS_PACK\99_VISUAL_INDEX_AND_MAPS\EXPERIMENT_VISUAL_LIBRARY
```

## Supported common software

- VS Code
- Git / GitHub
- Obsidian
- Proteus
- KiCad
- Fusion 360
- PlatformIO
- Arduino IDE
- Flutter
- Python
- CSV / Excel-compatible data
- LTspice
- Logic analyzers / oscilloscopes / thermal cameras
- Ollama/local AI review pipeline, future phase

## What is included

- Functional Specification Document
- Architecture document
- Dashboard UI skeleton
- Data schemas
- Experiment templates
- Proteus/KiCad/Fusion evidence templates
- Automation scripts
- Sample experiments
- Codex prompt
- Omega OS folder mapping
- GitHub issue templates
- Obsidian note templates

## How to run the module

1. Drop the folder into `modules/00_OMEGA_EXPERIMENT_VALIDATION_ENGINE`.
2. Open the dashboard and go to `More` then `Experiment Engine`, or use the sidebar `Experiments` entry.
3. The dashboard loads the root `module_manifest.json` and the sample experiments from `sample_data/experiments`.

## How to create an experiment

1. Open `Experiments`.
2. Choose `Create`.
3. Fill in the objective, hypothesis, plan, setup notes, evidence references, results, conclusion, lesson learned, and next actions.
4. Save the draft locally. The dashboard will create a new file under `storage/experiments/drafts` and will not overwrite an existing draft.

## Where evidence goes

Evidence stays local-first and can be linked from the experiment record. The recommended roots are:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\21_PROJECTS_AND_PROGRAMMES\_EXPERIMENTS
D:\NEW_EARTH_OMEGA_OS_PACK\22_KNOWLEDGE_AND_LEARNING\EXPERIMENT_KNOWLEDGE_BASE
D:\NEW_EARTH_OMEGA_OS_PACK\23_AI_AND_AUTOMATION\OMEGA_EXPERIMENT_ENGINE
D:\NEW_EARTH_OMEGA_OS_PACK\99_VISUAL_INDEX_AND_MAPS\EXPERIMENT_VISUAL_LIBRARY
```

## Obsidian, GitHub, and Omega OS sync

- Obsidian notes are generated from the experiment frontmatter and linked evidence.
- GitHub issue templates can hold the same experiment ID and the same checklist.
- Omega OS paths are treated as approved local roots only.
- Sync and export scripts should stay dry-run capable, log every destination, and never delete user data.

## How future AI review will work

Future local AI review can inspect:

- experiment notes
- evidence files
- CSV logs
- report templates
- related commits
- related GitHub issues

It should then propose:

- likely failure causes
- next tests
- risk notes
- engineering summaries

The AI review step should remain advisory only and must not make destructive file changes.
