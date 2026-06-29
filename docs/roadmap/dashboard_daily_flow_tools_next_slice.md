# Dashboard Daily Flow Tools - Next Slice

This page is the direct handoff from the completed dashboard calmness/session pass into the next dashboard build slice.

## Why this is next

The dashboard is now calmer and more visually consistent.

The next strongest improvement is not adding more status.
It is making the main daily operating loop feel tighter:

- Today Focus
- Top 3 Tasks
- Active Projects
- Quick Capture

This follows:

- `docs/roadmap/dashboard_future_roadmap.md`
- `docs/roadmap/major_upgrade_review.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`

## Completed first

These dashboard slices are now in a healthier place:

1. session visibility consistency
2. card hierarchy restraint
3. module snapshot calmness rules

That means the next slice can improve usefulness without first having to repair visual noise.

## Next slice objective

Strengthen the dashboard's daily flow so the home screen answers three questions more clearly:

1. what should I do now?
2. what supports that work?
3. what can I safely capture or carry forward without losing it?

## Build targets

### 1. Today to Top 3 handoff

Make the relationship between the Today panel and Top 3 more explicit.

Success looks like:

- the user understands how the chosen focus becomes real work
- the Today panel does not feel disconnected from the Top 3 block

### 2. Active Projects as support context

Keep projects visible, but clearly subordinate to the daily focus.

Success looks like:

- active projects read as context, not competing priorities
- progress and route actions stay useful at a glance

### 3. Quick Capture as a safe side lane

Preserve speed and availability while keeping capture secondary to committed work.

Success looks like:

- capture stays one step away
- it feels like a relief valve, not the main work surface

### 4. Carry-forward and tomorrow-focus cues

Use existing dashboard and planner surfaces more intentionally.

Success looks like:

- the user sees how work can move forward calmly
- the dashboard feels supportive on both high-energy and low-energy days

## Visual review assets

These rendered assets support this handoff:

- [Dashboard calmness review](images/dashboard_calmness_review.png)
- [Dashboard daily flow tools](images/dashboard_daily_flow_tools.png)

## Suggested test themes

When this slice is built, verify:

1. app open still orients the user in one glance
2. Today Focus and Top 3 still persist and reopen correctly
3. Active Projects routes still open correctly
4. Quick Capture remains fast and low-friction
5. analyzer, widget tests, and Windows build all stay green

## Practical note

Do not let this slice become a dashboard expansion pass.

The goal is:

- better flow
- better hierarchy
- better handoff

Not:

- more tiles
- more metrics
- more noise
