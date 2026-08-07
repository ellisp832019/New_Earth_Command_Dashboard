import 'dart:convert';
import 'dart:io';

import 'module_hub_state_repository.dart';
import 'module_manifest.dart';
import 'module_manifest_parser.dart';
import 'module_registry.dart';
import 'module_status.dart';
import '../dock/dock_position.dart';
import 'module_category.dart';
import 'module_health.dart';
import 'module_permissions.dart';
import '../routing/route_names.dart';

class ModuleLoader {
  const ModuleLoader({this.modulesRootPath = 'modules'});

  final String modulesRootPath;

  ModuleRegistry load({
    Map<String, bool>? enabledOverrides,
    ModuleHubStateRepository? stateRepository,
  }) {
    final parser = ModuleManifestParser();
    final modules = <ModuleManifest>[_moduleHubManifest()];
    final root = Directory(modulesRootPath);

    if (root.existsSync()) {
      final moduleDirectories =
          root.listSync(followLinks: false).whereType<Directory>().toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      for (final moduleDirectory in moduleDirectories) {
        final folderName = _folderName(moduleDirectory.path);
        if (folderName == '00_NEW_EARTH_OMEGA_MODULE_HUB_UI') {
          continue;
        }

        modules.add(_loadModuleDirectory(parser, moduleDirectory));
      }
    }

    final appliedModules = _applyEnabledOverrides(
      modules,
      enabledOverrides ??
          (stateRepository ?? ModuleHubStateRepository()).loadEnabledStates(),
    );

    final dockLayoutState = (stateRepository ?? ModuleHubStateRepository())
        .loadDockLayoutState();
    final dockAppliedModules = appliedModules
        .map((module) {
          final savedPosition = dockLayoutState.positionFor(module.id);
          if (savedPosition == null) {
            return module;
          }
          return module.copyWith(defaultDockPosition: savedPosition);
        })
        .toList(growable: false);

    return ModuleRegistry(seed: dockAppliedModules);
  }

  ModuleManifest _loadModuleDirectory(
    ModuleManifestParser parser,
    Directory moduleDirectory,
  ) {
    final folderName = _folderName(moduleDirectory.path);
    final manifestFile = _firstExistingFile([
      '${moduleDirectory.path}${Platform.pathSeparator}module_manifest.json',
      '${moduleDirectory.path}${Platform.pathSeparator}MODULE_MANIFEST.json',
    ]);

    if (manifestFile == null) {
      return parser.infer(
        folderName: folderName,
        installPath: moduleDirectory.path,
      );
    }

    try {
      final raw = File(manifestFile).readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return parser.parse(
          decoded,
          installPath: moduleDirectory.path,
          folderName: folderName,
        );
      }
    } catch (_) {
      // Fall through to inferred placeholder data if parsing fails.
    }

    return parser.infer(
      folderName: folderName,
      installPath: moduleDirectory.path,
    );
  }

  String? _firstExistingFile(List<String> paths) {
    for (final path in paths) {
      if (File(path).existsSync()) {
        return path;
      }
    }
    return null;
  }

  String _folderName(String path) {
    return path.split(RegExp(r'[\\/]+')).last;
  }

  ModuleManifest _moduleHubManifest() {
    return const ModuleManifest(
      id: 'module_hub',
      name: 'Module Hub',
      description:
          'System core registry for registering, inspecting, enabling and docking dashboard modules.',
      category: ModuleCategory.systemCore,
      version: '0.1.0',
      status: ModuleStatus.enabled,
      enabled: true,
      dockable: false,
      defaultDockPosition: DockPosition.fullscreen,
      iconKey: 'hub_outlined',
      routes: [RouteNames.moduleHub],
      permissions: [
        ModulePermission(type: ModulePermissionType.fileRead),
        ModulePermission(type: ModulePermissionType.omegaOsAccess),
      ],
      installPath: 'lib/features/modules',
      omegaOsPath: 'docs/architecture/module_hub',
      storagePath: 'lib/features/modules/storage',
      health: ModuleHealthSnapshot(
        state: ModuleHealthState.healthy,
        lastCheckedLabel: 'Placeholder: just now',
        backendStatus: 'UI shell only',
        errors: [],
        warnings: ['No real loader wired yet.'],
        nextAction: 'Connect manifest loading in the next phase.',
      ),
      source: ModuleManifestSource.manifest,
      tags: ['core', 'registry', 'dashboard'],
      notes: 'This module is the hub for the dashboard module shell.',
    );
  }

  List<ModuleManifest> _applyEnabledOverrides(
    List<ModuleManifest> modules,
    Map<String, bool> enabledOverrides,
  ) {
    return modules
        .map(
          (module) => enabledOverrides.containsKey(module.id)
              ? module.copyWith(enabled: enabledOverrides[module.id] ?? false)
              : module,
        )
        .toList(growable: false);
  }
}
