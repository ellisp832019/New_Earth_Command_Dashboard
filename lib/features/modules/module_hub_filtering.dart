import '../../core/modules/module_category.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_permissions.dart';
import '../../core/modules/module_status.dart';

enum ModuleHubSortMode { alphabetical, enabledFirst, category, status }

List<ModuleManifest> filterAndSortModuleHubModules({
  required Iterable<ModuleManifest> modules,
  String query = '',
  ModuleCategory? categoryFilter,
  ModuleStatus? statusFilter,
  bool? dockableFilter,
  ModulePermissionType? permissionFilter,
  ModuleHubSortMode sortMode = ModuleHubSortMode.alphabetical,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final filtered = modules
      .where((module) {
        final matchesSearch =
            normalizedQuery.isEmpty ||
            module.name.toLowerCase().contains(normalizedQuery) ||
            module.description.toLowerCase().contains(normalizedQuery) ||
            module.installPath.toLowerCase().contains(normalizedQuery) ||
            module.omegaOsPath.toLowerCase().contains(normalizedQuery) ||
            module.storagePath.toLowerCase().contains(normalizedQuery) ||
            module.routes.any(
              (route) => route.toLowerCase().contains(normalizedQuery),
            ) ||
            module.tags.any(
              (tag) => tag.toLowerCase().contains(normalizedQuery),
            ) ||
            module.permissions.any(
              (permission) =>
                  permission.type.label.toLowerCase().contains(
                    normalizedQuery,
                  ) ||
                  permission.type.name.toLowerCase().contains(normalizedQuery),
            );

        final matchesCategory =
            categoryFilter == null || module.category == categoryFilter;
        final matchesStatus =
            statusFilter == null || module.status == statusFilter;
        final matchesDockable =
            dockableFilter == null || module.dockable == dockableFilter;
        final matchesPermission =
            permissionFilter == null ||
            module.permissions.any(
              (permission) => permission.type == permissionFilter,
            );

        return matchesSearch &&
            matchesCategory &&
            matchesStatus &&
            matchesDockable &&
            matchesPermission;
      })
      .toList(growable: false);

  filtered.sort((a, b) => _compareModules(a, b, sortMode));
  return filtered;
}

int _compareModules(
  ModuleManifest a,
  ModuleManifest b,
  ModuleHubSortMode sortMode,
) {
  switch (sortMode) {
    case ModuleHubSortMode.alphabetical:
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case ModuleHubSortMode.enabledFirst:
      if (a.enabled != b.enabled) {
        return a.enabled ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case ModuleHubSortMode.category:
      final categoryComparison = a.category.label.compareTo(b.category.label);
      return categoryComparison != 0
          ? categoryComparison
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case ModuleHubSortMode.status:
      final statusComparison = a.status.label.compareTo(b.status.label);
      return statusComparison != 0
          ? statusComparison
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
