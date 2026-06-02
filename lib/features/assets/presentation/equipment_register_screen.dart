import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class EquipmentRegisterScreen extends ConsumerStatefulWidget {
  const EquipmentRegisterScreen({
    super.key,
    this.initialSearch,
    this.initialAssetId,
  });

  final String? initialSearch;
  final String? initialAssetId;

  @override
  ConsumerState<EquipmentRegisterScreen> createState() =>
      _EquipmentRegisterScreenState();
}

class _EquipmentRegisterScreenState
    extends ConsumerState<EquipmentRegisterScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSaving = false;
  String _activeFilter = 'all';
  bool _didHandleInitialTarget = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch?.trim().isNotEmpty == true) {
      _searchController.text = widget.initialSearch!.trim();
    } else if (widget.initialAssetId?.trim().isNotEmpty == true) {
      _searchController.text = widget.initialAssetId!.trim();
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
    final equipment = ref.watch(assetEquipmentRegisterProvider);

    return workspace.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _RegisterError(
        title: 'Equipment Register',
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspaceData) {
        return equipment.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _RegisterError(
            title: 'Equipment Register',
            onReload: () => ref.invalidate(assetEquipmentRegisterProvider),
          ),
          data: (table) {
            final filteredRows = _filterRows(table.rows);
            _maybeAutoOpenInitialRecord(
              context,
              workspaceData.assetsRootPath,
              table.rows,
            );
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
                label: Text(_isSaving ? 'Saving' : 'Add Equipment'),
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
                              title: 'Equipment Register',
                              subtitle:
                                  'Keep equipment clear, calm, and easy to find by name, project, or status.',
                              countLabel:
                                  '${filteredRows.length} of ${table.rows.length} equipment items shown.',
                              actionLabel: workspaceData.assetsRootPath == null
                                  ? 'Asset folder not linked yet'
                                  : workspaceData.assetsRootPath!,
                              onReload: () {
                                ref.invalidate(assetEquipmentRegisterProvider);
                              },
                              onBack: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(height: 20),
                            _RegisterSearchBar(
                              controller: _searchController,
                              hintText:
                                  'Search equipment by name, ID, project, location, or status',
                              activeFilter: _activeFilter,
                              filterLabels: const {
                                'all': 'All',
                                'available': 'Ready',
                                'attention': 'Attention',
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
                                  label: 'Available',
                                  value: _countStatuses(table.rows, const [
                                    'available',
                                    'in_use',
                                    'in_storage',
                                  ]),
                                  accent: AppColours.darkSuccess,
                                ),
                                _SummaryMetric(
                                  label: 'Broken / Repair',
                                  value: _countStatuses(table.rows, const [
                                    'broken',
                                    'repairing',
                                  ]),
                                  accent: const Color(0xFFE26B6B),
                                ),
                                _SummaryMetric(
                                  label: 'Linked Projects',
                                  value: _countDistinctProjects(table.rows),
                                  accent: AppColours.darkSecondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (filteredRows.isEmpty)
                              if (table.rows.isEmpty)
                                _EmptyRegisterState(
                                  title: 'No equipment yet',
                                  message:
                                      'Add your first item to start building a calm equipment register.',
                                  onAdd: workspaceData.assetsRootPath == null
                                      ? null
                                      : () => _addRecord(
                                          workspaceData.assetsRootPath!,
                                        ),
                                )
                              else
                                _EmptyFilterState(
                                  title: 'No equipment matches this view',
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
                                  return _EquipmentCard(
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

    final draft = await showDialog<_EquipmentDraft>(
      context: context,
      builder: (context) => const _EquipmentDialog(),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .appendEquipmentRecord(assetsRootPath, draft.toRow());
      if (!mounted) {
        return;
      }
      ref.invalidate(assetEquipmentRegisterProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Equipment item saved.')));
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

    final draft = await showDialog<_EquipmentDraft>(
      context: context,
      builder: (context) => _EquipmentDialog(existingRow: row),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .updateEquipmentRecord(assetsRootPath, draft.toRow());
      if (!mounted) {
        return;
      }
      ref.invalidate(assetEquipmentRegisterProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Equipment item updated.')));
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

  void _maybeAutoOpenInitialRecord(
    BuildContext context,
    String? assetsRootPath,
    List<Map<String, String>> rows,
  ) {
    final initialAssetId = widget.initialAssetId?.trim();
    if (_didHandleInitialTarget ||
        assetsRootPath == null ||
        initialAssetId == null ||
        initialAssetId.isEmpty) {
      return;
    }

    final match = rows.where((row) {
      return (row['asset_id'] ?? '').trim() == initialAssetId;
    }).toList(growable: false);
    if (match.isEmpty) {
      return;
    }

    _didHandleInitialTarget = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await _editRecord(assetsRootPath, match.first);
    });
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
    final condition = (row['condition'] ?? '').trim().toLowerCase();
    switch (_activeFilter) {
      case 'available':
        return status == 'available' ||
            status == 'in_use' ||
            status == 'in_storage';
      case 'attention':
        return status == 'broken' ||
            status == 'repairing' ||
            condition == 'broken' ||
            condition == 'repairing';
      case 'all':
      default:
        return true;
    }
  }

  String _rowSearchText(Map<String, String> row) {
    return [
      row['asset_id'],
      row['name'],
      row['type'],
      row['project'],
      row['location'],
      row['status'],
      row['condition'],
      row['notes'],
    ].whereType<String>().join(' ').toLowerCase();
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.row, this.onEdit});

  final Map<String, String> row;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? 'available').trim();
    final isHealthy =
        status == 'available' || status == 'in_use' || status == 'in_storage';

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
                      : 'Unnamed equipment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(
                label: status.isEmpty ? 'available' : status,
                accent: isHealthy
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit equipment',
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
              _InfoChip(label: row['asset_id'] ?? 'No ID'),
              _InfoChip(label: row['type'] ?? 'No type'),
              _InfoChip(label: row['project'] ?? 'No project'),
              _InfoChip(label: row['location'] ?? 'No location'),
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

class _EquipmentDialog extends StatefulWidget {
  const _EquipmentDialog({this.existingRow});

  final Map<String, String>? existingRow;

  @override
  State<_EquipmentDialog> createState() => _EquipmentDialogState();
}

class _EquipmentDialogState extends State<_EquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _assetIdController;
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _projectController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  String _status = 'available';
  String _condition = 'good';

  static const _statusOptions = [
    'available',
    'in_use',
    'in_storage',
    'broken',
    'repairing',
    'wishlist',
    'archived',
  ];

  static const _conditionOptions = [
    'good',
    'fair',
    'needs attention',
    'broken',
  ];

  @override
  void initState() {
    super.initState();
    final row = widget.existingRow;
    _assetIdController = TextEditingController(text: row?['asset_id'] ?? '');
    _nameController = TextEditingController(text: row?['name'] ?? '');
    _typeController = TextEditingController(text: row?['type'] ?? '');
    _projectController = TextEditingController(text: row?['project'] ?? '');
    _locationController = TextEditingController(text: row?['location'] ?? '');
    _notesController = TextEditingController(text: row?['notes'] ?? '');
    _status = row?['status']?.trim().isNotEmpty == true
        ? row!['status']!.trim()
        : 'available';
    _condition = row?['condition']?.trim().isNotEmpty == true
        ? row!['condition']!.trim()
        : 'good';
  }

  @override
  void dispose() {
    _assetIdController.dispose();
    _nameController.dispose();
    _typeController.dispose();
    _projectController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRow != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Equipment' : 'Add Equipment'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(
                  controller: _assetIdController,
                  label: 'Asset ID',
                  hintText: 'NE-EQ-0001',
                  enabled: !isEditing,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter an asset ID.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _nameController,
                  label: 'Name',
                  hintText: 'Cordless drill',
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter a name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _typeController,
                  label: 'Type',
                  hintText: 'Tool',
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _projectController,
                  label: 'Project',
                  hintText: 'MicroGrow',
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'Storage Box 1',
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
                DropdownButtonFormField<String>(
                  initialValue: _condition,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: _conditionOptions
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _condition = value);
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
              _EquipmentDraft(
                assetId: _assetIdController.text.trim(),
                name: _nameController.text.trim(),
                type: _typeController.text.trim(),
                project: _projectController.text.trim(),
                location: _locationController.text.trim(),
                condition: _condition,
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

  Widget _buildField({
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

class _EquipmentDraft {
  const _EquipmentDraft({
    required this.assetId,
    required this.name,
    required this.type,
    required this.project,
    required this.location,
    required this.condition,
    required this.status,
    required this.notes,
  });

  final String assetId;
  final String name;
  final String type;
  final String project;
  final String location;
  final String condition;
  final String status;
  final String notes;

  Map<String, String> toRow() {
    return {
      'asset_id': assetId,
      'name': name,
      'type': type,
      'project': project,
      'owner': '',
      'location': location,
      'condition': condition,
      'status': status,
      'purchase_date': '',
      'purchase_cost': '',
      'replacement_value': '',
      'serial_number': '',
      'receipt_link': '',
      'warranty_until': '',
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
            onChanged: (_) {},
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
