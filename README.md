# New Earth Command Dashboard

![New Earth Command Dashboard](assets/repo/01_repo_banner_new_earth_command_dashboard.png)

Local-first Flutter app for managing New Earth projects, tasks, daily focus, learning, content, business, wellbeing and build progress.

## Current Status

V0.1 foundation is live:

- Dashboard-first launch
- Material 3 New Earth theme
- Bottom navigation
- More screen links
- Drift/SQLite database foundation
- MVP database tables
- Default seed data and app settings
- Startup DailyPlan creation
- Dashboard reads local startup data
- Projects screen reads seeded projects
- Project detail and add/edit flows are live
- Project archive from Project Detail is live
- Project detail now surfaces linked journal history
- Tasks screen reads local tasks
- Task create/edit flows are live
- Task status actions, filters, and archive foundation are live
- Task search by title and notes is live
- Journal list, create-entry, and edit-entry foundation are live
- Learning list, add-topic, and edit-topic foundation are live
- Content list, add-idea, and edit-idea foundation are live
- Business list and add-opportunity foundation are live
- Wellbeing list and check-in foundation are live
- Inbox list and add-item foundation are live
- Dashboard Quick Capture saves directly into Inbox
- Settings screen now loads local app settings, shows the Top 3 rule, shows app version, and controls dashboard support-card visibility
- Voice Assistant / Voice Intelligence now includes wake handling, startup gating, a dashboard conversation dock, shared session flow, and review-first local capture
- Voice Intelligence V1 is integrated as a new `/voice` module with mock transcription, a full `/voice/conversation` loop, locally persisted shared thread memory and audit logging, remembered voice settings, meeting summaries, MicroGrow read-only status, safety gating, and no hidden hardware writes
- Omega Knowledge Engine is registered as a read-only local intelligence module at `/modules/omega-knowledge-engine`, with scan/report outputs, repository indexing, learning notes, architecture maps, and Obsidian export staging
- On Windows, the dashboard now waits for a connected headset or headset microphone before the main dashboard loads
- Meeting System phase 1 is live with dashboard, meeting index, wizard, detail, and trackers
- Launchpad module phase 1 is live with campaign manager, rewards, story builder, readiness tracker, finance modeller, and JSON seed import; phase 2 now adds media, grants, investors, partners, manufacturing, community, timeline, analytics, launch checklist, backer updates, fulfilment, and impact records; phase 3 is polishing the overview, summary cards, reward cards, and archive flow
- If you move the repo to a new folder, clear `build/windows/x64` and `.dart_tool`, then run `flutter clean` and `flutter pub get` before building Windows again

## Documentation

- [Project Index](PROJECT_INDEX.md)
- [Documentation Home](docs/README.md)
- [About & Help Centre](ABOUT_AND_HELP/99_INDEX/MASTER_INDEX.md)
- [Getting Started](docs/user_guide/getting_started.md)
- [App Roadmap](docs/roadmap/app_roadmap.md)
- [Roadmap Index](docs/roadmap/README.md)
- [Visual Project Map](docs/roadmap/visual_project_map.md)
- [Documentation Audit](docs/roadmap/documentation_audit.md)
- [Meeting System module](modules/meeting_system/README.md)
- [Voice Intelligence module pack](modules/voice_intelligence_module/README.md)
- [Launchpad module](modules/new_earth_launchpad_module/README.md)
- [Omega Knowledge Engine module](modules/26_OMEGA_KNOWLEDGE_ENGINE/README.md)
- [Module Hub architecture](docs/architecture/module_hub/module_hub_architecture.md)
- [MVP Roadmap](docs/roadmap/mvp_roadmap.md)
- [Architecture Decisions](docs/architecture/architecture_decisions.md)
- [Visual Direction](docs/design/visual_direction.md)
- [Asset Index](docs/assets/asset_index.md)
- [Local Build Guide](docs/developer_guide/local_build.md)

## Active Project Home

The Dashboard now has an Obsidian-facing active project folder. This is a mirrored documentation/workspace area, not Flutter app source:

- [`01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD/README.md`](01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD/README.md)
- [`01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD/docs/NEW_EARTH_DASHBOARD_PROJECT_HOME.md`](01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD/docs/NEW_EARTH_DASHBOARD_PROJECT_HOME.md)

Use that folder as the working home for dashboard-aligned notes, indices, and sync outputs that stay aligned with the Obsidian vault.

## How To Use The App

This app is now far enough along to support a real daily workflow.

Best simple rhythm:

1. Open `Dashboard`
2. Set `Main Focus`, `Why It Matters`, and `Morning Intention`
3. Choose your `Top 3`
4. Work from `Projects` and `Tasks`
5. Use `Quick Capture` for loose thoughts
6. Close the day with `Start Evening Review`

If you want the full operating guide, use:

- [Detailed User Guide](docs/user_guide/getting_started.md)

## Developer Shortcuts

For faster local work in VS Code:

- `Ctrl+Alt+A` runs `Flutter: quick analyze Omega + Modules`
- `Ctrl+Alt+B` runs `Flutter: get + analyze + test`
- `Ctrl+Alt+F` runs `Flutter: format project`
- `Ctrl+Alt+T` runs `Flutter: test`
- `Ctrl+Alt+R` runs `Flutter: run Windows`
- `Ctrl+Alt+W` runs `Flutter: run Chrome`
- `Ctrl+Alt+G` runs `Flutter: pub get`
- `Ctrl+Alt+C` runs `Flutter: clean`
- `Flutter: get + quick analyze` chains `pub get` and the quick analyze task
- `Flutter: build all local` chains Windows and Web builds
- Use `Terminal > Run Task` if you want the full task list

The quick analyze task checks the active Omega and module UI files without waiting for a full workspace pass.
The format, test, clean, and package tasks give you a simple maintenance loop without typing long commands.

## Debug Profiles

VS Code launch profiles are available for:

- `Launch Windows`
- `Launch Chrome`

Use them from the Run and Debug panel when you want to attach the debugger instead of using a terminal task.

## Best Visual Assets

These are the most useful documentation visuals right now:

- README banner: `assets/repo/01_repo_banner_new_earth_command_dashboard.png`
- GitHub overview: `assets/repo/33_github_readme_visual_overview.png`
- MVP checklist: `assets/repo/42_v01_mvp_feature_checklist.png`
- Dashboard user manual: `assets/user_guide/36_dashboard_user_manual_page.png`
- Projects and Tasks manual: `assets/user_guide/37_projects_tasks_user_manual_page.png`
- Journal and Planner manual: `assets/user_guide/38_journal_planner_user_manual_page.png`
- Developer toolkit cheat sheet: `docs/developer_guide/assets/developer_toolkit_cheat_sheet.png`
- Quick start guide: `assets/user_guide/35_getting_started_quick_start.png`
- Mobile overview: `assets/screenshots/27_mobile_app_screens_overview.png`
- Daily planning flow: `assets/screenshots/28_daily_planning_flow.png`
- Project detail explainer: `assets/screenshots/29_project_detail_screen_explained.png`

## Visual References

![GitHub Visual Overview](assets/repo/33_github_readme_visual_overview.png)

![MVP Feature Checklist](assets/repo/42_v01_mvp_feature_checklist.png)

## Visual System

The repo includes a strong PNG asset library for brand, layouts, diagrams, screenshots, user guide pages, and GitHub documentation.

Use the dark neon New Earth style for documentation and repo visuals. Use the calmer light Material 3 theme for the working app UI so the dashboard stays clear and low-overwhelm.
