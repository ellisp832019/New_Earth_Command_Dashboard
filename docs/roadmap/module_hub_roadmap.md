# Module Hub Roadmap

This roadmap keeps the Module Hub local-first, calm, and reviewable.

The Module Hub is the control center for discovering dashboard modules, checking what they need, and deciding what is enabled locally.

## Current Status

- Phase 1 complete: registry foundation
- Phase 2 complete: enabled-state persistence
- Next active phase: browsing and search

## Phase 1 - Registry Foundation

Goal:
Build the first working module registry and show modules in a calm hub view.

Includes:
- discover local module folders
- read manifests and infer fallback metadata
- show module cards in the hub
- show status, health, permissions, install path, and dockability
- open module detail, settings, and permissions screens

Success result:
The user can open the Module Hub and inspect the current module inventory.

## Phase 2 - Persistence And State

Goal:
Keep the enable/disable state local and stable across app restarts.

Includes:
- persist enabled and disabled state locally
- reload saved state on app start
- keep settings and detail screens in sync
- test manifest loading and state persistence

Success result:
The hub remembers module state after restart.

## Phase 3 - Browsing And Search

Goal:
Make the hub easier to scan as the module count grows.

Includes:
- search by name, tag, category, and path
- filters for status, category, dockability, and permissions
- sort options for quick scanning
- clearer empty states

Success result:
The user can find a module quickly without feeling overloaded.

## Phase 4 - Module Detail Depth

Goal:
Give each module a clearer inspection surface.

Includes:
- health breakdown
- warnings and next action
- richer manifest metadata
- permissions review
- logs or notes panels where useful

Success result:
The user can understand what the module does and what it needs.

## Phase 5 - Module Operations

Goal:
Add safe local operations around modules.

Includes:
- install or import module flow
- refresh or rescan
- update checks for local packages
- archive or remove where needed

Success result:
The hub can manage the module inventory instead of only viewing it.

## Phase 6 - Layout And Docking

Goal:
Let the hub act as a launcher and layout controller.

Includes:
- per-module dock placement controls
- pinned module shortcuts
- launch into dock surfaces
- dashboard entry points for favorite modules

Success result:
The hub becomes a practical launch point for the working system.

## Phase 7 - Safety And Governance

Goal:
Keep module actions explicit and safe.

Includes:
- approval screens for sensitive permissions
- manifest validation rules
- warnings for incomplete or risky modules
- audit logs for local actions

Success result:
The hub stays safe even as module power grows.

## Phase 8 - Polish And Release

Goal:
Make the hub pleasant to use every day.

Includes:
- tighter copy and spacing
- clearer empty states
- end-to-end tests
- Windows build verification
- doc updates

Success result:
The Module Hub is ready to stay in the regular workflow.

## Recommended Next Order

1. Browsing and search
2. Module detail depth
3. Module operations
4. Layout and docking
5. Safety and governance
6. Polish and release

