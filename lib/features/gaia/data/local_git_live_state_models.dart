enum LocalGitHeadMode { branch, detached }

enum LocalGitWorkingTreeState { clean, dirty, unknown }

enum LocalGitObservationKind {
  notGitRepository,
  gitUnavailable,
  commandFailed,
  commandTimedOut,
  invalidOutput,
  rootMismatch,
  upstreamUnavailable,
  remoteUnavailable,
}

enum LocalGitObservationSeverity { info, warning, error }

class LocalGitObservationIssue {
  const LocalGitObservationIssue({
    required this.kind,
    required this.severity,
    required this.message,
    this.command,
    this.output,
  });

  final LocalGitObservationKind kind;
  final LocalGitObservationSeverity severity;
  final String message;
  final String? command;
  final String? output;
}

class LocalGitObservationException implements Exception {
  const LocalGitObservationException({
    required this.kind,
    required this.message,
    this.command,
    this.details,
  });

  final LocalGitObservationKind kind;
  final String message;
  final String? command;
  final String? details;

  @override
  String toString() {
    final buffer = StringBuffer('LocalGitObservationException(');
    buffer.write(kind.name);
    buffer.write('): ');
    buffer.write(message);
    if (command != null && command!.isNotEmpty) {
      buffer.write(' [command: $command]');
    }
    if (details != null && details!.isNotEmpty) {
      buffer.write(' [details: $details]');
    }
    return buffer.toString();
  }
}

class LocalGitAheadBehind {
  const LocalGitAheadBehind({required this.ahead, required this.behind});

  final int ahead;
  final int behind;
}

class LocalGitRemoteIdentity {
  const LocalGitRemoteIdentity({required this.name, required this.url});

  final String name;
  final String url;
}

class LocalGitLiveState {
  LocalGitLiveState({
    required this.repositoryRoot,
    required this.observedAt,
    required this.headMode,
    required this.observedCommit,
    required this.workingTreeState,
    required List<LocalGitObservationIssue> issues,
    this.observedBranch,
    this.upstreamBranch,
    this.aheadBehind,
    this.remoteIdentity,
  }) : issues = List<LocalGitObservationIssue>.unmodifiable(issues);

  final String repositoryRoot;
  final DateTime observedAt;
  final LocalGitHeadMode headMode;
  final String observedCommit;
  final String? observedBranch;
  final LocalGitWorkingTreeState workingTreeState;
  final String? upstreamBranch;
  final LocalGitAheadBehind? aheadBehind;
  final LocalGitRemoteIdentity? remoteIdentity;
  final List<LocalGitObservationIssue> issues;
}
