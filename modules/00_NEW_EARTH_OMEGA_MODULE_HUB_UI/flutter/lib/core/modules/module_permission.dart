enum PermissionState {
  disabled,
  askEveryTime,
  allowed,
}

extension PermissionStateLabel on PermissionState {
  String get label {
    switch (this) {
      case PermissionState.disabled:
        return 'Disabled';
      case PermissionState.askEveryTime:
        return 'Ask every time';
      case PermissionState.allowed:
        return 'Allowed';
    }
  }
}

class ModulePermission {
  const ModulePermission({
    required this.key,
    required this.label,
    this.description = '',
    this.state = PermissionState.disabled,
  });

  final String key;
  final String label;
  final String description;
  final PermissionState state;

  ModulePermission copyWith({PermissionState? state}) {
    return ModulePermission(
      key: key,
      label: label,
      description: description,
      state: state ?? this.state,
    );
  }
}
