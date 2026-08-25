# Dashboard Daily Flow Tools

The Dashboard is a calm founder/operator workspace for one working-day loop:

`Today Focus -> Top 3 -> Active Projects -> Quick Capture -> Carry Forward`

## Authority Boundaries

- Today Focus is a Dashboard-local view backed by the existing local `DailyPlan` record.
- Top 3 references existing local task IDs and preserves their selected order. Tasks remain owned by the Tasks feature.
- Active Projects presents references and current fields from the existing Projects records. The Dashboard does not copy or own project truth.
- Quick Capture creates a temporary local Inbox item only. It cannot execute commands, create projects, call external services, or change another system's authority.
- Carry Forward is an explicit local planner decision. Saved notes and task dispositions such as complete, park, or defer are not accumulated automatically.

## Daily Flow Rules

- Today Focus may be empty or contain one concise focus.
- Top 3 contains zero to three bounded outcomes. Ordering is deterministic and stale closed or parked tasks are not shown as today's work.
- Active Projects remain supporting context, not a second priority list.
- Quick Capture is a relief valve. Captures stay in Inbox until the operator explicitly promotes, links, defers, archives, or discards them.
- Carry Forward requires an intentional review or disposition. Completed, dropped, parked, or deferred work does not silently remain in Today.

## Future LANE-01 Compatibility

The Daily Flow can later present governed lane references such as lane name, stage, mission, next action, and blocker. It does not create a Lane Registry, Workflow Registry, lane IDs, lifecycle authority, or lane administration.

## Explicitly Not Owned

Daily Flow does not own canonical projects, tasks, lanes, workflows, NEOS state, GAIA recommendations, Command Centre operations, process execution, MCP operations, or external network integrations.
