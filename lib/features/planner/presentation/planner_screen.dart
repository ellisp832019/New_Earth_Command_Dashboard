import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../application/planner_controller.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayPlan = ref.watch(todayPlanProvider);
    final taskOptions = ref.watch(plannerTaskOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Planner')),
      body: todayPlan.when(
        data: (plan) => taskOptions.when(
          data: (tasks) => _PlannerView(
            key: ValueKey(plan.updatedAt),
            plan: plan,
            taskOptions: tasks,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Planner tasks could not be loaded. Please try again.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Today\'s plan could not be loaded. Please try again.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlannerView extends ConsumerStatefulWidget {
  const _PlannerView({
    super.key,
    required this.plan,
    required this.taskOptions,
  });

  final DailyPlan plan;
  final List<Task> taskOptions;

  @override
  ConsumerState<_PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends ConsumerState<_PlannerView> {
  late final TextEditingController _morningIntentionController;
  late final TextEditingController _mainFocusController;

  bool _isSavingMorningIntention = false;
  bool _isSavingMainFocus = false;
  bool _isSavingTopThree = false;
  late List<String> _selectedTopTaskIds;

  @override
  void initState() {
    super.initState();
    _morningIntentionController = TextEditingController(
      text: widget.plan.morningIntention ?? '',
    );
    _mainFocusController = TextEditingController(
      text: widget.plan.mainFocus ?? '',
    );
    _selectedTopTaskIds = _topTaskIdsFromPlan(widget.plan);
  }

  @override
  void didUpdateWidget(covariant _PlannerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.plan.morningIntention != widget.plan.morningIntention) {
      _morningIntentionController.text = widget.plan.morningIntention ?? '';
    }

    if (oldWidget.plan.mainFocus != widget.plan.mainFocus) {
      _mainFocusController.text = widget.plan.mainFocus ?? '';
    }

    final previousTopTaskIds = _topTaskIdsFromPlan(oldWidget.plan);
    final currentTopTaskIds = _topTaskIdsFromPlan(widget.plan);
    if (!_sameIds(previousTopTaskIds, currentTopTaskIds)) {
      _selectedTopTaskIds = currentTopTaskIds;
    }
  }

  @override
  void dispose() {
    _morningIntentionController.dispose();
    _mainFocusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = widget.plan;
    final formattedDate = DateFormat('EEEE d MMMM y').format(plan.date);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Plan', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(formattedDate, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _EditablePlannerCard(
          title: 'Morning Intention',
          fieldKey: const Key('plannerMorningIntentionField'),
          buttonKey: const Key('plannerMorningIntentionSaveButton'),
          controller: _morningIntentionController,
          hintText: 'Set a calm direction for the day.',
          buttonLabel: 'Save Morning Intention',
          isSaving: _isSavingMorningIntention,
          onSave: () => _saveMorningIntention(context),
        ),
        const SizedBox(height: 12),
        _EditablePlannerCard(
          title: 'Main Focus',
          fieldKey: const Key('plannerMainFocusField'),
          buttonKey: const Key('plannerMainFocusSaveButton'),
          controller: _mainFocusController,
          hintText: 'Choose the one build step that matters most.',
          buttonLabel: 'Save Main Focus',
          isSaving: _isSavingMainFocus,
          onSave: () => _saveMainFocus(context),
        ),
        const SizedBox(height: 12),
        _TopThreePlannerCard(
          title: 'Top 3 Tasks',
          tasks: widget.taskOptions,
          selectedTaskIds: _selectedTopTaskIds,
          isSaving: _isSavingTopThree,
          onTaskToggled: _toggleTopTask,
          onSave: () => _saveTopThree(context),
        ),
        const SizedBox(height: 12),
        _PlannerCard(
          title: 'Evening Review',
          body: plan.eveningReview ?? 'No evening review recorded yet.',
        ),
        const SizedBox(height: 12),
        _PlannerCard(
          title: 'Carry Forward',
          body:
              plan.carryForwardNotes ?? 'Nothing parked for carry forward yet.',
        ),
        const SizedBox(height: 12),
        _PlannerCard(
          title: 'Tomorrow\'s Focus',
          body: plan.tomorrowFocus ?? 'Tomorrow\'s likely focus is still open.',
        ),
      ],
    );
  }

  Future<void> _saveMorningIntention(BuildContext context) async {
    setState(() => _isSavingMorningIntention = true);

    try {
      await ref
          .read(plannerControllerProvider)
          .saveMorningIntention(_morningIntentionController.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Morning intention saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingMorningIntention = false);
      }
    }
  }

  Future<void> _saveMainFocus(BuildContext context) async {
    setState(() => _isSavingMainFocus = true);

    try {
      await ref
          .read(plannerControllerProvider)
          .saveMainFocus(_mainFocusController.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Main focus saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingMainFocus = false);
      }
    }
  }

  void _toggleTopTask(String taskId, bool isSelected) {
    if (isSelected) {
      setState(() {
        _selectedTopTaskIds = _selectedTopTaskIds
            .where((id) => id != taskId)
            .toList();
      });
      return;
    }

    if (_selectedTopTaskIds.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You already have 3 priority tasks for today. Complete, remove, or carry one forward first.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _selectedTopTaskIds = [..._selectedTopTaskIds, taskId];
    });
  }

  Future<void> _saveTopThree(BuildContext context) async {
    setState(() => _isSavingTopThree = true);

    try {
      await ref
          .read(plannerControllerProvider)
          .saveTopThreeTaskIds(_selectedTopTaskIds);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Top 3 tasks saved.')));
    } on StateError catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _isSavingTopThree = false);
      }
    }
  }

  List<String> _topTaskIdsFromPlan(DailyPlan plan) {
    return [
      plan.topTask1Id,
      plan.topTask2Id,
      plan.topTask3Id,
    ].whereType<String>().toList();
  }

  bool _sameIds(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }
}

class _EditablePlannerCard extends StatelessWidget {
  const _EditablePlannerCard({
    required this.title,
    required this.fieldKey,
    required this.buttonKey,
    required this.controller,
    required this.hintText,
    required this.buttonLabel,
    required this.isSaving,
    required this.onSave,
  });

  final String title;
  final Key fieldKey;
  final Key buttonKey;
  final TextEditingController controller;
  final String hintText;
  final String buttonLabel;
  final bool isSaving;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              key: fieldKey,
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: buttonKey,
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerCard extends StatelessWidget {
  const _PlannerCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _TopThreePlannerCard extends StatelessWidget {
  const _TopThreePlannerCard({
    required this.title,
    required this.tasks,
    required this.selectedTaskIds,
    required this.isSaving,
    required this.onTaskToggled,
    required this.onSave,
  });

  final String title;
  final List<Task> tasks;
  final List<String> selectedTaskIds;
  final bool isSaving;
  final void Function(String taskId, bool isSelected) onTaskToggled;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '${selectedTaskIds.length} of 3 selected',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Text(
                'No open tasks are ready for today\'s priorities yet.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...tasks.map((task) {
                final isSelected = selectedTaskIds.contains(task.taskId);
                return CheckboxListTile(
                  key: Key('plannerTopTask-${task.taskId}'),
                  value: isSelected,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(task.title),
                  subtitle: Text(task.status),
                  onChanged: (_) => onTaskToggled(task.taskId, isSelected),
                );
              }),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: const Key('plannerTopThreeSaveButton'),
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.filter_3_outlined),
                label: const Text('Save Top 3 Tasks'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
