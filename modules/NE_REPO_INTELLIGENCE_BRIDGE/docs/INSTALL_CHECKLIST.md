# Install Checklist

1. Keep `NE_REPO_INTELLIGENCE_BRIDGE` in `modules/NE_REPO_INTELLIGENCE_BRIDGE`.
2. Start from `profiles/template.json`, then copy or rename it if you want a project-specific profile.
3. Set `repo_root` to the project repo path.
4. Confirm Obsidian vault path and project folder.
5. Confirm dashboard export path for the target project.
6. Run:
   `./scripts/validate_config.ps1 -Profile ./profiles/template.json`
7. Run:
   `./scripts/sync_all.ps1 -Profile ./profiles/template.json`
8. Open Obsidian and check the configured project export folder.
9. Point the Dashboard at the JSON files in the configured dashboard export folder.
