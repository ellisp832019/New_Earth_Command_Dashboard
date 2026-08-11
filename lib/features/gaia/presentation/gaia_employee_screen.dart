import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaia_dashboard_module/gaia_dashboard_module.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/gaia_employee_providers.dart';

class GaiaEmployeeScreen extends ConsumerWidget {
  const GaiaEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(gaiaEmployeeFeatureEnabledProvider);
    final controller = ref.watch(gaiaEmployeeControllerProvider);
    final backendUri = ref.watch(gaiaEmployeeBackendUriProvider);

    return WorkspaceShell(
      title: 'GAIA AI Employee',
      subtitle:
          'Read-only embedded operations and programme intelligence workspace',
      onBack: () => context.go(RouteNames.more),
      child: enabled && controller != null
          ? GaiaEmployeeWorkspace(
              controller: controller,
              backendUri: backendUri,
              onOpenControlCentre: () =>
                  _showControlCentreInstructions(context),
            )
          : _DisabledGaiaSurface(
              backendUri: backendUri,
              onOpenSettings: () => context.push(RouteNames.settings),
            ),
    );
  }
}

class GaiaEmployeeWorkspace extends StatelessWidget {
  const GaiaEmployeeWorkspace({
    super.key,
    required this.controller,
    required this.backendUri,
    required this.onOpenControlCentre,
  });

  final GaiaDashboardController controller;
  final Uri backendUri;
  final VoidCallback onOpenControlCentre;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final initialTabIndex = constraints.maxHeight < 800 ? 1 : 0;
        return _GaiaEmployeeWorkspaceScaffold(
          controller: controller,
          backendUri: backendUri,
          onOpenControlCentre: onOpenControlCentre,
          initialTabIndex: initialTabIndex,
        );
      },
    );
  }
}

class _GaiaEmployeeWorkspaceScaffold extends StatefulWidget {
  const _GaiaEmployeeWorkspaceScaffold({
    required this.controller,
    required this.backendUri,
    required this.onOpenControlCentre,
    required this.initialTabIndex,
  });

  final GaiaDashboardController controller;
  final Uri backendUri;
  final VoidCallback onOpenControlCentre;
  final int initialTabIndex;

  @override
  State<_GaiaEmployeeWorkspaceScaffold> createState() =>
      _GaiaEmployeeWorkspaceScaffoldState();
}

class _GaiaEmployeeWorkspaceScaffoldState
    extends State<_GaiaEmployeeWorkspaceScaffold>
    with SingleTickerProviderStateMixin {
  static const _tabs = <Tab>[
    Tab(text: 'Operations', icon: Icon(Icons.dashboard_outlined)),
    Tab(
      text: 'Programme intelligence',
      icon: Icon(Icons.account_tree_outlined),
    ),
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void didUpdateWidget(covariant _GaiaEmployeeWorkspaceScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex &&
        _tabController.index != widget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = math.max(220.0, constraints.maxHeight - 520.0);
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReadOnlyHeader(
                    backendUri: widget.backendUri,
                    controller: controller,
                    onOpenControlCentre: widget.onOpenControlCentre,
                    onRefresh: () => unawaited(controller.refresh()),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: contentHeight,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              tabs: _tabs,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  GaiaDashboardView(controller: controller),
                                  GaiaProgrammeSummaryView(
                                    controller: controller,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ReadOnlyHeader extends StatelessWidget {
  const _ReadOnlyHeader({
    required this.backendUri,
    required this.controller,
    required this.onOpenControlCentre,
    required this.onRefresh,
  });

  final Uri backendUri;
  final GaiaDashboardController controller;
  final VoidCallback onOpenControlCentre;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastRefresh = controller.lastRefreshAttemptAt;
    final refreshLabel = lastRefresh == null
        ? 'Never refreshed'
        : 'Refreshed ${_formatTimestamp(lastRefresh)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GAIA integration surface',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'This Dashboard surface is read-only. Execution, rollback, retention cleanup, signing-key management, and repository mutation stay in the standalone GAIA Control Centre.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GaiaStatusPill(
                    label: _connectionLabel(controller.connectionState),
                    color: _statusColor(controller.connectionState),
                    icon: _connectionIcon(controller.connectionState),
                  ),
                  const SizedBox(width: 8),
                  GaiaStatusPill(
                    label: _programmeLabel(controller.programmeSummaryState),
                    color: _programmeColor(controller.programmeSummaryState),
                    icon: Icons.account_tree_outlined,
                  ),
                  const SizedBox(width: 8),
                  GaiaStatusPill(
                    label: _projectOfficerLabel(controller.projectOfficerState),
                    color: _projectOfficerColor(controller.projectOfficerState),
                    icon: Icons.schema_outlined,
                  ),
                  const SizedBox(width: 8),
                  GaiaStatusPill(
                    label:
                        controller.programmeSummaryStale ||
                            controller.projectOfficerStale ||
                            controller.dataStale
                        ? 'Stale data'
                        : 'Fresh data',
                    color:
                        controller.programmeSummaryStale ||
                            controller.projectOfficerStale ||
                            controller.dataStale
                        ? Colors.orange
                        : Colors.green,
                    icon: Icons.history,
                  ),
                  const SizedBox(width: 8),
                  GaiaStatusPill(
                    label: refreshLabel,
                    color: Colors.teal,
                    icon: Icons.schedule,
                  ),
                  const SizedBox(width: 8),
                  GaiaStatusPill(
                    label: 'Backend: ${backendUri.authority}',
                    color: Colors.blue,
                    icon: Icons.link,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh GAIA'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenControlCentre,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open GAIA Control Centre'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DisabledGaiaSurface extends StatelessWidget {
  const _DisabledGaiaSurface({
    required this.backendUri,
    required this.onOpenSettings,
  });

  final Uri backendUri;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GAIA read-only surface is disabled',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'The embedded GAIA workspace stays hidden until you enable the Dashboard feature flag in Settings. While disabled, the backend is not contacted.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Configured backend endpoint: ${backendUri.toString()}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onOpenSettings,
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('Enable in Settings'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showControlCentreInstructions(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open GAIA Control Centre'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showControlCentreInstructions(BuildContext context) async {
  if (!context.mounted) {
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        title: const Text('Open GAIA Control Centre'),
        content: Text(
          'Execution, rollback, retention cleanup, signing-key management, and repository mutation stay in the dedicated GAIA Control Centre. '
          'Open the standalone app or documented launcher for those actions. The embedded Dashboard surface remains read-only.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

String _connectionLabel(GaiaDashboardConnectionState state) {
  return switch (state) {
    GaiaDashboardConnectionState.connected => 'Connected',
    GaiaDashboardConnectionState.connecting => 'Loading',
    GaiaDashboardConnectionState.degraded => 'Degraded',
    GaiaDashboardConnectionState.incompatible => 'Incompatible',
    GaiaDashboardConnectionState.unavailable => 'Unavailable',
    GaiaDashboardConnectionState.disconnected => 'Disconnected',
  };
}

Color _statusColor(GaiaDashboardConnectionState state) {
  return switch (state) {
    GaiaDashboardConnectionState.connected => Colors.green,
    GaiaDashboardConnectionState.connecting => Colors.blue,
    GaiaDashboardConnectionState.degraded => Colors.orange,
    GaiaDashboardConnectionState.incompatible => Colors.red,
    GaiaDashboardConnectionState.unavailable => Colors.blueGrey,
    GaiaDashboardConnectionState.disconnected => Colors.blueGrey,
  };
}

IconData _connectionIcon(GaiaDashboardConnectionState state) {
  return switch (state) {
    GaiaDashboardConnectionState.connected => Icons.check_circle_outline,
    GaiaDashboardConnectionState.connecting => Icons.sync,
    GaiaDashboardConnectionState.degraded => Icons.warning_amber_outlined,
    GaiaDashboardConnectionState.incompatible => Icons.report_outlined,
    GaiaDashboardConnectionState.unavailable => Icons.cloud_off_outlined,
    GaiaDashboardConnectionState.disconnected => Icons.link_off,
  };
}

String _programmeLabel(GaiaProgrammeSummaryState state) {
  return switch (state) {
    GaiaProgrammeSummaryState.loading => 'Programme loading',
    GaiaProgrammeSummaryState.ready => 'Programme ready',
    GaiaProgrammeSummaryState.empty => 'Programme empty',
    GaiaProgrammeSummaryState.stale => 'Programme stale',
    GaiaProgrammeSummaryState.unavailable => 'Programme unavailable',
    GaiaProgrammeSummaryState.incompatible => 'Programme incompatible',
    GaiaProgrammeSummaryState.partial => 'Programme partial',
    GaiaProgrammeSummaryState.error => 'Programme error',
  };
}

Color _programmeColor(GaiaProgrammeSummaryState state) {
  return switch (state) {
    GaiaProgrammeSummaryState.loading => Colors.blue,
    GaiaProgrammeSummaryState.ready => Colors.green,
    GaiaProgrammeSummaryState.empty => Colors.teal,
    GaiaProgrammeSummaryState.stale => Colors.orange,
    GaiaProgrammeSummaryState.unavailable => Colors.blueGrey,
    GaiaProgrammeSummaryState.incompatible => Colors.red,
    GaiaProgrammeSummaryState.partial => Colors.amber,
    GaiaProgrammeSummaryState.error => Colors.red,
  };
}

String _projectOfficerLabel(GaiaProjectOfficerSummaryState state) {
  return switch (state) {
    GaiaProjectOfficerSummaryState.loading => 'Project Officer loading',
    GaiaProjectOfficerSummaryState.ready => 'Project Officer ready',
    GaiaProjectOfficerSummaryState.empty => 'Project Officer empty',
    GaiaProjectOfficerSummaryState.stale => 'Project Officer stale',
    GaiaProjectOfficerSummaryState.unavailable => 'Project Officer unavailable',
    GaiaProjectOfficerSummaryState.incompatible =>
      'Project Officer incompatible',
    GaiaProjectOfficerSummaryState.partial => 'Project Officer partial',
    GaiaProjectOfficerSummaryState.error => 'Project Officer error',
  };
}

Color _projectOfficerColor(GaiaProjectOfficerSummaryState state) {
  return switch (state) {
    GaiaProjectOfficerSummaryState.loading => Colors.blue,
    GaiaProjectOfficerSummaryState.ready => Colors.green,
    GaiaProjectOfficerSummaryState.empty => Colors.teal,
    GaiaProjectOfficerSummaryState.stale => Colors.orange,
    GaiaProjectOfficerSummaryState.unavailable => Colors.blueGrey,
    GaiaProjectOfficerSummaryState.incompatible => Colors.red,
    GaiaProjectOfficerSummaryState.partial => Colors.amber,
    GaiaProjectOfficerSummaryState.error => Colors.red,
  };
}

String _formatTimestamp(DateTime value) {
  return value
      .toLocal()
      .toIso8601String()
      .replaceFirst('T', ' ')
      .split('.')
      .first;
}
