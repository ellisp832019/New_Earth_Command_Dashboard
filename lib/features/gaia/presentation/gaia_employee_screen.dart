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
      subtitle: 'Read-only embedded operations workspace',
      onBack: () => context.go(RouteNames.more),
      child: enabled && controller != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ReadOnlyHeader(
                  backendUri: backendUri,
                  onOpenControlCentre: () =>
                      _showControlCentreInstructions(context),
                ),
                const SizedBox(height: 12),
                Expanded(child: GaiaDashboardView(controller: controller)),
              ],
            )
          : _DisabledGaiaSurface(
              backendUri: backendUri,
              onOpenSettings: () => context.push(RouteNames.settings),
            ),
    );
  }
}

class _ReadOnlyHeader extends StatelessWidget {
  const _ReadOnlyHeader({
    required this.backendUri,
    required this.onOpenControlCentre,
  });

  final Uri backendUri;
  final VoidCallback onOpenControlCentre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              'This Dashboard surface is read-only. Execution, rollback, retention, and signing-key management stay in the standalone GAIA Control Centre.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const Chip(label: Text('Read only')),
                const Chip(label: Text('Loopback backend')),
                Chip(label: Text('Backend: ${backendUri.authority}')),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onOpenControlCentre,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open GAIA Control Centre'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go(RouteNames.settings),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Manage GAIA surface'),
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
          'Execution, rollback, retention cleanup, and signing-key management stay in the dedicated GAIA Control Centre. '
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
