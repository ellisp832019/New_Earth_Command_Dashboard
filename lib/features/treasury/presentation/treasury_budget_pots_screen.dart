import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/treasury_budget_pots_controller.dart';
import '../data/treasury_folder_service.dart';

class TreasuryBudgetPotsScreen extends ConsumerWidget {
  const TreasuryBudgetPotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final potsAsync = ref.watch(treasuryBudgetPotsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Budget Pots'),
        leading: IconButton(
          tooltip: 'Back to Treasury',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.go(RouteNames.treasury);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Add pot',
            onPressed: () => _showAddPotDialog(context, ref),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'Reload',
            onPressed: () => ref.invalidate(treasuryBudgetPotsProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Open monthly summary',
            onPressed: () => context.push(RouteNames.treasuryMonthlySummary),
            icon: const Icon(Icons.assessment_outlined),
          ),
        ],
      ),
      body: potsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _BudgetPotsErrorCard(
          onReload: () => ref.invalidate(treasuryBudgetPotsProvider),
        ),
        data: (snapshot) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _BudgetPotsHeroCard(snapshot: snapshot),
                const SizedBox(height: 16),
                _BudgetPotsQuickNavCard(),
                const SizedBox(height: 16),
                _BudgetOverviewCard(snapshot: snapshot),
                const SizedBox(height: 16),
                if (snapshot.editablePots.isEmpty) ...[
                  _BudgetPotsEmptyStateCard(
                    snapshot: snapshot,
                    onAddPot: () => _showAddPotDialog(context, ref),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  const _SectionTitle(
                    icon: Icons.grid_view_rounded,
                    title: 'Saved pots',
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth >= 1240
                          ? 3
                          : constraints.maxWidth >= 760
                          ? 2
                          : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.editablePots.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: crossAxisCount == 1 ? 2.4 : 1.5,
                        ),
                        itemBuilder: (context, index) {
                          final pot = snapshot.editablePots[index];
                          return _BudgetPotCard(
                            pot: pot,
                            onAdjust: () =>
                                _showAdjustPotDialog(context, ref, pot),
                            onMove: snapshot.editablePots.length > 1
                                ? () => _showMovePotDialog(
                                    context,
                                    ref,
                                    pot,
                                    snapshot.editablePots,
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                _BudgetPotsFooterCard(snapshot: snapshot),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BudgetPotsHeroCard extends StatelessWidget {
  const _BudgetPotsHeroCard({required this.snapshot});

  final TreasuryBudgetPotsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money = NumberFormat.currency(symbol: '£', decimalDigits: 2);

    return Container(
      decoration: _cardDecoration(highlighted: true),
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 900;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Pots',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A calm place to think about where money sits before it moves anywhere else.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusPill(
                    label: '${snapshot.editablePots.length} pots visible',
                    accent: AppColours.darkSecondary,
                  ),
                  _StatusPill(
                    label: money.format(snapshot.projectSpendTotal),
                    accent: AppColours.darkPurple,
                  ),
                  _StatusPill(
                    label:
                        'Recurring ${money.format(snapshot.subscriptionTotal)}',
                    accent: AppColours.darkAccent,
                  ),
                ],
              ),
            ],
          );

          final right = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroMetricCard(
                label: 'Monthly committed spend',
                value: money.format(
                  snapshot.projectSpendTotal + snapshot.subscriptionTotal,
                ),
                note:
                    'A simple combined read of project spend and recurring costs.',
                accent: AppColours.darkSuccess,
              ),
              const SizedBox(height: 12),
              _HeroMetricCard(
                label: 'Tracked states',
                value: '${snapshot.editablePots.length} saved pots',
                note:
                    'Each pot stays calm and visible so Hayley knows where attention sits.',
                accent: AppColours.darkSecondary,
              ),
              const SizedBox(height: 12),
              _HeroMetricCard(
                label: 'Saved movements',
                value: '${snapshot.movements.length} entries',
                note: _latestMovementNote(snapshot),
                accent: AppColours.darkAccent,
              ),
            ],
          );

          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(height: 18), right],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 20),
              SizedBox(width: 380, child: right),
            ],
          );
        },
      ),
    );
  }
}

class _BudgetOverviewCard extends StatelessWidget {
  const _BudgetOverviewCard({required this.snapshot});

  final TreasuryBudgetPotsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.view_comfy_alt_outlined,
            title: 'How Treasury is grouped',
          ),
          const SizedBox(height: 12),
          Text(
            'These pots are a calm planning layer built from the current Treasury states. They keep the money picture readable without needing a new file format yet.',
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

class _BudgetPotsQuickNavCard extends StatelessWidget {
  const _BudgetPotsQuickNavCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.route_outlined, title: 'Quick nav'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => context.go(RouteNames.treasury),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Treasury Home'),
              ),
              FilledButton.tonalIcon(
                onPressed: () =>
                    context.push(RouteNames.treasuryMonthlySummary),
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Monthly Summary'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.treasurySettings),
                icon: const Icon(Icons.tune_outlined),
                label: const Text('Settings'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.treasuryDecisions),
                icon: const Icon(Icons.gavel_outlined),
                label: const Text('Decisions'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetPotCard extends StatelessWidget {
  const _BudgetPotCard({
    required this.pot,
    required this.onAdjust,
    required this.onMove,
  });

  final TreasuryBudgetPotRecord pot;
  final VoidCallback onAdjust;
  final VoidCallback? onMove;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForKind(pot.kind);
    final money = NumberFormat.currency(symbol: '£', decimalDigits: 2);
    final delta = pot.balance - pot.target;

    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForKind(pot.kind), color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pot.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusPill(
                label: delta == 0
                    ? 'On target'
                    : delta > 0
                    ? '+${money.format(delta)}'
                    : '-${money.format(delta.abs())}',
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pot.notes,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Balance ${money.format(pot.balance)} · Target ${money.format(pot.target)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onAdjust,
                icon: const Icon(Icons.tune_outlined, size: 16),
                label: const Text('Adjust'),
              ),
              TextButton.icon(
                onPressed: onMove,
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Move'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (pot.items.isEmpty)
            Text(
              'Nothing is listed here yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            )
          else
            ...pot.items
                .take(3)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.radio_button_unchecked,
                          size: 16,
                          color: AppColours.darkAmber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (pot.items.length > 3) ...[
            const SizedBox(height: 4),
            Text(
              '+ ${pot.items.length - 3} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetPotsFooterCard extends StatelessWidget {
  const _BudgetPotsFooterCard({required this.snapshot});

  final TreasuryBudgetPotsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.info_outline, title: 'File status'),
          const SizedBox(height: 12),
          Text(
            snapshot.issues.isEmpty
                ? 'Budget Pots keeps a local pot file inside the Treasury dashboard folder and writes with backups.'
                : snapshot.issues.join('\n'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
          if (snapshot.budgetPotsPath != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusPill(
                  label: 'File ${snapshot.budgetPotsPath}',
                  accent: AppColours.darkSecondary,
                ),
                _StatusPill(
                  label: '${snapshot.movements.length} movements saved',
                  accent: AppColours.darkSuccess,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetPotsEmptyStateCard extends StatelessWidget {
  const _BudgetPotsEmptyStateCard({
    required this.snapshot,
    required this.onAddPot,
  });

  final TreasuryBudgetPotsSnapshot snapshot;
  final VoidCallback onAddPot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.inbox_outlined,
            title: 'No pots saved yet',
          ),
          const SizedBox(height: 12),
          Text(
            'This Treasury file is ready, but no editable pots have been created yet. Add the first calm pot to start shaping the money plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onAddPot,
                icon: const Icon(Icons.add),
                label: const Text('Add first pot'),
              ),
              FilledButton.tonalIcon(
                onPressed: () =>
                    context.push(RouteNames.treasuryMonthlySummary),
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Open monthly summary'),
              ),
            ],
          ),
          if (snapshot.budgetPotsPath != null) ...[
            const SizedBox(height: 14),
            Text(
              'Saved file: ${snapshot.budgetPotsPath}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetPotsErrorCard extends StatelessWidget {
  const _BudgetPotsErrorCard({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.info_outline,
                title: 'Budget Pots',
              ),
              const SizedBox(height: 12),
              Text(
                'Budget Pots could not load right now.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({
    required this.label,
    required this.value,
    required this.note,
    required this.accent,
  });

  final String label;
  final String value;
  final String note;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
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

String _latestMovementNote(TreasuryBudgetPotsSnapshot snapshot) {
  if (snapshot.movements.isEmpty) {
    return 'No movements have been saved yet.';
  }

  final latest = snapshot.movements.last;
  final note = latest.note.trim().isEmpty
      ? 'No note added.'
      : latest.note.trim();
  final summary = '${latest.date} · $note';
  return summary.length > 96 ? '${summary.substring(0, 93)}...' : summary;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
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

Future<void> _showAddPotDialog(BuildContext context, WidgetRef ref) async {
  final titleController = TextEditingController();
  final targetController = TextEditingController(text: '0');
  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var selectedKind = TreasuryBudgetPotKind.future;

  try {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add budget pot'),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Pot name',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Give the pot a name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TreasuryBudgetPotKind>(
                        initialValue: selectedKind,
                        decoration: const InputDecoration(labelText: 'Kind'),
                        items: TreasuryBudgetPotKind.values
                            .map(
                              (kind) => DropdownMenuItem(
                                value: kind,
                                child: Text(_kindLabel(kind)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setDialogState(() => selectedKind = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Target'),
                        validator: (value) {
                          final parsed = double.tryParse(value?.trim() ?? '');
                          if (parsed == null) {
                            return 'Enter a target amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(labelText: 'Notes'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || !context.mounted) {
      return;
    }

    await ref
        .read(treasuryBudgetPotsControllerProvider.notifier)
        .addPot(
          title: titleController.text.trim(),
          notes: notesController.text.trim(),
          target: double.tryParse(targetController.text.trim()) ?? 0,
        );
  } finally {
    titleController.dispose();
    targetController.dispose();
    notesController.dispose();
  }
}

Future<void> _showAdjustPotDialog(
  BuildContext context,
  WidgetRef ref,
  TreasuryBudgetPotRecord pot,
) async {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  try {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Adjust ${pot.title}'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Balance ${NumberFormat.currency(symbol: '£', decimalDigits: 2).format(pot.balance)}',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Change amount',
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(value?.trim() ?? '');
                      if (parsed == null || parsed == 0) {
                        return 'Enter a non-zero amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Note'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true || !context.mounted) {
      return;
    }

    await ref
        .read(treasuryBudgetPotsControllerProvider.notifier)
        .adjustPot(
          potId: pot.id,
          delta: double.tryParse(amountController.text.trim()) ?? 0,
          note: noteController.text.trim(),
        );
  } finally {
    amountController.dispose();
    noteController.dispose();
  }
}

Future<void> _showMovePotDialog(
  BuildContext context,
  WidgetRef ref,
  TreasuryBudgetPotRecord sourcePot,
  List<TreasuryBudgetPotRecord> allPots,
) async {
  final destinationOptions = allPots
      .where((pot) => pot.id != sourcePot.id)
      .toList(growable: false);
  if (destinationOptions.isEmpty) {
    return;
  }

  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var destinationPotId = destinationOptions.first.id;

  try {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('Move from ${sourcePot.title}'),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        'Current balance ${NumberFormat.currency(symbol: '£', decimalDigits: 2).format(sourcePot.balance)}',
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: destinationPotId,
                        decoration: const InputDecoration(
                          labelText: 'Destination pot',
                        ),
                        items: destinationOptions
                            .map(
                              (pot) => DropdownMenuItem(
                                value: pot.id,
                                child: Text(pot.title),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setDialogState(() => destinationPotId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Amount'),
                        validator: (value) {
                          final parsed = double.tryParse(value?.trim() ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a positive amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(labelText: 'Note'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || !context.mounted) {
      return;
    }

    await ref
        .read(treasuryBudgetPotsControllerProvider.notifier)
        .movePot(
          fromPotId: sourcePot.id,
          toPotId: destinationPotId,
          amount: double.tryParse(amountController.text.trim()) ?? 0,
          note: noteController.text.trim(),
        );
  } finally {
    amountController.dispose();
    noteController.dispose();
  }
}

String _kindLabel(TreasuryBudgetPotKind kind) {
  return switch (kind) {
    TreasuryBudgetPotKind.safe => 'Safe',
    TreasuryBudgetPotKind.watch => 'Watch',
    TreasuryBudgetPotKind.pause => 'Pause',
    TreasuryBudgetPotKind.decision => 'Decision',
    TreasuryBudgetPotKind.future => 'Future',
    TreasuryBudgetPotKind.archived => 'Archived',
  };
}

Color _accentForKind(TreasuryStatusKind kind) {
  return switch (kind) {
    TreasuryStatusKind.safe => AppColours.darkSuccess,
    TreasuryStatusKind.watch => AppColours.darkAmber,
    TreasuryStatusKind.pause => const Color(0xFFE26B6B),
    TreasuryStatusKind.decision => AppColours.darkSecondary,
    TreasuryStatusKind.future => AppColours.darkPurple,
    TreasuryStatusKind.archived => AppColours.darkMutedText,
  };
}

IconData _iconForKind(TreasuryStatusKind kind) {
  return switch (kind) {
    TreasuryStatusKind.safe => Icons.savings_outlined,
    TreasuryStatusKind.watch => Icons.visibility_outlined,
    TreasuryStatusKind.pause => Icons.pause_circle_outline,
    TreasuryStatusKind.decision => Icons.gavel_outlined,
    TreasuryStatusKind.future => Icons.auto_awesome_outlined,
    TreasuryStatusKind.archived => Icons.archive_outlined,
  };
}

BoxDecoration _cardDecoration({bool highlighted = false}) {
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
