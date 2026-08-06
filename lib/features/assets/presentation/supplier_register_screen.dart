import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class SupplierRegisterScreen extends ConsumerStatefulWidget {
  const SupplierRegisterScreen({super.key});

  @override
  ConsumerState<SupplierRegisterScreen> createState() =>
      _SupplierRegisterScreenState();
}

class _SupplierRegisterScreenState
    extends ConsumerState<SupplierRegisterScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final suppliers = ref.watch(assetSupplierRegisterProvider);

    return workspace.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _RegisterError(
        title: 'Supplier Register',
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return suppliers.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _RegisterError(
            title: 'Supplier Register',
            onReload: () => ref.invalidate(assetSupplierRegisterProvider),
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
                label: Text(_isSaving ? 'Saving' : 'Add Supplier'),
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
                              title: 'Supplier Register',
                              subtitle:
                                  'Keep supplier details tidy so ordering stays calm and quick.',
                              countLabel:
                                  '${table.rows.length} suppliers loaded.',
                              actionLabel: workspaceData.assetsRootPath == null
                                  ? 'Asset folder not linked yet'
                                  : workspaceData.assetsRootPath!,
                              onReload: () {
                                ref.invalidate(assetSupplierRegisterProvider);
                              },
                              onBack: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(height: 20),
                            _RegisterSummaryRow(
                              items: [
                                _SummaryMetric(
                                  label: 'Preferred',
                                  value: _countPreferred(table.rows),
                                  accent: AppColours.darkSuccess,
                                ),
                                _SummaryMetric(
                                  label: 'Reliable',
                                  value: _countReliable(table.rows),
                                  accent: AppColours.darkSecondary,
                                ),
                                _SummaryMetric(
                                  label: 'Categories',
                                  value: _countDistinctCategories(table.rows),
                                  accent: AppColours.darkAmber,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const _SupplierActionStrip(),
                            const SizedBox(height: 20),
                            if (table.rows.isEmpty)
                              _EmptyRegisterState(
                                title: 'No suppliers yet',
                                message:
                                    'Add the first supplier so ordering and maintenance links stay easy to follow.',
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
                                  return _SupplierCard(
                                    row: row,
                                    onEdit: workspaceData.assetsRootPath == null
                                        ? null
                                        : () => _editRecord(
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

    final draft = await showDialog<_SupplierDraft>(
      context: context,
      builder: (context) => const _SupplierDialog(),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .appendSupplierRecord(assetsRootPath, draft.toRow());
      if (!mounted) {
        return;
      }
      ref.invalidate(assetSupplierRegisterProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Supplier saved.')));
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

    final draft = await showDialog<_SupplierDraft>(
      context: context,
      builder: (context) => _SupplierDialog(existingRow: row),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .updateSupplierRecord(assetsRootPath, draft.toRow());
      if (!mounted) {
        return;
      }
      ref.invalidate(assetSupplierRegisterProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Supplier updated.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int _countPreferred(List<Map<String, String>> rows) {
    return rows.where((row) => _normalized(row['preferred']) == 'yes').length;
  }

  int _countReliable(List<Map<String, String>> rows) {
    return rows.where((row) {
      final reliability = _normalized(row['reliability']);
      return reliability == 'good' ||
          reliability == 'high' ||
          reliability == 'excellent';
    }).length;
  }

  int _countDistinctCategories(List<Map<String, String>> rows) {
    final categories = <String>{};
    for (final row in rows) {
      final category = (row['category'] ?? '').trim();
      if (category.isNotEmpty) {
        categories.add(category);
      }
    }
    return categories.length;
  }

  String _normalized(String? value) {
    return (value ?? '').trim().toLowerCase();
  }
}

class _SupplierActionStrip extends StatelessWidget {
  const _SupplierActionStrip();

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
              onPressed: () => context.push(RouteNames.assetOrdersTracker),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Open Orders Tracker'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(RouteNames.assetLowStock),
              icon: const Icon(Icons.trending_down_outlined),
              label: const Text('Open Low Stock / Reorder'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(RouteNames.assetRepairSummary),
              icon: const Icon(Icons.build_circle_outlined),
              label: const Text('Open Repair Summary'),
            ),
          ];

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward_outlined,
                    color: AppColours.darkSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Next actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColours.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Use supplier details when ordering, reordering, or checking repair-related parts.',
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
                width: 500,
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

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({required this.row, this.onEdit});

  final Map<String, String> row;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final preferred = (row['preferred'] ?? '').trim().toLowerCase() == 'yes';

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
                  row['name']?.trim().isNotEmpty == true
                      ? row['name']!.trim()
                      : 'Unnamed supplier',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(
                label: preferred ? 'preferred' : 'listed',
                accent: preferred
                    ? AppColours.darkSuccess
                    : AppColours.darkSecondary,
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit supplier',
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: row['supplier_id'] ?? 'No ID'),
              _InfoChip(label: row['category'] ?? 'No category'),
              _InfoChip(label: row['website'] ?? 'No website'),
              _InfoChip(label: row['reliability'] ?? 'No reliability'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Delivery: ${row['delivery_speed'] ?? 'n/a'}'),
              _InfoChip(label: 'Quality: ${row['quality'] ?? 'n/a'}'),
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

class _SupplierDialog extends StatefulWidget {
  const _SupplierDialog({this.existingRow});

  final Map<String, String>? existingRow;

  @override
  State<_SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<_SupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _supplierIdController;
  late final TextEditingController _nameController;
  late final TextEditingController _websiteController;
  late final TextEditingController _categoryController;
  late final TextEditingController _reliabilityController;
  late final TextEditingController _deliverySpeedController;
  late final TextEditingController _qualityController;
  late final TextEditingController _notesController;
  String _preferred = 'no';

  @override
  void initState() {
    super.initState();
    final row = widget.existingRow;
    _supplierIdController = TextEditingController(
      text: row?['supplier_id'] ?? '',
    );
    _nameController = TextEditingController(text: row?['name'] ?? '');
    _websiteController = TextEditingController(text: row?['website'] ?? '');
    _categoryController = TextEditingController(text: row?['category'] ?? '');
    _reliabilityController = TextEditingController(
      text: row?['reliability'] ?? '',
    );
    _deliverySpeedController = TextEditingController(
      text: row?['delivery_speed'] ?? '',
    );
    _qualityController = TextEditingController(text: row?['quality'] ?? '');
    _notesController = TextEditingController(text: row?['notes'] ?? '');
    _preferred = row?['preferred']?.trim().isNotEmpty == true
        ? row!['preferred']!.trim().toLowerCase()
        : 'no';
  }

  @override
  void dispose() {
    _supplierIdController.dispose();
    _nameController.dispose();
    _websiteController.dispose();
    _categoryController.dispose();
    _reliabilityController.dispose();
    _deliverySpeedController.dispose();
    _qualityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRow != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Supplier' : 'Add Supplier'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(
                  controller: _supplierIdController,
                  label: 'Supplier ID',
                  hintText: 'SUP-001',
                  enabled: !isEditing,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter a supplier ID.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _nameController,
                  label: 'Name',
                  hintText: 'RS Components',
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter a name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _websiteController,
                  label: 'Website',
                  hintText: 'https://...',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _categoryController,
                  label: 'Category',
                  hintText: 'Electronics / Fasteners',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _reliabilityController,
                        label: 'Reliability',
                        hintText: 'good',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _deliverySpeedController,
                        label: 'Delivery speed',
                        hintText: 'fast',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _qualityController,
                  label: 'Quality',
                  hintText: 'steady',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _preferred,
                  decoration: const InputDecoration(labelText: 'Preferred'),
                  items: const [
                    DropdownMenuItem(value: 'no', child: Text('no')),
                    DropdownMenuItem(value: 'yes', child: Text('yes')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _preferred = value);
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
              _SupplierDraft(
                supplierId: _supplierIdController.text.trim(),
                name: _nameController.text.trim(),
                website: _websiteController.text.trim(),
                category: _categoryController.text.trim(),
                reliability: _reliabilityController.text.trim(),
                deliverySpeed: _deliverySpeedController.text.trim(),
                quality: _qualityController.text.trim(),
                preferred: _preferred,
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label, hintText: hintText),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

class _SupplierDraft {
  const _SupplierDraft({
    required this.supplierId,
    required this.name,
    required this.website,
    required this.category,
    required this.reliability,
    required this.deliverySpeed,
    required this.quality,
    required this.preferred,
    required this.notes,
  });

  final String supplierId;
  final String name;
  final String website;
  final String category;
  final String reliability;
  final String deliverySpeed;
  final String quality;
  final String preferred;
  final String notes;

  Map<String, String> toRow() {
    return {
      'supplier_id': supplierId,
      'name': name,
      'website': website,
      'category': category,
      'reliability': reliability,
      'delivery_speed': deliverySpeed,
      'quality': quality,
      'preferred': preferred,
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
