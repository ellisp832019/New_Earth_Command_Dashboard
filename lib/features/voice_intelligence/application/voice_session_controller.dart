import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/voice_models.dart';

class VoiceSessionState {
  const VoiceSessionState({
    this.recordingActive = false,
    this.activeMode,
    this.recordingLabel = 'Recording inactive',
    this.lastTranscript = '',
  });

  final bool recordingActive;
  final VoiceSessionMode? activeMode;
  final String recordingLabel;
  final String lastTranscript;

  VoiceSessionState copyWith({
    bool? recordingActive,
    VoiceSessionMode? activeMode,
    String? recordingLabel,
    String? lastTranscript,
  }) {
    return VoiceSessionState(
      recordingActive: recordingActive ?? this.recordingActive,
      activeMode: activeMode ?? this.activeMode,
      recordingLabel: recordingLabel ?? this.recordingLabel,
      lastTranscript: lastTranscript ?? this.lastTranscript,
    );
  }
}

class VoiceSessionController extends Notifier<VoiceSessionState> {
  @override
  VoiceSessionState build() {
    return const VoiceSessionState();
  }

  void startRecording({
    required VoiceSessionMode mode,
    String label = 'Recording active',
  }) {
    state = state.copyWith(
      recordingActive: true,
      activeMode: mode,
      recordingLabel: label,
    );
  }

  void updateTranscript(String transcript) {
    state = state.copyWith(lastTranscript: transcript);
  }

  void stopRecording() {
    state = const VoiceSessionState();
  }

  void reset() {
    state = const VoiceSessionState();
  }
}
