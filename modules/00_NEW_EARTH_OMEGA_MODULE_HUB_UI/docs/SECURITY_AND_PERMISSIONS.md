# Security and Permissions Model

## Core rule

No module should receive powerful access by default.

The dashboard must gate access to:

- microphone
- screen capture
- file read
- file write
- browser automation
- app launching
- shell commands
- local network
- device control
- keyboard/mouse control
- internet access

## Permission states

```text
Disabled
Ask every time
Allowed
```

## AI assistant safety levels

```text
Level 0 — Chat only
Level 1 — Read dashboard context
Level 2 — Open apps and websites
Level 3 — Read selected files
Level 4 — Write files only inside approved folders
Level 5 — Browser automation
Level 6 — Screen capture and analysis
Level 7 — Mouse/keyboard control with approval
Level 8 — Shell commands with approval
Level 9 — Full trusted operator mode
```

Default should be Level 0 or Level 1.

## Audit log

Every privileged action should eventually create an audit entry:

- timestamp
- module id
- action
- permission used
- approved/denied
- result

## Future hardware isolation idea

For higher-risk AI automation, the assistant can run on a separate machine or hardware boundary. The dashboard can communicate with it through a controlled local API rather than giving it direct unrestricted access.
