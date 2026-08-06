# FSD — Acceptance Criteria

## Must pass
- Treasury tab appears in Dashboard navigation.
- App reads finance path from `config/local_paths.json`.
- App does not require finance folder to be inside repo.
- If path is missing, app shows calm setup instructions.
- Hayley can view Safe / Watch / Pause / Decision.
- Hayley can complete a weekly ritual.
- App can create missing tracker files.
- App can read/write dashboard state.
- App can read/write CSV tracker files.
- App creates backups before overwriting files.
- App does not delete finance files.
- `config/local_paths.json` is ignored by git.
- `config/local_paths.example.json` remains committed.
