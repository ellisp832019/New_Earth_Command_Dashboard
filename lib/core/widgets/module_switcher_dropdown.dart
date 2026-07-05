import 'package:flutter/material.dart';

import '../modules/module_navigation.dart';
import '../modules/module_category.dart';
import '../modules/module_manifest.dart';

class ModuleSwitcherDropdown extends StatelessWidget {
  const ModuleSwitcherDropdown({
    required this.modules,
    required this.selectedModule,
    required this.onSelected,
    super.key,
    this.launchTargetResolver,
  });

  final List<ModuleManifest> modules;
  final ModuleManifest? selectedModule;
  final ValueChanged<ModuleManifest> onSelected;
  final ModuleLaunchTarget? Function(ModuleManifest module)?
  launchTargetResolver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.72,
    );

    return Container(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ModuleManifest>(
          key: const Key('module-switcher-dropdown'),
          value: selectedModule,
          isExpanded: true,
          itemHeight: 68,
          borderRadius: BorderRadius.circular(20),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          menuMaxHeight: 360,
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
                  child: _ModuleMenuItem(
                    module: module,
                    launchTarget: launchTargetResolver?.call(module),
                  ),
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
          size: 15,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            module.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModuleMenuItem extends StatelessWidget {
  const _ModuleMenuItem({required this.module, this.launchTarget});

  final ModuleManifest module;
  final ModuleLaunchTarget? launchTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = module.enabled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(
              moduleIconFor(module.iconKey, category: module.category),
              size: 15,
            ),
          ),
          const SizedBox(width: 7),
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
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ModuleStatusPill(
                      label: isEnabled ? 'Enabled' : 'Disabled',
                      accentColor: isEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      module.category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                    if (launchTarget != null)
                      _ModuleStatusPill(
                        label: launchTarget!.label,
                        accentColor: theme.colorScheme.tertiary,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  module.routes.isEmpty
                      ? 'No route registered'
                      : launchTarget == ModuleLaunchTarget.home
                          ? module.routes.first
                          : 'Package shell',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
