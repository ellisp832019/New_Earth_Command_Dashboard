import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colours.dart';
import '../application/treasury_controller.dart';
import '../application/treasury_wizard_draft_controller.dart';
import '../data/treasury_wizard_draft.dart';
import '../data/treasury_wizard_flow.dart';

class TreasuryWizardScreen extends ConsumerStatefulWidget {
  const TreasuryWizardScreen({super.key, this.initialFlow});

  final String? initialFlow;

  @override
  ConsumerState<TreasuryWizardScreen> createState() =>
      _TreasuryWizardScreenState();
}

class _TreasuryWizardScreenState extends ConsumerState<TreasuryWizardScreen> {
  late final TreasuryWizardFlow _flow;
  late final List<TextEditingController> _controllers;
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _flow = resolveTreasuryWizardFlow(widget.initialFlow);
    _controllers = _buildControllers(_flow);
    final draftController = ref.read(treasuryWizardDraftsProvider.notifier);
    draftController.ensureLength(_flow, _stepsFor(_flow).length);
    final draft = ref.read(
      treasuryWizardDraftsProvider.select((drafts) => drafts[_flow]),
    );
    if (draft != null) {
      for (
        var index = 0;
        index < _controllers.length && index < draft.values.length;
        index++
      ) {
        _controllers[index].text = draft.values[index];
      }
    }
    for (var index = 0; index < _controllers.length; index++) {
      final stepIndex = index;
      _controllers[index].addListener(() {
        ref
            .read(treasuryWizardDraftsProvider.notifier)
            .setField(_flow, stepIndex, _controllers[stepIndex].text);
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _stepsFor(_flow);
    final totalSteps = steps.length + 1;
    final currentProgress = (_stepIndex + 1) / totalSteps;
    final theme = Theme.of(context);
    final draft = ref.watch(
      treasuryWizardDraftsProvider.select((drafts) => drafts[_flow]),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _WizardHeaderCard(
                  flow: _flow,
                  progress: currentProgress,
                  onBack: () => context.pop(),
                ),
                if (draft != null && draft.hasContent) ...[
                  const SizedBox(height: 14),
                  _WizardDraftBanner(
                    draft: draft,
                    onContinue: () => _goToStep(_stepIndex),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  decoration: _panelDecoration(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _WizardFlowChip(label: _flow.title),
                          const SizedBox(width: 10),
                          _WizardFlowChip(
                            label: '${_stepIndex + 1} of $totalSteps',
                            accent: AppColours.darkSuccess,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _stepIndex < steps.length
                            ? steps[_stepIndex].prompt
                            : 'Review your draft before it is saved into the calm Treasury flow.',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColours.darkText,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _stepIndex < steps.length
                            ? steps[_stepIndex].hint
                            : 'You can go back and edit anything before finishing.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColours.darkMutedText,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _stepIndex < steps.length
                            ? _WizardStepCard(
                                key: ValueKey('step-$_stepIndex'),
                                step: steps[_stepIndex],
                                controller: _controllers[_stepIndex],
                              )
                            : _WizardReviewCard(
                                key: const ValueKey('review'),
                                flow: _flow,
                                steps: steps,
                                controllers: _controllers,
                              ),
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final useWide = constraints.maxWidth >= 680;
                          final buttons = [
                            TextButton(
                              onPressed: _stepIndex == 0
                                  ? null
                                  : () => _goToStep(_stepIndex - 1),
                              child: const Text('Back'),
                            ),
                            if (_stepIndex < steps.length)
                              FilledButton.icon(
                                onPressed: () => _goToStep(_stepIndex + 1),
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Continue'),
                              )
                            else
                              FilledButton.icon(
                                onPressed: () => _finish(context),
                                icon: const Icon(Icons.save_outlined),
                                label: Text(switch (_flow) {
                                  TreasuryWizardFlow.weeklyRitual =>
                                    'Save review',
                                  TreasuryWizardFlow.receipts => 'Save receipt',
                                  _ => 'Save draft',
                                }),
                              ),
                            TextButton.icon(
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.account_balance_wallet_outlined,
                              ),
                              label: const Text('Return to Treasury'),
                            ),
                          ];

                          if (!useWide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final button in buttons) ...[
                                  button,
                                  const SizedBox(height: 10),
                                ],
                              ],
                            );
                          }

                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.end,
                            children: buttons,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToStep(int nextStep) {
    setState(() => _stepIndex = nextStep);
    ref
        .read(treasuryWizardDraftsProvider.notifier)
        .ensureLength(_flow, _stepsFor(_flow).length);
  }

  Future<void> _finish(BuildContext context) async {
    if (_flow != TreasuryWizardFlow.weeklyRitual) {
      if (_flow == TreasuryWizardFlow.receipts) {
        final service = ref.read(treasuryFolderServiceProvider);
        final snapshot = await service.loadWorkspace();
        if (!context.mounted) {
          return;
        }

        final financeRootPath = snapshot.financeRootPath;
        if (financeRootPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Treasury needs the finance folder linked first.'),
            ),
          );
          return;
        }

        final result = await service.saveReceiptRecord(
          financeRootPath: financeRootPath,
          item: _controllerText(0),
          supplier: _controllerText(1),
          amount: _controllerText(2),
          personalOrNewEarth: _controllers.length > 3
              ? _controllers[3].text
              : '',
          project: _controllerText(4),
          fileLocation: _controllerText(5),
          notes: _controllerText(6),
          recordedAt: DateTime.now(),
        );

        if (!context.mounted) {
          return;
        }

        ref.read(treasuryWizardDraftsProvider.notifier).markSaved(_flow);
        ref.invalidate(treasuryWorkspaceProvider);

        final savedName = result.receiptIndexPath
            .split(Platform.pathSeparator)
            .last;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Receipt saved to $savedName')));
        context.pop();
        return;
      }

      ref.read(treasuryWizardDraftsProvider.notifier).markSaved(_flow);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved locally in Treasury.')),
      );
      context.pop();
      return;
    }

    final service = ref.read(treasuryFolderServiceProvider);
    final snapshot = await service.loadWorkspace();
    if (!context.mounted) {
      return;
    }

    final financeRootPath = snapshot.financeRootPath;
    if (financeRootPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Treasury needs the finance folder linked first.'),
        ),
      );
      return;
    }

    final safeItems = _itemsForController(0);
    final watchItems = _itemsForController(1);
    final pauseItems = _itemsForController(2);
    final decisionItems = _itemsForController(3);
    final closingNote = _controllers.length > 4 ? _controllers[4].text : '';

    final result = await service.saveWeeklyReview(
      financeRootPath: financeRootPath,
      safeItems: safeItems,
      watchItems: watchItems,
      pauseItems: pauseItems,
      decisionItems: decisionItems,
      closingNote: closingNote,
      reviewedAt: DateTime.now(),
    );

    if (!context.mounted) {
      return;
    }

    ref.read(treasuryWizardDraftsProvider.notifier).markSaved(_flow);
    ref.invalidate(treasuryWorkspaceProvider);

    final savedName = result.reviewPath.split(Platform.pathSeparator).last;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Weekly review saved: $savedName')));
    context.pop();
  }

  List<String> _itemsForController(int index) {
    if (index >= _controllers.length) {
      return const <String>[];
    }

    final raw = _controllers[index].text.trim();
    if (raw.isEmpty) {
      return const <String>[];
    }

    return raw
        .split(RegExp(r'[\n\r;]+'))
        .map((item) => item.replaceFirst(RegExp(r'^[\-\*\d\.\)\s]+'), ''))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _controllerText(int index) {
    if (index >= _controllers.length) {
      return '';
    }

    return _controllers[index].text;
  }

  List<_WizardStepDefinition> _stepsFor(TreasuryWizardFlow flow) {
    switch (flow) {
      case TreasuryWizardFlow.weeklyRitual:
        return const [
          _WizardStepDefinition(
            label: 'Safe',
            prompt: 'What feels safe to spend or continue?',
            hint:
                'Use short calm notes. Safe items are the easiest place to start.',
          ),
          _WizardStepDefinition(
            label: 'Watch',
            prompt: 'What needs watching this week?',
            hint:
                'Anything uncertain, close to a boundary, or likely to change.',
          ),
          _WizardStepDefinition(
            label: 'Pause',
            prompt: 'What should pause for now?',
            hint:
                'Hold items here gently until the budget or timing feels better.',
          ),
          _WizardStepDefinition(
            label: 'Decision',
            prompt: 'What needs a decision with Peter?',
            hint:
                'Capture the one choice that needs agreement or a clear next move.',
          ),
          _WizardStepDefinition(
            label: 'Note',
            prompt: 'Add one short note for the weekly review.',
            hint: 'One sentence is enough. Keep it simple and kind.',
          ),
        ];
      case TreasuryWizardFlow.receipts:
        return const [
          _WizardStepDefinition(
            label: 'Item',
            prompt: 'What receipt or invoice are you adding?',
            hint: 'Name the purchase or invoice in a calm, easy-to-find way.',
          ),
          _WizardStepDefinition(
            label: 'Supplier',
            prompt: 'Who is the supplier?',
            hint: 'Add the merchant, vendor, or company name.',
          ),
          _WizardStepDefinition(
            label: 'Amount',
            prompt: 'What amount should be recorded?',
            hint: 'Enter the value as it appeared on the receipt.',
          ),
          _WizardStepDefinition(
            label: 'Type',
            prompt: 'Is this Personal or New Earth?',
            hint: 'Choose the calm category that fits the purchase.',
          ),
          _WizardStepDefinition(
            label: 'Project',
            prompt: 'Which project should this link to?',
            hint: 'Use the project name if there is one, or leave it simple.',
          ),
          _WizardStepDefinition(
            label: 'File location',
            prompt: 'Where is the file stored?',
            hint: 'Add the folder or filename if it is already sorted.',
          ),
          _WizardStepDefinition(
            label: 'Note',
            prompt: 'Anything else worth remembering?',
            hint: 'Optional context is fine. Keep it short.',
          ),
        ];
      case TreasuryWizardFlow.decisions:
        return const [
          _WizardStepDefinition(
            label: 'Decision',
            prompt: 'What decision needs attention?',
            hint: 'Describe the choice in plain language.',
          ),
          _WizardStepDefinition(
            label: 'Who',
            prompt: 'Who needs to be involved?',
            hint: 'Usually Hayley, Peter, or both.',
          ),
          _WizardStepDefinition(
            label: 'Why',
            prompt: 'Why does it matter right now?',
            hint: 'A short reason helps keep the next step clear.',
          ),
          _WizardStepDefinition(
            label: 'Note',
            prompt: 'What is the one calm note to keep?',
            hint: 'Keep this grounded and short.',
          ),
        ];
      case TreasuryWizardFlow.projectSpend:
        return const [
          _WizardStepDefinition(
            label: 'Project',
            prompt: 'Which project does this spend belong to?',
            hint: 'Use the project name Hayley already knows.',
          ),
          _WizardStepDefinition(
            label: 'Item',
            prompt: 'What was bought or paid for?',
            hint: 'A simple description is enough.',
          ),
          _WizardStepDefinition(
            label: 'Amount',
            prompt: 'What amount should be tracked?',
            hint: 'Record the number as calmly as possible.',
          ),
          _WizardStepDefinition(
            label: 'Receipt',
            prompt: 'Is the receipt saved yet?',
            hint: 'Choose yes, no, or to be sorted later.',
          ),
        ];
      case TreasuryWizardFlow.subscriptions:
        return const [
          _WizardStepDefinition(
            label: 'Service',
            prompt: 'Which subscription are you reviewing?',
            hint: 'Use the service or product name.',
          ),
          _WizardStepDefinition(
            label: 'Purpose',
            prompt: 'What is it used for?',
            hint: 'Keep the reason short and practical.',
          ),
          _WizardStepDefinition(
            label: 'Cost',
            prompt: 'What does it cost each cycle?',
            hint: 'Enter the price and the billing rhythm if known.',
          ),
          _WizardStepDefinition(
            label: 'Keep / Review',
            prompt: 'Does this feel like keep, cancel, or review?',
            hint: 'A simple direction is enough for the first pass.',
          ),
        ];
    }
  }

  List<TextEditingController> _buildControllers(TreasuryWizardFlow flow) {
    return List.generate(
      _stepsFor(flow).length,
      (_) => TextEditingController(),
    );
  }
}

class _WizardHeaderCard extends StatelessWidget {
  const _WizardHeaderCard({
    required this.flow,
    required this.progress,
    required this.onBack,
  });

  final TreasuryWizardFlow flow;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _panelDecoration(context, highlighted: true),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWide = constraints.maxWidth >= 860;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Treasury Wizard',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                flow.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                flow.subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColours.darkSurfaceAlt,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColours.darkSecondary,
                  ),
                ),
              ),
            ],
          );

          if (!useWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Treasury'),
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Treasury'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WizardDraftBanner extends StatelessWidget {
  const _WizardDraftBanner({required this.draft, required this.onContinue});

  final TreasuryWizardDraft draft;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSuccess.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColours.darkSuccess.withValues(alpha: 0.24),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWide = constraints.maxWidth >= 860;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _WizardFlowChip(
                label: 'Draft saved locally',
                accent: AppColours.darkSuccess,
              ),
              const SizedBox(height: 10),
              Text(
                'Hayley can pick up where she left off.',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                draft.firstSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
            ],
          );

          final action = FilledButton.tonalIcon(
            onPressed: onContinue,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Continue draft'),
          );

          if (!useWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 12), action],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: content),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _WizardStepCard extends StatelessWidget {
  const _WizardStepCard({
    super.key,
    required this.step,
    required this.controller,
  });

  final _WizardStepDefinition step;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.9),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WizardFlowChip(label: step.label, accent: AppColours.darkSuccess),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: step.label,
              hintText: step.hint,
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardReviewCard extends StatelessWidget {
  const _WizardReviewCard({
    super.key,
    required this.flow,
    required this.steps,
    required this.controllers,
  });

  final TreasuryWizardFlow flow;
  final List<_WizardStepDefinition> steps;
  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColours.darkSecondary.withValues(alpha: 0.22),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _WizardFlowChip(
            label: 'Review',
            accent: AppColours.darkSecondary,
          ),
          const SizedBox(height: 14),
          ...List.generate(steps.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    steps[index].label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controllers[index].text.isEmpty
                        ? 'Nothing entered yet.'
                        : controllers[index].text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColours.darkText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }),
          Text(
            flow.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
        ],
      ),
    );
  }
}

class _WizardFlowChip extends StatelessWidget {
  const _WizardFlowChip({
    required this.label,
    this.accent = AppColours.darkSecondary,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
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

class _WizardStepDefinition {
  const _WizardStepDefinition({
    required this.label,
    required this.prompt,
    required this.hint,
  });

  final String label;
  final String prompt;
  final String hint;
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
