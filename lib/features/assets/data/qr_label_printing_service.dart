import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'asset_csv_service.dart';

class QrLabelPrintService {
  QrLabelPrintService({
    AssetCsvService? csvService,
    Directory? workingDirectory,
  }) : _csvService = csvService ?? AssetCsvService(),
       _workingDirectory = workingDirectory ?? Directory.current;

  static const labelTypes = <QrLabelTypeOption>[
    QrLabelTypeOption(
      id: 'asset',
      title: 'Asset label',
      subtitle: 'For equipment and tracked assets.',
    ),
    QrLabelTypeOption(
      id: 'parts',
      title: 'Parts label',
      subtitle: 'For component bins and stock items.',
    ),
    QrLabelTypeOption(
      id: 'bin',
      title: 'Bin label',
      subtitle: 'For drawers, shelves and storage boxes.',
    ),
    QrLabelTypeOption(
      id: 'cable',
      title: 'Cable label',
      subtitle: 'For cables, adapters and cords.',
    ),
    QrLabelTypeOption(
      id: 'maintenance',
      title: 'Maintenance tag',
      subtitle: 'For repair and do-not-use tags.',
    ),
    QrLabelTypeOption(
      id: 'reorder',
      title: 'Reorder label',
      subtitle: 'For stock-level reminder labels.',
    ),
  ];

  static const labelSizes = <QrLabelSizeOption>[
    QrLabelSizeOption(
      id: '20x10',
      title: '20 x 10 mm',
      widthMm: 20,
      heightMm: 10,
      subtitle: 'Tiny parts and cable tags.',
    ),
    QrLabelSizeOption(
      id: '30x20',
      title: '30 x 20 mm',
      widthMm: 30,
      heightMm: 20,
      subtitle: 'ESP32 boards and sensors.',
    ),
    QrLabelSizeOption(
      id: '40x30',
      title: '40 x 30 mm',
      widthMm: 40,
      heightMm: 30,
      subtitle: 'Tools and small boxes.',
    ),
    QrLabelSizeOption(
      id: '50x30',
      title: '50 x 30 mm',
      widthMm: 50,
      heightMm: 30,
      subtitle: 'Equipment labels and PM260 rolls.',
    ),
    QrLabelSizeOption(
      id: '50x50',
      title: '50 x 50 mm',
      widthMm: 50,
      heightMm: 50,
      subtitle: 'Bins and shelves.',
    ),
    QrLabelSizeOption(
      id: '60x40',
      title: '60 x 40 mm',
      widthMm: 60,
      heightMm: 40,
      subtitle: 'Maintenance and reorder labels.',
    ),
  ];

  static const queueHeaders = <String>[
    'queue_id',
    'date_added',
    'asset_id',
    'label_type',
    'label_size',
    'priority',
    'status',
    'generated_file',
    'manifest_file',
    'printer_profile',
    'notes',
  ];

  static const printerProfileHeaders = <String>[
    'profile_id',
    'printer_name',
    'connection_type',
    'label_width_mm',
    'label_height_mm',
    'dpi',
    'notes',
  ];

  static const bulkTemplateHeaders = <String>[
    'template_id',
    'template_name',
    'search_query',
    'label_type',
    'label_size',
    'printer_profile_id',
    'priority',
    'notes',
    'created_at',
  ];

  static const labelRegisterHeaders = <String>[
    'label_id',
    'asset_id',
    'label_type',
    'label_size',
    'qr_payload',
    'label_text',
    'generated_file',
    'manifest_file',
    'print_status',
    'printed_date',
    'applied_date',
    'location',
    'notes',
  ];

  final AssetCsvService _csvService;
  final Directory _workingDirectory;

  static const QrPrinterProfile pm260Preset = QrPrinterProfile(
    profileId: 'pm260_etikez',
    printerName: 'ETIKEZ PM260',
    connectionType: 'Windows driver / Labelnize-compatible Bluetooth',
    labelWidthMm: '50',
    labelHeightMm: '30',
    dpi: '203',
    notes: 'Preset for the PM260 thermal label maker.',
  );

  static const QrPrinterProfile genericSmallPreset = QrPrinterProfile(
    profileId: 'thermal_50x30_generic',
    printerName: 'Generic 50 x 30 Thermal',
    connectionType: 'Windows driver',
    labelWidthMm: '50',
    labelHeightMm: '30',
    dpi: '203',
    notes: 'Safe preset for common 50 x 30 mm thermal rolls.',
  );

  static const QrPrinterProfile genericMediumPreset = QrPrinterProfile(
    profileId: 'thermal_60x40_generic',
    printerName: 'Generic 60 x 40 Thermal',
    connectionType: 'Windows driver',
    labelWidthMm: '60',
    labelHeightMm: '40',
    dpi: '203',
    notes: 'Safe preset for common 60 x 40 mm thermal rolls.',
  );

  static const List<QrPrinterProfile> recommendedPrinterPresets = [
    pm260Preset,
    genericSmallPreset,
    genericMediumPreset,
  ];

  Future<QrLabelPreview> generateLabelArtifacts(
    String assetsRootPath,
    QrLabelDraft draft,
  ) async {
    final normalizedDraft = draft.normalized();
    final labelId = _buildLabelId(
      normalizedDraft.assetId,
      normalizedDraft.labelType,
    );
    final generatedFolder = await _generatedQrFolder(
      assetsRootPath,
    ).create(recursive: true);
    final printQueueFolder = _printQueueFolder(assetsRootPath);
    await printQueueFolder.create(recursive: true);
    final pngFile = await _uniqueFile(
      generatedFolder,
      '${_safeFileName(normalizedDraft.assetId)}_qr.png',
    );
    final pdfFile = File(path.join(printQueueFolder.path, '$labelId.pdf'));

    await _writeQrPng(pngFile, normalizedDraft.assetId);
    await pdfFile.writeAsBytes(await buildLabelPdfBytes(normalizedDraft));
    final manifestFile = await _writeLabelManifest(
      assetsRootPath,
      QrLabelRegisterEntry(
        labelId: labelId,
        assetId: normalizedDraft.assetId,
        labelType: normalizedDraft.labelType,
        labelSize: normalizedDraft.labelSize,
        qrPayload: normalizedDraft.assetId,
        labelText: normalizedDraft.labelText,
        generatedFile: pdfFile.path,
        manifestFile: '',
        printStatus: 'generated',
        printedDate: '',
        appliedDate: '',
        location: normalizedDraft.location,
        notes: normalizedDraft.notes,
      ),
      generatedPngPath: pngFile.path,
      generatedPdfPath: pdfFile.path,
    );
    await _appendOrReplaceLabelRegister(
      assetsRootPath,
      QrLabelRegisterEntry(
        labelId: labelId,
        assetId: normalizedDraft.assetId,
        labelType: normalizedDraft.labelType,
        labelSize: normalizedDraft.labelSize,
        qrPayload: normalizedDraft.assetId,
        labelText: normalizedDraft.labelText,
        generatedFile: pdfFile.path,
        manifestFile: manifestFile.path,
        printStatus: 'generated',
        printedDate: '',
        appliedDate: '',
        location: normalizedDraft.location,
        notes: normalizedDraft.notes,
      ),
    );

    return QrLabelPreview(
      labelId: labelId,
      assetId: normalizedDraft.assetId,
      labelType: normalizedDraft.labelType,
      labelSize: normalizedDraft.labelSize,
      labelText: normalizedDraft.labelText,
      qrPayload: normalizedDraft.assetId,
      pngFile: pngFile,
      pdfFile: pdfFile,
      manifestFile: manifestFile,
      generatedAt: DateTime.now(),
    );
  }

  Future<QrQueueEntry> addToQueue(
    String assetsRootPath,
    QrLabelDraft draft, {
    String? generatedFilePath,
  }) async {
    final normalizedDraft = draft.normalized();
    final preview = generatedFilePath == null
        ? await generateLabelArtifacts(assetsRootPath, normalizedDraft)
        : null;
    final generatedFile = generatedFilePath ?? preview!.pdfFile.path;
    final manifestFile = preview != null
        ? preview.manifestFile.path
        : _manifestFileForGeneratedFile(assetsRootPath, generatedFile).path;
    final queueEntry = QrQueueEntry(
      queueId: _buildQueueId(
        normalizedDraft.assetId,
        normalizedDraft.labelType,
      ),
      dateAdded: DateTime.now(),
      assetId: normalizedDraft.assetId,
      labelType: normalizedDraft.labelType,
      labelSize: normalizedDraft.labelSize,
      priority: normalizedDraft.priority,
      status: 'queued',
      generatedFile: generatedFile,
      manifestFile: manifestFile,
      printerProfile: normalizedDraft.printerProfileId,
      notes: normalizedDraft.notes,
    );

    await _csvService.appendRow(
      _printQueueFile(assetsRootPath),
      queueEntry.toCsvRow(),
      expectedHeaders: queueHeaders,
    );

    return queueEntry;
  }

  Future<void> printLabel(QrLabelDraft draft) async {
    final normalizedDraft = draft.normalized();
    final pdfBytes = await buildLabelPdfBytes(normalizedDraft);
    await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  }

  Future<bool> printLabelToPrinter(QrLabelDraft draft, Printer printer) async {
    final normalizedDraft = draft.normalized();
    final pdfBytes = await buildLabelPdfBytes(normalizedDraft);
    return Printing.directPrintPdf(
      printer: printer,
      onLayout: (_) async => pdfBytes,
      name: normalizedDraft.assetId,
      usePrinterSettings: true,
    );
  }

  Future<AssetCsvTable> readLabelRegister(String assetsRootPath) {
    return _csvService.readTable(
      _labelRegisterFile(assetsRootPath),
      expectedHeaders: labelRegisterHeaders,
    );
  }

  Future<AssetCsvTable> readPrintQueue(String assetsRootPath) {
    return _csvService.readTable(
      _printQueueFile(assetsRootPath),
      expectedHeaders: queueHeaders,
    );
  }

  Future<AssetCsvTable> readPrinterProfiles(String assetsRootPath) {
    return _csvService.readTable(
      _printerProfilesFile(assetsRootPath),
      expectedHeaders: printerProfileHeaders,
    );
  }

  Future<AssetCsvTable> readBulkTemplates(String assetsRootPath) {
    return _csvService.readTable(
      _bulkTemplatesFile(assetsRootPath),
      expectedHeaders: bulkTemplateHeaders,
    );
  }

  Future<QrPrinterProfile> appendPrinterProfile(
    String assetsRootPath,
    QrPrinterProfile profile,
  ) async {
    await _csvService.appendRow(
      _printerProfilesFile(assetsRootPath),
      profile.toCsvRow(),
      expectedHeaders: printerProfileHeaders,
    );
    return profile;
  }

  Future<QrBulkTemplate> upsertBulkTemplate(
    String assetsRootPath,
    QrBulkTemplate template,
  ) async {
    final normalized = template.normalized();
    final file = _bulkTemplatesFile(assetsRootPath);
    final table = await _csvService.readTable(
      file,
      expectedHeaders: bulkTemplateHeaders,
    );
    final rows = <Map<String, String>>[];
    var replaced = false;

    for (final row in table.rows) {
      final currentId = (row['template_id'] ?? '').trim();
      if (currentId.isNotEmpty && currentId == normalized.templateId) {
        rows.add(normalized.toCsvRow());
        replaced = true;
      } else {
        rows.add(row);
      }
    }

    if (!replaced) {
      rows.add(normalized.toCsvRow());
    }

    await _csvService.writeTable(
      file,
      AssetCsvTable(headers: bulkTemplateHeaders, rows: rows),
    );
    return normalized;
  }

  Future<QrPrinterProfile> ensurePm260Preset(String assetsRootPath) async {
    final table = await readPrinterProfiles(assetsRootPath);
    final existing = table.rows.any((row) {
      final id = (row['profile_id'] ?? '').trim().toLowerCase();
      final printerName = (row['printer_name'] ?? '').trim().toLowerCase();
      return id == pm260Preset.profileId.toLowerCase() ||
          printerName.contains('pm260');
    });

    if (existing) {
      return pm260Preset;
    }

    return appendPrinterProfile(assetsRootPath, pm260Preset);
  }

  Future<List<QrPrinterProfile>> ensureRecommendedPrinterPresets(
    String assetsRootPath,
  ) async {
    final table = await readPrinterProfiles(assetsRootPath);
    final existingIds = table.rows
        .map((row) => (row['profile_id'] ?? '').trim().toLowerCase())
        .toSet();
    final existingNames = table.rows
        .map((row) => (row['printer_name'] ?? '').trim().toLowerCase())
        .toSet();
    final added = <QrPrinterProfile>[];

    for (final preset in recommendedPrinterPresets) {
      final id = preset.profileId.trim().toLowerCase();
      final printerName = preset.printerName.trim().toLowerCase();
      final exists =
          existingIds.contains(id) || existingNames.contains(printerName);
      if (exists) {
        continue;
      }

      await appendPrinterProfile(assetsRootPath, preset);
      added.add(preset);
    }

    return added;
  }

  Future<void> markQueuePrinted(String assetsRootPath, String queueId) async {
    await _updateQueueRow(
      assetsRootPath,
      queueId,
      (row) => {...row, 'status': 'printed'},
    );
  }

  Future<void> markQueueApplied(String assetsRootPath, String queueId) async {
    await _updateQueueRow(
      assetsRootPath,
      queueId,
      (row) => {...row, 'status': 'applied'},
    );
  }

  Future<void> markQueueReprintNeeded(
    String assetsRootPath,
    String queueId,
  ) async {
    await _updateQueueRow(
      assetsRootPath,
      queueId,
      (row) => {...row, 'status': 'reprint_needed'},
    );
  }

  Future<void> markQueueQueued(String assetsRootPath, String queueId) async {
    await _updateQueueRow(
      assetsRootPath,
      queueId,
      (row) => {...row, 'status': 'queued'},
    );
  }

  Future<File> exportReadyQueueCsv(String assetsRootPath) async {
    final table = await readPrintQueue(assetsRootPath);
    final readyRows = table.rows
        .where((row) {
          final status = (row['status'] ?? '').trim().toLowerCase();
          return status == 'generated' || status == 'queued';
        })
        .toList(growable: false);

    final exportFolder = await _historyExportsFolder(
      assetsRootPath,
    ).create(recursive: true);
    final file = File(
      path.join(
        exportFolder.path,
        'qr_ready_queue_${_timestampSlug(DateTime.now())}.csv',
      ),
    );
    final lines = <String>[
      queueHeaders.join(','),
      ...readyRows.map(
        (row) =>
            queueHeaders.map((header) => _csvCell(row[header] ?? '')).join(','),
      ),
    ];
    await file.writeAsString('${lines.join('\n')}\n', flush: true);
    return file;
  }

  Future<void> markLabelPrinted(String assetsRootPath, String labelId) async {
    await _updateLabelRow(
      assetsRootPath,
      labelId,
      (row) => {
        ...row,
        'print_status': 'printed',
        'printed_date': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> markLabelApplied(String assetsRootPath, String labelId) async {
    await _updateLabelRow(
      assetsRootPath,
      labelId,
      (row) => {
        ...row,
        'print_status': 'applied',
        'applied_date': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<File> exportRecentLabelHistory(
    String assetsRootPath, {
    int limit = 12,
  }) async {
    final rows = await _recentLabelHistoryRows(assetsRootPath, limit: limit);
    final exportFolder = await _historyExportsFolder(
      assetsRootPath,
    ).create(recursive: true);
    final file = File(
      path.join(
        exportFolder.path,
        'qr_label_history_recent_${_timestampSlug(DateTime.now())}.csv',
      ),
    );
    final headers = <String>[
      'label_id',
      'asset_id',
      'label_type',
      'label_size',
      'print_status',
      'printed_date',
      'applied_date',
      'generated_file',
      'location',
      'notes',
    ];
    final lines = <String>[headers.join(',')];
    for (final row in rows) {
      lines.add(headers.map((header) => _csvCell(row[header] ?? '')).join(','));
    }
    await file.writeAsString('${lines.join('\n')}\n', flush: true);
    return file;
  }

  Future<File> exportRecentLabelHistoryPdf(
    String assetsRootPath, {
    int limit = 12,
  }) async {
    final rows = await _recentLabelHistoryRows(assetsRootPath, limit: limit);
    final exportFolder = await _historyExportsFolder(
      assetsRootPath,
    ).create(recursive: true);
    final file = File(
      path.join(
        exportFolder.path,
        'qr_label_history_recent_${_timestampSlug(DateTime.now())}.pdf',
      ),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text(
              'QR Label History',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Recent local label records exported from the New Earth dashboard.',
            ),
            pw.SizedBox(height: 16),
            ...rows.map(
              (row) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      row['label_id']?.trim().isNotEmpty == true
                          ? row['label_id']!.trim()
                          : 'Label record',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Asset: ${row['asset_id'] ?? ''}  |  Type: ${row['label_type'] ?? ''}  |  Size: ${row['label_size'] ?? ''}',
                    ),
                    pw.Text(
                      'Printed: ${row['printed_date'] ?? 'Not recorded'}  |  Applied: ${row['applied_date'] ?? 'Not recorded'}',
                    ),
                    if ((row['generated_file'] ?? '').trim().isNotEmpty)
                      pw.Text('File: ${row['generated_file']}'),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  Future<Uint8List> buildReadyQueuePdfBytes(String assetsRootPath) async {
    final queueTable = await readPrintQueue(assetsRootPath);
    final readyRows = queueTable.rows
        .where((row) {
          final status = (row['status'] ?? '').trim().toLowerCase();
          return status == 'generated' || status == 'queued';
        })
        .toList(growable: false);
    if (readyRows.isEmpty) {
      return buildLabelPdfBytes(
        const QrLabelDraft(
          assetId: 'No ready labels',
          labelType: 'asset',
          labelSize: '50x30',
          labelText: 'No ready labels',
          location: '',
          notes: '',
          priority: 'normal',
          printerProfileId: '',
        ),
      );
    }

    final labelTable = await readLabelRegister(assetsRootPath);
    final labelRowsById = <String, Map<String, String>>{};
    for (final row in labelTable.rows) {
      final id = (row['label_id'] ?? '').trim();
      if (id.isNotEmpty) {
        labelRowsById[id] = row;
      }
    }

    final pdf = pw.Document();
    for (final queueRow in readyRows) {
      final queueId = (queueRow['queue_id'] ?? '').trim();
      final labelId = queueId.startsWith('queue_')
          ? queueId.substring('queue_'.length)
          : queueId;
      final labelRow = labelRowsById[labelId];
      final assetId = (labelRow?['asset_id'] ?? queueRow['asset_id'] ?? '')
          .trim();
      final labelText = (labelRow?['label_text'] ?? assetId).trim();
      final labelType = (queueRow['label_type'] ?? 'asset').trim();
      final labelSizeId = (queueRow['label_size'] ?? '50x30').trim();
      final location = (labelRow?['location'] ?? '').trim();
      final notes = (labelRow?['notes'] ?? queueRow['notes'] ?? '').trim();
      final size = sizeById(labelSizeId);
      final draft = QrLabelDraft(
        assetId: assetId.isEmpty ? 'Unknown asset' : assetId,
        labelType: labelType,
        labelSize: size.id,
        labelText: labelText.isEmpty
            ? (assetId.isEmpty ? 'Unknown asset' : assetId)
            : labelText,
        location: location,
        notes: notes,
        priority: (queueRow['priority'] ?? 'normal').trim(),
        printerProfileId: (queueRow['printer_profile'] ?? '').trim(),
      );

      final normalizedDraft = draft.normalized();
      final pageFormat = PdfPageFormat(
        size.widthMm * PdfPageFormat.mm,
        size.heightMm * PdfPageFormat.mm,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Container(
              width: pageFormat.width,
              height: pageFormat.height,
              padding: const pw.EdgeInsets.all(4),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    normalizedDraft.labelText.isNotEmpty
                        ? normalizedDraft.labelText
                        : normalizedDraft.assetId,
                    style: pw.TextStyle(
                      fontSize: size.widthMm <= 30 ? 7 : 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    maxLines: 2,
                  ),
                  pw.Text(
                    normalizedDraft.labelTitle,
                    style: pw.TextStyle(fontSize: size.widthMm <= 30 ? 5 : 7),
                    maxLines: 1,
                  ),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: normalizedDraft.assetId,
                        width: pageFormat.width * 0.72,
                        height: pageFormat.width * 0.72,
                        drawText: false,
                      ),
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Text(
                        normalizedDraft.assetId,
                        style: pw.TextStyle(
                          fontSize: size.widthMm <= 30 ? 7 : 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      if (normalizedDraft.location.isNotEmpty)
                        pw.Text(
                          normalizedDraft.location,
                          style: pw.TextStyle(
                            fontSize: size.widthMm <= 30 ? 5 : 7,
                          ),
                          maxLines: 2,
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  Future<Uint8List> buildLabelPdfBytes(QrLabelDraft draft) async {
    final normalizedDraft = draft.normalized();
    final size = normalizedDraft.size;
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat(
      size.widthMm * PdfPageFormat.mm,
      size.heightMm * PdfPageFormat.mm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Container(
            width: pageFormat.width,
            height: pageFormat.height,
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  normalizedDraft.labelText.isNotEmpty
                      ? normalizedDraft.labelText
                      : normalizedDraft.assetId,
                  style: pw.TextStyle(
                    fontSize: size.widthMm <= 30 ? 7 : 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
                pw.Text(
                  normalizedDraft.labelTitle,
                  style: pw.TextStyle(fontSize: size.widthMm <= 30 ? 5 : 7),
                  maxLines: 1,
                ),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: normalizedDraft.assetId,
                      width: pageFormat.width * 0.72,
                      height: pageFormat.width * 0.72,
                      drawText: false,
                    ),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Text(
                      normalizedDraft.assetId,
                      style: pw.TextStyle(
                        fontSize: size.widthMm <= 30 ? 7 : 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                    if (normalizedDraft.location.isNotEmpty)
                      pw.Text(
                        normalizedDraft.location,
                        style: pw.TextStyle(
                          fontSize: size.widthMm <= 30 ? 5 : 7,
                        ),
                        maxLines: 2,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  QrLabelSizeOption sizeById(String id) {
    return labelSizes.firstWhere(
      (size) => size.id == id,
      orElse: () => labelSizes.first,
    );
  }

  QrLabelTypeOption typeById(String id) {
    return labelTypes.firstWhere(
      (type) => type.id == id,
      orElse: () => labelTypes.first,
    );
  }

  Directory _generatedQrFolder(String assetsRootPath) {
    return Directory(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '01_GENERATED_QR_PNGS',
      ),
    );
  }

  Directory _printQueueFolder(String assetsRootPath) {
    return Directory(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '03_PRINT_QUEUE',
      ),
    );
  }

  Directory _labelTemplatesFolder(String assetsRootPath) {
    return Directory(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '02_LABEL_TEMPLATES',
      ),
    );
  }

  Directory _printerProfilesFolder(String assetsRootPath) {
    return Directory(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '10_PRINTER_SETUP_AND_PROFILES',
      ),
    );
  }

  Directory _bulkTemplatesFolder(String assetsRootPath) {
    return Directory(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '02_LABEL_TEMPLATES',
      ),
    );
  }

  Directory _historyExportsFolder(String assetsRootPath) {
    return Directory(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '03_PRINT_QUEUE',
        'history_exports',
      ),
    );
  }

  Directory _labelManifestsFolder(String assetsRootPath) {
    return Directory(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '03_PRINT_QUEUE',
        'label_manifests',
      ),
    );
  }

  File _manifestFileForGeneratedFile(
    String assetsRootPath,
    String generatedFilePath,
  ) {
    return _labelManifestFile(
      assetsRootPath,
      path.basenameWithoutExtension(generatedFilePath),
    );
  }

  File _labelRegisterFile(String assetsRootPath) {
    return File(
      path.join(
        _labelTemplatesFolder(assetsRootPath).path,
        'qr_label_register.csv',
      ),
    );
  }

  File _printQueueFile(String assetsRootPath) {
    return File(
      path.join(_printQueueFolder(assetsRootPath).path, 'print_queue.csv'),
    );
  }

  File _printerProfilesFile(String assetsRootPath) {
    return File(
      path.join(
        _printerProfilesFolder(assetsRootPath).path,
        'printer_profiles.csv',
      ),
    );
  }

  File _bulkTemplatesFile(String assetsRootPath) {
    return File(
      path.join(
        _bulkTemplatesFolder(assetsRootPath).path,
        'bulk_templates.csv',
      ),
    );
  }

  File _labelManifestFile(String assetsRootPath, String labelId) {
    return File(
      path.join(
        _labelManifestsFolder(assetsRootPath).path,
        '${_safeFileName(labelId)}.json',
      ),
    );
  }

  String _normalizedRootPath(String assetsRootPath) {
    final trimmed = assetsRootPath.trim();
    return trimmed.isNotEmpty ? trimmed : _workingDirectory.path;
  }

  String _safeFileName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return cleaned.isEmpty ? 'label' : cleaned;
  }

  String _timestampSlug(DateTime value) {
    return value
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .replaceAll('T', '_');
  }

  String _buildLabelId(String assetId, String labelType) {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return '${_safeFileName(assetId)}_${_safeFileName(labelType)}_$timestamp';
  }

  String _buildQueueId(String assetId, String labelType) {
    return 'queue_${_buildLabelId(assetId, labelType)}';
  }

  Future<void> _writeQrPng(File file, String assetId) async {
    final painter = QrPainter(
      data: assetId,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: ui.Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: ui.Color(0xFF000000),
      ),
    );
    final byteData = await painter.toImageData(
      512,
      format: ui.ImageByteFormat.png,
    );
    final bytes = byteData?.buffer.asUint8List();
    if (bytes == null) {
      throw StateError('QR generation returned no image data.');
    }

    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<File> _writeLabelManifest(
    String assetsRootPath,
    QrLabelRegisterEntry entry, {
    required String generatedPngPath,
    required String generatedPdfPath,
  }) async {
    final file = _labelManifestFile(assetsRootPath, entry.labelId);
    await file.parent.create(recursive: true);
    final manifest = {
      'label_id': entry.labelId,
      'asset_id': entry.assetId,
      'label_type': entry.labelType,
      'label_size': entry.labelSize,
      'qr_payload': entry.qrPayload,
      'label_text': entry.labelText,
      'generated_png': generatedPngPath,
      'generated_pdf': generatedPdfPath,
      'print_status': entry.printStatus,
      'printed_date': entry.printedDate,
      'applied_date': entry.appliedDate,
      'location': entry.location,
      'notes': entry.notes,
      'created_at': DateTime.now().toIso8601String(),
    };
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(manifest),
      flush: true,
    );
    return file;
  }

  Future<File> _uniqueFile(Directory folder, String fileName) async {
    var candidate = File(path.join(folder.path, fileName));
    if (!await candidate.exists()) {
      return candidate;
    }

    final base = path.basenameWithoutExtension(fileName);
    final ext = path.extension(fileName);
    var counter = 2;
    while (true) {
      candidate = File(path.join(folder.path, '${base}_$counter$ext'));
      if (!await candidate.exists()) {
        return candidate;
      }
      counter += 1;
    }
  }

  Future<void> _appendOrReplaceLabelRegister(
    String assetsRootPath,
    QrLabelRegisterEntry entry,
  ) async {
    final file = _labelRegisterFile(assetsRootPath);
    final table = await _csvService.readTable(
      file,
      expectedHeaders: labelRegisterHeaders,
    );
    final rows = <Map<String, String>>[];
    var replaced = false;

    for (final row in table.rows) {
      final currentLabelId = (row['label_id'] ?? '').trim();
      if (currentLabelId.isNotEmpty && currentLabelId == entry.labelId) {
        rows.add(entry.toCsvRow());
        replaced = true;
      } else {
        rows.add(row);
      }
    }

    if (!replaced) {
      rows.add(entry.toCsvRow());
    }

    await _csvService.writeTable(
      file,
      AssetCsvTable(headers: labelRegisterHeaders, rows: rows),
    );
  }

  Future<void> _updateQueueRow(
    String assetsRootPath,
    String queueId,
    Map<String, String> Function(Map<String, String> row) updater,
  ) async {
    final file = _printQueueFile(assetsRootPath);
    final table = await _csvService.readTable(
      file,
      expectedHeaders: queueHeaders,
    );
    final updatedRows = <Map<String, String>>[];
    var replaced = false;

    for (final row in table.rows) {
      final currentQueueId = (row['queue_id'] ?? '').trim();
      if (currentQueueId.isNotEmpty && currentQueueId == queueId) {
        updatedRows.add(updater(row));
        replaced = true;
      } else {
        updatedRows.add(row);
      }
    }

    if (!replaced) {
      throw StateError('Queue item $queueId was not found.');
    }

    await _csvService.writeTable(
      file,
      AssetCsvTable(headers: queueHeaders, rows: updatedRows),
    );
  }

  Future<void> _updateLabelRow(
    String assetsRootPath,
    String labelId,
    Map<String, String> Function(Map<String, String> row) updater,
  ) async {
    final file = _labelRegisterFile(assetsRootPath);
    final table = await _csvService.readTable(
      file,
      expectedHeaders: labelRegisterHeaders,
    );
    final updatedRows = <Map<String, String>>[];
    var replaced = false;

    for (final row in table.rows) {
      final currentLabelId = (row['label_id'] ?? '').trim();
      if (currentLabelId.isNotEmpty && currentLabelId == labelId) {
        updatedRows.add(updater(row));
        replaced = true;
      } else {
        updatedRows.add(row);
      }
    }

    if (!replaced) {
      throw StateError('Label $labelId was not found.');
    }

    await _csvService.writeTable(
      file,
      AssetCsvTable(headers: labelRegisterHeaders, rows: updatedRows),
    );
  }

  Future<List<Map<String, String>>> _recentLabelHistoryRows(
    String assetsRootPath, {
    int limit = 12,
  }) async {
    final table = await readLabelRegister(assetsRootPath);
    final rows = [...table.rows];
    rows.sort((a, b) {
      final aValue = (a['label_id'] ?? '').trim().toLowerCase();
      final bValue = (b['label_id'] ?? '').trim().toLowerCase();
      return bValue.compareTo(aValue);
    });
    return rows.take(limit).toList(growable: false);
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}

class QrLabelDraft {
  const QrLabelDraft({
    required this.assetId,
    required this.labelType,
    required this.labelSize,
    required this.labelText,
    required this.location,
    required this.notes,
    required this.priority,
    required this.printerProfileId,
  });

  final String assetId;
  final String labelType;
  final String labelSize;
  final String labelText;
  final String location;
  final String notes;
  final String priority;
  final String printerProfileId;

  QrLabelDraft normalized() {
    return QrLabelDraft(
      assetId: assetId.trim(),
      labelType: labelType.trim().isEmpty ? 'asset' : labelType.trim(),
      labelSize: labelSize.trim().isEmpty ? '50x30' : labelSize.trim(),
      labelText: labelText.trim().isEmpty ? assetId.trim() : labelText.trim(),
      location: location.trim(),
      notes: notes.trim(),
      priority: priority.trim().isEmpty ? 'normal' : priority.trim(),
      printerProfileId: printerProfileId.trim(),
    );
  }

  QrLabelSizeOption get size {
    final normalizedSize = labelSize.trim();
    final match = QrLabelPrintService.labelSizes.where(
      (size) => size.id == normalizedSize,
    );
    return match.isNotEmpty
        ? match.first
        : QrLabelPrintService.labelSizes.first;
  }

  String get labelTitle {
    final typeOption = QrLabelPrintService.labelTypes
        .where((type) => type.id == labelType.trim())
        .toList(growable: false);
    return typeOption.isNotEmpty ? typeOption.first.title : 'Asset label';
  }
}

class QrLabelPreview {
  const QrLabelPreview({
    required this.labelId,
    required this.assetId,
    required this.labelType,
    required this.labelSize,
    required this.labelText,
    required this.qrPayload,
    required this.pngFile,
    required this.pdfFile,
    required this.manifestFile,
    required this.generatedAt,
  });

  final String labelId;
  final String assetId;
  final String labelType;
  final String labelSize;
  final String labelText;
  final String qrPayload;
  final File pngFile;
  final File pdfFile;
  final File manifestFile;
  final DateTime generatedAt;
}

class QrQueueEntry {
  const QrQueueEntry({
    required this.queueId,
    required this.dateAdded,
    required this.assetId,
    required this.labelType,
    required this.labelSize,
    required this.priority,
    required this.status,
    required this.generatedFile,
    required this.manifestFile,
    required this.printerProfile,
    required this.notes,
  });

  final String queueId;
  final DateTime dateAdded;
  final String assetId;
  final String labelType;
  final String labelSize;
  final String priority;
  final String status;
  final String generatedFile;
  final String manifestFile;
  final String printerProfile;
  final String notes;

  Map<String, String> toCsvRow() {
    return {
      'queue_id': queueId,
      'date_added': dateAdded.toIso8601String(),
      'asset_id': assetId,
      'label_type': labelType,
      'label_size': labelSize,
      'priority': priority,
      'status': status,
      'generated_file': generatedFile,
      'manifest_file': manifestFile,
      'printer_profile': printerProfile,
      'notes': notes,
    };
  }
}

class QrPrinterProfile {
  const QrPrinterProfile({
    required this.profileId,
    required this.printerName,
    required this.connectionType,
    required this.labelWidthMm,
    required this.labelHeightMm,
    required this.dpi,
    required this.notes,
  });

  final String profileId;
  final String printerName;
  final String connectionType;
  final String labelWidthMm;
  final String labelHeightMm;
  final String dpi;
  final String notes;

  Map<String, String> toCsvRow() {
    return {
      'profile_id': profileId,
      'printer_name': printerName,
      'connection_type': connectionType,
      'label_width_mm': labelWidthMm,
      'label_height_mm': labelHeightMm,
      'dpi': dpi,
      'notes': notes,
    };
  }
}

class QrBulkTemplate {
  const QrBulkTemplate({
    required this.templateId,
    required this.templateName,
    required this.searchQuery,
    required this.labelType,
    required this.labelSize,
    required this.printerProfileId,
    required this.priority,
    required this.notes,
    required this.createdAt,
  });

  final String templateId;
  final String templateName;
  final String searchQuery;
  final String labelType;
  final String labelSize;
  final String printerProfileId;
  final String priority;
  final String notes;
  final DateTime createdAt;

  QrBulkTemplate normalized() {
    final name = templateName.trim();
    final slug = templateId.trim().isEmpty
        ? _slugify(name)
        : _slugify(templateId);
    return QrBulkTemplate(
      templateId: slug.isEmpty ? 'template' : slug,
      templateName: name.isEmpty ? 'Bulk template' : name,
      searchQuery: searchQuery.trim(),
      labelType: labelType.trim().isEmpty ? 'asset' : labelType.trim(),
      labelSize: labelSize.trim().isEmpty ? '50x30' : labelSize.trim(),
      printerProfileId: printerProfileId.trim(),
      priority: priority.trim().isEmpty ? 'normal' : priority.trim(),
      notes: notes.trim(),
      createdAt: createdAt,
    );
  }

  Map<String, String> toCsvRow() {
    final normalizedTemplate = normalized();
    return {
      'template_id': normalizedTemplate.templateId,
      'template_name': normalizedTemplate.templateName,
      'search_query': normalizedTemplate.searchQuery,
      'label_type': normalizedTemplate.labelType,
      'label_size': normalizedTemplate.labelSize,
      'printer_profile_id': normalizedTemplate.printerProfileId,
      'priority': normalizedTemplate.priority,
      'notes': normalizedTemplate.notes,
      'created_at': normalizedTemplate.createdAt.toIso8601String(),
    };
  }

  static QrBulkTemplate fromCsvRow(Map<String, String> row) {
    return QrBulkTemplate(
      templateId: (row['template_id'] ?? '').trim(),
      templateName: (row['template_name'] ?? '').trim(),
      searchQuery: (row['search_query'] ?? '').trim(),
      labelType: (row['label_type'] ?? '').trim(),
      labelSize: (row['label_size'] ?? '').trim(),
      printerProfileId: (row['printer_profile_id'] ?? '').trim(),
      priority: (row['priority'] ?? '').trim(),
      notes: (row['notes'] ?? '').trim(),
      createdAt:
          DateTime.tryParse((row['created_at'] ?? '').trim()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class QrLabelRegisterEntry {
  const QrLabelRegisterEntry({
    required this.labelId,
    required this.assetId,
    required this.labelType,
    required this.labelSize,
    required this.qrPayload,
    required this.labelText,
    required this.generatedFile,
    required this.manifestFile,
    required this.printStatus,
    required this.printedDate,
    required this.appliedDate,
    required this.location,
    required this.notes,
  });

  final String labelId;
  final String assetId;
  final String labelType;
  final String labelSize;
  final String qrPayload;
  final String labelText;
  final String generatedFile;
  final String printStatus;
  final String printedDate;
  final String appliedDate;
  final String location;
  final String notes;
  final String manifestFile;

  Map<String, String> toCsvRow() {
    return {
      'label_id': labelId,
      'asset_id': assetId,
      'label_type': labelType,
      'label_size': labelSize,
      'qr_payload': qrPayload,
      'label_text': labelText,
      'generated_file': generatedFile,
      'manifest_file': manifestFile,
      'print_status': printStatus,
      'printed_date': printedDate,
      'applied_date': appliedDate,
      'location': location,
      'notes': notes,
    };
  }
}

class QrLabelTypeOption {
  const QrLabelTypeOption({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class QrLabelSizeOption {
  const QrLabelSizeOption({
    required this.id,
    required this.title,
    required this.widthMm,
    required this.heightMm,
    required this.subtitle,
  });

  final String id;
  final String title;
  final double widthMm;
  final double heightMm;
  final String subtitle;
}

String _slugify(String value) {
  final cleaned = value.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '_',
  );
  return cleaned
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
