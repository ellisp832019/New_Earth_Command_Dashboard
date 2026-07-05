import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/modules/module_manifest.dart';
import '../../../core/modules/module_navigation.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/module_switcher_dropdown.dart';
import '../../../core/widgets/workspace_frame.dart';
import '../application/module_hub_controller.dart';

class ModuleWorkspaceShell extends ConsumerWidget {
  const ModuleWorkspaceShell({
    required this.module,
    required this.modules,
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.trailingActions = const <Widget>[],
  });

  final ModuleManifest module;
  final List<ModuleManifest> modules;
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> trailingActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleOptions = <ModuleManifest>[];
    final seenModuleIds = <String>{};
    for (final candidate in modules) {
      if (seenModuleIds.add(candidate.id)) {
        moduleOptions.add(candidate);
      }
    }
    if (moduleOptions.isEmpty) {
      moduleOptions.add(module);
    }
    final selectedModule = moduleOptions.firstWhere(
      (candidate) => candidate.id == module.id,
      orElse: () => moduleOptions.first,
    );

    return WorkspaceFrame(
      header: _ModuleWorkspaceHeader(
        module: module,
        modules: moduleOptions,
        selectedModule: selectedModule,
        title: title,
        subtitle: subtitle,
        trailingActions: trailingActions,
        launchTargetResolver: (module) => ref
            .read(moduleHubStateRepositoryProvider)
            .loadLaunchTarget(module.id),
        onModuleSelected: (selectedModule) {
          final target = ref
              .read(moduleHubStateRepositoryProvider)
              .loadLaunchTarget(selectedModule.id);
          context.go(moduleLaunchRoute(selectedModule, target));
        },
      ),
      child: child,
    );
  }
}

class _ModuleWorkspaceHeader extends StatelessWidget {
  const _ModuleWorkspaceHeader({
    required this.module,
    required this.modules,
    required this.selectedModule,
    required this.title,
    required this.subtitle,
    required this.trailingActions,
    required this.launchTargetResolver,
    required this.onModuleSelected,
  });

  final ModuleManifest module;
  final List<ModuleManifest> modules;
  final ModuleManifest selectedModule;
  final String title;
  final String subtitle;
  final List<Widget> trailingActions;
  final ModuleLaunchTarget? Function(ModuleManifest module)
  launchTargetResolver;
  final ValueChanged<ModuleManifest> onModuleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectorWidth = modules.length > 1 ? 270.0 : 220.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColours.darkBackground.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColours.darkOutline.withValues(alpha: 0.9),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;

          final titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    tooltip: 'Back to Module Hub',
                    onPressed: () => context.go(RouteNames.moduleHub),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ),
            ],
          );

          final selector = SizedBox(
            width: selectorWidth,
            child: ModuleSwitcherDropdown(
              modules: modules,
              selectedModule: selectedModule,
              onSelected: onModuleSelected,
              launchTargetResolver: launchTargetResolver,
            ),
          );

          final launchToggle = _ModuleLaunchTargetToggle(module: module);

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleBlock,
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    selector,
                    launchToggle,
                  ],
                ),
                if (trailingActions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: trailingActions,
                  ),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 16),
              selector,
              const SizedBox(width: 12),
              launchToggle,
              if (trailingActions.isNotEmpty) ...[
                const SizedBox(width: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: trailingActions,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ModuleLaunchTargetToggle extends ConsumerStatefulWidget {
  const _ModuleLaunchTargetToggle({required this.module});

  final ModuleManifest module;

  @override
  ConsumerState<_ModuleLaunchTargetToggle> createState() =>
      _ModuleLaunchTargetToggleState();
}

class _ModuleLaunchTargetToggleState
    extends ConsumerState<_ModuleLaunchTargetToggle> {
  late ModuleLaunchTarget _target;

  @override
  void initState() {
    super.initState();
    _target = ref
        .read(moduleHubStateRepositoryProvider)
        .loadLaunchTarget(widget.module.id);
  }

  @override
  Widget build(BuildContext context) {
    final hasHomeRoute = moduleHomeRoute(widget.module) != null;
    if (!hasHomeRoute) {
      return Tooltip(
        message: 'This module opens directly from its package route.',
        child: Text(
          'Package only',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColours.darkMutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SegmentedButton<ModuleLaunchTarget>(
      segments: ModuleLaunchTarget.values
          .map(
            (target) => ButtonSegment<ModuleLaunchTarget>(
              value: target,
              label: Text(target.label),
              icon: Icon(
                target == ModuleLaunchTarget.home
                    ? Icons.home_outlined
                    : Icons.widgets_outlined,
              ),
            ),
          )
          .toList(growable: false),
      selected: <ModuleLaunchTarget>{_target},
      onSelectionChanged: (selection) async {
        if (selection.isEmpty) {
          return;
        }

        final nextTarget = selection.first;
        setState(() {
          _target = nextTarget;
        });
        await ref
            .read(moduleHubStateRepositoryProvider)
            .saveLaunchTarget(widget.module.id, nextTarget);
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
