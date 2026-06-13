import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/module_category.dart';
import '../../core/modules/module_health.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_status.dart';
import '../../core/routing/route_names.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.onEnabledChanged,
  });

  final ModuleManifest module;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(theme, module.status);
    final borderColor = statusColor.withValues(alpha: 0.42);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () => context.push(RouteNames.moduleHubModule(module.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(module.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          module.category.label,
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusBadge(label: module.status.label, color: statusColor),
                      const SizedBox(height: 8),
                      _SourceBadge(module: module),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                module.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CompactChip(
                    label: module.enabled ? 'Enabled' : 'Disabled',
                    icon: module.enabled ? Icons.toggle_on : Icons.toggle_off,
                  ),
                  _CompactChip(
                    label: module.health.state.label,
                    icon: Icons.health_and_safety_outlined,
                  ),
                  if (module.dockable)
                    const _CompactChip(
                      label: 'Dockable',
                      icon: Icons.view_sidebar_outlined,
                    ),
                  _CompactChip(
                    label: '${module.permissions.length} permissions',
                    icon: Icons.verified_user_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: module.enabled,
                      onChanged: onEnabledChanged,
                      title: const Text('Local toggle'),
                      subtitle: const Text('Saved locally'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: () =>
                        context.push(RouteNames.moduleHubModule(module.id)),
                    child: const Text('Inspect'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(ThemeData theme, ModuleStatus status) {
  switch (status) {
    case ModuleStatus.enabled:
      return theme.colorScheme.primary;
    case ModuleStatus.installed:
      return theme.colorScheme.tertiary;
    case ModuleStatus.disabled:
      return theme.colorScheme.outline;
    case ModuleStatus.needsConfiguration:
      return theme.colorScheme.secondary;
    case ModuleStatus.error:
      return theme.colorScheme.error;
    case ModuleStatus.scaffold:
      return theme.colorScheme.surfaceTint;
    case ModuleStatus.planned:
      return theme.colorScheme.secondary;
    case ModuleStatus.experimental:
      return theme.colorScheme.primaryContainer;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final isManifest = module.source == ModuleManifestSource.manifest;
    final color = isManifest
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        module.source.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
