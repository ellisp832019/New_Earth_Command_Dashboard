# 01_USERS_AND_DEVICES_CONTROL

**Omega Module:** Users & Devices Control  
**Type:** Core security, identity, device registry, access control, approvals, and audit layer  
**Version:** 0.1.0 scaffold  
**Design:** Local-first, security-first, cloud-optional later

This module is the control brain for **who and what can access the New Earth Dashboard**.

It manages:

- Human users
- Family users
- Co-founders and collaborators
- Guests
- AI agents
- Automation scripts
- Local PCs, phones, tablets, cameras, printers, scanners, backup drives
- MicroGrow nodes and ESP32 devices
- GAIA local AI assistant
- Alexa / voice gateway devices
- Future local hubs, XR devices, and hardware interfaces

## Core rule

No user, device, AI agent, automation script, or voice gateway should access sensitive systems unless it has:

```text
Identity
Role
Permission
Trust level
Audit trail
```

## Recommended Dashboard location

```text
new-earth-dashboard/modules/01_USERS_AND_DEVICES_CONTROL/
```

## Recommended Omega OS mirror

```text
D:\NEW_EARTH_OMEGA_OS_PACK\00_CORE_SYSTEMS\01_USERS_AND_DEVICES_CONTROL
```

Alternative:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\23_AI_AND_AUTOMATION\01_USERS_AND_DEVICES_CONTROL
```

## What is inside

- Full FSD and architecture docs
- Users, devices, roles, permissions, trust levels, audit, and approval JSON examples
- TypeScript policy engine stubs
- UI screen/component stubs
- Module Hub integration notes
- Omega OS placement notes
- Codex implementation prompt
- Threat model
- Test plans
- Templates and schemas
- [User guide](./docs/USER_GUIDE.md)

## Build phases

1. Static JSON registry
2. Dashboard UI screens
3. Module Hub gatekeeper
4. Device onboarding and pairing
5. AI and voice governance
6. PIN/passkey/certificate security later

## Reading order

If you are new to the module, start with:

1. `docs/USER_GUIDE.md`
2. `docs/FSD_USERS_AND_DEVICES.md`
3. `docs/MODULE_HUB_INTEGRATION.md`
4. `docs/FUTURE_ROADMAP.md`
