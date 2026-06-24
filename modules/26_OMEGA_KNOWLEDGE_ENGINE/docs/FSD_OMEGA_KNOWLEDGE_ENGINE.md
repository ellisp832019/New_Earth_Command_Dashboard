# Functional Specification Document — Omega Knowledge Engine

## 1. Purpose

The Omega Knowledge Engine is a New Earth Dashboard module that turns project repositories into living knowledge systems.

It helps the user learn from their own codebase by scanning repositories, creating documentation, building learning notes, mapping architecture, and preparing future AI tutor integration.

## 2. Problem

As New Earth grows, knowledge becomes scattered across:

- Source code
- Markdown docs
- Obsidian notes
- Git history
- meeting notes
- diagrams
- module packs
- personal learning

Without a dedicated knowledge engine, important understanding gets lost.

## 3. Solution

Create a local-first module that indexes every project and generates:

- repo maps
- code summaries
- architecture maps
- learning notes
- comment suggestions
- project memory
- Obsidian exports

## 4. Scope v1

Included:

- Local repository scanning
- Extension-based file discovery
- Ignore rules
- Markdown report generation
- JSON index generation
- Obsidian export folder
- Dashboard UI specification
- Safe comment suggestion workflow

Excluded from v1:

- automatic source rewriting
- cloud AI dependency
- automatic commits
- production knowledge graph database
- background scanning daemon

## 5. User Roles

### Builder / Founder
Uses the module to understand project structure and learn the codebase.

### Engineer
Uses reports to find gaps, missing docs, and architecture issues.

### Future AI Tutor
Uses generated outputs as grounded source material.

## 6. Core Workflows

### Workflow A — First Scan

1. User adds module to repo.
2. User runs scanner.
3. Engine creates repository index.
4. Engine creates learning notes.
5. User reviews reports.

### Workflow B — Learning Session

1. User opens Dashboard module.
2. User selects repo.
3. User opens learning notes.
4. User studies file-by-file explanations.
5. User adds manual notes or asks AI tutor later.

### Workflow C — Comment Review

1. Engine generates comment suggestions.
2. User reviews them.
3. Codex or AI generates patch.
4. User approves patch.
5. Backup is created.
6. Comments are applied.

## 7. Safety Requirements

- No auto-edit by default.
- No destructive operations.
- No secrets extraction into public docs.
- Ignore generated and dependency folders.
- Backup before source modifications.
- Always generate review reports first.

## 8. Dashboard UI

Tabs:

1. Overview
2. Repositories
3. Scan Results
4. Learning Notes
5. Architecture Map
6. Comment Suggestions
7. Project Memory
8. Obsidian Export
9. Settings

## 9. Future v2-v5

v2:
- Git change intelligence
- repo comparison
- daily knowledge digest

v3:
- local AI tutor
- natural language repo Q&A
- code explanation chat

v4:
- knowledge graph
- concept relationships
- project dependency brain

v5:
- GAIA voice tutor
- visual timeline playback
- engineering mentor mode
