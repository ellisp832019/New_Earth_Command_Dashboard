# Programme Summary UI

## Host Experience

The GAIA Employee screen keeps the existing read-only boundary messaging and adds an explicit programme intelligence tab.

The host surface exposes:

- current backend status
- programme summary freshness
- project officer summary freshness
- a manual refresh action
- a link back to the standalone GAIA Control Centre

## Tabs

### Operations

This tab preserves the existing GAIA dashboard module view.

It continues to show the legacy read-only operations summary and the package-owned project officer surface.

### Programme Intelligence

This tab renders the merged `GaiaProgrammeSummaryView` from `gaia_dashboard_module`.

The view surfaces:

- programme summary state
- project counts
- health counts
- architecture registry counts
- dependency graph counts
- change impact summary
- roadmap state
- release train readiness
- programme packages
- selected contract and review state
- cross-project evidence

## Readability

The UI keeps the Dashboard command-centre style:

- calm card-based layout
- compact status pills
- scrollable content where necessary
- no raw JSON exposure
- no mutation controls
