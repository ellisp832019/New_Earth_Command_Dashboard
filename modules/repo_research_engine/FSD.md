# Functional Specification Document - Repo Research Engine

## Parent System

New Earth Dashboard

## Vision

Create a reusable, local-first research engine that can turn any Git repository into structured knowledge, risks, project-specific insights, Codex prompts, and implementation tasks.

## Core Outcome

The user can select a repository, choose a project profile, analyse it, and receive a useful research pack.

## Core Features

### Repo Input

MVP:

- local folder path

Future:

- GitHub URL
- GitLab URL
- zipped repo upload
- repo comparison

### Safe Scanner

The scanner must:

- walk repo folders
- ignore `.git`, build caches, `node_modules`, `vendor`, and large binary folders
- classify files by extension and folder
- detect docs, code, configs, hardware files, firmware files, tests and scripts
- flag risky files
- avoid executing anything

### Profile System

Profiles are JSON files that describe what each New Earth project cares about.

Each profile contains:

- project name
- project type
- priority keywords
- ignore keywords
- useful file patterns
- risk keywords
- output focus areas
- export targets
- export locations
- report templates

### Analyser

The analyser must:

- load scan results
- load selected profile
- score repo relevance
- identify useful sections
- identify risks
- suggest what to copy, study or ignore
- generate implementation ideas

### Exporters

The exporter must create:

- full markdown research report
- executive summary
- Codex prompt
- Obsidian vault note
- action checklist
- risks log

## Non-Goals for MVP

MVP must not:

- run unknown repo code
- install dependencies
- flash firmware
- make network calls
- commit changes to researched repos
- copy licensed code blindly

## Maximum Benefit Features

- Research profiles for all New Earth projects
- Knowledge Vault integration
- Codex handoff generator
- Risk and licence awareness
- Implementation roadmap at the end of every report
- Future repo comparison mode

## MVP Data Flow

```text
Local Repo Path
    ↓
Safe Scanner
    ↓
Scan Manifest JSON
    ↓
Selected Profile JSON
    ↓
Profile Analyser
    ↓
Research Report Markdown
    ↓
Vault Export + Codex Prompt
```

