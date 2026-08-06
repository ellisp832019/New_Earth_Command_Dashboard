# Codex Task 01 - Lifecycle and Labels

## Goal

Add the first experiment workspace slice: a clear lifecycle, clearer labels, and a calmer scan path.

## Requirements

- Add experiment lifecycle states in the workspace model or UI state.
- Show the state clearly in the workspace list and detail views.
- Rename visible labels so the workspace reads as a workspace, not a generic engine.
- Keep the route and navigation behavior unchanged.
- Keep the feature local-only and review-first.

## Suggested UI changes

- Add a state chip to each experiment card.
- Add a workspace summary chip for the active state count.
- Change the main workspace title to `Omega Experiment Workspace`.
- Use `Workspace` for the primary section label.
- Use `New Draft` for the create section label.

## Acceptance Criteria

- The user can see experiment state at a glance.
- The user can tell the difference between a draft and a running experiment.
- The workspace title and labels feel consistent across the dashboard card and the main screen.
- The app still analyzes cleanly after the change.

