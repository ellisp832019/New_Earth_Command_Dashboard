enum ModulePermissionType {
  microphone,
  speaker,
  screenCapture,
  fileRead,
  fileWrite,
  browserControl,
  appLaunch,
  shellCommands,
  mouseKeyboardControl,
  localNetwork,
  internetAccess,
  calendarAccess,
  emailAccess,
  contactsAccess,
  repoAccess,
  omegaOsAccess,
}

extension ModulePermissionTypeLabel on ModulePermissionType {
  String get label {
    switch (this) {
      case ModulePermissionType.microphone:
        return 'Microphone';
      case ModulePermissionType.speaker:
        return 'Speaker';
      case ModulePermissionType.screenCapture:
        return 'Screen Capture';
      case ModulePermissionType.fileRead:
        return 'File Read';
      case ModulePermissionType.fileWrite:
        return 'File Write';
      case ModulePermissionType.browserControl:
        return 'Browser Control';
      case ModulePermissionType.appLaunch:
        return 'App Launch';
      case ModulePermissionType.shellCommands:
        return 'Shell Commands';
      case ModulePermissionType.mouseKeyboardControl:
        return 'Mouse + Keyboard Control';
      case ModulePermissionType.localNetwork:
        return 'Local Network';
      case ModulePermissionType.internetAccess:
        return 'Internet Access';
      case ModulePermissionType.calendarAccess:
        return 'Calendar Access';
      case ModulePermissionType.emailAccess:
        return 'Email Access';
      case ModulePermissionType.contactsAccess:
        return 'Contacts Access';
      case ModulePermissionType.repoAccess:
        return 'Repo Access';
      case ModulePermissionType.omegaOsAccess:
        return 'Omega OS Access';
    }
  }
}

enum ModulePermissionState { disabled, askEveryTime, allowed }

extension ModulePermissionStateLabel on ModulePermissionState {
  String get label {
    switch (this) {
      case ModulePermissionState.disabled:
        return 'Disabled';
      case ModulePermissionState.askEveryTime:
        return 'Ask Every Time';
      case ModulePermissionState.allowed:
        return 'Allowed';
    }
  }
}

class ModulePermission {
  const ModulePermission({
    required this.type,
    this.state = ModulePermissionState.disabled,
    this.notes = '',
  });

  final ModulePermissionType type;
  final ModulePermissionState state;
  final String notes;

  String get label => type.label;

  ModulePermission copyWith({ModulePermissionState? state, String? notes}) {
    return ModulePermission(
      type: type,
      state: state ?? this.state,
      notes: notes ?? this.notes,
    );
  }
}
