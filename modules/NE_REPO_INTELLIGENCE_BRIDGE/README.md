# New Earth Repo Intelligence Bridge

Local-first module for turning any New Earth project repo into a living knowledge source for:

- **Obsidian** human-readable Markdown notes
- **Omega OS** long-term project memory
- **New Earth Dashboard** machine-readable JSON
- **Safe AI / Voice Layer** controlled context files

This module is designed to live in `modules/NE_REPO_INTELLIGENCE_BRIDGE` and point at any repo you want to inspect.

## Core flow

```text
Project Repo
  -> scan / sync
Obsidian Markdown exports
  -> readable knowledge vault
Dashboard JSON exports
  -> live dashboard cards, risks, tasks, timeline
AI context export
  -> safe permission-bounded assistant layer
```

## Example local-first paths

```text
<OBSIDIAN_VAULT_PATH>
<DASHBOARD_EXPORT_ROOT>
<OPTIONAL_OMEGA_OS_EXPORT_ROOT>
```

These are example destinations only. The real locations come from the selected profile in `profiles/`.
For a clean starting point, copy `profiles/template.json` and fill in your own paths.

## Quick start on Windows

From the repository root:

```powershell
cd .\modules\NE_REPO_INTELLIGENCE_BRIDGE
.\scripts\validate_config.ps1 -Profile .\profiles\template.json
.\scripts\sync_all.ps1 -Profile .\profiles\template.json
```

Watch mode:

```powershell
.\scripts\watch_repo.ps1 -Profile .\profiles\template.json
```

## What gets created

### Obsidian exports

Markdown notes are written to:

```text
<obsidian_vault_path>/<obsidian_project_folder>/
```

### Dashboard exports

JSON files are written to:

```text
<dashboard_export_path>/
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
