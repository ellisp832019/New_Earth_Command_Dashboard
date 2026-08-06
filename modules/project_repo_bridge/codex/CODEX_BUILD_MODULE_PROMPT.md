# Codex Prompt: Build Project Repo Bridge Integration

Use this after Codex has inspected the Dashboard project/task system.

```text
Integrate the New Earth Project Repo Bridge module into this Dashboard repo.

Goal:
The Dashboard already has existing projects and tasks. Do not replace them. Add a read-only migration/adapter layer that reads the current Dashboard project/task data, maps projects to local Git repos using the Project Repo Bridge config, and generates unified project records for a new Projects Intelligence page.

Tasks:
1. Review modules/project_repo_bridge/README.md and docs/FSD_PROJECT_REPO_BRIDGE.md.
2. Update config/dashboard_sources.example.json or create config/dashboard_sources.json with the correct Dashboard project/task source paths.
3. Keep existing Dashboard projects and tasks working.
4. Adapt DashboardProjectAdapter and DashboardTaskAdapter to the actual app structure.
5. Wire migrate_dashboard_projects.py so it can read the current Dashboard data.
6. Wire scan_repos.py to use config/repo_registry.json.
7. Add a Projects Intelligence page/route using the provided UI components as a starting point.
8. Display unified project records from data/unified/unified_projects.json.
9. Do not overwrite old project/task data.
10. Add clear comments around anything that is adapter-specific.

Acceptance criteria:
- Existing Dashboard project/task pages still work.
- I can run scan_repos.py manually.
- I can run migrate_dashboard_projects.py manually.
- unified_projects.json is generated.
- Projects Intelligence page displays merged Dashboard + repo data.
- No destructive migration is performed.
```
