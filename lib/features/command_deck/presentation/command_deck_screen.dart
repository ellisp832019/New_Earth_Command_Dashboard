import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../data/command_deck_service.dart';

class CommandDeckScreen extends StatefulWidget {
  const CommandDeckScreen({super.key});

  @override
  State<CommandDeckScreen> createState() => _CommandDeckScreenState();
}

class _CommandDeckScreenState extends State<CommandDeckScreen> {
  late final CommandDeckService _service;
  late Future<CommandDeckWorkspace> _workspaceFuture;

  @override
  void initState() {
    super.initState();
    _service = CommandDeckService();
    _workspaceFuture = _service.loadWorkspace();
  }

  void _reloadWorkspace() {
    setState(() {
      _workspaceFuture = _service.loadWorkspace();
    });
  }

  Future<void> _runCommand(
    CommandDeckWorkspace workspace,
    CommandDeckCommand command,
  ) async {
    if (command.requiresConfirmation) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirm command'),
          content: Text(
            'Run "${command.label}"? This command is marked for confirmation.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Run'),
            ),
          ],
        ),
      );
      if (shouldContinue != true) {
        return;
      }
    }

    try {
      await _service.executeCommand(
        command,
        workspace.config,
        onNavigate: (route) async {
          context.push(route);
        },
      );

      if (!mounted) {
        return;
      }

      if (command.type == CommandDeckCommandType.info) {
        await _showInfoDialog(workspace, command);
      } else {
        final status = switch (command.type) {
          CommandDeckCommandType.openUrl => 'Opened ${command.label}.',
          CommandDeckCommandType.openFolder =>
            'Opened ${command.label} in the file explorer.',
          CommandDeckCommandType.openRoute =>
            'Opened ${command.label} in the dashboard.',
          CommandDeckCommandType.script => 'Ran ${command.label}.',
          CommandDeckCommandType.info => 'Opened ${command.label}.',
          CommandDeckCommandType.unknown => 'Ran ${command.label}.',
        };
        _showSnackBar(status);
      }

      _reloadWorkspace();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Command failed: $error');
    }
  }

  Future<void> _showInfoDialog(
    CommandDeckWorkspace workspace,
    CommandDeckCommand command,
  ) async {
    final hotkeyDetails = workspace.config.obsEnabled
        ? [
            'Start recording: ${workspace.config.startRecordingHotkey.isEmpty ? 'Not configured' : workspace.config.startRecordingHotkey}',
            'Stop recording: ${workspace.config.stopRecordingHotkey.isEmpty ? 'Not configured' : workspace.config.stopRecordingHotkey}',
          ]
        : const ['OBS hotkeys are not enabled in the local config yet.'];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(command.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((command.description ?? '').isNotEmpty) ...[
              Text(command.description!),
              const SizedBox(height: 14),
            ],
            ...hotkeyDetails.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(line),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceShell(
      title: 'Command Deck',
      subtitle: 'Future hardware-support surface for bounded commands and tactile controls.',
      onBack: () => context.go(RouteNames.dashboard),
      trailingActions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _reloadWorkspace,
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: SafeArea(
        child: FutureBuilder<CommandDeckWorkspace>(
          future: _workspaceFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _CommandDeckError(
                error: snapshot.error,
                onRetry: _reloadWorkspace,
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final workspace = snapshot.data!;
            final groupedCommands = workspace.registry.groupedCommands;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _CommandDeckHero(workspace: workspace),
                const SizedBox(height: 16),
                _CommandDeckReadinessStrip(workspace: workspace),
                const SizedBox(height: 16),
                _PathReadinessPanel(workspace: workspace),
                const SizedBox(height: 16),
                const _CommandLegendCard(),
                if (workspace.validationIssues.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ValidationIssuesCard(issues: workspace.validationIssues),
                ],
                const SizedBox(height: 16),
                if (groupedCommands.isEmpty)
                  _EmptyStateCard(
                    title: 'No commands are registered yet.',
                    body:
                        'Add entries to modules/new_earth_command_deck/config/command_registry.example.json to populate the virtual deck.',
                  )
                else
                  ...groupedCommands.expand(
                    (group) => [
                      _CommandGroupSection(
                        group: group,
                        config: workspace.config,
                        onRunCommand: (command) =>
                            _runCommand(workspace, command),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                _RecentActionsCard(entries: workspace.actionLog),
                const SizedBox(height: 16),
                const _ModulePackCard(),
                const SizedBox(height: 16),
                const _SetupNotesCard(),
                const SizedBox(height: 16),
                _FooterCard(
                  configPath: workspace.configPath,
                  registryPath: workspace.registryPath,
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PathReadinessPanel extends StatelessWidget {
  const _PathReadinessPanel({required this.workspace});

  final CommandDeckWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final items = workspace.pathReadiness;
    final readyCount = items.where((item) => item.isReady).length;
    final placeholderCount = items.where((item) => item.isPlaceholder).length;
    final missingCount = items.where((item) => item.isMissing).length;
    final externalCount = items.where((item) => item.isExternal).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_outlined, color: AppColours.darkSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Path readiness',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
                ),
              ),
              _Pill(
                label: '$readyCount ready',
                accent: AppColours.darkSuccess,
                compact: true,
              ),
              const SizedBox(width: 8),
              _Pill(
                label: '$placeholderCount placeholders',
                accent: AppColours.darkAmber,
                compact: true,
              ),
              const SizedBox(width: 8),
              _Pill(
                label: '$missingCount missing',
                accent: AppColours.darkPurple,
                compact: true,
              ),
              if (externalCount > 0) ...[
                const SizedBox(width: 8),
                _Pill(
                  label: '$externalCount external',
                  accent: AppColours.darkSecondary,
                  compact: true,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'This checks the local config values you will eventually wire on your machine. Placeholders are example values, missing means the path is configured but not found here yet, external means the path lives on another drive or in your Linux install, and ready means the target exists on disk.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 1100
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth >= 760
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: width,
                      child: _PathReadinessCard(item: item),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PathReadinessCard extends StatelessWidget {
  const _PathReadinessCard({required this.item});

  final CommandDeckPathReadiness item;

  @override
  Widget build(BuildContext context) {
    final accent = _pathReadinessAccent(item);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                ),
                alignment: Alignment.center,
                child: Icon(_pathReadinessIcon(item), color: accent, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Pill(label: item.statusLabel, accent: accent, compact: true),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.key,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: item.value.isEmpty ? '(empty)' : item.value,
            triggerMode: TooltipTriggerMode.tap,
            child: Text(
              item.value.isEmpty ? '(empty)' : item.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.displayDetail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandDeckReadinessStrip extends StatelessWidget {
  const _CommandDeckReadinessStrip({required this.workspace});

  final CommandDeckWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final hasLocalConfig = File(workspace.configPath).existsSync();
    final configReady = hasLocalConfig;
    final registryReady = workspace.validationIssues.isEmpty;
    final actionsReady = workspace.actionLog.isNotEmpty;

    final cards = [
      _ReadinessCard(
        label: 'Config',
        value: configReady ? 'Ready' : 'Example',
        detail: configReady
            ? 'Local command_deck.json is in place.'
            : 'Using the bundled example config for now.',
        accent: configReady ? AppColours.darkSuccess : AppColours.darkAmber,
        icon: configReady ? Icons.check_circle_outline : Icons.edit_outlined,
      ),
      _ReadinessCard(
        label: 'Registry',
        value: registryReady ? 'Clean' : 'Needs review',
        detail: registryReady
            ? 'The command registry validated successfully.'
            : '${workspace.validationIssues.length} issue${workspace.validationIssues.length == 1 ? '' : 's'} need attention.',
        accent: registryReady ? AppColours.darkSuccess : AppColours.darkAmber,
        icon: registryReady
            ? Icons.verified_outlined
            : Icons.warning_amber_outlined,
      ),
      _ReadinessCard(
        label: 'Action log',
        value: actionsReady ? 'Active' : 'Empty',
        detail: actionsReady
            ? '${workspace.actionLog.length} recent action${workspace.actionLog.length == 1 ? '' : 's'} logged locally.'
            : 'The log will fill once you run a command.',
        accent: actionsReady
            ? AppColours.darkSecondary
            : AppColours.darkMutedText,
        icon: actionsReady
            ? Icons.receipt_long_outlined
            : Icons.hourglass_empty,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 980 ? 3 : 1;

        if (crossAxisCount == 1) {
          return Column(
            children: [
              for (final card in cards) ...[card, const SizedBox(height: 12)],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              Expanded(child: cards[index]),
              if (index != cards.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final String detail;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.22)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Pill(label: label, accent: accent, compact: true),
                    const Spacer(),
                    _Pill(label: value, accent: accent, compact: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
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

class _CommandLegendCard extends StatelessWidget {
  const _CommandLegendCard();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _LegendItem(
        label: 'Open page',
        description: 'Routes inside the dashboard.',
        icon: Icons.route_outlined,
        accent: AppColours.darkPrimary,
      ),
      _LegendItem(
        label: 'Open folder',
        description: 'Local project or vault paths.',
        icon: Icons.folder_open_outlined,
        accent: AppColours.darkSuccess,
      ),
      _LegendItem(
        label: 'Run script',
        description: 'Local Python helper actions.',
        icon: Icons.terminal_outlined,
        accent: AppColours.darkAmber,
      ),
      _LegendItem(
        label: 'Info card',
        description: 'Setup notes or safe reference data.',
        icon: Icons.info_outline,
        accent: AppColours.darkPurple,
      ),
      _LegendItem(
        label: 'Confirm first',
        description: 'Used for future risky actions.',
        icon: Icons.shield_outlined,
        accent: AppColours.darkAmber,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Command legend',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 10),
          Text(
            'A compact key for the virtual deck. Use these labels to read the command cards quickly, like a Stream Deck page.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1100
                  ? 5
                  : constraints.maxWidth >= 820
                  ? 3
                  : 1;

              if (crossAxisCount == 1) {
                return Column(
                  children: [
                    for (final item in items) ...[
                      _LegendCard(item: item),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.9,
                ),
                itemBuilder: (context, index) =>
                    _LegendCard(item: items[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.item});

  final _LegendItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.accent.withValues(alpha: 0.2)),
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, color: item.accent, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem {
  const _LegendItem({
    required this.label,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color accent;
}

Color _pathReadinessAccent(CommandDeckPathReadiness item) {
  return switch (item.status) {
    CommandDeckPathStatus.ready => AppColours.darkSuccess,
    CommandDeckPathStatus.placeholder => AppColours.darkAmber,
    CommandDeckPathStatus.missing =>
      item.isExternal ? AppColours.darkSecondary : AppColours.darkPurple,
  };
}

IconData _pathReadinessIcon(CommandDeckPathReadiness item) {
  return switch (item.status) {
    CommandDeckPathStatus.ready => Icons.check_circle_outline,
    CommandDeckPathStatus.placeholder => Icons.edit_outlined,
    CommandDeckPathStatus.missing =>
      item.isExternal ? Icons.swap_horiz_outlined : Icons.folder_off_outlined,
  };
}

class _CommandDeckHero extends StatelessWidget {
  const _CommandDeckHero({required this.workspace});

  final CommandDeckWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Command Deck',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppColours.darkText,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A virtual command surface for meeting starts, build sessions, project jumps, and local handoff workflows.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  'The Command Deck stays local-first and software-only for now. Scripts, page links, and folder targets live in the module pack so the page remains calm, portable, and easy to extend later.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  const _Pill(
                    label: 'Software-only first',
                    accent: AppColours.darkSecondary,
                  ),
                  const _Pill(
                    label: 'Grouped by workflow',
                    accent: AppColours.darkSuccess,
                  ),
                  _Pill(
                    label: workspace.actionLog.isEmpty
                        ? 'No recent actions'
                        : '${workspace.actionLog.length} recent actions',
                    accent: AppColours.darkAmber,
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
                onPressed: () => context.push(RouteNames.dashboard),
                icon: const Icon(Icons.dashboard_outlined),
                label: const Text('Dashboard'),
              ),
              TextButton.icon(
                onPressed: () => context.push(RouteNames.launchpad),
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Launchpad'),
              ),
              TextButton.icon(
                onPressed: () => context.push(RouteNames.settings),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Settings'),
              ),
            ],
          );

          final metadata = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoLine(label: 'Config', value: workspace.configPath),
              const SizedBox(height: 8),
              _InfoLine(label: 'Registry', value: workspace.registryPath),
              const SizedBox(height: 8),
              _InfoLine(
                label: 'OBS',
                value: workspace.config.obsEnabled
                    ? 'Start ${workspace.config.startRecordingHotkey.isEmpty ? 'not set' : workspace.config.startRecordingHotkey} / Stop ${workspace.config.stopRecordingHotkey.isEmpty ? 'not set' : workspace.config.stopRecordingHotkey}'
                    : 'Disabled in local config',
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 18),
                metadata,
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 18),
              SizedBox(width: 350, child: metadata),
              const SizedBox(width: 18),
              SizedBox(width: 230, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _CommandGroupSection extends StatelessWidget {
  const _CommandGroupSection({
    required this.group,
    required this.config,
    required this.onRunCommand,
  });

  final CommandDeckCommandGroup group;
  final CommandDeckConfig config;
  final Future<void> Function(CommandDeckCommand command) onRunCommand;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForGroup(group.name);

    return Container(
      key: Key('commandDeckGroup-${group.name}'),
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForGroup(group.name), color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
                ),
              ),
              _Pill(label: '${group.commands.length} cards', accent: accent),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _groupDescription(group.name),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1120
                  ? 3
                  : constraints.maxWidth >= 760
                  ? 2
                  : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.commands.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: crossAxisCount == 1 ? 2.45 : 1.95,
                ),
                itemBuilder: (context, index) {
                  final command = group.commands[index];
                  final resolvedPath = _resolvedTarget(command, config);
                  return _CommandActionCard(
                    command: command,
                    resolvedPath: resolvedPath,
                    isAvailable: _isAvailable(command, resolvedPath),
                    onPressed: () => onRunCommand(command),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CommandActionCard extends StatelessWidget {
  const _CommandActionCard({
    required this.command,
    required this.resolvedPath,
    required this.isAvailable,
    required this.onPressed,
  });

  final CommandDeckCommand command;
  final String? resolvedPath;
  final bool isAvailable;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType(command.type);
    final tint = _cardTintForType(command.type);
    final subtitle = _commandSubtitle(command, resolvedPath);

    return InkWell(
      key: Key('commandDeckCommand-${command.id}'),
      borderRadius: BorderRadius.circular(20),
      onTap: isAvailable ? onPressed : null,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAvailable
                ? accent.withValues(alpha: 0.28)
                : AppColours.darkOutline.withValues(alpha: 0.9),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _iconForType(command.type),
                    color: accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                _Pill(
                  label: _commandKindLabel(command),
                  accent: accent,
                  compact: true,
                ),
                const Spacer(),
                _Pill(label: command.typeLabel, accent: accent, compact: true),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              command.label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
            const Spacer(),
            if (resolvedPath?.isNotEmpty == true) ...[
              Tooltip(
                message: resolvedPath!,
                triggerMode: TooltipTriggerMode.tap,
                child: Text(
                  _displayTargetLabel(command, resolvedPath!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                command: command,
                accent: accent,
                onPressed: isAvailable ? onPressed : null,
                isAvailable: isAvailable,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActionsCard extends StatelessWidget {
  const _RecentActionsCard({required this.entries});

  final List<CommandDeckActionLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppColours.darkSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                'Recent actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(
              'No command actions have been logged yet. Run a command and it will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
            )
          else
            Column(
              children: [
                for (final entry in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColours.darkSurfaceRaised.withValues(
                          alpha: 0.88,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColours.darkOutline.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.bolt_outlined,
                            color: AppColours.darkSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.label,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppColours.darkText),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${entry.timestampLabel} · ${entry.type} · ${entry.group}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColours.darkMutedText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ModulePackCard extends StatelessWidget {
  const _ModulePackCard();

  @override
  Widget build(BuildContext context) {
    final cards = const [
      _SupportFileCard(
        title: 'Config',
        subtitle: 'Path settings and local machine defaults.',
        path: 'modules/new_earth_command_deck/config',
        icon: Icons.tune_outlined,
        accent: AppColours.darkSecondary,
      ),
      _SupportFileCard(
        title: 'Scripts',
        subtitle: 'Meeting, build session, and Codex handoff helpers.',
        path: 'modules/new_earth_command_deck/scripts',
        icon: Icons.terminal_outlined,
        accent: AppColours.darkSuccess,
      ),
      _SupportFileCard(
        title: 'Templates',
        subtitle: 'Meeting and handoff templates kept with the pack.',
        path: 'modules/new_earth_command_deck/templates',
        icon: Icons.description_outlined,
        accent: AppColours.darkAmber,
      ),
      _SupportFileCard(
        title: 'Stream Deck',
        subtitle: 'Layout and button map planning.',
        path: 'modules/new_earth_command_deck/stream_deck',
        icon: Icons.gamepad_outlined,
        accent: AppColours.darkPurple,
      ),
      _SupportFileCard(
        title: 'Omega OS',
        subtitle: 'Folder structure that mirrors the command pack.',
        path: 'modules/new_earth_command_deck/omega_os',
        icon: Icons.folder_outlined,
        accent: AppColours.darkPrimary,
      ),
      _SupportFileCard(
        title: 'Codex',
        subtitle: 'Handoff prompts and task notes for future work.',
        path: 'modules/new_earth_command_deck/codex',
        icon: Icons.psychology_outlined,
        accent: AppColours.darkSecondary,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Module pack',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 10),
          Text(
            'Everything for the Command Deck stays inside modules/new_earth_command_deck/ so the dashboard page and the support pack stay aligned.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1120
                  ? 3
                  : constraints.maxWidth >= 720
                  ? 2
                  : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: crossAxisCount == 1 ? 2.8 : 2.35,
                ),
                itemBuilder: (context, index) => cards[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SupportFileCard extends StatelessWidget {
  const _SupportFileCard({
    required this.title,
    required this.subtitle,
    required this.path,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String path;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            path,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationIssuesCard extends StatelessWidget {
  const _ValidationIssuesCard({required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: AppColours.darkAmber,
              ),
              const SizedBox(width: 10),
              Text(
                'Registry notes',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                issue,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetupNotesCard extends StatelessWidget {
  const _SetupNotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Setup notes',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 10),
          Text(
            '1. Keep command registry entries grouped by workflow.\n'
            '2. Keep private paths in local config files, not in code.\n'
            '3. Treat destructive or high-risk actions as confirm-first.\n'
            '4. Add new buttons to the registry before wiring hardware.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  const _FooterCard({required this.configPath, required this.registryPath});

  final String configPath;
  final String registryPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Source files',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'Config', value: configPath),
          const SizedBox(height: 8),
          _InfoLine(label: 'Registry', value: registryPath),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColours.darkSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColours.darkMutedText,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.accent,
    this.compact = false,
  });

  final String label;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CommandDeckError extends StatelessWidget {
  const _CommandDeckError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _panelDecoration(highlighted: true),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColours.darkAmber),
              const SizedBox(height: 12),
              Text(
                'Command Deck could not load.',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration({bool highlighted = false}) {
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

Color _accentForGroup(String group) {
  final normalized = group.toLowerCase();
  if (normalized.contains('core')) {
    return AppColours.darkSecondary;
  }
  if (normalized.contains('project')) {
    return AppColours.darkSuccess;
  }
  if (normalized.contains('research')) {
    return AppColours.darkAmber;
  }
  if (normalized.contains('record')) {
    return AppColours.darkPurple;
  }
  return AppColours.darkPrimary;
}

Color _accentForType(CommandDeckCommandType type) {
  return switch (type) {
    CommandDeckCommandType.openUrl => AppColours.darkSecondary,
    CommandDeckCommandType.openFolder => AppColours.darkSuccess,
    CommandDeckCommandType.openRoute => AppColours.darkPrimary,
    CommandDeckCommandType.script => AppColours.darkAmber,
    CommandDeckCommandType.info => AppColours.darkPurple,
    CommandDeckCommandType.unknown => AppColours.darkMutedText,
  };
}

Color _cardTintForType(CommandDeckCommandType type) {
  return switch (type) {
    CommandDeckCommandType.openUrl => AppColours.darkSecondary,
    CommandDeckCommandType.openFolder => AppColours.darkSuccess,
    CommandDeckCommandType.openRoute => AppColours.darkPrimary,
    CommandDeckCommandType.script => AppColours.darkAmber,
    CommandDeckCommandType.info => AppColours.darkPurple,
    CommandDeckCommandType.unknown => AppColours.darkMutedText,
  };
}

IconData _iconForGroup(String group) {
  final normalized = group.toLowerCase();
  if (normalized.contains('core')) {
    return Icons.space_dashboard_outlined;
  }
  if (normalized.contains('project')) {
    return Icons.folder_open_outlined;
  }
  if (normalized.contains('research')) {
    return Icons.search_outlined;
  }
  if (normalized.contains('record')) {
    return Icons.fiber_manual_record_outlined;
  }
  return Icons.tune_outlined;
}

IconData _iconForType(CommandDeckCommandType type) {
  return switch (type) {
    CommandDeckCommandType.openUrl => Icons.public_outlined,
    CommandDeckCommandType.openFolder => Icons.folder_open_outlined,
    CommandDeckCommandType.openRoute => Icons.route_outlined,
    CommandDeckCommandType.script => Icons.terminal_outlined,
    CommandDeckCommandType.info => Icons.info_outline,
    CommandDeckCommandType.unknown => Icons.help_outline,
  };
}

String _groupDescription(String group) {
  final normalized = group.toLowerCase();
  if (normalized.contains('core')) {
    return 'High-frequency actions for starting the day and opening the most common build workflows.';
  }
  if (normalized.contains('project')) {
    return 'Shortcuts for switching into project repos or app pages without losing the local context.';
  }
  if (normalized.contains('research')) {
    return 'Quick jumps into dashboard areas for search, finance, and asset review.';
  }
  if (normalized.contains('record')) {
    return 'Support cards for the recording workflow and the configured OBS hotkeys.';
  }
  return 'Supporting setup files, local paths, and safety notes for the module pack.';
}

String _buttonLabel(CommandDeckCommand command, bool isAvailable) {
  if (!isAvailable) {
    return 'Needs config';
  }

  return switch (command.type) {
    CommandDeckCommandType.info => 'View setup',
    CommandDeckCommandType.openRoute => 'Open page',
    CommandDeckCommandType.openFolder => 'Open folder',
    CommandDeckCommandType.openUrl => 'Open link',
    CommandDeckCommandType.script => 'Run',
    CommandDeckCommandType.unknown => 'Unavailable',
  };
}

Widget _buildActionButton({
  required CommandDeckCommand command,
  required Color accent,
  required VoidCallback? onPressed,
  required bool isAvailable,
}) {
  final icon = switch (command.type) {
    CommandDeckCommandType.info => Icons.info_outline,
    CommandDeckCommandType.openFolder => Icons.folder_open_outlined,
    CommandDeckCommandType.openRoute => Icons.route_outlined,
    CommandDeckCommandType.openUrl => Icons.open_in_new_outlined,
    CommandDeckCommandType.script => Icons.play_arrow_rounded,
    CommandDeckCommandType.unknown => Icons.help_outline,
  };
  final label = _buttonLabel(command, isAvailable);

  if (command.type == CommandDeckCommandType.openRoute) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  if (command.type == CommandDeckCommandType.openFolder) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: AppColours.darkSuccess,
        backgroundColor: AppColours.darkSuccess.withValues(alpha: 0.16),
      ),
    );
  }

  if (command.type == CommandDeckCommandType.script) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: AppColours.darkAmber,
        backgroundColor: AppColours.darkAmber.withValues(alpha: 0.16),
      ),
    );
  }

  if (command.type == CommandDeckCommandType.info) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: AppColours.darkPurple,
        backgroundColor: AppColours.darkPurple.withValues(alpha: 0.16),
      ),
    );
  }

  return FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
  );
}

String _commandKindLabel(CommandDeckCommand command) {
  return switch (command.type) {
    CommandDeckCommandType.openRoute => 'Page',
    CommandDeckCommandType.openFolder => 'Folder',
    CommandDeckCommandType.openUrl => 'Link',
    CommandDeckCommandType.script => 'Script',
    CommandDeckCommandType.info => 'Info',
    CommandDeckCommandType.unknown => 'Other',
  };
}

String _commandSubtitle(CommandDeckCommand command, String? resolvedPath) {
  if ((command.description ?? '').isNotEmpty) {
    if (command.type == CommandDeckCommandType.info) {
      return command.description!;
    }
    return command.description!;
  }

  return switch (command.type) {
    CommandDeckCommandType.openRoute => 'Opens ${command.target}.',
    CommandDeckCommandType.openFolder =>
      resolvedPath == null
          ? 'Needs a configured local path.'
          : 'Opens the local folder at $resolvedPath.',
    CommandDeckCommandType.openUrl => 'Opens the configured local link.',
    CommandDeckCommandType.script =>
      resolvedPath == null
          ? 'Needs a script path.'
          : 'Runs the local helper script at $resolvedPath.',
    CommandDeckCommandType.info => 'Shows the local setup details.',
    CommandDeckCommandType.unknown => 'Command type is not supported yet.',
  };
}

String _displayTargetLabel(CommandDeckCommand command, String resolvedPath) {
  if (command.type == CommandDeckCommandType.script ||
      command.type == CommandDeckCommandType.openFolder) {
    return path.basename(resolvedPath);
  }

  return resolvedPath;
}

bool _isAvailable(CommandDeckCommand command, String? resolvedPath) {
  return switch (command.type) {
    CommandDeckCommandType.info => true,
    CommandDeckCommandType.openRoute => command.target.trim().isNotEmpty,
    CommandDeckCommandType.openUrl => command.target.trim().isNotEmpty,
    CommandDeckCommandType.openFolder =>
      resolvedPath != null &&
          (Directory(resolvedPath).existsSync() ||
              File(resolvedPath).existsSync()),
    CommandDeckCommandType.script =>
      resolvedPath != null && File(resolvedPath).existsSync(),
    CommandDeckCommandType.unknown => false,
  };
}

String? _resolvedTarget(CommandDeckCommand command, CommandDeckConfig config) {
  if (command.type == CommandDeckCommandType.openUrl) {
    return command.target;
  }

  if (command.type == CommandDeckCommandType.openRoute) {
    return command.target;
  }

  if (command.type == CommandDeckCommandType.script) {
    final target = command.target.trim();
    if (target.isEmpty) {
      return null;
    }
    final moduleRoot = CommandDeckService().moduleRootDirectory();
    return path.join(moduleRoot.path, target);
  }

  final key = command.targetKey?.trim() ?? command.target.trim();
  if (key.isEmpty) {
    return null;
  }

  final resolved = config.lookupPath(key);
  if (resolved != null && resolved.isNotEmpty) {
    return resolved;
  }

  final moduleRoot = CommandDeckService().moduleRootDirectory();
  final relativePath = path.join(moduleRoot.path, key);
  if (Directory(relativePath).existsSync() || File(relativePath).existsSync()) {
    return relativePath;
  }

  return null;
}
