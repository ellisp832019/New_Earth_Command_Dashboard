# Module Hub Integration

The Module Hub should ask this module before opening sensitive modules.

```text
User clicks module
↓
Module Hub asks canOpenModule()
↓
Users & Devices Control checks role, permission, trust level
↓
Allow or deny
↓
Audit event created
```

## Contract

```ts
canOpenModule(actor, device, moduleRule)
canPerformAction(actor, device, moduleRule, action)
```
