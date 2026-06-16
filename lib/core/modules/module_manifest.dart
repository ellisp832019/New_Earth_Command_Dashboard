import 'package:flutter/material.dart';

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
    this.storagePath = '',
    this.iconKey = '',
    this.routes = const [],
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
  final String storagePath;
  final String iconKey;
  final List<String> routes;
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
    String? storagePath,
    String? iconKey,
    List<String>? routes,
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
      storagePath: storagePath ?? this.storagePath,
      iconKey: iconKey ?? this.iconKey,
      routes: routes ?? this.routes,
      health: health ?? this.health,
      source: source ?? this.source,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }
}

IconData moduleIconFor(
  String iconKey, {
  ModuleCategory? category,
}) {
  switch (iconKey.trim().toLowerCase()) {
    case 'science':
    case 'science_outlined':
      return Icons.science_outlined;
    case 'science_rounded':
      return Icons.science_rounded;
    case 'bug_report':
    case 'bug_report_outlined':
      return Icons.bug_report_outlined;
    case 'dashboard':
    case 'dashboard_outlined':
      return Icons.dashboard_outlined;
    case 'folder':
    case 'folder_outlined':
      return Icons.folder_outlined;
    case 'description':
    case 'description_outlined':
      return Icons.description_outlined;
    case 'biotech':
    case 'biotech_outlined':
      return Icons.biotech_outlined;
    case 'fact_check':
    case 'fact_check_outlined':
      return Icons.fact_check_outlined;
    case 'inventory_2':
    case 'inventory_2_outlined':
      return Icons.inventory_2_outlined;
    case 'hub':
    case 'hub_outlined':
      return Icons.hub_outlined;
    case 'flask':
    case 'flask_outlined':
      return Icons.science_outlined;
  }

  switch (category) {
    case null:
      return Icons.hub_outlined;
    case ModuleCategory.aiAutomation:
      return Icons.auto_awesome_outlined;
    case ModuleCategory.voiceHardware:
      return Icons.mic_none_rounded;
    case ModuleCategory.knowledgeResearch:
      return Icons.travel_explore_outlined;
    case ModuleCategory.projectManagement:
      return Icons.folder_outlined;
    case ModuleCategory.grantsFunding:
      return Icons.receipt_long_outlined;
    case ModuleCategory.backupRecovery:
      return Icons.backup_outlined;
    case ModuleCategory.microGrow:
      return Icons.spa_outlined;
    case ModuleCategory.xrVisualSystems:
      return Icons.view_in_ar_outlined;
    case ModuleCategory.financeTreasury:
      return Icons.account_balance_wallet_outlined;
    case ModuleCategory.systemCore:
      return Icons.settings_outlined;
    case ModuleCategory.security:
      return Icons.shield_outlined;
    case ModuleCategory.communityOutreach:
      return Icons.campaign_outlined;
  }
}
