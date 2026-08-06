# Module Hub Security Review

## Primary risk

The Module Hub will eventually host AI, automation, device control, file access and shell-capable modules.

## First phase control

The first phase is UI only. No real privileged actions should be enabled.

## Required future controls

- permission states
- audit logs
- backend health checks
- per-module config
- safe mode
- disable all modules switch
- file boundary controls
- shell command approval
- screen capture approval
- keyboard/mouse approval

## AI assistant special warning

The AI Assistant Dock should start at Level 0 or Level 1 only. It should not receive shell, mouse, keyboard, file write or screen capture access until the permission gate is enforced.
