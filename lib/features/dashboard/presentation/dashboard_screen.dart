import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../../inbox/application/inbox_controller.dart';
import '../../planner/application/planner_controller.dart';
import '../../tasks/application/tasks_controller.dart';
import '../application/dashboard_controller.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);

    return snapshot.when(
      data: (data) => _DashboardContent(snapshot: data),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: _DashboardError(error: error)),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          key: const Key('dashboardScrollView'),
          cacheExtent: 3000,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 28 : 18,
                isWide ? 28 : 18,
                isWide ? 28 : 18,
                24,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardHero(snapshot: snapshot),
                    const SizedBox(height: 22),
                    _TopTaskShowcase(snapshot: snapshot),
                    const SizedBox(height: 22),
                    _SecondaryPanelGrid(snapshot: snapshot),
                    const SizedBox(height: 22),
                    _SupportModuleGrid(snapshot: snapshot),
                    const SizedBox(height: 22),
                    const _DashboardEveningReviewCard(),
                    const SizedBox(height: 20),
                    _DashboardFooter(isDark: isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _greeting();
    final weekday = DateFormat('EEEE').format(snapshot.date);
    final shortDate = DateFormat('d MMM y').format(snapshot.date);
    final focusChip = snapshot.mainFocus?.isNotEmpty == true
        ? 'Deep Work'
        : 'Set Focus';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 980;

          final brandAndCopy = [
            const _DashboardBrandBlock(),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$greeting, El',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColours.darkText,
                      fontSize: 38,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Focus on what matters most today.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColours.darkMutedText,
                    ),
                  ),
                ],
              ),
            ),
          ];

          final chips = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeaderMetricChip(label: 'Focus', value: focusChip),
              _HeaderMetricChip(
                label: 'Energy',
                value: snapshot.energyLabel,
                accentColor: AppColours.darkSuccess,
              ),
              _HeaderMetricChip(label: 'Day', value: weekday),
              _HeaderMetricChip(label: 'Date', value: shortDate),
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...brandAndCopy, const SizedBox(height: 18), chips],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: brandAndCopy,
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 580,
                child: Align(alignment: Alignment.topRight, child: chips),
              ),
            ],
          );
        },
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }
}

class _TopTaskShowcase extends StatelessWidget {
  const _TopTaskShowcase({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final tasks = snapshot.topTasks;
    final cards = tasks.isEmpty
        ? [
            const _ShowcaseTaskState(
              badge: '1',
              title: 'Choose your first priority task',
              subtitle: 'Your Top 3 will appear here once selected.',
              label: 'Today',
              accent: AppColours.darkSecondary,
            ),
            const _ShowcaseTaskState(
              badge: '2',
              title: 'Create momentum with one useful action',
              subtitle: 'Planner and Tasks stay in sync with this list.',
              label: 'Planner',
              accent: AppColours.darkSuccess,
            ),
            const _ShowcaseTaskState(
              badge: '3',
              title: 'Keep the dashboard calm',
              subtitle: 'Only three priorities live here at a time.',
              label: 'Focus',
              accent: AppColours.darkPurple,
            ),
          ]
        : List.generate(3, (index) {
            final task = index < tasks.length ? tasks[index] : null;
            return _ShowcaseTaskState.fromTask(index: index, task: task);
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            'Today\'s Focus',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColours.darkText),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final useThreeColumns = constraints.maxWidth >= 860;
            if (useThreeColumns) {
              return Row(
                children: [
                  for (var index = 0; index < cards.length; index++) ...[
                    Expanded(
                      child: _ShowcaseTaskCard(
                        snapshotTask: index < tasks.length
                            ? tasks[index]
                            : null,
                        state: cards[index],
                      ),
                    ),
                    if (index != cards.length - 1) const SizedBox(width: 14),
                  ],
                ],
              );
            }

            return Column(
              children: [
                for (var index = 0; index < cards.length; index++) ...[
                  _ShowcaseTaskCard(
                    snapshotTask: index < tasks.length ? tasks[index] : null,
                    state: cards[index],
                  ),
                  if (index != cards.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SecondaryPanelGrid extends StatelessWidget {
  const _SecondaryPanelGrid({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useThreeColumns = constraints.maxWidth >= 980;

        if (useThreeColumns) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DashboardFocusCard(snapshot: snapshot)),
              const SizedBox(width: 16),
              Expanded(child: _ActiveProjectsPanel(snapshot: snapshot)),
              const SizedBox(width: 16),
              const Expanded(child: _DashboardQuickCaptureCard()),
            ],
          );
        }

        return Column(
          children: [
            _DashboardFocusCard(snapshot: snapshot),
            const SizedBox(height: 16),
            _ActiveProjectsPanel(snapshot: snapshot),
            const SizedBox(height: 16),
            const _DashboardQuickCaptureCard(),
          ],
        );
      },
    );
  }
}

class _SupportModuleGrid extends StatelessWidget {
  const _SupportModuleGrid({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = <_MiniModuleState>[
      if (snapshot.showLearningCard)
        const _MiniModuleState(
          title: 'Learning Focus',
          description: 'Track the skill that supports today\'s build.',
          icon: Icons.school_outlined,
          accent: AppColours.darkSuccess,
        ),
      if (snapshot.showContentCard)
        const _MiniModuleState(
          title: 'Content Focus',
          description: 'Turn progress into public awareness.',
          icon: Icons.campaign_outlined,
          accent: AppColours.darkSecondary,
        ),
      if (snapshot.showBusinessCard)
        const _MiniModuleState(
          title: 'Business Reminder',
          description: 'Keep funding and next practical actions visible.',
          icon: Icons.handshake_outlined,
          accent: AppColours.darkAmber,
        ),
      if (snapshot.showWellbeingCard)
        const _MiniModuleState(
          title: 'Wellbeing',
          description: 'Build New Earth without burning out.',
          icon: Icons.favorite_border,
          accent: AppColours.darkPurple,
        ),
    ];

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1120
            ? 4
            : constraints.maxWidth >= 740
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: crossAxisCount == 1 ? 3.1 : 2.05,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => _MiniModuleCard(state: cards[index]),
        );
      },
    );
  }
}

class _DashboardFocusCard extends ConsumerStatefulWidget {
  const _DashboardFocusCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  ConsumerState<_DashboardFocusCard> createState() =>
      _DashboardFocusCardState();
}

class _DashboardFocusCardState extends ConsumerState<_DashboardFocusCard> {
  late final TextEditingController _mainFocusController;
  late final TextEditingController _focusReasonController;
  late final TextEditingController _morningIntentionController;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mainFocusController = TextEditingController(
      text: widget.snapshot.mainFocus ?? '',
    );
    _focusReasonController = TextEditingController(
      text: widget.snapshot.focusReason ?? '',
    );
    _morningIntentionController = TextEditingController(
      text: widget.snapshot.morningIntention ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _DashboardFocusCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.snapshot.mainFocus != widget.snapshot.mainFocus) {
      _mainFocusController.text = widget.snapshot.mainFocus ?? '';
    }
    if (oldWidget.snapshot.focusReason != widget.snapshot.focusReason) {
      _focusReasonController.text = widget.snapshot.focusReason ?? '';
    }
    if (oldWidget.snapshot.morningIntention !=
        widget.snapshot.morningIntention) {
      _morningIntentionController.text = widget.snapshot.morningIntention ?? '';
    }
  }

  @override
  void dispose() {
    _mainFocusController.dispose();
    _focusReasonController.dispose();
    _morningIntentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFocus = widget.snapshot.mainFocus?.isNotEmpty == true;
    final hasReason = widget.snapshot.focusReason?.isNotEmpty == true;
    final hasIntention = widget.snapshot.morningIntention?.isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final actions = [
                TextButton.icon(
                  key: const Key('dashboardFocusEditButton'),
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _isEditing = !_isEditing;
                            if (!_isEditing) {
                              _mainFocusController.text =
                                  widget.snapshot.mainFocus ?? '';
                              _focusReasonController.text =
                                  widget.snapshot.focusReason ?? '';
                              _morningIntentionController.text =
                                  widget.snapshot.morningIntention ?? '';
                            }
                          });
                        },
                  icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                  label: Text(_isEditing ? 'Close' : 'Quick Edit'),
                ),
                TextButton.icon(
                  key: const Key('dashboardFocusClearButton'),
                  onPressed: _isSaving ? null : () => _clearFocus(context),
                  icon: const Icon(Icons.clear_outlined),
                  label: const Text('Clear Focus'),
                ),
              ];

              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PanelTitle(
                      title: 'Today\'s Focus',
                      icon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                );
              }

              return Row(
                children: [
                  const _PanelTitle(
                    title: 'Today\'s Focus',
                    icon: Icons.flag_outlined,
                  ),
                  const Spacer(),
                  Wrap(spacing: 8, runSpacing: 8, children: actions),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          if (_isEditing) ...[
            TextField(
              key: const Key('dashboardMainFocusField'),
              controller: _mainFocusController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Main Focus'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('dashboardFocusReasonField'),
              controller: _focusReasonController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Why It Matters'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('dashboardMorningIntentionField'),
              controller: _morningIntentionController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Morning Intention'),
            ),
            const SizedBox(height: 14),
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
                  ? widget.snapshot.mainFocus!
                  : 'A blank daily plan is ready for today.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
              ),
            ),
            const SizedBox(height: 16),
            _FocusDetailRow(
              label: 'Why It Matters',
              value: hasReason
                  ? widget.snapshot.focusReason!
                  : 'No focus reason set yet.',
            ),
            const SizedBox(height: 12),
            _FocusDetailRow(
              label: 'Morning Intention',
              value: hasIntention
                  ? widget.snapshot.morningIntention!
                  : 'No morning intention set yet.',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _isSaving = true);

    try {
      final plannerController = ref.read(plannerControllerProvider);
      await plannerController.saveMainFocus(_mainFocusController.text);
      await plannerController.saveFocusReason(_focusReasonController.text);
      await plannerController.saveMorningIntention(
        _morningIntentionController.text,
      );
      if (!context.mounted) {
        return;
      }
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

  Future<void> _clearFocus(BuildContext context) async {
    setState(() => _isSaving = true);

    try {
      await ref.read(plannerControllerProvider).clearFocus();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Today\'s focus cleared.')));
      setState(() => _isEditing = false);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ActiveProjectsPanel extends StatelessWidget {
  const _ActiveProjectsPanel({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final projects = snapshot.activeProjects;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PanelTitle(
                title: 'Active Projects',
                icon: Icons.folder_copy_outlined,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(RouteNames.projects),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (projects.isEmpty)
            Text(
              '${snapshot.activeProjectCount} projects are available.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Column(
              children: [
                for (var index = 0; index < projects.length; index++) ...[
                  _ProjectProgressRow(project: projects[index]),
                  if (index != projects.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _DashboardEveningReviewCard extends StatelessWidget {
  const _DashboardEveningReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.nightlight_round, color: AppColours.darkPurple),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evening Review',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
                ),
                const SizedBox(height: 6),
                Text(
                  'Record what moved forward before the day ends.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            key: const Key('dashboardStartEveningReviewButton'),
            onPressed: () => context.go('${RouteNames.planner}?section=review'),
            icon: const Icon(Icons.nightlight_round),
            label: const Text('Start Evening Review'),
          ),
        ],
      ),
    );
  }
}

class _DashboardQuickCaptureCard extends ConsumerStatefulWidget {
  const _DashboardQuickCaptureCard();

  @override
  ConsumerState<_DashboardQuickCaptureCard> createState() =>
      _DashboardQuickCaptureCardState();
}

class _DashboardQuickCaptureCardState
    extends ConsumerState<_DashboardQuickCaptureCard> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'Quick Capture',
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Capture a task, idea, note, or content seed.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: BoxDecoration(
              color: AppColours.darkSurfaceAlt.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColours.darkOutline),
            ),
            child: Text(
              'Capture an idea, task or note...',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _CaptureTypeChip(label: 'Task'),
              _CaptureTypeChip(label: 'Note'),
              _CaptureTypeChip(label: 'Idea', selected: true),
              _CaptureTypeChip(label: 'Journal'),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('dashboardQuickCaptureButton'),
            onPressed: _isSaving ? null : () => _openQuickCapture(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Capture'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            key: const Key('dashboardVoiceCaptureButton'),
            onPressed: () => context.push(RouteNames.voiceAssistant),
            icon: const Icon(Icons.mic_none_rounded),
            label: const Text('Voice Capture'),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuickCapture() async {
    final result = await showDialog<_QuickCaptureDraft>(
      context: context,
      builder: (dialogContext) => const _QuickCaptureDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final item = await ref
          .read(inboxActionsControllerProvider)
          .createItem(
            title: result.title,
            body: result.body,
            type: result.type,
            status: 'New',
          );

      if (!mounted) {
        return;
      }

      final label = item.title ?? item.body ?? 'Inbox item saved.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label saved to Inbox.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _QuickCaptureDraft {
  const _QuickCaptureDraft({this.title, this.body, this.type});

  final String? title;
  final String? body;
  final String? type;
}

class _QuickCaptureDialog extends StatefulWidget {
  const _QuickCaptureDialog();

  @override
  State<_QuickCaptureDialog> createState() => _QuickCaptureDialogState();
}

class _QuickCaptureDialogState extends State<_QuickCaptureDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String? _type;

  static const _typeOptions = [
    'Task',
    'Idea',
    'Journal Note',
    'Content Idea',
    'Learning Note',
    'Business Opportunity',
    'Future Idea',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Capture'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('dashboardQuickCaptureTitleField'),
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('dashboardQuickCaptureBodyField'),
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
                minLines: 3,
                maxLines: 5,
                validator: (value) {
                  final title = _titleController.text.trim();
                  final body = value?.trim() ?? '';
                  if (title.isEmpty && body.isEmpty) {
                    return 'Please enter a title or body.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const Key('dashboardQuickCaptureTypeField'),
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No type selected'),
                  ),
                  ..._typeOptions.map(
                    (type) => DropdownMenuItem<String?>(
                      value: type,
                      child: Text(type),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _type = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('dashboardQuickCaptureSaveButton'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.of(context).pop(
              _QuickCaptureDraft(
                title: _optionalText(_titleController.text),
                body: _optionalText(_bodyController.text),
                type: _type,
              ),
            );
          },
          child: const Text('Save to Inbox'),
        ),
      ],
    );
  }

  String? _optionalText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _ShowcaseTaskCard extends ConsumerWidget {
  const _ShowcaseTaskCard({required this.snapshotTask, required this.state});

  final DashboardTopTask? snapshotTask;
  final _ShowcaseTaskState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTask = snapshotTask != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: state.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: state.accent.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: state.accent.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  state.badge,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (hasTask)
                Row(
                  children: [
                    IconButton(
                      key: Key('dashboardTopTaskDone-${snapshotTask!.taskId}'),
                      onPressed: () async {
                        await ref
                            .read(tasksControllerProvider)
                            .markTaskDone(snapshotTask!.taskId);
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      color: AppColours.darkText,
                      tooltip: 'Mark done',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      key: Key(
                        'dashboardTopTaskRemove-${snapshotTask!.taskId}',
                      ),
                      onPressed: () async {
                        await ref
                            .read(tasksControllerProvider)
                            .removeFromTopThree(snapshotTask!.taskId);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColours.darkMutedText,
                      tooltip: 'Remove from Top 3',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            state.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 8),
          Text(
            state.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InlineTag(label: state.label, accent: state.accent),
              if (hasTask && snapshotTask!.projectName != null) ...[
                const SizedBox(width: 8),
                _InlineTag(
                  label: snapshotTask!.projectName!,
                  accent: AppColours.darkSurfaceRaised,
                  foreground: AppColours.darkText,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectProgressRow extends StatelessWidget {
  const _ProjectProgressRow({required this.project});

  final DashboardProjectSummary project;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RouteNames.projectDetail(project.projectId)),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${project.progressPercentage}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: project.progressPercentage / 100,
                backgroundColor: AppColours.darkSurfaceAlt,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColours.darkSecondary,
                ),
              ),
            ),
            if ((project.nextAction ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                project.nextAction!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniModuleCard extends StatelessWidget {
  const _MiniModuleCard({required this.state});

  final _MiniModuleState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(state.icon, color: state.accent),
          const SizedBox(height: 14),
          Text(
            state.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
          ),
          const SizedBox(height: 8),
          Text(
            state.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
          ),
        ],
      ),
    );
  }
}

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColours.darkSurface.withValues(alpha: 0.94)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColours.darkSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Small consistent actions create extraordinary results over time.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColours.darkSecondary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
        ),
      ],
    );
  }
}

class _DashboardBrandBlock extends StatelessWidget {
  const _DashboardBrandBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BrandSeal(),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEW EARTH',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontSize: 28,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'COMMAND DASHBOARD',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColours.darkSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandSeal extends StatelessWidget {
  const _BrandSeal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102C47), Color(0xFF08141A)],
        ),
        border: Border.all(color: AppColours.darkSecondary, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Container(
              height: 14,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(100, 30)),
                gradient: LinearGradient(
                  colors: [Color(0xFF4C8EFF), Color(0xFF97E7FF)],
                ),
              ),
            ),
          ),
          const Icon(Icons.spa_rounded, size: 34, color: Colors.white),
        ],
      ),
    );
  }
}

class _HeaderMetricChip extends StatelessWidget {
  const _HeaderMetricChip({
    required this.label,
    required this.value,
    this.accentColor = AppColours.darkSecondary,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusDetailRow extends StatelessWidget {
  const _FocusDetailRow({required this.label, required this.value});

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
        const SizedBox(height: 5),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
        ),
      ],
    );
  }
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foreground ?? accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CaptureTypeChip extends StatelessWidget {
  const _CaptureTypeChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColours.darkPrimary : AppColours.darkMutedText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppColours.darkPrimary.withValues(alpha: 0.18)
            : AppColours.darkSurfaceAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? AppColours.darkPrimary : AppColours.darkOutline,
        ),
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

class _ShowcaseTaskState {
  const _ShowcaseTaskState({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.accent,
  });

  factory _ShowcaseTaskState.fromTask({
    required int index,
    required DashboardTopTask? task,
  }) {
    const accents = [
      AppColours.darkSecondary,
      AppColours.darkSuccess,
      AppColours.darkPurple,
    ];
    final accent = accents[index];
    if (task == null) {
      return _ShowcaseTaskState(
        badge: '${index + 1}',
        title: 'Choose another priority task',
        subtitle: 'There is still room in your Top 3 for today.',
        label: 'Open slot',
        accent: accent,
      );
    }

    return _ShowcaseTaskState(
      badge: '${index + 1}',
      title: task.title,
      subtitle: '${task.status} • Priority ${task.priority}',
      label: task.projectName ?? 'Top 3 Task',
      accent: accent,
    );
  }

  final String badge;
  final String title;
  final String subtitle;
  final String label;
  final Color accent;
}

class _MiniModuleState {
  const _MiniModuleState({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          'Dashboard could not be loaded. Please try again.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
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
