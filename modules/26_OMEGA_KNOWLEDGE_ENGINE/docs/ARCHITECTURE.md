# Architecture — Omega Knowledge Engine

```text
Repository Paths
      │
      ▼
Repository Scanner
      │
      ├── repository_index.json
      ├── repository_index.md
      ├── code_learning_notes.md
      ├── comment_suggestions.md
      ├── architecture_map.md
      └── project_memory.md
      │
      ▼
Dashboard UI
      │
      ├── Overview
      ├── Learning
      ├── Architecture
      ├── Project Memory
      └── Exports
      │
      ▼
Obsidian / Omega OS Export
```

## Engine Layers

### 00_CORE
Shared configuration, constants, schemas, and safety rules.

### 01_REPOSITORY_SCANNER
Discovers files, filters noise, and indexes code/documentation.

### 02_CODE_KNOWLEDGE
Creates file-level and symbol-level learning notes.

### 03_ARCHITECTURE_ENGINE
Creates high-level maps of modules, folders, services, dependencies, and flows.

### 04_DOCUMENTATION_ENGINE
Generates markdown documentation and report files.

### 05_OBSIDIAN_BRIDGE
Exports knowledge into Obsidian/Omega OS compatible markdown.

### 06_PROJECT_MEMORY
Tracks milestones, decisions, lessons, and important changes.

### 07_CHANGE_INTELLIGENCE
Future layer for Git commit summaries and change impact reports.

### 08_AI_TUTOR
Future local AI tutor grounded in generated docs and source indexes.

### 09_VISUALISATION_ENGINE
Future diagrams, Mermaid maps, dependency trees, and architecture visuals.

### 10_SEARCH_AND_QUERY
Future local search over code, docs, and generated knowledge.

### 11_DASHBOARD_UI
Dashboard module shell and tabs.

### 12_EXPORTS
Markdown, JSON, PDF-ready, Obsidian, and future audio outputs.

### 13_AUTOMATION
Scheduled scans and digest generation later.

### 14_SECURITY
Safety, ignore rules, secret handling, and permissions.
