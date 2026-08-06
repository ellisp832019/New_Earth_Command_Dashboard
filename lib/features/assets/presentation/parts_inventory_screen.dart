import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/widgets/workspace_shell.dart';
import '../application/assets_controller.dart';

class PartsInventoryScreen extends ConsumerStatefulWidget {
  const PartsInventoryScreen({
    super.key,
    this.initialSearch,
  });

  final String? initialSearch;

  @override
  ConsumerState<PartsInventoryScreen> createState() =>
      _PartsInventoryScreenState();
}

class _PartsInventoryScreenState extends ConsumerState<PartsInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSaving = false;
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch?.trim().isNotEmpty == true) {
      _searchController.text = widget.initialSearch!.trim();
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final parts = ref.watch(assetPartsRegisterProvider);

    return workspace.when(
      loading: () => WorkspaceShell(
        title: 'Parts Inventory',
        subtitle: 'Asset parts workspace',
        onBack: () => Navigator.of(context).maybePop(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => WorkspaceShell(
        title: 'Parts Inventory',
        subtitle: 'Asset parts workspace',
        onBack: () => Navigator.of(context).maybePop(),
        child: _RegisterError(
          title: 'Parts Inventory',
          onReload: () => ref.invalidate(assetWorkspaceProvider),
        ),
      ),
      data: (workspaceData) {
        return parts.when(
          loading: () => WorkspaceShell(
            title: 'Parts Inventory',
            subtitle: 'Asset parts workspace',
            onBack: () => Navigator.of(context).maybePop(),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => WorkspaceShell(
            title: 'Parts Inventory',
            subtitle: 'Asset parts workspace',
            onBack: () => Navigator.of(context).maybePop(),
            child: _RegisterError(
              title: 'Parts Inventory',
              onReload: () => ref.invalidate(assetPartsRegisterProvider),
            ),
          ),
          data: (table) {
            final filteredRows = _filterRows(table.rows);
            return WorkspaceShell(
              title: 'Parts Inventory',
              subtitle: 'Asset parts workspace',
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
                              title: 'Parts Inventory',
                              subtitle:
                                  'Keep parts light, clear, and easy to search by part, project, or stock status.',
                              countLabel:
                                  '${filteredRows.length} of ${table.rows.length} part records shown.',
                              actionLabel: workspaceData.assetsRootPath == null
                                  ? 'Asset folder not linked yet'
                                  : workspaceData.assetsRootPath!,
                              onReload: () {
                                ref.invalidate(assetPartsRegisterProvider);
                              },
                              onBack: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(height: 20),
                            _RegisterSearchBar(
                              controller: _searchController,
                              hintText:
                                  'Search parts by name, ID, category, supplier, project, or status',
                              activeFilter: _activeFilter,
                              filterLabels: const {
                                'all': 'All',
                                'low_stock': 'Low Stock',
                                'wishlist': 'Wishlist',
                              },
                              onFilterChanged: (value) {
                                setState(() => _activeFilter = value);
                              },
                              onClear: () {
                                setState(() {
                                  _activeFilter = 'all';
                                  _searchController.clear();
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _RegisterSummaryRow(
                              items: [
                                _SummaryMetric(
                                  label: 'Low Stock',
                                  value: _countLowStock(table.rows),
                                  accent: AppColours.darkAmber,
                                ),
                                _SummaryMetric(
                                  label: 'Wishlist',
                                  value: _countStatuses(table.rows, const [
                                    'wishlist',
                                  ]),
                                  accent: AppColours.darkPurple,
                                ),
                                _SummaryMetric(
                                  label: 'Projects Linked',
                                  value: _countDistinctProjects(table.rows),
                                  accent: AppColours.darkSecondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (filteredRows.isEmpty)
                              if (table.rows.isEmpty)
                                _EmptyRegisterState(
                                  title: 'No parts yet',
                                  message:
                                      'Add your first part so the reorder and low stock workflow has something to work with.',
                                  onAdd: workspaceData.assetsRootPath == null
                                      ? null
                                      : () => _addRecord(
                                          workspaceData.assetsRootPath!,
                                        ),
                                )
                              else
                                _EmptyFilterState(
                                  title: 'No parts match this view',
                                  message:
                                      'Try a different search or switch the filter back to All.',
                                  onClear: _clearFilters,
                                )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredRows.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final row = filteredRows[index];
                                  return _PartCard(
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
                      label: Text(_isSaving ? 'Saving' : 'Add Part'),
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

    final draft = await showDialog<_PartDraft>(
      context: context,
      builder: (context) => const _PartDialog(),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .appendPartRecord(assetsRootPath, draft.toRow());
      if (!mounted) {
        return;
      }
      ref.invalidate(assetPartsRegisterProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Part saved.')));
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

    final draft = await showDialog<_PartDraft>(
      context: context,
      builder: (context) => _PartDialog(existingRow: row),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .updatePartRecord(assetsRootPath, draft.toRow());
      if (!mounted) {
        return;
      }
      ref.invalidate(assetPartsRegisterProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Part updated.')));
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

    final partId = (row['part_id'] ?? '').trim();
    final label = (row['name'] ?? '').trim().isNotEmpty == true
        ? row['name']!.trim()
        : partId.isEmpty
        ? 'this part'
        : partId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete part entry?'),
        content: Text(
          'Remove $label from the register? This only deletes the row from the local CSV file.',
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
          .deletePartRecord(assetsRootPath, partId);
      if (!mounted) {
        return;
      }
      ref.invalidate(assetPartsRegisterProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label removed from the register.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int _countStatuses(List<Map<String, String>> rows, List<String> values) {
    return rows.where((row) {
      final status = (row['status'] ?? '').trim().toLowerCase();
      return values.contains(status);
    }).length;
  }

  int _countLowStock(List<Map<String, String>> rows) {
    return rows.where((row) {
      final status = (row['status'] ?? '').trim().toLowerCase();
      if (status == 'low_stock' || status == 'reorder_needed') {
        return true;
      }
      final quantity = int.tryParse((row['quantity'] ?? '').trim());
      final minQuantity = int.tryParse((row['min_quantity'] ?? '').trim());
      return quantity != null && minQuantity != null && quantity <= minQuantity;
    }).length;
  }

  int _countDistinctProjects(List<Map<String, String>> rows) {
    final projects = <String>{};
    for (final row in rows) {
      final project = (row['project'] ?? '').trim();
      if (project.isNotEmpty) {
        projects.add(project);
      }
    }
    return projects.length;
  }

  void _clearFilters() {
    setState(() {
      _activeFilter = 'all';
      _searchController.clear();
    });
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, String>> _filterRows(List<Map<String, String>> rows) {
    final query = _searchController.text.trim().toLowerCase();
    return rows
        .where((row) {
          if (!_matchesActiveFilter(row)) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }

          return _rowSearchText(row).contains(query);
        })
        .toList(growable: false);
  }

  bool _matchesActiveFilter(Map<String, String> row) {
    final status = (row['status'] ?? '').trim().toLowerCase();
    switch (_activeFilter) {
      case 'low_stock':
        return status == 'low_stock' ||
            status == 'reorder_needed' ||
            _isBelowMinQuantity(row);
      case 'wishlist':
        return status == 'wishlist';
      case 'all':
      default:
        return true;
    }
  }

  bool _isBelowMinQuantity(Map<String, String> row) {
    final quantity = int.tryParse((row['quantity'] ?? '').trim());
    final minQuantity = int.tryParse((row['min_quantity'] ?? '').trim());
    return quantity != null && minQuantity != null && quantity <= minQuantity;
  }

  String _rowSearchText(Map<String, String> row) {
    return [
      row['part_id'],
      row['name'],
      row['category'],
      row['project'],
      row['location'],
      row['supplier'],
      row['status'],
      row['notes'],
    ].whereType<String>().join(' ').toLowerCase();
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({required this.row, this.onEdit, this.onDelete});

  final Map<String, String> row;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? 'available').trim();
    final isLowStock = status == 'low_stock' || status == 'reorder_needed';
    final quantity = row['quantity']?.trim().isNotEmpty == true
        ? row['quantity']!.trim()
        : '0';
    final minQuantity = row['min_quantity']?.trim().isNotEmpty == true
        ? row['min_quantity']!.trim()
        : '0';

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
                      : 'Unnamed part',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(
                label: status.isEmpty ? 'available' : status,
                accent: isLowStock
                    ? AppColours.darkAmber
                    : AppColours.darkSuccess,
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit part',
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete part',
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
              _InfoChip(label: row['part_id'] ?? 'No ID'),
              _InfoChip(label: row['category'] ?? 'No category'),
              _InfoChip(label: row['project'] ?? 'No project'),
              _InfoChip(label: row['location'] ?? 'No location'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Qty $quantity  •  Min $minQuantity',
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

class _PartDialog extends StatefulWidget {
  const _PartDialog({this.existingRow});

  final Map<String, String>? existingRow;

  @override
  State<_PartDialog> createState() => _PartDialogState();
}

class _PartDialogState extends State<_PartDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _partIdController;
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _projectController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minQuantityController;
  late final TextEditingController _locationController;
  late final TextEditingController _supplierController;
  late final TextEditingController _notesController;
  String _status = 'available';

  static const _statusOptions = [
    'available',
    'low_stock',
    'reorder_needed',
    'wishlist',
    'archived',
  ];

  @override
  void initState() {
    super.initState();
    final row = widget.existingRow;
    _partIdController = TextEditingController(text: row?['part_id'] ?? '');
    _nameController = TextEditingController(text: row?['name'] ?? '');
    _categoryController = TextEditingController(text: row?['category'] ?? '');
    _projectController = TextEditingController(text: row?['project'] ?? '');
    _quantityController = TextEditingController(text: row?['quantity'] ?? '0');
    _minQuantityController = TextEditingController(
      text: row?['min_quantity'] ?? '0',
    );
    _locationController = TextEditingController(text: row?['location'] ?? '');
    _supplierController = TextEditingController(text: row?['supplier'] ?? '');
    _notesController = TextEditingController(text: row?['notes'] ?? '');
    _status = row?['status']?.trim().isNotEmpty == true
        ? row!['status']!.trim()
        : 'available';
  }

  @override
  void dispose() {
    _partIdController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _projectController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _locationController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRow != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Part' : 'Add Part'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(
                  controller: _partIdController,
                  label: 'Part ID',
                  hintText: 'NE-PART-0001',
                  enabled: !isEditing,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter a part ID.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _nameController,
                  label: 'Name',
                  hintText: 'M3 screws',
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter a name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _categoryController,
                  label: 'Category',
                  hintText: 'Fasteners',
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
                        hintText: '12',
                        keyboardType: TextInputType.number,
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
                        controller: _minQuantityController,
                        label: 'Min quantity',
                        hintText: '10',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (int.tryParse((value ?? '').trim()) == null) {
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
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'Electronics Drawer 2',
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _supplierController,
                  label: 'Supplier',
                  hintText: 'RS Components',
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
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.of(context).pop(
              _PartDraft(
                partId: _partIdController.text.trim(),
                name: _nameController.text.trim(),
                category: _categoryController.text.trim(),
                project: _projectController.text.trim(),
                quantity: _quantityController.text.trim(),
                minQuantity: _minQuantityController.text.trim(),
                location: _locationController.text.trim(),
                supplier: _supplierController.text.trim(),
                status: _status,
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

class _PartDraft {
  const _PartDraft({
    required this.partId,
    required this.name,
    required this.category,
    required this.project,
    required this.quantity,
    required this.minQuantity,
    required this.location,
    required this.supplier,
    required this.status,
    required this.notes,
  });

  final String partId;
  final String name;
  final String category;
  final String project;
  final String quantity;
  final String minQuantity;
  final String location;
  final String supplier;
  final String status;
  final String notes;

  Map<String, String> toRow() {
    return {
      'part_id': partId,
      'name': name,
      'category': category,
      'project': project,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'location': location,
      'supplier': supplier,
      'last_ordered': '',
      'last_cost': '',
      'status': status,
      'datasheet_link': '',
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

class _RegisterSearchBar extends StatelessWidget {
  const _RegisterSearchBar({
    required this.controller,
    required this.hintText,
    required this.activeFilter,
    required this.filterLabels,
    required this.onFilterChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final String activeFilter;
  final Map<String, String> filterLabels;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear search',
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in filterLabels.entries)
                FilterChip(
                  selected: activeFilter == entry.key,
                  label: Text(entry.value),
                  onSelected: (_) => onFilterChanged(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState({
    required this.title,
    required this.message,
    required this.onClear,
  });

  final String title;
  final String message;
  final VoidCallback onClear;

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
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear search and filters'),
          ),
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
