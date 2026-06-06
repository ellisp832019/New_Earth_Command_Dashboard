import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../data/command_deck_service.dart';

class CommandDeckScreen extends StatefulWidget {
  const CommandDeckScreen({super.key});

  @override
  State<CommandDeckScreen> createState() => _CommandDeckScreenState();
}

class _CommandDeckScreenState extends State<CommandDeckScreen> {
  late final CommandDeckService _service;
  late Future<CommandDeckWorkspace> _workspaceFuture;

  static const _moduleFolders = [
    _FolderCard(
      title: 'Docs',
      subtitle: 'FSD, overview notes, integration guidance, and future plans.',
      path: 'modules/new_earth_command_deck/docs',
      icon: Icons.description_outlined,
      accent: AppColours.darkSecondary,
    ),
    _FolderCard(
      title: 'Hardware',
      subtitle: 'ESP32-S3 spec and firmware pseudocode kept with the pack.',
      path: 'modules/new_earth_command_deck/hardware',
      icon: Icons.memory_outlined,
      accent: AppColours.darkAmber,
    ),
    _FolderCard(
      title: 'Scripts',
      subtitle: 'Meeting, build session, Codex handoff, and registry checks.',
      path: 'modules/new_earth_command_deck/scripts',
      icon: Icons.play_circle_outline,
      accent: AppColours.darkSuccess,
    ),
    _FolderCard(
      title: 'Stream Deck',
      subtitle: 'Layout, button map, and profile planning stay local here.',
      path: 'modules/new_earth_command_deck/stream_deck',
      icon: Icons.gamepad_outlined,
      accent: AppColours.darkPurple,
    ),
    _FolderCard(
      title: 'Templates',
      subtitle: 'Meeting and build templates for repeatable operations.',
      path: 'modules/new_earth_command_deck/templates',
      icon: Icons.receipt_long_outlined,
      accent: AppColours.darkPrimary,
    ),
  ];

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
    final resolvedPath = _service.resolveTarget(command, workspace.config);
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

    if (command.type != CommandDeckCommandType.openUrl &&
        (resolvedPath == null || resolvedPath.isEmpty)) {
      _showSnackBar(
        'Command target could not be resolved from the local config.',
      );
      return;
    }

    try {
      await _service.executeCommand(command, workspace.config);
      if (!mounted) {
        return;
      }

      final status = switch (command.type) {
        CommandDeckCommandType.openUrl => 'Opened ${command.label}.',
        CommandDeckCommandType.openFolder =>
          'Opened ${command.label} in the file explorer.',
        CommandDeckCommandType.script => 'Ran ${command.label}.',
        CommandDeckCommandType.unknown => 'Ran ${command.label}.',
      };
      _showSnackBar(status);
      _reloadWorkspace();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Command failed: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
            final commands = workspace.registry.commands;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: _panelDecoration(highlighted: true),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 980;

                      final header = Column(
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
                            'Local-first control centre for Stream Deck workflows, scripts, and mission shortcuts.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColours.darkText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: Text(
                              'The support docs, hardware plans, Stream Deck profiles, and scripts stay inside modules/new_earth_command_deck/ so the module remains self-contained.',
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
                              _Pill(
                                label: 'Software-only first',
                                accent: AppColours.darkSecondary,
                              ),
                              _Pill(
                                label: 'Local-first',
                                accent: AppColours.darkSuccess,
                              ),
                              _Pill(
                                label: 'Safety confirmations',
                                accent: AppColours.darkAmber,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Registry: ${workspace.registryPath}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColours.darkMutedText,
                            ),
                          ),
                          Text(
                            'Config: ${workspace.configPath}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColours.darkMutedText,
                            ),
                          ),
                        ],
                      );

                      final actions = Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: isWide
                            ? WrapAlignment.end
                            : WrapAlignment.start,
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                context.push(RouteNames.meetingDashboard),
                            icon: const Icon(Icons.event_note_outlined),
                            label: const Text('Meeting System'),
                          ),
                          TextButton.icon(
                            onPressed: () => context.push(RouteNames.launchpad),
                            icon: const Icon(Icons.campaign_outlined),
                            label: const Text('Launchpad'),
                          ),
                          TextButton.icon(
                            onPressed: () => context.push(RouteNames.more),
                            icon: const Icon(Icons.apps_outlined),
                            label: const Text('Back to More'),
                          ),
                        ],
                      );

                      if (!isWide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header,
                            const SizedBox(height: 18),
                            actions,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: header),
                          const SizedBox(width: 20),
                          SizedBox(width: 320, child: actions),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 1100
                        ? 3
                        : constraints.maxWidth >= 760
                        ? 2
                        : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commands.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: crossAxisCount == 1 ? 2.6 : 2.2,
                      ),
                      itemBuilder: (context, index) {
                        final command = commands[index];
                        final resolvedPath = _service.resolveTarget(
                          command,
                          workspace.config,
                        );
                        final pathExists =
                            resolvedPath != null &&
                            (Directory(resolvedPath).existsSync() ||
                                File(resolvedPath).existsSync());
                        final isUnavailable =
                            command.type == CommandDeckCommandType.openFolder
                            ? !pathExists
                            : command.type != CommandDeckCommandType.openUrl &&
                                  (resolvedPath == null ||
                                      resolvedPath.isEmpty);

                        return _CommandCard(
                          command: command,
                          resolvedPath: resolvedPath,
                          unavailable: isUnavailable,
                          onPressed: isUnavailable
                              ? null
                              : () => _runCommand(workspace, command),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 1100
                        ? 3
                        : constraints.maxWidth >= 760
                        ? 2
                        : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _moduleFolders.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: crossAxisCount == 1 ? 2.8 : 2.2,
                      ),
                      itemBuilder: (context, index) {
                        final folder = _moduleFolders[index];
                        return _FolderCardView(card: folder);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _panelDecoration(),
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
                            'TODOs for later work',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColours.darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...const [
                        'TODO: add persistent action logs and a visible command history.',
                        'TODO: add safety confirmations for destructive or high-risk commands.',
                        'TODO: connect meeting and build session creation to local file services.',
                        'TODO: wire the future hardware bridge after the software-only flow is stable.',
                      ].map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            item,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColours.darkMutedText,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _panelDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended file layout',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColours.darkText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Keep every Command Deck support file inside the module pack rather than moving it into assets, docs, tools, or the repo root.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkMutedText,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'modules/new_earth_command_deck/{docs,hardware,scripts,stream_deck,templates,omega_os}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColours.darkSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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

class _CommandCard extends StatelessWidget {
  const _CommandCard({
    required this.command,
    required this.resolvedPath,
    required this.unavailable,
    required this.onPressed,
  });

  final CommandDeckCommand command;
  final String? resolvedPath;
  final bool unavailable;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = switch (command.type) {
      CommandDeckCommandType.openUrl => AppColours.darkSecondary,
      CommandDeckCommandType.openFolder => AppColours.darkSuccess,
      CommandDeckCommandType.script => AppColours.darkAmber,
      CommandDeckCommandType.unknown => AppColours.darkPurple,
    };
    final hasResolvedPath = resolvedPath?.isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForType(command.type), color: accent),
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
            unavailable
                ? 'TODO: configure this local target path in command_deck.json.'
                : command.type == CommandDeckCommandType.script
                ? 'Runs the local helper script stored in the module pack.'
                : command.type == CommandDeckCommandType.openFolder
                ? 'Opens the local folder resolved from config.'
                : 'Opens the configured local dashboard URL.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const Spacer(),
          if (hasResolvedPath) ...[
            Text(
              resolvedPath!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(unavailable ? 'Needs config' : 'Run'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(CommandDeckCommandType type) {
    return switch (type) {
      CommandDeckCommandType.openUrl => Icons.public_outlined,
      CommandDeckCommandType.openFolder => Icons.folder_open_outlined,
      CommandDeckCommandType.script => Icons.terminal_outlined,
      CommandDeckCommandType.unknown => Icons.help_outline,
    };
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

class _FolderCard {
  const _FolderCard({
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
}

class _FolderCardView extends StatelessWidget {
  const _FolderCardView({required this.card});

  final _FolderCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(card.icon, color: card.accent),
          const SizedBox(height: 12),
          Text(
            card.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 8),
          Text(
            card.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            card.path,
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
