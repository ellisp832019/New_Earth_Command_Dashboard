# GAIA Security Model

GAIA is a local assistant, but local does not automatically mean safe.

## Rule

GAIA can suggest, prepare, read, summarise, and request.

GAIA cannot silently:

- Delete files
- Move money
- Send messages
- Control MicroGrow hardware
- Publish content
- Change system settings
- Disable security

## Architecture

```text
GAIA USB Runtime
  ↓
Dashboard GAIA Module
  ↓
Permission Gateway
  ↓
Approved Dashboard API
```

The Dashboard remains the source of truth.
