# 26_OMEGA_KNOWLEDGE_ENGINE

Universal New Earth Dashboard module for turning every project repository into a living knowledge system.

## Mission

The Omega Knowledge Engine scans repositories, documents architecture, creates learning notes, tracks decisions, builds project memory, and prepares exports for Obsidian and the Omega OS.

It is designed to be safe by default:

- Scan first
- Report first
- Generate notes first
- Suggest comments first
- Never mass-edit source code without approval
- Keep source rewriting off unless a future backup-first workflow is added

## How to open it

- Open the Dashboard
- Go to `More`
- Choose `Omega Knowledge Engine`
- Or open the `Module Hub` and use the featured Omega card or module route

## What the screen shows

- Repository validation and readiness
- Output file previews
- Learning notes
- Architecture map
- Comment suggestions
- Project memory
- Obsidian export staging
- Local settings and source paths
- Module discovery from `More` and the `Module Hub`

## Core Capabilities

1. Repository scanning
2. Code indexing
3. Function/class discovery
4. Architecture mapping
5. Learning note generation
6. Comment suggestion reports
7. Project memory files
8. Change intelligence
9. Obsidian/Omega OS export
10. Dashboard UI integration
11. AI tutor specification
12. Future knowledge graph roadmap

## Recommended Dashboard Location

```text
modules/26_OMEGA_KNOWLEDGE_ENGINE/
```

## First Run

```bash
python scripts/omega_scan.py --config config/engine_config.yaml
```

The Dashboard exposes the same command through the local `Run scan` action.

Windows:

```bat
RUN_SCAN.bat
```

Linux/macOS:

```bash
./RUN_SCAN.sh
```

## Output

```text
output/
├── repository_index.json
├── repository_index.md
├── code_learning_notes.md
├── comment_suggestions.md
├── architecture_map.md
├── project_memory.md
└── obsidian_export/
```

## Safety Notes

- Default mode is scan/report only.
- Generated comments are suggestions only.
- Missing repo paths and missing outputs are surfaced in the dashboard rather than hidden.
- Exports stay local and review-first.

## Operating Principle

The module should become the learning brain of New Earth, helping you understand what you have built and keeping that knowledge alive over time.
