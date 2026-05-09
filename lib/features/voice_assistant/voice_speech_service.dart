import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceTtsVoiceOption {
  const VoiceTtsVoiceOption({
    required this.name,
    required this.locale,
    this.gender,
    this.identifier,
  });

  factory VoiceTtsVoiceOption.fromMap(Map<dynamic, dynamic> voice) {
    return VoiceTtsVoiceOption(
      name: (voice['name'] ?? 'Unknown voice').toString(),
      locale: (voice['locale'] ?? 'unknown').toString(),
      gender: voice['gender']?.toString(),
      identifier: voice['identifier']?.toString(),
    );
  }

  final String name;
  final String locale;
  final String? gender;
  final String? identifier;

  String get label {
    final parts = <String>['$name ($locale)'];
    if (gender != null && gender!.isNotEmpty) {
      parts.add(gender!);
    }
    return parts.join(' - ');
  }

  Map<String, String> toVoiceMap() {
    final map = <String, String>{'name': name, 'locale': locale};
    if (gender != null && gender!.isNotEmpty) {
      map['gender'] = gender!;
    }
    if (identifier != null && identifier!.isNotEmpty) {
      map['identifier'] = identifier!;
    }
    return map;
  }

  @override
  bool operator ==(Object other) {
    return other is VoiceTtsVoiceOption &&
        other.name == name &&
        other.locale == locale &&
        other.gender == gender &&
        other.identifier == identifier;
  }

  @override
  int get hashCode => Object.hash(name, locale, gender, identifier);
}

class VoiceAssistantSpeechService {
  VoiceAssistantSpeechService() : _channel = const MethodChannel(_channelName);

  static const String _channelName = 'new_earth/windows_voice_speech';

  final MethodChannel _channel;

  bool get _isVoiceOutputSupported {
    if (kIsWeb) {
      return false;
    }

    if (!Platform.isWindows) {
      return false;
    }

    return Platform.environment['FLUTTER_TEST'] != 'true';
  }

  Future<List<VoiceTtsVoiceOption>> loadVoices() async {
    if (!_isVoiceOutputSupported) {
      return const <VoiceTtsVoiceOption>[];
    }

    try {
      final rawVoices = await _channel.invokeMethod<List<dynamic>>(
        'listVoices',
      );
      final voices = rawVoices ?? const <dynamic>[];
      return voices
          .whereType<Map<dynamic, dynamic>>()
          .map(VoiceTtsVoiceOption.fromMap)
          .toList()
        ..sort((a, b) {
          final localeCompare = a.locale.compareTo(b.locale);
          if (localeCompare != 0) {
            return localeCompare;
          }
          return a.name.compareTo(b.name);
        });
    } on PlatformException catch (_) {
      return const <VoiceTtsVoiceOption>[];
    } catch (_) {
      return const <VoiceTtsVoiceOption>[];
    }
  }

  Future<void> speak(
    String text, {
    required bool enabled,
    double rate = 0.5,
    double pitch = 1.0,
    VoiceTtsVoiceOption? voice,
  }) async {
    if (!enabled || text.trim().isEmpty || !_isVoiceOutputSupported) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('speak', <String, dynamic>{
        'text': text.trim(),
        'rate': rate.clamp(0.0, 1.0),
        'pitch': pitch.clamp(0.5, 2.0),
        'voice': voice?.toVoiceMap(),
      });
    } catch (_) {
      // Best-effort only. Voice output should never block the workflow.
    }
  }

  Future<void> stop() async {
    if (!_isVoiceOutputSupported) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('stopSpeaking');
    } catch (_) {
      // Ignore voice output shutdown errors.
    }
  }

  void dispose() {}
}

VoiceTtsVoiceOption? resolveConfiguredVoiceOption({
  required List<VoiceTtsVoiceOption> voices,
  required String? preferredName,
  required String? preferredLocale,
  required String? preferredGender,
  required String? preferredIdentifier,
}) {
  for (final voice in voices) {
    if (voice.name == preferredName &&
        voice.locale == preferredLocale &&
        voice.gender == preferredGender &&
        voice.identifier == preferredIdentifier) {
      return voice;
    }
  }

  return null;
}

final voiceAssistantSpeechServiceProvider =
    Provider<VoiceAssistantSpeechService>((ref) {
      final service = VoiceAssistantSpeechService();
      ref.onDispose(service.dispose);
      return service;
    });

final voiceAssistantVoicesProvider = FutureProvider<List<VoiceTtsVoiceOption>>((
  ref,
) async {
  final service = ref.read(voiceAssistantSpeechServiceProvider);
  return service.loadVoices();
});
