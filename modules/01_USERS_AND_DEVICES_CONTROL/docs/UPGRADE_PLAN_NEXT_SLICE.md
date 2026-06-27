# Users & Devices Control - Next Slice Upgrade Plan

This is the next practical upgrade plan for the module after the onboarding report and printable packs.

## Goal

Move the access layer from a good guided demo into a stronger local operator system without losing clarity.

## Phase 1 - Operator safety

1. Add a dedicated lock-state banner to every protected module route.
2. Surface the currently selected user and device more clearly in protected screens.
3. Add stronger blocked-state summaries for missing role, PIN, trust, and approval.

## Phase 2 - PIN governance

4. Add expiry and rotation guidance for recovery PINs.
5. Add a per-user PIN event timeline in the PIN Registry.
6. Add a safer revoke-and-replace workflow for primary PIN changes.

## Phase 3 - Device trust

7. Add a device trust review queue for devices still in `Needs review`.
8. Add clearer trust posture reasons on each device card.
9. Add a trust drill checklist directly inside Device Onboarding.

## Phase 4 - Admin reporting

10. Expand the Onboarding Report into a broader readiness dashboard.
11. Add filters for archived, blocked, and exception-only users.
12. Add export options for handoff sheet, readiness summary, and trust review.

## Phase 5 - Audit hardening

13. Add audit grouping by user, device, module, and action family.
14. Add a latest-risk panel for failed unlocks, repeated denials, and stale trust.
15. Add a calmer incident summary export for review with Peter or Hayley.

## Phase 6 - Data migration finish

16. Move the remaining user and device demo state fully into SQLite-first storage.
17. Keep JSON seeds only as first-run demo and fallback material.
18. Add a small migration health check screen for local support.

## Phase 7 - Future-ready security

19. Prepare passkey-ready data structures without enabling cloud login.
20. Keep local-first unlock as the default until the next security review approves expansion.

## Testing focus for the next slice

- unlock and relock loops
- per-user PIN assignment and recovery
- trusted versus blocked device behavior
- route protection while locked
- export and audit consistency
