import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/repo_research_engine/data/repo_research_engine_service.dart';

class FakeProcess implements Process {
  FakeProcess({this.onKill, this.onStdinData}) {
    _stdoutController = StreamController<List<int>>();
    _stderrController = StreamController<List<int>>();
    _stdinSink = IOSink(_RecordingStdinConsumer(onData: onStdinData));
  }

  late final StreamController<List<int>> _stdoutController;
  late final StreamController<List<int>> _stderrController;
  late final IOSink _stdinSink;
  final Completer<int> _exitCodeCompleter = Completer<int>();
  final Future<void> Function()? onKill;
  final void Function(String data)? onStdinData;

  int killCount = 0;
  bool stdoutClosed = false;
  bool stderrClosed = false;

  @override
  IOSink get stdin => _stdinSink;

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

class _RecordingStdinConsumer implements StreamConsumer<List<int>> {
  _RecordingStdinConsumer({this.onData});

  final void Function(String data)? onData;

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    final bytes = <int>[];
    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }
    onData?.call(utf8.decode(bytes));
  }

  @override
  Future<void> close() async {}
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

  group('RepoResearchEngineService.cloneRepository', () {
    Future<Directory> temporaryWorkingDirectory() {
      return Directory.systemTemp.createTemp('repo-research-clone-test-');
    }

    Map<String, dynamic> successPayload() {
      return <String, dynamic>{
        'exitCode': 0,
        'source': 'https://example.com/repo.git',
        'workspaceRoot': 'D:/workspace',
        'repositoryRoot': 'D:/workspace/owner/repo',
        'sourceRoot': 'D:/workspace/owner/repo/source',
        'provider': 'github',
        'ownerPath': 'owner',
        'repoName': 'repo',
        'branch': 'main',
        'commit': 'abc123',
        'manifestPath': 'D:/workspace/owner/repo/manifest.json',
        'workspaceManifestPath': 'D:/workspace/manifest.json',
        'command': <String>[],
        'stdout': '',
        'stderr': '',
      };
    }

    test(
      'passes the versioned protocol and preserves clone arguments',
      () async {
        final workingDirectory = await temporaryWorkingDirectory();
        addTearDown(() => workingDirectory.delete(recursive: true));
        final process = FakeProcess();
        final starter = RecordingProcessStarter(process);
        process.emitStdout(jsonEncode(successPayload()));
        process.completeExit(0);
        unawaited(process.closeOutputs());

        final service = RepoResearchEngineService(
          workingDirectory: workingDirectory,
          processStarter: starter.call,
        );
        final result = await service.cloneRepository(
          source: 'https://example.com/repo.git',
          workspaceRoot: 'D:/workspace',
          branch: 'main',
        );

        final args = starter.arguments!;
        final operationIndex = args.indexOf('--operation-id');
        final operationId = args[operationIndex + 1];
        expect(
          operationId,
          matches(RegExp(r'^clone_v1_[0-9]{8}T[0-9]{6}Z_[0-9a-f]{32}$')),
        );
        expect(
          args,
          containsAll(<String>[
            '--protocol-version',
            'ds05-c4b1-clone-protocol-v1',
            '--source',
            'https://example.com/repo.git',
            '--workspace-root',
            'D:/workspace',
            '--branch',
            'main',
          ]),
        );
        expect(args, isNot(contains('--control-stdin')));
        expect(result.repoName, 'repo');
        expect(result.exitCode, 0);
        expect(result.command, <String>[
          Platform.isWindows ? 'python' : 'python3',
          ...args,
        ]);

        final history = File(
          path.join(
            workingDirectory.path,
            'modules',
            'repo_research_engine',
            'reports',
            'clone_history.json',
          ),
        );
        expect(await history.exists(), isTrue);
        expect(jsonDecode(await history.readAsString()), hasLength(1));
      },
    );

    test('default watchdog is at least thirteen minutes and is injectable', () {
      expect(
        RepoResearchEngineService.defaultCloneWatchdogTimeout,
        greaterThanOrEqualTo(const Duration(minutes: 13)),
      );
      final service = RepoResearchEngineService(
        cloneWatchdogTimeout: const Duration(seconds: 7),
      );
      expect(service, isNotNull);
    });

    test('parses structured failures without appending history', () async {
      final workingDirectory = await temporaryWorkingDirectory();
      addTearDown(() => workingDirectory.delete(recursive: true));
      final process = FakeProcess();
      final operationReady = Completer<String>();
      Future<Process> failingStarter(
        String executable,
        List<String> arguments, {
        String? workingDirectory,
        bool runInShell = false,
      }) async {
        final operationId = arguments[arguments.indexOf('--operation-id') + 1];
        operationReady.complete(operationId);
        process.emitStderr(
          jsonEncode(<String, dynamic>{
            'protocol_version': 'ds05-c4b1-clone-protocol-v1',
            'operation_id': operationId,
            'kind': 'clone_failure',
            'failure_kind': 'git_failed',
            'message': 'Git failed for token=hidden',
            'exit_code': 12,
            'stdout': '',
            'stderr': 'https://user:secret@example.com/repo.git',
            'cleanup_state': 'completed',
            'primary_cause': null,
          }),
        );
        process.completeExit(12);
        unawaited(process.closeOutputs());
        return process;
      }

      final serviceWithFailureStarter = RepoResearchEngineService(
        workingDirectory: workingDirectory,
        processStarter: failingStarter,
      );
      try {
        await serviceWithFailureStarter.cloneRepository(
          source: 'D:/source',
          workspaceRoot: 'D:/workspace',
        );
        fail('Expected a structured clone failure.');
      } on RepoResearchCloneException catch (error) {
        expect(error.kind, RepoResearchCloneFailureKind.gitFailure);
        expect(error.operationId, await operationReady.future);
        expect(error.message, isNot(contains('hidden')));
        expect(error.stderr, isNot(contains('secret')));
      }
      final history = File(
        path.join(
          workingDirectory.path,
          'modules',
          'repo_research_engine',
          'reports',
          'clone_history.json',
        ),
      );
      expect(await history.exists(), isFalse);
    });

    test('sends one operation-scoped cancellation frame', () async {
      final workingDirectory = await temporaryWorkingDirectory();
      addTearDown(() => workingDirectory.delete(recursive: true));
      final cancellation = RepoResearchCloneCancellation();
      String? operationId;
      String? frameText;
      late final FakeProcess process;
      process = FakeProcess(
        onStdinData: (data) {
          frameText = data.trim();
          final frame = jsonDecode(frameText!) as Map<String, dynamic>;
          process.emitStderr(
            jsonEncode(<String, dynamic>{
              'protocol_version': 'ds05-c4b1-clone-protocol-v1',
              'operation_id': operationId,
              'kind': 'clone_failure',
              'failure_kind': 'cancelled',
              'message': 'Clone cancelled.',
              'exit_code': 14,
              'stdout': '',
              'stderr': '',
              'cleanup_state': 'completed',
              'primary_cause': null,
            }),
          );
          expect(frame['operation_id'], operationId);
          process.completeExit(14);
          unawaited(process.closeOutputs());
        },
      );
      final starter = RecordingProcessStarter(process);
      final service = RepoResearchEngineService(
        workingDirectory: workingDirectory,
        processStarter: starter.call,
      );
      final pending = service.cloneRepositoryWithCancellation(
        source: 'D:/source',
        workspaceRoot: 'D:/workspace',
        cancellation: cancellation,
      );
      while (starter.arguments == null) {
        await Future<void>.delayed(Duration.zero);
      }
      operationId =
          starter.arguments![starter.arguments!.indexOf('--operation-id') + 1];
      expect(starter.arguments, contains('--control-stdin'));
      cancellation.request();
      cancellation.request();

      try {
        await pending;
        fail('Expected cancellation to fail the clone.');
      } on RepoResearchCloneException catch (error) {
        expect(error.kind, RepoResearchCloneFailureKind.cancelled);
      }
      expect(frameText, isNotNull);
      expect(jsonDecode(frameText!)['operation_id'], operationId);
    });

    test(
      'cancellation requested after success does not change the result',
      () async {
        final workingDirectory = await temporaryWorkingDirectory();
        addTearDown(() => workingDirectory.delete(recursive: true));
        var frameCount = 0;
        final process = FakeProcess(onStdinData: (_) => frameCount += 1);
        process.emitStdout(jsonEncode(successPayload()));
        process.completeExit(0);
        unawaited(process.closeOutputs());
        final cancellation = RepoResearchCloneCancellation();
        final service = RepoResearchEngineService(
          workingDirectory: workingDirectory,
          processStarter: RecordingProcessStarter(process).call,
        );

        final result = await service.cloneRepositoryWithCancellation(
          source: 'D:/source',
          workspaceRoot: 'D:/workspace',
          cancellation: cancellation,
        );
        cancellation.request();
        await Future<void>.delayed(Duration.zero);

        expect(result.succeeded, isTrue);
        expect(frameCount, 0);
      },
    );

    test(
      'watchdog kills only the owned Python process and drains output',
      () async {
        final workingDirectory = await temporaryWorkingDirectory();
        addTearDown(() => workingDirectory.delete(recursive: true));
        late final FakeProcess process;
        process = FakeProcess(
          onKill: () async {
            process.completeExit(137);
            await process.closeOutputs();
          },
        );
        final service = RepoResearchEngineService(
          workingDirectory: workingDirectory,
          cloneWatchdogTimeout: const Duration(milliseconds: 5),
          processStarter: RecordingProcessStarter(process).call,
        );
        try {
          await service.cloneRepository(
            source: 'D:/source',
            workspaceRoot: 'D:/workspace',
          );
          fail('Expected watchdog failure.');
        } on RepoResearchCloneException catch (error) {
          expect(error.kind, RepoResearchCloneFailureKind.watchdogFailure);
        }
        expect(process.killCount, 1);
        expect(process.stdoutClosed, isTrue);
        expect(process.stderrClosed, isTrue);
      },
    );
  });
}
