import '../dock/dock_position.dart';
import 'module_category.dart';
import 'module_health.dart';
import 'module_permissions.dart';
import 'module_status.dart';

enum ModuleManifestSource { manifest, inferred }

extension ModuleManifestSourceLabel on ModuleManifestSource {
  String get label {
    switch (this) {
      case ModuleManifestSource.manifest:
        return 'Manifest';
      case ModuleManifestSource.inferred:
        return 'Inferred scaffold';
    }
  }
}

class ModuleManifest {
  const ModuleManifest({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.version,
    required this.status,
    required this.enabled,
    required this.dockable,
    required this.defaultDockPosition,
    required this.permissions,
    required this.installPath,
    required this.omegaOsPath,
    required this.health,
    this.source = ModuleManifestSource.manifest,
    this.tags = const [],
    this.notes = '',
  });

  final String id;
  final String name;
  final String description;
  final ModuleCategory category;
  final String version;
  final ModuleStatus status;
  final bool enabled;
  final bool dockable;
  final DockPosition defaultDockPosition;
  final List<ModulePermission> permissions;
  final String installPath;
  final String omegaOsPath;
  final ModuleHealthSnapshot health;
  final ModuleManifestSource source;
  final List<String> tags;
  final String notes;

  ModuleManifest copyWith({
    String? name,
    String? description,
    ModuleCategory? category,
    String? version,
    ModuleStatus? status,
    bool? enabled,
    bool? dockable,
    DockPosition? defaultDockPosition,
    List<ModulePermission>? permissions,
    String? installPath,
    String? omegaOsPath,
    ModuleHealthSnapshot? health,
    ModuleManifestSource? source,
    List<String>? tags,
    String? notes,
  }) {
    return ModuleManifest(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      version: version ?? this.version,
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
      dockable: dockable ?? this.dockable,
      defaultDockPosition: defaultDockPosition ?? this.defaultDockPosition,
      permissions: permissions ?? this.permissions,
      installPath: installPath ?? this.installPath,
      omegaOsPath: omegaOsPath ?? this.omegaOsPath,
      health: health ?? this.health,
      source: source ?? this.source,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }
}
