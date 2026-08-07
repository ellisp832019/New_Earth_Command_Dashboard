# Architecture Decisions

This page records practical decisions that shape implementation.

## ADR 001 - Local-First V0.1

Decision:

The app is local-first and offline-first for V0.1.

Reason:

The MVP is a personal command dashboard. It should work without login, cloud sync, or external services.

Implications:

- No login in V0.1.
- No cloud sync in V0.1.
- No live calendar, GitHub, WordPress, or MicroGrow integration yet.
- Drift and SQLite are the database foundation.

## ADR 002 - Feature-Based Flutter Structure

Decision:

Use a feature-based folder structure with shared core infrastructure.

Reason:

The app has many modules, but each module should stay simple and understandable.

Current structure:

- `lib/core`
- `lib/features/dashboard`
- `lib/features/projects`
- `lib/features/tasks`
- `lib/features/planner`
- `lib/features/journal`
- `lib/features/learning`
- `lib/features/content`
- `lib/features/business`
- `lib/features/wellbeing`
- `lib/features/inbox`
- `lib/features/settings`

## ADR 003 - Routing

Decision:

Use `go_router` for navigation.

Reason:

The app needs clear route names, nested navigation over time, and simple expansion as detail screens are added.

## ADR 004 - State Management

Decision:

Use Riverpod when state is needed.

Reason:

Riverpod keeps app state explicit and testable without tying screens directly to data logic.

## ADR 005 - Visual System Split

Decision:

Use the dark neon asset style for documentation, repo, and promotional visuals; use the calmer light theme for the working MVP app UI.

Reason:

The brand assets are strong and high-impact, while the app itself must reduce overwhelm.

Reference:

- `docs/design/visual_direction.md`
- `assets/branding/40_brand_style_guide.png`
- `assets/screenshots/new_earth_command_dashboard_02_dashboard_mockup.png`

## ADR 006 - GAIA v0.9 Project Context Read-Only

Decision:

Define GAIA v0.9 around a structured read-only Project Context contract that distinguishes live observation from recorded checkpoints and carries provenance/freshness metadata.

Reason:

GAIA needs evidence-aware reasoning without any execution authority, and the repository already contains live, recorded, generated, and historical state that must remain distinguishable.

Reference:

- `docs/integrations/gaia/v0.9/START_HERE.md`
- `docs/integrations/gaia/v0.9/PROJECT_CONTEXT_CONTRACT.md`
- `docs/architecture/decisions/ADR-GAIA-V0-9-PROJECT-CONTEXT-READ-ONLY.md`
