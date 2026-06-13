import '../dock/dock_position.dart';
import 'module_permission.dart';
import 'module_status.dart';

class ModuleManifest {
  const ModuleManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.category,
    required this.description,
    required this.status,
    required this.dockable,
    required this.defaultDockPosition,
    required this.permissions,
    required this.omegaOsPath,
    this.enabled = false,
  });

  final String id;
  final String name;
  final String version;
  final String category;
  final String description;
  final ModuleStatus status;
  final bool dockable;
  final DockPosition defaultDockPosition;
  final List<ModulePermission> permissions;
  final String omegaOsPath;
  final bool enabled;

  ModuleManifest copyWith({
    ModuleStatus? status,
    bool? enabled,
    List<ModulePermission>? permissions,
  }) {
    return ModuleManifest(
      id: id,
      name: name,
      version: version,
      category: category,
      description: description,
      status: status ?? this.status,
      dockable: dockable,
      defaultDockPosition: defaultDockPosition,
      permissions: permissions ?? this.permissions,
      omegaOsPath: omegaOsPath,
      enabled: enabled ?? this.enabled,
    );
  }
}
