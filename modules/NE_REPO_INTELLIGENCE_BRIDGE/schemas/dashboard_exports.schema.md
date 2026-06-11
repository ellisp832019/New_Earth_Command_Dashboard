# Dashboard Export Schemas

These JSON shapes are intentionally simple for easy Dashboard integration.

## project_status.json

```json
{
  "project": "MicroGrow",
  "type": "firmware_app_hardware",
  "status": "active",
  "phase": "repo intelligence sync",
  "health": "green",
  "health_score": 80,
  "current_focus": "...",
  "generated_at": "..."
}
```

## ai_context.json

```json
{
  "project_name": "MicroGrow",
  "source_of_truth": "local repo + Omega OS + Obsidian exports",
  "locked_rules": [],
  "safe_ai_permissions": [],
  "blocked_ai_permissions": [],
  "human_approval_required": []
}
```
