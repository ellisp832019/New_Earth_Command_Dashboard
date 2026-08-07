# Voice Startup Preflight

- Date: 2026-08-06
- Base branch: `feature/new-earth-dashboard-platform-control-hardening-2026-08-06`
- Base commit: `6718f5448fd652b2092426c4f199453df06e2f8b`
- Working branch: `fix/dashboard-non-blocking-voice-startup-2026-08-06`
- Risk under review: `R-005` Voice hardware blocking startup
- Risk status: `mitigating`
- Release-readiness: `not_ready`

## Current Startup Sequence

1. `lib/main.dart` binds Flutter widgets.
2. Desktop window setup runs on supported desktop targets.
3. `runApp` starts `ProviderScope` with `NewEarthCommandDashboardApp`.
4. `lib/app.dart` waits on `databaseReadyProvider` inside the app shell.
5. The router resolves the initial location from `AppLaunchRoute`.
6. Security/session routing and dashboard shell build.
7. Optional voice overlays and assistant surfaces appear only when settings enable them.

## Current Voice Initialization Sequence

- `VoiceHandsfreeLayer` arms voice capture after the first frame when `voiceAssistantEnabled` is true.
- On Windows, it tries `DesktopSpeechBridgeService.captureOnce()` first.
- If that does not produce a transcript, it tries `WindowsVoiceTypingService.startVoiceTyping()`.
- If voice typing is not available, it falls back to `SpeechToText.initialize()` and then `listen()`.
- The voice assistant screen also initializes `SpeechToText` when the user starts capture or handsfree mode.
- The voice startup gate route uses `VoiceStartupGateService.checkReady()` for headset-like device checks.

## Voice-Related Settings

- `voiceAssistantEnabled`
- `voiceRepliesEnabled`
- `voiceStartupGateEnabled`
- preferred TTS voice name, locale, gender, identifier
- preferred TTS rate
- preferred TTS pitch
- dock visibility controls for the voice conversation dock and assistant status chip

## Microphone and Headset Checks

- Windows headset/audio-device checks live in `VoiceStartupGateService`.
- `VoiceSpeechDiagnosticsService` combines the headset check with desktop bridge diagnostics.
- `VoiceHandsfreeLayer` and `VoiceAssistantScreen` both rely on microphone and speech availability, but they do so after the app shell is already built.

## Plugin and Platform Initialization

- `speech_to_text` is initialized from the voice assistant and handsfree layer.
- `hotkey_manager` and desktop window APIs initialize before `runApp` on supported desktop targets.
- The Windows voice bridge is optional and can fall back to native typing or diagnostics.
- `VoiceAssistantSpeechService` loads voices through a desktop channel and falls back to PowerShell when needed.

## Voice Tests

- `test/features/voice_assistant/voice_startup_gate_service_test.dart`
- `test/features/voice_assistant/voice_startup_gate_screen_test.dart`
- `test/features/voice_assistant/voice_assistant_turn_coordinator_test.dart`
- `test/features/voice_assistant/voice_conversation_dock_test.dart`
- `test/features/voice_assistant/voice_session_controller_test.dart`
- `test/voice_intelligence/voice_module_test.dart`

## Current Governance Snapshot

- `R-005` remains `mitigating`.
- `project_control/generated/release_readiness.md` reports `not_ready`.
- The only stated reason is that one or more open P1 risks remain.

## Preflight Notes

- The current branch is published from the platform-control baseline.
- Voice remains an optional capability in the app shell, but the startup gate and handsfree initialization still need a focused hardening pass.
- This preflight records the baseline before any new code changes for the non-blocking voice startup work.
