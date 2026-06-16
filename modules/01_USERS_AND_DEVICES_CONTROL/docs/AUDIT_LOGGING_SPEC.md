# Audit Logging Spec

## Event types
- user_created
- user_role_changed
- device_created
- device_trust_changed
- permission_assigned
- module_access_allowed
- module_access_denied
- action_allowed
- action_denied
- approval_requested
- approval_approved
- approval_denied
- ai_agent_request
- voice_gateway_request

## Minimum event

```json
{
  "event_id": "audit_001",
  "timestamp": "2026-06-16T05:00:00Z",
  "actor_id": "user_peter_owner",
  "device_id": "device_new_earth_dev",
  "event_type": "module_access_checked",
  "target_module": "17_FINANCE_AND_TREASURY",
  "action": "view",
  "result": "allowed",
  "reason": "Owner role and admin device trust level satisfied."
}
```
