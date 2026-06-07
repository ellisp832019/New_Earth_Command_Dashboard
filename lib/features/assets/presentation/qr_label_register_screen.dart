import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';

class QrLabelRegisterScreen extends ConsumerStatefulWidget {
  const QrLabelRegisterScreen({super.key});

  @override
  ConsumerState<QrLabelRegisterScreen> createState() =>
      _QrLabelRegisterScreenState();
}

class _QrLabelRegisterScreenState extends ConsumerState<QrLabelRegisterScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(assetWorkspaceProvider);
    final labels = ref.watch(assetQrLabelRegisterProvider);

    return workspace.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          _QrLabelError(onReload: () => ref.invalidate(assetWorkspaceProvider)),
      data: (workspaceData) {
        return labels.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _QrLabelError(
            onReload: () => ref.invalidate(assetQrLabelRegisterProvider),
          ),
          data: (table) {
            final labeledAssets = _distinctValues(table.rows, 'asset_id');
            final missingLabelCodes = _countEmptyValues(
              table.rows,
              'label_code',
            );
            final missingAssetIds = _countEmptyValues(table.rows, 'asset_id');

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
                label: Text(_isSaving ? 'Saving' : 'Add QR Label'),
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
                            _QrLabelHeader(
                              assetPath: workspaceData.assetsRootPath,
                              labelCount: table.rows.length,
                              labeledAssets: labeledAssets.length,
                              missingLabelCodes: missingLabelCodes,
                              missingAssetIds: missingAssetIds,
                            ),
                            const SizedBox(height: 20),
                            _QrLabelSummaryRow(
                              labelCount: table.rows.length,
                              labeledAssets: labeledAssets.length,
                              missingLabelCodes: missingLabelCodes,
                              missingAssetIds: missingAssetIds,
                            ),
                            const SizedBox(height: 20),
                            if (table.rows.isEmpty)
                              _EmptyQrLabelState(
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
                                  return _QrLabelCard(row: table.rows[index]);
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

    final draft = await showDialog<_QrLabelDraft>(
      context: context,
      builder: (context) => const _QrLabelDialog(),
    );
    if (draft == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(assetRegisterRepositoryProvider)
          .appendQrLabelRecord(assetsRootPath, draft.toRow());
      if (!mounted) {
        return;
      }
      ref.invalidate(assetQrLabelRegisterProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR label saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _QrLabelHeader extends StatelessWidget {
  const _QrLabelHeader({
    required this.assetPath,
    required this.labelCount,
    required this.labeledAssets,
    required this.missingLabelCodes,
    required this.missingAssetIds,
  });

  final String? assetPath;
  final int labelCount;
  final int labeledAssets;
  final int missingLabelCodes;
  final int missingAssetIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QR Labels',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prepare label IDs and targets now so scanning can come later without changing the calm register shape.',
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
              _InfoChip(label: assetPath ?? 'Asset folder not linked'),
              _InfoChip(label: '$labelCount labels'),
              _InfoChip(label: '$labeledAssets assets referenced'),
              _InfoChip(label: '$missingLabelCodes missing codes'),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go(RouteNames.assets),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Assets'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(RouteNames.assetQrLabelHistory),
                icon: const Icon(Icons.history_outlined),
                label: const Text('History'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(RouteNames.assetInventorySession),
                icon: const Icon(Icons.checklist_rtl_outlined),
                label: const Text('Inventory Session'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(RouteNames.assetQrLifecycle),
                icon: const Icon(Icons.timeline_outlined),
                label: const Text('Lifecycle'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(RouteNames.assetQrLabelStudio),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Open Studio'),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 16),
                chips,
                const SizedBox(height: 16),
                actions,
              ],
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
                    Align(alignment: Alignment.topRight, child: chips),
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

class _QrLabelSummaryRow extends StatelessWidget {
  const _QrLabelSummaryRow({
    required this.labelCount,
    required this.labeledAssets,
    required this.missingLabelCodes,
    required this.missingAssetIds,
  });

  final int labelCount;
  final int labeledAssets;
  final int missingLabelCodes;
  final int missingAssetIds;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final cards = [
          _MetricCard(
            label: 'Labels',
            value: labelCount,
            accent: AppColours.darkSecondary,
          ),
          _MetricCard(
            label: 'Assets referenced',
            value: labeledAssets,
            accent: AppColours.darkSuccess,
          ),
          _MetricCard(
            label: 'Missing codes',
            value: missingLabelCodes,
            accent: AppColours.darkAmber,
          ),
          _MetricCard(
            label: 'Missing asset IDs',
            value: missingAssetIds,
            accent: const Color(0xFFE26B6B),
          ),
        ];

        if (wide) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
              const SizedBox(width: 12),
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          );
        }

        return Column(
          children: [
            cards[0],
            const SizedBox(height: 12),
            cards[1],
            const SizedBox(height: 12),
            cards[2],
            const SizedBox(height: 12),
            cards[3],
          ],
        );
      },
    );
  }
}

class _QrLabelCard extends StatelessWidget {
  const _QrLabelCard({required this.row});

  final Map<String, String> row;

  @override
  Widget build(BuildContext context) {
    final assetId = row['asset_id']?.trim().isNotEmpty == true
        ? row['asset_id']!.trim()
        : 'No asset ID';
    final labelCode = row['label_code']?.trim().isNotEmpty == true
        ? row['label_code']!.trim()
        : 'No label code';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  labelCode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(
                label: row['status']?.trim().isNotEmpty == true
                    ? row['status']!.trim()
                    : 'pending',
                accent: AppColours.darkSecondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: assetId),
              _InfoChip(label: row['qr_target'] ?? 'No QR target'),
              _InfoChip(label: row['file_or_url'] ?? 'No file or URL'),
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

class _EmptyQrLabelState extends StatelessWidget {
  const _EmptyQrLabelState({required this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            title: 'No QR labels yet',
            icon: Icons.qr_code_2_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Start with a few label rows so scanning can be added later without changing the register shape.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add QR Label'),
            ),
          ],
        ],
      ),
    );
  }
}

class _QrLabelError extends StatelessWidget {
  const _QrLabelError({required this.onReload});

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
                'QR label register could not load right now.',
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

class _QrLabelDialog extends StatefulWidget {
  const _QrLabelDialog();

  @override
  State<_QrLabelDialog> createState() => _QrLabelDialogState();
}

class _QrLabelDialogState extends State<_QrLabelDialog> {
  late final TextEditingController _assetIdController;
  late final TextEditingController _labelCodeController;
  late final TextEditingController _qrTargetController;
  late final TextEditingController _fileOrUrlController;
  late final TextEditingController _statusController;
  late final TextEditingController _printedDateController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _assetIdController = TextEditingController();
    _labelCodeController = TextEditingController();
    _qrTargetController = TextEditingController();
    _fileOrUrlController = TextEditingController();
    _statusController = TextEditingController(text: 'pending');
    _printedDateController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _assetIdController.dispose();
    _labelCodeController.dispose();
    _qrTargetController.dispose();
    _fileOrUrlController.dispose();
    _statusController.dispose();
    _printedDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add QR Label'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _assetIdController,
              decoration: const InputDecoration(labelText: 'Asset ID'),
            ),
            TextField(
              controller: _labelCodeController,
              decoration: const InputDecoration(labelText: 'Label code'),
            ),
            TextField(
              controller: _qrTargetController,
              decoration: const InputDecoration(
                labelText: 'QR target',
                hintText: 'asset search or local file path',
              ),
            ),
            TextField(
              controller: _fileOrUrlController,
              decoration: const InputDecoration(labelText: 'File or URL'),
            ),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            TextField(
              controller: _printedDateController,
              decoration: const InputDecoration(labelText: 'Printed date'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _QrLabelDraft(
                assetId: _assetIdController.text.trim(),
                labelCode: _labelCodeController.text.trim(),
                qrTarget: _qrTargetController.text.trim(),
                fileOrUrl: _fileOrUrlController.text.trim(),
                status: _statusController.text.trim(),
                printedDate: _printedDateController.text.trim(),
                notes: _notesController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _QrLabelDraft {
  const _QrLabelDraft({
    required this.assetId,
    required this.labelCode,
    required this.qrTarget,
    required this.fileOrUrl,
    required this.status,
    required this.printedDate,
    required this.notes,
  });

  final String assetId;
  final String labelCode;
  final String qrTarget;
  final String fileOrUrl;
  final String status;
  final String printedDate;
  final String notes;

  Map<String, String> toRow() {
    return {
      'asset_id': assetId,
      'label_code': labelCode,
      'qr_target': qrTarget,
      'file_or_url': fileOrUrl,
      'status': status,
      'printed_date': printedDate,
      'notes': notes,
    };
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColours.darkText),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
        border: Border.all(color: accent.withValues(alpha: 0.35)),
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
        ? AppColours.darkSurfaceAlt.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.93),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: highlighted
          ? AppColours.darkSecondary.withValues(alpha: 0.28)
          : AppColours.darkOutline,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x20000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  );
}

List<String> _distinctValues(List<Map<String, String>> rows, String key) {
  final values = <String>{};
  for (final row in rows) {
    final value = (row[key] ?? '').trim();
    if (value.isNotEmpty) {
      values.add(value);
    }
  }
  return values.toList(growable: false);
}

int _countEmptyValues(List<Map<String, String>> rows, String key) {
  var count = 0;
  for (final row in rows) {
    if ((row[key] ?? '').trim().isEmpty) {
      count += 1;
    }
  }
  return count;
}
