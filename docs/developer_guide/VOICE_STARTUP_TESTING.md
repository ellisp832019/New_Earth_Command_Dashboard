# Voice Startup Testing

Use this guide when you are working on the non-blocking voice startup path.

## What to Test

- dashboard shell still loads first
- voice startup moves through an explicit state model
- startup failure is visible
- retry works after recoverable failures
- unsupported platforms stay non-blocking

## Focused Commands

```powershell
flutter analyze
flutter test test/features/voice_intelligence/voice_startup_coordinator_test.dart --reporter expanded
flutter test test/widget_test.dart --plain-name "voice startup" --reporter expanded
```

## Recommended Test Layers

1. Use the coordinator unit tests for state transitions and retry behavior.
2. Use widget tests as shell smoke coverage.
3. Keep platform-specific failures in the coordinator tests by injecting a test probe.

## Test Support

- `test/support/voice_startup_test_support.dart`
- `test/features/voice_intelligence/voice_startup_coordinator_test.dart`

## Notes

- The coordinator should not need a real microphone to be tested.
- Use deterministic probes instead of relying on Windows audio hardware in automated tests.
- If widget tests become flaky, prefer state assertions over text-based overlay assertions.
