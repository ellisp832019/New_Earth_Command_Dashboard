import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/assets_controller.dart';

class ReorderListScreen extends ConsumerStatefulWidget {
  const ReorderListScreen({super.key});

  @override
  ConsumerState<ReorderListScreen> createState() => _ReorderListScreenState();
}

class _ReorderListScreenState extends ConsumerState<ReorderListScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final reorderList = ref.watch(assetReorderListProvider);

    return workspace.when(
      loading: () => WorkspaceShell(
        title: 'Reorder List',
        subtitle: 'Asset reorder workspace',
        onBack: () => Navigator.of(context).maybePop(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WorkspaceShell(
        title: 'Reorder List',
        subtitle: 'Asset reorder workspace',
        onBack: () => Navigator.of(context).maybePop(),
        child: _RegisterError(
          title: 'Reorder List',
          onReload: () => ref.invalidate(assetWorkspaceProvider),
        ),
      ),
      data: (workspaceData) {
        return reorderList.when(
          loading: () => WorkspaceShell(
            title: 'Reorder List',
            subtitle: 'Asset reorder workspace',
            onBack: () => Navigator.of(context).maybePop(),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => WorkspaceShell(
            title: 'Reorder List',
            subtitle: 'Asset reorder workspace',
            onBack: () => Navigator.of(context).maybePop(),
            child: _RegisterError(
              title: 'Reorder List',
              onReload: () => ref.invalidate(assetReorderListProvider),
            ),
          ),
          data: (table) {
            final urgentCount = _countUrgent(table.rows);
            final linkedSuppliers = _countLinkedSuppliers(table.rows);

            return WorkspaceShell(
              title: 'Reorder List',
              subtitle: 'Asset reorder workspace',
              onBack: () => Navigator.of(context).maybePop(),
              child: Stack(
                children: [
                  SafeArea(
                    child: CustomScrollView(
                      slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RegisterHeader(
                              title: 'Reorder List',
                              subtitle:
                                  'Keep future purchases visible without forcing them into the main low-stock list.',
                              countLabel:
                                  '${table.rows.length} reorder entries loaded.',
                              actionLabel: workspaceData.assetsRootPath == null
                                  ? 'Asset folder not linked yet'
                                  : workspaceData.assetsRootPath!,
                              onReload: () {
                                ref.invalidate(assetReorderListProvider);
                              },
                              onBack: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(height: 20),
                            _RegisterSummaryRow(
                              items: [
                                _SummaryMetric(
                                  label: 'Urgent',
                                  value: urgentCount,
                                  accent: AppColours.darkAmber,
                                ),
                                _SummaryMetric(
                                  label: 'Linked suppliers',
                                  value: linkedSuppliers,
                                  accent: AppColours.darkSecondary,
                                ),
                                _SummaryMetric(
                                  label: 'Estimated spend',
                                  value: _estimateSpend(table.rows),
                                  accent: AppColours.darkSuccess,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (table.rows.isEmpty)
                              _EmptyRegisterState(
                                title: 'No reorder entries yet',
                                message:
                                    'Add the first item to keep future purchasing decisions gentle and visible.',
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
                                  return _ReorderCard(row: table.rows[index]);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: FloatingActionButton.extended(
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
                      label: Text(_isSaving ? 'Saving' : 'Add Reorder'),
                    ),
                  ),
                ],
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

    final draft = await showDialog<_ReorderDraft>(
      context: context,
      builder: (context) => const _ReorderDialog(),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(assetRegisterRepositoryProvider).appendReorderRecord(
            assetsRootPath,
            draft.toRow(),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(assetReorderListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reorder entry saved.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int _countUrgent(List<Map<String, String>> rows) {
    return rows.where((row) => _normalized(row['priority']) == 'urgent').length;
  }

  int _countLinkedSuppliers(List<Map<String, String>> rows) {
    return rows
        .where((row) => (row['supplier'] ?? '').trim().isNotEmpty)
        .length;
  }

  int _estimateSpend(List<Map<String, String>> rows) {
    var total = 0;
    for (final row in rows) {
      final quantity = int.tryParse((row['quantity_needed'] ?? '').trim()) ?? 0;
      final cost = double.tryParse((row['estimated_cost'] ?? '').trim()) ?? 0;
      total += (quantity * cost).round();
    }
    return total;
  }

  String _normalized(String? value) {
    return (value ?? '').trim().toLowerCase();
  }
}

class _ReorderCard extends StatelessWidget {
  const _ReorderCard({required this.row});

  final Map<String, String> row;

  @override
  Widget build(BuildContext context) {
    final priority = (row['priority'] ?? 'normal').trim();
    final isUrgent = priority.toLowerCase() == 'urgent';

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
                      : 'Unnamed reorder item',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _StatusPill(
                label: priority,
                accent: isUrgent ? AppColours.darkAmber : AppColours.darkSecondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: row['date'] ?? 'No date'),
              _InfoChip(label: row['project'] ?? 'No project'),
              _InfoChip(
                label: 'Qty ${row['quantity_needed'] ?? '0'}',
              ),
              _InfoChip(
                label: 'Spend ${row['estimated_cost']?.trim().isNotEmpty == true ? row['estimated_cost']!.trim() : '0'}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: row['status'] ?? 'No status'),
              _InfoChip(label: row['supplier'] ?? 'No supplier'),
            ],
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

class _ReorderDialog extends StatefulWidget {
  const _ReorderDialog();

  @override
  State<_ReorderDialog> createState() => _ReorderDialogState();
}

class _ReorderDialogState extends State<_ReorderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _itemController;
  late final TextEditingController _projectController;
  late final TextEditingController _quantityController;
  late final TextEditingController _estimatedCostController;
  late final TextEditingController _supplierController;
  late final TextEditingController _notesController;
  String _priority = 'normal';
  String _status = 'open';

  static const _priorityOptions = [
    'normal',
    'urgent',
    'watch',
  ];

  static const _statusOptions = [
    'open',
    'watch',
    'ordered',
    'parked',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dateController = TextEditingController(text: today);
    _itemController = TextEditingController();
    _projectController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _estimatedCostController = TextEditingController(text: '0');
    _supplierController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _itemController.dispose();
    _projectController.dispose();
    _quantityController.dispose();
    _estimatedCostController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Reorder Entry'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(controller: _dateController, label: 'Date', hintText: '2026-05-28'),
                const SizedBox(height: 12),
                _field(
                  controller: _itemController,
                  label: 'Item',
                  hintText: 'M3 screws',
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter an item name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(controller: _projectController, label: 'Project', hintText: 'MicroGrow'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _quantityController,
                        label: 'Quantity needed',
                        hintText: '5',
                        validator: (value) {
                          if (int.tryParse((value ?? '').trim()) == null) {
                            return 'Enter a number.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _estimatedCostController,
                        label: 'Estimated cost',
                        hintText: '12.50',
                        validator: (value) {
                          if (double.tryParse((value ?? '').trim()) == null) {
                            return 'Enter a number.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(controller: _supplierController, label: 'Supplier', hintText: 'RS Components'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: _priorityOptions
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _priority = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: _statusOptions
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
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
              _ReorderDraft(
                date: _dateController.text.trim(),
                item: _itemController.text.trim(),
                project: _projectController.text.trim(),
                quantityNeeded: _quantityController.text.trim(),
                estimatedCost: _estimatedCostController.text.trim(),
                priority: _priority,
                status: _status,
                supplier: _supplierController.text.trim(),
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

class _ReorderDraft {
  const _ReorderDraft({
    required this.date,
    required this.item,
    required this.project,
    required this.quantityNeeded,
    required this.estimatedCost,
    required this.priority,
    required this.status,
    required this.supplier,
    required this.notes,
  });

  final String date;
  final String item;
  final String project;
  final String quantityNeeded;
  final String estimatedCost;
  final String priority;
  final String status;
  final String supplier;
  final String notes;

  Map<String, String> toRow() {
    return {
      'date': date,
      'item': item,
      'project': project,
      'quantity_needed': quantityNeeded,
      'estimated_cost': estimatedCost,
      'priority': priority,
      'status': status,
      'supplier': supplier,
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
