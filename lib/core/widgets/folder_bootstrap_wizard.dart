import 'package:flutter/material.dart';

import '../utils/folder_bootstrap_result.dart';

class FolderBootstrapWizardStep {
  const FolderBootstrapWizardStep({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

class FolderBootstrapWizardPlan {
  const FolderBootstrapWizardPlan({
    required this.title,
    required this.subtitle,
    required this.steps,
    required this.missingFolders,
    required this.missingFiles,
    this.createLabel = 'Create missing templates',
    this.reloadLabel = 'Reload and continue',
    this.finishLabel = 'Finish',
  });

  final String title;
  final String subtitle;
  final List<FolderBootstrapWizardStep> steps;
  final List<String> missingFolders;
  final List<String> missingFiles;
  final String createLabel;
  final String reloadLabel;
  final String finishLabel;
}

Future<void> showFolderBootstrapWizard({
  required BuildContext context,
  required FolderBootstrapWizardPlan plan,
  required Future<FolderBootstrapCreationResult> Function()
  onCreateMissingStructure,
  required VoidCallback onReload,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return _FolderBootstrapWizardDialog(
        plan: plan,
        onCreateMissingStructure: onCreateMissingStructure,
        onReload: onReload,
      );
    },
  );
}

enum _BootstrapWizardStage { review, create, finish }

class _FolderBootstrapWizardDialog extends StatefulWidget {
  const _FolderBootstrapWizardDialog({
    required this.plan,
    required this.onCreateMissingStructure,
    required this.onReload,
  });

  final FolderBootstrapWizardPlan plan;
  final Future<FolderBootstrapCreationResult> Function()
  onCreateMissingStructure;
  final VoidCallback onReload;

  @override
  State<_FolderBootstrapWizardDialog> createState() =>
      _FolderBootstrapWizardDialogState();
}

class _FolderBootstrapWizardDialogState
    extends State<_FolderBootstrapWizardDialog> {
  _BootstrapWizardStage _stage = _BootstrapWizardStage.review;
  bool _isBusy = false;
  List<String> _createdFolders = <String>[];
  List<String> _createdFiles = <String>[];

  FolderBootstrapWizardPlan get plan => widget.plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stageIndex = switch (_stage) {
      _BootstrapWizardStage.review => 0,
      _BootstrapWizardStage.create => 1,
      _BootstrapWizardStage.finish => 2,
    };

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.85,
                  ),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              plan.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close wizard',
                        onPressed: _isBusy
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StageChip(label: 'Review', active: stageIndex == 0),
                      _StageChip(label: 'Create', active: stageIndex == 1),
                      _StageChip(label: 'Finish', active: stageIndex == 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StageSummaryCard(plan: plan, stage: _stage),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: switch (_stage) {
                      _BootstrapWizardStage.review => _ReviewStageCard(
                        key: const ValueKey('review-stage'),
                        plan: plan,
                      ),
                      _BootstrapWizardStage.create => _CreateStageCard(
                        key: const ValueKey('create-stage'),
                        plan: plan,
                        isBusy: _isBusy,
                      ),
                      _BootstrapWizardStage.finish => _FinishStageCard(
                        key: const ValueKey('finish-stage'),
                        createdFolders: _createdFolders,
                        createdFiles: _createdFiles,
                        isBusy: _isBusy,
                      ),
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isBusy
                            ? null
                            : () {
                                if (_stage == _BootstrapWizardStage.review) {
                                  Navigator.of(context).pop();
                                  return;
                                }

                                setState(() {
                                  _stage = switch (_stage) {
                                    _BootstrapWizardStage.review =>
                                      _BootstrapWizardStage.review,
                                    _BootstrapWizardStage.create =>
                                      _BootstrapWizardStage.review,
                                    _BootstrapWizardStage.finish =>
                                      _BootstrapWizardStage.create,
                                  };
                                });
                              },
                        child: Text(
                          _stage == _BootstrapWizardStage.review
                              ? 'Back to setup'
                              : _stage == _BootstrapWizardStage.create
                              ? 'Back to review'
                              : 'Back to create',
                        ),
                      ),
                      const Spacer(),
                      if (_stage == _BootstrapWizardStage.review)
                        FilledButton(
                          onPressed: _isBusy
                              ? null
                              : () {
                                  setState(
                                    () => _stage = _BootstrapWizardStage.create,
                                  );
                                },
                          child: const Text('Review setup'),
                        )
                      else if (_stage == _BootstrapWizardStage.create)
                        FilledButton(
                          onPressed: _isBusy ? null : _createStructure,
                          child: _isBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(plan.createLabel),
                        )
                      else
                        FilledButton(
                          onPressed: _isBusy
                              ? null
                              : () {
                                  widget.onReload();
                                  Navigator.of(context).pop();
                                },
                          child: Text(plan.reloadLabel),
                        ),
                    ],
                  ),
                  if (_stage == _BootstrapWizardStage.finish) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isBusy
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(plan.finishLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createStructure() async {
    setState(() => _isBusy = true);
    try {
      final result = await widget.onCreateMissingStructure();
      if (!mounted) {
        return;
      }

      setState(() {
        _createdFolders = result.createdFolders;
        _createdFiles = result.createdFiles;
        _stage = _BootstrapWizardStage.finish;
      });
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

class _StageSummaryCard extends StatelessWidget {
  const _StageSummaryCard({required this.plan, required this.stage});

  final FolderBootstrapWizardPlan plan;
  final _BootstrapWizardStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stageIndex = switch (stage) {
      _BootstrapWizardStage.review => 1,
      _BootstrapWizardStage.create => 2,
      _BootstrapWizardStage.finish => 3,
    };
    final stageTitle = switch (stage) {
      _BootstrapWizardStage.review => 'Review the folder link',
      _BootstrapWizardStage.create => 'Create only what is missing',
      _BootstrapWizardStage.finish => 'Confirm the result',
    };
    final stageBody = switch (stage) {
      _BootstrapWizardStage.review =>
        'Check the source-of-truth folder, look at the missing items, then continue when it feels right.',
      _BootstrapWizardStage.create =>
        'The wizard will create only the missing folders and starter files. Existing finance data stays untouched.',
      _BootstrapWizardStage.finish =>
        'Review what was created, then reload the folder health so the main Treasury screen can update.',
    };
    final missingLabel = [
      if (plan.missingFolders.isNotEmpty)
        '${plan.missingFolders.length} folder${plan.missingFolders.length == 1 ? '' : 's'} missing',
      if (plan.missingFiles.isNotEmpty)
        '${plan.missingFiles.length} file${plan.missingFiles.length == 1 ? '' : 's'} missing',
    ].join(' • ');
    final statusLabel = missingLabel.isEmpty
        ? 'Nothing is missing right now'
        : missingLabel;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Step $stageIndex of 3',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _StageChip(label: statusLabel, active: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            stageTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stageBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStageCard extends StatelessWidget {
  const _ReviewStageCard({super.key, required this.plan});

  final FolderBootstrapWizardPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BootstrapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageHeading(
            icon: Icons.visibility_outlined,
            title: 'Review the setup',
            subtitle:
                'This pipeline checks the external folder, then creates only the missing pieces.',
          ),
          const SizedBox(height: 14),
          Text(
            'Wizard steps',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...plan.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StepItem(step: step),
            ),
          ),
          const SizedBox(height: 10),
          if (plan.missingFolders.isNotEmpty) ...[
            Text(
              'Missing folders',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _CompactList(items: plan.missingFolders),
            const SizedBox(height: 14),
          ],
          if (plan.missingFiles.isNotEmpty) ...[
            Text(
              'Missing files',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _CompactList(items: plan.missingFiles),
          ],
          if (plan.missingFolders.isEmpty && plan.missingFiles.isEmpty)
            Text(
              'Nothing is missing right now, but the wizard can still be reused for other business areas later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateStageCard extends StatelessWidget {
  const _CreateStageCard({super.key, required this.plan, required this.isBusy});

  final FolderBootstrapWizardPlan plan;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BootstrapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageHeading(
            icon: Icons.auto_awesome_outlined,
            title: 'Create only the missing structure',
            subtitle:
                'Existing finance files stay untouched. New folders and templates are created locally, one safe step at a time.',
          ),
          const SizedBox(height: 14),
          Text(
            'What this pipeline will create',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _CompactList(
            items: [
              if (plan.missingFolders.isEmpty) 'No new folders are needed.',
              ...plan.missingFolders,
              if (plan.missingFiles.isEmpty) 'No new files are needed.',
              ...plan.missingFiles,
            ],
          ),
          const SizedBox(height: 14),
          if (isBusy)
            Text(
              'Creating the missing structure now...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Text(
              'After this step, the wizard will show the created items and offer a reload.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

class _FinishStageCard extends StatelessWidget {
  const _FinishStageCard({
    super.key,
    required this.createdFolders,
    required this.createdFiles,
    required this.isBusy,
  });

  final List<String> createdFolders;
  final List<String> createdFiles;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BootstrapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageHeading(
            icon: Icons.check_circle_outline,
            title: 'Setup created',
            subtitle:
                'The missing folders and templates are now in place. Reload to let Treasury recheck the folder health.',
          ),
          const SizedBox(height: 14),
          if (createdFolders.isNotEmpty) ...[
            Text(
              'Created folders',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _CompactList(items: createdFolders),
            const SizedBox(height: 14),
          ],
          if (createdFiles.isNotEmpty) ...[
            Text(
              'Created files',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _CompactList(items: createdFiles),
            const SizedBox(height: 14),
          ],
          if (isBusy)
            Text(
              'Working...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _BootstrapCard extends StatelessWidget {
  const _BootstrapCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _StageHeading extends StatelessWidget {
  const _StageHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.step});

  final FolderBootstrapWizardStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(step.icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
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

class _CompactList extends StatelessWidget {
  const _CompactList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.radio_button_unchecked, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.28)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
