# New Earth Command Dashboard Module Relations

Relationships and handoffs between the active module lanes.

<!-- AUTO-GENERATED:START -->
## Why This Exists
- Use this note when you want to see how module changes travel across the system.
- It shows upstream and downstream relationships rather than a simple lane list.

## Module Relationships
| Module | Feeds Into | Relation |
| --- | --- | --- |
| Dashboard | Projects, Tasks, Treasury | Capture and overview work often starts here and routes outward. |
| Projects | Dashboard, Knowledge, Meetings | Project context gathers evidence and links to follow-up workflows. |
| Tasks | Dashboard, Projects, Treasury | Task review turns captured work into the next practical action. |
| Treasury | Projects, Tasks, Assets | Treasury work often depends on project context and leads into asset handling. |
| Knowledge | Projects, Meetings, Obsidian Sync | Knowledge extraction feeds back into project memory and vault notes. |
| Meetings | Projects, Tasks, Knowledge | Meeting bundles create inputs for follow-up tasks and archive notes. |
| Voice | Dashboard, Projects, Tasks | Voice capture is a front door to other lanes, but remains parked for now. |
| Obsidian Sync | All lanes | Exports and vault notes depend on the rest of the repo being kept in sync. |

## Change Handoffs
- If Dashboard changes, re-check Projects and Tasks because they share the user-facing handoff path.
- If Treasury changes, verify the asset and QR workflows before the lane is considered stable.
- If Knowledge changes, confirm that extraction and sync notes still line up with the source files.
- If Meetings changes, confirm that task carry-forward and project references still resolve cleanly.
- If Obsidian Sync changes, update the registry, graph, map, and status notes together.

## Reading Guide
- Upstream means the module usually supplies context or input.
- Downstream means the module often receives follow-up work or generated output.
- Shared means the modules should be reviewed together when one changes.

## Cross-Checks
- [[NEW_EARTH_DASHBOARD_PROJECT_MAP]]
- [[NEW_EARTH_DASHBOARD_MODULE_STATUS]]
- [[NEW_EARTH_DASHBOARD_PROJECT_GRAPH]]
- [[NEW_EARTH_DASHBOARD_CURRENT_STATE]]

## Operating Rule
- When one lane changes, scan the related lanes before calling the slice complete.
<!-- AUTO-GENERATED:END -->
