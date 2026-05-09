import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voice_startup_gate_service.dart';

final voiceStartupGateServiceProvider =
    Provider<VoiceStartupGateService>((ref) {
      final service = VoiceStartupGateService();
      ref.onDispose(service.dispose);
      return service;
    });

final voiceStartupGateProvider =
    FutureProvider<VoiceStartupGateResult>((ref) async {
      return ref.read(voiceStartupGateServiceProvider).checkReady();
    });
