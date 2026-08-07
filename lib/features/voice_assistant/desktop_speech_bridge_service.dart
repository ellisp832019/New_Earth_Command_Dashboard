import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class DesktopSpeechBridgeCapture {
  const DesktopSpeechBridgeCapture({
    required this.transcript,
    this.model,
    this.durationSeconds,
    this.segments = const <DesktopSpeechBridgeSegment>[],
  });

  final String transcript;
  final String? model;
  final int? durationSeconds;
  final List<DesktopSpeechBridgeSegment> segments;
}

class DesktopSpeechBridgeDiagnostics {
  const DesktopSpeechBridgeDiagnostics({
    required this.ok,
    required this.pythonVersion,
    required this.bridgeModel,
    required this.defaultInputDevice,
    required this.inputDevices,
    required this.recommendation,
  });

  final bool ok;
  final String pythonVersion;
  final String bridgeModel;
  final Map<String, dynamic>? defaultInputDevice;
  final List<Map<String, dynamic>> inputDevices;
  final String recommendation;

  factory DesktopSpeechBridgeDiagnostics.fromJson(Map<String, dynamic> json) {
    final devices = (json['input_devices'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((device) => Map<String, dynamic>.from(device))
        .toList();
    final defaultDevice = json['default_input_device'];
    return DesktopSpeechBridgeDiagnostics(
      ok: json['ok'] == true,
      pythonVersion: json['python_version']?.toString() ?? 'unknown',
      bridgeModel: json['bridge_model']?.toString() ?? 'unknown',
      defaultInputDevice: defaultDevice is Map
          ? Map<String, dynamic>.from(defaultDevice)
          : null,
      inputDevices: devices,
      recommendation: json['recommendation']?.toString() ?? '',
    );
  }
}

class DesktopSpeechBridgeJob {
  const DesktopSpeechBridgeJob({required this.result, required this.cancel});

  final Future<DesktopSpeechBridgeCapture?> result;
  final VoidCallback cancel;
}

class DesktopSpeechBridgeSegment {
  const DesktopSpeechBridgeSegment({
    required this.startSeconds,
    required this.endSeconds,
    required this.text,
  });

  final double startSeconds;
  final double endSeconds;
  final String text;
}

class DesktopSpeechBridgeService {
  DesktopSpeechBridgeService();

  static bool get isSupported =>
      !kIsWeb &&
      Platform.isWindows &&
      Platform.environment['FLUTTER_TEST'] != 'true';

  Future<DesktopSpeechBridgeCapture?> captureOnce({
    Duration timeout = const Duration(seconds: 120),
    int durationSeconds = 8,
  }) async {
    final job = await _startBridgeCapture([
      'listen-once',
      '--json',
      '--duration',
      durationSeconds.toString(),
    ], timeout: timeout);
    return job.result;
  }

  Future<DesktopSpeechBridgeCapture?> transcribeFile(
    String sourcePath, {
    Duration timeout = const Duration(minutes: 30),
    String? draftOutputPath,
  }) async {
    final job = await startTranscribeFile(
      sourcePath,
      timeout: timeout,
      draftOutputPath: draftOutputPath,
    );
    return job.result;
  }

  Future<DesktopSpeechBridgeDiagnostics?> diagnoseAudio({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!isSupported) {
      return null;
    }

    final script = _locateBridgeScript();
    if (script == null) {
      return null;
    }

    final python = await _resolvePythonCommand();
    if (python == null) {
      return null;
    }

    final args = <String>[
      ...python.args,
      script.path,
      'diagnose-audio',
      '--json',
    ];

    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();
    var cancelled = false;
    Process? process;

    try {
      process = await Process.start(python.command, args, runInShell: true);

      final stdoutDone = process.stdout
          .transform(utf8.decoder)
          .listen(stdoutBuffer.write)
          .asFuture<void>();
      final stderrDone = process.stderr
          .transform(utf8.decoder)
          .listen(stderrBuffer.write)
          .asFuture<void>();

      final exitCode = await process.exitCode.timeout(
        timeout,
        onTimeout: () {
          cancelled = true;
          process?.kill(ProcessSignal.sigterm);
          return -1;
        },
      );

      await Future.wait([stdoutDone, stderrDone]);

      if (cancelled || exitCode != 0) {
        return null;
      }

      final payload = stdoutBuffer.toString().trim();
      if (payload.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return DesktopSpeechBridgeDiagnostics.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<DesktopSpeechBridgeJob> startTranscribeFile(
    String sourcePath, {
    Duration timeout = const Duration(minutes: 30),
    String? draftOutputPath,
  }) async {
    final trimmedPath = sourcePath.trim();
    if (trimmedPath.isEmpty) {
      return DesktopSpeechBridgeJob(
        result: Future<DesktopSpeechBridgeCapture?>.value(null),
        cancel: () {},
      );
    }

    return _startBridgeCapture([
      'transcribe-file',
      '--json',
      trimmedPath,
      if (draftOutputPath != null && draftOutputPath.trim().isNotEmpty)
        '--draft-output',
      if (draftOutputPath != null && draftOutputPath.trim().isNotEmpty)
        draftOutputPath.trim(),
    ], timeout: timeout);
  }

  Future<DesktopSpeechBridgeJob> _startBridgeCapture(
    List<String> commandArgs, {
    required Duration timeout,
  }) async {
    if (!isSupported) {
      return DesktopSpeechBridgeJob(
        result: Future<DesktopSpeechBridgeCapture?>.value(null),
        cancel: () {},
      );
    }

    final script = _locateBridgeScript();
    if (script == null) {
      return DesktopSpeechBridgeJob(
        result: Future<DesktopSpeechBridgeCapture?>.value(null),
        cancel: () {},
      );
    }

    final python = await _resolvePythonCommand();
    if (python == null) {
      return DesktopSpeechBridgeJob(
        result: Future<DesktopSpeechBridgeCapture?>.value(null),
        cancel: () {},
      );
    }

    final args = <String>[...python.args, script.path, ...commandArgs];

    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();
    var cancelled = false;
    Process? process;

    Future<DesktopSpeechBridgeCapture?> resultFuture() async {
      try {
        process = await Process.start(python.command, args, runInShell: true);

        final stdoutDone = process!.stdout
            .transform(utf8.decoder)
            .listen(stdoutBuffer.write)
            .asFuture<void>();
        final stderrDone = process!.stderr
            .transform(utf8.decoder)
            .listen(stderrBuffer.write)
            .asFuture<void>();

        final exitCode = await process!.exitCode.timeout(
          timeout,
          onTimeout: () {
            cancelled = true;
            process?.kill(ProcessSignal.sigterm);
            return -1;
          },
        );

        await Future.wait([stdoutDone, stderrDone]);

        if (cancelled || exitCode != 0) {
          return null;
        }

        final payload = stdoutBuffer.toString().trim();
        if (payload.isEmpty) {
          return null;
        }

        final decoded = jsonDecode(payload);
        if (decoded is! Map<String, dynamic>) {
          return null;
        }

        final transcript = (decoded['transcript'] ?? '').toString().trim();
        if (transcript.isEmpty) {
          return null;
        }

        return DesktopSpeechBridgeCapture(
          transcript: transcript,
          model: decoded['model']?.toString(),
          durationSeconds: int.tryParse(
            decoded['duration_seconds']?.toString() ?? '',
          ),
          segments: _parseSegments(decoded['segments']),
        );
      } catch (_) {
        return null;
      }
    }

    return DesktopSpeechBridgeJob(
      result: resultFuture(),
      cancel: () {
        cancelled = true;
        process?.kill(ProcessSignal.sigterm);
      },
    );
  }

  List<DesktopSpeechBridgeSegment> _parseSegments(dynamic rawSegments) {
    if (rawSegments is! List) {
      return const <DesktopSpeechBridgeSegment>[];
    }

    final segments = <DesktopSpeechBridgeSegment>[];
    for (final rawSegment in rawSegments) {
      if (rawSegment is! Map) {
        continue;
      }
      final start = double.tryParse(rawSegment['start']?.toString() ?? '');
      final end = double.tryParse(rawSegment['end']?.toString() ?? '');
      final text = rawSegment['text']?.toString().trim() ?? '';
      if (start == null || end == null || text.isEmpty) {
        continue;
      }
      segments.add(
        DesktopSpeechBridgeSegment(
          startSeconds: start,
          endSeconds: end,
          text: text,
        ),
      );
    }
    return segments;
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
