import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../../widgets/calm_guidance_card.dart';
import '../application/planner_controller.dart';
import '../../tasks/application/tasks_controller.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key, this.initialSection});

  final String? initialSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayPlan = ref.watch(todayPlanProvider);
    final taskOptions = ref.watch(plannerTaskOptionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Daily Planner'),
        actions: [
          IconButton(
            tooltip: 'Open Tasks',
            onPressed: () => context.push(RouteNames.tasks),
            icon: const Icon(Icons.task_alt_outlined),
          ),
          IconButton(
            tooltip: 'Back to Dashboard',
            onPressed: () => context.push(RouteNames.dashboard),
            icon: const Icon(Icons.dashboard_outlined),
          ),
        ],
      ),
      body: todayPlan.when(
        data: (plan) => taskOptions.when(
          data: (tasks) => _PlannerView(
            key: ValueKey(plan.updatedAt),
            plan: plan,
            taskOptions: tasks,
            initialSection: initialSection,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Planner tasks could not be loaded. Try again in a moment.',
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
              'Today\'s plan could not be loaded. Try again in a moment.',
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
    this.initialSection,
  });

  final DailyPlan plan;
  final List<Task> taskOptions;
  final String? initialSection;

  @override
  ConsumerState<_PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends ConsumerState<_PlannerView> {
  late final TextEditingController _morningIntentionController;
  late final TextEditingController _mainFocusController;
  late final TextEditingController _focusReasonController;
  late final TextEditingController _carryForwardController;
  late final TextEditingController _tomorrowFocusController;
  late final TextEditingController _movedForwardController;
  late final TextEditingController _completedController;
  late final TextEditingController _learnedController;
  late final TextEditingController _blockersController;
  late final ScrollController _scrollController;
  final GlobalKey _eveningReviewKey = GlobalKey();
  final GlobalKey _carryForwardKey = GlobalKey();

  bool _isSavingMorningIntention = false;
  bool _isSavingMainFocus = false;
  bool _isSavingFocusReason = false;
  bool _isSavingCarryForward = false;
  bool _isSavingTomorrowFocus = false;
  bool _isSavingEveningReview = false;
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
    _focusReasonController = TextEditingController(
      text: widget.plan.focusReason ?? '',
    );
    _carryForwardController = TextEditingController(
      text: widget.plan.carryForwardNotes ?? '',
    );
    _tomorrowFocusController = TextEditingController(
      text: widget.plan.tomorrowFocus ?? '',
    );
    _movedForwardController = TextEditingController(
      text: widget.plan.whatMovedForward ?? '',
    );
    _completedController = TextEditingController(
      text: widget.plan.whatWasCompleted ?? '',
    );
    _learnedController = TextEditingController(
      text: widget.plan.whatWasLearned ?? '',
    );
    _blockersController = TextEditingController(
      text: widget.plan.blockers ?? '',
    );
    _scrollController = ScrollController();
    _selectedTopTaskIds = _topTaskIdsFromPlan(widget.plan);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToInitialSectionIfNeeded();
    });
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

    if (oldWidget.plan.focusReason != widget.plan.focusReason) {
      _focusReasonController.text = widget.plan.focusReason ?? '';
    }

    if (oldWidget.plan.carryForwardNotes != widget.plan.carryForwardNotes) {
      _carryForwardController.text = widget.plan.carryForwardNotes ?? '';
    }

    if (oldWidget.plan.tomorrowFocus != widget.plan.tomorrowFocus) {
      _tomorrowFocusController.text = widget.plan.tomorrowFocus ?? '';
    }

    if (oldWidget.plan.whatMovedForward != widget.plan.whatMovedForward) {
      _movedForwardController.text = widget.plan.whatMovedForward ?? '';
    }

    if (oldWidget.plan.whatWasCompleted != widget.plan.whatWasCompleted) {
      _completedController.text = widget.plan.whatWasCompleted ?? '';
    }

    if (oldWidget.plan.whatWasLearned != widget.plan.whatWasLearned) {
      _learnedController.text = widget.plan.whatWasLearned ?? '';
    }

    if (oldWidget.plan.blockers != widget.plan.blockers) {
      _blockersController.text = widget.plan.blockers ?? '';
    }

    final previousTopTaskIds = _topTaskIdsFromPlan(oldWidget.plan);
    final currentTopTaskIds = _topTaskIdsFromPlan(widget.plan);
    if (!_sameIds(previousTopTaskIds, currentTopTaskIds)) {
      _selectedTopTaskIds = currentTopTaskIds;
    }

    if (oldWidget.initialSection != widget.initialSection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToInitialSectionIfNeeded();
      });
    }
  }

  @override
  void dispose() {
    _morningIntentionController.dispose();
    _mainFocusController.dispose();
    _focusReasonController.dispose();
    _carryForwardController.dispose();
    _tomorrowFocusController.dispose();
    _movedForwardController.dispose();
    _completedController.dispose();
    _learnedController.dispose();
    _blockersController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = widget.plan;
    final formattedDate = DateFormat('EEEE d MMMM y').format(plan.date);

    return ListView(
      key: const Key('plannerScrollView'),
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: _plannerPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Planner',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppColours.darkText,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A calm place to set the day, choose the Top 3, and review it gently.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PlannerGuidanceCard(
          plan: plan,
          taskOptions: widget.taskOptions,
          selectedTopTaskIds: _selectedTopTaskIds,
        ),
        const SizedBox(height: 12),
        _EditablePlannerCard(
          title: 'Morning Intention',
          fieldKey: const Key('plannerMorningIntentionField'),
          buttonKey: const Key('plannerMorningIntentionSaveButton'),
          controller: _morningIntentionController,
          hintText: 'Set a simple direction for today.',
          buttonLabel: 'Save Intention',
          isSaving: _isSavingMorningIntention,
          onSave: () => _saveMorningIntention(context),
        ),
        const SizedBox(height: 12),
        _EditablePlannerCard(
          title: 'Main Focus',
          fieldKey: const Key('plannerMainFocusField'),
          buttonKey: const Key('plannerMainFocusSaveButton'),
          controller: _mainFocusController,
          hintText: 'Choose one useful step for today.',
          buttonLabel: 'Save Focus',
          isSaving: _isSavingMainFocus,
          onSave: () => _saveMainFocus(context),
        ),
        const SizedBox(height: 12),
        _EditablePlannerCard(
          title: 'Why It Matters',
          fieldKey: const Key('plannerFocusReasonField'),
          buttonKey: const Key('plannerFocusReasonSaveButton'),
          controller: _focusReasonController,
          hintText: 'Keep the reason short and clear.',
          buttonLabel: 'Save Reason',
          isSaving: _isSavingFocusReason,
          onSave: () => _saveFocusReason(context),
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
        KeyedSubtree(
          key: _eveningReviewKey,
          child: _EveningReviewPlannerCard(
            title: 'Evening Review',
            movedForwardController: _movedForwardController,
            completedController: _completedController,
            learnedController: _learnedController,
            blockersController: _blockersController,
            isSaving: _isSavingEveningReview,
            onSave: () => _saveEveningReview(context),
          ),
        ),
        const SizedBox(height: 12),
        _EditablePlannerCard(
          title: 'Carry Forward',
          fieldKey: const Key('plannerCarryForwardField'),
          buttonKey: const Key('plannerCarryForwardSaveButton'),
          controller: _carryForwardController,
          hintText: 'Park what can wait until later.',
          buttonLabel: 'Save Carry Forward',
          isSaving: _isSavingCarryForward,
          onSave: () => _saveCarryForward(context),
        ),
        const SizedBox(height: 12),
        KeyedSubtree(
          key: _carryForwardKey,
          child: _CarryForwardReviewCard(
            carryForwardNotes: plan.carryForwardNotes?.trim() ?? '',
            onReviewParked: () => _openParkedTasks(context),
            onOpenTasks: () => context.push(RouteNames.tasks),
          ),
        ),
        const SizedBox(height: 12),
        _EditablePlannerCard(
          title: 'Tomorrow\'s Focus',
          fieldKey: const Key('plannerTomorrowFocusField'),
          buttonKey: const Key('plannerTomorrowFocusSaveButton'),
          controller: _tomorrowFocusController,
          hintText: 'Note the likely first move for tomorrow.',
          buttonLabel: 'Save Tomorrow',
          isSaving: _isSavingTomorrowFocus,
          onSave: () => _saveTomorrowFocus(context),
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
      ).showSnackBar(const SnackBar(content: Text('Intention saved.')));
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
      ).showSnackBar(const SnackBar(content: Text('Focus saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingMainFocus = false);
      }
    }
  }

  Future<void> _saveFocusReason(BuildContext context) async {
    setState(() => _isSavingFocusReason = true);

    try {
      await ref
          .read(plannerControllerProvider)
          .saveFocusReason(_focusReasonController.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reason saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingFocusReason = false);
      }
    }
  }

  Future<void> _saveCarryForward(BuildContext context) async {
    setState(() => _isSavingCarryForward = true);

    try {
      await ref
          .read(plannerControllerProvider)
          .saveCarryForwardNotes(_carryForwardController.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Carry forward saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingCarryForward = false);
      }
    }
  }

  Future<void> _saveTomorrowFocus(BuildContext context) async {
    setState(() => _isSavingTomorrowFocus = true);

    try {
      await ref
          .read(plannerControllerProvider)
          .saveTomorrowFocus(_tomorrowFocusController.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tomorrow saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingTomorrowFocus = false);
      }
    }
  }

  Future<void> _saveEveningReview(BuildContext context) async {
    setState(() => _isSavingEveningReview = true);

    try {
      await ref
          .read(plannerControllerProvider)
          .saveEveningReview(
            movedForward: _movedForwardController.text,
            completed: _completedController.text,
            learned: _learnedController.text,
            blockers: _blockersController.text,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingEveningReview = false);
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
            'You already have 3 priority tasks. Complete, remove, or carry one forward first.',
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
      ).showSnackBar(const SnackBar(content: Text('Top 3 saved.')));
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

  void _scrollToInitialSectionIfNeeded() {
    final targetContext = switch (widget.initialSection) {
      'review' => _eveningReviewKey.currentContext,
      'carryForward' => _carryForwardKey.currentContext,
      _ => null,
    };

    if (targetContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: 0.1,
    );
  }

  void _openParkedTasks(BuildContext context) {
    ref.read(selectedTaskStatusFilterProvider.notifier).setFilter('Parked');
    ref.read(selectedTaskProjectFilterProvider.notifier).setFilter(null);
    ref.read(taskSearchQueryProvider.notifier).clear();
    context.push(RouteNames.tasks);
  }
}

class _PlannerGuidanceCard extends StatelessWidget {
  const _PlannerGuidanceCard({
    required this.plan,
    required this.taskOptions,
    required this.selectedTopTaskIds,
  });

  final DailyPlan plan;
  final List<Task> taskOptions;
  final List<String> selectedTopTaskIds;

  @override
  Widget build(BuildContext context) {
    final guidance = _buildGuidance();

    return CalmGuidanceCard(
      title: guidance.title,
      summary: guidance.summary,
      reason: guidance.reason,
    );
  }

  _PlannerGuidance _buildGuidance() {
    final selectedTasks = taskOptions
        .where((task) => selectedTopTaskIds.contains(task.taskId))
        .toList();
    final firstTask = selectedTasks.isNotEmpty ? selectedTasks.first : null;
    final mainFocus = plan.mainFocus?.trim();
    final hasMainFocus = mainFocus != null && mainFocus.isNotEmpty;
    final hasCarryForward = plan.carryForwardNotes?.trim().isNotEmpty == true;
    final hasTomorrowFocus = plan.tomorrowFocus?.trim().isNotEmpty == true;

    if (hasMainFocus && firstTask != null) {
      return _PlannerGuidance(
        title: 'Stay with today\'s focus',
        summary: 'Start with $mainFocus, then move into ${firstTask.title}.',
        reason:
            'The day already has a clear anchor and the Top 3 is ready to support it.',
      );
    }

    if (hasMainFocus) {
      return _PlannerGuidance(
        title: 'Stay with today\'s focus',
        summary: 'Start with $mainFocus.',
        reason:
            'It gives the planner one clear anchor before anything else needs attention.',
      );
    }

    if (firstTask != null) {
      return _PlannerGuidance(
        title: 'Pick one clear start',
        summary: 'Begin with ${firstTask.title}.',
        reason:
            'The Top 3 is already set, so one task can lead the rest of the day calmly.',
      );
    }

    if (hasCarryForward || hasTomorrowFocus) {
      return _PlannerGuidance(
        title: 'Close the loop gently',
        summary: 'Review what can wait, then note the next small step.',
        reason:
            'You already have loose threads to carry forward, so the planner can help tidy them without adding pressure.',
      );
    }

    return _PlannerGuidance(
      title: 'Set one small anchor',
      summary: 'Choose a main focus before adding more detail.',
      reason: 'A single clear focus keeps the planner calm and easier to use.',
    );
  }
}

class _PlannerGuidance {
  const _PlannerGuidance({
    required this.title,
    required this.summary,
    required this.reason,
  });

  final String title;
  final String summary;
  final String reason;
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

    return Container(
      decoration: _plannerPanelDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: fieldKey,
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: hintText),
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
    );
  }
}

class _EveningReviewPlannerCard extends StatelessWidget {
  const _EveningReviewPlannerCard({
    required this.title,
    required this.movedForwardController,
    required this.completedController,
    required this.learnedController,
    required this.blockersController,
    required this.isSaving,
    required this.onSave,
  });

  final String title;
  final TextEditingController movedForwardController;
  final TextEditingController completedController;
  final TextEditingController learnedController;
  final TextEditingController blockersController;
  final bool isSaving;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _plannerPanelDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 12),
          _ReviewField(
            fieldKey: const Key('plannerMovedForwardField'),
            controller: movedForwardController,
            label: 'What moved forward today?',
          ),
          const SizedBox(height: 12),
          _ReviewField(
            fieldKey: const Key('plannerCompletedField'),
            controller: completedController,
            label: 'What did I complete?',
          ),
          const SizedBox(height: 12),
          _ReviewField(
            fieldKey: const Key('plannerLearnedField'),
            controller: learnedController,
            label: 'What did I learn?',
          ),
          const SizedBox(height: 12),
          _ReviewField(
            fieldKey: const Key('plannerBlockersField'),
            controller: blockersController,
            label: 'What blocked me?',
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              key: const Key('plannerEveningReviewSaveButton'),
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.nightlight_round),
              label: const Text('Save Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({
    required this.fieldKey,
    required this.controller,
    required this.label,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      minLines: 2,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
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

    return Container(
      decoration: _plannerPanelDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${selectedTaskIds.length} of 3 selected',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Text(
              'No open tasks are ready for today\'s priorities yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
              ),
            )
          else
            ...tasks.map((task) {
              final isSelected = selectedTaskIds.contains(task.taskId);
              return CheckboxListTile(
                key: Key('plannerTopTask-${task.taskId}'),
                value: isSelected,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkText,
                  ),
                ),
                subtitle: Text(
                  task.status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
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
              label: const Text('Save Top 3'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarryForwardReviewCard extends StatelessWidget {
  const _CarryForwardReviewCard({
    required this.carryForwardNotes,
    required this.onReviewParked,
    required this.onOpenTasks,
  });

  final String carryForwardNotes;
  final VoidCallback onReviewParked;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNotes = carryForwardNotes.trim().isNotEmpty;

    return Container(
      decoration: _plannerPanelDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carry Forward Review',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasNotes
                ? 'Review the parked work when you are ready to reopen it.'
                : 'Nothing is parked yet. This area will help when items need to wait.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
            ),
          ),
          if (hasNotes) ...[
            const SizedBox(height: 10),
            Text(
              carryForwardNotes,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColours.darkText,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onReviewParked,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Review Parked'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenTasks,
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Open Tasks'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

BoxDecoration _plannerPanelDecoration() {
  return BoxDecoration(
    color: AppColours.darkSurface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColours.darkOutline.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
