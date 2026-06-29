# Major Upgrade Execution Plan

This file turns the broader major-upgrade roadmap into the next practical build order.

It sits one level below `12_major_upgrade_plan.md`.

Use it when the question is:

What should we build next, in what order, and what does each stream need before it is safe to expand?

## Current Read

The repo is now in a stronger place than a simple MVP shell.

What is stable enough to build on:

- calm dashboard and daily loop foundation
- stronger planner, projects, and handoff flow
- local-first database foundation
- active specialist modules with real routes
- Users & Devices session model
- Company Command Centre read-only operations
- Omega Knowledge Engine shell and output surfaces

What still needs hardening before broad expansion:

- route-level trust enforcement consistency
- restart and migration confidence
- cleaner security/admin recovery flows
- report/export consistency
- cross-module health visibility

## Active Upgrade Order

This is the recommended execution order from the repo's current state.

### Stream 1 - Users & Devices Trust Completion

Reason:

- it is already the trust spine for startup, Treasury, and protected module work
- a weak exception here affects the whole app
- later security and reporting work becomes easier once route trust is consistent

Immediate slices:

1. route protection sweep
2. failed unlock and timed lockout review
3. recovery and admin reset workflow polish
4. onboarding workspace tightening
5. device trust evidence and quarantine flow
6. approval workflow polish
7. access review dashboard
8. persistence and migration hardening

### Stream 2 - Dashboard Calm Session Layer

Reason:

- more specialist modules are now real enough to compete for attention
- session and status visibility should stay quiet, readable, and dependable

Immediate slices:

1. session visibility consistency
2. card hierarchy restraint
3. module snapshot calmness rules

### Stream 3 - Omega Knowledge Engine Completion

Reason:

- the module already has a strong shell and clear purpose
- it should deepen through safe read-only operational maturity, not broad automation

Immediate slices:

1. repository validation and health checks
2. output preview quality
3. learning notes and architecture map quality
4. exports and error handling

### Stream 4 - Company Command Centre Safe Operations

Reason:

- the founder/admin value is already strong
- the next value comes from safe, auditable workflow maturity instead of visual expansion

Immediate slices:

1. tracker polish
2. evidence trust improvements
3. write-mode safety design

## First Active Stream Definition

The first stream to execute now is:

- `Users & Devices Trust Completion`

### Slice 1 - Route protection sweep

Goal:

- make the Security Lock the only public entry point while the app is locked
- remove locked-state bypasses into Users & Devices admin surfaces
- preserve clear resume routing after unlock

Build rules:

1. locked users can see `Security Lock`
2. locked users cannot browse Users, Devices, Access Matrix, Audit, Onboarding, or PIN Registry directly
3. blocked route attempts should preserve the intended resume route
4. lock-screen helper buttons must stay honest and not point at routes that remain blocked

Done looks like:

- locked-state redirect logic is centralized
- Users & Devices admin routes are blocked while locked
- lock-screen actions only enable deeper admin routes after unlock
- tests prove both blocked and resumed paths

### Slice 2 - Failed unlock and lockout confidence

Goal:

- make repeated bad PIN attempts visible and auditable without punishing normal use

Done looks like:

- cooldown behaviour is obvious
- audit trail shows wrong PIN and lockout events clearly
- reset and recovery behaviour stays readable

### Slice 3 - Recovery and admin reset governance

Goal:

- give operators one calm, traceable path for lost PIN handling

Done looks like:

- recovery issuance, use, revoke, and forced reset are distinct
- reason capture is mandatory where it matters
- support flow is easy to explain and test

### Slice 4 - Onboarding workspace tightening

Goal:

- give operators one guided place to see which user is ready, what is missing, and what the next safe step should be

Done looks like:

- onboarding status reads clearly from role, PIN, trust, and audit state
- the next operator action is visible without guessing
- completion view explains whether the user is ready to verify locally

### Slice 5 - Device trust evidence and quarantine flow

Goal:

- make trust explainable and give operators a deliberate way to pause risky devices

Done looks like:

- devices show trust source, review context, last-seen info, and operator notes
- quarantined devices are visible in the device workspace
- quarantined devices fail trust checks until restored

### Slice 6 - Approval workflow polish

Goal:

- make operator review easier to scan and less ambiguous

Done looks like:

- approval statuses are normalized consistently
- triage view highlights stale, risky, or blocked requests
- approval cards explain whether a deeper trust or rule issue still needs fixing first

### Slice 7 - Access review dashboard

Goal:

- give admins one calm summary for lockouts, recovery, quarantine, approvals, and denied unlocks

Done looks like:

- key security posture counts are visible from the module home
- drill-down links open the right admin surfaces directly

### Slice 8 - Persistence and migration hardening

Goal:

- prove that new trust evidence and older approval data survive local reloads cleanly

Done looks like:

- repository tests cover trust evidence round-trip
- legacy approval statuses normalize on load and stay consistent after write-back

## Repo-Wide Gates Before The Next Stream

Do not move on from Stream 1 until:

1. `flutter analyze` passes
2. focused security and routing tests pass
3. `flutter test` passes for shared logic
4. `flutter build windows` passes if runtime code changed
5. locked and unlocked manual route checks are complete
6. Users & Devices guide wording still matches the real flow
7. trust evidence and quarantine surfaces are covered by focused widget and repository tests
8. approval queue and access review surfaces are covered by focused widget tests

## Manual Test Themes For This Phase

Use these checks during the active stream:

1. startup opens `Security Lock`
2. locked session cannot open protected module routes directly
3. locked session preserves the intended destination after unlock
4. unlocked session can reach Users & Devices admin routes normally
5. PIN management only opens once the session is unlocked
6. relock returns protected routes to `Security Lock`

## Summary

The app does not mainly need more breadth right now.

It needs:

- cleaner trust enforcement
- calmer admin safety tools
- stronger route consistency
- disciplined stream-by-stream hardening

That is why the next execution order should begin with:

- Users & Devices route protection
- then unlock/lockout confidence
- then recovery governance
