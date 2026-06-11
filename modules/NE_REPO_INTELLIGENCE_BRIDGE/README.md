# New Earth Repo Intelligence Bridge

Local-first module for turning any New Earth project repo into a living knowledge source for:

- **Obsidian** human-readable Markdown notes
- **Omega OS** long-term project memory
- **New Earth Dashboard** machine-readable JSON
- **Safe AI / Voice Layer** controlled context files

This module is designed to sit inside any repo, or live centrally inside the Omega OS automation folder.

## Core flow

```text
Project Repo
   ↓ scan / sync
Obsidian Markdown exports
   ↓ readable knowledge vault
Dashboard JSON exports
   ↓ live dashboard cards, risks, tasks, timeline
AI context export
   ↓ safe permission-bounded assistant layer
```

## Your recommended Omega OS paths

```text
D:/NEW_EARTH_OMEGA_OS_PACK/09_KNOWLEDGE_VAULT_OBSIDIAN
D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/01_PROJECT_REPO_BRIDGE
D:/NEW_EARTH_OMEGA_OS_PACK/23_AI_AND_AUTOMATION/03_OBSIDIAN_REPO_SYNC_MODULE
```

## Quick start on Windows

From this module folder:

```powershell
cd .\NE_REPO_INTELLIGENCE_BRIDGE
.\scripts\validate_config.ps1 -Profile .\profiles\microgrow.json
.\scripts\sync_all.ps1 -Profile .\profiles\microgrow.json
```

Watch mode:

```powershell
.\scripts\watch_repo.ps1 -Profile .\profiles\microgrow.json
```

## What gets created

### Obsidian exports

Markdown notes are written to:

```text
<obsidian_vault_path>/<obsidian_project_folder>/
```

Example:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/09_KNOWLEDGE_VAULT_OBSIDIAN/03_REPO_KNOWLEDGE_EXPORTS/MicroGrow
```

### Dashboard exports

JSON files are written to:

```text
<dashboard_export_path>/
```

Example:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/01_PROJECT_REPO_BRIDGE/MicroGrow
```

## Safety rule

This module does **not** delete files. Markdown updates use safe generated sections:

```markdown
<!-- AUTO-GENERATED:START -->
Generated content here
<!-- AUTO-GENERATED:END -->
```

Hand-written notes outside those markers are preserved.

## Dashboard JSON outputs

```text
project_status.json
next_actions.json
tasks.json
risks.json
decisions.json
timeline.json
repo_health.json
ai_context.json
sync_manifest.json
```

## Best use

Use this as the bridge between your repos, Obsidian, Omega OS, Dashboard, and future intelligent voice layer.
