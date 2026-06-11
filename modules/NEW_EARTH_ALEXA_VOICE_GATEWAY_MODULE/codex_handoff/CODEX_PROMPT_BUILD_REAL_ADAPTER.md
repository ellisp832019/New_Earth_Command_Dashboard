# Codex Prompt: Build Real Dashboard Adapter

```text
Build a real adapter for modules/voice_gateway_alexa that connects the gateway to the existing New Earth Dashboard APIs.

Requirements:
- Keep the permission system as the single gate.
- Do not bypass voice_permissions.yaml.
- Do not add finance, shell, file deletion, raw Obsidian vault, or AI agent commands.
- Keep MicroGrow read-only.
- Implement these commands first:
  - dashboard.summary.today
  - dashboard.project.status.read
  - microgrow.status.read
  - dashboard.note.add
  - dashboard.task.add
  - dashboard.focus.start
  - dashboard.tasks.next
- Add tests for blocked commands.
- Add a local config file example but do not commit secrets.
- Update README with the exact dashboard startup command.
```
