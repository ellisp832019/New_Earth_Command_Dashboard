# Security Review — AI Assistant Dock

## Permission posture

Default permissions should be disabled until explicitly enabled.

## Requested permissions

- microphone
- speaker
- screen_capture
- file_read
- file_write_project_only
- browser_control
- app_launch
- shell_commands_approval
- keyboard_mouse_approval
- local_network
- internet_access_optional

## Review notes

No backend control should be enabled during the first UI shell phase.
