import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/gaia/data/local_git_command_executor.dart';
import 'package:new_earth_command_dashboard/features/gaia/data/local_git_live_state_adapter.dart';
import 'package:new_earth_command_dashboard/features/gaia/data/local_git_live_state_models.dart';

void main() {
  group('LocalGitLiveStateAdapter', () {
    test('observes a real temp repository without mutating it', () async {
      final fixture = await _createRepositoryFixture();
      addTearDown(() async {
        await fixture.root.delete(recursive: true);
        await fixture.remote.delete(recursive: true);
      });

      final adapter = LocalGitLiveStateAdapter(
        repositoryRoot: fixture.root,
        clock: () => DateTime.parse('2026-08-08T12:34:56Z'),
      );
      final state = await adapter.observe();

      expect(
        state.repositoryRoot,
        path.normalize(path.absolute(fixture.root.path)),
      );
      expect(state.observedAt, DateTime.parse('2026-08-08T12:34:56Z'));
      expect(state.headMode, LocalGitHeadMode.branch);
      expect(state.observedBranch, 'feature/live-state');
      expect(state.observedCommit, fixture.latestCommit);
      expect(state.workingTreeState, LocalGitWorkingTreeState.clean);
      expect(state.upstreamBranch, 'origin/feature/live-state');
      expect(state.aheadBehind, isNotNull);
      expect(state.aheadBehind!.ahead, 1);
      expect(state.aheadBehind!.behind, 0);
      expect(state.remoteIdentity, isNotNull);
      expect(state.remoteIdentity!.name, 'origin');
      expect(
        state.remoteIdentity!.url,
        'https://redacted@github.com/ellisp832019/New_Earth_Command_Dashboard.git',
      );
      expect(state.issues, isEmpty);

      final statusAfter = await _gitCapture(fixture.root, <String>[
        'status',
        '--porcelain=v1',
        '--untracked-files=normal',
      ]);
      expect(statusAfter.trim(), isEmpty);
    });

    test('skips upstream and ahead-behind reads for detached heads', () async {
      final executor = FakeLocalGitCommandExecutor(
        showToplevelResult: '/tmp/repo',
        headCommitResult: 'deadbeef',
        branchNameResult: '',
        statusPorcelainResult: '',
        upstreamBranchResult: 'origin/main',
        aheadBehindCountsResult: '0 0',
        originRemoteUrlResult: 'https://example.com/repo.git',
      );
      final adapter = LocalGitLiveStateAdapter(
        repositoryRoot: Directory('/tmp/repo'),
        commandExecutor: executor,
        clock: () => DateTime.parse('2026-08-08T12:00:00Z'),
      );

      final state = await adapter.observe();

      expect(state.headMode, LocalGitHeadMode.detached);
      expect(state.observedBranch, isNull);
      expect(state.upstreamBranch, isNull);
      expect(state.aheadBehind, isNull);
      expect(state.remoteIdentity, isNotNull);
      expect(executor.calls, isNot(contains('readUpstreamBranch')));
      expect(executor.calls, isNot(contains('readAheadBehindCounts')));
    });

    test('reports status failures as unknown working tree state', () async {
      final executor = FakeLocalGitCommandExecutor(
        showToplevelResult: '/tmp/repo',
        headCommitResult: 'deadbeef',
        branchNameResult: 'feature/live-state',
        statusPorcelainError: LocalGitObservationException(
          kind: LocalGitObservationKind.commandTimedOut,
          message: 'Timed out while reading status.',
          command: 'git status --porcelain=v1 --untracked-files=normal',
        ),
      );
      final adapter = LocalGitLiveStateAdapter(
        repositoryRoot: Directory('/tmp/repo'),
        commandExecutor: executor,
        clock: () => DateTime.parse('2026-08-08T12:00:00Z'),
      );

      final state = await adapter.observe();

      expect(state.workingTreeState, LocalGitWorkingTreeState.unknown);
      expect(state.issues, hasLength(1));
      expect(state.issues.single.kind, LocalGitObservationKind.commandTimedOut);
      expect(state.issues.single.severity, LocalGitObservationSeverity.warning);
      expect(
        state.issues.single.command,
        'git status --porcelain=v1 --untracked-files=normal',
      );
    });

    test('rejects repository root mismatches', () async {
      final executor = FakeLocalGitCommandExecutor(
        showToplevelResult: '/tmp/other-repo',
        headCommitResult: 'deadbeef',
        branchNameResult: 'feature/live-state',
        statusPorcelainResult: '',
      );
      final adapter = LocalGitLiveStateAdapter(
        repositoryRoot: Directory('/tmp/repo'),
        commandExecutor: executor,
      );

      await expectLater(
        adapter.observe(),
        throwsA(
          isA<LocalGitObservationException>()
              .having(
                (error) => error.kind,
                'kind',
                LocalGitObservationKind.rootMismatch,
              )
              .having(
                (error) => error.message,
                'message',
                contains('does not match the Git toplevel'),
              ),
        ),
      );
    });
  });
}

class FakeLocalGitCommandExecutor implements LocalGitCommandExecutor {
  FakeLocalGitCommandExecutor({
    this.showToplevelResult,
    this.headCommitResult,
    this.branchNameResult,
    this.statusPorcelainResult,
    this.upstreamBranchResult,
    this.aheadBehindCountsResult,
    this.originRemoteUrlResult,
    this.showToplevelError,
    this.headCommitError,
    this.branchNameError,
    this.statusPorcelainError,
    this.upstreamBranchError,
    this.aheadBehindCountsError,
    this.originRemoteUrlError,
  });

  final String? showToplevelResult;
  final String? headCommitResult;
  final String? branchNameResult;
  final String? statusPorcelainResult;
  final String? upstreamBranchResult;
  final String? aheadBehindCountsResult;
  final String? originRemoteUrlResult;
  final LocalGitObservationException? showToplevelError;
  final LocalGitObservationException? headCommitError;
  final LocalGitObservationException? branchNameError;
  final LocalGitObservationException? statusPorcelainError;
  final LocalGitObservationException? upstreamBranchError;
  final LocalGitObservationException? aheadBehindCountsError;
  final LocalGitObservationException? originRemoteUrlError;

  final List<String> calls = <String>[];

  @override
  Future<String> readBranchName() async {
    calls.add('readBranchName');
    if (branchNameError != null) {
      throw branchNameError!;
    }
    return branchNameResult ?? '';
  }

  @override
  Future<String> readHeadCommit() async {
    calls.add('readHeadCommit');
    if (headCommitError != null) {
      throw headCommitError!;
    }
    return headCommitResult ?? '';
  }

  @override
  Future<String?> readAheadBehindCounts() async {
    calls.add('readAheadBehindCounts');
    if (aheadBehindCountsError != null) {
      throw aheadBehindCountsError!;
    }
    return aheadBehindCountsResult;
  }

  @override
  Future<String?> readOriginRemoteUrl() async {
    calls.add('readOriginRemoteUrl');
    if (originRemoteUrlError != null) {
      throw originRemoteUrlError!;
    }
    return originRemoteUrlResult;
  }

  @override
  Future<String> readShowToplevel() async {
    calls.add('readShowToplevel');
    if (showToplevelError != null) {
      throw showToplevelError!;
    }
    return showToplevelResult ?? '';
  }

  @override
  Future<String> readStatusPorcelain() async {
    calls.add('readStatusPorcelain');
    if (statusPorcelainError != null) {
      throw statusPorcelainError!;
    }
    return statusPorcelainResult ?? '';
  }

  @override
  Future<String?> readUpstreamBranch() async {
    calls.add('readUpstreamBranch');
    if (upstreamBranchError != null) {
      throw upstreamBranchError!;
    }
    return upstreamBranchResult;
  }
}

class _RepositoryFixture {
  _RepositoryFixture({
    required this.root,
    required this.remote,
    required this.latestCommit,
  });

  final Directory root;
  final Directory remote;
  final String latestCommit;
}

Future<_RepositoryFixture> _createRepositoryFixture() async {
  final remote = await Directory.systemTemp.createTemp(
    'gaia_local_git_remote_',
  );
  final root = await Directory.systemTemp.createTemp('gaia_local_git_repo_');

  await _git(remote, <String>['init', '--bare']);
  await _git(root, <String>['init']);
  await _git(root, <String>['checkout', '-b', 'feature/live-state']);
  await _git(root, <String>[
    'config',
    'user.name',
    'New Earth Command Dashboard',
  ]);
  await _git(root, <String>['config', 'user.email', 'codex@example.com']);

  final file = File(path.join(root.path, 'README.md'));
  await file.writeAsString('initial state\n', flush: true);
  await _git(root, <String>['add', 'README.md']);
  await _git(root, <String>['commit', '-m', 'initial commit']);
  await _git(root, <String>['remote', 'add', 'origin', remote.path]);
  await _git(root, <String>['push', '-u', 'origin', 'feature/live-state']);
  await file.writeAsString('initial state\nsecond commit\n', flush: true);
  await _git(root, <String>['add', 'README.md']);
  await _git(root, <String>['commit', '-m', 'second commit']);
  await _git(root, <String>[
    'remote',
    'set-url',
    'origin',
    'https://token:user@github.com/ellisp832019/New_Earth_Command_Dashboard.git',
  ]);

  final latestCommit = await _gitCapture(root, <String>['rev-parse', 'HEAD']);
  return _RepositoryFixture(
    root: root,
    remote: remote,
    latestCommit: latestCommit.trim(),
  );
}

Future<void> _git(Directory directory, List<String> args) async {
  final result = await Process.run(
    'git',
    args,
    workingDirectory: directory.path,
    runInShell: false,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'git ${args.join(' ')} failed: ${result.stderr ?? result.stdout}',
    );
  }
}

Future<String> _gitCapture(Directory directory, List<String> args) async {
  final result = await Process.run(
    'git',
    args,
    workingDirectory: directory.path,
    runInShell: false,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'git ${args.join(' ')} failed: ${result.stderr ?? result.stdout}',
    );
  }
  return result.stdout.toString();
}
