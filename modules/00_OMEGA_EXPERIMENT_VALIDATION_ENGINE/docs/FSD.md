# Functional Specification Document

## Module

`00_OMEGA_EXPERIMENT_VALIDATION_ENGINE`

## Purpose

Create a reusable Omega Standard system for planning, running, recording, comparing, validating and learning from experiments across all New Earth projects.

## Problem solved

Without a dedicated module, experiments become scattered across photos, notes, repos, screenshots, Proteus files, KiCad folders and random CSV logs. This module creates a repeatable engineering workflow so every test becomes searchable evidence.

## Users

- Peter Ellis — founder, engineer, builder
- Future collaborators
- Codex / local AI assistants
- Project reviewers, mentors, funders

## Project types supported

- MicroGrow hardware and firmware
- BioCalm sensor work
- New Earth Dashboard modules
- GAIA local AI experiments
- New Earth Living app tests
- XR OS prototypes
- Future electronics, mechanical, AI and software projects

## Core features

### 1. Experiment Registry

Every experiment has:

- experiment ID
- title
- project
- category
- status
- owner
- dates
- hypothesis
- objective
- setup
- linked files
- evidence
- results
- conclusions
- next actions

### 2. Evidence Vault

Evidence can include:

- photos
- videos
- Proteus projects
- KiCad projects
- Fusion 360 files
- LTspice simulations
- oscilloscope screenshots
- logic analyzer captures
- serial logs
- firmware versions
- CSV/Excel-compatible test data
- screenshots
- notes

### 3. Results Engine

The module can compare test candidates using a scoring model.

Example sensor scoring:

- accuracy
- stability
- wiring complexity
- cost
- firmware simplicity
- availability
- reliability
- production suitability

### 4. Lessons Learned

Every experiment must capture:

- what worked
- what failed
- cause of failure
- design rule created
- reusable recommendation

### 5. Dashboard Integration

Dashboard screens:

- Experiment Command Centre
- Create Experiment
- Active Experiments
- Evidence Vault
- Results Comparison
- Lessons Learned
- Reports
- Software Integrations
- AI Review Queue

### 6. Obsidian Integration

Each experiment can generate an Obsidian note with frontmatter, links and evidence references.

### 7. GitHub Integration

Each experiment can generate a GitHub issue template for tracking engineering tasks.

### 8. Proteus Integration

Proteus is treated as a first-class evidence source for:

- circuit block simulation
- microcontroller simulation
- logic testing
- stage-based validation
- screenshot/waveform capture
- design iteration history

### 9. AI Review Future Phase

Future local AI review can inspect:

- experiment notes
- logs
- CSV files
- screenshots
- Proteus summaries
- KiCad exports
- Fusion screenshots

and produce:

- likely failure causes
- risks
- recommendations
- next tests
- final engineering summary

## Status lifecycle

```text
IDEA
PLANNED
READY
RUNNING
BLOCKED
ANALYSING
COMPLETE
ARCHIVED
```

## Priority lifecycle

```text
LOW
MEDIUM
HIGH
CRITICAL
```

## Experiment categories

```text
SENSOR_VALIDATION
CIRCUIT_BLOCK
PROTEUS_SIMULATION
PCB_VALIDATION
FIRMWARE_TEST
MECHANICAL_TEST
ENCLOSURE_TEST
POWER_TEST
COMMUNICATION_TEST
SOFTWARE_TEST
AI_MODEL_TEST
USER_TEST
GRANT_STRATEGY_TEST
```

## Omega requirement

No experiment is complete until it has:

1. objective
2. setup
3. evidence
4. result
5. conclusion
6. lesson learned
7. next action
