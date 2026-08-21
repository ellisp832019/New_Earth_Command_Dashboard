import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/repo_research_engine/data/repo_research_engine_service.dart';

class FakeProcess implements Process {
  FakeProcess({this.onKill}) {
    _stdoutController = StreamController<List<int>>();
    _stderrController = StreamController<List<int>>();
  }

  late final StreamController<List<int>> _stdoutController;
  late final StreamController<List<int>> _stderrController;
  final Completer<int> _exitCodeCompleter = Completer<int>();
  final Future<void> Function()? onKill;

  int killCount = 0;
  bool stdoutClosed = false;
  bool stderrClosed = false;

  @override
  IOSink get stdin => throw UnimplementedError();

  @override
  Stream<List<int>> get stdout => _stdoutController.stream;

  @override
  Stream<List<int>> get stderr => _stderrController.stream;

  @override
  Future<int> get exitCode => _exitCodeCompleter.future;

  @override
  int get pid => 12345;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killCount += 1;
    unawaited(onKill?.call());
    return true;
  }

  void emitStdout(String text) {
    _stdoutController.add(utf8.encode(text));
  }

  void emitStderr(String text) {
    _stderrController.add(utf8.encode(text));
  }

  void completeExit(int code) {
    if (!_exitCodeCompleter.isCompleted) {
      _exitCodeCompleter.complete(code);
    }
  }

  Future<void> closeOutputs() async {
    if (!_stdoutController.isClosed) {
      await _stdoutController.close();
    }
    if (!_stderrController.isClosed) {
      await _stderrController.close();
    }
    stdoutClosed = true;
    stderrClosed = true;
  }
}

class RecordingProcessStarter {
  RecordingProcessStarter(this.process);

  final FakeProcess process;
  String? executable;
  List<String>? arguments;
  String? workingDirectory;
  bool? runInShell;
  int callCount = 0;

  Future<Process> call(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool runInShell = false,
  }) async {
    callCount += 1;
    this.executable = executable;
    this.arguments = List<String>.from(arguments);
    this.workingDirectory = workingDirectory;
    this.runInShell = runInShell;
    return process;
  }
}

void main() {
  group('RepoResearchEngineService.runResearch', () {
    test('successful run retains the current result shape', () async {
      final process = FakeProcess();
      final starter = RecordingProcessStarter(process);
      final service = RepoResearchEngineService(
        researchTimeout: const Duration(seconds: 1),
        processStarter: starter.call,
      );
      final moduleRoot = service.moduleRootDirectory().path;
      final expectedExecutable = Platform.isWindows ? 'python' : 'python3';

      process.emitStdout('research stdout\n');
      process.emitStderr('research stderr\n');
      process.completeExit(0);
      unawaited(
        Future<void>(() async {
          await process.closeOutputs();
        }),
      );

      final result = await service.runResearch(
        repoPath: 'D:/repo',
        profile: 'Generic',
        outDirectory: 'D:/out',
        omegaRoot: 'D:/omega',
        compareWith: 'D:/compare',
        baselineInventory: 'D:/baseline.json',
        compareProfile: 'Compare',
        graphExport: true,
      );

      expect(result.exitCode, 0);
      expect(result.stdout, 'research stdout\n');
      expect(result.stderr, 'research stderr\n');
      expect(result.outputDirectory, 'D:/out');
      expect(result.succeeded, isTrue);
      expect(starter.callCount, 1);
      expect(starter.executable, expectedExecutable);
      expect(starter.workingDirectory, moduleRoot);
      expect(starter.runInShell, isTrue);
      expect(
        starter.arguments,
        equals(<String>[
          path.join(moduleRoot, 'scripts', 'run_research.py'),
          '--repo',
          'D:/repo',
          '--profile',
          'Generic',
          '--out',
          'D:/out',
          '--omega-root',
          'D:/omega',
          '--compare-with',
          'D:/compare',
          '--baseline-inventory',
          'D:/baseline.json',
          '--compare-profile',
          'Compare',
          '--graph-export',
        ]),
      );
      expect(result.command, <String>[
        expectedExecutable,
        ...starter.arguments!,
      ]);
    });

    test('graph-export argument behaviour is preserved', () async {
      final processWithoutFlag = FakeProcess();
      final starterWithoutFlag = RecordingProcessStarter(processWithoutFlag);
      final serviceWithoutFlag = RepoResearchEngineService(
        researchTimeout: const Duration(seconds: 1),
        processStarter: starterWithoutFlag.call,
      );
      processWithoutFlag.completeExit(0);
      unawaited(
        Future<void>(() async {
          await processWithoutFlag.closeOutputs();
        }),
      );

      await serviceWithoutFlag.runResearch(
        repoPath: 'D:/repo',
        profile: 'Generic',
        outDirectory: 'D:/out',
        graphExport: false,
      );

      expect(starterWithoutFlag.arguments, isNot(contains('--graph-export')));

      final processWithFlag = FakeProcess();
      final starterWithFlag = RecordingProcessStarter(processWithFlag);
      final serviceWithFlag = RepoResearchEngineService(
        researchTimeout: const Duration(seconds: 1),
        processStarter: starterWithFlag.call,
      );
      processWithFlag.completeExit(0);
      unawaited(
        Future<void>(() async {
          await processWithFlag.closeOutputs();
        }),
      );

      await serviceWithFlag.runResearch(
        repoPath: 'D:/repo',
        profile: 'Generic',
        outDirectory: 'D:/out',
        graphExport: true,
      );

      expect(starterWithFlag.arguments, contains('--graph-export'));
    });

    test('non-zero exit retains current semantic behavior', () async {
      final process = FakeProcess();
      final starter = RecordingProcessStarter(process);
      final service = RepoResearchEngineService(
        researchTimeout: const Duration(seconds: 1),
        processStarter: starter.call,
      );

      process.emitStdout('stdout output');
      process.emitStderr('stderr output');
      process.completeExit(17);
      unawaited(
        Future<void>(() async {
          await process.closeOutputs();
        }),
      );

      final result = await service.runResearch(
        repoPath: 'D:/repo',
        profile: 'Generic',
        outDirectory: 'D:/out',
      );

      expect(result.exitCode, 17);
      expect(result.succeeded, isFalse);
      expect(result.stdout, 'stdout output');
      expect(result.stderr, 'stderr output');
      expect(starter.callCount, 1);
    });

    test('process-start failures are deterministic launch failures', () async {
      var callCount = 0;
      List<String>? arguments;
      String? capturedWorkingDirectory;
      bool? capturedRunInShell;
      final service = RepoResearchEngineService(
        researchTimeout: const Duration(seconds: 1),
        processStarter:
            (
              String executable,
              List<String> args, {
              String? workingDirectory,
              bool runInShell = false,
            }) async {
              callCount += 1;
              arguments = List<String>.from(args);
              capturedWorkingDirectory = workingDirectory;
              capturedRunInShell = runInShell;
              throw ProcessException(
                executable,
                args,
                'The system cannot find the file specified.',
              );
            },
      );

      try {
        await service.runResearch(
          repoPath: 'D:/repo',
          profile: 'Generic',
          outDirectory: 'D:/out',
        );
        fail('Expected runResearch to throw a launch failure.');
      } on RepoResearchProcessException catch (error) {
        expect(error.kind, RepoResearchProcessFailureKind.launchFailure);
        expect(error.message, 'Unable to start local research.');
        expect(
          error.details,
          contains('The system cannot find the file specified.'),
        );
        expect(error.stdout, isEmpty);
        expect(error.stderr, isEmpty);
        expect(callCount, 1);
        expect(capturedWorkingDirectory, isNotNull);
        expect(capturedRunInShell, isTrue);
        expect(arguments, isNotNull);
        expect(error.command.first, Platform.isWindows ? 'python' : 'python3');
      }
    });

    test('missing executable is classified as a launch failure', () async {
      final missingExecutableError = ProcessException(
        'python',
        const <String>[],
        'The system cannot find the file specified.',
      );

      var callCount = 0;
      List<String>? arguments;
      String? capturedWorkingDirectory;
      bool? capturedRunInShell;

      final failingService = RepoResearchEngineService(
        researchTimeout: const Duration(seconds: 1),
        processStarter:
            (
              String executable,
              List<String> args, {
              String? workingDirectory,
              bool runInShell = false,
            }) async {
              callCount += 1;
              arguments = List<String>.from(args);
              capturedWorkingDirectory = workingDirectory;
              capturedRunInShell = runInShell;
              throw missingExecutableError;
            },
      );

      try {
        await failingService.runResearch(
          repoPath: 'D:/repo',
          profile: 'Generic',
          outDirectory: 'D:/out',
        );
        fail('Expected runResearch to throw a launch failure.');
      } on RepoResearchProcessException catch (error) {
        expect(error.kind, RepoResearchProcessFailureKind.launchFailure);
        expect(error.message, 'Unable to start local research.');
        expect(
          error.details,
          contains('The system cannot find the file specified.'),
        );
        expect(callCount, 1);
        expect(arguments, isNotNull);
        expect(capturedWorkingDirectory, isNotNull);
        expect(capturedRunInShell, isTrue);
      }
    });

    test('timeout terminates the direct process and drains output', () async {
      late final FakeProcess process;
      final drainCompleted = Completer<void>();
      process = FakeProcess(
        onKill: () async {
          process.completeExit(124);
          await Future<void>.delayed(const Duration(milliseconds: 10));
          if (!drainCompleted.isCompleted) {
            drainCompleted.complete();
          }
          await process.closeOutputs();
        },
      );
      final starter = RecordingProcessStarter(process);
      final service = RepoResearchEngineService(
        researchTimeout: const Duration(milliseconds: 1),
        processStarter: starter.call,
      );

      process.emitStdout('partial stdout');
      process.emitStderr('partial stderr');

      try {
        await service.runResearch(
          repoPath: 'D:/repo',
          profile: 'Generic',
          outDirectory: 'D:/out',
        );
        fail('Expected runResearch to time out.');
      } on RepoResearchProcessException catch (error) {
        expect(error.kind, RepoResearchProcessFailureKind.timedOut);
        expect(error.message, 'Timed out while running local research.');
        expect(error.stdout, 'partial stdout');
        expect(error.stderr, 'partial stderr');
        expect(error.command.first, Platform.isWindows ? 'python' : 'python3');
      }

      expect(starter.callCount, 1);
      expect(process.killCount, 1);
      expect(drainCompleted.isCompleted, isTrue);
    });

    test('default timeout is defined in one place', () {
      expect(
        RepoResearchEngineService.defaultResearchTimeout,
        const Duration(minutes: 10),
      );
    });

    test(
      'runResearch does not create a repository-local data directory',
      () async {
        final process = FakeProcess();
        final starter = RecordingProcessStarter(process);
        final service = RepoResearchEngineService(
          researchTimeout: const Duration(seconds: 1),
          processStarter: starter.call,
        );

        process.completeExit(0);
        unawaited(
          Future<void>(() async {
            await process.closeOutputs();
          }),
        );

        await service.runResearch(
          repoPath: 'D:/repo',
          profile: 'Generic',
          outDirectory: 'D:/out',
        );

        expect(Directory('data').existsSync(), isFalse);
      },
    );
  });
}
