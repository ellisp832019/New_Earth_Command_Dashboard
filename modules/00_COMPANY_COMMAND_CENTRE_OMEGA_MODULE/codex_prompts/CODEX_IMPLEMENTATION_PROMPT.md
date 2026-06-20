# Codex Prompt — Implement 00_COMPANY_COMMAND_CENTRE

You are working inside the New Earth Omega Dashboard repo.

I have imported a new module folder called:

`00_COMPANY_COMMAND_CENTRE`

The external Omega OS company folder is:

`D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY`

## Goal
Integrate this as a clean dashboard module called **Company Command Centre**.

## Requirements
1. Inspect the current repo structure before making changes.
2. Follow the existing module registration pattern used by the dashboard.
3. Add a Module Hub tile for `Company Command Centre`.
4. Add a route/page for `/modules/company-command-centre` or the closest existing routing convention.
5. Build the UI shell first using mock JSON files from this module.
6. Include these pages/tabs: Overview, Compliance & Deadlines, Finance Snapshot, Website & Brand, LinkedIn & Marketing, Product Portfolio, IP & Asset Register, Grants Pipeline, Partnerships, Evidence Library, Director Action Board, Settings.
7. Keep the first implementation read-only.
8. Add config for the Omega OS source path but do not write to it yet.
9. Add graceful fallback if the path does not exist.
10. Preserve the existing dashboard style and architecture.
11. Do not break existing modules.
12. Add or update tests if the repo already has a test pattern.
13. Update documentation with where the module was registered and how to run it.

## Data source
Use:
- `data/mock/company_overview.json`
- `data/mock/action_board.json`
- `data/mock/product_portfolio.json`
- `data/mock/grants_pipeline.json`

## Done criteria
- App builds/runs.
- Module is visible from hub.
- Module page opens.
- Mock data displays.
- Settings show the Omega OS path.
- Existing modules still work.
