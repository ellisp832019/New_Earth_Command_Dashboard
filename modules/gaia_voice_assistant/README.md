# GAIA Voice Assistant Dashboard Module

This module connects the New Earth Dashboard to GAIA, a local AI assistant runtime that can run from a USB SSD/stick or from a dedicated local AI box.

The dashboard module must remain the authority for permissions. GAIA should never directly control sensitive systems.

## Responsibilities

- Detect GAIA runtime status.
- Send structured commands to GAIA.
- Send conversation turns to the local GAIA runtime.
- Display responses, logs, model status, and voice state.
- Require approval for sensitive actions.
- Bridge voice input/output to existing dashboard voice work.

## Keep existing dashboard voice work

Do not delete the current voice module. Move or wrap it into:

```text
modules/gaia_voice_assistant/gaia_core/existing_dashboard_voice/
```

Then route its transcript output into the GAIA bridge.
