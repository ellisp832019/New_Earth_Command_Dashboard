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

## Next

### Browsing And Search

Goal:
Make the hub easier to scan as the module count grows.

Includes:
- search by name, tag, category, and path
- filters for status, category, dockability, and permissions
- sort options for quick scanning
- clearer empty states

Result:
The user can find a module quickly without feeling overloaded.

### Module Detail Depth

Goal:
Give each module a clearer inspection surface.

Includes:
- health breakdown
- warnings and next action
- richer manifest metadata
- permissions review
- logs or notes panels where useful

Result:
The user can understand what the module does and what it needs.

### Module Operations

Goal:
Add safe local operations around modules.

Includes:
- install or import module flow
- refresh or rescan
- update checks for local packages
- archive or remove where needed

Result:
The hub can manage the module inventory instead of only viewing it.

### Layout And Docking

Goal:
Let the hub act as a launcher and layout controller.

Includes:
- per-module dock placement controls
- pinned module shortcuts
- launch into dock surfaces
- dashboard entry points for favorite modules

Result:
The hub becomes a practical launch point for the working system.

### Safety And Governance

Goal:
Keep module actions explicit and safe.

Includes:
- approval screens for sensitive permissions
- manifest validation rules
- warnings for incomplete or risky modules
- audit logs for local actions

Result:
The hub stays safe even as module power grows.

## Later

### Polish And Release

Goal:
Make the hub pleasant to use every day.

Includes:
- tighter copy and spacing
- clearer empty states
- end-to-end tests
- Windows build verification
- doc updates

Result:
The Module Hub is ready to stay in the regular workflow.

## Recommended Next Order

1. Browsing and search
2. Module detail depth
3. Module operations
4. Layout and docking
5. Safety and governance
6. Polish and release
