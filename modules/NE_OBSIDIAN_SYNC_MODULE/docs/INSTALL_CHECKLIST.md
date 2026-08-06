# Install Checklist

Use this checklist every time you add the module to a repo.

- [ ] Keep the module in `modules/NE_OBSIDIAN_SYNC_MODULE`
- [ ] Update `project_name`
- [ ] Update `project_type`
- [ ] Update `repo_path` to the repo root
- [ ] Update `docs_source_path`
- [ ] Update `obsidian_vault_path`
- [ ] Update `obsidian_project_folder`
- [ ] Update `dashboard_export_path` if needed
- [ ] Update `tags`
- [ ] Update `related_projects`
- [ ] Choose a sync mode
- [ ] If this is the Dashboard, use `profiles/new_earth_dashboard.json`
- [ ] Run `python .\scripts\obsidian_sync\migrate_dashboard_docs.py --compare`
- [ ] Run `python .\scripts\obsidian_sync\migrate_dashboard_docs.py --dry-run`
- [ ] Ask Codex to run `CODEX_OBSIDIAN_SYNC_TASK.md`
- [ ] Review files in `modules/NE_OBSIDIAN_SYNC_MODULE/exports/`
- [ ] Run the sync script
- [ ] Open Obsidian and confirm files arrived
- [ ] Commit the module if it should stay with the repo
