import 'dart:async';
import 'dart:convert';
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
  Process? _fallbackSpeechProcess;

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
    } on MissingPluginException {
      return await _loadVoicesWithPowerShell();
    } on PlatformException catch (_) {
      return await _loadVoicesWithPowerShell();
    } catch (_) {
      return await _loadVoicesWithPowerShell();
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
      return;
    } on MissingPluginException {
      await _speakWithPowerShellFallback(
        text.trim(),
        rate: rate,
        pitch: pitch,
        voiceName: voice?.name,
      );
    } on PlatformException {
      await _speakWithPowerShellFallback(
        text.trim(),
        rate: rate,
        pitch: pitch,
        voiceName: voice?.name,
      );
    } catch (_) {
      await _speakWithPowerShellFallback(
        text.trim(),
        rate: rate,
        pitch: pitch,
        voiceName: voice?.name,
      );
    }
  }

  Future<void> stop() async {
    if (_fallbackSpeechProcess != null) {
      _fallbackSpeechProcess!.kill(ProcessSignal.sigterm);
      _fallbackSpeechProcess = null;
    }

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

  Future<List<VoiceTtsVoiceOption>> _loadVoicesWithPowerShell() async {
    if (!Platform.isWindows) {
      return const <VoiceTtsVoiceOption>[];
    }

    try {
      final script = <String>[
        'Add-Type -AssemblyName System.Speech',
        r'$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer',
        r'$voices = $synth.GetInstalledVoices() | ForEach-Object {',
        r'  $info = $_.VoiceInfo',
        r'  [PSCustomObject]@{',
        r'    name = $info.Name',
        r'    locale = $info.Culture.Name',
        r'    gender = $info.Gender.ToString()',
        r'    identifier = $info.Name',
        r'  }',
        r'}',
        r'$voices | ConvertTo-Json -Compress',
      ].join('\n');

      final output = await Process.run(
        'powershell',
        <String>[
          '-NoLogo',
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-EncodedCommand',
          _encodePowerShellCommand(script),
        ],
        runInShell: true,
      );

      if (output.exitCode != 0) {
        return const <VoiceTtsVoiceOption>[];
      }

      final payload = output.stdout.toString().trim();
      if (payload.isEmpty) {
        return const <VoiceTtsVoiceOption>[];
      }

      final decoded = jsonDecode(payload);
      final rawVoices = decoded is List
          ? decoded
          : decoded is Map<String, dynamic>
          ? <dynamic>[decoded]
          : const <dynamic>[];

      return rawVoices
          .whereType<Map>()
          .map(
            (voice) => VoiceTtsVoiceOption(
              name: voice['name']?.toString() ?? 'Unknown voice',
              locale: voice['locale']?.toString() ?? 'unknown',
              gender: voice['gender']?.toString(),
              identifier: voice['identifier']?.toString(),
            ),
          )
          .toList()
        ..sort((a, b) {
          final localeCompare = a.locale.compareTo(b.locale);
          if (localeCompare != 0) {
            return localeCompare;
          }
          return a.name.compareTo(b.name);
        });
    } catch (_) {
      return const <VoiceTtsVoiceOption>[];
    }
  }

  Future<void> _speakWithPowerShellFallback(
    String text, {
    required double rate,
    required double pitch,
    String? voiceName,
  }) async {
    if (!Platform.isWindows || text.trim().isEmpty) {
      return;
    }

    try {
      await stop();
      final script = _buildPowerShellSpeechScript(
        text: text.trim(),
        rate: rate,
        voiceName: voiceName,
      );
      final process = await Process.start(
        'powershell',
        <String>[
          '-NoLogo',
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-EncodedCommand',
          _encodePowerShellCommand(script),
        ],
        runInShell: true,
      );
      _fallbackSpeechProcess = process;
      unawaited(process.exitCode.then((_) {
        if (identical(_fallbackSpeechProcess, process)) {
          _fallbackSpeechProcess = null;
        }
      }));
    } catch (_) {
      // Best-effort only. Voice output should never block the workflow.
    }
  }

  String _buildPowerShellSpeechScript({
    required String text,
    required double rate,
    String? voiceName,
  }) {
    final normalizedText = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final safeText = _escapePowerShellSingleQuoted(normalizedText);
    final safeVoiceName = _escapePowerShellSingleQuoted(voiceName ?? '');
    final rateValue = ((rate.clamp(0.0, 1.0) - 0.5) * 20).round();

    final buffer = StringBuffer()
      ..writeln('Add-Type -AssemblyName System.Speech')
      ..writeln(r'$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer')
      ..writeln(r'try {');

    if (safeVoiceName.isNotEmpty) {
      buffer.writeln(
        "  try { \$synth.SelectVoice('$safeVoiceName') } catch {}",
      );
    }

    buffer
      ..writeln('  \$synth.Rate = $rateValue')
      ..writeln("  \$synth.Speak('$safeText')")
      ..writeln(r'} finally {')
      ..writeln(r'  $synth.Dispose()')
      ..writeln(r'}');

    return buffer.toString();
  }

  String _escapePowerShellSingleQuoted(String value) {
    return value.replaceAll("'", "''");
  }

  String _encodePowerShellCommand(String script) {
    final bytes = <int>[];
    for (final codeUnit in script.codeUnits) {
      bytes.add(codeUnit & 0xFF);
      bytes.add((codeUnit >> 8) & 0xFF);
    }
    return base64Encode(bytes);
  }
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
