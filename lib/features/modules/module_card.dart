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
    final isSensitiveModule = _isSensitiveModule(module.id);
    final isKnowledgeEngineModule = _isKnowledgeEngineModule(module.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () => context.push(RouteNames.moduleHubModule(module.id)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.48,
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        moduleIconFor(
                          module.iconKey,
                          category: module.category,
                        ),
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(module.name, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 2),
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
                        _StatusBadge(
                          label: module.status.label,
                          color: statusColor,
                        ),
                        const SizedBox(height: 4),
                        _SourceBadge(module: module),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  module.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
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
                    if (isKnowledgeEngineModule)
                      const _CompactChip(
                        label: 'Scan/report only',
                        icon: Icons.auto_awesome_mosaic_outlined,
                      ),
                    if (isSensitiveModule)
                      const _CompactChip(
                        label: 'Access gate',
                        icon: Icons.lock_outline,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local toggle',
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Saved locally',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: module.enabled,
                      onChanged: onEnabledChanged,
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () =>
                          context.push(RouteNames.moduleHubModule(module.id)),
                      child: const Text('Inspect'),
                    ),
                  ],
                ),
                if (isKnowledgeEngineModule) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push(
                        '${RouteNames.omegaKnowledgeEngine}?tab=scan-results',
                      ),
                      icon: const Icon(Icons.table_view_outlined),
                      label: const Text('Open outputs'),
                    ),
                  ),
                ],
                if (isSensitiveModule && module.routes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.go(module.routes.first),
                      icon: const Icon(Icons.lock_open_outlined),
                      label: const Text('Open gate'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _isSensitiveModule(String moduleId) {
  switch (moduleId) {
    case '01_USERS_AND_DEVICES_CONTROL':
    case 'newearth.finance_treasury':
    case 'repo_research_engine':
    case 'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE':
    case 'gaia_voice_assistant':
      return true;
    default:
      return false;
  }
}

bool _isKnowledgeEngineModule(String moduleId) {
  return moduleId == '26_OMEGA_KNOWLEDGE_ENGINE';
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
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
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(icon, size: 15),
      label: Text(label),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
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
