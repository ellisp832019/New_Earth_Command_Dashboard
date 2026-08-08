import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'local_git_live_state_models.dart';

abstract class LocalGitCommandExecutor {
  Future<String> readShowToplevel();
  Future<String> readHeadCommit();
  Future<String> readBranchName();
  Future<String> readStatusPorcelain();
  Future<String?> readUpstreamBranch();
  Future<String?> readAheadBehindCounts();
  Future<String?> readOriginRemoteUrl();
}

class ProcessLocalGitCommandExecutor implements LocalGitCommandExecutor {
  ProcessLocalGitCommandExecutor({
    required Directory repositoryRoot,
    this.timeout = const Duration(seconds: 10),
  }) : _repositoryRoot = repositoryRoot;

  final Directory _repositoryRoot;
  final Duration timeout;

  @override
  Future<String> readShowToplevel() {
    return _runCommand(<String>['rev-parse', '--show-toplevel']);
  }

  @override
  Future<String> readHeadCommit() {
    return _runCommand(<String>['rev-parse', 'HEAD']);
  }

  @override
  Future<String> readBranchName() {
    return _runCommand(<String>['branch', '--show-current']);
  }

  @override
  Future<String> readStatusPorcelain() {
    return _runCommand(<String>[
      'status',
      '--porcelain=v1',
      '--untracked-files=normal',
    ]);
  }

  @override
  Future<String?> readUpstreamBranch() async {
    try {
      return await _runCommand(<String>[
        'rev-parse',
        '--abbrev-ref',
        '--symbolic-full-name',
        '@{upstream}',
      ]);
    } on LocalGitObservationException catch (error) {
      if (error.kind == LocalGitObservationKind.commandFailed) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<String?> readAheadBehindCounts() async {
    try {
      return await _runCommand(<String>[
        'rev-list',
        '--left-right',
        '--count',
        'HEAD...@{upstream}',
      ]);
    } on LocalGitObservationException catch (error) {
      if (error.kind == LocalGitObservationKind.commandFailed) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<String?> readOriginRemoteUrl() async {
    try {
      return await _runCommand(<String>['remote', 'get-url', 'origin']);
    } on LocalGitObservationException catch (error) {
      if (error.kind == LocalGitObservationKind.commandFailed) {
        return null;
      }
      rethrow;
    }
  }

  Future<String> _runCommand(List<String> args) async {
    final command = 'git ${args.join(' ')}';
    Process process;
    try {
      process = await Process.start(
        'git',
        args,
        workingDirectory: _repositoryRoot.path,
        runInShell: false,
      );
    } on ProcessException catch (error) {
      throw LocalGitObservationException(
        kind: LocalGitObservationKind.gitUnavailable,
        message: 'Unable to start the git executable.',
        command: command,
        details: error.message,
      );
    }

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

    int exitCode;
    try {
      exitCode = await process.exitCode.timeout(timeout);
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      try {
        await Future.wait<void>(<Future<void>>[stdoutDone, stderrDone]);
      } catch (_) {}
      throw LocalGitObservationException(
        kind: LocalGitObservationKind.commandTimedOut,
        message: 'Timed out while running a read-only git command.',
        command: command,
      );
    }

    await Future.wait<void>(<Future<void>>[stdoutDone, stderrDone]);
    final stdoutText = stdoutBuffer.toString().trimRight();
    final stderrText = stderrBuffer.toString().trimRight();
    if (exitCode != 0) {
      throw LocalGitObservationException(
        kind: LocalGitObservationKind.commandFailed,
        message: 'Git command failed.',
        command: command,
        details: stderrText.isNotEmpty ? stderrText : stdoutText,
      );
    }

    return stdoutText;
  }
}
