import 'package:flutter/material.dart';

import '../modules/module_category.dart';
import '../modules/module_manifest.dart';

class ModuleSwitcherDropdown extends StatelessWidget {
  const ModuleSwitcherDropdown({
    required this.modules,
    required this.selectedModule,
    required this.onSelected,
    super.key,
  });

  final List<ModuleManifest> modules;
  final ModuleManifest? selectedModule;
  final ValueChanged<ModuleManifest> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.72,
    );

    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 420),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ModuleManifest>(
          key: const Key('module-switcher-dropdown'),
          value: selectedModule,
          isExpanded: true,
          itemHeight: 72,
          borderRadius: BorderRadius.circular(20),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          menuMaxHeight: 420,
          dropdownColor: theme.colorScheme.surface,
          hint: Text(
            'Select module',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          selectedItemBuilder: (context) {
            return modules
                .map((module) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: _SelectedModuleLabel(module: module),
                  );
                })
                .toList(growable: false);
          },
          items: modules
              .map(
                (module) => DropdownMenuItem<ModuleManifest>(
                  value: module,
                  child: _ModuleMenuItem(module: module),
                ),
              )
              .toList(growable: false),
          onChanged: (module) {
            if (module == null) {
              return;
            }
            onSelected(module);
          },
        ),
      ),
    );
  }
}

class _SelectedModuleLabel extends StatelessWidget {
  const _SelectedModuleLabel({required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(
          moduleIconFor(module.iconKey, category: module.category),
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            module.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModuleMenuItem extends StatelessWidget {
  const _ModuleMenuItem({required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = module.enabled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              moduleIconFor(module.iconKey, category: module.category),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        module.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ModuleStatusPill(
                      label: isEnabled ? 'Enabled' : 'Disabled',
                      accentColor: isEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  module.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  module.routes.isEmpty
                      ? 'No route registered'
                      : module.routes.first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleStatusPill extends StatelessWidget {
  const _ModuleStatusPill({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
