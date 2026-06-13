import 'desktop_speech_bridge_service.dart';
import 'voice_startup_gate_service.dart';

class VoiceSpeechDiagnosticsReport {
  const VoiceSpeechDiagnosticsReport({
    required this.headsetStatus,
    required this.bridgeStatus,
    required this.recommendation,
    required this.headsetDevices,
    required this.bridgeDiagnostics,
  });

  final String headsetStatus;
  final String bridgeStatus;
  final String recommendation;
  final List<VoiceInputDevice> headsetDevices;
  final DesktopSpeechBridgeDiagnostics? bridgeDiagnostics;
}

class VoiceSpeechDiagnosticsService {
  VoiceSpeechDiagnosticsService({
    VoiceStartupGateService? startupGateService,
    DesktopSpeechBridgeService? bridgeService,
  })  : _startupGateService = startupGateService ?? VoiceStartupGateService(),
        _bridgeService = bridgeService ?? DesktopSpeechBridgeService();

  final VoiceStartupGateService _startupGateService;
  final DesktopSpeechBridgeService _bridgeService;

  Future<VoiceSpeechDiagnosticsReport> run() async {
    final gateResult = await _startupGateService.checkReady();
    final bridgeDiagnostics = await _bridgeService.diagnoseAudio();

    final headsetStatus = gateResult.message;
    final bridgeStatus = bridgeDiagnostics == null
        ? 'Offline bridge diagnostics could not be run here.'
        : bridgeDiagnostics.ok
        ? 'Offline bridge ready on ${bridgeDiagnostics.pythonVersion}.'
        : 'Offline bridge has a capture problem.';

    final recommendation = bridgeDiagnostics?.recommendation.isNotEmpty == true
        ? bridgeDiagnostics!.recommendation
        : gateResult.isReady
        ? 'The headset looks connected. If capture is still quiet, check whether the headset is the default Windows recording device.'
        : 'Connect or select a headset microphone, then try again.';

    return VoiceSpeechDiagnosticsReport(
      headsetStatus: headsetStatus,
      bridgeStatus: bridgeStatus,
      recommendation: recommendation,
      headsetDevices: gateResult.devices,
      bridgeDiagnostics: bridgeDiagnostics,
    );
  }
}
