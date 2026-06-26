# Users & Devices Upgrade Roadmap

This roadmap turns the current Users & Devices work into a calmer upgrade path.

Use it after the current security lock, PIN registry, and access gate baseline.

## Current Read

What already exists:

- startup `Security Lock`
- remembered local identity flow
- local PIN registry with database-first storage
- per-user primary and recovery PIN handling
- device trust and access matrix checks
- audit trail and approval surfacing
- session side panel with countdown and active user state
- user guide diagrams and walkthroughs

What is still missing:

- stronger route-level enforcement across every module entry
- cleaner admin governance for PIN resets and user recovery
- richer device trust evidence and quarantine flow
- better lockout and failed-attempt handling
- clearer operator dashboards for onboarding and exceptions
- release-grade migration coverage across the whole data layer

## Upgrade Goal

Make Users & Devices Control feel like a dependable local security system, not just a demo gate.

That means:

- clearer identity ownership
- stronger route protection
- calmer recovery tools
- better audit visibility
- safer persistence

## Recommended Order

### Upgrade 1 - Route protection sweep

Goal:

- make sure every sensitive route checks the active local session before opening
- remove bypass paths from direct links, helper buttons, and secondary navigation

Main work:

- audit `go_router` entry points
- gate sensitive module routes through one shared session rule
- make blocked routes return to `Security Lock` with a clear message

Check:

- locked session cannot open sensitive pages from deep links or shortcut buttons
- allowed routes still open quickly once unlocked

### Upgrade 2 - Failed unlock and lockout rules

Goal:

- slow down brute-force PIN guessing without making normal use painful

Main work:

- add per-user failed attempt counters
- add timed lockout after repeated failures
- write lockout and retry events to audit history

Check:

- repeated wrong PINs trigger a visible cooldown
- correct PIN works again after cooldown ends or admin recovery

### Upgrade 3 - Recovery and admin reset flow

Goal:

- give operators one clear path for lost PIN handling

Main work:

- add reset reason capture
- add operator note field for recovery actions
- distinguish recovery issuance, recovery use, and forced reset in audit history

Check:

- support person can rotate a user's PIN safely
- recovery actions are traceable later

### Upgrade 4 - User onboarding workspace

Goal:

- turn onboarding into a guided flow instead of scattered screens

Main work:

- add a staged checklist for create user -> assign role -> assign PIN -> trust device -> verify access
- show incomplete onboarding steps clearly

Check:

- a brand-new user can be brought to working state from one guided flow

### Upgrade 5 - Device trust evidence

Goal:

- make device trust feel earned and explainable

Main work:

- show why a device is trusted, pending, downgraded, or blocked
- add trust evidence fields such as last seen, operator note, trust source, and trust review date

Check:

- device cards explain trust state without opening code or logs

### Upgrade 6 - Device quarantine and revoke flow

Goal:

- make compromised or retired devices easy to remove from trusted use

Main work:

- add quarantine state
- add revoke trust flow
- surface trust revocation in session and gate checks

Check:

- a quarantined device cannot unlock protected routes
- audit trail explains why access failed

### Upgrade 7 - Approval workflow polish

Goal:

- make approvals readable enough for day-to-day use

Main work:

- show pending approvals by module, user, and reason
- show completed approvals and expiry state
- clarify whether approval is still required after trust or permission changes

Check:

- operator can tell exactly which approval is blocking access

### Upgrade 8 - Access review dashboard

Goal:

- provide one calm review surface for security posture

Main work:

- add summary cards for locked users, recovery PINs, quarantined devices, pending approvals, and recent failed unlocks
- add drill-down links into the right screen

Check:

- security review can happen from one place instead of multiple tabs

### Upgrade 9 - Persistence and migration hardening

Goal:

- finish the database migration work around users, devices, PINs, and audit records

Main work:

- move remaining fallback demo sources into stable SQLite-backed repositories where appropriate
- add migration tests for legacy PIN and audit data
- verify app boot on upgrade scenarios

Check:

- old demo data upgrades cleanly
- no duplicate or lost PIN records appear after migration

### Upgrade 10 - Release verification and docs pass

Goal:

- make the module testable by someone other than the builder

Main work:

- expand focused widget and repository tests
- add manual test checklist for onboarding, unlock, lockout, recovery, trust revoke, and gated-route checks
- refresh the user guide and diagrams to match the final flow

Check:

- operator can follow the guide and verify the whole flow without guessing

## Suggested Commit Shape

Use small slices like this:

1. `feat(security): enforce route gating across sensitive modules`
2. `feat(security): add failed unlock lockout rules`
3. `feat(users-devices): add recovery and admin reset workflow`
4. `feat(users-devices): add guided onboarding workspace`
5. `feat(users-devices): surface device trust evidence`
6. `feat(users-devices): add quarantine and revoke flow`
7. `feat(users-devices): polish approval review surfaces`
8. `feat(users-devices): add access review dashboard`
9. `feat(users-devices): harden persistence and migrations`
10. `docs(users-devices): refresh guide, checklist, and visuals`

## Recommended Verification Per Slice

After each upgrade:

1. Run `flutter analyze`
2. Run the smallest relevant test file first
3. Run `flutter test` if shared security logic changed
4. Launch `flutter run -d windows`
5. Manually test one happy path and one blocked path

## Best Next Build

If only one upgrade should start next, do this one first:

- **Upgrade 1 - Route protection sweep**

Reason:

- it closes the most important bypass risk
- it improves the whole app, not just the module screen
- it gives every later upgrade a safer base
