import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../application/business_controller.dart';
import '../data/business_repository.dart';

class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(businessItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.dashboard),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            key: const Key('addBusinessItemButton'),
            onPressed: () => context.push(RouteNames.newBusiness),
            icon: const Icon(Icons.add),
            tooltip: 'Add Opportunity',
          ),
        ],
      ),
      body: items.when(
        data: (businessItems) {
          if (businessItems.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _BusinessSetupCard(
                  onOpenSetupWizard: () {
                    _showBusinessSetupWizard(
                      context,
                      onStartCreating: () =>
                          context.push(RouteNames.newBusiness),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No business items yet. Capture a lead when it feels useful.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: businessItems.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _BusinessOverviewCard(itemCount: businessItems.length);
              }

              if (index == 1) {
                return _BusinessHintCard();
              }

              return _BusinessItemCard(item: businessItems[index - 2]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Business opportunities could not be loaded. Try again in a moment.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

void _showBusinessSetupWizard(
  BuildContext context, {
  required VoidCallback onStartCreating,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _BusinessSetupWizardDialog(onStartCreating: onStartCreating);
    },
  );
}

class _BusinessSetupCard extends StatelessWidget {
  const _BusinessSetupCard({required this.onOpenSetupWizard});

  final VoidCallback onOpenSetupWizard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.22),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Business setup wizard', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Use a calm guided flow to set up the first opportunity. The same pattern can be reused for future business areas later.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onOpenSetupWizard,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Open setup wizard'),
                ),
                TextButton.icon(
                  onPressed: () => context.push(RouteNames.newBusiness),
                  icon: const Icon(Icons.add),
                  label: const Text('Add opportunity'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessSetupWizardDialog extends StatefulWidget {
  const _BusinessSetupWizardDialog({required this.onStartCreating});

  final VoidCallback onStartCreating;

  @override
  State<_BusinessSetupWizardDialog> createState() =>
      _BusinessSetupWizardDialogState();
}

enum _BusinessWizardStage { review, create, finish }

class _BusinessSetupWizardDialogState
    extends State<_BusinessSetupWizardDialog> {
  _BusinessWizardStage _stage = _BusinessWizardStage.review;
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stageIndex = switch (_stage) {
      _BusinessWizardStage.review => 0,
      _BusinessWizardStage.create => 1,
      _BusinessWizardStage.finish => 2,
    };

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business setup wizard',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A calm onboarding flow for the first opportunity, with a reusable shape for future business areas.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isBusy
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _BusinessWizardChip(label: 'Review', active: stageIndex == 0),
                  _BusinessWizardChip(label: 'Create', active: stageIndex == 1),
                  _BusinessWizardChip(label: 'Finish', active: stageIndex == 2),
                ],
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (_stage) {
                  _BusinessWizardStage.review => const _BusinessWizardStepCard(
                    key: ValueKey('business-review-step'),
                    title: 'Review the flow',
                    body:
                        'We keep the first step simple: review the area, then move into the first opportunity form only when it feels ready.',
                    bullets: [
                      'Capture one lead at a time.',
                      'Keep the next action visible.',
                      'Reuse the same flow shape for future areas.',
                    ],
                  ),
                  _BusinessWizardStage.create => const _BusinessWizardStepCard(
                    key: ValueKey('business-create-step'),
                    title: 'Create the first opportunity',
                    body:
                        'Use the existing opportunity form, already wired to the dashboard data model, so this setup remains local-first and simple.',
                    bullets: [
                      'Add a name and a practical next step.',
                      'Link it to a project if helpful.',
                      'Leave optional details blank for now.',
                    ],
                  ),
                  _BusinessWizardStage.finish => const _BusinessWizardStepCard(
                    key: ValueKey('business-finish-step'),
                    title: 'Finish and continue',
                    body:
                        'Once the first opportunity exists, the Business screen becomes the home for future reviews, follow-ups, and outreach.',
                    bullets: [
                      'Return to the list when done.',
                      'The wizard can be reopened later if needed.',
                    ],
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
                            if (_stage == _BusinessWizardStage.review) {
                              Navigator.of(context).pop();
                              return;
                            }

                            setState(() {
                              _stage = switch (_stage) {
                                _BusinessWizardStage.review =>
                                  _BusinessWizardStage.review,
                                _BusinessWizardStage.create =>
                                  _BusinessWizardStage.review,
                                _BusinessWizardStage.finish =>
                                  _BusinessWizardStage.create,
                              };
                            });
                          },
                    child: Text(
                      _stage == _BusinessWizardStage.review ? 'Close' : 'Back',
                    ),
                  ),
                  const Spacer(),
                  if (_stage == _BusinessWizardStage.review)
                    FilledButton(
                      onPressed: _isBusy
                          ? null
                          : () => setState(
                              () => _stage = _BusinessWizardStage.create,
                            ),
                      child: const Text('Continue'),
                    )
                  else if (_stage == _BusinessWizardStage.create)
                    FilledButton(
                      onPressed: _isBusy ? null : _startCreating,
                      child: _isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Open opportunity form'),
                    )
                  else
                    FilledButton(
                      onPressed: _isBusy
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: const Text('Done'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startCreating() async {
    setState(() => _isBusy = true);
    try {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      widget.onStartCreating();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

class _BusinessWizardStepCard extends StatelessWidget {
  const _BusinessWizardStepCard({
    super.key,
    required this.title,
    required this.body,
    required this.bullets,
  });

  final String title;
  final String body;
  final List<String> bullets;

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
            const SizedBox(height: 14),
            ...bullets.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_unchecked, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(bullet, style: theme.textTheme.bodySmall),
                    ),
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

class _BusinessWizardChip extends StatelessWidget {
  const _BusinessWizardChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BusinessOverviewCard extends StatelessWidget {
  const _BusinessOverviewCard({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Business overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              itemCount == 1
                  ? '1 opportunity is ready to review.'
                  : '$itemCount opportunities are ready to review.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Keep the next move small, practical, and easy to follow up on.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessHintCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BusinessHintChip(
              icon: Icons.work_outline,
              label: 'Capture one lead',
            ),
            _BusinessHintChip(
              icon: Icons.follow_the_signs_outlined,
              label: 'Keep the next action visible',
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessItemCard extends StatelessWidget {
  const _BusinessItemCard({required this.item});

  final BusinessListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = item.item.name;
    final deadline = item.item.deadline == null
        ? 'Not set'
        : DateFormat('d MMM yyyy').format(item.item.deadline!);
    final followUpDate = item.item.followUpDate == null
        ? 'Not set'
        : DateFormat('d MMM yyyy').format(item.item.followUpDate!);
    final statusLabel = 'Status: ${item.item.status}';
    final typeLabel = item.item.type;
    final projectLabel = item.projectName;

    return Card(
      key: Key('businessItemCard-${item.item.businessOpportunityId}'),
      child: InkWell(
        onTap: () => GoRouter.of(
          context,
        ).push(RouteNames.editBusiness(item.item.businessOpportunityId)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (typeLabel != null && typeLabel.isNotEmpty)
                    _BusinessInfoChip(label: typeLabel),
                  if (projectLabel != null)
                    _BusinessInfoChip(label: projectLabel),
                  _BusinessInfoChip(label: statusLabel),
                ],
              ),
              const SizedBox(height: 10),
              Text('Deadline: $deadline', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                "Next Step: ${item.item.nextAction ?? 'Choose the next practical move.'}",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Follow-Up: $followUpDate',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessInfoChip extends StatelessWidget {
  const _BusinessInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: theme.textTheme.bodySmall),
      ),
    );
  }
}

class _BusinessHintChip extends StatelessWidget {
  const _BusinessHintChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
