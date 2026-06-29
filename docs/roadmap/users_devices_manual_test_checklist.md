# Users & Devices Manual Test Checklist

Use this checklist after route protection, lockout, PIN recovery, or session changes.

This is the practical operator test pass for the local trust layer.

## 1. Startup lock entry

1. Launch the app from a fully closed state.
2. Confirm the app opens on `Security Lock`.
3. Confirm no protected module opens first.
4. Confirm the session pill shows `Locked`.

## 2. Locked-route protection

1. While locked, try to open:
   - Users & Devices
   - Users
   - Devices
   - Access Matrix
   - Audit
   - PIN Registry
   - Treasury
2. Confirm each route returns to `Security Lock`.
3. Confirm the lock screen keeps the intended resume route.

## 3. Happy-path unlock

1. Select a valid local user and paired device.
2. Enter the correct primary PIN.
3. Confirm unlock succeeds.
4. Confirm the app resumes to the intended protected route.
5. Confirm the session pill shows `Active`.

## 4. Failed PIN attempt visibility

1. Pick a valid user and paired device.
2. Enter a wrong PIN once.
3. Confirm unlock stays blocked.
4. Confirm the lock screen explains the mismatch.
5. Confirm the message shows remaining-attempt guidance before lockout.
6. Open the audit log after unlock and confirm the failed attempt was recorded.

## 5. Lockout behaviour

1. Enter the wrong PIN repeatedly until lockout triggers.
2. Confirm the UI changes from mismatch guidance to cooldown guidance.
3. Confirm a valid PIN still fails during the cooldown window.
4. Confirm the audit log contains:
   - failed PIN attempt entries
   - a lockout-triggered entry
   - an already-locked entry if a retry happens during cooldown
5. Wait until the cooldown ends.
6. Confirm a correct primary PIN succeeds again.

## 6. Recovery PIN flow

1. Unlock the session.
2. Open `Users & Devices -> PIN Registry`.
3. Pick a user.
4. Issue a recovery PIN with a reason and operator note.
5. Confirm the recovery PIN is shown clearly once.
6. Lock the session again.
7. Use the recovery PIN on `Security Lock`.
8. Confirm unlock succeeds.
9. Confirm the audit log shows:
   - recovery PIN issued
   - recovery PIN used

## 7. Forced reset flow

1. Open `PIN Registry`.
2. Pick a user with an existing primary PIN.
3. Use `Force reset primary PIN`.
4. Enter a new primary PIN.
5. Add the reset reason and operator note.
6. Confirm the old primary PIN no longer works.
7. Confirm the new primary PIN does work.
8. Confirm the audit log shows a forced reset event.

## 8. Lockout clear flow

1. Create a real lockout for a user.
2. Unlock as an operator.
3. Open `PIN Registry`.
4. Use `Clear lockout timer`.
5. Add the reason and note.
6. Confirm the user can try again immediately.
7. Confirm the audit log shows the lockout-clear event.

## 9. Revoke flow

1. Revoke one recovery PIN.
2. Confirm it no longer unlocks the session.
3. Revoke all PINs for a user.
4. Confirm the user cannot unlock until a new primary or recovery PIN is issued.
5. Confirm the audit log shows revoke events.

## 10. Relock and restart confidence

1. Unlock the session.
2. Let the session timeout expire or use `Lock now`.
3. Confirm the app returns to `Security Lock`.
4. Close the app completely.
5. Reopen it.
6. Confirm the locked state is still enforced on startup.

## 11. Access review dashboard

1. Unlock the session.
2. Open `Users & Devices Control` module home.
3. Review the `Access review dashboard`.
4. Confirm the summary cards show:
   - lockout pressure
   - recovery PIN pressure
   - quarantined device pressure
   - pending approvals
   - recent denied unlocks
5. Use one drill-down action.
6. Confirm it opens the matching admin surface directly.

## 12. Approval Queue triage

1. Open `Approval Queue`.
2. Confirm the summary reads with normalized statuses.
3. Create or locate at least one pending request.
4. Confirm the request card shows module, user, device, and reason clearly.
5. Confirm any prerequisite hint explains whether permission, trust, or identity still needs work.
6. Approve or deny the request.
7. Confirm the final state is reflected in `Audit Log`.

## Pass Criteria

This slice is healthy when:

1. locked routes stay blocked
2. correct PINs unlock cleanly
3. repeated wrong PINs trigger cooldown
4. recovery and reset actions are traceable
5. access review drill-downs open the right admin surfaces
6. approval triage is readable without guesswork
7. restart and relock behaviour stay predictable
