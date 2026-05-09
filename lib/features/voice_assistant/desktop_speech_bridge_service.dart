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
  });

  final String transcript;
  final String? model;
  final int? durationSeconds;
}

class DesktopSpeechBridgeService {
  DesktopSpeechBridgeService();

  static bool get isSupported =>
      !kIsWeb && Platform.isWindows && Platform.environment['FLUTTER_TEST'] != 'true';

  Future<DesktopSpeechBridgeCapture?> captureOnce({
    Duration timeout = const Duration(seconds: 120),
    int durationSeconds = 8,
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
      'listen-once',
      '--json',
      '--duration',
      durationSeconds.toString(),
    ];

    try {
      final process = await Process.start(
        python.command,
        args,
        runInShell: true,
      );

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      final stdoutDone = process.stdout
          .transform(utf8.decoder)
          .listen(stdoutBuffer.write).asFuture<void>();
      final stderrDone = process.stderr
          .transform(utf8.decoder)
          .listen(stderrBuffer.write).asFuture<void>();

      final exitCode = await process.exitCode.timeout(
        timeout,
        onTimeout: () {
          process.kill(ProcessSignal.sigterm);
          return -1;
        },
      );

      await Future.wait([stdoutDone, stderrDone]);

      if (exitCode != 0) {
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
        durationSeconds: int.tryParse(decoded['duration_seconds']?.toString() ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

  Future<_PythonCommand?> _resolvePythonCommand() async {
    final commands = <_PythonCommand>[
      const _PythonCommand(command: 'py', args: ['-3']),
      const _PythonCommand(command: 'python', args: <String>[]),
      const _PythonCommand(command: 'python3', args: <String>[]),
    ];

    for (final candidate in commands) {
      try {
        final result = await Process.run(
          candidate.command,
          <String>[...candidate.args, '--version'],
          runInShell: true,
        );
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
  const _PythonCommand({
    required this.command,
    required this.args,
  });

  final String command;
  final List<String> args;
}
