# Test Plan

## UI tests

- Modules screen loads.
- All mock modules render as cards.
- Module card status chips display correctly.
- Detail screen opens for every module.
- Permission list displays correctly.
- Health panel displays placeholder values.
- Dock panel placeholder opens.

## Model tests

- Manifest can be parsed.
- Missing optional fields do not break the UI.
- Unknown category falls back to `Other`.
- Unknown status falls back to `installed` or `disabled`.

## Future integration tests

- Manifest loading from plugins folder.
- Enable/disable state persists.
- Permission state persists.
- Backend health check updates module health.
- WebSocket events update logs.

## Manual acceptance checklist

- The dashboard feels like it has a real module command centre.
- No real backend is required for first version.
- It is obvious where future modules will plug in.
- Permission gating is visible from day one.
