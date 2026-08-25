# Dashboard Card Personalization

Phase 5A adds a small presentation preference layer for the Dashboard. It controls only card visibility and deterministic order for the human-facing workspace.

## Card Identity And Default Order

Stable IDs are defined in `DashboardCardLayout`:

1. `daily_flow`
2. `next_step`
3. `treasury`
4. `command_centre`
5. `support_stack`

`daily_flow` is one unit containing Today Focus, Top 3, Active Projects, Quick Capture, and Carry Forward. It cannot be hidden or fragmented by personalization.

## Preferences

Preferences are owned by `DASHBOARD_LOCAL` and persisted as one JSON value on the existing local `AppSettings` record. The stored shape contains only ordered card IDs and hidden card IDs. No widget configuration, project data, task data, lane data, or remote state is stored.

The settings surface provides:

- visibility switches for non-critical cards
- Move Up and Move Down ordering
- Reset to Default

Hidden cards remain present in their feature stores. Reordering affects presentation only.

## Safety And Fallback

Missing, malformed, unknown, duplicate, or removed IDs are normalized safely. Known cards missing from an older preference are appended in deterministic default order. `daily_flow` is always visible.

## Future Compatibility

Future lane-aware cards can use the same stable-ID presentation seam without adding lane IDs, workflow authority, lifecycle management, GAIA control, NEOS dependency, Command Centre operations, or cross-repository writes.
