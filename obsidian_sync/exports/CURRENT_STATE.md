# Gaia Current State

## Purpose

Gaia, the New Earth Command Dashboard, is a local-first Flutter app for managing projects, tasks, daily focus, learning, content, business actions, wellbeing, treasury work, assets, meetings, and voice capture.

It is built to reduce overwhelm and keep the day organized from one calm dashboard.

## Current Status

- Status: V0.1 foundation is live and broadly usable
- Current branch: `feat/asset-intelligence-tab`
- Current version/tag: `a38c0ff`
- Last reviewed: `2026-06-03`

## What Works

- Dashboard-first shell with Material 3 styling and bottom navigation
- Local Drift/SQLite database foundation with seed data and startup checks
- Daily plan creation at startup
- Working local screens for projects, tasks, planner, journal, learning, content, business, wellbeing, inbox, settings, treasury, assets, QR labels, meetings, knowledge library, and voice assistant
- Local create/edit flows for the core capture modules
- Dashboard quick capture into Inbox
- Task archive, search, filters, and Top 3 support
- Voice stack with startup gate, handsfree wake layer, shared session state, conversation dock, and Windows typing bridge

## What Is Incomplete

- No login in V0.1
- No cloud sync in V0.1
- No live calendar, GitHub, WordPress, or MicroGrow integration yet
- No AI assistant in V0.1
- Several roadmap slices still need polish, especially voice follow-up, asset intelligence, and knowledge library reliability
- The root-level `obsidian_sync` folder now exists in the working tree and still needs to be committed if Peter wants it tracked in git

## Current Risks

- The app surface is broad, so routing, state, and documentation can drift if slices move too quickly
- Windows-specific voice dependencies can vary by machine and are a known stability risk
- Local file paths and asset/config assumptions need to stay stable
- Too many parallel feature slices could dilute MVP focus

## Next Priority Actions

1. Finish the voice polish slice from the roadmap: remembered thread, briefing clarity, quick follow-up chips, and shared session-state tuning.
2. Harden the asset intelligence and QR/print flows without widening scope.
3. Keep the local-first foundation stable and add AI only through a small adapter after the voice path is calm.

## Related Files

- [[NEW_EARTH_DASHBOARD_INDEX]]
- [[NEW_EARTH_DASHBOARD_ARCHITECTURE]]
- [[NEW_EARTH_DASHBOARD_ROADMAP]]
- [[NEW_EARTH_DASHBOARD_DECISIONS]]
- [[NEW_EARTH_DASHBOARD_BUILD_LOG]]
- `README.md`
- `docs/README.md`
- `docs/fsd/00_master_index.md`
- `docs/roadmap/app_roadmap.md`
- `docs/roadmap/voice_10_task_roadmap.md`
- `docs/roadmap/ai_10_task_roadmap.md`
- `docs/architecture/architecture_decisions.md`
- `TASK.md`
