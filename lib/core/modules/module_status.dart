enum ModuleStatus {
  installed,
  enabled,
  disabled,
  needsConfiguration,
  error,
  planned,
  experimental,
}

extension ModuleStatusLabel on ModuleStatus {
  String get label {
    switch (this) {
      case ModuleStatus.installed:
        return 'Installed';
      case ModuleStatus.enabled:
        return 'Enabled';
      case ModuleStatus.disabled:
        return 'Disabled';
      case ModuleStatus.needsConfiguration:
        return 'Needs Configuration';
      case ModuleStatus.error:
        return 'Error';
      case ModuleStatus.planned:
        return 'Planned';
      case ModuleStatus.experimental:
        return 'Experimental';
    }
  }
}
