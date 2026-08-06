import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routing/route_names.dart';
import '../voice_startup_gate_service.dart';

class VoiceStartupGateBypassNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void allowBypass() {
    state = true;
  }

  void reset() {
    state = false;
  }
}

final voiceStartupGateBypassProvider =
    NotifierProvider<VoiceStartupGateBypassNotifier, bool>(
      VoiceStartupGateBypassNotifier.new,
    );

final voiceStartupGateLandingRoute = ValueNotifier<String?>(null);

class VoiceStartupGateLandingNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void requestVoiceAssistant() {
    state = RouteNames.voiceAssistant;
    voiceStartupGateLandingRoute.value = RouteNames.voiceAssistant;
    ref.read(voiceStartupGateBypassProvider.notifier).allowBypass();
  }

  void requestDashboard() {
    state = RouteNames.dashboard;
    voiceStartupGateLandingRoute.value = RouteNames.dashboard;
    ref.read(voiceStartupGateBypassProvider.notifier).allowBypass();
  }

  void clear() {
    state = null;
    voiceStartupGateLandingRoute.value = null;
  }
}

final voiceStartupGateLandingProvider =
    NotifierProvider<VoiceStartupGateLandingNotifier, String?>(
      VoiceStartupGateLandingNotifier.new,
    );

final voiceStartupGateServiceProvider = Provider<VoiceStartupGateService>((
  ref,
) {
  final service = VoiceStartupGateService();
  ref.onDispose(service.dispose);
  return service;
});

final voiceStartupGateProvider = FutureProvider<VoiceStartupGateResult>((
  ref,
) async {
  return ref.read(voiceStartupGateServiceProvider).checkReady();
});
