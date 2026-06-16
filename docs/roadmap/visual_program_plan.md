# Visual Program Plan

This page lays out the image strategy for the whole New Earth Command Dashboard repo.

The goal is to keep visuals useful, consistent, and easy to expand as the system grows.

## What We Already Have

- Core architecture overview diagrams in `docs/assets/diagrams/`
- Module hub architecture images in `docs/architecture/module_hub/visuals/`
- Module gallery images in `docs/architecture/module_gallery/visuals/`
- Knowledge fabric sync diagrams in `docs/architecture/module_hub/visuals/`
- Roadmap and user-guide illustrations in `docs/assets/repo/`, `docs/assets/screenshots/`, and `docs/assets/user_guide/`

## Current Status

The visual library is past the early planning stage and now has a stable core.

### Already Stable

- Core architecture overview, database, and local-first privacy diagrams
- Module Hub shell, status, and knowledge-fabric sync diagrams
- A broad module gallery with overview images for the major active modules
- User guide visuals and repo documentation graphics

### Still Missing Or Parked

- A dedicated voice session state machine diagram
- A backup / recovery control flow diagram
- Wider system-layer maps that show how the major modules fit together
- Future-only visuals such as AI adapter and live integration diagrams

## Current Visual Working Set

These are the visual families already worth keeping current:

- Dashboard shell and core workflow
- Module Hub shell, docking, and governance
- Repo Intelligence Bridge and sync flow
- Obsidian sync and knowledge vault fabric
- Voice assistant workflow and wake/session flow
- Treasury and operational review flows
- User guide and onboarding visuals

## Phase 1 - Core System Images

Create or maintain diagrams for the core system layers:

- Dashboard shell overview
- Module Hub lifecycle and dock system
- Repo Intelligence Bridge control flow
- Obsidian sync module and vault fabric
- Voice session state machine
- Treasury / finance control flow
- Backup / recovery control flow

### Recommended next image order

1. Voice session state machine
2. Backup / recovery control flow
3. Full repo topology map
4. Shell / module / knowledge / operational layers map
5. Local-first data flow map

## Phase 2 - Module Images

Create one primary visual for each major module so the repo has a consistent image set:

- `new_earth_command_deck`
- `new_earth_launchpad_module`
- `meeting_system`
- `knowledge_engine`
- `NE_REPO_INTELLIGENCE_BRIDGE`
- `NE_OBSIDIAN_SYNC_MODULE`
- `system_backup`
- `gaia_voice_assistant`
- `voice_intelligence_module`
- `NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE`
- `funding_grants_command_centre`
- `project_repo_bridge`
- `repo_research_engine`

Each module image should answer the same questions:

- What does this module do?
- What inputs does it read?
- What outputs does it write?
- What local files or folders does it touch?
- What other modules does it connect to?

## Phase 3 - Whole-System Maps

Create wider diagrams that explain how modules fit together:

- Full repo topology
- Shell / module / knowledge / operational layers
- Local-first data flow
- Current vs future module coverage
- Dependency graph of major modules
- Dashboard to vault feedback loop
- Local sync, export, and review paths

## Phase 4 - Future Work Images

These should stay parked until the core images are stable:

- AI adapter and safe-assist architecture
- External integration strategy
- Live dock host and multi-window module layout
- Cross-repo knowledge fabric map
- Release readiness and build proof visuals
- Future module onboarding diagram

## Naming Convention

Use stable, descriptive names:

- `knowledge_fabric_sync_architecture_01_end_to_end.png`
- `knowledge_fabric_sync_architecture_02_bridge_control_panel.png`
- `knowledge_fabric_sync_architecture_03_obsidian_sync.png`
- `knowledge_fabric_sync_architecture_04_executive_overview.png`

For new module visuals, prefer:

- `module_name_overview.png`
- `module_name_flow.png`
- `module_name_architecture.png`
- `module_name_status.png`

## Recommended Order

1. Keep the current architecture and knowledge-fabric visuals clean.
2. Add one overview image per active module.
3. Add one layer map for the whole system.
4. Add future visuals only when the module or system slice is real enough to support them.

## Practical Next Step

If we are continuing the visual program now, the best use of effort is to close the remaining core-system gaps first, starting with voice session state and backup / recovery, then move on to the broader whole-system maps.

## Why This Matters

The repo is big enough that images need their own strategy.

If we keep the visuals grouped, indexed, and phase-based, we can scale the documentation without losing the plot.
