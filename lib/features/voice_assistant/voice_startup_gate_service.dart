import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VoiceInputDevice {
  const VoiceInputDevice({required this.name, required this.identifier});

  factory VoiceInputDevice.fromMap(Map<dynamic, dynamic> device) {
    return VoiceInputDevice(
      name: (device['name'] ?? 'Unknown microphone').toString(),
      identifier: (device['identifier'] ?? '').toString(),
    );
  }

  final String name;
  final String identifier;

  bool get isHeadsetLike {
    final lowerName = name.toLowerCase();
    final lowerId = identifier.toLowerCase();
    const keywords = <String>[
      'headset',
      'headphone',
      'headphones',
      'bluetooth',
      'hands-free',
      'hands free',
      'airpods',
      'earbud',
      'earbuds',
      'earphone',
      'earphones',
      'buds',
      'pod',
      'wireless',
      'usb audio',
      'bt ',
      'bthenum',
    ];

    return keywords.any(
      (keyword) => lowerName.contains(keyword) || lowerId.contains(keyword),
    );
  }
}

enum VoiceStartupGateState {
  ready,
  noDevices,
  microphoneOnly,
  checkFailed,
  bypassed,
}

class VoiceStartupGateResult {
  const VoiceStartupGateResult({
    required this.isReady,
    required this.message,
    required this.devices,
    this.state,
  });

  final bool isReady;
  final String message;
  final List<VoiceInputDevice> devices;
  final VoiceStartupGateState? state;

  VoiceStartupGateState get resolvedState {
    if (state != null) {
      return state!;
    }

    if (isReady) {
      return VoiceStartupGateState.ready;
    }

    if (devices.isEmpty) {
      return VoiceStartupGateState.noDevices;
    }

    final headsetDevices = devices
        .where((device) => device.isHeadsetLike)
        .toList();
    if (headsetDevices.isNotEmpty) {
      return VoiceStartupGateState.ready;
    }

    return VoiceStartupGateState.microphoneOnly;
  }

  factory VoiceStartupGateResult.fromDevices(List<VoiceInputDevice> devices) {
    final headsetDevices = devices
        .where((device) => device.isHeadsetLike)
        .toList();
    if (headsetDevices.isNotEmpty) {
      final names = headsetDevices.map((device) => device.name).join(', ');
      return VoiceStartupGateResult(
        isReady: true,
        message: 'Headset detected: $names. The assistant is ready.',
        devices: devices,
        state: VoiceStartupGateState.ready,
      );
    }

    if (devices.isEmpty) {
      return const VoiceStartupGateResult(
        isReady: false,
        message:
            'No active microphone or headset was detected. Connect a Bluetooth headset or headset microphone, then retry.',
        devices: <VoiceInputDevice>[],
        state: VoiceStartupGateState.noDevices,
      );
    }

    final deviceNames = devices.map((device) => device.name).join(', ');
    return VoiceStartupGateResult(
      isReady: false,
      message:
          'A microphone is available, but the assistant did not see a headset-like device yet. Found: $deviceNames. If this is your headset mic, choose Continue with Voice.',
      devices: devices,
      state: VoiceStartupGateState.microphoneOnly,
    );
  }
}

class VoiceStartupGateService {
  VoiceStartupGateService() : _channel = const MethodChannel(_channelName);

  static const String _channelName = 'new_earth/windows_audio_gate';

  final MethodChannel _channel;

  bool get _isSupported {
    if (kIsWeb) {
      return false;
    }

    if (!Platform.isWindows) {
      return false;
    }

    return !const bool.fromEnvironment('FLUTTER_TEST');
  }

  Future<VoiceStartupGateResult> checkReady() async {
    if (!_isSupported) {
      return const VoiceStartupGateResult(
        isReady: true,
        message: 'Voice startup gate is bypassed on this platform.',
        devices: <VoiceInputDevice>[],
        state: VoiceStartupGateState.bypassed,
      );
    }

    try {
      final rawDevices = await _channel.invokeMethod<List<dynamic>>(
        'listCaptureDevices',
      );
      final devices =
          (rawDevices ?? const <dynamic>[])
              .whereType<Map<dynamic, dynamic>>()
              .map(VoiceInputDevice.fromMap)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return VoiceStartupGateResult.fromDevices(devices);
    } catch (_) {
      return const VoiceStartupGateResult(
        isReady: false,
        message:
            'The assistant could not check for audio devices right now. The headset may still work, but the device query needs another look. Open Voice diagnostics for the bridge and default input check.',
        devices: <VoiceInputDevice>[],
        state: VoiceStartupGateState.checkFailed,
      );
    }
  }

  void dispose() {}
}
