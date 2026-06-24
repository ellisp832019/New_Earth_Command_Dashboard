import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/dock/dock_position.dart';
import '../../core/modules/module_category.dart';
import '../../core/modules/module_event_bus.dart';
import '../../core/modules/module_health.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_permissions.dart';
import '../../core/modules/module_status.dart';
import '../../core/modules/module_types.dart';
import '../../core/routing/route_names.dart';
import 'application/module_hub_controller.dart';
import 'module_card.dart';
import 'module_hub_filtering.dart';
import 'module_dock_preview.dart';

class ModulesScreen extends ConsumerStatefulWidget {
  const ModulesScreen({super.key});

  @override
  ConsumerState<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends ConsumerState<ModulesScreen> {
  late final TextEditingController _searchController;
  late ModuleViewMode _viewMode;
  ModuleCategory? _categoryFilter;
  ModuleStatus? _statusFilter;
  bool? _dockableFilter;
  ModulePermissionType? _permissionFilter;
  late ModuleHubSortMode _sortMode;

  @override
  void initState() {
    super.initState();
    final persistedState = ref
        .read(moduleHubStateRepositoryProvider)
        .loadHubUiState();
    _searchController = TextEditingController(
      text: _stringState(persistedState, 'searchQuery'),
    );
    _viewMode = _parseViewMode(_stringState(persistedState, 'viewMode'));
    _categoryFilter = _parseCategoryFilter(
      _stringState(persistedState, 'categoryFilter'),
    );
    _statusFilter = _parseStatusFilter(
      _stringState(persistedState, 'statusFilter'),
    );
    _dockableFilter = _parseBoolFilter(persistedState['dockableFilter']);
    _permissionFilter = _parsePermissionFilter(
      _stringState(persistedState, 'permissionFilter'),
    );
    _sortMode = _parseSortMode(_stringState(persistedState, 'sortMode'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modules = ref.watch(moduleHubModulesProvider);
    final visibleStatusFilters = ModuleStatus.values
        .where((status) => modules.any((module) => module.status == status))
        .toList(growable: false);
    final effectiveStatusFilter = visibleStatusFilters.contains(_statusFilter)
        ? _statusFilter
        : null;
    final filteredModules = filterAndSortModuleHubModules(
      modules: modules,
      query: _searchController.text,
      categoryFilter: _categoryFilter,
      statusFilter: effectiveStatusFilter,
      dockableFilter: _dockableFilter,
      permissionFilter: _permissionFilter,
      sortMode: _sortMode,
    );
    final enabledCount = filteredModules
        .where((module) => module.enabled)
        .length;
    final errorCount = filteredModules
        .where((module) => module.health.state == ModuleHealthState.error)
        .length;
    final manifestCount = filteredModules
        .where((module) => module.source == ModuleManifestSource.manifest)
        .length;
    final inferredCount = filteredModules.length - manifestCount;
    final recentEvents = ref.watch(moduleRecentEventsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => _goBack(context)),
        title: const Text('Module Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeaderCard(
            subtitle: 'Live local module registry',
            summary:
                'Showing ${filteredModules.length} of ${modules.length} modules',
            enabledCount: enabledCount,
            errorCount: errorCount,
            manifestCount: manifestCount,
            inferredCount: inferredCount,
          ),
          const SizedBox(height: 16),
          _PinnedStartHereCard(
            module: modules
                .where((module) => module.id == '01_USERS_AND_DEVICES_CONTROL')
                .cast<ModuleManifest?>()
                .firstOrNull,
          ),
          const SizedBox(height: 16),
          _PinnedKnowledgeEngineCard(
            module: modules
                .where((module) => module.id == '26_OMEGA_KNOWLEDGE_ENGINE')
                .cast<ModuleManifest?>()
                .firstOrNull,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assistant dock preview',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ModuleDockPreview(
                    module: _assistantDockPreview(),
                    initialPosition: DockPosition.right,
                    showAssistantDockPlaceholder: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityCard(theme, recentEvents),
          const SizedBox(height: 16),
          _buildSearchAndViewControls(theme),
          const SizedBox(height: 12),
          _buildFilterChips(
            theme,
            visibleStatusFilters: visibleStatusFilters,
            effectiveStatusFilter: effectiveStatusFilter,
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(filteredModules),
          const SizedBox(height: 16),
          _buildModuleGridOrList(filteredModules),
        ],
      ),
    );
  }

  Widget _buildSearchAndViewControls(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search modules',
                      hintText: 'Name, tag, permission, or folder',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                                _saveUiState();
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                      _saveUiState();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                _buildSortMenu(),
                const SizedBox(width: 10),
                ToggleButtons(
                  isSelected: [
                    _viewMode == ModuleViewMode.grid,
                    _viewMode == ModuleViewMode.list,
                  ],
                  onPressed: (index) {
                    setState(() {
                      _viewMode = index == 0
                          ? ModuleViewMode.grid
                          : ModuleViewMode.list;
                    });
                    _saveUiState();
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.grid_view_outlined),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.view_agenda_outlined),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Use search, filters, and sort to narrow the registry to what matters now.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    ThemeData theme, {
    required List<ModuleStatus> visibleStatusFilters,
    required ModuleStatus? effectiveStatusFilter,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Dockability', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _HubFilterChip(
                  label: const Text('All'),
                  selected: _dockableFilter == null,
                  onSelected: (_) {
                    setState(() => _dockableFilter = null);
                    _saveUiState();
                  },
                ),
                _HubFilterChip(
                  label: const Text('Dockable'),
                  selected: _dockableFilter == true,
                  onSelected: (_) {
                    setState(() => _dockableFilter = true);
                    _saveUiState();
                  },
                ),
                _HubFilterChip(
                  label: const Text('Fixed'),
                  selected: _dockableFilter == false,
                  onSelected: (_) {
                    setState(() => _dockableFilter = false);
                    _saveUiState();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Category', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _HubFilterChip(
                  label: const Text('All'),
                  selected: _categoryFilter == null,
                  onSelected: (_) {
                    setState(() => _categoryFilter = null);
                    _saveUiState();
                  },
                ),
                ...ModuleCategory.values.map(
                  (category) => _HubFilterChip(
                    label: Text(category.label),
                    selected: _categoryFilter == category,
                    onSelected: (_) {
                      setState(() => _categoryFilter = category);
                      _saveUiState();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Status', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _HubFilterChip(
                  label: const Text('All'),
                  selected: _statusFilter == null,
                  onSelected: (_) {
                    setState(() => _statusFilter = null);
                    _saveUiState();
                  },
                ),
                ...visibleStatusFilters.map(
                  (status) => _HubFilterChip(
                    label: Text(status.label),
                    selected: effectiveStatusFilter == status,
                    onSelected: (_) {
                      setState(() => _statusFilter = status);
                      _saveUiState();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Permissions', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _HubFilterChip(
                  label: const Text('All'),
                  selected: _permissionFilter == null,
                  onSelected: (_) {
                    setState(() => _permissionFilter = null);
                    _saveUiState();
                  },
                ),
                ...ModulePermissionType.values.map(
                  (permissionType) => _HubFilterChip(
                    label: Text(permissionType.label),
                    selected: _permissionFilter == permissionType,
                    onSelected: (_) {
                      setState(() => _permissionFilter = permissionType);
                      _saveUiState();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Clear filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(List<ModuleManifest> modules) {
    final installedCount = modules
        .where((module) => module.status == ModuleStatus.installed)
        .length;
    final experimentalCount = modules
        .where((module) => module.status == ModuleStatus.experimental)
        .length;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SummaryCard(label: 'Modules', value: '${modules.length}'),
        _SummaryCard(
          label: 'Enabled',
          value: '${modules.where((module) => module.enabled).length}',
        ),
        _SummaryCard(label: 'Installed', value: '$installedCount'),
        _SummaryCard(label: 'Experimental', value: '$experimentalCount'),
      ],
    );
  }

  Widget _buildActivityCard(ThemeData theme, List<ModuleEvent> recentEvents) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live activity', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              recentEvents.isEmpty
                  ? 'No module events yet. Enable a module or change a dock position to see the live feed.'
                  : 'Recent module events are shown here as they happen.',
              style: theme.textTheme.bodySmall,
            ),
            if (recentEvents.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                children: [
                  for (final event in recentEvents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ActivityRow(event: event),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGridOrList(List<ModuleManifest> modules) {
    if (modules.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No modules match these filters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try a broader search or clear one of the filters to bring the module back.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    if (_viewMode == ModuleViewMode.list) {
      return Column(
        children: [
          for (final module in modules) ...[
            ModuleCard(
              module: module,
              onEnabledChanged: (value) {
                ref
                    .read(moduleHubModulesProvider.notifier)
                    .setModuleEnabled(module.id, value);
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1300
            ? 3
            : constraints.maxWidth >= 900
            ? 2
            : 1;
        return GridView.builder(
          itemCount: modules.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 340,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];
            return ModuleCard(
              module: module,
              onEnabledChanged: (value) {
                ref
                    .read(moduleHubModulesProvider.notifier)
                    .setModuleEnabled(module.id, value);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSortMenu() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<ModuleHubSortMode>(
        value: _sortMode,
        borderRadius: BorderRadius.circular(16),
        items: const [
          DropdownMenuItem(
            value: ModuleHubSortMode.alphabetical,
            child: Text('A-Z'),
          ),
          DropdownMenuItem(
            value: ModuleHubSortMode.enabledFirst,
            child: Text('Enabled first'),
          ),
          DropdownMenuItem(
            value: ModuleHubSortMode.category,
            child: Text('Category'),
          ),
          DropdownMenuItem(
            value: ModuleHubSortMode.status,
            child: Text('Status'),
          ),
        ],
        onChanged: (value) {
          if (value == null) {
            return;
          }
          setState(() => _sortMode = value);
          _saveUiState();
        },
        icon: const Icon(Icons.sort),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _categoryFilter = null;
      _statusFilter = null;
      _dockableFilter = null;
      _permissionFilter = null;
      _sortMode = ModuleHubSortMode.alphabetical;
    });
    _saveUiState();
  }

  void _saveUiState() {
    unawaited(
      ref
          .read(moduleHubStateRepositoryProvider)
          .saveHubUiState(<String, dynamic>{
            'searchQuery': _searchController.text,
            'viewMode': _viewMode.name,
            'categoryFilter': _categoryFilter?.name,
            'statusFilter': _statusFilter?.name,
            'dockableFilter': _dockableFilter,
            'permissionFilter': _permissionFilter?.name,
            'sortMode': _sortMode.name,
          }),
    );
  }

  String _stringState(Map<String, dynamic> state, String key) {
    final value = state[key];
    return value?.toString() ?? '';
  }

  ModuleViewMode _parseViewMode(String value) {
    switch (value) {
      case 'list':
        return ModuleViewMode.list;
      case 'grid':
      default:
        return ModuleViewMode.grid;
    }
  }

  ModuleCategory? _parseCategoryFilter(String value) {
    for (final category in ModuleCategory.values) {
      if (category.name == value) {
        return category;
      }
    }
    return null;
  }

  ModuleStatus? _parseStatusFilter(String value) {
    for (final status in ModuleStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    return null;
  }

  bool? _parseBoolFilter(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
    return null;
  }

  ModulePermissionType? _parsePermissionFilter(String value) {
    for (final permissionType in ModulePermissionType.values) {
      if (permissionType.name == value) {
        return permissionType;
      }
    }
    return null;
  }

  ModuleHubSortMode _parseSortMode(String value) {
    for (final sortMode in ModuleHubSortMode.values) {
      if (sortMode.name == value) {
        return sortMode;
      }
    }
    return ModuleHubSortMode.alphabetical;
  }

  ModuleManifest _assistantDockPreview() {
    return const ModuleManifest(
      id: 'assistant_dock_preview',
      name: 'AI Assistant Dock',
      description:
          'Local fallback dock for wake-triggered voice replies, quick follow-up chips and conversational handoff.',
      category: ModuleCategory.aiAutomation,
      version: '0.1.0',
      status: ModuleStatus.experimental,
      enabled: false,
      dockable: true,
      defaultDockPosition: DockPosition.right,
      permissions: [
        ModulePermission(type: ModulePermissionType.microphone),
        ModulePermission(type: ModulePermissionType.speaker),
        ModulePermission(type: ModulePermissionType.screenCapture),
        ModulePermission(type: ModulePermissionType.localNetwork),
      ],
      installPath: 'modules/assistant_dock_preview',
      omegaOsPath: 'OMEGA_OS/MODULES/AI_ASSISTANT_DOCK',
      health: ModuleHealthSnapshot(
        state: ModuleHealthState.offline,
        lastCheckedLabel: 'Placeholder: not running',
        backendStatus: 'Offline fallback',
        errors: [],
        warnings: ['Route handoff not connected yet.'],
        nextAction: 'Wake listener can reopen the full assistant later.',
      ),
      tags: ['assistant', 'dock', 'voice'],
      notes:
          'Synthetic preview used to satisfy the dock placeholder requirement.',
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.dashboard);
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}

class _PinnedStartHereCard extends StatelessWidget {
  const _PinnedStartHereCard({required this.module});

  final ModuleManifest? module;

  @override
  Widget build(BuildContext context) {
    if (module == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                moduleIconFor(module!.iconKey, category: module!.category),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: const [
                      Chip(label: Text('Start here')),
                      Chip(label: Text('Sensitive module')),
                      Chip(label: Text('Local access gate')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(module!.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'This is the easiest launch point for identity, device trust, approvals, and audit.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(module!.description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => context.push(
                          RouteNames.moduleHubModule(module!.id),
                        ),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open module home'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => context.go(RouteNames.usersDevices),
                        icon: const Icon(Icons.shield_outlined),
                        label: const Text('Open access gate'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push(RouteNames.usersDevicesUsers),
                        icon: const Icon(Icons.people_outline),
                        label: const Text('Open Users'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push(RouteNames.usersDevicesDevices),
                        icon: const Icon(Icons.devices_outlined),
                        label: const Text('Open Devices'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedKnowledgeEngineCard extends StatelessWidget {
  const _PinnedKnowledgeEngineCard({required this.module});

  final ModuleManifest? module;

  @override
  Widget build(BuildContext context) {
    if (module == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.secondary.withValues(alpha: 0.1),
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                moduleIconFor(module!.iconKey, category: module!.category),
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: const [
                      Chip(label: Text('Featured module')),
                      Chip(label: Text('Scan/report only')),
                      Chip(label: Text('Knowledge engine')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(module!.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Use this when you want a local scan, architecture map, learning notes, or export preview for any repo.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(module!.description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => context.push(
                          RouteNames.omegaKnowledgeEngine,
                        ),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open module home'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '${RouteNames.omegaKnowledgeEngine}?tab=scan-results',
                        ),
                        icon: const Icon(Icons.table_view_outlined),
                        label: const Text('Open outputs'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '${RouteNames.omegaKnowledgeEngine}?tab=settings',
                        ),
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Open settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.subtitle,
    required this.summary,
    required this.enabledCount,
    required this.errorCount,
    required this.manifestCount,
    required this.inferredCount,
  });

  final String subtitle;
  final String summary;
  final int enabledCount;
  final int errorCount;
  final int manifestCount;
  final int inferredCount;

  @override
  Widget build(BuildContext context) {
    return _HubPanel(
      icon: Icons.grid_view_outlined,
      title: 'More - Module Hub',
      subtitle: subtitle,
      body: summary,
      footer:
          'Folder-only entries are shown as Scaffold until they gain a root manifest.',
      action: Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(RouteNames.dashboard);
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
        ),
      ),
      metrics: [
        _SummaryCard(label: 'Enabled', value: '$enabledCount'),
        _SummaryCard(label: 'Errors', value: '$errorCount'),
        _SummaryCard(label: 'Manifest', value: '$manifestCount'),
        _SummaryCard(label: 'Inferred', value: '$inferredCount'),
        const _SummaryCard(label: 'Mode', value: 'Live local'),
        const _SummaryCard(label: 'Path', value: 'Folder-backed'),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.event});

  final ModuleEvent event;

  @override
  Widget build(BuildContext context) {
    return _HubPanel(
      icon: switch (event.type) {
        ModuleEventType.enabledChanged => Icons.toggle_on,
        ModuleEventType.dockPositionChanged => Icons.view_sidebar,
        ModuleEventType.registryReloaded => Icons.refresh,
      },
      title: event.type.label,
      subtitle: event.message.isEmpty ? event.moduleId : event.message,
      body: event.timestamp.toLocal().toIso8601String(),
      compact: true,
      metrics: [_SummaryCard(label: 'Module', value: event.moduleId)],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _HubPanel extends StatelessWidget {
  const _HubPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.metrics,
    this.footer,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String body;
  final List<Widget> metrics;
  final String? footer;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 38 : 46,
                    height: compact ? 38 : 46,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: compact ? 20 : 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(subtitle, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(body, style: theme.textTheme.bodyMedium),
              if (footer != null) ...[
                const SizedBox(height: 6),
                Text(footer!, style: theme.textTheme.bodySmall),
              ],
              if (action != null) ...[const SizedBox(height: 12), action!],
              const SizedBox(height: 14),
              Wrap(spacing: 10, runSpacing: 10, children: metrics),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubFilterChip extends StatelessWidget {
  const _HubFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: selected
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
      side: BorderSide(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.72)
            : theme.colorScheme.outlineVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
