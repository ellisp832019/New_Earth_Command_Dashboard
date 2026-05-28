# FSD — Treasury Automation Workflows

## Folder health check
When Treasury opens:
1. Read `config/local_paths.json`.
2. Check finance folder exists.
3. Check required subfolders exist.
4. Check required tracker files exist.
5. Show calm setup if anything is missing.

## Create missing templates
Only create missing files. Do not overwrite existing files.

## Weekly finance note
When Hayley completes the weekly ritual:
1. Generate Markdown note.
2. Save to weekly review folder.
3. Update dashboard state.
4. Add decisions to decisions register.
5. Show “Review saved” confirmation.

## Project spend totals
Read project CSV and calculate totals by project.
