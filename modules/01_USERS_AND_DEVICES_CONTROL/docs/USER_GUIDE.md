# Users & Devices Control - User Guide

## What this module is

Users & Devices Control is the local security layer for the New Earth Command Dashboard.
It handles:

- users
- devices
- roles
- permissions
- trust levels
- approvals
- audit events

The module is designed to stay local-first. It is the place to check whether a user or device is allowed to open a sensitive dashboard area.

## The core rule

Before any sensitive module opens, the system should have:

- identity
- role
- permission
- trust level
- audit trail

If one of those is missing, the gate should explain what is missing and why.

## Where to find it

Open the Dashboard Module Hub, then choose:

- `Users & Devices Control`

You can also reach it from the module detail page for the same module through:

- `Open access gate`
- `Open module route`

## Main screens

### Users

Use this screen to manage local identities.

What you can do:

- add a user
- edit a user
- archive or restore a user
- delete a user
- seed a sample user for testing

What to check:

- display name
- role
- title
- linked devices
- permissions
- notes

### Devices

Use this screen to manage local devices.

What you can do:

- add a device
- edit a device
- archive or restore a device
- delete a device
- seed a sample device

What to check:

- device name
- type
- trust level
- owner
- allowed actions
- notes

### Access Matrix

Use this screen to inspect and edit role and permission rules.

What you can do:

- choose a user
- assign a role
- grant a permission
- review module access rules
- create a sample approval

What to check:

- whether the selected role has the needed permission
- whether the module requires a trust floor
- whether the module requires approval for specific actions

### Device Onboarding

Use this screen when a new device needs to become trusted.

What you can do:

- start the onboarding wizard
- choose a template
- register a sample device
- review trust history

What to check:

- whether the device is registered
- whether the trust level is high enough
- whether the device owner is correct

### Approval Queue

Use this screen when a request is valid but needs human review.

What you can do:

- review pending requests
- approve a request
- deny a request
- create a sample approval
- jump to the Access Matrix or Audit Log

What to check:

- requester
- device
- target module
- action
- risk level
- reason

### Audit Log

Use this screen to inspect the record of sensitive decisions.

What you can do:

- view all access and approval events
- open the latest audit event from the gate
- inspect allow and deny outcomes

What to check:

- event type
- actor
- device
- module
- action
- result
- reason

## Using the access gate

The gate is the entry point for sensitive surfaces.

### Typical flow

1. Open the Module Hub.
2. Select a sensitive module card.
3. Open the module route or the access gate.
4. Choose a local user.
5. Choose a local device.
6. Click `Open screen`.
7. If the gate blocks access, read the `Why blocked` panel.
8. Fix the missing identity, trust, permission, or approval issue.
9. Try again.

### What the gate shows

- the selected user
- the selected device
- the current status
- the latest audit event
- the reason access was blocked

### Common blocked reasons

- unknown user
- unknown device
- archived user
- blocked device
- device trust too low
- missing required permission
- approval required

## Sample actions

The module includes sample buttons so you can test the system quickly.

Common sample actions:

- `Register user`
- `Register device`
- `Create approval`
- `Open Security Lock`
- `Open latest audit`
- `View latest audit`

These are useful when you want to test the flow end to end without hand-building every record.

## Local data behavior

The module uses local data only.

How it works:

- the module starts with JSON seed files
- live users, devices, approvals, and audit events are stored locally
- the app keeps the data on the device
- no cloud login is required

## Recommended daily use

If you are onboarding someone or testing a change:

1. Open Users and confirm the identity exists.
2. Open Devices and confirm the device is trusted.
3. Open Access Matrix and confirm the role has the required permission.
4. Open Device Onboarding if trust needs to be raised.
5. Use Approval Queue for higher-risk actions.
6. Check Audit Log whenever you need a trail of what happened.

## Security reminders

- Never assume a device is trusted just because it exists.
- Never assume a role is enough without the permission.
- Never skip the audit trail.
- Use approvals for actions that are risky or sensitive.

## If something looks wrong

Check these first:

- Is the selected user archived?
- Is the selected device blocked or low trust?
- Does the role have the right permission?
- Is the action waiting for approval?
- Did the gate write an audit event?

If the module still feels incomplete, open the Security Lock screen and verify the selected local context there.

