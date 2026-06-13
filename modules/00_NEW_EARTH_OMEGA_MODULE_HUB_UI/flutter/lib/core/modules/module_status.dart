enum ModuleStatus {
  proposed,
  installed,
  disabled,
  enabled,
  running,
  needsConfiguration,
  warning,
  error,
  archived,
}

extension ModuleStatusLabel on ModuleStatus {
  String get label {
    switch (this) {
      case ModuleStatus.proposed:
        return 'Proposed';
      case ModuleStatus.installed:
        return 'Installed';
      case ModuleStatus.disabled:
        return 'Disabled';
      case ModuleStatus.enabled:
        return 'Enabled';
      case ModuleStatus.running:
        return 'Running';
      case ModuleStatus.needsConfiguration:
        return 'Needs Configuration';
      case ModuleStatus.warning:
        return 'Warning';
      case ModuleStatus.error:
        return 'Error';
      case ModuleStatus.archived:
        return 'Archived';
    }
  }
}
