import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dock/dock_position.dart';
import '../../core/modules/module_category.dart';
import '../../core/modules/module_health.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_navigation.dart';
import '../../core/modules/module_status.dart';
import '../../core/routing/route_names.dart';
import '../../core/widgets/module_switcher_dropdown.dart';
import 'application/module_hub_controller.dart';

class ModulePackageScreen extends ConsumerWidget {
  const ModulePackageScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(moduleHubModulesProvider);
    final module = modules
        .where((item) => item.id == moduleId)
        .cast<ModuleManifest?>()
        .firstOrNull;

    if (module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Module package')),
        body: Center(
          child: Text(
            'Module "$moduleId" was not found in the local registry.',
          ),
        ),
      );
    }

    final selectedSection = _selectedSectionFor(
      module,
      GoRouterState.of(context).uri.path,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1200;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PackageHeader(module: module, modules: modules),
                    Expanded(
                      child: isWide
                          ? Row(
                              children: [
                                _PackageRail(
                                  module: module,
                                  selectedSection: selectedSection,
                                  onSectionSelected: (route) {
                                    context.go(route);
                                  },
                                ),
                                const VerticalDivider(width: 1),
                                Expanded(
                                  child: _PackageBody(
                                    module: module,
                                    selectedSection: selectedSection,
                                    onSectionSelected: (route) {
                                      context.go(route);
                                    },
                                  ),
                                ),
                                const VerticalDivider(width: 1),
                                SizedBox(
                                  width: 360,
                                  child: _PackageInsights(module: module),
                                ),
                              ],
                            )
                          : ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _PackageBody(
                                  module: module,
                                  selectedSection: selectedSection,
                                  onSectionSelected: (route) {
                                    context.go(route);
                                  },
                                ),
                                const SizedBox(height: 16),
                                _PackageInsights(module: module),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PackageHeader extends StatelessWidget {
  const _PackageHeader({required this.module, required this.modules});

  final ModuleManifest module;
  final List<ModuleManifest> modules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.32,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.folder_open_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.name,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  module.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 320,
            child: ModuleSwitcherDropdown(
              modules: modules,
              selectedModule: module,
              onSelected: (selectedModule) {
                final route = RouteNames.modulePackage(selectedModule.id);
                if (route.isNotEmpty) {
                  context.go(route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageRail extends StatelessWidget {
  const _PackageRail({
    required this.module,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  final ModuleManifest module;
  final String selectedSection;
  final ValueChanged<String> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routes = _packageRoutes(module);

    return SizedBox(
      width: 240,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Sections', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final route in routes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SectionTile(
                label: _sectionLabel(route),
                selected: route == selectedSection,
                onTap: () => onSectionSelected(route),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () {
              final route = moduleHomeRoute(module);
              if (route != null) {
                context.go(route);
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open module home'),
          ),
        ],
      ),
    );
  }
}

class _PackageBody extends StatelessWidget {
  const _PackageBody({
    required this.module,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  final ModuleManifest module;
  final String selectedSection;
  final ValueChanged<String> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routes = _packageRoutes(module);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              title: 'Routes',
              value: '${routes.length}',
              subtitle: 'Package sections',
              icon: Icons.route_outlined,
            ),
            _MetricCard(
              title: 'Status',
              value: module.status.label,
              subtitle: module.enabled ? 'Enabled locally' : 'Disabled locally',
              icon: Icons.health_and_safety_outlined,
            ),
            _MetricCard(
              title: 'Dockable',
              value: module.dockable ? 'Yes' : 'No',
              subtitle: module.defaultDockPosition.label,
              icon: Icons.view_sidebar_outlined,
            ),
            _MetricCard(
              title: 'Permissions',
              value: '${module.permissions.length}',
              subtitle: 'Local controls',
              icon: Icons.verified_user_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Package overview', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'This module opens as its own package shell so it keeps the same calm frame as the main dashboard while still carrying module-specific sections and actions.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(module.category.label)),
                    Chip(label: Text(module.source.label)),
                    Chip(label: Text(module.status.label)),
                    Chip(
                      label: Text('Section: ${_sectionLabel(selectedSection)}'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        final route = moduleHomeRoute(module);
                        if (route != null) {
                          context.go(route);
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open module home'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        if (routes.isNotEmpty) {
                          onSectionSelected(routes.first);
                        }
                      },
                      icon: const Icon(Icons.dashboard_outlined),
                      label: const Text('Open overview'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Section launcher', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final route in routes)
                      ActionChip(
                        label: Text(_sectionLabel(route)),
                        onPressed: () => onSectionSelected(route),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PackageInsights extends StatelessWidget {
  const _PackageInsights({required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Insights', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                Text(module.health.state.label),
                const SizedBox(height: 8),
                Text(module.health.backendStatus),
                const SizedBox(height: 8),
                Text(
                  module.health.nextAction,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notes', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                Text(
                  module.notes.isEmpty ? 'No notes recorded.' : module.notes,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 10),
              Text(title, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      selected: selected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
          : null,
      onTap: onTap,
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

String _sectionLabel(String route) {
  final segment = route.split('/').last;
  if (segment.isEmpty) {
    return 'Overview';
  }

  return segment
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

List<String> _packageRoutes(dynamic module) {
  final routes = <String>[];
  for (final route in module.routes.cast<String>()) {
    final trimmed = route.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    if (trimmed == module.routes.first) {
      routes.add(trimmed);
      continue;
    }
    routes.add(trimmed);
  }
  return routes;
}

String _selectedSectionFor(ModuleManifest module, String currentPath) {
  final packageRoutes = _packageRoutes(module);
  for (final route in packageRoutes) {
    if (currentPath == route || currentPath.startsWith('$route/')) {
      return route;
    }
  }
  return packageRoutes.isEmpty ? module.routes.first : packageRoutes.first;
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
