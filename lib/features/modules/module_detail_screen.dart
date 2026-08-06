import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dock/dock_position.dart';
import '../../core/modules/module_category.dart';
import '../../core/modules/module_health.dart';
import '../../core/modules/module_manifest.dart';
import '../../core/modules/module_permissions.dart';
import '../../core/modules/module_navigation.dart';
import '../../core/modules/module_status.dart';
import '../../core/routing/route_names.dart';
import 'application/module_hub_controller.dart';
import 'module_dock_preview.dart';
import 'module_health_panel.dart';
import 'module_logs_panel.dart';
import 'widgets/module_workspace_shell.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final modules = ref.watch(moduleHubModulesProvider);
    final showGateShortcuts = _isSensitiveModule(module.id);
    final preferredRoute = moduleLaunchRoute(
      module,
      ref.read(moduleHubStateRepositoryProvider).loadLaunchTarget(module.id),
    );

    return ModuleWorkspaceShell(
      module: module,
      modules: modules,
      title: module.name,
      subtitle: module.description,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailPanel(
            title: 'Overview',
            subtitle: module.description,
            icon: moduleIconFor(
              module.iconKey,
              category: module.category,
            ),
            body: module.name,
            chips: [
              module.category.label,
              module.status.label,
              module.source.label,
              'v${module.version}',
              module.enabled ? 'Enabled locally' : 'Disabled locally',
              module.dockable ? 'Dockable' : 'Screen-first',
            ],
            actions: [
              FilledButton.tonal(
                onPressed: () {
                  context.push(
                    RouteNames.moduleHubModulePermissions(module.id),
                  );
                },
                child: const Text('Inspect permissions'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  context.push(
                    RouteNames.moduleHubModuleSettings(module.id),
                  );
                },
                child: const Text('Open settings'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  context.push(
                    RouteNames.moduleHubModuleOperations(module.id),
                  );
                },
                child: const Text('Open operations'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  context.push(
                    RouteNames.moduleHubModuleDocking(module.id),
                  );
                },
                child: const Text('Inspect docking'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  context.push(
                    RouteNames.moduleHubModuleGovernance(module.id),
                  );
                },
                child: const Text('Review governance'),
              ),
              FilledButton(
                onPressed: () {
                  context.go(preferredRoute);
                },
                child: const Text('Open module'),
              ),
            ],
            child: const SizedBox.shrink(),
          ),
          if (_isKnowledgeEngineModule(module.id)) ...[
            const SizedBox(height: 16),
            _DetailPanel(
              title: 'Knowledge engine quick access',
              subtitle: 'Jump straight to the scan outputs or safe settings',
              icon: Icons.travel_explore_outlined,
              body:
                  'This module stays read-only by default. Use the scan outputs shortcut to open the repository index and generated notes directly.',
              chips: const [
                'Scan/report only',
                'Repository index',
                'Learning notes',
                'Obsidian export',
              ],
              actions: [
                FilledButton(
                  onPressed: module.routes.isEmpty
                      ? null
                      : () => context.go(
                          Uri(
                            path: preferredRoute,
                            queryParameters: {'tab': 'scan-results'},
                          ).toString(),
                        ),
                  child: const Text('Open scan outputs'),
                ),
                FilledButton.tonal(
                  onPressed: module.routes.isEmpty
                      ? null
                      : () => context.go(
                          Uri(
                            path: preferredRoute,
                            queryParameters: {'tab': 'settings'},
                          ).toString(),
                        ),
                  child: const Text('Open safe settings'),
                ),
              ],
              child: const SizedBox.shrink(),
            ),
          ],
          if (showGateShortcuts) ...[
            const SizedBox(height: 16),
            _DetailPanel(
              title: 'Gate posture',
              subtitle: 'Why this module stays behind a local check',
              icon: Icons.lock_outline,
              body: _gatePostureBody(module.id),
              chips: _gatePostureChips(module.id),
              actions: [
                FilledButton(
                  onPressed: () => context.go(preferredRoute),
                  child: const Text('Open module route'),
                ),
              ],
              child: const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            _DetailPanel(
              title: 'Access control shortcuts',
              subtitle: 'Jump straight into the local access gate and review paths',
              icon: Icons.shield_outlined,
              body:
                  'Open the gate or the module route directly, depending on what you need to inspect.',
              chips: const [
                'Access gate',
                'Local route',
                'Audit aware',
              ],
              actions: [
                FilledButton(
                  onPressed: () => context.go(preferredRoute),
                  child: const Text('Open module route'),
                ),
                if (module.id == '01_USERS_AND_DEVICES_CONTROL') ...[
                  FilledButton.tonal(
                    onPressed: () => context.push(RouteNames.usersDevicesUsers),
                    child: const Text('Open Users'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push(RouteNames.usersDevicesDevices),
                    child: const Text('Open Devices'),
                  ),
                  FilledButton.tonal(
                    onPressed: () =>
                        context.push(RouteNames.usersDevicesAccessMatrix),
                    child: const Text('Open Access Matrix'),
                  ),
                  FilledButton.tonal(
                    onPressed: () =>
                        context.push(RouteNames.usersDevicesApprovalQueue),
                    child: const Text('Open Approvals'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.push(RouteNames.usersDevicesAuditLog),
                    child: const Text('Open Audit Log'),
                  ),
                ],
              ],
              child: const SizedBox.shrink(),
            ),
          ],
          const SizedBox(height: 16),
          _DetailPanel(
            title: 'Health',
            subtitle: 'Local health and readiness signals',
            icon: Icons.health_and_safety_outlined,
            body: 'Module health status',
            chips: [
              module.health.state.label,
              module.health.backendStatus,
              if (module.health.warnings.isNotEmpty) '${module.health.warnings.length} warnings',
            ],
            actions: const [],
            child: ModuleHealthPanel(module: module),
          ),
          const SizedBox(height: 16),
          _DetailPanel(
            title: 'Manifest info',
            subtitle: 'Source paths and configuration details',
            icon: Icons.description_outlined,
            body: 'Module metadata and filesystem references',
            chips: const [],
            actions: const [],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Module ID', value: module.id),
                _InfoRow(label: 'Version', value: module.version),
                _InfoRow(label: 'Category', value: module.category.label),
                _InfoRow(label: 'Source', value: module.source.label),
                _InfoRow(label: 'Current status', value: module.status.label),
                _InfoRow(
                  label: 'Enabled state',
                  value: module.enabled ? 'Enabled' : 'Disabled',
                ),
                _InfoRow(
                  label: 'Dockable',
                  value: module.dockable ? 'Yes' : 'No',
                ),
                _InfoRow(
                  label: 'Default dock position',
                  value: module.defaultDockPosition.label,
                ),
                _InfoRow(label: 'Install path', value: module.installPath),
                _InfoRow(label: 'Omega OS path', value: module.omegaOsPath),
                _InfoRow(
                  label: 'Storage path',
                  value: module.storagePath.isEmpty
                      ? 'Not configured'
                      : module.storagePath,
                ),
                _InfoRow(
                  label: 'Routes',
                  value: module.routes.isEmpty
                      ? 'No explicit routes'
                      : module.routes.join('\n'),
                ),
                _InfoRow(
                  label: 'Tags',
                  value: module.tags.isEmpty
                      ? 'None'
                      : module.tags.join(', '),
                ),
                _InfoRow(
                  label: 'Notes',
                  value: module.notes.isEmpty ? 'None recorded' : module.notes,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailPanel(
            title: 'Permissions review',
            subtitle: 'What this module can touch locally',
            icon: Icons.verified_user_outlined,
            body: module.permissions.isEmpty
                ? 'This module does not request permissions yet.'
                : '${module.permissions.length} permission(s) requested locally.',
            chips: const [],
            actions: [
              FilledButton.tonal(
                onPressed: () {
                  context.push(
                    RouteNames.moduleHubModulePermissions(module.id),
                  );
                },
                child: const Text('Open permissions panel'),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: module.permissions.isEmpty
                  ? [const Text('No permissions have been defined for this module.')]
                  : module.permissions
                      .map(
                        (permission) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.42),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          permission.label,
                                          style: theme.textTheme.titleSmall,
                                        ),
                                      ),
                                      Chip(label: Text(permission.state.label)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _permissionSummary(permission),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  if (permission.notes.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      permission.notes,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _DetailPanel(
            title: 'Dock options',
            subtitle: 'The calmer preview path for this module',
            icon: Icons.view_sidebar_outlined,
            body: module.dockable
                ? 'This module can be previewed in multiple dock positions.'
                : 'This module is treated as a screen-first system core module.',
            chips: const [],
            actions: const [],
            child: ModuleDockPreview(
              module: module,
              initialPosition: module.defaultDockPosition,
              showAssistantDockPlaceholder: module.id == 'module_hub',
            ),
          ),
          const SizedBox(height: 16),
          ModuleLogsPanel(module: module),
        ],
      ),
    );
  }

  String _permissionSummary(ModulePermission permission) {
    return switch (permission.type) {
      ModulePermissionType.microphone =>
        'Audio input access is reviewed here before voice-related features are enabled.',
      ModulePermissionType.speaker =>
        'Audio output access is reviewed here before spoken feedback is enabled.',
      ModulePermissionType.screenCapture =>
        'Screen capture access is needed for visual inspection or assistant support.',
      ModulePermissionType.fileRead =>
        'Read access lets the module inspect local files without changing them.',
      ModulePermissionType.fileWrite =>
        'Write access lets the module update local files or save module output.',
      ModulePermissionType.browserControl =>
        'Browser control is reserved for modules that need to move through web surfaces.',
      ModulePermissionType.appLaunch =>
        'App launch access lets the module open other local tools when needed.',
      ModulePermissionType.shellCommands =>
        'Shell command access is powerful and should stay explicit.',
      ModulePermissionType.mouseKeyboardControl =>
        'Mouse and keyboard access allows direct control of local interfaces.',
      ModulePermissionType.localNetwork =>
        'Local network access is used for trusted devices on the same network.',
      ModulePermissionType.internetAccess =>
        'Internet access is only needed for modules that reach beyond the local machine.',
      ModulePermissionType.calendarAccess =>
        'Calendar access is held here for future scheduling surfaces.',
      ModulePermissionType.emailAccess =>
        'Email access is held here for future communication surfaces.',
      ModulePermissionType.contactsAccess =>
        'Contacts access is reserved for directory-aware workflows.',
      ModulePermissionType.repoAccess =>
        'Repository access supports source-aware and code-linked workflows.',
      ModulePermissionType.omegaOsAccess =>
        'Omega OS access links the module back to the wider New Earth operating surface.',
    };
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

String _gatePostureBody(String moduleId) {
  return switch (moduleId) {
    '01_USERS_AND_DEVICES_CONTROL' =>
      'Identity, trust, approvals, and audit live here before any sensitive module opens.',
    'newearth.finance_treasury' =>
      'Treasury work stays behind local identity, role, trust, and audit checks.',
    'repo_research_engine' =>
      'Research exports and evidence stays gated so the local trail stays clear.',
    'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE' =>
      'Voice gateway actions stay behind an explicit identity and trust check.',
    'gaia_voice_assistant' =>
      'The assistant surface remains local, trusted, and auditable before it speaks or acts.',
    _ =>
      'Sensitive routes stay local, trusted, and recorded before they can open.',
  };
}

List<String> _gatePostureChips(String moduleId) {
  return switch (moduleId) {
    '01_USERS_AND_DEVICES_CONTROL' => const [
        'Identity',
        'Trust',
        'Approval queue',
        'Audit log',
      ],
    'newearth.finance_treasury' => const [
        'Finance',
        'Role-based',
        'Trusted device',
        'Audited',
      ],
    'repo_research_engine' => const [
        'Research',
        'Evidence',
        'Local trail',
        'Approval aware',
      ],
    'NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE' => const [
        'Voice gateway',
        'Local trust',
        'Controlled actions',
        'Audited',
      ],
    'gaia_voice_assistant' => const [
        'Voice AI',
        'Conversation history',
        'Safe actions',
        'Audit aware',
      ],
    _ => const ['Local-first', 'Trusted', 'Audited'],
  };
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.body,
    required this.chips,
    required this.actions,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String body;
  final List<String> chips;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.46),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 6),
                        Text(subtitle, style: theme.textTheme.headlineSmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(body),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chips.map((chip) => Chip(label: Text(chip))).toList(),
                ),
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(spacing: 12, runSpacing: 12, children: actions),
              ],
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
