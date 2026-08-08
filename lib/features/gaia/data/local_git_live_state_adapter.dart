import 'dart:io';

import 'package:path/path.dart' as path;

import 'local_git_command_executor.dart';
import 'local_git_live_state_models.dart';

class LocalGitLiveStateAdapter {
  LocalGitLiveStateAdapter({
    required Directory repositoryRoot,
    LocalGitCommandExecutor? commandExecutor,
    DateTime Function()? clock,
  }) : _repositoryRoot = repositoryRoot,
       _commandExecutor =
           commandExecutor ??
           ProcessLocalGitCommandExecutor(repositoryRoot: repositoryRoot),
       _clock = clock ?? DateTime.now;

  final Directory _repositoryRoot;
  final LocalGitCommandExecutor _commandExecutor;
  final DateTime Function() _clock;

  Future<LocalGitLiveState> observe() async {
    final issues = <LocalGitObservationIssue>[];
    final normalizedRoot = _normalizePath(_repositoryRoot.path);
    final topLevel = await _readTopLevelOrThrow();
    final normalizedTopLevel = _normalizePath(topLevel);
    if (!_samePath(normalizedRoot, normalizedTopLevel)) {
      throw LocalGitObservationException(
        kind: LocalGitObservationKind.rootMismatch,
        message:
            'The supplied repository root does not match the Git toplevel.',
        details: 'expected=$normalizedRoot, actual=$normalizedTopLevel',
      );
    }

    final observedCommit = await _readRequired(
      _commandExecutor.readHeadCommit,
      kind: LocalGitObservationKind.commandFailed,
      message: 'Unable to read the current HEAD commit.',
      command: 'git rev-parse HEAD',
    );
    if (observedCommit.trim().isEmpty) {
      throw const LocalGitObservationException(
        kind: LocalGitObservationKind.invalidOutput,
        message: 'Git returned an empty HEAD commit.',
        command: 'git rev-parse HEAD',
      );
    }

    final branchName = await _readRequired(
      _commandExecutor.readBranchName,
      kind: LocalGitObservationKind.commandFailed,
      message: 'Unable to read the current branch name.',
      command: 'git branch --show-current',
    );

    final headMode = branchName.trim().isEmpty
        ? LocalGitHeadMode.detached
        : LocalGitHeadMode.branch;

    final workingTreeState = await _readWorkingTreeState(issues);
    String? upstreamBranch;
    LocalGitAheadBehind? aheadBehind;
    if (headMode == LocalGitHeadMode.branch) {
      upstreamBranch = await _readUpstreamBranch(issues);
      if (upstreamBranch != null && upstreamBranch.trim().isNotEmpty) {
        aheadBehind = await _readAheadBehind(issues);
      }
    }

    final remoteIdentity = await _readRemoteIdentity(issues);

    final normalizedBranchName = branchName.trim();
    final normalizedUpstreamBranch = upstreamBranch?.trim();

    return LocalGitLiveState(
      repositoryRoot: normalizedRoot,
      observedAt: _clock().toUtc(),
      headMode: headMode,
      observedCommit: observedCommit.trim(),
      observedBranch: headMode == LocalGitHeadMode.branch
          ? normalizedBranchName
          : null,
      workingTreeState: workingTreeState,
      upstreamBranch:
          normalizedUpstreamBranch == null || normalizedUpstreamBranch.isEmpty
          ? null
          : normalizedUpstreamBranch,
      aheadBehind: aheadBehind,
      remoteIdentity: remoteIdentity,
      issues: issues,
    );
  }

  Future<String> _readTopLevelOrThrow() async {
    try {
      final topLevel = await _commandExecutor.readShowToplevel();
      if (topLevel.trim().isEmpty) {
        throw const LocalGitObservationException(
          kind: LocalGitObservationKind.invalidOutput,
          message: 'Git returned an empty repository toplevel.',
          command: 'git rev-parse --show-toplevel',
        );
      }
      return topLevel;
    } on LocalGitObservationException catch (error) {
      if (error.kind == LocalGitObservationKind.commandFailed) {
        throw LocalGitObservationException(
          kind: LocalGitObservationKind.notGitRepository,
          message: 'The supplied directory is not a Git repository.',
          command: 'git rev-parse --show-toplevel',
          details: error.details,
        );
      }
      rethrow;
    }
  }

  Future<String> _readRequired(
    Future<String> Function() loader, {
    required LocalGitObservationKind kind,
    required String message,
    required String command,
  }) async {
    try {
      return await loader();
    } on LocalGitObservationException catch (error) {
      throw LocalGitObservationException(
        kind: kind,
        message: message,
        command: command,
        details: error.details ?? error.toString(),
      );
    }
  }

  Future<LocalGitWorkingTreeState> _readWorkingTreeState(
    List<LocalGitObservationIssue> issues,
  ) async {
    try {
      final output = await _commandExecutor.readStatusPorcelain();
      return output.trim().isEmpty
          ? LocalGitWorkingTreeState.clean
          : LocalGitWorkingTreeState.dirty;
    } on LocalGitObservationException catch (error) {
      issues.add(
        LocalGitObservationIssue(
          kind: error.kind,
          severity: LocalGitObservationSeverity.warning,
          message: 'Unable to read the working tree state.',
          command: 'git status --porcelain=v1 --untracked-files=normal',
          output: error.details ?? error.toString(),
        ),
      );
      return LocalGitWorkingTreeState.unknown;
    }
  }

  Future<String?> _readUpstreamBranch(
    List<LocalGitObservationIssue> issues,
  ) async {
    try {
      return await _commandExecutor.readUpstreamBranch();
    } on LocalGitObservationException catch (error) {
      issues.add(
        LocalGitObservationIssue(
          kind: error.kind,
          severity: LocalGitObservationSeverity.warning,
          message: 'Unable to read the configured upstream branch.',
          command:
              'git rev-parse --abbrev-ref --symbolic-full-name @{upstream}',
          output: error.details ?? error.toString(),
        ),
      );
      return null;
    }
  }

  Future<LocalGitAheadBehind?> _readAheadBehind(
    List<LocalGitObservationIssue> issues,
  ) async {
    try {
      final output = await _commandExecutor.readAheadBehindCounts();
      if (output == null || output.trim().isEmpty) {
        return null;
      }
      final counts = output.trim().split(RegExp(r'\s+'));
      if (counts.length < 2) {
        issues.add(
          const LocalGitObservationIssue(
            kind: LocalGitObservationKind.invalidOutput,
            severity: LocalGitObservationSeverity.warning,
            message: 'Git returned invalid ahead/behind output.',
          ),
        );
        return null;
      }
      final ahead = int.tryParse(counts[0]);
      final behind = int.tryParse(counts[1]);
      if (ahead == null || behind == null) {
        issues.add(
          const LocalGitObservationIssue(
            kind: LocalGitObservationKind.invalidOutput,
            severity: LocalGitObservationSeverity.warning,
            message: 'Git returned non-integer ahead/behind output.',
          ),
        );
        return null;
      }
      return LocalGitAheadBehind(ahead: ahead, behind: behind);
    } on LocalGitObservationException catch (error) {
      issues.add(
        LocalGitObservationIssue(
          kind: error.kind,
          severity: LocalGitObservationSeverity.warning,
          message: 'Unable to read ahead/behind counts.',
          command: 'git rev-list --left-right --count HEAD...@{upstream}',
          output: error.details ?? error.toString(),
        ),
      );
      return null;
    }
  }

  Future<LocalGitRemoteIdentity?> _readRemoteIdentity(
    List<LocalGitObservationIssue> issues,
  ) async {
    try {
      final url = await _commandExecutor.readOriginRemoteUrl();
      if (url == null || url.trim().isEmpty) {
        return null;
      }
      return LocalGitRemoteIdentity(
        name: 'origin',
        url: _redactRemoteUrl(url.trim()),
      );
    } on LocalGitObservationException catch (error) {
      issues.add(
        LocalGitObservationIssue(
          kind: error.kind,
          severity: LocalGitObservationSeverity.warning,
          message: 'Unable to read the configured origin remote.',
          command: 'git remote get-url origin',
          output: error.details ?? error.toString(),
        ),
      );
      return null;
    }
  }

  static String _normalizePath(String value) {
    return path.normalize(path.absolute(value));
  }

  static bool _samePath(String left, String right) {
    final normalizedLeft = _canonicalPath(left);
    final normalizedRight = _canonicalPath(right);
    if (Platform.isWindows) {
      return normalizedLeft.toLowerCase() == normalizedRight.toLowerCase();
    }
    return path.equals(normalizedLeft, normalizedRight);
  }

  static String _canonicalPath(String value) {
    try {
      return Directory(value).resolveSymbolicLinksSync();
    } on FileSystemException {
      return path.normalize(path.absolute(value));
    }
  }

  static String _redactRemoteUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.scheme.isNotEmpty && uri.host.isNotEmpty) {
      if (uri.userInfo.isEmpty) {
        return uri.toString();
      }
      return Uri(
        scheme: uri.scheme,
        userInfo: 'redacted',
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: uri.path,
        query: uri.hasQuery ? uri.query : null,
        fragment: uri.hasFragment ? uri.fragment : null,
      ).toString();
    }

    final scpLike = RegExp(r'^[^@]+@([^:]+):(.+)$');
    final match = scpLike.firstMatch(url);
    if (match != null) {
      return 'redacted@${match.group(1)}:${match.group(2)}';
    }

    return url;
  }
}
