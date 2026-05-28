import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class MaintenanceLogScreen extends ConsumerStatefulWidget {
  const MaintenanceLogScreen({super.key});

  @override
  ConsumerState<MaintenanceLogScreen> createState() =>
      _MaintenanceLogScreenState();
}

class _MaintenanceLogScreenState extends ConsumerState<MaintenanceLogScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final maintenance = ref.watch(assetMaintenanceLogProvider);

    return workspace.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _RegisterError(
        title: 'Maintenance Log',
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return maintenance.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _RegisterError(
            title: 'Maintenance Log',
            onReload: () => ref.invalidate(assetMaintenanceLogProvider),
          ),
          data: (table) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: _isSaving || workspaceData.assetsRootPath == null
                    ? null
                    : () => _addRecord(workspaceData.assetsRootPath!),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_isSaving ? 'Saving' : 'Add Log'),
              ),
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RegisterHeader(
                              title: 'Maintenance Log',
                              subtitle:
                                  'Track repairs and follow-up work without making the workflow feel heavy.',
                              countLabel:
                                  '${table.rows.length} maintenance records loaded.',
                              actionLabel: workspaceData.assetsRootPath == null
                                  ? 'Asset folder not linked yet'
                                  : workspaceData.assetsRootPath!,
                              onReload: () {
                                ref.invalidate(assetMaintenanceLogProvider);
                              },
                              onBack: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(height: 20),
                            _RegisterSummaryRow(
                              items: [
                                _SummaryMetric(
                                  label: 'Open',
                                  value: _countStatuses(
                                    table.rows,
                                    const ['open', 'in_progress', 'waiting_parts'],
                                  ),
                                  accent: AppColours.darkAmber,
                                ),
                                _SummaryMetric(
                                  label: 'Done',
                                  value: _countStatuses(
                                    table.rows,
                                    const ['done', 'closed'],
                                  ),
                                  accent: AppColours.darkSuccess,
                                ),
                                _SummaryMetric(
                                  label: 'Finance linked',
                                  value: _countLinkedFinance(table.rows),
                                  accent: AppColours.darkSecondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (table.rows.isEmpty)
                              _EmptyRegisterState(
                                title: 'No maintenance logs yet',
                                message:
                                    'Add the first repair note or follow-up action so maintenance history stays easy to read later.',
                                onAdd: workspaceData.assetsRootPath == null
                                    ? null
                                    : () => _addRecord(workspaceData.assetsRootPath!),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: table.rows.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _MaintenanceCard(row: table.rows[index]);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addRecord(String assetsRootPath) async {
    if (_isSaving) {
      return;
    }

    final draft = await showDialog<_MaintenanceDraft>(
      context: context,
      builder: (context) => const _MaintenanceDialog(),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(assetRegisterRepositoryProvider).appendMaintenanceRecord(
            assetsRootPath,
            draft.toRow(),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(assetMaintenanceLogProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance log saved.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int _countStatuses(List<Map<String, String>> rows, List<String> values) {
    return rows.where((row) {
      final status = _normalized(row['status']);
      return values.contains(status);
    }).length;
  }

  int _countLinkedFinance(List<Map<String, String>> rows) {
    return rows
        .where((row) => (row['linked_finance_record'] ?? '').trim().isNotEmpty)
        .length;
  }

  String _normalized(String? value) {
    return (value ?? '').trim().toLowerCase();
  }
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({required this.row});

  final Map<String, String> row;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? 'open').trim();
    final isDone = status == 'done' || status == 'closed';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row['item']?.trim().isNotEmpty == true
                      ? row['item']!.trim()
                      : 'Untitled maintenance item',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _StatusPill(
                label: status,
                accent: isDone ? AppColours.darkSuccess : AppColours.darkAmber,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: row['date'] ?? 'No date'),
              _InfoChip(label: row['asset_id'] ?? 'No asset ID'),
              _InfoChip(label: row['cost']?.trim().isNotEmpty == true ? 'Cost ${row['cost']!.trim()}' : 'No cost'),
              _InfoChip(
                label: row['linked_finance_record']?.trim().isNotEmpty == true
                    ? 'Finance ${row['linked_finance_record']!.trim()}'
                    : 'No finance link',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            row['issue']?.trim().isNotEmpty == true
                ? 'Issue: ${row['issue']!.trim()}'
                : 'Issue noted, with no extra details yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            row['action']?.trim().isNotEmpty == true
                ? 'Action: ${row['action']!.trim()}'
                : 'Action still parked for now.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
          ),
          if ((row['notes'] ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              row['notes']!.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.35,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MaintenanceDialog extends StatefulWidget {
  const _MaintenanceDialog();

  @override
  State<_MaintenanceDialog> createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends State<_MaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _assetIdController;
  late final TextEditingController _itemController;
  late final TextEditingController _issueController;
  late final TextEditingController _actionController;
  late final TextEditingController _costController;
  late final TextEditingController _financeController;
  late final TextEditingController _notesController;
  String _status = 'open';

  static const _statusOptions = [
    'open',
    'in_progress',
    'waiting_parts',
    'done',
    'closed',
    'parked',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dateController = TextEditingController(text: today);
    _assetIdController = TextEditingController();
    _itemController = TextEditingController();
    _issueController = TextEditingController();
    _actionController = TextEditingController();
    _costController = TextEditingController();
    _financeController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _assetIdController.dispose();
    _itemController.dispose();
    _issueController.dispose();
    _actionController.dispose();
    _costController.dispose();
    _financeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Maintenance Log'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(
                  controller: _dateController,
                  label: 'Date',
                  hintText: '2026-05-28',
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _assetIdController,
                  label: 'Asset ID',
                  hintText: 'NE-EQ-0001',
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _itemController,
                  label: 'Item',
                  hintText: 'Field scanner',
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter an item name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(controller: _issueController, label: 'Issue', hintText: 'Screen flickering'),
                const SizedBox(height: 12),
                _field(controller: _actionController, label: 'Action', hintText: 'Replace cable'),
                const SizedBox(height: 12),
                _field(controller: _costController, label: 'Cost', hintText: '12.50'),
                const SizedBox(height: 12),
                _field(
                  controller: _financeController,
                  label: 'Linked finance record',
                  hintText: 'FIN-123',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: _statusOptions
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional context',
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }

            Navigator.of(context).pop(
              _MaintenanceDraft(
                date: _dateController.text.trim(),
                assetId: _assetIdController.text.trim(),
                item: _itemController.text.trim(),
                issue: _issueController.text.trim(),
                action: _actionController.text.trim(),
                status: _status,
                cost: _costController.text.trim(),
                linkedFinanceRecord: _financeController.text.trim(),
                notes: _notesController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hintText),
      validator: validator,
    );
  }
}

class _MaintenanceDraft {
  const _MaintenanceDraft({
    required this.date,
    required this.assetId,
    required this.item,
    required this.issue,
    required this.action,
    required this.status,
    required this.cost,
    required this.linkedFinanceRecord,
    required this.notes,
  });

  final String date;
  final String assetId;
  final String item;
  final String issue;
  final String action;
  final String status;
  final String cost;
  final String linkedFinanceRecord;
  final String notes;

  Map<String, String> toRow() {
    return {
      'date': date,
      'asset_id': assetId,
      'item': item,
      'issue': issue,
      'action': action,
      'status': status,
      'cost': cost,
      'linked_finance_record': linkedFinanceRecord,
      'notes': notes,
    };
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.actionLabel,
    required this.onReload,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final String countLabel;
  final String actionLabel;
  final VoidCallback onReload;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColours.darkText,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(label: countLabel),
              _InfoChip(label: actionLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterSummaryRow extends StatelessWidget {
  const _RegisterSummaryRow({required this.items});

  final List<_SummaryMetric> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout = constraints.maxWidth >= 840;
        final children = [
          for (final item in items)
            Expanded(child: _SummaryTile(metric: item)),
        ];

        if (useWideLayout) {
          return Row(
            children: [
              children[0],
              const SizedBox(width: 12),
              children[1],
              const SizedBox(width: 12),
              children[2],
            ],
          );
        }

        return Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _SummaryTile(metric: items[index]),
              if (index != items.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.metric});

  final _SummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: metric.accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${metric.value}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRegisterState extends StatelessWidget {
  const _EmptyRegisterState({
    required this.title,
    required this.message,
    required this.onAdd,
  });

  final String title;
  final String message;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add first item'),
            ),
          ],
        ],
      ),
    );
  }
}

class _RegisterError extends StatelessWidget {
  const _RegisterError({required this.title, required this.onReload});

  final String title;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title could not load right now.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
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

class _SummaryMetric {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkMutedText,
              fontWeight: FontWeight.w600,
            ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
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
