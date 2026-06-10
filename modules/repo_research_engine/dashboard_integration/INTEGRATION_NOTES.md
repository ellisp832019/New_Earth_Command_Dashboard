# Dashboard Integration Notes

Add this module as a tools page inside the New Earth Dashboard.

Suggested route:

```text
/more/repo-research-engine
```

Suggested module registry entry:

```json
{
  "id": "repo_research_engine",
  "name": "Repo Research Engine",
  "category": "Knowledge + Research",
  "status": "MVP",
  "local_first": true,
  "requires_network": false
}
```

The dashboard UI should call the scanner through a safe local backend command, not by running unknown repo code.

## Page Set

- Repo Research Home
- Repository Scanner
- Research Reports
- Profile Manager
- Knowledge Vault Exports
- Codex Prompt Generator
- Settings

See `dashboard_integration/DASHBOARD_PAGE_MAP.md` for the intended route contract.

## Current Wiring

- The module is already launched from the `More` hub in Flutter.
- The home route is the main landing page, with nested routes for scanner, reports, profiles, exports, prompts, and settings.
- The UI should keep the home page as the calm summary view and use the nested routes for focused work.
- The scanner page now includes an opt-in clone-to-workspace flow that turns a Git URL or local repo into a structured local source folder before scanning.
- The scanner page now offers a one-click clone-and-scan action that clones into the workspace and immediately runs the safe bundle on the cloned source folder.
- After a successful clone, the dashboard opens the imported source folder so the user can inspect the workspace immediately.
