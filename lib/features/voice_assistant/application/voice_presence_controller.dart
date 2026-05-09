import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoicePresenceState {
  const VoicePresenceState({
    required this.label,
    required this.detail,
    required this.isActive,
    this.opacity = 0.34,
  });

  const VoicePresenceState.idle()
      : label = 'Gaia idle',
        detail = 'Ready when you are',
        isActive = false,
        opacity = 0.28;

  final String label;
  final String detail;
  final bool isActive;
  final double opacity;

  VoicePresenceState copyWith({
    String? label,
    String? detail,
    bool? isActive,
    double? opacity,
  }) {
    return VoicePresenceState(
      label: label ?? this.label,
      detail: detail ?? this.detail,
      isActive: isActive ?? this.isActive,
      opacity: opacity ?? this.opacity,
    );
  }
}

class VoicePresenceNotifier extends Notifier<VoicePresenceState> {
  @override
  VoicePresenceState build() => const VoicePresenceState.idle();

  void setPresence(VoicePresenceState presence) {
    state = presence;
  }
}

final voicePresenceProvider =
    NotifierProvider<VoicePresenceNotifier, VoicePresenceState>(
      VoicePresenceNotifier.new,
    );
