# Dashboard Export Schemas

These JSON shapes are intentionally simple for easy Dashboard integration.

## project_status.json

```json
{
  "project": "__PROJECT_NAME__",
  "type": "__PROJECT_TYPE__",
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
  "project_name": "__PROJECT_NAME__",
  "source_of_truth": "local repo + Obsidian exports + dashboard exports",
  "locked_rules": [],
  "safe_ai_permissions": [],
  "blocked_ai_permissions": [],
  "human_approval_required": []
}
```
