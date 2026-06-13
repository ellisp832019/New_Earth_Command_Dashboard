# Security Review — MicroGrow Control

## Permission posture

Default permissions should be disabled until explicitly enabled.

## Requested permissions

- local_network
- device_control
- firmware_status
- audit_log

## Review notes

No backend control should be enabled during the first UI shell phase.
