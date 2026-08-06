# Commit Split Plan

This plan shows how I would split the next larger users-and-devices upgrade batch into small, reviewable commits.

It is a planning guide, not a record of current uncommitted work.

## Why Split Commits

The Users & Devices work touches access, PINs, session state, onboarding, and docs.
Those pieces are easier to review and safer to debug when they land in separate commits.

## Recommended Split

### 1. Security gate and session cleanup

Scope:

- tighten the startup lock path
- keep the remembered user/device flow stable
- remove duplicate unlock affordances
- keep the security session box and countdown clear

Suggested commit message:

- `feat(security): tighten session gate and unlock flow`

### 2. PIN registry and per-user PIN handling

Scope:

- keep one primary PIN record per user
- support recovery PIN issuance and revocation
- fix PIN registry layout and entry points
- keep PIN audit events visible

Suggested commit message:

- `feat(users-devices): harden per-user pin registry`

### 3. Device trust and onboarding polish

Scope:

- improve device onboarding entry points
- keep trust posture readable
- make trusted device selection clearer
- surface trust state in the module home

Suggested commit message:

- `feat(users-devices): refine device trust onboarding`

### 4. Module hub and dashboard surfacing

Scope:

- keep the module easy to reach from the dashboard
- preserve the calm summary card on the home screen
- keep shortcuts and navigation labels consistent

Suggested commit message:

- `feat(navigation): surface users-devices module more clearly`

### 5. Documentation and visuals

Scope:

- update the user guide
- keep the click-by-click walkthrough current
- maintain the access-flow diagrams and onboarding visuals
- document the test checklist

Suggested commit message:

- `docs(users-devices): refresh guide and visual flow docs`

## Commit Ordering Rule

1. Land the code that makes the flow work.
2. Land the UI polish that makes it understandable.
3. Land the docs and visuals last so they describe the final state.

## If A Batch Grows Too Large

Split again by the most independent surface:

- security session
- PIN registry
- device onboarding
- dashboard surfacing
- documentation

## Review Checklist

Before each commit:

- run `flutter analyze`
- confirm the app still starts
- test the touched flow once
- keep the diff scoped to one idea
