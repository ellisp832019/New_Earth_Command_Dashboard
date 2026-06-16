# Access Control Model

The module uses a hybrid model:

1. Role-based permissions.
2. Device trust levels.
3. Module access rules.
4. Action-level approval rules.
5. Audit events.

## Decision flow

```text
Actor request
↓
Identify actor
↓
Identify device
↓
Check role permissions
↓
Check device trust
↓
Check action approval rules
↓
Allow / Deny / Request Approval
↓
Write audit event
```

## Example decision

```json
{
  "allowed": false,
  "requiresApproval": true,
  "reason": "Action requires approval."
}
```
