# Voice Startup Data Flow Audit

## What Executes Before `runApp`

- `WidgetsFlutterBinding.ensureInitialized()` in `lib/main.dart`
- Desktop window initialization on supported desktop targets
- `hotKeyManager.unregisterAll()`
- `DesktopWindowApi.initialize()`
- `DesktopWindowApi.waitUntilReadyToShow(...)`
- `DesktopPresenceController.instance.initialize()`

These steps happen before the app widget tree is mounted. None of them are voice-specific.

## What Executes Before the Main Dashboard Is Available

- `runApp(const ProviderScope(child: NewEarthCommandDashboardApp()))`
- `databaseReadyProvider` is watched from `lib/app.dart`
- The router builds the app shell and initial route
- Security session state and dock overlays initialize

The main dashboard depends on local database readiness, not voice readiness.

## What Checks for Voice Hardware

- `VoiceStartupGateService.checkReady()`
- `VoiceSpeechDiagnosticsService.run()`
- `VoiceAssistantScreen._showVoiceDiagnostics()`

The startup gate looks for headset-like device names or identifiers through a platform channel.

## What Requests Microphone Permission

- `SpeechToText.initialize(...)` in `VoiceHandsfreeLayer`
- `SpeechToText.initialize(...)` in `VoiceAssistantScreen`

Permission requests are deferred until voice capture is actually armed. They are not part of `runApp`.

## What Initializes Speech Plugins

- `DesktopSpeechBridgeService.captureOnce()`
- `WindowsVoiceTypingService.startVoiceTyping()`
- `SpeechToText.initialize()`
- `VoiceAssistantSpeechService.loadVoices()`
- `VoiceAssistantSpeechService.speak(...)`

## What Can Throw

- Platform channels may throw `MissingPluginException`
- Desktop bridge startup can fail or return null
- Speech initialization can fail or return false
- Route logic can still throw if a programming error exists in navigation or state wiring

Most voice helpers already catch expected plugin and platform failures, but the current flow still mixes optional voice setup with the assistant experience and startup-gate UX.

## What Can Wait Indefinitely

- `DesktopSpeechBridgeService.captureOnce()` has a timeout, but the flow around it can still feel blocking while a voice mode is being armed
- `VoiceStartupGateService` rechecks in a loop while the gate screen is open
- Speech initialization has no visible bounded voice-status model today

## What Can Redirect or Gate the User

- The voice startup gate route can send the user to the voice assistant or dashboard
- The handsfree layer can take over focus and begin capture after app shell startup
- Voice-only flows can redirect to assistant surfaces once they are ready

## Essential Functionality

- Local database initialization
- Settings and repository loading
- Routing
- Security/session routing
- App shell and dashboard rendering

## Optional Functionality

- Microphone detection
- Headset detection
- Speech recognition startup
- Windows desktop voice typing
- Desktop speech bridge capture
- TTS voice enumeration
- Voice startup gate UX

## Current Error States

- Voice startup gate can show no-device, microphone-only, or check-failed messaging
- Voice assistant screens show speech availability and speech error messaging
- Voice diagnostics can surface bridge and headset recommendations

## Retriability

- `VoiceStartupGateProvider` can be invalidated to retry the headset check
- Voice assistant speech paths retry by rearming or reinitializing when the user starts a new capture
- There is no single explicit startup coordinator with retry semantics yet

## Audit Conclusion

Voice is already conceptually optional, but the startup and assistant paths still spread voice readiness logic across multiple widgets and services. The next step is to centralize optional voice startup behind an explicit coordinator with bounded timeout, visible status, and retry.
