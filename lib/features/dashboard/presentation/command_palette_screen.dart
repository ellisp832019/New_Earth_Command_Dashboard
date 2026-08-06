import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../../command_deck/data/command_deck_service.dart';
import '../application/dashboard_controller.dart';
import '../../projects/application/projects_controller.dart';
import '../../tasks/application/tasks_controller.dart';

class CommandPaletteScreen extends ConsumerStatefulWidget {
  const CommandPaletteScreen({super.key});

  @override
  ConsumerState<CommandPaletteScreen> createState() =>
      _CommandPaletteScreenState();
}

class _CommandPaletteScreenState extends ConsumerState<CommandPaletteScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openRecentAction(CommandDeckActionLogEntry entry) async {
    final normalizedType = entry.type.toLowerCase().replaceAll('_', '');
    final target = entry.resolvedTarget.trim().isNotEmpty
        ? entry.resolvedTarget.trim()
        : entry.target.trim();

    if (target.isEmpty) {
      _showSnackBar('No destination was recorded for this action.');
      return;
    }

    try {
      switch (normalizedType) {
        case 'openroute':
          context.push(target);
          return;
        case 'openurl':
          await _openUrl(target);
          break;
        case 'openfolder':
          await _openFolder(target);
          break;
        default:
          _showSnackBar('That recent action cannot be reopened directly.');
          return;
      }

      _showSnackBar('Reopened ${entry.label}.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar('Could not reopen ${entry.label}: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final recentActions = ref.watch(commandPaletteRecentActionsProvider);
    final query = _searchController.text.trim().toLowerCase();

    final projects = projectsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <Project>[],
    );
    final tasks = tasksAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <Task>[],
    );
    final projectNamesById = <String, String>{
      for (final project in projects) project.projectId: project.name,
    };
    final entries = _buildEntries(
      context,
      query: query,
      projects: projects,
      tasks: tasks,
      projectNamesById: projectNamesById,
    );
    final groupedEntries = _groupEntries(entries);

    return WorkspaceShell(
      title: 'Command Palette',
      subtitle: 'Search pages, projects, tasks, and actions',
      onBack: () => context.pop(),
      trailingActions: [
        TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
          label: const Text('Close'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jump anywhere in the dashboard.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search pages, projects, tasks, and calm create actions from one place.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('commandPaletteSearchField'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search pages, projects, tasks, and actions',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            key: const Key('clearCommandPaletteSearchButton'),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _PaletteHintChip(label: 'Pages'),
                    _PaletteHintChip(label: 'Projects'),
                    _PaletteHintChip(label: 'Tasks'),
                    _PaletteHintChip(label: 'Create'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (query.isEmpty)
            _RecentActionsCard(
              recentActions: recentActions,
              onOpenCommandDeck: () => context.go(RouteNames.commandDeck),
              onOpenAction: _openRecentAction,
            ),
          if (query.isEmpty) const SizedBox(height: 18),
          if (groupedEntries.isEmpty)
            _PaletteEmptyState(query: query)
          else
            ...groupedEntries.entries.expand((entry) {
              return [
                _PaletteGroupCard(title: entry.key, entries: entry.value),
                const SizedBox(height: 14),
              ];
            }),
        ],
      ),
    );
  }

  List<_CommandPaletteEntry> _buildEntries(
    BuildContext context, {
    required String query,
    required List<Project> projects,
    required List<Task> tasks,
    required Map<String, String> projectNamesById,
  }) {
    final staticEntries = <_CommandPaletteEntry>[
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Dashboard',
        description: 'Open the main dashboard.',
        searchText: 'dashboard home today focus',
        icon: Icons.dashboard_outlined,
        onTap: () => context.go(RouteNames.dashboard),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Projects Hub',
        description: 'Open the project intelligence hub.',
        searchText: 'projects hub intelligence workspace projects',
        icon: Icons.folder_outlined,
        onTap: () => context.go(RouteNames.projectsIntelligence),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Projects Workspace',
        description: 'Open the editable projects workspace.',
        searchText: 'projects workspace edit list',
        icon: Icons.view_agenda_outlined,
        onTap: () => context.go(RouteNames.projectsWorkspace),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Tasks',
        description: 'Open the task board.',
        searchText: 'tasks task board inbox today planned',
        icon: Icons.checklist_outlined,
        onTap: () => context.go(RouteNames.tasks),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Planner',
        description: 'Open the daily planner.',
        searchText: 'planner day review carry forward',
        icon: Icons.today_outlined,
        onTap: () => context.go(RouteNames.planner),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Assets',
        description: 'Open the asset intelligence home.',
        searchText: 'assets inventory qr labels evidence parts equipment',
        icon: Icons.inventory_2_outlined,
        onTap: () => context.go(RouteNames.assets),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Treasury',
        description: 'Open financial planning and decisions.',
        searchText: 'treasury budget decisions money',
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => context.go(RouteNames.treasury),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Voice Intelligence',
        description:
            'Open the new voice module with notes, meetings, and MicroGrow status.',
        searchText:
            'voice intelligence voice assistant speech wizard notes meetings microgrow',
        icon: Icons.mic_outlined,
        onTap: () => context.go(RouteNames.voice),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Systems',
        description: 'Open recovery and protection tools.',
        searchText: 'systems backup guardian health recovery',
        icon: Icons.security_outlined,
        onTap: () => context.go(RouteNames.systems),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Backup Guardian',
        description: 'Open the backup workflow.',
        searchText: 'backup guardian restore drive external',
        icon: Icons.backup_outlined,
        onTap: () => context.push(RouteNames.backupGuardian),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Knowledge Library',
        description: 'Open search and manifests for the knowledge vault.',
        searchText: 'knowledge library search pdf manifest',
        icon: Icons.local_library_outlined,
        onTap: () => context.go(RouteNames.knowledgeLibrary),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'More',
        description: 'Open the utility hub.',
        searchText: 'more utilities settings command deck meeting',
        icon: Icons.apps_outlined,
        onTap: () => context.go(RouteNames.more),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Journal',
        description: 'Open the journal entry stream.',
        searchText: 'journal notes entries',
        icon: Icons.menu_book_outlined,
        onTap: () => context.go(RouteNames.journal),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Learning',
        description: 'Open learning notes and progress.',
        searchText: 'learning study skill notes',
        icon: Icons.school_outlined,
        onTap: () => context.go(RouteNames.learning),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Content',
        description: 'Open content planning and drafts.',
        searchText: 'content planner draft publish',
        icon: Icons.campaign_outlined,
        onTap: () => context.go(RouteNames.content),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Business',
        description: 'Open business opportunities and follow-up.',
        searchText: 'business opportunity pipeline',
        icon: Icons.handshake_outlined,
        onTap: () => context.go(RouteNames.business),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Wellbeing',
        description: 'Open the wellbeing check-in space.',
        searchText: 'wellbeing energy mood check in',
        icon: Icons.favorite_border,
        onTap: () => context.go(RouteNames.wellbeing),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Inbox',
        description: 'Open the quick capture inbox.',
        searchText: 'inbox quick capture notes',
        icon: Icons.inbox_outlined,
        onTap: () => context.go(RouteNames.inbox),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'Command Deck',
        description: 'Open the virtual command surface.',
        searchText: 'command deck stream deck quick actions',
        icon: Icons.space_dashboard_outlined,
        onTap: () => context.go(RouteNames.commandDeck),
      ),
      _CommandPaletteEntry(
        group: 'Navigate',
        kind: 'Page',
        title: 'QR Studio',
        description: 'Open label generation and printing.',
        searchText: 'qr studio labels print queue history',
        icon: Icons.print_outlined,
        onTap: () => context.go(RouteNames.assetQrLabelStudio),
      ),
      _CommandPaletteEntry(
        group: 'Create',
        kind: 'Create',
        title: 'New Project',
        description: 'Open the project form.',
        searchText: 'new project create project',
        icon: Icons.create_new_folder_outlined,
        onTap: () => context.go(RouteNames.newProject),
      ),
      _CommandPaletteEntry(
        group: 'Create',
        kind: 'Create',
        title: 'New Task',
        description: 'Open the task form.',
        searchText: 'new task create task',
        icon: Icons.add_task_outlined,
        onTap: () => context.go(RouteNames.newTask),
      ),
      _CommandPaletteEntry(
        group: 'Create',
        kind: 'Create',
        title: 'New Journal Entry',
        description: 'Open the journal form.',
        searchText: 'new journal create journal entry',
        icon: Icons.note_add_outlined,
        onTap: () => context.go(RouteNames.newJournal),
      ),
      _CommandPaletteEntry(
        group: 'Create',
        kind: 'Create',
        title: 'New Learning Item',
        description: 'Open the learning form.',
        searchText: 'new learning create learning',
        icon: Icons.school_outlined,
        onTap: () => context.go(RouteNames.newLearning),
      ),
      _CommandPaletteEntry(
        group: 'Create',
        kind: 'Create',
        title: 'New Content Item',
        description: 'Open the content form.',
        searchText: 'new content create content',
        icon: Icons.article_outlined,
        onTap: () => context.go(RouteNames.newContent),
      ),
      _CommandPaletteEntry(
        group: 'Create',
        kind: 'Create',
        title: 'New Business Opportunity',
        description: 'Open the business form.',
        searchText: 'new business create opportunity',
        icon: Icons.work_outline,
        onTap: () => context.go(RouteNames.newBusiness),
      ),
      _CommandPaletteEntry(
        group: 'Create',
        kind: 'Create',
        title: 'New Meeting',
        description: 'Open the meeting wizard.',
        searchText: 'new meeting create meeting',
        icon: Icons.meeting_room_outlined,
        onTap: () => context.go(RouteNames.meetingNew),
      ),
      _CommandPaletteEntry(
        group: 'Create',
        kind: 'Create',
        title: 'Quick Capture',
        description: 'Capture a note into the inbox.',
        searchText: 'quick capture inbox note',
        icon: Icons.bolt_outlined,
        onTap: () => context.go(RouteNames.assetQuickCapture),
      ),
    ];

    final projectEntries = projects.map((project) {
      final searchParts = <String>[
        project.name,
        project.shortDescription ?? '',
        project.currentMilestone ?? '',
        project.nextAction ?? '',
        project.status,
        project.priority,
      ];

      return _CommandPaletteEntry(
        group: 'Projects',
        kind: 'Project',
        title: project.name,
        description: [
          if (project.shortDescription?.isNotEmpty == true)
            project.shortDescription!,
          'Status: ${project.status} • Priority: ${project.priority}',
        ].join('\n'),
        searchText: searchParts.join(' ').toLowerCase(),
        icon: Icons.folder_outlined,
        onTap: () => context.push(RouteNames.projectDetail(project.projectId)),
      );
    }).toList();

    final taskEntries = tasks.map((task) {
      final projectName = projectNamesById[task.projectId];
      final searchParts = <String>[
        task.title,
        task.description ?? '',
        task.category ?? '',
        task.status,
        task.priority,
        task.notes ?? '',
        projectName ?? '',
      ];

      return _CommandPaletteEntry(
        group: 'Tasks',
        kind: 'Task',
        title: task.title,
        description: [
          if (projectName?.isNotEmpty == true) 'Project: $projectName',
          'Status: ${task.status} • Priority: ${task.priority}',
        ].join('\n'),
        searchText: searchParts.join(' ').toLowerCase(),
        icon: Icons.checklist_outlined,
        onTap: () => context.push(RouteNames.editTask(task.taskId)),
      );
    }).toList();

    final allEntries = [...staticEntries, ...projectEntries, ...taskEntries];

    if (query.isEmpty) {
      return allEntries;
    }

    return allEntries
        .where((entry) => entry.searchText.contains(query))
        .toList(growable: false);
  }

  Map<String, List<_CommandPaletteEntry>> _groupEntries(
    List<_CommandPaletteEntry> entries,
  ) {
    const groupOrder = ['Navigate', 'Projects', 'Tasks', 'Create'];
    final grouped = <String, List<_CommandPaletteEntry>>{};

    for (final entry in entries) {
      grouped
          .putIfAbsent(entry.group, () => <_CommandPaletteEntry>[])
          .add(entry);
    }

    final ordered = <String, List<_CommandPaletteEntry>>{};
    for (final group in groupOrder) {
      final groupEntries = grouped[group];
      if (groupEntries != null && groupEntries.isNotEmpty) {
        ordered[group] = groupEntries;
      }
    }
    return ordered;
  }
}

class _CommandPaletteEntry {
  const _CommandPaletteEntry({
    required this.group,
    required this.kind,
    required this.title,
    required this.description,
    required this.searchText,
    required this.icon,
    required this.onTap,
  });

  final String group;
  final String kind;
  final String title;
  final String description;
  final String searchText;
  final IconData icon;
  final VoidCallback onTap;
}

class _PaletteGroupCard extends StatelessWidget {
  const _PaletteGroupCard({required this.title, required this.entries});

  final String title;
  final List<_CommandPaletteEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleEntries = entries.take(_visibleEntryCount(title)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...visibleEntries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaletteEntryTile(entry: entry),
            ),
          ),
        ],
      ),
    );
  }

  int _visibleEntryCount(String group) {
    switch (group) {
      case 'Navigate':
        return 10;
      case 'Projects':
      case 'Tasks':
        return 6;
      case 'Create':
        return 8;
      default:
        return 8;
    }
  }
}

class _PaletteEntryTile extends StatelessWidget {
  const _PaletteEntryTile({required this.entry});

  final _CommandPaletteEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColours.darkSurface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key('commandPaletteEntry-${entry.title}'),
        borderRadius: BorderRadius.circular(16),
        onTap: entry.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColours.darkSurfaceRaised.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColours.darkOutline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    entry.icon,
                    color: AppColours.darkSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColours.darkText,
                            ),
                          ),
                        ),
                        _PaletteBadge(label: entry.kind),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteBadge extends StatelessWidget {
  const _PaletteBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColours.darkSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PaletteHintChip extends StatelessWidget {
  const _PaletteHintChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColours.darkSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PaletteEmptyState extends StatelessWidget {
  const _PaletteEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Text(
        query.isEmpty
            ? 'Type to search for pages, projects, tasks, or create actions.'
            : 'No matches found. Try a different page, project, or task name.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
      ),
    );
  }
}

class _RecentActionsCard extends StatelessWidget {
  const _RecentActionsCard({
    required this.recentActions,
    required this.onOpenCommandDeck,
    required this.onOpenAction,
  });

  final List<CommandDeckActionLogEntry> recentActions;
  final VoidCallback onOpenCommandDeck;
  final Future<void> Function(CommandDeckActionLogEntry entry) onOpenAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onOpenCommandDeck,
                icon: const Icon(Icons.space_dashboard_outlined),
                label: const Text('Open Command Deck'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            recentActions.isEmpty
                ? 'No commands have been logged yet.'
                : 'The latest commands you ran in the Command Deck.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          if (recentActions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: recentActions
                  .map((entry) {
                    return _RecentActionChip(
                      entry: entry,
                      onTap: () => onOpenAction(entry),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentActionChip extends StatelessWidget {
  const _RecentActionChip({required this.entry, required this.onTap});

  final CommandDeckActionLogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: Key('recentActionChip-${entry.commandId}'),
      color: AppColours.darkSurfaceRaised.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColours.darkOutline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.group} • ${_recentActionTypeLabel(entry.type)} • ${entry.timestampLabel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _recentActionTypeLabel(String type) {
  switch (type.toLowerCase().replaceAll('_', '')) {
    case 'openroute':
      return 'Page';
    case 'openurl':
      return 'Link';
    case 'openfolder':
      return 'Folder';
    case 'script':
      return 'Script';
    case 'info':
      return 'Info';
    default:
      return 'Action';
  }
}

Future<void> _openUrl(String url) async {
  if (url.trim().isEmpty) {
    return;
  }

  if (Platform.isWindows) {
    await Process.start('cmd.exe', ['/c', 'start', '', url], runInShell: true);
    return;
  }

  if (Platform.isMacOS) {
    await Process.start('open', [url], runInShell: true);
    return;
  }

  await Process.start('xdg-open', [url], runInShell: true);
}

Future<void> _openFolder(String folderPath) async {
  final normalizedPath = folderPath.trim();
  if (normalizedPath.isEmpty) {
    return;
  }

  if (Platform.isWindows) {
    await Process.start('explorer.exe', [normalizedPath]);
    return;
  }

  if (Platform.isMacOS) {
    await Process.start('open', [normalizedPath], runInShell: true);
    return;
  }

  await Process.start('xdg-open', [normalizedPath], runInShell: true);
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.14),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
