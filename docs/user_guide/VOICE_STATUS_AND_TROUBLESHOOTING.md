# Voice Status and Troubleshooting

Voice is optional. The dashboard should still open even if voice is not ready.

## Status Chip

The voice status chip tells you what the startup flow is doing:

- `Voice disabled` means voice is off in Settings.
- `Voice initializing` means the app is checking voice readiness in the background.
- `Voice ready` means speech features are available.
- `Voice unavailable` means the current platform does not support the voice startup path.
- `Permission required` means microphone access needs attention.
- `Microphone unavailable` means no input device was detected.
- `Voice plugin unavailable` means the plugin or platform bridge was not available.
- `Voice startup failed` means startup hit a timeout or unexpected error.

## What To Do

If voice is not ready:

1. Keep using the dashboard.
2. Check Settings for voice options.
3. Make sure a microphone or headset is connected on Windows.
4. Grant microphone permission if the OS asks for it.
5. Tap `Retry` when the status chip offers it.

## If You Do Not Want Voice

You do not need to fix anything.
The dashboard is still fully usable without voice.

## If Voice Keeps Failing

Try this order:

1. Close and reopen the app.
2. Check the Windows input device list.
3. Confirm the microphone is not muted.
4. Retry after the system is idle.
5. Review the developer logs if the failure repeats.

## Calm Reminder

Voice startup should never block your main work.
If it fails, treat it as optional capability recovery, not a dashboard failure.
