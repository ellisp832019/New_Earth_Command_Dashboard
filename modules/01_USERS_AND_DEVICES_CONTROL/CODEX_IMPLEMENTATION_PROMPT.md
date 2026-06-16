# Codex Implementation Prompt — 01_USERS_AND_DEVICES_CONTROL

You are working inside the New Earth Dashboard repository.

Create/import the Omega core module:

```text
modules/01_USERS_AND_DEVICES_CONTROL/
```

Mission: implement this as the local-first identity, device registry, access-control, approvals, and audit layer for the Dashboard.

## Required steps
1. Copy this folder into `modules/01_USERS_AND_DEVICES_CONTROL/`.
2. Compare with the existing dashboard structure and align naming, imports, routing, styling, linting, and file conventions.
3. Add Module Hub card using `dashboard_integration/MODULE_HUB_CARD.example.json`.
4. Add routes for Users, Devices, Access Matrix, Device Onboarding, Approval Queue, and Audit Log.
5. Use JSON files in `data/` and `config/` as Phase 1 static data.
6. Wire or expose these functions:
   - registerUser()
   - registerDevice()
   - getUserById()
   - getDeviceById()
   - assignRole()
   - assignPermission()
   - checkPermission()
   - checkDeviceTrust()
   - canOpenModule()
   - canPerformAction()
   - createAuditEvent()
   - createApprovalRequest()
   - approveRequest()
   - denyRequest()
7. Do not add cloud auth yet.
8. Do not break existing modules.

## Security rule
No user, device, AI agent, script, or voice gateway accesses sensitive modules unless it has identity, role, permission, trust level, and audit trail.
