# Dashboard Phase 5 Personalization Closure

**Audit date:** 2026-08-25
**Repository:** New Earth Command Dashboard
**Branch:** `main`
**Commit:** `ec9a1752e371dbe4c817fa073240282fe20b5d9f`

## Scope

Phase 5 is limited to bounded Dashboard presentation preferences:

- five stable Dashboard card IDs
- local card visibility
- deterministic card ordering
- bounded reset behavior
- UX clarification for descriptions, Daily Flow protection, reset scope, accessibility, and small windows

No drag-and-drop, freeform layout, resizing, multiple layouts, lane state, backend, network, MCP, GAIA, or NEOS behavior was added.

## Phase 5A

Phase 5A introduced `DashboardCardLayout` with the stable IDs `daily_flow`, `next_step`, `treasury`, `command_centre`, and `support_stack`. Defaults are deterministic. Unknown, duplicate, removed, malformed, and missing IDs are normalized safely, and `daily_flow` is always retained and visible.

Preferences are stored as one JSON value on the existing local `AppSettings` record under the Dashboard-local authority. Schema version 17 adds only the nullable `dashboard_card_layout_json` column through an additive migration.

## Phase 5B And 5B1

The UX review identified three findings and Phase 5B1 remediated them:

- each card now has a concise human-readable description
- Daily Flow explicitly states that it is always visible and cannot be hidden
- reset is labeled `Restore default layout` and states that only card order and visibility change

Ordering controls remain bounded Move Up and Move Down actions with tooltips. The small-window test confirmed that the personalization surface and ordering controls do not overflow.

## Authority Boundaries

Personalization changes presentation only. Daily Flow remains one indivisible card backed by the existing Daily Plan, Tasks, Projects, and Inbox data. No duplicate task, project, or daily-plan authority exists.

The personalization layer does not require or modify GAIA, NEOS, Command Centre authority, MCP, or future LANE-01 state.

## Validation

- Dashboard layout tests: PASS
- Personalization UX tests: PASS
- Database tests: PASS
- Users/devices migration tests: PASS
- Dashboard widget suite: PASS, 64 tests
- `flutter analyze`: PASS
- `git diff --check`: PASS

The worktree remained aligned with `origin/main` at `0/0`. The five protected generated Flutter files remained the only pre-existing dirty files. This closure document is intentionally uncommitted for review.

## Controlled Exclusions

The following remain out of scope: drag-and-drop, freeform positioning, resizing, multiple saved layouts, per-device profiles, cloud sync, backend integration, network calls, MCP operations, GAIA integration, NEOS dependency, and LANE-01 implementation.

## Closure Decision

Dashboard Phase 5 personalization is complete and safe to close. The next programme slice should be selected from the broader roadmap after pre-commit review; no additional Phase 5 personalization work is required.
