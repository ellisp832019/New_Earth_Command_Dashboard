# Dashboard Integration

The Dashboard should read JSON from the bridge output folder configured in the selected profile or template copy.

Example:

```text
<dashboard_export_path>
```

Recommended first files to connect:

1. `project_status.json` for the project overview card.
2. `next_actions.json` for the next action panel.
3. `repo_health.json` for the health score.
4. `risks.json` for the risk panel.
5. `ai_context.json` for the safe AI layer.

## Dashboard card model

```text
Project Name
Status / Phase / Health
Current Focus
Next 3 Actions
Risk Count
Last Sync Time
Open in Obsidian
Open Repo Folder
```

## AI layer

The AI layer should load `ai_context.json` before taking action. It should treat `blocked_ai_permissions` as hard denies and `human_approval_required` as confirmation gates.
