import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/treasury_controller.dart';
import '../application/treasury_decisions_controller.dart';
import '../data/treasury_folder_service.dart';

class TreasuryDecisionsBoardScreen extends ConsumerWidget {
  const TreasuryDecisionsBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(treasuryWorkspaceProvider);
    final decisions = ref.watch(treasuryDecisionRecordsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Decisions Board'),
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
            tooltip: 'Add decision',
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDecisionDialog(context, ref),
          ),
        ],
      ),
      body: workspace.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _TreasuryBoardSetupHint(
          message:
              'Treasury needs a calm setup before the decisions board can load.',
          actionLabel: 'Open Treasury setup',
          onAction: () => context.go(RouteNames.treasury),
        ),
        data: (snapshot) {
          if (!snapshot.isReady) {
            return _TreasuryBoardSetupHint(
              message:
                  'The finance folder is linked, but Treasury still needs a few files before the decisions board is ready.',
              actionLabel: 'Open Treasury setup',
              onAction: () => context.go(RouteNames.treasury),
            );
          }

          return decisions.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Decisions could not be loaded right now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (records) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _DecisionsSummaryCard(
                    count: records.length,
                    financeRootPath: snapshot.financeRootPath ?? 'Unlinked',
                  ),
                  const SizedBox(height: 14),
                  _DecisionsStateOverviewCard(snapshot: snapshot),
                  const SizedBox(height: 14),
                  _DecisionsActionCard(
                    onAddDecision: () => _showAddDecisionDialog(context, ref),
                  ),
                  const SizedBox(height: 14),
                  if (records.isEmpty)
                    _TreasuryBoardSetupHint(
                      message:
                          'No decisions have been logged yet. Add the first one when a choice needs attention.',
                      actionLabel: 'Add decision',
                      onAction: () => _showAddDecisionDialog(context, ref),
                    )
                  else
                    ...records.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DecisionRecordCard(record: record),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DecisionsStateOverviewCard extends StatelessWidget {
  const _DecisionsStateOverviewCard({required this.snapshot});

  final TreasuryWorkspaceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateCounts = {
      for (final item in snapshot.stateSummaries) item.kind: item.count,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Treasury state overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'A calm glance at the Safe / Watch / Pause / Decision picture before opening the register.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DecisionInfoChip(
                  label: 'Safe ${stateCounts[TreasuryStatusKind.safe] ?? 0}',
                ),
                _DecisionInfoChip(
                  label: 'Watch ${stateCounts[TreasuryStatusKind.watch] ?? 0}',
                ),
                _DecisionInfoChip(
                  label: 'Pause ${stateCounts[TreasuryStatusKind.pause] ?? 0}',
                ),
                _DecisionInfoChip(
                  label:
                      'Decision ${stateCounts[TreasuryStatusKind.decision] ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionsSummaryCard extends StatelessWidget {
  const _DecisionsSummaryCard({
    required this.count,
    required this.financeRootPath,
  });

  final int count;
  final String financeRootPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Decision queue', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              count == 1
                  ? '1 decision is ready for review in the register.'
                  : '$count decisions are ready for review in the register.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Source folder: $financeRootPath',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionsActionCard extends StatelessWidget {
  const _DecisionsActionCard({required this.onAddDecision});

  final VoidCallback onAddDecision;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.28),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: onAddDecision,
              icon: const Icon(Icons.add),
              label: const Text('Add decision'),
            ),
            OutlinedButton.icon(
              onPressed: onAddDecision,
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Open entry form'),
            ),
            TextButton.icon(
              onPressed: () =>
                  context.push(RouteNames.treasuryMonthlySummary),
              icon: const Icon(Icons.assessment_outlined),
              label: const Text('Open monthly summary'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionRecordCard extends StatelessWidget {
  const _DecisionRecordCard({required this.record});

  final TreasuryDecisionRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.tryParse(record.date);
    final formattedDate = date == null
        ? record.date
        : DateFormat('d MMM yyyy').format(date);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.decisionNeeded,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 12),
                _DecisionStatusPill(label: record.status),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DecisionInfoChip(label: formattedDate),
                if (record.amount.isNotEmpty)
                  _DecisionInfoChip(label: record.amount),
                if (record.owner.isNotEmpty)
                  _DecisionInfoChip(label: record.owner),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Decision: ${record.decision.isEmpty ? 'Not recorded yet' : record.decision}',
              style: theme.textTheme.bodyMedium,
            ),
            if (record.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(record.notes, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _DecisionInfoChip extends StatelessWidget {
  const _DecisionInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: theme.textTheme.bodySmall),
      ),
    );
  }
}

class _DecisionStatusPill extends StatelessWidget {
  const _DecisionStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = label.toLowerCase().contains('pause')
        ? const Color(0xFFE26B6B)
        : AppColours.darkSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TreasuryBoardSetupHint extends StatelessWidget {
  const _TreasuryBoardSetupHint({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Treasury setup needed',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 14),
                  FilledButton(onPressed: onAction, child: Text(actionLabel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showAddDecisionDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _AddDecisionDialog(
        onSave: (payload) async {
          await ref
              .read(treasuryDecisionsControllerProvider)
              .saveDecision(
                date: payload.date,
                decisionNeeded: payload.decisionNeeded,
                amount: payload.amount,
                status: payload.status,
                decision: payload.decision,
                owner: payload.owner,
                notes: payload.notes,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Decision saved to the register.')),
            );
          }
        },
      );
    },
  );
}

class _DecisionDraft {
  const _DecisionDraft({
    required this.date,
    required this.decisionNeeded,
    required this.amount,
    required this.status,
    required this.decision,
    required this.owner,
    required this.notes,
  });

  final String date;
  final String decisionNeeded;
  final String amount;
  final String status;
  final String decision;
  final String owner;
  final String notes;
}

class _AddDecisionDialog extends StatefulWidget {
  const _AddDecisionDialog({required this.onSave});

  final Future<void> Function(_DecisionDraft payload) onSave;

  @override
  State<_AddDecisionDialog> createState() => _AddDecisionDialogState();
}

class _AddDecisionDialogState extends State<_AddDecisionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _decisionNeededController = TextEditingController();
  final _amountController = TextEditingController();
  final _decisionController = TextEditingController();
  final _ownerController = TextEditingController();
  final _notesController = TextEditingController();

  String _status = 'Decision';
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  static const _statusOptions = ['Decision', 'Watch', 'Pause', 'Safe'];

  @override
  void dispose() {
    _decisionNeededController.dispose();
    _amountController.dispose();
    _decisionController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('d MMM yyyy').format(_date);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'Add decision',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Capture one calm decision at a time and keep the next action visible.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _decisionNeededController,
                  decoration: const InputDecoration(
                    labelText: 'Decision needed',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please enter what needs a decision.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: const Text('Date'),
                          subtitle: Text(dateLabel),
                          trailing: const Icon(Icons.calendar_today_outlined),
                          onTap: () => _pickDate(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: _statusOptions
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _status = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _decisionController,
                  decoration: const InputDecoration(
                    labelText: 'Decision',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(
                    labelText: 'Owner',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : () => _save(context),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save decision'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() => _date = picked);
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _DecisionDraft(
          date: DateFormat('yyyy-MM-dd').format(_date),
          decisionNeeded: _decisionNeededController.text.trim(),
          amount: _amountController.text.trim(),
          status: _status,
          decision: _decisionController.text.trim(),
          owner: _ownerController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
