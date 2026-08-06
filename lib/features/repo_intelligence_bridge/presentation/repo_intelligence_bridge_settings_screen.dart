import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/repo_intelligence_bridge_controller.dart';
import '../data/repo_intelligence_bridge_models.dart';
import 'sync_run_terminal_dialog.dart';

class RepoIntelligenceBridgeSettingsScreen extends ConsumerStatefulWidget {
  const RepoIntelligenceBridgeSettingsScreen({super.key});

  @override
  ConsumerState<RepoIntelligenceBridgeSettingsScreen> createState() =>
      _RepoIntelligenceBridgeSettingsScreenState();
}

class _RepoIntelligenceBridgeSettingsScreenState
    extends ConsumerState<RepoIntelligenceBridgeSettingsScreen> {
  final TextEditingController _exportRootController = TextEditingController();
  final TextEditingController _obsidianVaultController = TextEditingController();
  final TextEditingController _moduleHomeController = TextEditingController();
  String? _selectedProfileFile;
  bool _hydrated = false;

  @override
  void dispose() {
    _exportRootController.dispose();
    _obsidianVaultController.dispose();
    _moduleHomeController.dispose();
    super.dispose();
  }

  Future<void> _runSyncTerminal({
    required String title,
    required Future<RepoIntelligenceBridgeSyncResult> Function(
      void Function(String line) onOutputLine,
    ) run,
    required VoidCallback openLog,
  }) async {
    await showRepoIntelligenceBridgeSyncTerminalDialog(
      context: context,
      title: title,
      run: run,
      onOpenLog: openLog,
    );
    if (!mounted) {
      return;
    }
    ref.invalidate(repoIntelligenceBridgeWorkspaceProvider);
  }

  void _hydrate(RepoIntelligenceBridgeWorkspace workspace) {
    if (_hydrated && _selectedProfileFile == workspace.activeProfile.fileName) {
      return;
    }

    _selectedProfileFile = workspace.activeProfile.fileName;
    _exportRootController.text = workspace.state.dashboardExportRoot.isNotEmpty
        ? workspace.state.dashboardExportRoot
        : workspace.activeProfile.dashboardExportPath;
    _obsidianVaultController.text = workspace.state.obsidianVaultPath;
    _moduleHomeController.text = workspace.state.moduleHomePath;
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    final workspaceAsync = ref.watch(repoIntelligenceBridgeWorkspaceProvider);

    return WorkspaceShell(
      title: 'Repo Intelligence Bridge Settings',
      subtitle: 'Local bridge configuration',
      onBack: () => context.go(RouteNames.repoIntelligenceBridge),
      trailingActions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () =>
              ref.invalidate(repoIntelligenceBridgeWorkspaceProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: workspaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (workspace) {
          _hydrate(workspace);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SettingsHeroCard(
                workspace: workspace,
                onOpenBridge: () => context.go(RouteNames.repoIntelligenceBridge),
                onOpenProfiles: () => ref
                    .read(repoIntelligenceBridgeControllerProvider)
                    .openProfilesFolder(),
                onOpenModuleHome: () => ref
                    .read(repoIntelligenceBridgeControllerProvider)
                    .openModuleHome(),
                onOpenSyncLog: () =>
                    ref.read(repoIntelligenceBridgeControllerProvider).openSyncLog(),
                onOpenStateFile: () =>
                    ref.read(repoIntelligenceBridgeControllerProvider).openStateFile(),
              ),
              const SizedBox(height: 16),
              _BridgeSectionCard(
                title: 'Project profiles',
                icon: Icons.folder_copy_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue:
                          workspace.profiles.isEmpty ? null : _selectedProfileFile,
                      decoration: const InputDecoration(
                        labelText: 'Active profile',
                        prefixIcon: Icon(Icons.list_alt_outlined),
                      ),
                      items: [
                        for (final profile in workspace.profiles)
                          DropdownMenuItem<String>(
                            value: profile.fileName,
                            child: Text(
                              '${profile.projectName} (${profile.fileName})',
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedProfileFile = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      workspace.profiles.isEmpty
                          ? 'No profile files were found in the module profiles folder.'
                          : 'The active profile decides which project folder the dashboard reads.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final rule in workspace.activeProfile.lockedRules
                            .take(4))
                          _InlineTag(
                            label: rule,
                            accent: AppColours.darkSurfaceRaised,
                            foreground: AppColours.darkText,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _BridgeSectionCard(
                title: 'Path configuration',
                icon: Icons.route_outlined,
                child: Column(
                  children: [
                    TextField(
                      controller: _exportRootController,
                      decoration: const InputDecoration(
                        labelText: 'Dashboard export root',
                        prefixIcon: Icon(Icons.folder_open_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _obsidianVaultController,
                      decoration: const InputDecoration(
                        labelText: 'Obsidian vault path',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _moduleHomeController,
                      decoration: const InputDecoration(
                        labelText: 'Module home path',
                        prefixIcon: Icon(Icons.folder_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _BridgeSectionCard(
                title: 'Manual sync',
                icon: Icons.sync_outlined,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _runSyncTerminal(
                        title: 'Validate Config Terminal',
                        run: (onLine) => ref
                            .read(repoIntelligenceBridgeControllerProvider)
                            .runValidateConfig(onOutputLine: onLine),
                        openLog: () =>
                            ref.read(repoIntelligenceBridgeControllerProvider).openSyncLog(),
                      ),
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Validate'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _runSyncTerminal(
                        title: 'Obsidian Sync Terminal',
                        run: (onLine) => ref
                            .read(repoIntelligenceBridgeControllerProvider)
                            .runObsidianSync(onOutputLine: onLine),
                        openLog: () =>
                            ref.read(repoIntelligenceBridgeControllerProvider).openSyncLog(),
                      ),
                      icon: const Icon(Icons.book_outlined),
                      label: const Text('Sync Obsidian'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _runSyncTerminal(
                        title: 'Dashboard Sync Terminal',
                        run: (onLine) => ref
                            .read(repoIntelligenceBridgeControllerProvider)
                            .runDashboardSync(onOutputLine: onLine),
                        openLog: () =>
                            ref.read(repoIntelligenceBridgeControllerProvider).openSyncLog(),
                      ),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: const Text('Sync Dashboard'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _runSyncTerminal(
                        title: 'Full Sync Terminal',
                        run: (onLine) => ref
                            .read(repoIntelligenceBridgeControllerProvider)
                            .runFullSync(onOutputLine: onLine),
                        openLog: () =>
                            ref.read(repoIntelligenceBridgeControllerProvider).openSyncLog(),
                      ),
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: const Text('Run full sync'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _BridgeSectionCard(
                title: 'Save changes',
                icon: Icons.save_outlined,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        final selectedProfile = workspace.profiles.firstWhere(
                          (profile) => profile.fileName == _selectedProfileFile,
                          orElse: () => workspace.activeProfile,
                        );
                        await ref
                            .read(repoIntelligenceBridgeControllerProvider)
                            .updateState(
                              state: RepoIntelligenceBridgeState(
                                activeProfileFile: selectedProfile.fileName,
                                dashboardExportRoot:
                                    _exportRootController.text.trim(),
                                obsidianVaultPath:
                                    _obsidianVaultController.text.trim(),
                                moduleHomePath:
                                    _moduleHomeController.text.trim(),
                                lastSyncAt: workspace.lastSyncTime?.toIso8601String(),
                              ),
                            );
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bridge settings saved locally.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save config'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedProfileFile = workspace.activeProfile.fileName;
                          _exportRootController.text =
                              workspace.state.dashboardExportRoot.isNotEmpty
                              ? workspace.state.dashboardExportRoot
                              : workspace.activeProfile.dashboardExportPath;
                          _obsidianVaultController.text =
                              workspace.state.obsidianVaultPath;
                          _moduleHomeController.text =
                              workspace.state.moduleHomePath;
                        });
                      },
                      icon: const Icon(Icons.restart_alt_outlined),
                      label: const Text('Reset fields'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard({
    required this.workspace,
    required this.onOpenBridge,
    required this.onOpenProfiles,
    required this.onOpenModuleHome,
    required this.onOpenSyncLog,
    required this.onOpenStateFile,
  });

  final RepoIntelligenceBridgeWorkspace workspace;
  final VoidCallback onOpenBridge;
  final VoidCallback onOpenProfiles;
  final VoidCallback onOpenModuleHome;
  final VoidCallback onOpenSyncLog;
  final VoidCallback onOpenStateFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings and profiles',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColours.darkText,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a profile, keep paths local, and review the state file without touching source repos.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InlineTag(
                    label: workspace.activeProfile.projectName,
                    accent: AppColours.darkSecondary,
                    foreground: AppColours.darkSecondary,
                  ),
                  _InlineTag(
                    label: '${workspace.profiles.length} profiles',
                    accent: AppColours.darkSuccess,
                    foreground: AppColours.darkSuccess,
                  ),
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: wide ? WrapAlignment.end : WrapAlignment.start,
            children: [
              FilledButton.icon(
                onPressed: onOpenBridge,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open bridge'),
              ),
              TextButton.icon(
                onPressed: onOpenProfiles,
                icon: const Icon(Icons.folder_copy_outlined),
                label: const Text('Profiles folder'),
              ),
              TextButton.icon(
                onPressed: onOpenModuleHome,
                icon: const Icon(Icons.folder_outlined),
                label: const Text('Module home'),
              ),
              TextButton.icon(
                onPressed: onOpenSyncLog,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Open last sync log'),
              ),
              TextButton.icon(
                onPressed: onOpenStateFile,
                icon: const Icon(Icons.description_outlined),
                label: const Text('State file'),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 20),
              SizedBox(width: 320, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _BridgeSectionCard extends StatelessWidget {
  const _BridgeSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColours.darkSecondary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

BoxDecoration _panelDecoration(
  BuildContext context, {
  bool highlighted = false,
}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurface.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? AppColours.darkSecondary.withValues(alpha: 0.22)
          : AppColours.darkOutline.withValues(alpha: 0.9),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 26,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({
    required this.label,
    required this.accent,
    this.foreground,
  });

  final String label;
  final Color accent;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foreground ?? accent,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
