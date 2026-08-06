enum ModuleHealthState { healthy, warning, degraded, offline, error, unknown }

extension ModuleHealthStateLabel on ModuleHealthState {
  String get label {
    switch (this) {
      case ModuleHealthState.healthy:
        return 'Healthy';
      case ModuleHealthState.warning:
        return 'Warning';
      case ModuleHealthState.degraded:
        return 'Degraded';
      case ModuleHealthState.offline:
        return 'Offline';
      case ModuleHealthState.error:
        return 'Error';
      case ModuleHealthState.unknown:
        return 'Unknown';
    }
  }
}

class ModuleHealthSnapshot {
  const ModuleHealthSnapshot({
    required this.state,
    required this.lastCheckedLabel,
    required this.backendStatus,
    required this.errors,
    required this.warnings,
    required this.nextAction,
  });

  final ModuleHealthState state;
  final String lastCheckedLabel;
  final String backendStatus;
  final List<String> errors;
  final List<String> warnings;
  final String nextAction;

  ModuleHealthSnapshot copyWith({
    ModuleHealthState? state,
    String? lastCheckedLabel,
    String? backendStatus,
    List<String>? errors,
    List<String>? warnings,
    String? nextAction,
  }) {
    return ModuleHealthSnapshot(
      state: state ?? this.state,
      lastCheckedLabel: lastCheckedLabel ?? this.lastCheckedLabel,
      backendStatus: backendStatus ?? this.backendStatus,
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      nextAction: nextAction ?? this.nextAction,
    );
  }
}
