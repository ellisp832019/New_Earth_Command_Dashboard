// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colours.dart';
import '../application/assets_controller.dart';
import '../data/qr_label_printing_service.dart';

class QrLabelStudioScreen extends ConsumerStatefulWidget {
  const QrLabelStudioScreen({super.key});

  @override
  ConsumerState<QrLabelStudioScreen> createState() =>
      _QrLabelStudioScreenState();
}

class _QrLabelStudioScreenState extends ConsumerState<QrLabelStudioScreen> {
  late final TextEditingController _searchController;
  late final TextEditingController _assetIdController;
  late final TextEditingController _labelTextController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;

  String _labelType = QrLabelPrintService.labelTypes.first.id;
  String _labelSize = QrLabelPrintService.labelSizes[3].id;
  String _printerProfileId = '';
  String _selectedPrinterUrl = '';
  String _priority = 'normal';
  Map<String, String>? _selectedAsset;
  QrLabelPreview? _preview;
  bool _isBusy = false;
  bool _didSeedPm260 = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _assetIdController = TextEditingController();
    _labelTextController = TextEditingController();
    _locationController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _assetIdController.dispose();
    _labelTextController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceAsync = ref.watch(assetWorkspaceProvider);
    final equipmentAsync = ref.watch(assetEquipmentRegisterProvider);
    final labelRegisterAsync = ref.watch(assetQrLabelTemplateRegisterProvider);
    final queueAsync = ref.watch(assetQrPrintQueueProvider);
    final profilesAsync = ref.watch(assetQrPrinterProfilesProvider);
    final bulkTemplatesAsync = ref.watch(assetQrBulkTemplatesProvider);
    final printersAsync = ref.watch(assetAvailablePrintersProvider);
    final printingInfoAsync = ref.watch(assetPrintingInfoProvider);

    return workspaceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _StudioError(
        message: 'Knowledge of the asset folder is not ready yet.',
        onBack: () => context.go(RouteNames.assets),
        onReload: () => ref.invalidate(assetWorkspaceProvider),
      ),
      data: (workspace) {
        return equipmentAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => _StudioError(
            message: 'Equipment register could not load right now.',
            onBack: () => context.go(RouteNames.assets),
            onReload: () => ref.invalidate(assetEquipmentRegisterProvider),
          ),
          data: (equipmentTable) {
            return queueAsync.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _StudioError(
                message: 'Print queue could not load right now.',
                onBack: () => context.go(RouteNames.assets),
                onReload: () => ref.invalidate(assetQrPrintQueueProvider),
              ),
              data: (queueTable) {
                return profilesAsync.when(
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => _StudioError(
                    message: 'Printer profiles could not load right now.',
                    onBack: () => context.go(RouteNames.assets),
                    onReload: () =>
                        ref.invalidate(assetQrPrinterProfilesProvider),
                  ),
                  data: (profilesTable) {
                    final filteredAssets = _filteredAssets(
                      equipmentTable.rows,
                      _searchController.text,
                    );
                    final assetsRootPath = workspace.assetsRootPath;
                    final printerProfiles = profilesTable.rows;
                    final availablePrinters =
                        printersAsync.asData?.value ?? const <Printer>[];
                    final printingInfo = printingInfoAsync.asData?.value;
                    final selectedPrinter = _selectedPrinter(
                      availablePrinters,
                      _selectedPrinterUrl,
                    );
                    if (assetsRootPath != null &&
                        printerProfiles.isEmpty &&
                        !_didSeedPm260) {
                      _didSeedPm260 = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (!mounted) {
                          return;
                        }
                        await ref
                            .read(assetQrLabelPrintServiceProvider)
                            .ensurePm260Preset(assetsRootPath);
                        ref.invalidate(assetQrPrinterProfilesProvider);
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _statusMessage =
                              'PM260 preset added for this workspace.';
                        });
                      });
                    }
                    final selectedPrinterProfile = _selectedPrinterProfile(
                      printerProfiles,
                    );
                    final hasPm260Preset = printerProfiles.any((row) {
                      final id = (row['profile_id'] ?? '').trim().toLowerCase();
                      final printerName = (row['printer_name'] ?? '')
                          .trim()
                          .toLowerCase();
                      return id ==
                              QrLabelPrintService.pm260Preset.profileId
                                  .toLowerCase() ||
                          printerName.contains('pm260');
                    });
                    final currentDraft = _buildDraft(
                      printerProfileId: selectedPrinterProfile,
                    );
                    final latestTemplateLabel = _latestTemplateLabel(
                      bulkTemplatesAsync.asData?.value.rows ?? const [],
                    );
                    final readyRows = _queueRowsByStatus(queueTable.rows, {
                      'generated',
                      'queued',
                    });
                    final retryRows = _queueRowsByStatus(queueTable.rows, {
                      'reprint_needed',
                    });
                    final printedRows = _queueRowsByStatus(queueTable.rows, {
                      'printed',
                    });
                    final appliedRows = _queueRowsByStatus(queueTable.rows, {
                      'applied',
                    });

                    return Scaffold(
                      backgroundColor: Colors.transparent,
                      body: SafeArea(
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.all(20),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _StudioHero(
                                      onBackToAssets: () =>
                                          context.go(RouteNames.assets),
                                      onBackToRegister: () => context.go(
                                        RouteNames.assetQrLabelRegister,
                                      ),
                                      onOpenHistory: () => context.push(
                                        RouteNames.assetQrLabelHistory,
                                      ),
                                      onOpenPrintQueue: () => context.push(
                                        RouteNames.assetQrPrintQueue,
                                      ),
                                      onOpenScanLookup: () => context.push(
                                        RouteNames.assetScanLookup,
                                      ),
                                      onOpenInventorySession: () =>
                                          context.push(
                                            RouteNames.assetInventorySession,
                                          ),
                                      readyCount: readyRows.length,
                                      retryCount: retryRows.length,
                                      printedCount: printedRows.length,
                                      appliedCount: appliedRows.length,
                                      hasPm260Preset: hasPm260Preset,
                                      latestTemplateLabel: latestTemplateLabel,
                                      onRefresh: () {
                                        ref.invalidate(
                                          assetQrLabelTemplateRegisterProvider,
                                        );
                                        ref.invalidate(
                                          assetQrPrintQueueProvider,
                                        );
                                        ref.invalidate(
                                          assetQrBulkTemplatesProvider,
                                        );
                                        ref.invalidate(
                                          assetQrPrinterProfilesProvider,
                                        );
                                        ref.invalidate(
                                          assetEquipmentRegisterProvider,
                                        );
                                      },
                                      workspacePath: workspace.assetsRootPath,
                                    ),
                                    const SizedBox(height: 20),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final wide =
                                            constraints.maxWidth >= 1200;
                                        final left = Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _BuildCard(
                                              searchController:
                                                  _searchController,
                                              assetIdController:
                                                  _assetIdController,
                                              labelTextController:
                                                  _labelTextController,
                                              locationController:
                                                  _locationController,
                                              notesController: _notesController,
                                              selectedAsset: _selectedAsset,
                                              filteredAssets: filteredAssets,
                                              labelType: _labelType,
                                              labelSize: _labelSize,
                                              selectedPrinterProfile:
                                                  selectedPrinterProfile,
                                              printerProfiles: printerProfiles,
                                              priority: _priority,
                                              canUseWorkspace:
                                                  assetsRootPath != null,
                                              onAssetSelected: _applyAsset,
                                              onSearchChanged: () =>
                                                  setState(() {}),
                                              onLabelTypeChanged: (value) {
                                                setState(() {
                                                  _labelType = value;
                                                });
                                              },
                                              onLabelSizeChanged: (value) {
                                                setState(() {
                                                  _labelSize = value;
                                                });
                                              },
                                              onPrinterProfileChanged: (value) {
                                                setState(() {
                                                  _printerProfileId = value;
                                                });
                                              },
                                              onPriorityChanged: (value) {
                                                setState(() {
                                                  _priority = value;
                                                });
                                              },
                                              onGeneratePreview:
                                                  assetsRootPath == null
                                                  ? null
                                                  : () => _generatePreview(
                                                      assetsRootPath,
                                                      selectedPrinterProfile,
                                                    ),
                                              onAddToQueue:
                                                  assetsRootPath == null
                                                  ? null
                                                  : () => _addToQueue(
                                                      assetsRootPath,
                                                      selectedPrinterProfile,
                                                    ),
                                              onBulkGenerate:
                                                  assetsRootPath == null ||
                                                      filteredAssets.isEmpty
                                                  ? null
                                                  : () => _bulkGenerate(
                                                      assetsRootPath,
                                                      selectedPrinterProfile,
                                                      filteredAssets,
                                                    ),
                                              onLoadLatestTemplate:
                                                  assetsRootPath == null
                                                  ? null
                                                  : () =>
                                                        _loadLatestBulkTemplate(
                                                          assetsRootPath,
                                                        ),
                                              onCopyLatestTemplate:
                                                  assetsRootPath == null
                                                  ? null
                                                  : () =>
                                                        _copyLatestBulkTemplate(
                                                          assetsRootPath,
                                                        ),
                                              onSaveBulkTemplate:
                                                  assetsRootPath == null
                                                  ? null
                                                  : () => _saveBulkTemplate(
                                                      assetsRootPath,
                                                      selectedPrinterProfile,
                                                    ),
                                              onLoadBulkTemplate:
                                                  assetsRootPath == null
                                                  ? null
                                                  : () => _loadBulkTemplate(
                                                      assetsRootPath,
                                                    ),
                                              onPrint: assetsRootPath == null
                                                  ? null
                                                  : () => _printLabel(
                                                      assetsRootPath,
                                                      selectedPrinterProfile,
                                                    ),
                                              onOpenFolder: _preview == null
                                                  ? null
                                                  : () => _openFolder(
                                                      _preview!.pdfFile.parent,
                                                    ),
                                              isBusy: _isBusy,
                                              statusMessage: _statusMessage,
                                            ),
                                            const SizedBox(height: 20),
                      _PreviewCard(
                        preview: _preview,
                        currentDraft: currentDraft,
                        selectedPrinterProfile: selectedPrinterProfile,
                        printerProfileCount: printerProfiles.length,
                      ),
                                          ],
                                        );

                                        final right = Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _PrinterConnectionCard(
                                              printers: availablePrinters,
                                              printingInfo: printingInfo,
                                              selectedPrinter: selectedPrinter,
                                              selectedPrinterProfile:
                                                  selectedPrinterProfile,
                                              hasPm260Preset: hasPm260Preset,
                                              onPrinterChanged: (printer) {
                                                setState(() {
                                                  _selectedPrinterUrl =
                                                      printer?.url ?? '';
                                                });
                                              },
                                              onPrintSelected:
                                                  assetsRootPath == null ||
                                                      selectedPrinter == null
                                                  ? null
                                                  : () =>
                                                        _printToConnectedPrinter(
                                                          selectedPrinter,
                                                        ),
                                            ),
                                            const SizedBox(height: 20),
                                            _PrinterProfilesCard(
                                              profiles: printerProfiles,
                                              onAddProfile: () =>
                                                  _addPrinterProfile(
                                                    workspace.assetsRootPath!,
                                                  ),
                                              onAddPm260Preset: () =>
                                                  _addPm260Preset(
                                                    workspace.assetsRootPath!,
                                                  ),
                                            ),
                                            const SizedBox(height: 20),
                                            _LabelRegisterCard(
                                              labels:
                                                  labelRegisterAsync
                                                      .asData
                                                      ?.value
                                                      .rows ??
                                                  const [],
                                              onEditLabel: (row) =>
                                                  _editLabelRegisterEntry(
                                                    workspace.assetsRootPath!,
                                                    row,
                                                  ),
                                              onDeleteLabel: (row) =>
                                                  _deleteLabelRegisterEntry(
                                                    workspace.assetsRootPath!,
                                                    row,
                                                  ),
                                            ),
                                            const SizedBox(height: 20),
                                            _QueueBoardCard(
                                              title: 'Ready to print',
                                              subtitle:
                                                  'Queued or generated labels waiting for the PM260 or the Windows print dialog.',
                                              rows: readyRows,
                                              accent: AppColours.darkSuccess,
                                              onMarkPrinted: (queueId) =>
                                                  _markQueuePrinted(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                              onMarkApplied: (queueId) =>
                                                  _markQueueApplied(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                              onMarkReprintNeeded: (queueId) =>
                                                  _markQueueReprintNeeded(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                            ),
                                            const SizedBox(height: 20),
                                            _QueueBoardCard(
                                              title: 'Printed, needs applying',
                                              subtitle:
                                                  'Labels that have printed and still need to be applied to the physical item.',
                                              rows: printedRows,
                                              accent: AppColours.darkAmber,
                                              onMarkPrinted: (queueId) =>
                                                  _markQueuePrinted(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                              onMarkApplied: (queueId) =>
                                                  _markQueueApplied(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                              onMarkReprintNeeded: (queueId) =>
                                                  _markQueueReprintNeeded(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                            ),
                                            const SizedBox(height: 20),
                                            _QueueBoardCard(
                                              title: 'Applied',
                                              subtitle:
                                                  'Labels already on the assets or bins.',
                                              rows: appliedRows,
                                              accent: AppColours.darkSecondary,
                                              onMarkPrinted: (queueId) =>
                                                  _markQueuePrinted(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                              onMarkApplied: (queueId) =>
                                                  _markQueueApplied(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                              onMarkReprintNeeded: (queueId) =>
                                                  _markQueueReprintNeeded(
                                                    workspace.assetsRootPath!,
                                                    queueId,
                                                  ),
                                            ),
                                          ],
                                        );

                                        if (wide) {
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(flex: 3, child: left),
                                              const SizedBox(width: 20),
                                              Expanded(flex: 2, child: right),
                                            ],
                                          );
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            left,
                                            const SizedBox(height: 20),
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
  }

  void _applyAsset(Map<String, String> row) {
    final assetId = (row['asset_id'] ?? '').trim();
    setState(() {
      _selectedAsset = row;
      _assetIdController.text = assetId;
      _labelTextController.text = (row['name'] ?? '').trim();
      _locationController.text = (row['location'] ?? '').trim();
      _notesController.text = (row['project'] ?? '').trim();
      _preview = null;
      _statusMessage = 'Loaded $assetId.';
    });
  }

  Future<void> _generatePreview(
    String assetsRootPath,
    String printerProfileId,
  ) async {
    final draft = _buildDraft(printerProfileId: printerProfileId);
    if (draft.assetId.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Choose or enter an asset ID first.';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = 'Generating QR label preview...';
    });
    try {
      final preview = await ref
          .read(assetQrLabelPrintServiceProvider)
          .generateLabelArtifacts(assetsRootPath, draft);
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = preview;
        _statusMessage = 'Preview ready and saved locally.';
      });
      ref.invalidate(assetQrLabelTemplateRegisterProvider);
      ref.invalidate(assetQrPrintQueueProvider);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _addToQueue(
    String assetsRootPath,
    String printerProfileId,
  ) async {
    final draft = _buildDraft(printerProfileId: printerProfileId);
    if (draft.assetId.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Choose or enter an asset ID first.';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = 'Adding label to the print queue...';
    });
    try {
      final queueEntry = await ref
          .read(assetQrLabelPrintServiceProvider)
          .addToQueue(
            assetsRootPath,
            draft,
            generatedFilePath: _preview?.pdfFile.path,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Queued ${queueEntry.assetId} for printing.';
      });
      ref.invalidate(assetQrPrintQueueProvider);
      ref.invalidate(assetQrLabelTemplateRegisterProvider);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _printLabel(
    String assetsRootPath,
    String printerProfileId,
  ) async {
    final draft = _buildDraft(printerProfileId: printerProfileId);
    if (draft.assetId.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Choose or enter an asset ID first.';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = 'Opening the Windows print dialog...';
    });
    try {
      await ref.read(assetQrLabelPrintServiceProvider).printLabel(draft);
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Print dialog opened. Mark the queue row when done.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _markQueuePrinted(String assetsRootPath, String queueId) async {
    await ref
        .read(assetQrLabelPrintServiceProvider)
        .markQueuePrinted(assetsRootPath, queueId);
    ref.invalidate(assetQrPrintQueueProvider);
    ref.invalidate(assetQrLabelTemplateRegisterProvider);
    if (mounted) {
      setState(() {
        _statusMessage = 'Marked queue item as printed.';
      });
    }
  }

  Future<void> _bulkGenerate(
    String assetsRootPath,
    String printerProfileId,
    List<Map<String, String>> rows,
  ) async {
    if (_isBusy || rows.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bulk generate labels?'),
          content: Text(
            'Generate labels for ${rows.length} filtered asset${rows.length == 1 ? '' : 's'} using the current label type, size, and printer profile.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage =
          'Bulk generating ${rows.length} label${rows.length == 1 ? '' : 's'}...';
    });

    final service = ref.read(assetQrLabelPrintServiceProvider);
    var generatedCount = 0;
    var skippedCount = 0;

    try {
      for (final row in rows) {
        final assetId = (row['asset_id'] ?? '').trim();
        if (assetId.isEmpty) {
          skippedCount += 1;
          continue;
        }

        final draft = _draftFromAssetRow(
          row,
          printerProfileId: printerProfileId,
        );
        final preview = await service.generateLabelArtifacts(
          assetsRootPath,
          draft,
        );
        await service.addToQueue(
          assetsRootPath,
          draft,
          generatedFilePath: preview.pdfFile.path,
        );
        generatedCount += 1;

        if (mounted && generatedCount % 10 == 0) {
          setState(() {
            _statusMessage =
                'Bulk generated $generatedCount of ${rows.length} labels...';
          });
        }
      }

      ref.invalidate(assetQrLabelTemplateRegisterProvider);
      ref.invalidate(assetQrPrintQueueProvider);
      if (mounted) {
        setState(() {
          _statusMessage =
              'Bulk generated $generatedCount label${generatedCount == 1 ? '' : 's'}${skippedCount > 0 ? ' and skipped $skippedCount empty row${skippedCount == 1 ? '' : 's'}' : ''}.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _saveBulkTemplate(
    String assetsRootPath,
    String printerProfileId,
  ) async {
    final templateName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(
          text:
              'Bulk ${_searchController.text.trim().isEmpty ? 'labels' : _searchController.text.trim()}',
        );
        return AlertDialog(
          title: const Text('Save bulk template'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Template name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (templateName == null || templateName.trim().isEmpty) {
      return;
    }

    final service = ref.read(assetQrLabelPrintServiceProvider);
    final template = QrBulkTemplate(
      templateId: templateName,
      templateName: templateName,
      searchQuery: _searchController.text,
      labelType: _labelType,
      labelSize: _labelSize,
      printerProfileId: printerProfileId,
      priority: _priority,
      notes: 'Saved from QR Studio',
      createdAt: DateTime.now(),
    );

    await service.upsertBulkTemplate(assetsRootPath, template);
    if (!mounted) {
      return;
    }

    setState(() {
      _statusMessage = 'Saved bulk template "$templateName".';
    });
  }

  Future<void> _loadBulkTemplate(String assetsRootPath) async {
    final service = ref.read(assetQrLabelPrintServiceProvider);
    final table = await service.readBulkTemplates(assetsRootPath);
    final templates =
        table.rows.map(QrBulkTemplate.fromCsvRow).toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (templates.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved bulk templates yet.')),
      );
      return;
    }

    final selected = await showDialog<QrBulkTemplate>(
      context: context,
      builder: (context) {
        var chosen = templates.first;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Load bulk template'),
              content: SizedBox(
                width: 560,
                height: 420,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: templates.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return RadioListTile<QrBulkTemplate>(
                      value: template,
                      groupValue: chosen,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          chosen = value;
                        });
                      },
                      title: Text(template.templateName),
                      subtitle: Text(
                        '${template.searchQuery.isEmpty ? 'No search' : template.searchQuery} • ${template.labelType} • ${template.labelSize}',
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(chosen),
                  child: const Text('Load'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _searchController.text = selected.searchQuery;
      _labelType = selected.labelType;
      _labelSize = selected.labelSize;
      _printerProfileId = selected.printerProfileId;
      _priority = selected.priority;
      _statusMessage = 'Loaded bulk template "${selected.templateName}".';
    });
  }

  Future<void> _loadLatestBulkTemplate(String assetsRootPath) async {
    final service = ref.read(assetQrLabelPrintServiceProvider);
    final table = await service.readBulkTemplates(assetsRootPath);
    final templates =
        table.rows.map(QrBulkTemplate.fromCsvRow).toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (templates.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved bulk templates yet.')),
      );
      return;
    }

    final selected = templates.first;
    setState(() {
      _searchController.text = selected.searchQuery;
      _labelType = selected.labelType;
      _labelSize = selected.labelSize;
      _printerProfileId = selected.printerProfileId;
      _priority = selected.priority;
      _statusMessage =
          'Loaded latest bulk template "${selected.templateName}".';
    });
  }

  Future<void> _copyLatestBulkTemplate(String assetsRootPath) async {
    final table = await ref
        .read(assetQrLabelPrintServiceProvider)
        .readBulkTemplates(assetsRootPath);
    final templates =
        table.rows.map(QrBulkTemplate.fromCsvRow).toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (templates.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved bulk templates yet.')),
      );
      return;
    }

    final selected = templates.first;
    final payload = [
      'Template: ${selected.templateName}',
      'Search query: ${selected.searchQuery.isEmpty ? '(none)' : selected.searchQuery}',
      'Label type: ${selected.labelType}',
      'Label size: ${selected.labelSize}',
      'Printer profile: ${selected.printerProfileId.isEmpty ? '(none)' : selected.printerProfileId}',
      'Priority: ${selected.priority}',
      'Notes: ${selected.notes.isEmpty ? '(none)' : selected.notes}',
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) {
      return;
    }

    setState(() {
      _statusMessage = 'Copied "${selected.templateName}" to the clipboard.';
    });
  }

  Future<void> _markQueueApplied(String assetsRootPath, String queueId) async {
    await ref
        .read(assetQrLabelPrintServiceProvider)
        .markQueueApplied(assetsRootPath, queueId);
    ref.invalidate(assetQrPrintQueueProvider);
    ref.invalidate(assetQrLabelTemplateRegisterProvider);
    if (mounted) {
      setState(() {
        _statusMessage = 'Marked queue item as applied.';
      });
    }
  }

  Future<void> _markQueueReprintNeeded(
    String assetsRootPath,
    String queueId,
  ) async {
    await ref
        .read(assetQrLabelPrintServiceProvider)
        .markQueueReprintNeeded(assetsRootPath, queueId);
    ref.invalidate(assetQrPrintQueueProvider);
    ref.invalidate(assetQrLabelTemplateRegisterProvider);
    if (mounted) {
      setState(() {
        _statusMessage = 'Marked queue item for reprint.';
      });
    }
  }

  Future<void> _editLabelRegisterEntry(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    final entry = await showDialog<QrLabelRegisterEntry>(
      context: context,
      builder: (context) => _EditLabelRegisterDialog(row: row),
    );
    if (entry == null) {
      return;
    }

    await ref
        .read(assetQrLabelPrintServiceProvider)
        .updateLabelRegisterEntry(assetsRootPath, entry);
    ref.invalidate(assetQrLabelTemplateRegisterProvider);
    if (mounted) {
      setState(() {
        _statusMessage = 'Updated label entry ${entry.labelId}.';
      });
    }
  }

  Future<void> _deleteLabelRegisterEntry(
    String assetsRootPath,
    Map<String, String> row,
  ) async {
    final labelId = (row['label_id'] ?? '').trim();
    if (labelId.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete label entry?'),
          content: Text(
            'Remove $labelId from the local label register? This keeps the generated files and manifest on disk.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete entry'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(assetQrLabelPrintServiceProvider)
        .deleteLabelRegisterEntry(assetsRootPath, labelId);
    ref.invalidate(assetQrLabelTemplateRegisterProvider);
    if (mounted) {
      setState(() {
        _statusMessage = 'Deleted label entry $labelId from the register.';
      });
    }
  }

  Future<void> _addPrinterProfile(String assetsRootPath) async {
    final profile = await showDialog<QrPrinterProfile>(
      context: context,
      builder: (context) => const _AddPrinterProfileDialog(),
    );
    if (profile == null) {
      return;
    }

    await ref
        .read(assetQrLabelPrintServiceProvider)
        .appendPrinterProfile(assetsRootPath, profile);
    ref.invalidate(assetQrPrinterProfilesProvider);
    if (mounted) {
      setState(() {
        _printerProfileId = profile.profileId;
        _statusMessage = 'Saved printer profile ${profile.profileId}.';
      });
    }
  }

  Future<void> _addPm260Preset(String assetsRootPath) async {
    await ref
        .read(assetQrLabelPrintServiceProvider)
        .ensurePm260Preset(assetsRootPath);
    ref.invalidate(assetQrPrinterProfilesProvider);
    if (mounted) {
      setState(() {
        _printerProfileId = QrLabelPrintService.pm260Preset.profileId;
        _statusMessage = 'PM260 preset added or already available.';
      });
    }
  }

  Future<void> _openFolder(Directory folder) async {
    if (!Platform.isWindows) {
      return;
    }

    await Process.start('explorer.exe', [folder.path]);
  }

  Future<void> _printToConnectedPrinter(Printer printer) async {
    final draft = _buildDraft(printerProfileId: _selectedPrinterProfileId());
    if (draft.assetId.trim().isEmpty) {
      setState(() {
        _statusMessage = 'Choose or enter an asset ID first.';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = 'Sending the label to ${printer.name}...';
    });
    try {
      await ref
          .read(assetQrLabelPrintServiceProvider)
          .printLabelToPrinter(draft, printer);
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage =
            'Sent the label to ${printer.name}. Mark the queue row when done.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = _friendlyErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  QrLabelDraft _buildDraft({required String printerProfileId}) {
    return QrLabelDraft(
      assetId: _assetIdController.text,
      labelType: _labelType,
      labelSize: _labelSize,
      labelText: _labelTextController.text,
      location: _locationController.text,
      notes: _notesController.text,
      priority: _priority,
      printerProfileId: printerProfileId,
    );
  }

  QrLabelDraft _draftFromAssetRow(
    Map<String, String> row, {
    required String printerProfileId,
  }) {
    final assetId = (row['asset_id'] ?? '').trim();
    final name = (row['name'] ?? '').trim();
    final location = (row['location'] ?? '').trim();
    final notes = (row['notes'] ?? '').trim();

    return QrLabelDraft(
      assetId: assetId,
      labelType: _labelType,
      labelSize: _labelSize,
      labelText: name.isEmpty ? assetId : name,
      location: location,
      notes: notes,
      priority: _priority,
      printerProfileId: printerProfileId,
    );
  }

  String _friendlyErrorMessage(Object error) {
    if (error is StateError) {
      return error.message;
    }
    return error.toString();
  }

  String _selectedPrinterProfile(List<Map<String, String>> profiles) {
    if (_printerProfileId.trim().isNotEmpty) {
      return _printerProfileId.trim();
    }
    for (final row in profiles) {
      final id = (row['profile_id'] ?? '').trim();
      final printerName = (row['printer_name'] ?? '').trim().toLowerCase();
      if (id.toLowerCase() == QrLabelPrintService.pm260Preset.profileId ||
          printerName.contains('pm260')) {
        return id;
      }
    }
    if (profiles.isNotEmpty) {
      final first = (profiles.first['profile_id'] ?? '').trim();
      if (first.isNotEmpty) {
        return first;
      }
    }
    return 'manual';
  }

  String _selectedPrinterProfileId() {
    return _printerProfileId.trim();
  }

  Printer? _selectedPrinter(List<Printer> printers, String selectedUrl) {
    if (printers.isEmpty) {
      return null;
    }

    final normalizedUrl = selectedUrl.trim();
    if (normalizedUrl.isNotEmpty) {
      for (final printer in printers) {
        if (printer.url == normalizedUrl) {
          return printer;
        }
      }
    }

    for (final printer in printers) {
      if (printer.isDefault) {
        return printer;
      }
    }

    return printers.first;
  }

  List<Map<String, String>> _filteredAssets(
    List<Map<String, String>> rows,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return rows.take(8).toList(growable: false);
    }

    return rows
        .where((row) {
          final haystack = [
            row['asset_id'],
            row['name'],
            row['type'],
            row['project'],
            row['location'],
          ].join(' ').toLowerCase();
          return haystack.contains(trimmed);
        })
        .take(8)
        .toList(growable: false);
  }

  List<Map<String, String>> _queueRowsByStatus(
    List<Map<String, String>> rows,
    Set<String> statuses,
  ) {
    return rows
        .where((row) {
          final status = (row['status'] ?? '').trim().toLowerCase();
          return statuses.contains(status);
        })
        .toList(growable: false);
  }

  String _latestTemplateLabel(List<Map<String, String>> rows) {
    if (rows.isEmpty) {
      return 'No saved template';
    }

    final templates =
        rows.map(QrBulkTemplate.fromCsvRow).toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latestName = templates.first.templateName.trim();
    return latestName.isEmpty ? 'No saved template' : latestName;
  }
}

class _StudioHero extends StatelessWidget {
  const _StudioHero({
    required this.onBackToAssets,
    required this.onBackToRegister,
    required this.onOpenHistory,
    required this.onOpenPrintQueue,
    required this.onOpenScanLookup,
    required this.onOpenInventorySession,
    required this.readyCount,
    required this.retryCount,
    required this.printedCount,
    required this.appliedCount,
    required this.hasPm260Preset,
    required this.latestTemplateLabel,
    required this.onRefresh,
    required this.workspacePath,
  });

  final VoidCallback onBackToAssets;
  final VoidCallback onBackToRegister;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenPrintQueue;
  final VoidCallback onOpenScanLookup;
  final VoidCallback onOpenInventorySession;
  final int readyCount;
  final int retryCount;
  final int printedCount;
  final int appliedCount;
  final bool hasPm260Preset;
  final String latestTemplateLabel;
  final VoidCallback onRefresh;
  final String? workspacePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(context, highlighted: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QR Label Studio',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate QR PNGs, save print-ready PDFs, queue labels, and hand them to the Windows print dialog for the PM260 or any other installed thermal driver.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                workspacePath ?? 'Asset folder not linked',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusPill(
                    label: 'Ready: $readyCount',
                    accent: AppColours.darkSuccess,
                  ),
                  _StatusPill(
                    label: 'Retry: $retryCount',
                    accent: const Color(0xFFE26B6B),
                  ),
                  _StatusPill(
                    label: 'Printed: $printedCount',
                    accent: AppColours.darkAmber,
                  ),
                  _StatusPill(
                    label: 'Applied: $appliedCount',
                    accent: AppColours.darkSecondary,
                  ),
                  _StatusPill(
                    label: hasPm260Preset ? 'PM260 ready' : 'PM260 missing',
                    accent: hasPm260Preset
                        ? AppColours.darkSuccess
                        : AppColours.darkAmber,
                  ),
                  _StatusPill(
                    label: 'Template: $latestTemplateLabel',
                    accent: latestTemplateLabel == 'No saved template'
                        ? AppColours.darkMutedText
                        : AppColours.darkSecondary,
                  ),
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              FilledButton.tonalIcon(
                onPressed: onBackToAssets,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Assets'),
              ),
              OutlinedButton.icon(
                onPressed: onBackToRegister,
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text('Back to QR Labels'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenPrintQueue,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Print Queue'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenHistory,
                icon: const Icon(Icons.history_outlined),
                label: const Text('History'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenScanLookup,
                icon: const Icon(Icons.search),
                label: const Text('Scan Lookup'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenInventorySession,
                icon: const Icon(Icons.checklist_rtl_outlined),
                label: const Text('Inventory Session'),
              ),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              SizedBox(
                width: 360,
                child: Align(alignment: Alignment.topRight, child: actions),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BuildCard extends StatelessWidget {
  const _BuildCard({
    required this.searchController,
    required this.assetIdController,
    required this.labelTextController,
    required this.locationController,
    required this.notesController,
    required this.selectedAsset,
    required this.filteredAssets,
    required this.labelType,
    required this.labelSize,
    required this.selectedPrinterProfile,
    required this.printerProfiles,
    required this.priority,
    required this.onAssetSelected,
    required this.onSearchChanged,
    required this.onLabelTypeChanged,
    required this.onLabelSizeChanged,
    required this.onPrinterProfileChanged,
    required this.onPriorityChanged,
    required this.onGeneratePreview,
    required this.onAddToQueue,
    required this.onBulkGenerate,
    required this.onLoadLatestTemplate,
    required this.onCopyLatestTemplate,
    required this.onSaveBulkTemplate,
    required this.onLoadBulkTemplate,
    required this.onPrint,
    required this.onOpenFolder,
    required this.canUseWorkspace,
    required this.isBusy,
    required this.statusMessage,
  });

  final TextEditingController searchController;
  final TextEditingController assetIdController;
  final TextEditingController labelTextController;
  final TextEditingController locationController;
  final TextEditingController notesController;
  final Map<String, String>? selectedAsset;
  final List<Map<String, String>> filteredAssets;
  final String labelType;
  final String labelSize;
  final String selectedPrinterProfile;
  final List<Map<String, String>> printerProfiles;
  final String priority;
  final ValueChanged<Map<String, String>> onAssetSelected;
  final VoidCallback onSearchChanged;
  final ValueChanged<String> onLabelTypeChanged;
  final ValueChanged<String> onLabelSizeChanged;
  final ValueChanged<String> onPrinterProfileChanged;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback? onGeneratePreview;
  final VoidCallback? onAddToQueue;
  final VoidCallback? onBulkGenerate;
  final VoidCallback? onLoadLatestTemplate;
  final VoidCallback? onCopyLatestTemplate;
  final VoidCallback? onSaveBulkTemplate;
  final VoidCallback? onLoadBulkTemplate;
  final VoidCallback? onPrint;
  final VoidCallback? onOpenFolder;
  final bool canUseWorkspace;
  final bool isBusy;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Label builder',
            icon: Icons.qr_code_2_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Search an asset, adjust the label text, choose a size, and generate a print-ready label for the PM260 workflow.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            onChanged: (_) => onSearchChanged(),
            decoration: const InputDecoration(
              labelText: 'Search equipment',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          if (filteredAssets.isEmpty)
            Text(
              'No equipment matches that search yet.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filteredAssets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final row = filteredAssets[index];
                  final assetId = (row['asset_id'] ?? '').trim();
                  final name = (row['name'] ?? '').trim();
                  final location = (row['location'] ?? '').trim();
                  final isSelected =
                      selectedAsset?['asset_id']?.trim() == assetId;
                  return InkWell(
                    onTap: () => onAssetSelected(row),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColours.darkSecondary.withValues(alpha: 0.12)
                            : AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColours.darkSecondary.withValues(alpha: 0.55)
                              : AppColours.darkOutline,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? assetId : name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: AppColours.darkText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  assetId,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColours.darkSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                if (location.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    location,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColours.darkMutedText,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColours.darkMutedText,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: assetIdController,
                  decoration: const InputDecoration(labelText: 'Asset ID'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: labelType,
                  decoration: const InputDecoration(labelText: 'Label type'),
                  items: QrLabelPrintService.labelTypes
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.id,
                          child: Text(option.title),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      onLabelTypeChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: labelSize,
                  decoration: const InputDecoration(labelText: 'Label size'),
                  items: QrLabelPrintService.labelSizes
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.id,
                          child: Text(option.title),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      onLabelSizeChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: selectedPrinterProfile.isEmpty
                      ? null
                      : selectedPrinterProfile,
                  decoration: const InputDecoration(
                    labelText: 'Printer profile',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'manual',
                      child: Text(
                        'Manual / Windows dialog',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...printerProfiles.map(
                      (row) => DropdownMenuItem<String>(
                        value: (row['profile_id'] ?? '').trim(),
                        child: Text(
                          (row['printer_name'] ?? '').trim().isEmpty
                              ? (row['profile_id'] ?? '').trim()
                              : (row['printer_name'] ?? '').trim(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onPrinterProfileChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: labelTextController,
                  decoration: const InputDecoration(labelText: 'Label text'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onPriorityChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(labelText: 'Location / project'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notesController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isBusy || !canUseWorkspace
                    ? null
                    : onGeneratePreview,
                icon: isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_outlined),
                label: const Text('Generate preview'),
              ),
              FilledButton.tonalIcon(
                onPressed: isBusy || !canUseWorkspace ? null : onAddToQueue,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Add to queue'),
              ),
              FilledButton.tonalIcon(
                onPressed: isBusy || !canUseWorkspace || onBulkGenerate == null
                    ? null
                    : onBulkGenerate,
                icon: const Icon(Icons.playlist_add),
                label: const Text('Bulk generate'),
              ),
              OutlinedButton.icon(
                onPressed:
                    isBusy || !canUseWorkspace || onLoadLatestTemplate == null
                    ? null
                    : onLoadLatestTemplate,
                icon: const Icon(Icons.history_toggle_off_outlined),
                label: const Text('Load latest'),
              ),
              OutlinedButton.icon(
                onPressed:
                    isBusy || !canUseWorkspace || onCopyLatestTemplate == null
                    ? null
                    : onCopyLatestTemplate,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy latest'),
              ),
              OutlinedButton.icon(
                onPressed:
                    isBusy || !canUseWorkspace || onSaveBulkTemplate == null
                    ? null
                    : onSaveBulkTemplate,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save template'),
              ),
              OutlinedButton.icon(
                onPressed:
                    isBusy || !canUseWorkspace || onLoadBulkTemplate == null
                    ? null
                    : onLoadBulkTemplate,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Load template'),
              ),
              OutlinedButton.icon(
                onPressed: isBusy || !canUseWorkspace ? null : onPrint,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print dialog'),
              ),
              if (onOpenFolder != null)
                OutlinedButton.icon(
                  onPressed: onOpenFolder,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Open PDF folder'),
                ),
            ],
          ),
          if (statusMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              statusMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.preview,
    required this.currentDraft,
    required this.selectedPrinterProfile,
    required this.printerProfileCount,
  });

  final QrLabelPreview? preview;
  final QrLabelDraft currentDraft;
  final String selectedPrinterProfile;
  final int printerProfileCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Label preview',
            icon: Icons.preview_outlined,
          ),
          const SizedBox(height: 12),
          if (preview == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate a preview to see the QR code, title, asset ID, and saved print-ready files.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColours.darkMutedText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Printer profile: ${selectedPrinterProfile.isEmpty ? 'Manual / Windows dialog' : selectedPrinterProfile}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Printer profiles available: $printerProfileCount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkMutedText,
                  ),
                ),
              ],
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 640;
                final image = Container(
                  width: 220,
                  height: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.file(preview!.pngFile, fit: BoxFit.contain),
                );

                final details = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDraft.labelTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColours.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preview!.assetId,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColours.darkSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentDraft.labelText.isEmpty
                          ? preview!.assetId
                          : currentDraft.labelText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColours.darkMutedText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Size: ${currentDraft.labelSize}   Queue ID: ${preview!.labelId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Printer profile: ${selectedPrinterProfile.isEmpty ? 'Manual / Windows dialog' : selectedPrinterProfile}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Printer profiles available: $printerProfileCount',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF: ${path.basename(preview!.pdfFile.path)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColours.darkMutedText,
                      ),
                    ),
                  ],
                );

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [image, const SizedBox(height: 16), details],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image,
                    const SizedBox(width: 20),
                    Expanded(child: details),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PrinterConnectionCard extends StatelessWidget {
  const _PrinterConnectionCard({
    required this.printers,
    required this.printingInfo,
    required this.selectedPrinter,
    required this.selectedPrinterProfile,
    required this.hasPm260Preset,
    required this.onPrinterChanged,
    required this.onPrintSelected,
  });

  final List<Printer> printers;
  final PrintingInfo? printingInfo;
  final Printer? selectedPrinter;
  final String selectedPrinterProfile;
  final bool hasPm260Preset;
  final ValueChanged<Printer?> onPrinterChanged;
  final VoidCallback? onPrintSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: _pm260DirectMatch() ? 'Connected printer' : 'Printer setup',
            icon: Icons.usb_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            _printerStatusMessage(),
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
              Chip(
                label: Text(_printerStatusChip()),
                backgroundColor:
                    _printerStatusChipColor(context).withValues(alpha: 0.15),
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (printers.isNotEmpty)
                Chip(
                  label: Text('${printers.length} detected'),
                  backgroundColor:
                      AppColours.darkSurfaceAlt.withValues(alpha: 0.9),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              Chip(
                label: Text(_pm260ProfileChipLabel()),
                backgroundColor:
                    _pm260ProfileColour().withValues(alpha: 0.15),
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Chip(
                label: Text(_pm260DeviceChipLabel()),
                backgroundColor:
                    _pm260DeviceColour().withValues(alpha: 0.15),
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!_pm260DirectMatch()) ...[
            const SizedBox(height: 10),
            Text(
              _pm260MatchMessage(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ],
          if (printers.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              printingInfo?.canListPrinters == true
                  ? 'If the USB printer was just plugged in, give Windows a moment to finish installing the driver, then reopen this screen.'
                  : 'The print dialog remains available until Windows can list printers on this machine.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.35,
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected printer',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _PrinterStateBadge(
                  label: _pm260DirectMatch() ? 'Matched' : 'Setup needed',
                  accent: _pm260DirectMatch()
                      ? AppColours.darkSuccess
                      : AppColours.darkAmber,
                  gentle: !_pm260DirectMatch(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _pm260DirectMatch()
                    ? AppColours.darkSuccess.withValues(alpha: 0.08)
                    : AppColours.darkAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _pm260DirectMatch()
                      ? AppColours.darkSuccess.withValues(alpha: 0.6)
                      : AppColours.darkAmber.withValues(alpha: 0.45),
                ),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedPrinter?.url,
                decoration: const InputDecoration(labelText: 'Selected printer'),
                items: printers
                    .map(
                      (printer) => DropdownMenuItem<String>(
                        value: printer.url,
                        child: Text(
                          printer.isDefault
                              ? '${printer.name} (Default)'
                              : printer.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  Printer? match;
                  for (final printer in printers) {
                    if (printer.url == value) {
                      match = printer;
                      break;
                    }
                  }
                  onPrinterChanged(match);
                },
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final printer in printers.take(3))
                  Chip(
                    label: Text(
                      printer.isDefault
                          ? '${printer.name} - default'
                          : printer.name,
                    ),
                    backgroundColor:
                        (printer.isDefault
                                ? AppColours.darkSuccess
                                : AppColours.darkSecondary)
                            .withValues(alpha: 0.15),
                    labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColours.darkText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            if (selectedPrinter != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _pm260DirectMatch()
                      ? AppColours.darkSuccess.withValues(alpha: 0.10)
                      : AppColours.darkAmber.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _pm260DirectMatch()
                        ? AppColours.darkSuccess.withValues(alpha: 0.45)
                        : AppColours.darkAmber.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  _selectedPrinterDetails(selectedPrinter!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _pm260DirectMatch()
                        ? AppColours.darkText
                        : AppColours.darkText,
                    height: 1.35,
                    fontWeight:
                        _pm260DirectMatch() ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onPrintSelected,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print to printer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _printerStatusMessage() {
    if (printingInfo?.canListPrinters != true) {
      return 'Printer access is not ready yet.';
    }
    if (printers.isEmpty) {
      return 'Windows can see the printer list, but no ready printer is showing yet.';
    }
    final printer = selectedPrinter;
    if (printer == null) {
      return 'Pick the USB printer here for direct print.';
    }
    return _pm260DirectMatch()
        ? 'PM260 is ready for direct print.'
        : 'Windows can see ${printers.length} printer(s). ${printer.name} is selected.';
  }

  String _printerStatusChip() {
    if (printingInfo?.canListPrinters != true) {
      return 'Printer setup paused';
    }
    if (printers.isEmpty) {
      return 'Setup in progress';
    }
    return 'Windows sees printers';
  }

  Color _printerStatusChipColor(BuildContext context) {
    if (printingInfo?.canListPrinters != true) {
      return AppColours.darkAmber;
    }
    if (printers.isEmpty) {
      return AppColours.darkAmber;
    }
    return AppColours.darkSuccess;
  }

  String _selectedPrinterDetails(Printer printer) {
    if (printer.location?.trim().isNotEmpty == true) {
      return 'Location: ${printer.location!.trim()}';
    }
    if (printer.comment?.trim().isNotEmpty == true) {
      return 'Windows note: ${printer.comment!.trim()}';
    }
    return 'Selected printer is ready to receive labels from Windows.';
  }

  bool _pm260ProfileSelected() {
    return selectedPrinterProfile.trim().toLowerCase().contains('pm260');
  }

  bool _pm260DetectedOnWindows() {
    for (final printer in printers) {
      final name = printer.name.trim().toLowerCase();
      final location = printer.location?.trim().toLowerCase() ?? '';
      final comment = printer.comment?.trim().toLowerCase() ?? '';
      if (name.contains('pm260') ||
          location.contains('pm260') ||
          comment.contains('pm260')) {
        return true;
      }
    }
    return false;
  }

  bool _pm260DirectMatch() {
    return _pm260ProfileSelected() && _pm260DetectedOnWindows();
  }

  String _pm260ProfileChipLabel() {
    if (!_pm260ProfileSelected()) {
      return hasPm260Preset ? 'PM260 profile ready' : 'PM260 profile missing';
    }
    return 'PM260 profile selected';
  }

  Color _pm260ProfileColour() {
    if (_pm260ProfileSelected() || hasPm260Preset) {
      return AppColours.darkSuccess;
    }
    return AppColours.darkAmber;
  }

  String _pm260DeviceChipLabel() {
    return _pm260DetectedOnWindows()
        ? 'PM260 printer detected'
        : 'PM260 printer not detected';
  }

  Color _pm260DeviceColour() {
    return _pm260DetectedOnWindows()
        ? AppColours.darkSuccess
        : AppColours.darkAmber;
  }

  String _pm260MatchMessage() {
    if (_pm260DirectMatch()) {
      return 'The PM260 profile and the Windows printer both match, so direct print should be ready.';
    }
    final profileSelected = _pm260ProfileSelected();
    final deviceDetected = _pm260DetectedOnWindows();
    if (profileSelected && !deviceDetected) {
      return 'Setup reminder: PM260 is selected in the label builder, but Windows is not seeing the PM260 printer yet.';
    }
    if (!profileSelected && deviceDetected) {
      return 'Setup reminder: Windows can see a PM260 printer, but the label builder is using a different printer profile for now.';
    }
    return 'Setup reminder: the PM260 profile is parked for now, and Windows is not currently detecting a PM260 printer.';
  }
}

class _PrinterProfilesCard extends StatelessWidget {
  const _PrinterProfilesCard({
    required this.profiles,
    required this.onAddProfile,
    required this.onAddPm260Preset,
  });

  final List<Map<String, String>> profiles;
  final VoidCallback onAddProfile;
  final VoidCallback onAddPm260Preset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionTitle(
                title: 'Printer profiles',
                icon: Icons.print_outlined,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onAddProfile,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onAddPm260Preset,
                icon: const Icon(Icons.print_outlined),
                label: const Text('PM260 preset'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profiles.isEmpty
                ? 'No printer profiles are saved yet. Add the PM260 preset or another thermal profile to keep printing smooth.'
                : 'Printer profiles stay local so the PM260 preset and any other thermal drivers are easy to reuse.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: '${profiles.length} profile${profiles.length == 1 ? '' : 's'}',
                accent: AppColours.darkSecondary,
              ),
              _StatusPill(
                label: profiles.any((row) {
                  final name = (row['printer_name'] ?? '').trim().toLowerCase();
                  final id = (row['profile_id'] ?? '').trim().toLowerCase();
                  return name.contains('pm260') ||
                      id == QrLabelPrintService.pm260Preset.profileId
                          .toLowerCase();
                })
                    ? 'PM260 preset ready'
                    : 'PM260 preset missing',
                accent: profiles.any((row) {
                  final name = (row['printer_name'] ?? '').trim().toLowerCase();
                  final id = (row['profile_id'] ?? '').trim().toLowerCase();
                  return name.contains('pm260') ||
                      id == QrLabelPrintService.pm260Preset.profileId
                          .toLowerCase();
                })
                    ? AppColours.darkSuccess
                    : AppColours.darkAmber,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (profiles.isEmpty)
            Text(
              'No printer profiles yet. Add one for the PM260 or your chosen thermal printer.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColours.darkMutedText,
                height: 1.4,
              ),
            )
          else
            Column(
              children: [
                for (final row in profiles.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColours.darkSurfaceAlt.withValues(
                          alpha: 0.94,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColours.darkOutline),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (row['printer_name'] ?? '').trim().isEmpty
                                      ? (row['profile_id'] ?? '').trim()
                                      : (row['printer_name'] ?? '').trim(),
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: AppColours.darkText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${row['connection_type'] ?? ''}  •  ${row['label_width_mm'] ?? ''} x ${row['label_height_mm'] ?? ''} mm  •  ${row['dpi'] ?? ''} dpi',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColours.darkMutedText,
                                      ),
                                ),
                              ],
                            ),
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

class _LabelRegisterCard extends StatelessWidget {
  const _LabelRegisterCard({
    required this.labels,
    required this.onEditLabel,
    required this.onDeleteLabel,
  });

  final List<Map<String, String>> labels;
  final Future<void> Function(Map<String, String> row) onEditLabel;
  final Future<void> Function(Map<String, String> row) onDeleteLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Label register',
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            'Generated label records are kept locally so printing and later applying stay easy to track.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${labels.length} labels recorded',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (labels.isEmpty)
            Text(
              'No generated labels yet.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Column(
              children: [
                for (final row in labels.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MiniRecordCard(
                      row: row,
                      title: row['asset_id'] ?? 'Unknown asset',
                      subtitle:
                          '${row['label_type'] ?? ''} • ${row['print_status'] ?? ''}',
                      detail: path.basename(row['generated_file'] ?? ''),
                      onEdit: () => onEditLabel(row),
                      onDelete: () => onDeleteLabel(row),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _QueueBoardCard extends StatelessWidget {
  const _QueueBoardCard({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.accent,
    required this.onMarkPrinted,
    required this.onMarkApplied,
    required this.onMarkReprintNeeded,
  });

  final String title;
  final String subtitle;
  final List<Map<String, String>> rows;
  final Color accent;
  final Future<void> Function(String queueId) onMarkPrinted;
  final Future<void> Function(String queueId) onMarkApplied;
  final Future<void> Function(String queueId) onMarkReprintNeeded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionTitle(title: title, icon: Icons.local_printshop_outlined),
              const Spacer(),
              _InlineCount(label: 'Count', count: rows.length, accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkMutedText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text(
              'Nothing here right now.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
            )
          else
            Column(
              children: [
                for (final row in rows.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _QueueRowCard(
                      row: row,
                      onMarkPrinted: () => onMarkPrinted(row['queue_id'] ?? ''),
                      onMarkApplied: () => onMarkApplied(row['queue_id'] ?? ''),
                      onMarkReprintNeeded: () =>
                          onMarkReprintNeeded(row['queue_id'] ?? ''),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _QueueRowCard extends StatelessWidget {
  const _QueueRowCard({
    required this.row,
    required this.onMarkPrinted,
    required this.onMarkApplied,
    required this.onMarkReprintNeeded,
  });

  final Map<String, String> row;
  final VoidCallback onMarkPrinted;
  final VoidCallback onMarkApplied;
  final VoidCallback onMarkReprintNeeded;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? '').trim();
    final accent = _statusAccent(status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row['asset_id'] ?? 'Unknown asset',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _InlineCount(count: 1, accent: accent, label: status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${row['label_type'] ?? ''} • ${row['label_size'] ?? ''} • ${path.basename(row['generated_file'] ?? '')}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: onMarkPrinted,
                child: const Text('Mark printed'),
              ),
              TextButton(
                onPressed: onMarkApplied,
                child: const Text('Mark applied'),
              ),
              TextButton(
                onPressed: onMarkReprintNeeded,
                child: const Text('Reprint'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniRecordCard extends StatelessWidget {
  const _MiniRecordCard({
    required this.row,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, String> row;
  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColours.darkMutedText),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Tooltip(
                message: row['label_id'] ?? 'Label entry',
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              Tooltip(
                message: row['label_id'] ?? 'Label entry',
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditLabelRegisterDialog extends StatefulWidget {
  const _EditLabelRegisterDialog({required this.row});

  final Map<String, String> row;

  @override
  State<_EditLabelRegisterDialog> createState() =>
      _EditLabelRegisterDialogState();
}

class _EditLabelRegisterDialogState extends State<_EditLabelRegisterDialog> {
  late final TextEditingController _assetIdController;
  late final TextEditingController _labelTypeController;
  late final TextEditingController _labelSizeController;
  late final TextEditingController _labelTextController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late final TextEditingController _printStatusController;
  late final TextEditingController _printedDateController;
  late final TextEditingController _appliedDateController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _assetIdController = TextEditingController(
      text: widget.row['asset_id'] ?? '',
    );
    _labelTypeController = TextEditingController(
      text: widget.row['label_type'] ?? '',
    );
    _labelSizeController = TextEditingController(
      text: widget.row['label_size'] ?? '',
    );
    _labelTextController = TextEditingController(
      text: widget.row['label_text'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.row['location'] ?? '',
    );
    _notesController = TextEditingController(text: widget.row['notes'] ?? '');
    _printStatusController = TextEditingController(
      text: widget.row['print_status'] ?? '',
    );
    _printedDateController = TextEditingController(
      text: widget.row['printed_date'] ?? '',
    );
    _appliedDateController = TextEditingController(
      text: widget.row['applied_date'] ?? '',
    );
  }

  @override
  void dispose() {
    _assetIdController.dispose();
    _labelTypeController.dispose();
    _labelSizeController.dispose();
    _labelTextController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _printStatusController.dispose();
    _printedDateController.dispose();
    _appliedDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit label entry'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _assetIdController,
                decoration: const InputDecoration(labelText: 'Asset ID'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _labelTypeController,
                      decoration: const InputDecoration(labelText: 'Label type'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _labelSizeController,
                      decoration: const InputDecoration(labelText: 'Label size'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelTextController,
                decoration: const InputDecoration(labelText: 'Label text'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location / project'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _printStatusController,
                      decoration: const InputDecoration(labelText: 'Print status'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _printedDateController,
                      decoration: const InputDecoration(labelText: 'Printed date'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _appliedDateController,
                decoration: const InputDecoration(labelText: 'Applied date'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.tonalIcon(
          onPressed: _saving
              ? null
              : () {
                  final labelId = (widget.row['label_id'] ?? '').trim();
                  if (labelId.isEmpty) {
                    Navigator.of(context).pop();
                    return;
                  }
                  setState(() {
                    _saving = true;
                  });
                  Navigator.of(context).pop(
                    QrLabelRegisterEntry(
                      labelId: labelId,
                      assetId: _assetIdController.text,
                      labelType: _labelTypeController.text,
                      labelSize: _labelSizeController.text,
                      qrPayload: widget.row['qr_payload'] ?? '',
                      labelText: _labelTextController.text,
                      generatedFile: widget.row['generated_file'] ?? '',
                      manifestFile: widget.row['manifest_file'] ?? '',
                      printStatus: _printStatusController.text,
                      printedDate: _printedDateController.text,
                      appliedDate: _appliedDateController.text,
                      location: _locationController.text,
                      notes: _notesController.text,
                    ),
                  );
                },
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save changes'),
        ),
      ],
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

class _PrinterStateBadge extends StatelessWidget {
  const _PrinterStateBadge({
    required this.label,
    required this.accent,
    this.gentle = false,
  });

  final String label;
  final Color accent;
  final bool gentle;

  @override
  Widget build(BuildContext context) {
    final backgroundOpacity = gentle ? 0.08 : 0.12;
    final borderOpacity = gentle ? 0.18 : 0.28;
    final textColor = gentle ? accent.withValues(alpha: 0.9) : accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: backgroundOpacity),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: borderOpacity)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InlineCount extends StatelessWidget {
  const _InlineCount({
    required this.count,
    required this.accent,
    required this.label,
  });

  final int count;
  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Text(
        '$label: $count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
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

class _AddPrinterProfileDialog extends StatefulWidget {
  const _AddPrinterProfileDialog();

  @override
  State<_AddPrinterProfileDialog> createState() =>
      _AddPrinterProfileDialogState();
}

class _AddPrinterProfileDialogState extends State<_AddPrinterProfileDialog> {
  late final TextEditingController _profileIdController;
  late final TextEditingController _printerNameController;
  late final TextEditingController _connectionTypeController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _dpiController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _profileIdController = TextEditingController();
    _printerNameController = TextEditingController();
    _connectionTypeController = TextEditingController(text: 'Windows driver');
    _widthController = TextEditingController(text: '50');
    _heightController = TextEditingController(text: '30');
    _dpiController = TextEditingController(text: '203');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _profileIdController.dispose();
    _printerNameController.dispose();
    _connectionTypeController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _dpiController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add printer profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _profileIdController,
              decoration: const InputDecoration(labelText: 'Profile ID'),
            ),
            TextField(
              controller: _printerNameController,
              decoration: const InputDecoration(labelText: 'Printer name'),
            ),
            TextField(
              controller: _connectionTypeController,
              decoration: const InputDecoration(labelText: 'Connection type'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    decoration: const InputDecoration(labelText: 'Width mm'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height mm'),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _dpiController,
              decoration: const InputDecoration(labelText: 'DPI'),
            ),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes'),
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
              QrPrinterProfile(
                profileId: _profileIdController.text.trim(),
                printerName: _printerNameController.text.trim(),
                connectionType: _connectionTypeController.text.trim(),
                labelWidthMm: _widthController.text.trim(),
                labelHeightMm: _heightController.text.trim(),
                dpi: _dpiController.text.trim(),
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

class _StudioError extends StatelessWidget {
  const _StudioError({
    required this.message,
    required this.onBack,
    required this.onReload,
  });

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
                message,
                style: Theme.of(context).textTheme.titleMedium,
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

Color _statusAccent(String status) {
  switch (status.toLowerCase()) {
    case 'printed':
      return AppColours.darkAmber;
    case 'applied':
      return AppColours.darkSuccess;
    case 'reprint_needed':
      return const Color(0xFFE26B6B);
    case 'queued':
    case 'generated':
    default:
      return AppColours.darkSecondary;
  }
}
