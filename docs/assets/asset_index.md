# Asset Index

This page maps the existing PNG assets so they can guide documentation, design, and future app work from the beginning.

## Summary

The repo currently includes 56 PNG assets across:

- `assets/branding` - 7 brand and palette assets.
- `assets/diagrams` - 10 architecture and flow diagrams.
- `assets/screenshots` - 12 app mockups and screen concepts.
- `assets/user_guide` - 17 user guide and manual pages.
- `assets/repo` - 6 GitHub and repository documentation visuals.
- `assets/tutorials` - 1 onboarding flow.
- `assets/app_store` - 1 app store screenshot set.
- `assets/alternatives` - 2 alternate concept visuals.

## Best Source Assets

| Need | Use |
| --- | --- |
| Brand identity | `assets/branding/40_brand_style_guide.png` |
| Quick palette reference | `assets/branding/new_earth_command_dashboard_12_colour_palette.png` |
| README banner | `assets/repo/01_repo_banner_new_earth_command_dashboard.png` |
| Documentation structure | `assets/repo/41_github_docs_folder_map.png` |
| MVP checklist | `assets/repo/42_v01_mvp_feature_checklist.png` |
| Roadmap visual | `assets/repo/03_mvp_roadmap_visual.png` |
| App shell direction | `assets/screenshots/new_earth_command_dashboard_02_dashboard_mockup.png` |
| Mobile product overview | `assets/screenshots/27_mobile_app_screens_overview.png` |
| Architecture overview | `assets/diagrams/02_architecture_overview_diagram.png` |
| Database direction | `assets/diagrams/19_database_relationship_diagram.png` |
| Local-first privacy | `assets/diagrams/30_local_first_privacy_diagram.png` |
| User guide cover | `assets/user_guide/34_user_guide_cover.png` |
| Quick start guide | `assets/user_guide/35_getting_started_quick_start.png` |

## Folder Guidance

### Branding

Use for visual identity, palette decisions, icon references, splash direction, and brand documentation.

Key files:

- `40_brand_style_guide.png`
- `new_earth_command_dashboard_12_colour_palette.png`
- `new_earth_command_dashboard_01_hero_branding.png`
- `24_app_splash_screen.png`

### Screenshots

Use for app layout references, README previews, user guide images, and future implementation comparison.

The smaller MVP mockups are especially useful for the current Flutter shell because they show a calmer, lighter interface.

### Diagrams

Use for developer docs and architectural explanation.

Keep these close to:

- Architecture decisions.
- Build workflow.
- Database planning.
- Local-first privacy.
- Backup and export planning.

### Repo

Use for GitHub-facing documentation, README visuals, and project orientation.

The docs folder map is especially useful as the north star for building out the documentation structure.

### User Guide

Use for end-user help pages. These assets already cover dashboard, Top 3 tasks, quick capture, evening review, journal, learning, content, projects, and planner concepts.

## Implementation Notes

The images are not currently registered as Flutter runtime assets in `pubspec.yaml`. That is fine for documentation and design reference.

When a future task needs to display images in the Flutter app, add only the required paths to `pubspec.yaml` and keep the change scoped to that task.
