import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';
import '../data/asset_inventory_session_service.dart';

class InventorySessionScreen extends ConsumerStatefulWidget {
  const InventorySessionScreen({super.key});

  @override
  ConsumerState<InventorySessionScreen> createState() =>
      _InventorySessionScreenState();
}

class _InventorySessionScreenState
    extends ConsumerState<InventorySessionScreen> {
  late final TextEditingController _sessionNameController;
  late final TextEditingController _notesController;
  AssetInventorySessionPack? _latestPack;
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    _sessionNameController = TextEditingController(
      text: 'Hayley and Ellis inventory week',
    );
    _notesController = TextEditingController(
      text: 'Print this pack, count the shelves, and mark anything missing.',
    );
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceAsync = ref.watch(assetWorkspaceProvider);
    final equipmentAsync = ref.watch(assetEquipmentRegisterProvider);
    final partsAsync = ref.watch(assetPartsRegisterProvider);
    final labelsAsync = ref.watch(assetQrLabelRegisterProvider);
    final lowStockAsync = ref.watch(assetLowStockPartsProvider);
    final sessionLogAsync = ref.watch(assetInventorySessionLogProvider);

    return workspaceAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _InventoryError(
        title: 'Inventory session',
        message: 'The asset workspace is not ready yet.',
        onBack: () => context.go(RouteNames.assets),
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspace) {
        return equipmentAsync.when(
          loading: () => const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _InventoryError(
            title: 'Inventory session',
            message: 'Equipment register could not load right now.',
            onBack: () => context.go(RouteNames.assets),
            onReload: () => ref.invalidate(assetEquipmentRegisterProvider),
          ),
          data: (equipmentTable) {
            return partsAsync.when(
              loading: () => const Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _InventoryError(
                title: 'Inventory session',
                message: 'Parts inventory could not load right now.',
                onBack: () => context.go(RouteNames.assets),
                onReload: () => ref.invalidate(assetPartsRegisterProvider),
              ),
              data: (partsTable) {
                return labelsAsync.when(
                  loading: () => const Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => _InventoryError(
                    title: 'Inventory session',
                    message: 'QR labels could not load right now.',
                    onBack: () => context.go(RouteNames.assets),
                    onReload: () =>
                        ref.invalidate(assetQrLabelRegisterProvider),
                  ),
                  data: (labelsTable) {
                    return lowStockAsync.when(
                      loading: () => const Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => _InventoryError(
                        title: 'Inventory session',
                        message: 'Low stock data could not load right now.',
                        onBack: () => context.go(RouteNames.assets),
                        onReload: () =>
                            ref.invalidate(assetLowStockPartsProvider),
                      ),
                      data: (lowStockRows) {
                        return sessionLogAsync.when(
                          loading: () => const Scaffold(
                            backgroundColor: Colors.transparent,
                            body: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stackTrace) => _InventoryError(
                            title: 'Inventory session',
                            message:
                                'The inventory session log could not load right now.',
                            onBack: () => context.go(RouteNames.assets),
                            onReload: () => ref.invalidate(
                              assetInventorySessionLogProvider,
                            ),
                          ),
                          data: (sessionLogTable) {
                            final qrLabelsByAssetId = {
                              for (final row in labelsTable.rows)
                                if ((row['asset_id'] ?? '').trim().isNotEmpty)
                                  row['asset_id']!.trim(): row,
                            };
                            final equipmentCount = equipmentTable.rows.length;
                            final partsCount = partsTable.rows.length;
                            final lowStockCount = lowStockRows.length;
                            final labeledEquipmentCount = equipmentTable.rows
                                .where((row) {
                                  final assetId = (row['asset_id'] ?? '')
                                      .trim();
                                  final labelCode =
                                      (qrLabelsByAssetId[assetId]?['label_code'] ??
                                              '')
                                          .trim();
                                  return assetId.isNotEmpty &&
                                      labelCode.isNotEmpty;
                                })
                                .length;
                            final unlabeledEquipmentCount =
                                equipmentCount - labeledEquipmentCount;

                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              body: SafeArea(
                                child: CustomScrollView(
                                  slivers: [
                                    SliverPadding(
                                      padding: const EdgeInsets.all(20),
                                      sliver: SliverToBoxAdapter(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _InventoryHeroCard(
                                              workspacePath:
                                                  workspace.assetsRootPath,
                                              equipmentCount: equipmentCount,
                                              partsCount: partsCount,
                                              labeledEquipmentCount:
                                                  labeledEquipmentCount,
                                              unlabeledEquipmentCount:
                                                  unlabeledEquipmentCount,
                                              lowStockCount: lowStockCount,
                                              onBack: () =>
                                                  context.go(RouteNames.assets),
                                              onOpenEquipment: () =>
                                                  context.push(
                                                    RouteNames.assetEquipment,
                                                  ),
                                              onOpenParts: () => context.push(
                                                RouteNames.assetParts,
                                              ),
                                              onOpenLowStock: () =>
                                                  context.push(
                                                    RouteNames.assetLowStock,
                                                  ),
                                              onOpenQrLabels: () =>
                                                  context.push(
                                                    RouteNames
                                                        .assetQrLabelRegister,
                                                  ),
                                              onOpenQrStudio: () =>
                                                  context.push(
                                                    RouteNames
                                                        .assetQrLabelStudio,
                                                  ),
                                              onOpenPrintQueue: () =>
                                                  context.push(
                                                    RouteNames
                                                        .assetQrPrintQueue,
                                                  ),
                                            ),
                                            const SizedBox(height: 20),
                                            _InventoryPlanCard(
                                              sessionNameController:
                                                  _sessionNameController,
                                              notesController: _notesController,
                                              onBuildPack:
                                                  _isBuilding ||
                                                      workspace
                                                              .assetsRootPath ==
                                                          null
                                                  ? null
                                                  : () => _buildPack(
                                                      workspace.assetsRootPath!,
                                                      equipmentTable.rows,
                                                      partsTable.rows,
                                                      qrLabelsByAssetId,
                                                      lowStockCount,
                                                    ),
                                              onOpenLatestPack:
                                                  _latestPack == null
                                                  ? null
                                                  : () => _openFile(
                                                      _latestPack!.pdfFile,
                                                    ),
                                              isBusy: _isBuilding,
                                              latestPack: _latestPack,
                                            ),
                                            const SizedBox(height: 20),
                                            if (_latestPack != null) ...[
                                              _LatestPackCard(
                                                pack: _latestPack!,
                                                onOpenFolder: () => _openFolder(
                                                  _latestPack!.pdfFile.parent,
                                                ),
                                                onOpenCsv: () => _openFile(
                                                  _latestPack!.csvFile,
                                                ),
                                                onOpenPdf: () => _openFile(
                                                  _latestPack!.pdfFile,
                                                ),
                                                onCopyCsvPath: () => _copyPath(
                                                  _latestPack!.csvFile.path,
                                                ),
                                                onCopyPdfPath: () => _copyPath(
                                                  _latestPack!.pdfFile.path,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                final wide =
                                                    constraints.maxWidth >= 960;
                                                final left = Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _SessionNotesCard(
                                                      title:
                                                          'How to run the count',
                                                      items: const [
                                                        'Print the inventory pack first.',
                                                        'Walk equipment and parts together, shelf by shelf.',
                                                        'Use the QR labels to confirm IDs before you count.',
                                                        'Record anything missing or broken in the notes column.',
                                                      ],
                                                    ),
                                                    const SizedBox(height: 18),
                                                    _SessionNotesCard(
                                                      title:
                                                          'What this pack covers',
                                                      items: [
                                                        '$equipmentCount equipment items',
                                                        '$partsCount parts rows',
                                                        '$labeledEquipmentCount equipment items already linked to QR labels',
                                                        '$unlabeledEquipmentCount equipment items still missing a QR label',
                                                      ],
                                                    ),
                                                  ],
                                                );

                                                final right = _SessionLogCard(
                                                  sessions:
                                                      sessionLogTable.rows,
                                                );

                                                if (wide) {
                                                  return Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(child: left),
                                                      const SizedBox(width: 18),
                                                      Expanded(child: right),
                                                    ],
                                                  );
                                                }

                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    left,
                                                    const SizedBox(height: 18),
                                                    right,
                                                  ],
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
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _buildPack(
    String assetsRootPath,
    List<Map<String, String>> equipmentRows,
    List<Map<String, String>> partsRows,
    Map<String, Map<String, String>> qrLabelsByAssetId,
    int lowStockCount,
  ) async {
    if (_isBuilding) {
      return;
    }

    setState(() {
      _isBuilding = true;
    });

    try {
      final pack = await ref
          .read(assetInventorySessionServiceProvider)
          .buildInventoryPack(
            assetsRootPath,
            sessionName: _sessionNameController.text,
            equipmentRows: equipmentRows,
            partsRows: partsRows,
            qrLabelsByAssetId: qrLabelsByAssetId,
            lowStockPartsCount: lowStockCount,
            notes: _notesController.text,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _latestPack = pack;
      });
      ref.invalidate(assetInventorySessionLogProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Inventory pack built: ${path.basename(pack.csvFile.path)}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBuilding = false;
        });
      }
    }
  }

  Future<void> _openFolder(Directory folder) async {
    if (!Platform.isWindows) return;
    await Process.start('explorer.exe', [folder.path]);
  }

  Future<void> _openFile(File file) async {
    if (!Platform.isWindows) return;
    await Process.start('cmd.exe', [
      '/c',
      'start',
      '""',
      file.path,
    ], workingDirectory: file.parent.path);
  }

  Future<void> _copyPath(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied path: $value')));
  }
}

class _InventoryHeroCard extends StatelessWidget {
  const _InventoryHeroCard({
    required this.workspacePath,
    required this.equipmentCount,
    required this.partsCount,
    required this.labeledEquipmentCount,
    required this.unlabeledEquipmentCount,
    required this.lowStockCount,
    required this.onBack,
    required this.onOpenEquipment,
    required this.onOpenParts,
    required this.onOpenLowStock,
    required this.onOpenQrLabels,
    required this.onOpenQrStudio,
    required this.onOpenPrintQueue,
  });

  final String? workspacePath;
  final int equipmentCount;
  final int partsCount;
  final int labeledEquipmentCount;
  final int unlabeledEquipmentCount;
  final int lowStockCount;
  final VoidCallback onBack;
  final VoidCallback onOpenEquipment;
  final VoidCallback onOpenParts;
  final VoidCallback onOpenLowStock;
  final VoidCallback onOpenQrLabels;
  final VoidCallback onOpenQrStudio;
  final VoidCallback onOpenPrintQueue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Session',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Build a calm stocktake pack for you and Hayley. The session keeps the registers, QR labels, and printable checklist together for this week.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                workspacePath ?? 'Asset folder not linked',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                ),
              ),
            ],
          );

          final chips = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(label: 'Equipment', value: '$equipmentCount'),
              _StatChip(label: 'Parts', value: '$partsCount'),
              _StatChip(label: 'QR linked', value: '$labeledEquipmentCount'),
              _StatChip(label: 'QR missing', value: '$unlabeledEquipmentCount'),
              _StatChip(label: 'Low stock', value: '$lowStockCount'),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Assets'),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenEquipment,
                icon: const Icon(Icons.precision_manufacturing_outlined),
                label: const Text('Open Equipment'),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenParts,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Open Parts'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLowStock,
                icon: const Icon(Icons.trending_down_outlined),
                label: const Text('Low Stock'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrLabels,
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text('QR Labels'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenQrStudio,
                icon: const Icon(Icons.print_outlined),
                label: const Text('QR Studio'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenPrintQueue,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Print Queue'),
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
                width: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [chips, const SizedBox(height: 16), actions],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InventoryPlanCard extends StatelessWidget {
  const _InventoryPlanCard({
    required this.sessionNameController,
    required this.notesController,
    required this.onBuildPack,
    required this.onOpenLatestPack,
    required this.isBusy,
    required this.latestPack,
  });

  final TextEditingController sessionNameController;
  final TextEditingController notesController;
  final VoidCallback? onBuildPack;
  final VoidCallback? onOpenLatestPack;
  final bool isBusy;
  final AssetInventorySessionPack? latestPack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Build this week\'s pack',
            icon: Icons.checklist_rounded,
          ),
          const SizedBox(height: 10),
          Text(
            'Use this to prep a local CSV and printable PDF before you and Hayley walk the stock and asset shelves.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: sessionNameController,
            decoration: const InputDecoration(
              labelText: 'Session name',
              hintText: 'Hayley and Ellis inventory week',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Session notes',
              hintText: 'What to count, what to check, and what to flag.',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onBuildPack,
                icon: isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.playlist_add_check),
                label: Text(isBusy ? 'Building' : 'Build inventory pack'),
              ),
              if (latestPack != null)
                FilledButton.tonalIcon(
                  onPressed: onOpenLatestPack,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Open latest PDF'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LatestPackCard extends StatelessWidget {
  const _LatestPackCard({
    required this.pack,
    required this.onOpenFolder,
    required this.onOpenCsv,
    required this.onOpenPdf,
    required this.onCopyCsvPath,
    required this.onCopyPdfPath,
  });

  final AssetInventorySessionPack pack;
  final VoidCallback onOpenFolder;
  final VoidCallback onOpenCsv;
  final VoidCallback onOpenPdf;
  final VoidCallback onCopyCsvPath;
  final VoidCallback onCopyPdfPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Latest pack',
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            pack.sessionName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CSV and PDF are ready in the inventory sessions folder.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(label: 'Equipment', value: '${pack.equipmentCount}'),
              _StatChip(label: 'Parts', value: '${pack.partsCount}'),
              _StatChip(
                label: 'QR linked',
                value: '${pack.labeledEquipmentCount}',
              ),
              _StatChip(
                label: 'QR missing',
                value: '${pack.unlabeledEquipmentCount}',
              ),
              _StatChip(
                label: 'Low stock',
                value: '${pack.lowStockPartsCount}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onOpenFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open folder'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenCsv,
                icon: const Icon(Icons.table_view_outlined),
                label: const Text('Open CSV'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Open PDF'),
              ),
              TextButton.icon(
                onPressed: onCopyCsvPath,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy CSV'),
              ),
              TextButton.icon(
                onPressed: onCopyPdfPath,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy PDF'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionNotesCard extends StatelessWidget {
  const _SessionNotesCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title, icon: Icons.notes_outlined),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionLogCard extends StatelessWidget {
  const _SessionLogCard({required this.sessions});

  final List<Map<String, String>> sessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Recent inventory sessions',
            icon: Icons.history_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Keep a local record of each stocktake week so you can compare counts later.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          if (sessions.isEmpty)
            Text(
              'No inventory sessions have been built yet.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Column(
              children: [
                for (final row in sessions.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColours.darkSurfaceAlt.withValues(
                          alpha: 0.94,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColours.darkOutline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (row['session_name'] ?? '').trim().isNotEmpty
                                ? row['session_name']!.trim()
                                : 'Inventory session',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColours.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (row['created_at'] ?? '').trim(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColours.darkMutedText),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Equipment ${row['equipment_items'] ?? '0'}  •  Parts ${row['parts_items'] ?? '0'}  •  QR missing ${row['unlabeled_equipment_items'] ?? '0'}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColours.darkSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InventoryError extends StatelessWidget {
  const _InventoryError({
    required this.title,
    required this.message,
    required this.onBack,
    required this.onReload,
  });

  final String title;
  final String message;
  final VoidCallback onBack;
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
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                  TextButton.icon(
                    onPressed: onReload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reload'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceRaised.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColours.darkSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColours.darkText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

BoxDecoration _panelDecoration({bool highlighted = false}) {
  return BoxDecoration(
    color: highlighted
        ? AppColours.darkSurfaceAlt.withValues(alpha: 0.96)
        : AppColours.darkSurface.withValues(alpha: 0.93),
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
