# New Earth Command Dashboard Documentation

This folder is the working documentation home for the New Earth Command Dashboard.

The app is built local-first, offline-first, and clarity-first. Documentation should follow the same rule: help the reader understand what matters next without adding noise.

## Start Here

- [Getting Started](user_guide/getting_started.md)
- [MVP Roadmap](roadmap/mvp_roadmap.md)
- [App Roadmap](roadmap/app_roadmap.md)
- [Meeting System module](../modules/meeting_system/README.md)
- [Architecture Decisions](architecture/architecture_decisions.md)
- [Visual Direction](design/visual_direction.md)
- [Asset Index](assets/asset_index.md)
- [Hayley Asset Intelligence Guide](hayley_assets/HAYLEY_ASSET_VIEW_GUIDE.md)
- [Inventory Session Checklist](hayley_assets/HAYLEY_INVENTORY_SESSION_CHECKLIST.md)
- [Codex Workflow](developer_guide/codex_workflow.md)
- [Local Build Guide](developer_guide/local_build.md)

## Source Documents

The Functional Specification Document lives in [fsd](fsd/00_master_index.md). Before coding, read the master index, the FSD file relevant to the current task, and `TASK.md` in the repo root.

## Documentation Principles

- Keep every page focused on one job.
- Prefer calm, practical wording.
- Use the existing PNG assets as visual anchors for brand, layout, screenshots, and architecture.
- Keep docs current as each build slice lands.
- Record meaningful implementation steps in [development_log.md](developer_guide/development_log.md).

## Current Documentation Shape

- `fsd/` contains the source specification.
- `user_guide/` explains how to use the app.
- `developer_guide/` explains how to build and maintain the app.
- `architecture/` records decisions that shape implementation.
- `roadmap/` keeps the MVP and app-level build order clear.
- `testing/` holds verification notes and release checks.
- `assets/` documents the image library and how it should be used.
- `design/` captures brand, colour, layout, and tone guidance.
