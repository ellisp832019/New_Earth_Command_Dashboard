# Users & Devices Control - User Guide

Local security layer for identities, devices, approvals, and audit.

## What it does

Use this module to check whether a user or device can open a sensitive dashboard area.

It manages:

- users
- devices
- roles
- permissions
- trust levels
- approvals
- audit events

The module home now also shows a short access plan so the main security flow is easy to read at a glance.

The main app now opens on `Security Lock` first. That screen uses the New Earth desktop startup image in the background, then lets you continue into the dashboard or the optional voice gate.

A small opaque security session box now sits in the top-left corner of the desktop shell. It shows whether the session is active, the active user, whether that user is online, the timeout window, and a live countdown to expiry. You can tap it to return to `Security Lock` or jump to `Access Matrix`.

## Startup flow

Use this flow when you want to understand how the app opens now:

1. Launch the app.
2. Review `Security Lock`.
3. Pick the local user and device.
4. Unlock into the dashboard, or into the voice gate if that option is turned on.
5. Open `Settings` if you want to show or hide the voice startup gate.
6. Use the top-left session box to check the live countdown, active user, and online status during testing.

Quick checks:

- `Active user` should match the person you just unlocked with
- `Status: online` should appear when the local session is active
- The countdown should keep moving once per second

## Start here

If you are opening the module for the first time, do this first:

1. Open `Users & Devices Control`.
2. Click `Reset demo data`.
3. Open `Users` and confirm `Hayley Arthur` exists.
4. Open `Devices` and confirm `NEW_EARTH_DEV` exists.
5. Open `Access Matrix` and confirm Treasury needs finance permission plus the trust floor.
6. Open the Treasury gate with the seeded user and device.
7. Check `Audit Log` after the decision.
8. If the voice startup gate is enabled, continue there next and confirm the headset check appears after the lock screen.

## Core rule

Before a sensitive module opens, the system needs:

- identity
- role
- permission
- trust level
- audit trail

If anything is missing, the gate should explain what is missing and why.

The startup lock is the first check. The voice gate is optional and should only be used when you want the headset readiness step at startup.

## Treasury example

Treasury is a good example because it is a sensitive finance area.

Current rules:

- `finance.view` for viewing
- `finance.edit` for editing
- `finance.admin` for the most sensitive finance control
- trust level `4` or higher for module access
- approval for actions like `delete_record`, `export_data`, and `change_bank_details`

Seeded example data:

- `Hayley Arthur` is a `Co-founder` with finance view/edit access
- `NEW_EARTH_DEV` is a trusted local device with trust level `4`

## How to use the seed demo

Use the seed demo when you want a safe local test setup without building records by hand.

### Seed a sample user

Use `Seed sample user` when you want a new local identity to test with.

What it does:

- adds a sample user record
- gives you a user you can inspect in `Users`
- helps you test the permission side of access

When to use it:

- you want to test a blocked or allowed user path
- you want to compare a finance user with a lighter user
- you want to reset the flow without creating a custom person first

Click-by-click:

1. Open `Users`.
2. Click `Seed sample user`.
3. Wait for the new user card to appear.
4. Open the new user and check the role and permissions.

### Seed a sample device

Use `Seed sample device` when you want a test device to work with.

What it does:

- adds a sample device record
- gives you a device you can inspect in `Devices`
- helps you test the trust side of access

When to use it:

- you want to test a low-trust or trusted device path
- you want to compare one device against another
- you want to check how the gate reacts to owner and trust changes

Click-by-click:

1. Open `Devices`.
2. Click `Seed sample device`.
3. Wait for the new device card to appear.
4. Open the new device and check the trust level and owner.

### Create a sample approval

Use `Create sample approval` when you want to watch the approval queue fill and clear.

What it does:

- adds a local approval request
- gives you something to review in `Approval Queue`
- helps you test the approval step without triggering a real risky action first

When to use it:

- you want to test the approve and deny buttons
- you want to see how the audit trail records approval handling
- you want to confirm the queue is wired correctly

Click-by-click:

1. Open `Approval Queue`.
2. Click `Create sample approval`.
3. Review the new request.
4. Approve it or deny it.
5. Check `Audit Log` to see the recorded decision.

### Reset demo data

Use `Reset demo data` when you want to return to the seeded local state.

What it does:

- clears the current demo state
- restores the seeded users, devices, approvals, and audit entries
- gives you a known starting point for repeat testing

When to use it:

- you have changed the seed data and want a fresh start
- you want to repeat the same test several times
- you want to compare a clean allow path with a blocked path

Click-by-click:

1. Open `Users & Devices Control`.
2. Click `Reset demo data`.
3. Wait for the seeded users, devices, approvals, and audit entries to come back.
4. Start the checklist again from the top.

## Quick test checklist

1. Open `Users & Devices Control`.
2. Click `Reset demo data`.
3. Open `Users` and confirm `Hayley Arthur` is active.
4. Open `Devices` and confirm `NEW_EARTH_DEV` is trust level `4`.
5. Open `Access Matrix` and confirm Treasury needs finance permission plus the trust floor.
6. Open the Treasury gate with `Hayley Arthur` and `NEW_EARTH_DEV`.
7. Confirm a normal Treasury open is allowed.
8. Switch to a low-trust device or lighter user and confirm the gate blocks access.
9. Try an approval-required action if the screen offers one.
10. Open `Audit Log` and confirm the allow, deny, or approval event was written.
11. Search the audit log by actor, device, module, action, or reason.
12. Switch the audit result filter to narrow the trail to allowed, denied, or pending events.
13. Open `Security Lock` from app start and confirm the New Earth desktop image appears behind the gate.
14. Turn the voice startup gate on in `Settings` if you want the headset check after unlock.
15. Turn it off again if you want startup to go straight from `Security Lock` to the dashboard.
16. Watch the top-left security session box count down while the session is active.
17. Tap the box to return to `Security Lock`, or use the `Access Matrix` shortcut inside it when you want to inspect the rules again.

## Step-by-step Treasury walkthrough

Use this when you want to test Treasury in order and see each decision point.

1. Open the Dashboard Module Hub.
Why this matters: this is the entry point that decides whether the security layer is in the path.
2. Select `Users & Devices Control`.
Why this matters: you want the local registry open before you test any sensitive access.
3. Open `Users`.
Why this matters: the user must exist and be active before Treasury can open.
4. Find `Hayley Arthur`.
Why this matters: she is the seeded finance example for testing the normal path.
5. Confirm the user is active and has finance access.
Why this matters: the role and permission must both support finance work.
6. Open `Devices`.
Why this matters: device trust is part of the access decision, not just the user.
7. Find `NEW_EARTH_DEV`.
Why this matters: it is the seeded trusted device for the normal Treasury path.
8. Confirm the device is trusted at level `4`.
Why this matters: Treasury requires the trust floor to be met.
9. Open `Access Matrix`.
Why this matters: the rule tells you what Treasury needs before you try the gate.
10. Confirm Treasury needs finance permission and a trust floor of `4`.
Why this matters: it confirms the system will check both permission and trust.
11. Open the Treasury gate.
Why this matters: this is the actual check before Treasury opens.
12. Select `Hayley Arthur` and `NEW_EARTH_DEV`.
Why this matters: the gate needs both the user and device selected at the same time.
13. Click `Open screen`.
Why this matters: this is the moment the gate either allows or blocks access.
14. If Treasury opens, test a normal view action.
Why this matters: it proves the normal finance path works after the gate passes.
15. If the gate blocks, read `Why blocked` and fix the missing identity, permission, trust, or approval.
Why this matters: the block message tells you exactly which part of the rule failed.
16. If the action needs approval, open `Approval Queue`.
Why this matters: approval-required actions should pause for human review.
17. Review the pending request.
Why this matters: you need to confirm the request is the one you meant to test.
18. Approve or deny the request.
Why this matters: this is the human decision point for sensitive actions.
19. Try the action again if approval was granted.
Why this matters: the action should only continue after approval has been recorded.
20. Open `Audit Log` and confirm the decision was recorded.
Why this matters: the audit trail proves what happened and why.

What you should see:

- The Treasury gate shows the selected user and device.
- A valid Treasury setup opens the screen.
- A bad setup shows `Why blocked`.
- An approval-only action moves into `Approval Queue`.
- The final decision appears in `Audit Log`.

## Step-by-step access system walkthrough

Use this when you want to test the whole access system from start to finish.

1. Open `Users & Devices Control`.
Why this matters: you want the access system reset to a known local state.
2. Click `Reset demo data`.
Why this matters: a clean seed state makes the later test results easier to trust.
3. Open `Users` and check the sample users.
Why this matters: you need to know which identities are available for the test.
4. Open `Devices` and compare the trust levels.
Why this matters: the trust floor only makes sense when you compare devices side by side.
5. Open `Access Matrix` and inspect Treasury rules.
Why this matters: the rule tells you what the gate will accept or reject.
6. Open the Treasury gate with a trusted user and device.
Why this matters: this is the main allow path you want to prove works.
7. Confirm the allow path works.
Why this matters: it shows the basic role, trust, and permission combo is valid.
8. Switch to a lower-trust device and confirm the block path works.
Why this matters: the system should reject devices that do not meet Treasury's trust floor.
9. Switch to a lighter user and confirm the permission block works.
Why this matters: the system should reject users who lack the needed finance access.
10. Trigger an approval-required action and confirm it pauses for review.
Why this matters: sensitive actions should not execute instantly.
11. Open `Approval Queue` and process the request.
Why this matters: human review is the control point for risky actions.
12. Review the result in `Audit Log`.
Why this matters: every allow, deny, or approval should leave a trace.
13. Open `Device Onboarding` and register a sample device if you want to test trust setup.
Why this matters: onboarding is how a device becomes trusted enough for later access.
14. Open `Security Lock` and confirm the selected context matches what you expect.
Why this matters: the lock view is a quick sanity check for the current local context.
15. Watch the top-left session box count down while the session stays active, and confirm the active user label and online status match what you expect.
Why this matters: you can see the live timeout instead of guessing.
16. Tap the session box to reopen `Security Lock` or use `Access Matrix` if you want to inspect the rule set mid-test.
Why this matters: the corner box is a quick navigation and status shortcut.
17. Reset demo data and repeat the flow until the results feel familiar.
Why this matters: repetition makes the rules easier to trust and remember.

What you should see:

- The trusted user and device path is allowed.
- The low-trust device path is blocked.
- The lighter user path is blocked for permission reasons.
- The approval path pauses until review happens.
- Device onboarding writes a new trusted record.
- Security Lock matches the current local context.

## What each screen is for

### Users

Check the person. Confirm the role, permissions, and linked devices.

### Devices

Check the device. Confirm the trust level, owner, and allowed actions.

### Access Matrix

Check the rule. Confirm the required permission, trust floor, and approval rules.

### Device Onboarding

Use this when a new device needs to become trusted.

### Approval Queue

Use this when a valid action needs human review before it can continue.

### Audit Log

Use this to verify what happened and why the system allowed, denied, or paused access.

## Full Treasury walkthrough

Use this if you want the Treasury-only version with a tighter path.

1. Open the Dashboard Module Hub.
Why this matters: this is the entry point where you first reach the control layer.
2. Select `Users & Devices Control`.
Why this matters: Treasury cannot be checked until the local registry is open.
3. Open `Users` and confirm the finance user is active.
Why this matters: the person has to exist and be active before finance access can work.
4. Open `Devices` and confirm the device is trusted enough.
Why this matters: Treasury depends on device trust as well as user identity.
5. Open `Access Matrix` and confirm Treasury needs the right permission and trust floor.
Why this matters: this tells you exactly what the gate will require.
6. Open the Treasury gate.
Why this matters: this is the actual allow/deny checkpoint.
7. Select the user and device.
Why this matters: the gate uses both selections together.
8. Click `Open screen`.
Why this matters: this is the moment the gate decides whether to let Treasury open.
9. If blocked, read `Why blocked` and fix the missing identity, permission, trust, or approval.
Why this matters: the block message points to the exact missing piece.
10. If approval is needed, review `Approval Queue`, approve or deny it, then try again.
Why this matters: sensitive actions should pause for a human decision.
11. Open `Audit Log` and confirm the decision was recorded.
Why this matters: the audit trail proves what happened and why.

## If something looks wrong

Check these first:

- Is the selected user archived?
- Is the selected device blocked or low trust?
- Does the role have the right permission?
- Is the action waiting for approval?
- Did the gate write an audit event?

## Common mistakes

These are the most common reasons a test does not behave as expected.

- You clicked `Open screen` before selecting both the user and the device.
- You used a low-trust device for the Treasury path.
- You tested a user that does not have finance permissions.
- You forgot to reset the demo data after changing the seed state.
- You looked for the approval result before processing the request in `Approval Queue`.
- You expected the audit log to change before the action was actually allowed or denied.
- You seeded a new item but did not refresh or re-open the relevant screen.

## Safe habit

For Treasury, always check:

1. the person
2. the device
3. the permission
4. the trust floor
5. whether the action needs approval
6. the audit trail
