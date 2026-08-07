import 'voice_models.dart';

class VoiceModuleConfig {
  const VoiceModuleConfig({required this.runtime, required this.featureFlags});

  final VoiceRuntimeConfig runtime;
  final VoiceFeatureFlags featureFlags;

  factory VoiceModuleConfig.fromEnvironment() {
    return VoiceModuleConfig(
      runtime: VoiceRuntimeConfig.fromEnvironment(),
      featureFlags: const VoiceFeatureFlags(),
    );
  }
}
