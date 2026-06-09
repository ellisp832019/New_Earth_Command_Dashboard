import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

enum VoiceSpeechProviderMode { localTts, openAiRealtime }

enum VoiceSpeechTone { neutral, wake, briefing, wizard, calmConfirmation }

@visibleForTesting
double normalizeVoiceSpeechRate(double rate) {
  if (!rate.isFinite) {
    return 0.5;
  }

  return rate.clamp(0.46, 0.56).toDouble();
}

@visibleForTesting
double normalizeVoiceSpeechPitch(double pitch) {
  if (!pitch.isFinite) {
    return 1.0;
  }

  return pitch.clamp(0.96, 1.04).toDouble();
}

@visibleForTesting
String normalizeAssistantSpeechText(String text) {
  return text.trim().replaceAll(RegExp(r'\s+'), ' ');
}

@visibleForTesting
VoiceSpeechProviderMode resolveVoiceSpeechProviderMode({
  Map<String, String>? environment,
}) {
  final env = environment ?? Platform.environment;
  final provider = env['VOICE_SPEECH_PROVIDER']?.trim().toLowerCase();
  if (provider == 'openai_realtime' || provider == 'openai-realtime') {
    return VoiceSpeechProviderMode.openAiRealtime;
  }

  return VoiceSpeechProviderMode.localTts;
}

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
  VoiceAssistantSpeechService({
    VoiceSpeechProviderMode? providerMode,
    String? realtimeModel,
    String? realtimeVoice,
  }) : _channel = const MethodChannel(_channelName),
       _providerMode = providerMode ?? resolveVoiceSpeechProviderMode(),
       _realtimeModel =
           realtimeModel ??
           Platform.environment['OPENAI_VOICE_MODEL'] ??
           'gpt-realtime-2',
       _realtimeVoice =
           realtimeVoice ?? Platform.environment['OPENAI_REALTIME_VOICE'];

  static const String _channelName = 'new_earth/windows_voice_speech';

  final MethodChannel _channel;
  final VoiceSpeechProviderMode _providerMode;
  final String _realtimeModel;
  final String? _realtimeVoice;
  Process? _fallbackSpeechProcess;
  Future<void> _speechQueue = Future<void>.value();

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
    VoiceSpeechTone tone = VoiceSpeechTone.neutral,
  }) async {
    if (!enabled || text.trim().isEmpty || !_isVoiceOutputSupported) {
      return;
    }

    final requestText = normalizeAssistantSpeechText(text);
    final normalizedRate = normalizeVoiceSpeechRate(rate);
    final normalizedPitch = normalizeVoiceSpeechPitch(pitch);
    final pending = _speechQueue.then((_) async {
      if (_providerMode == VoiceSpeechProviderMode.openAiRealtime) {
        try {
          await _speakWithOpenAiRealtimeBridge(
            requestText,
            rate: normalizedRate,
            pitch: normalizedPitch,
            voiceName: voice?.name,
            tone: tone,
          );
          return;
        } catch (_) {
          // Fall back to local TTS below if the realtime bridge is unavailable.
        }
      }

      try {
        await _channel.invokeMethod<void>('speak', <String, dynamic>{
          'text': requestText,
          'rate': normalizedRate,
          'pitch': normalizedPitch,
          'voice': voice?.toVoiceMap(),
        });
        return;
      } on MissingPluginException {
        await _speakWithPowerShellFallback(
          requestText,
          rate: normalizedRate,
          pitch: normalizedPitch,
          voiceName: voice?.name,
        );
      } on PlatformException {
        await _speakWithPowerShellFallback(
          requestText,
          rate: normalizedRate,
          pitch: normalizedPitch,
          voiceName: voice?.name,
        );
      } catch (_) {
        await _speakWithPowerShellFallback(
          requestText,
          rate: normalizedRate,
          pitch: normalizedPitch,
          voiceName: voice?.name,
        );
      }
    });

    _speechQueue = pending.catchError((_) {});
    await pending;
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

      final output = await Process.run('powershell', <String>[
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-EncodedCommand',
        _encodePowerShellCommand(script),
      ], runInShell: true);

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
      final process = await Process.start('powershell', <String>[
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-EncodedCommand',
        _encodePowerShellCommand(script),
      ], runInShell: true);
      _fallbackSpeechProcess = process;
      unawaited(
        process.exitCode.then((_) {
          if (identical(_fallbackSpeechProcess, process)) {
            _fallbackSpeechProcess = null;
          }
        }),
      );
    } catch (_) {
      // Best-effort only. Voice output should never block the workflow.
    }
  }

  Future<void> _speakWithOpenAiRealtimeBridge(
    String text, {
    required double rate,
    required double pitch,
    String? voiceName,
    required VoiceSpeechTone tone,
  }) async {
    if (!Platform.isWindows || text.trim().isEmpty) {
      return;
    }

    try {
      await stop();
      final script = _locateBridgeScript();
      if (script == null) {
        throw StateError('Voice bridge script not found.');
      }

      final python = await _resolvePythonCommand();
      if (python == null) {
        throw StateError('Python launcher not found.');
      }

      final speechTone = _buildRealtimeSpeechTone(
        rate: rate,
        pitch: pitch,
        voiceName: voiceName ?? _realtimeVoice,
        tone: tone,
      );
      final process = await Process.start(python.command, <String>[
        ...python.args,
        script.path,
        'realtime-speak',
        '--json',
        if (_realtimeModel.trim().isNotEmpty) ...<String>[
          '--model',
          _realtimeModel.trim(),
        ],
        if ((_realtimeVoice ?? '').trim().isNotEmpty) ...<String>[
          '--voice',
          _realtimeVoice!.trim(),
        ],
        if (speechTone.isNotEmpty) ...<String>['--instructions', speechTone],
        text.trim(),
      ], runInShell: true);

      _fallbackSpeechProcess = process;
      unawaited(
        process.exitCode.then((_) {
          if (identical(_fallbackSpeechProcess, process)) {
            _fallbackSpeechProcess = null;
          }
        }),
      );

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();
      final stdoutDone = process.stdout
          .transform(utf8.decoder)
          .listen(stdoutBuffer.write)
          .asFuture<void>();
      final stderrDone = process.stderr
          .transform(utf8.decoder)
          .listen(stderrBuffer.write)
          .asFuture<void>();

      final exitCode = await process.exitCode;
      await Future.wait([stdoutDone, stderrDone]);

      if (exitCode != 0) {
        final stderrText = stderrBuffer.toString().trim();
        final stdoutText = stdoutBuffer.toString().trim();
        throw StateError(
          stderrText.isNotEmpty
              ? stderrText
              : stdoutText.isNotEmpty
              ? stdoutText
              : 'Realtime speech bridge failed.',
        );
      }
    } catch (_) {
      rethrow;
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
      ..writeln(
        r'$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer',
      )
      ..writeln(r'try {');

    if (safeVoiceName.isNotEmpty) {
      buffer.writeln(
        "  try { \$synth.SelectVoice('$safeVoiceName') } catch {}",
      );
    }

    buffer
      ..writeln('  \$synth.Rate = $rateValue')
      ..writeln(r'  $synth.Volume = 100')
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

  String _buildRealtimeSpeechTone({
    required double rate,
    required double pitch,
    String? voiceName,
    required VoiceSpeechTone tone,
  }) {
    final toneLine = switch (tone) {
      VoiceSpeechTone.wake =>
        'Treat this as a wake acknowledgement: brief, immediate, reassuring, and ready to move.',
      VoiceSpeechTone.briefing =>
        'Treat this as a briefing: concise, clear, and quietly powerful.',
      VoiceSpeechTone.wizard =>
        'Treat this as wizard guidance: step-by-step, calm, and confidence-building.',
      VoiceSpeechTone.calmConfirmation =>
        'Treat this as a calm save confirmation: short, grounded, and reassuring.',
      VoiceSpeechTone.neutral =>
        'Treat this as a normal dashboard reply: short, warm, practical, and sure of itself.',
    };

    return [
      'Speak the user text exactly in one calm, steady voice.',
      toneLine,
      'Keep the reply short, warm, conversational, and purposeful.',
      'Use clean pauses between the summary and the next step.',
      'Do not add extra information.',
      if (voiceName != null && voiceName.isNotEmpty)
        'The selected local voice label is $voiceName, but the spoken output should remain natural and calm.',
    ].join('\n');
  }

  Future<_PythonCommand?> _resolvePythonCommand() async {
    final commands = <_PythonCommand>[
      const _PythonCommand(command: 'py', args: ['-3']),
      const _PythonCommand(command: 'python', args: <String>[]),
      const _PythonCommand(command: 'python3', args: <String>[]),
    ];

    for (final candidate in commands) {
      try {
        final result = await Process.run(candidate.command, <String>[
          ...candidate.args,
          '--version',
        ], runInShell: true);
        if (result.exitCode == 0) {
          return candidate;
        }
      } catch (_) {
        // Try the next Python launcher.
      }
    }

    return null;
  }

  File? _locateBridgeScript() {
    final startingPoints = <Directory>[
      Directory.current,
      File(Platform.resolvedExecutable).parent,
    ];

    for (final start in startingPoints) {
      var directory = start;
      for (var i = 0; i < 8; i += 1) {
        final candidate = File(
          path.join(directory.path, 'tools', 'voice_bridge', 'voice_bridge.py'),
        );
        if (candidate.existsSync()) {
          return candidate;
        }

        final parent = directory.parent;
        if (parent.path == directory.path) {
          break;
        }
        directory = parent;
      }
    }

    return null;
  }
}

class _PythonCommand {
  const _PythonCommand({required this.command, required this.args});

  final String command;
  final List<String> args;
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
