import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class OrdersTrackerScreen extends ConsumerStatefulWidget {
  const OrdersTrackerScreen({super.key});

  @override
  ConsumerState<OrdersTrackerScreen> createState() =>
      _OrdersTrackerScreenState();
}

class _OrdersTrackerScreenState extends ConsumerState<OrdersTrackerScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final orders = ref.watch(assetOrdersTrackerProvider);

    return workspace.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _RegisterError(
        title: 'Orders Tracker',
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return orders.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _RegisterError(
            title: 'Orders Tracker',
            onReload: () => ref.invalidate(assetOrdersTrackerProvider),
          ),
          data: (table) {
            final pendingCount = _countStatuses(table.rows, const [
              'open',
              'watch',
              'ordered',
            ]);
            final linkedFinance = _countLinkedFinance(table.rows);

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
                label: Text(_isSaving ? 'Saving' : 'Add Order'),
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
                              title: 'Orders Tracker',
                              subtitle:
                                  'Keep supplier orders visible and calm without losing the finance link.',
                              countLabel: '${table.rows.length} orders loaded.',
                              actionLabel: workspaceData.assetsRootPath == null
                                  ? 'Asset folder not linked yet'
                                  : workspaceData.assetsRootPath!,
                              onReload: () {
                                ref.invalidate(assetOrdersTrackerProvider);
                              },
                              onBack: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(height: 20),
                            _RegisterSummaryRow(
                              items: [
                                _SummaryMetric(
                                  label: 'Pending',
                                  value: pendingCount,
                                  accent: AppColours.darkAmber,
                                ),
                                _SummaryMetric(
                                  label: 'Finance linked',
                                  value: linkedFinance,
                                  accent: AppColours.darkSecondary,
                                ),
                                _SummaryMetric(
                                  label: 'Total spend',
                                  value: _estimateSpend(table.rows),
                                  accent: AppColours.darkSuccess,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const _OrderActionStrip(),
                            const SizedBox(height: 20),
                            if (table.rows.isEmpty)
                              _EmptyRegisterState(
                                title: 'No orders yet',
                                message:
                                    'Add the first order to keep supplier follow-up and receipts tidy.',
                                onAdd: workspaceData.assetsRootPath == null
                                    ? null
                                    : () => _addRecord(
                                        workspaceData.assetsRootPath!,
                                      ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: table.rows.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final row = table.rows[index];
                                  return _OrderCard(
                                    row: row,
                                    onEdit: workspaceData.assetsRootPath == null
                                        ? null
                                        : () => _editRecord(
                                            workspaceData.assetsRootPath!,
                                            row,
                                          ),
                                    onDelete:
                                        workspaceData.assetsRootPath == null
                                        ? null
                                        : () => _deleteRecord(
                                            workspaceData.assetsRootPath!,
                                            row,
                                          ),
                                  );
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

    final draft = await showDialog<_OrderDraft>(
      context: context,
      builder: (context) => const _OrderDialog(),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .appendOrderRecord(assetsRootPath, draft.toRow());
      if (!mounted) {
        return;
      }
      ref.invalidate(assetOrdersTrackerProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _editRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    if (_isSaving) {
      return;
    }

    final draft = await showDialog<_OrderDraft>(
      context: context,
      builder: (context) => _OrderDialog(existingRow: row),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedRow = draft.toRow();
      updatedRow['order_id'] = row['order_id'] ?? updatedRow['order_id'] ?? '';
      await ref
          .read(assetRegisterRepositoryProvider)
          .updateOrderRecord(assetsRootPath, updatedRow);
      if (!mounted) {
        return;
      }
      ref.invalidate(assetOrdersTrackerProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order updated.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    if (_isSaving) {
      return;
    }

    final orderId = (row['order_id'] ?? '').trim();
    final label = (row['item'] ?? '').trim().isNotEmpty == true
        ? row['item']!.trim()
        : orderId.isEmpty
        ? 'this order'
        : orderId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete order entry?'),
        content: Text(
          'Remove $label from the tracker? This only deletes the row from the local CSV file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColours.darkAmber,
              foregroundColor: AppColours.darkText,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .deleteOrderRecord(assetsRootPath, orderId);
      if (!mounted) {
        return;
      }
      ref.invalidate(assetOrdersTrackerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label removed from the tracker.')),
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
        .where((row) => (row['finance_record_id'] ?? '').trim().isNotEmpty)
        .length;
  }

  int _estimateSpend(List<Map<String, String>> rows) {
    var total = 0;
    for (final row in rows) {
      final quantity = int.tryParse((row['quantity'] ?? '').trim()) ?? 0;
      final cost = double.tryParse((row['total_cost'] ?? '').trim()) ?? 0;
      if (cost > 0) {
        total += cost.round();
      } else {
        total += quantity;
      }
    }
    return total;
  }

  String _normalized(String? value) {
    return (value ?? '').trim().toLowerCase();
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.row, this.onEdit, this.onDelete});

  final Map<String, String> row;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? 'open').trim();
    final isOpen =
        status.toLowerCase() == 'open' || status.toLowerCase() == 'watch';

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
                      : 'Untitled order',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(
                label: status,
                accent: isOpen ? AppColours.darkAmber : AppColours.darkSuccess,
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit order',
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete order',
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: row['order_id'] ?? 'No order ID'),
              _InfoChip(label: row['date'] ?? 'No date'),
              _InfoChip(label: row['supplier'] ?? 'No supplier'),
              _InfoChip(label: row['project'] ?? 'No project'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Qty ${row['quantity'] ?? '0'}'),
              _InfoChip(
                label:
                    'Total ${row['total_cost']?.trim().isNotEmpty == true ? row['total_cost']!.trim() : '0'}',
              ),
              _InfoChip(
                label: row['receipt_link']?.trim().isNotEmpty == true
                    ? 'Receipt linked'
                    : 'No receipt',
              ),
              _InfoChip(
                label: row['finance_record_id']?.trim().isNotEmpty == true
                    ? 'Finance linked'
                    : 'No finance link',
              ),
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

class _OrderActionStrip extends StatelessWidget {
  const _OrderActionStrip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 860;
          final actions = [
            FilledButton.icon(
              onPressed: () => context.push(RouteNames.assetSupplierRegister),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Open Supplier Register'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(RouteNames.assetLowStock),
              icon: const Icon(Icons.trending_down_outlined),
              label: const Text('Open Low Stock / Reorder'),
            ),
          ];

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.call_split_outlined,
                    color: AppColours.darkSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Follow-up',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Orders often need a supplier check or a low stock review next. Keep the handoff easy.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 14),
                Wrap(spacing: 10, runSpacing: 10, children: actions),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 16),
              SizedBox(
                width: 430,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(spacing: 10, runSpacing: 10, children: actions),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderDialog extends StatefulWidget {
  const _OrderDialog({this.existingRow});

  final Map<String, String>? existingRow;

  @override
  State<_OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<_OrderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _supplierController;
  late final TextEditingController _itemController;
  late final TextEditingController _projectController;
  late final TextEditingController _quantityController;
  late final TextEditingController _totalCostController;
  late final TextEditingController _trackingController;
  late final TextEditingController _receiptController;
  late final TextEditingController _financeController;
  late final TextEditingController _notesController;
  String _status = 'open';

  static const _statusOptions = [
    'open',
    'watch',
    'ordered',
    'received',
    'parked',
  ];

  @override
  void initState() {
    super.initState();
    final row = widget.existingRow;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dateController = TextEditingController(text: row?['date'] ?? today);
    _supplierController = TextEditingController(text: row?['supplier'] ?? '');
    _itemController = TextEditingController(text: row?['item'] ?? '');
    _projectController = TextEditingController(text: row?['project'] ?? '');
    _quantityController = TextEditingController(text: row?['quantity'] ?? '1');
    _totalCostController = TextEditingController(
      text: row?['total_cost'] ?? '0',
    );
    _trackingController = TextEditingController(text: row?['tracking'] ?? '');
    _receiptController = TextEditingController(
      text: row?['receipt_link'] ?? '',
    );
    _financeController = TextEditingController(
      text: row?['finance_record_id'] ?? '',
    );
    _notesController = TextEditingController(text: row?['notes'] ?? '');
    _status = row?['status']?.trim().isNotEmpty == true
        ? row!['status']!.trim()
        : 'open';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _supplierController.dispose();
    _itemController.dispose();
    _projectController.dispose();
    _quantityController.dispose();
    _totalCostController.dispose();
    _trackingController.dispose();
    _receiptController.dispose();
    _financeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRow != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Order' : 'Add Order'),
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
                  controller: _supplierController,
                  label: 'Supplier',
                  hintText: 'RS Components',
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter a supplier.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _itemController,
                  label: 'Item',
                  hintText: 'M3 screws',
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter an item.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _projectController,
                  label: 'Project',
                  hintText: 'MicroGrow',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _quantityController,
                        label: 'Quantity',
                        hintText: '10',
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
                        controller: _totalCostController,
                        label: 'Total cost',
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
                _field(
                  controller: _trackingController,
                  label: 'Tracking',
                  hintText: 'TRACK-001',
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _receiptController,
                  label: 'Receipt link',
                  hintText: 'file or URL',
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _financeController,
                  label: 'Finance record ID',
                  hintText: 'FIN-123',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: _statusOptions
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
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
              _OrderDraft(
                date: _dateController.text.trim(),
                supplier: _supplierController.text.trim(),
                item: _itemController.text.trim(),
                project: _projectController.text.trim(),
                quantity: _quantityController.text.trim(),
                totalCost: _totalCostController.text.trim(),
                status: _status,
                tracking: _trackingController.text.trim(),
                receiptLink: _receiptController.text.trim(),
                financeRecordId: _financeController.text.trim(),
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
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label, hintText: hintText),
      validator: validator,
    );
  }
}

class _OrderDraft {
  const _OrderDraft({
    required this.date,
    required this.supplier,
    required this.item,
    required this.project,
    required this.quantity,
    required this.totalCost,
    required this.status,
    required this.tracking,
    required this.receiptLink,
    required this.financeRecordId,
    required this.notes,
  });

  final String date;
  final String supplier;
  final String item;
  final String project;
  final String quantity;
  final String totalCost;
  final String status;
  final String tracking;
  final String receiptLink;
  final String financeRecordId;
  final String notes;

  Map<String, String> toRow() {
    return {
      'order_id': 'NE-ORDER-${DateTime.now().microsecondsSinceEpoch}',
      'date': date,
      'supplier': supplier,
      'item': item,
      'project': project,
      'quantity': quantity,
      'total_cost': totalCost,
      'status': status,
      'tracking': tracking,
      'receipt_link': receiptLink,
      'finance_record_id': financeRecordId,
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
          for (final item in items) Expanded(child: _SummaryTile(metric: item)),
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColours.darkMutedText),
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
