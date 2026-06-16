# FSD — Users & Devices Control

## Purpose
Create a local-first security module for the Dashboard that controls users, devices, AI agents, roles, permissions, device trust, approvals, and audit logging.

## Screens
- Users Overview
- User Profile
- Devices Overview
- Device Profile
- Access Matrix
- Device Onboarding
- Approval Queue
- Audit Log

## Functional requirements
- Register users and devices.
- Assign roles and permissions.
- Assign device trust levels.
- Check module access.
- Check action access.
- Create approval requests for high-risk actions.
- Create audit logs for allow/deny/approval decisions.
- Treat AI agents and voice gateways as controlled identities.

## Non-functional requirements
- Local-first.
- Cloud login not required for Phase 1.
- Human-readable JSON data.
- UI-ready structures.
- Compatible with Module Hub.
- Prepared for PIN, passkey, QR pairing, local device certificates, and encrypted local storage later.
