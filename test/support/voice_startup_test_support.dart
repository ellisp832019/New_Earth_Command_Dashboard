import 'package:new_earth_command_dashboard/features/voice_intelligence/application/voice_startup_coordinator.dart';

class TestVoiceStartupProbe implements VoiceStartupProbe {
  TestVoiceStartupProbe({
    VoiceStartupState? enabledState,
    VoiceStartupState? disabledState,
    this.delay = Duration.zero,
    this.error,
  }) : enabledState = enabledState ?? const VoiceStartupState.ready(),
       disabledState = disabledState ?? const VoiceStartupState.disabled();

  VoiceStartupState enabledState;
  VoiceStartupState disabledState;
  Duration delay;
  Object? error;
  int callCount = 0;

  @override
  Future<VoiceStartupState> evaluate({
    required bool voiceEnabled,
    required bool voiceFirstMode,
    required Duration timeout,
  }) async {
    callCount += 1;

    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (error != null) {
      throw error!;
    }

    return voiceEnabled ? enabledState : disabledState;
  }
}
