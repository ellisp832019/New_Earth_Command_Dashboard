import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_presence_controller.dart';

enum VoiceSessionOwner { none, handsfree, assistant, dock }

extension VoiceSessionOwnerLabel on VoiceSessionOwner {
  String get displayLabel {
    switch (this) {
      case VoiceSessionOwner.none:
        return 'Idle';
      case VoiceSessionOwner.handsfree:
        return 'Handsfree';
      case VoiceSessionOwner.assistant:
        return 'Assistant';
      case VoiceSessionOwner.dock:
        return 'Dock';
    }
  }
}

enum VoiceSessionPhase {
  idle,
  waking,
  listening,
  processing,
  speaking,
  awaitingFollowUp,
  error,
}

extension VoiceSessionPhaseLabel on VoiceSessionPhase {
  String get displayLabel {
    switch (this) {
      case VoiceSessionPhase.idle:
        return 'Idle';
      case VoiceSessionPhase.waking:
        return 'Waking';
      case VoiceSessionPhase.listening:
        return 'Listening';
      case VoiceSessionPhase.processing:
        return 'Processing';
      case VoiceSessionPhase.speaking:
        return 'Speaking';
      case VoiceSessionPhase.awaitingFollowUp:
        return 'Awaiting follow-up';
      case VoiceSessionPhase.error:
        return 'Error';
    }
  }
}

class VoiceSessionState {
  const VoiceSessionState({
    required this.owner,
    required this.phase,
    required this.label,
    required this.detail,
    required this.isActive,
    required this.opacity,
  });

  const VoiceSessionState.idle()
    : owner = VoiceSessionOwner.none,
      phase = VoiceSessionPhase.idle,
      label = 'Assistant idle',
      detail = 'Ready when you are',
      isActive = false,
      opacity = 0.28;

  final VoiceSessionOwner owner;
  final VoiceSessionPhase phase;
  final String label;
  final String detail;
  final bool isActive;
  final double opacity;

  bool get canBeClaimed =>
      owner == VoiceSessionOwner.none ||
      phase == VoiceSessionPhase.idle ||
      phase == VoiceSessionPhase.error ||
      phase == VoiceSessionPhase.awaitingFollowUp;

  VoiceSessionState copyWith({
    VoiceSessionOwner? owner,
    VoiceSessionPhase? phase,
    String? label,
    String? detail,
    bool? isActive,
    double? opacity,
  }) {
    return VoiceSessionState(
      owner: owner ?? this.owner,
      phase: phase ?? this.phase,
      label: label ?? this.label,
      detail: detail ?? this.detail,
      isActive: isActive ?? this.isActive,
      opacity: opacity ?? this.opacity,
    );
  }
}

class VoiceSessionNotifier extends Notifier<VoiceSessionState> {
  @override
  VoiceSessionState build() => const VoiceSessionState.idle();

  bool beginListening({
    required VoiceSessionOwner owner,
    required String label,
    required String detail,
    double opacity = 0.72,
  }) {
    if (!state.canBeClaimed && state.owner != owner) {
      return false;
    }

    _commit(
      state.copyWith(
        owner: owner,
        phase: VoiceSessionPhase.listening,
        label: label,
        detail: detail,
        isActive: true,
        opacity: opacity,
      ),
    );
    return true;
  }

  void beginWaking({
    required VoiceSessionOwner owner,
    required String label,
    required String detail,
    double opacity = 0.64,
  }) {
    if (!state.canBeClaimed && state.owner != owner) {
      return;
    }

    _commit(
      state.copyWith(
        owner: owner,
        phase: VoiceSessionPhase.waking,
        label: label,
        detail: detail,
        isActive: true,
        opacity: opacity,
      ),
    );
  }

  void beginProcessing({
    required VoiceSessionOwner owner,
    required String label,
    required String detail,
    double opacity = 0.72,
  }) {
    if (!state.canBeClaimed && state.owner != owner) {
      return;
    }

    _commit(
      state.copyWith(
        owner: owner,
        phase: VoiceSessionPhase.processing,
        label: label,
        detail: detail,
        isActive: true,
        opacity: opacity,
      ),
    );
  }

  void beginSpeaking({
    required VoiceSessionOwner owner,
    required String label,
    required String detail,
    double opacity = 0.72,
  }) {
    if (!state.canBeClaimed && state.owner != owner) {
      return;
    }

    _commit(
      state.copyWith(
        owner: owner,
        phase: VoiceSessionPhase.speaking,
        label: label,
        detail: detail,
        isActive: true,
        opacity: opacity,
      ),
    );
  }

  void beginAwaitingFollowUp({
    required VoiceSessionOwner owner,
    required String label,
    required String detail,
    double opacity = 0.64,
  }) {
    if (!state.canBeClaimed && state.owner != owner) {
      return;
    }

    _commit(
      state.copyWith(
        owner: owner,
        phase: VoiceSessionPhase.awaitingFollowUp,
        label: label,
        detail: detail,
        isActive: true,
        opacity: opacity,
      ),
    );
  }

  bool handoff({
    required VoiceSessionOwner from,
    required VoiceSessionOwner to,
    required VoiceSessionPhase phase,
    required String label,
    required String detail,
    double opacity = 0.64,
    bool isActive = true,
  }) {
    if (state.owner != from) {
      return false;
    }

    _commit(
      state.copyWith(
        owner: to,
        phase: phase,
        label: label,
        detail: detail,
        isActive: isActive,
        opacity: opacity,
      ),
    );
    return true;
  }

  void updatePresence({
    required String label,
    required String detail,
    required bool isActive,
    required double opacity,
  }) {
    _commit(
      state.copyWith(
        label: label,
        detail: detail,
        isActive: isActive,
        opacity: opacity,
      ),
    );
  }

  void setError({required String detail}) {
    _commit(
      VoiceSessionState(
        owner: VoiceSessionOwner.none,
        phase: VoiceSessionPhase.error,
        label: 'Assistant idle',
        detail: detail,
        isActive: false,
        opacity: 0.28,
      ),
    );
  }

  void release({
    required VoiceSessionOwner owner,
    String label = 'Assistant idle',
    String detail = 'Ready when you are',
    double opacity = 0.28,
  }) {
    if (state.owner != owner && state.owner != VoiceSessionOwner.none) {
      return;
    }

    _commit(
      VoiceSessionState(
        owner: VoiceSessionOwner.none,
        phase: VoiceSessionPhase.idle,
        label: label,
        detail: detail,
        isActive: false,
        opacity: opacity,
      ),
    );
  }

  bool canBeClaimedBy(VoiceSessionOwner owner) =>
      state.canBeClaimed || state.owner == owner;

  void _commit(VoiceSessionState next) {
    state = next;
    ref
        .read(voicePresenceProvider.notifier)
        .setPresence(
          VoicePresenceState(
            label: next.label,
            detail: next.detail,
            isActive: next.isActive,
            opacity: next.opacity,
          ),
        );
  }
}

final voiceSessionProvider =
    NotifierProvider<VoiceSessionNotifier, VoiceSessionState>(
      VoiceSessionNotifier.new,
    );
