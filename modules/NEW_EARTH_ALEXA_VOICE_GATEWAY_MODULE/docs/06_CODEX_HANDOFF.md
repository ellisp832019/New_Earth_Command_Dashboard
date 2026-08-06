# Codex Handoff

Paste this into Codex after placing the module in your dashboard repo.

```text
You are working inside my New Earth Dashboard repo.

I have added a module at:
modules/voice_gateway_alexa/

Goal:
Integrate this Alexa Voice Gateway module into the dashboard safely.

Rules:
1. Do not expose raw local files, finance data, Obsidian vault contents, shell commands, or AI agent execution to Alexa.
2. Keep MicroGrow read-only at first.
3. Route Alexa requests only through the gateway permission and safety layer.
4. Add dashboard API adapters only for allowed commands.
5. Keep all secrets in local ignored config files.
6. Add tests for permission denial and blocked commands.
7. Add audit logging for every voice command.

First tasks:
- Inspect modules/voice_gateway_alexa/README.md and docs/.
- Identify the dashboard API endpoints that match the mock adapter.
- Create a real DashboardAdapter implementation.
- Wire gateway startup into the dashboard dev environment.
- Add a README section explaining how to run it locally.
- Do not add destructive commands.
```

