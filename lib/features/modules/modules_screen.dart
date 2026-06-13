import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dock/dock_position.dart';
import '../../core/modules/module_category.dart';
import '../../core/modules/module_health.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_permissions.dart';
import '../../core/modules/module_status.dart';
import '../../core/modules/module_types.dart';
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
  final _searchController = TextEditingController();
  ModuleViewMode _viewMode = ModuleViewMode.grid;
  ModuleCategory? _categoryFilter;
  ModuleStatus? _statusFilter;
  bool? _dockableFilter;
  ModulePermissionType? _permissionFilter;
  ModuleHubSortMode _sortMode = ModuleHubSortMode.alphabetical;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modules = ref.watch(moduleHubModulesProvider);
    final filteredModules = filterAndSortModuleHubModules(
      modules: modules,
      query: _searchController.text,
      categoryFilter: _categoryFilter,
      statusFilter: _statusFilter,
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

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeaderCard(
            title: 'Module Hub',
            subtitle:
                'Install, enable, inspect and manage New Earth Dashboard modules',
            summary:
                'Showing ${filteredModules.length} of ${modules.length} modules',
            enabledCount: enabledCount,
            errorCount: errorCount,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Assistant Dock Preview',
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
          _buildSearchAndViewControls(theme),
          const SizedBox(height: 12),
          _buildFilterChips(theme),
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
        padding: const EdgeInsets.all(16),
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
                      hintText: 'Name, description, tag, permission or folder',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                _buildSortMenu(),
                const SizedBox(width: 12),
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
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.grid_view_outlined),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.view_agenda_outlined),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Use search, filters, and sort to narrow the registry to what matters now.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Dockability', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _dockableFilter == null,
                  onSelected: (_) => setState(() => _dockableFilter = null),
                ),
                ChoiceChip(
                  label: const Text('Dockable'),
                  selected: _dockableFilter == true,
                  onSelected: (_) => setState(() => _dockableFilter = true),
                ),
                ChoiceChip(
                  label: const Text('Fixed'),
                  selected: _dockableFilter == false,
                  onSelected: (_) => setState(() => _dockableFilter = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Category', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _categoryFilter == null,
                  onSelected: (_) => setState(() => _categoryFilter = null),
                ),
                ...ModuleCategory.values.map(
                  (category) => ChoiceChip(
                    label: Text(category.label),
                    selected: _categoryFilter == category,
                    onSelected: (_) {
                      setState(() => _categoryFilter = category);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Status', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                ),
                ...ModuleStatus.values.map(
                  (status) => ChoiceChip(
                    label: Text(status.label),
                    selected: _statusFilter == status,
                    onSelected: (_) {
                      setState(() => _statusFilter = status);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Permissions', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _permissionFilter == null,
                  onSelected: (_) => setState(() => _permissionFilter = null),
                ),
                ...ModulePermissionType.values.map(
                  (permissionType) => ChoiceChip(
                    label: Text(permissionType.label),
                    selected: _permissionFilter == permissionType,
                    onSelected: (_) {
                      setState(() => _permissionFilter = permissionType);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
      spacing: 12,
      runSpacing: 12,
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
            mainAxisExtent: 320,
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
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.enabledCount,
    required this.errorCount,
  });

  final String title;
  final String subtitle;
  final String summary;
  final int enabledCount;
  final int errorCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(label: 'Enabled', value: '$enabledCount'),
                _SummaryCard(label: 'Errors', value: '$errorCount'),
                const _SummaryCard(label: 'Mode', value: 'Mock registry'),
                const _SummaryCard(label: 'Path', value: 'Local only'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
