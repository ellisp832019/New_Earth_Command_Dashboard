import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../planner/application/planner_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../application/dashboard_controller.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = DateFormat('EEEE d MMMM y').format(DateTime.now());
    final snapshot = ref.watch(dashboardSnapshotProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('New Earth Command Dashboard'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(74),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      'What moves the mission forward today?',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        snapshot.when(
          data: (data) => _DashboardCardList(snapshot: data),
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => SliverFillRemaining(
            hasScrollBody: false,
            child: _DashboardError(error: error),
          ),
        ),
      ],
    );
  }
}

class _DashboardCardList extends StatelessWidget {
  const _DashboardCardList({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DashboardCardData(
        title: 'Today\'s Focus',
        description: null,
        icon: Icons.flag_outlined,
        mainFocus: snapshot.mainFocus,
        morningIntention: snapshot.morningIntention,
      ),
      _DashboardCardData(
        title: 'Top 3 Tasks',
        description: snapshot.topTaskTitles.isEmpty
            ? 'No Top 3 tasks selected yet.'
            : null,
        icon: Icons.filter_3_outlined,
        topTasks: snapshot.topTasks,
      ),
      _DashboardCardData(
        title: 'Active Projects',
        description: '${snapshot.activeProjectCount} projects are available.',
        icon: Icons.folder_copy_outlined,
      ),
      const _DashboardCardData(
        title: 'Learning Focus',
        description: 'Track the skill that supports today\'s build.',
        icon: Icons.school_outlined,
      ),
      const _DashboardCardData(
        title: 'Content Focus',
        description: 'Turn progress into public awareness.',
        icon: Icons.campaign_outlined,
      ),
      const _DashboardCardData(
        title: 'Business Reminder',
        description: 'Keep funding and opportunity actions visible.',
        icon: Icons.handshake_outlined,
      ),
      const _DashboardCardData(
        title: 'Wellbeing',
        description: 'Build New Earth without burning out.',
        icon: Icons.self_improvement_outlined,
      ),
      const _DashboardCardData(
        title: 'Quick Capture',
        description: 'Capture a task, idea, note, or content seed.',
        icon: Icons.add_circle_outline,
      ),
      const _DashboardCardData(
        title: 'Evening Review',
        description: 'Record what moved forward before the day ends.',
        icon: Icons.nightlight_round,
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList.separated(
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          if (card.title == 'Today\'s Focus') {
            return _DashboardFocusCard(
              title: card.title,
              icon: card.icon,
              mainFocus: card.mainFocus,
              morningIntention: card.morningIntention,
            );
          }

          return _DashboardCard(
            title: card.title,
            description: card.description,
            icon: card.icon,
            topTasks: card.topTasks,
          );
        },
      ),
    );
  }
}

class _DashboardCardData {
  const _DashboardCardData({
    required this.title,
    required this.description,
    required this.icon,
    this.topTasks = const [],
    this.mainFocus,
    this.morningIntention,
  });

  final String title;
  final String? description;
  final IconData icon;
  final List<DashboardTopTask> topTasks;
  final String? mainFocus;
  final String? morningIntention;
}

class _DashboardFocusCard extends ConsumerStatefulWidget {
  const _DashboardFocusCard({
    required this.title,
    required this.icon,
    required this.mainFocus,
    required this.morningIntention,
  });

  final String title;
  final IconData icon;
  final String? mainFocus;
  final String? morningIntention;

  @override
  ConsumerState<_DashboardFocusCard> createState() =>
      _DashboardFocusCardState();
}

class _DashboardFocusCardState extends ConsumerState<_DashboardFocusCard> {
  late final TextEditingController _mainFocusController;
  late final TextEditingController _morningIntentionController;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mainFocusController = TextEditingController(text: widget.mainFocus ?? '');
    _morningIntentionController = TextEditingController(
      text: widget.morningIntention ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _DashboardFocusCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mainFocus != widget.mainFocus) {
      _mainFocusController.text = widget.mainFocus ?? '';
    }

    if (oldWidget.morningIntention != widget.morningIntention) {
      _morningIntentionController.text = widget.morningIntention ?? '';
    }
  }

  @override
  void dispose() {
    _mainFocusController.dispose();
    _morningIntentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFocus = widget.mainFocus?.isNotEmpty == true;
    final hasIntention = widget.morningIntention?.isNotEmpty == true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        key: const Key('dashboardFocusEditButton'),
                        onPressed: _isSaving
                            ? null
                            : () {
                                setState(() {
                                  _isEditing = !_isEditing;
                                  if (!_isEditing) {
                                    _mainFocusController.text =
                                        widget.mainFocus ?? '';
                                    _morningIntentionController.text =
                                        widget.morningIntention ?? '';
                                  }
                                });
                              },
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit_outlined,
                        ),
                        label: Text(_isEditing ? 'Close' : 'Quick Edit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_isEditing) ...[
                    TextField(
                      key: const Key('dashboardMainFocusField'),
                      controller: _mainFocusController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Main Focus',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('dashboardMorningIntentionField'),
                      controller: _morningIntentionController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Morning Intention',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('dashboardFocusSaveButton'),
                      onPressed: _isSaving ? null : () => _save(context),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save Focus'),
                    ),
                  ] else ...[
                    Text(
                      hasFocus
                          ? widget.mainFocus!
                          : 'A blank daily plan is ready for today.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text('Morning Intention', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      hasIntention
                          ? widget.morningIntention!
                          : 'No morning intention set yet.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _isSaving = true);

    try {
      final plannerController = ref.read(plannerControllerProvider);
      await plannerController.saveMainFocus(_mainFocusController.text);
      await plannerController.saveMorningIntention(
        _morningIntentionController.text,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Today\'s focus saved.')));
      setState(() => _isEditing = false);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _DashboardCard extends ConsumerWidget {
  const _DashboardCard({
    required this.title,
    required this.description,
    required this.icon,
    this.topTasks = const [],
  });

  final String title;
  final String? description;
  final IconData icon;
  final List<DashboardTopTask> topTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  if (topTasks.isEmpty)
                    Text(description ?? '', style: theme.textTheme.bodyMedium)
                  else
                    Column(
                      children: topTasks.map((task) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _DashboardTopTaskRow(
                            task: task,
                            onMarkDone: () async {
                              await ref
                                  .read(tasksControllerProvider)
                                  .markTaskDone(task.taskId);
                            },
                            onRemove: () async {
                              await ref
                                  .read(tasksControllerProvider)
                                  .removeFromTopThree(task.taskId);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTopTaskRow extends StatelessWidget {
  const _DashboardTopTaskRow({
    required this.task,
    required this.onMarkDone,
    required this.onRemove,
  });

  final DashboardTopTask task;
  final Future<void> Function() onMarkDone;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          key: Key('dashboardTopTaskDone-${task.taskId}'),
          onPressed: onMarkDone,
          icon: const Icon(Icons.check_box_outline_blank),
          tooltip: 'Mark done',
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                [
                  if (task.projectName != null) task.projectName!,
                  'Priority: ${task.priority}',
                  'Status: ${task.status}',
                ].join('   '),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          key: Key('dashboardTopTaskRemove-${task.taskId}'),
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline),
          tooltip: 'Remove from Top 3',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Dashboard could not be loaded. Please try again.',
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
