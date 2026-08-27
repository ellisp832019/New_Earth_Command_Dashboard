import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/platform_core_composition.dart';
import '../data/platform_core_runtime_configuration.dart';
import '../domain/governed_status.dart';

class PlatformCoreGovernedStatusScreen extends ConsumerWidget {
  const PlatformCoreGovernedStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(platformCoreLiveStatusProvider);

    return WorkspaceShell(
      title: 'Platform Core',
      subtitle: 'Read-only declaration and architecture status.',
      onBack: () => context.go(RouteNames.more),
      child: status.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _StatusPanel(
          state: _StatusState.unavailable,
          explanation: 'The Platform Core source is unavailable.',
          onRefresh: () => _refresh(ref),
        ),
        data: (liveStatus) => _LiveStatusPanel(
          liveStatus: liveStatus,
          onRefresh: () => _refresh(ref),
        ),
      ),
    );
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(platformCoreProductionCompositionProvider);
    ref.invalidate(platformCoreLiveStatusProvider);
  }
}

class _LiveStatusPanel extends StatelessWidget {
  const _LiveStatusPanel({required this.liveStatus, required this.onRefresh});

  final PlatformCoreLiveStatus liveStatus;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final configuration = liveStatus.composition.configuration;
    final envelope = liveStatus.envelope;
    final state = _stateFor(configuration, envelope);
    final explanation = _explanationFor(configuration, envelope, state);
    final metadata = envelope == null ? null : _firstMetadata(envelope);
    final declared = envelope == null ? null : _firstDeclared(envelope);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StatusPanel(
          state: state,
          explanation: explanation,
          onRefresh: onRefresh,
        ),
        if (declared != null) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Declared project',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Name',
                    value: declared.displayName ?? 'Unavailable',
                  ),
                  _DetailRow(
                    label: 'Type',
                    value: declared.systemType ?? 'Unavailable',
                  ),
                  _DetailRow(
                    label: 'Repository',
                    value: declared.repository ?? 'Unavailable',
                  ),
                  _DetailRow(
                    label: 'Contract',
                    value: declared.contractVersion ?? 'Unavailable',
                  ),
                  if (metadata?.retrievedAt != null)
                    _DetailRow(
                      label: 'Last read',
                      value: metadata!.retrievedAt!.toIso8601String(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  _StatusState _stateFor(
    PlatformCoreRuntimeConfiguration configuration,
    GovernedStatusEnvelope? envelope,
  ) {
    switch (configuration.status) {
      case PlatformCoreRuntimeConfigurationStatus.unavailable:
        return configuration.configurationSource == null
            ? _StatusState.notConfigured
            : _StatusState.unavailable;
      case PlatformCoreRuntimeConfigurationStatus.invalidRoot:
        return _StatusState.invalidConfiguration;
      case PlatformCoreRuntimeConfigurationStatus.notConfigured:
        return _StatusState.notConfigured;
      case PlatformCoreRuntimeConfigurationStatus.configured:
        break;
    }

    final failure = envelope == null ? null : _firstFailure(envelope);
    if (failure != null) return _StatusState.declarationIssue;
    return _firstDeclared(envelope) == null
        ? _StatusState.unavailable
        : _StatusState.declarationAvailable;
  }

  String _explanationFor(
    PlatformCoreRuntimeConfiguration configuration,
    GovernedStatusEnvelope? envelope,
    _StatusState state,
  ) {
    switch (state) {
      case _StatusState.notConfigured:
        return 'Set NEW_EARTH_PLATFORM_CORE_ROOT to view the local declaration source.';
      case _StatusState.invalidConfiguration:
        return 'The configured Platform Core root is not a valid usable source.';
      case _StatusState.unavailable:
        return 'The configured Platform Core source is unavailable.';
      case _StatusState.declarationIssue:
        return 'The Platform Core declaration could not be accepted.';
      case _StatusState.declarationAvailable:
        return 'The Dashboard is viewing the current Platform Core declaration.';
    }
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.state,
    required this.explanation,
    required this.onRefresh,
  });

  final _StatusState state;
  final String explanation;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = switch (state) {
      _StatusState.declarationAvailable => theme.colorScheme.primary,
      _StatusState.notConfigured => theme.colorScheme.secondary,
      _ => theme.colorScheme.error,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree_outlined, color: colour),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Platform Core',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  key: const Key('platformCoreGovernedStatusRefreshButton'),
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Platform Core status',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _labelFor(state),
              style: theme.textTheme.titleMedium?.copyWith(color: colour),
            ),
            const SizedBox(height: 8),
            Text(explanation),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Source: Platform Core')),
                Chip(label: Text('Declared authority')),
                Chip(label: Text('Read-only')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(_StatusState state) {
    switch (state) {
      case _StatusState.notConfigured:
        return 'Not configured';
      case _StatusState.invalidConfiguration:
        return 'Configuration issue';
      case _StatusState.unavailable:
        return 'Unavailable';
      case _StatusState.declarationIssue:
        return 'Declaration issue';
      case _StatusState.declarationAvailable:
        return 'Declaration available';
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

enum _StatusState {
  notConfigured,
  invalidConfiguration,
  unavailable,
  declarationIssue,
  declarationAvailable,
}

GovernedStatusSourceMetadata? _firstMetadata(GovernedStatusEnvelope envelope) {
  return envelope.sourceMetadata.isEmpty ? null : envelope.sourceMetadata.first;
}

GovernedStatusSourceFailure? _firstFailure(GovernedStatusEnvelope envelope) {
  return envelope.sourceFailures.isEmpty ? null : envelope.sourceFailures.first;
}

DeclaredStatusLayer? _firstDeclared(GovernedStatusEnvelope? envelope) {
  if (envelope == null || envelope.records.isEmpty) return null;
  return envelope.records.first.declared;
}
