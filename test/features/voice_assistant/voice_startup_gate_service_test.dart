import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_startup_gate_service.dart';

void main() {
  test('startup gate accepts headset-like device names', () {
    final result = VoiceStartupGateResult.fromDevices([
      const VoiceInputDevice(
        name: 'Bluetooth Headset Microphone',
        identifier: 'BTHENUM\\DEV_1234',
      ),
      const VoiceInputDevice(
        name: 'Microphone Array',
        identifier: 'SWD\\MMDEVAPI\\ABC',
      ),
    ]);

    expect(result.isReady, isTrue);
    expect(result.message, contains('Headset detected'));
    expect(result.resolvedState.name, 'ready');
  });

  test('startup gate blocks when only a generic microphone is present', () {
    final result = VoiceStartupGateResult.fromDevices([
      const VoiceInputDevice(
        name: 'Microphone Array',
        identifier: 'SWD\\MMDEVAPI\\ABC',
      ),
    ]);

    expect(result.isReady, isFalse);
    expect(result.message, contains('did not see a headset-like device'));
    expect(result.resolvedState.name, 'microphoneOnly');
  });

  test('startup gate blocks when no devices are available', () {
    final result = VoiceStartupGateResult.fromDevices(const []);

    expect(result.isReady, isFalse);
    expect(result.message, contains('No active microphone or headset'));
    expect(result.resolvedState.name, 'noDevices');
  });

  test('headset detection looks for bluetooth and headset keywords', () {
    expect(
      const VoiceInputDevice(
        name: 'AirPods Hands-Free',
        identifier: '',
      ).isHeadsetLike,
      isTrue,
    );
    expect(
      const VoiceInputDevice(
        name: 'USB Microphone',
        identifier: '',
      ).isHeadsetLike,
      isFalse,
    );
    expect(
      const VoiceInputDevice(
        name: 'USB Audio Headphones',
        identifier: '',
      ).isHeadsetLike,
      isTrue,
    );
  });
}
