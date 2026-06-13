# Security Review — Local AI Runtime

## Permission posture

Default permissions should be disabled until explicitly enabled.

## Requested permissions

- local_network
- model_registry
- system_health

## Review notes

No backend control should be enabled during the first UI shell phase.
