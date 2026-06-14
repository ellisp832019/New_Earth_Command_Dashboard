# Module Hub Roadmap

This roadmap keeps the Module Hub local-first, calm, and reviewable.

The Module Hub is the control center for discovering dashboard modules, checking what they need, and deciding what is enabled locally.

## Completed

### Registry Foundation

Done:
- discover local module folders
- read manifests and infer fallback metadata
- show module cards in the hub
- show status, health, permissions, install path, and dockability
- open module detail, settings, and permissions screens

Result:
The user can open the Module Hub and inspect the current module inventory.

### Persistence And State

Done:
- persist enabled and disabled state locally
- reload saved state on app start
- keep settings and detail screens in sync
- test manifest loading and state persistence

Result:
The hub remembers module state after restart.

### Browsing And Search

Done:
- search by name, tag, category, path, permissions, and dockability
- filters for status, category, dockability, and permissions
- sort options for quick scanning
- clearer empty states

Result:
The user can find a module quickly without feeling overloaded.

### Module Detail Depth

Done:
- health breakdown
- warnings and next action
- richer manifest metadata
- permissions review
- logs and notes panels

Result:
The user can understand what the module does and what it needs.

### Module Operations

Done:
- refresh and rescan local module registry
- inspect install and Omega OS paths
- jump back into settings, permissions, docking, and governance
- keep install/import and archive/remove flows staged safely for later wiring

Result:
The hub can manage the module inventory in small local steps instead of only viewing it.

### Layout And Docking

Done:
- dock preview by position
- local pin toggle for layout planning
- placement snapshot for the active module
- dock launch handoff

Result:
The hub can act as a practical launcher and layout controller.

### Safety And Governance

Done:
- validation checklist
- sensitive permission review
- audit trail placeholder
- navigation into permissions, operations, and docking from one review surface

Result:
The hub keeps module actions explicit and safe.

### Polish And Release

Done:
- tighter copy and spacing
- back navigation to More
- truthful scaffold versus planned status labels
- clearer action labels across detail and sub-screens
- saved browse state for search, filters, sort, and view mode
- focused end-to-end and repository tests
- Windows build verification

Result:
The Module Hub is pleasant to use, stays honest about module state, remembers how it was being used, and still builds on Windows.

## Later

### Live Dock Rollout

Planned:
- add a shell-level dock host in the app shell
- mount one real docked module into the host
- persist dock position and restore it on app start
- add Treasury as the second live docked module once the first dock is stable
- keep the preview screen as the place to choose layout, not the place where docking actually happens

## Recommended Rollout Order

1. Add the shell-level dock host.
2. Mount `Backup Guardian` as the first live docked module.
3. Persist and restore the saved dock position.
4. Add `Treasury` as the second live docked module after the first one feels stable.
5. Keep drag-and-drop or multi-window behavior for a later phase.

## Recommended Next Order

1. Start the live dock rollout with `Backup Guardian`.
2. Keep the dock host narrow and trustworthy.
3. Return to the next active product slice after the dock baseline is working.
