# Codex Prompt: Add Scan Button Later

Use this only after the manual scripts work.

```text
Add a local Dashboard action/button called Scan All Repos for the Project Repo Bridge.

Requirements:
1. The button must call the existing scanner through the app's safe local backend/electron/node process if available.
2. If the Dashboard is browser-only, do not attempt direct filesystem access. Instead show clear instructions to run the scanner manually.
3. After scanning, reload unified_projects.json.
4. Show scan result status: success, warnings, missing repos, dirty repos.
5. Keep paths local and configurable.
```
