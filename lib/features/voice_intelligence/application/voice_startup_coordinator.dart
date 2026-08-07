import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../settings/application/settings_controller.dart';
import '../../voice_assistant/voice_startup_gate_service.dart';

enum VoiceStartupStatus {
  disabled,
  initializing,
  ready,
  unavailable,
  permissionDenied,
  hardwareMissing,
  pluginUnavailable,
  failed,
}

extension VoiceStartupStatusLabel on VoiceStartupStatus {
  String get label {
    switch (this) {
      case VoiceStartupStatus.disabled:
        return 'Voice disabled';
      case VoiceStartupStatus.initializing:
        return 'Voice initializing';
      case VoiceStartupStatus.ready:
        return 'Voice ready';
      case VoiceStartupStatus.unavailable:
        return 'Voice unavailable';
      case VoiceStartupStatus.permissionDenied:
        return 'Permission required';
      case VoiceStartupStatus.hardwareMissing:
        return 'Microphone unavailable';
      case VoiceStartupStatus.pluginUnavailable:
        return 'Voice plugin unavailable';
      case VoiceStartupStatus.failed:
        return 'Voice startup failed';
    }
  }
}

class VoiceStartupState {
  const VoiceStartupState({
    required this.status,
    required this.message,
    required this.canRetry,
  });

  const VoiceStartupState.disabled({
    this.message = 'Voice is disabled in Settings.',
  }) : status = VoiceStartupStatus.disabled,
       canRetry = false;

  const VoiceStartupState.initializing({
    this.message = 'Checking voice readiness in the background.',
  }) : status = VoiceStartupStatus.initializing,
       canRetry = false;

  const VoiceStartupState.ready({this.message = 'Voice is ready.'})
    : status = VoiceStartupStatus.ready,
      canRetry = false;

  const VoiceStartupState.unavailable({required this.message})
    : status = VoiceStartupStatus.unavailable,
      canRetry = false;

  const VoiceStartupState.permissionDenied({required this.message})
    : status = VoiceStartupStatus.permissionDenied,
      canRetry = true;

  const VoiceStartupState.hardwareMissing({required this.message})
    : status = VoiceStartupStatus.hardwareMissing,
      canRetry = true;

  const VoiceStartupState.pluginUnavailable({required this.message})
    : status = VoiceStartupStatus.pluginUnavailable,
      canRetry = true;

  const VoiceStartupState.failed({required this.message})
    : status = VoiceStartupStatus.failed,
      canRetry = true;

  final VoiceStartupStatus status;
  final String message;
  final bool canRetry;

  VoiceStartupState copyWith({
    VoiceStartupStatus? status,
    String? message,
    bool? canRetry,
  }) {
    return VoiceStartupState(
      status: status ?? this.status,
      message: message ?? this.message,
      canRetry: canRetry ?? this.canRetry,
    );
  }
}

abstract class VoiceStartupProbe {
  Future<VoiceStartupState> evaluate({
    required bool voiceEnabled,
    required bool voiceFirstMode,
    required Duration timeout,
  });
}

class DefaultVoiceStartupProbe implements VoiceStartupProbe {
  DefaultVoiceStartupProbe({
    SpeechToText? speechToText,
    MethodChannel? audioChannel,
  }) : _speechToText = speechToText ?? SpeechToText(),
       _audioChannel = audioChannel ?? const MethodChannel(_channelName);

  static const String _channelName = 'new_earth/windows_audio_gate';

  final SpeechToText _speechToText;
  final MethodChannel _audioChannel;

  @override
  Future<VoiceStartupState> evaluate({
    required bool voiceEnabled,
    required bool voiceFirstMode,
    required Duration timeout,
  }) async {
    if (!voiceEnabled) {
      return const VoiceStartupState.disabled();
    }

    if (kIsWeb) {
      return const VoiceStartupState.unavailable(
        message: 'Voice startup is unavailable on web.',
      );
    }

    if (!Platform.isWindows) {
      return const VoiceStartupState.unavailable(
        message: 'Voice startup is unavailable on this platform.',
      );
    }

    try {
      final hardwareDevices = await _listAudioDevices().timeout(timeout);
      if (hardwareDevices.isEmpty) {
        return const VoiceStartupState.hardwareMissing(
          message:
              'No microphone or headset was detected. The dashboard remains usable without voice.',
        );
      }

      if (!voiceFirstMode) {
        final hasPermission = await _speechToText.hasPermission.timeout(
          timeout,
        );
        if (!hasPermission) {
          return const VoiceStartupState.permissionDenied(
            message:
                'Microphone permission is not granted. Open system settings later if you want voice.',
          );
        }
      }

      final available = await _speechToText
          .initialize(finalTimeout: const Duration(milliseconds: 800))
          .timeout(timeout);

      if (!available) {
        final hasPermission = await _speechToText.hasPermission;
        if (!hasPermission) {
          return const VoiceStartupState.permissionDenied(
            message:
                'Microphone permission is not granted. Open system settings later if you want voice.',
          );
        }

        return const VoiceStartupState.pluginUnavailable(
          message:
              'The voice plugin is unavailable right now, but the dashboard stays usable.',
        );
      }

      return const VoiceStartupState.ready(
        message: 'Voice is ready. Optional speech features are available.',
      );
    } on MissingPluginException {
      return const VoiceStartupState.pluginUnavailable(
        message:
            'The voice plugin is unavailable on this build, but the dashboard remains usable.',
      );
    } on TimeoutException {
      return const VoiceStartupState.failed(
        message:
            'Voice startup timed out. The dashboard remains usable and you can retry later.',
      );
    } on PlatformException catch (error) {
      final message = error.message?.trim();
      if (message != null && message.toLowerCase().contains('permission')) {
        return const VoiceStartupState.permissionDenied(
          message:
              'Microphone permission is not granted. Open system settings later if you want voice.',
        );
      }

      return VoiceStartupState.failed(
        message:
            'Voice startup failed. The dashboard remains usable and you can retry later.',
      );
    } catch (_) {
      return const VoiceStartupState.failed(
        message:
            'Voice startup failed. The dashboard remains usable and you can retry later.',
      );
    }
  }

  Future<List<VoiceInputDevice>> _listAudioDevices() async {
    final rawDevices = await _audioChannel.invokeMethod<List<dynamic>>(
      'listCaptureDevices',
    );

    return (rawDevices ?? const <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(VoiceInputDevice.fromMap)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}

class VoiceStartupCoordinator extends Notifier<VoiceStartupState> {
  bool _running = false;
  bool _retryRequested = false;
  bool _disposed = false;
  bool _hasStartupContext = false;
  bool _lastVoiceEnabled = false;
  bool _lastVoiceFirstMode = false;
  String? _lastSettingsSignature;
  int _generation = 0;

  @override
  VoiceStartupState build() {
    ref.onDispose(_dispose);

    final settingsSnapshot = ref
        .watch(settingsSnapshotProvider)
        .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
    if (settingsSnapshot == null) {
      return const VoiceStartupState.disabled(
        message: 'Voice status will appear after settings finish loading.',
      );
    }

    final enabled = settingsSnapshot.settings.voiceAssistantEnabled;
    final voiceFirstMode = settingsSnapshot.settings.voiceStartupGateEnabled;
    final signature = '$enabled:$voiceFirstMode';

    if (_lastSettingsSignature != signature) {
      _lastSettingsSignature = signature;

      if (!enabled) {
        _generation += 1;
        _running = false;
        _retryRequested = false;
        _hasStartupContext = false;
        state = const VoiceStartupState.disabled();
      } else {
        state = VoiceStartupState.initializing(
          message: voiceFirstMode
              ? 'Voice-first mode is checking hardware and speech readiness.'
              : 'Voice startup is checking hardware and speech readiness in the background.',
        );
        unawaited(start(voiceEnabled: enabled, voiceFirstMode: voiceFirstMode));
      }
    }

    return state;
  }

  Future<void> start({
    required bool voiceEnabled,
    required bool voiceFirstMode,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (_disposed) {
      return;
    }

    _hasStartupContext = true;
    _lastVoiceEnabled = voiceEnabled;
    _lastVoiceFirstMode = voiceFirstMode;

    if (!voiceEnabled) {
      state = const VoiceStartupState.disabled();
      return;
    }

    if (_running) {
      return;
    }

    final currentGeneration = ++_generation;
    _running = true;
    state = VoiceStartupState.initializing(
      message: voiceFirstMode
          ? 'Voice-first mode is checking hardware and speech readiness.'
          : 'Voice startup is checking hardware and speech readiness in the background.',
    );

    try {
      final probe = ref.read(voiceStartupProbeProvider);
      final result = await probe
          .evaluate(
            voiceEnabled: voiceEnabled,
            voiceFirstMode: voiceFirstMode,
            timeout: timeout,
          )
          .timeout(timeout);

      if (_disposed || currentGeneration != _generation) {
        return;
      }

      state = result;
    } on TimeoutException {
      if (_disposed || currentGeneration != _generation) {
        return;
      }

      state = const VoiceStartupState.failed(
        message:
            'Voice startup timed out. The dashboard remains usable and you can retry later.',
      );
    } catch (_) {
      if (_disposed || currentGeneration != _generation) {
        return;
      }

      state = const VoiceStartupState.failed(
        message:
            'Voice startup failed. The dashboard remains usable and you can retry later.',
      );
    } finally {
      _running = false;
    }

    if (_disposed || currentGeneration != _generation) {
      return;
    }

    if (_retryRequested) {
      _retryRequested = false;
      unawaited(
        start(
          voiceEnabled: _lastVoiceEnabled,
          voiceFirstMode: _lastVoiceFirstMode,
        ),
      );
    }
  }

  Future<void> retry({Duration timeout = const Duration(seconds: 8)}) async {
    if (_disposed) {
      return;
    }

    if (_running) {
      _retryRequested = true;
      return;
    }

    if (!_hasStartupContext) {
      final settingsSnapshot = ref
          .read(settingsSnapshotProvider)
          .maybeWhen(data: (snapshot) => snapshot, orElse: () => null);
      if (settingsSnapshot == null) {
        return;
      }

      _lastVoiceEnabled = settingsSnapshot.settings.voiceAssistantEnabled;
      _lastVoiceFirstMode = settingsSnapshot.settings.voiceStartupGateEnabled;
      _hasStartupContext = true;
    }

    await start(
      voiceEnabled: _lastVoiceEnabled,
      voiceFirstMode: _lastVoiceFirstMode,
      timeout: timeout,
    );
  }

  void disable() {
    if (_disposed) {
      return;
    }

    _generation += 1;
    _running = false;
    _retryRequested = false;
    _hasStartupContext = false;
    state = const VoiceStartupState.disabled();
  }

  void _dispose() {
    _disposed = true;
    _retryRequested = false;
  }
}

final voiceStartupProbeProvider = Provider<VoiceStartupProbe>((ref) {
  return DefaultVoiceStartupProbe();
});

final voiceStartupCoordinatorProvider =
    NotifierProvider<VoiceStartupCoordinator, VoiceStartupState>(
      VoiceStartupCoordinator.new,
    );
