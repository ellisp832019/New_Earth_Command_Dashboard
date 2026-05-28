import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

enum _QuickCaptureKind { equipment, part }

class QuickCaptureScreen extends ConsumerStatefulWidget {
  const QuickCaptureScreen({super.key});

  @override
  ConsumerState<QuickCaptureScreen> createState() =>
      _QuickCaptureScreenState();
}

class _QuickCaptureScreenState extends ConsumerState<QuickCaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _projectController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  _QuickCaptureKind _kind = _QuickCaptureKind.equipment;
  String _status = 'available';
  bool _isSaving = false;

  static const _equipmentStatuses = <String>[
    'available',
    'in_use',
    'in_storage',
    'broken',
    'repairing',
    'wishlist',
  ];

  static const _partStatuses = <String>[
    'available',
    'low_stock',
    'reorder_needed',
    'wishlist',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _typeController = TextEditingController();
    _projectController = TextEditingController();
    _locationController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _projectController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(assetWorkspaceProvider);

    return workspace.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quick capture could not load right now.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => ref.invalidate(assetWorkspaceProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (workspaceData) {
        final statusOptions = _statusOptionsFor(_kind);
        final selectedStatus =
            statusOptions.contains(_status) ? _status : statusOptions.first;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed:
                _isSaving || workspaceData.assetsRootPath == null
                    ? null
                    : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Saving' : 'Save'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _QuickCaptureHeader(
                    assetsRootPath: workspaceData.assetsRootPath,
                    kind: _kind,
                    statusLabel: selectedStatus,
                    onBack: () => Navigator.of(context).maybePop(),
                    onSwitchKind: _setKind,
                  ),
                  const SizedBox(height: 20),
                  if (workspaceData.assetsRootPath == null) ...[
                    _UnavailableNotice(
                      onReload: () => ref.invalidate(assetWorkspaceProvider),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: _panelDecoration(context),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _PanelTitle(
                            title: 'One-minute capture',
                            icon: Icons.flash_on_outlined,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Capture the essentials now. You can refine the record later in the register.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColours.darkMutedText,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 18),
                          const _SectionLabel(
                            label: 'Capture mode',
                            hint:
                                'Use the header buttons to switch between equipment and parts. The form stays the same either way.',
                          ),
                          const SizedBox(height: 18),
                          _Field(
                            controller: _nameController,
                            label: 'Item name',
                            hintText: 'Cordless drill or M3 screws',
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Enter an item name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _typeController,
                            label: 'Type / category',
                            hintText: _kind == _QuickCaptureKind.equipment
                                ? 'Tool, device, sensor...'
                                : 'Fastener, cable, label...',
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _projectController,
                            label: 'Project',
                            hintText: 'MicroGrow',
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _locationController,
                            label: 'Location',
                            hintText: 'Workbench A',
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            key: ValueKey<String>('status-${_kind.name}'),
                            initialValue: selectedStatus,
                            decoration: const InputDecoration(labelText: 'Status'),
                            items: statusOptions
                                .map(
                                  (value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value.replaceAll('_', ' ')),
                                  ),
                                )
                                .toList(growable: false),
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
                            minLines: 3,
                            maxLines: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final workspace = await ref.read(assetWorkspaceProvider.future);
    final assetsRootPath = workspace.assetsRootPath;
    if (assetsRootPath == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(assetRegisterRepositoryProvider);
      final timestamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());

      if (_kind == _QuickCaptureKind.equipment) {
        await repository.appendEquipmentRecord(
          assetsRootPath,
          {
            'asset_id': 'NE-EQ-$timestamp',
            'name': _nameController.text.trim(),
            'type': _typeController.text.trim(),
            'project': _projectController.text.trim(),
            'owner': '',
            'location': _locationController.text.trim(),
            'condition': _equipmentConditionFor(_status),
            'status': _status,
            'purchase_date': '',
            'purchase_cost': '',
            'replacement_value': '',
            'serial_number': '',
            'receipt_link': '',
            'warranty_until': '',
            'notes': _notesController.text.trim(),
          },
        );
      } else {
        await repository.appendPartRecord(
          assetsRootPath,
          {
            'part_id': 'NE-PART-$timestamp',
            'name': _nameController.text.trim(),
            'category': _typeController.text.trim(),
            'project': _projectController.text.trim(),
            'quantity': '0',
            'min_quantity': '0',
            'location': _locationController.text.trim(),
            'supplier': '',
            'last_ordered': '',
            'last_cost': '',
            'status': _status,
            'datasheet_link': '',
            'notes': _notesController.text.trim(),
          },
        );
      }

      if (!mounted) {
        return;
      }

      ref.invalidate(assetEquipmentRegisterProvider);
      ref.invalidate(assetPartsRegisterProvider);
      ref.invalidate(assetWorkspaceProvider);

      _nameController.clear();
      _typeController.clear();
      _projectController.clear();
      _locationController.clear();
      _notesController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _kind == _QuickCaptureKind.equipment
                ? 'Equipment quick capture saved.'
                : 'Part quick capture saved.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _setKind(_QuickCaptureKind kind) {
    setState(() {
      _kind = kind;
      final statusOptions = _statusOptionsFor(kind);
      if (!statusOptions.contains(_status)) {
        _status = statusOptions.first;
      }
    });
  }

  List<String> _statusOptionsFor(_QuickCaptureKind kind) {
    return kind == _QuickCaptureKind.equipment
        ? _equipmentStatuses
        : _partStatuses;
  }

  String _equipmentConditionFor(String status) {
    switch (status) {
      case 'broken':
        return 'broken';
      case 'repairing':
        return 'needs attention';
      case 'wishlist':
        return 'fair';
      default:
        return 'good';
    }
  }
}

class _QuickCaptureHeader extends StatelessWidget {
  const _QuickCaptureHeader({
    required this.assetsRootPath,
    required this.kind,
    required this.statusLabel,
    required this.onBack,
    required this.onSwitchKind,
  });

  final String? assetsRootPath;
  final _QuickCaptureKind kind;
  final String statusLabel;
  final VoidCallback onBack;
  final ValueChanged<_QuickCaptureKind> onSwitchKind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEquipment = kind == _QuickCaptureKind.equipment;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;

          final copy = Column(
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
                    child: Text(
                      'Quick Capture',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColours.darkText,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Capture a useful record in under a minute, then refine it later in the register.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(label: assetsRootPath ?? 'Asset folder not linked'),
              _InfoChip(label: isEquipment ? 'Equipment mode' : 'Part mode'),
              _InfoChip(label: 'Status: ${statusLabel.replaceAll('_', ' ')}'),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: wide ? WrapAlignment.end : WrapAlignment.start,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => onSwitchKind(_QuickCaptureKind.equipment),
                icon: const Icon(Icons.precision_manufacturing_outlined),
                label: const Text('Equipment'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => onSwitchKind(_QuickCaptureKind.part),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Part'),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), chips, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(
                width: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    chips,
                    const SizedBox(height: 16),
                    actions,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UnavailableNotice extends StatelessWidget {
  const _UnavailableNotice({required this.onReload});

  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Row(
        children: [
          const Icon(Icons.link_off_outlined, color: AppColours.darkAmber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The external asset folder is not linked yet, so quick capture cannot save until that path is available.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.4,
                  ),
            ),
          ),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
            label: const Text('Reload'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
      ),
      validator: validator,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColours.darkSecondary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColours.darkText,
              ),
        ),
      ],
    );
  }
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
