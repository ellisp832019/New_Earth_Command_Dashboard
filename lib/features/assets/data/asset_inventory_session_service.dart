import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'asset_csv_service.dart';

class AssetInventorySessionService {
  AssetInventorySessionService({
    AssetCsvService? csvService,
    Directory? workingDirectory,
  }) : _csvService = csvService ?? AssetCsvService(),
       _workingDirectory = workingDirectory ?? Directory.current;

  static const sessionLogHeaders = <String>[
    'session_id',
    'session_name',
    'created_at',
    'equipment_items',
    'parts_items',
    'labeled_equipment_items',
    'unlabeled_equipment_items',
    'low_stock_parts',
    'csv_file',
    'pdf_file',
    'notes',
  ];

  static const sessionChecklistHeaders = <String>[
    'item_kind',
    'record_id',
    'name',
    'project',
    'location',
    'current_status',
    'expected_quantity',
    'count_actual',
    'counted_by',
    'counted_at',
    'qr_label_code',
    'notes',
  ];

  final AssetCsvService _csvService;
  final Directory _workingDirectory;

  Future<AssetInventorySessionPack> buildInventoryPack(
    String assetsRootPath, {
    required String sessionName,
    required String countedBy,
    required List<Map<String, String>> equipmentRows,
    required List<Map<String, String>> partsRows,
    required Map<String, Map<String, String>> qrLabelsByAssetId,
    required int lowStockPartsCount,
    String notes = '',
  }) async {
    final normalizedSessionName = sessionName.trim().isEmpty
        ? 'Inventory Week Pack'
        : sessionName.trim();
    final sessionId = _buildSessionId(normalizedSessionName);
    final exportFolder = _inventorySessionsFolder(assetsRootPath);
    await exportFolder.create(recursive: true);

    final equipmentItems = _buildEquipmentItems(
      equipmentRows,
      qrLabelsByAssetId,
      countedBy: countedBy,
    );
    final partItems = _buildPartItems(partsRows, countedBy: countedBy);
    final rows = <AssetInventorySessionRow>[...equipmentItems, ...partItems];

    final csvFile = File(
      path.join(exportFolder.path, '${_safeFileName(sessionId)}_checklist.csv'),
    );
    final pdfFile = File(
      path.join(exportFolder.path, '${_safeFileName(sessionId)}_checklist.pdf'),
    );

    await _csvService.writeTable(
      csvFile,
      AssetCsvTable(
        headers: sessionChecklistHeaders,
        rows: rows.map((row) => row.toCsvRow()).toList(growable: false),
      ),
    );
    await pdfFile.writeAsBytes(
      await _buildPdfBytes(
        sessionName: normalizedSessionName,
        sessionId: sessionId,
        notes: notes,
        rows: rows,
        equipmentCount: equipmentItems.length,
        partsCount: partItems.length,
        lowStockPartsCount: lowStockPartsCount,
        csvFile: csvFile.path,
      ),
      flush: true,
    );

    await _appendSessionLog(
      assetsRootPath,
      AssetInventorySessionLogEntry(
        sessionId: sessionId,
        sessionName: normalizedSessionName,
        createdAt: DateTime.now(),
        equipmentItems: equipmentItems.length,
        partsItems: partItems.length,
        labeledEquipmentItems: equipmentItems
            .where((row) => row.qrLabelCode.trim().isNotEmpty)
            .length,
        unlabeledEquipmentItems: equipmentItems
            .where((row) => row.qrLabelCode.trim().isEmpty)
            .length,
        lowStockParts: lowStockPartsCount,
        csvFile: csvFile.path,
        pdfFile: pdfFile.path,
        notes: notes,
      ),
    );

    return AssetInventorySessionPack(
      sessionId: sessionId,
      sessionName: normalizedSessionName,
      createdAt: DateTime.now(),
      csvFile: csvFile,
      pdfFile: pdfFile,
      checklistRows: rows,
      equipmentCount: equipmentItems.length,
      partsCount: partItems.length,
      labeledEquipmentCount: equipmentItems
          .where((row) => row.qrLabelCode.trim().isNotEmpty)
          .length,
      unlabeledEquipmentCount: equipmentItems
          .where((row) => row.qrLabelCode.trim().isEmpty)
          .length,
      lowStockPartsCount: lowStockPartsCount,
    );
  }

  Future<AssetCsvTable> readSessionLog(String assetsRootPath) {
    return _csvService.readTable(
      _sessionLogFile(assetsRootPath),
      expectedHeaders: sessionLogHeaders,
    );
  }

  Future<File> exportRowsCsv(
    String assetsRootPath, {
    required String fileStem,
    required List<AssetInventorySessionRow> rows,
  }) async {
    final exportFolder = _inventorySessionsFolder(assetsRootPath);
    await exportFolder.create(recursive: true);
    final file = File(
      path.join(exportFolder.path, '${_safeFileName(fileStem)}.csv'),
    );

    await _csvService.writeTable(
      file,
      AssetCsvTable(
        headers: sessionChecklistHeaders,
        rows: rows.map((row) => row.toCsvRow()).toList(growable: false),
      ),
    );

    return file;
  }

  Directory _inventorySessionsFolder(String assetsRootPath) {
    return Directory(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        '04_INVENTORY_SESSIONS',
      ),
    );
  }

  File _sessionLogFile(String assetsRootPath) {
    return File(
      path.join(
        _inventorySessionsFolder(assetsRootPath).path,
        'inventory_sessions.csv',
      ),
    );
  }

  String _normalizedRootPath(String assetsRootPath) {
    final trimmed = assetsRootPath.trim();
    return trimmed.isNotEmpty ? trimmed : _workingDirectory.path;
  }

  List<AssetInventorySessionRow> _buildEquipmentItems(
    List<Map<String, String>> equipmentRows,
    Map<String, Map<String, String>> qrLabelsByAssetId, {
    required String countedBy,
  }) {
    return equipmentRows
        .map((row) {
          final assetId = _clean(row['asset_id']);
          final qrRow = qrLabelsByAssetId[assetId];
          return AssetInventorySessionRow(
            itemKind: 'equipment',
            recordId: assetId,
            name: _clean(row['name']),
            project: _clean(row['project']),
            location: _clean(row['location']),
            currentStatus: _clean(row['status']),
            expectedQuantity: 1,
            countActual: '',
            countedBy: countedBy.trim(),
            countedAt: '',
            qrLabelCode: _clean(qrRow?['label_code']),
            notes: _clean(row['notes']),
          );
        })
        .toList(growable: false);
  }

  List<AssetInventorySessionRow> _buildPartItems(
    List<Map<String, String>> partsRows, {
    required String countedBy,
  }) {
    return partsRows
        .map((row) {
          return AssetInventorySessionRow(
            itemKind: 'part',
            recordId: _clean(row['part_id']),
            name: _clean(row['name']),
            project: _clean(row['project']),
            location: _clean(row['location']),
            currentStatus: _clean(row['status']),
            expectedQuantity: _intValue(row['quantity']) ?? 0,
            countActual: '',
            countedBy: countedBy.trim(),
            countedAt: '',
            qrLabelCode: '',
            notes: _clean(row['notes']),
          );
        })
        .toList(growable: false);
  }

  Future<Uint8List> _buildPdfBytes({
    required String sessionName,
    required String sessionId,
    required String notes,
    required List<AssetInventorySessionRow> rows,
    required int equipmentCount,
    required int partsCount,
    required int lowStockPartsCount,
    required String csvFile,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text(
              sessionName,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Session ID: $sessionId'),
            pw.Text('Prepared for inventory count and QR check this week.'),
            if (notes.trim().isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text('Notes: ${notes.trim()}'),
            ],
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _pdfBadge('Equipment', '$equipmentCount'),
                _pdfBadge('Parts', '$partsCount'),
                _pdfBadge('Low stock parts', '$lowStockPartsCount'),
                _pdfBadge(
                  'Labelled equipment',
                  '${rows.where((row) => row.itemKind == 'equipment' && row.qrLabelCode.isNotEmpty).length}',
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'CSV checklist: $csvFile',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.SizedBox(height: 14),
            pw.TableHelper.fromTextArray(
              headers: const [
                'Kind',
                'Record',
                'Name',
                'Project',
                'Location',
                'Expected',
                'Count',
                'By',
                'At',
                'QR',
              ],
              data: rows
                  .map(
                    (row) => [
                      row.itemKind,
                      row.recordId,
                      row.name,
                      row.project,
                      row.location,
                      row.expectedQuantity.toString(),
                      row.countActual,
                      row.countedBy,
                      row.countedAt,
                      row.qrLabelCode,
                    ],
                  )
                  .toList(growable: false),
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerStyle: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
              columnWidths: const {
                0: pw.FixedColumnWidth(46),
                1: pw.FixedColumnWidth(74),
                2: pw.FlexColumnWidth(1.4),
                3: pw.FlexColumnWidth(1.0),
                4: pw.FlexColumnWidth(1.0),
                5: pw.FixedColumnWidth(44),
                6: pw.FixedColumnWidth(44),
                7: pw.FixedColumnWidth(44),
                8: pw.FixedColumnWidth(56),
                9: pw.FixedColumnWidth(64),
              },
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfBadge(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text('$label: $value'),
    );
  }

  Future<void> _appendSessionLog(
    String assetsRootPath,
    AssetInventorySessionLogEntry entry,
  ) async {
    await _csvService.appendRow(
      _sessionLogFile(assetsRootPath),
      entry.toCsvRow(),
      expectedHeaders: sessionLogHeaders,
    );
  }

  String _clean(String? value) => (value ?? '').trim();

  int? _intValue(String? value) {
    final cleaned = _clean(value);
    if (cleaned.isEmpty) {
      return null;
    }
    return int.tryParse(cleaned);
  }

  String _buildSessionId(String sessionName) {
    return '${_safeFileName(sessionName)}_${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}';
  }

  String _safeFileName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return cleaned.isEmpty ? 'inventory_session' : cleaned;
  }
}

class AssetInventorySessionRow {
  const AssetInventorySessionRow({
    required this.itemKind,
    required this.recordId,
    required this.name,
    required this.project,
    required this.location,
    required this.currentStatus,
    required this.expectedQuantity,
    required this.countActual,
    required this.countedBy,
    required this.countedAt,
    required this.qrLabelCode,
    required this.notes,
  });

  final String itemKind;
  final String recordId;
  final String name;
  final String project;
  final String location;
  final String currentStatus;
  final int expectedQuantity;
  final String countActual;
  final String countedBy;
  final String countedAt;
  final String qrLabelCode;
  final String notes;

  Map<String, String> toCsvRow() {
    return {
      'item_kind': itemKind,
      'record_id': recordId,
      'name': name,
      'project': project,
      'location': location,
      'current_status': currentStatus,
      'expected_quantity': expectedQuantity.toString(),
      'count_actual': countActual,
      'counted_by': countedBy,
      'counted_at': countedAt,
      'qr_label_code': qrLabelCode,
      'notes': notes,
    };
  }
}

class AssetInventorySessionPack {
  const AssetInventorySessionPack({
    required this.sessionId,
    required this.sessionName,
    required this.createdAt,
    required this.csvFile,
    required this.pdfFile,
    required this.checklistRows,
    required this.equipmentCount,
    required this.partsCount,
    required this.labeledEquipmentCount,
    required this.unlabeledEquipmentCount,
    required this.lowStockPartsCount,
  });

  final String sessionId;
  final String sessionName;
  final DateTime createdAt;
  final File csvFile;
  final File pdfFile;
  final List<AssetInventorySessionRow> checklistRows;
  final int equipmentCount;
  final int partsCount;
  final int labeledEquipmentCount;
  final int unlabeledEquipmentCount;
  final int lowStockPartsCount;
}

class AssetInventorySessionLogEntry {
  const AssetInventorySessionLogEntry({
    required this.sessionId,
    required this.sessionName,
    required this.createdAt,
    required this.equipmentItems,
    required this.partsItems,
    required this.labeledEquipmentItems,
    required this.unlabeledEquipmentItems,
    required this.lowStockParts,
    required this.csvFile,
    required this.pdfFile,
    required this.notes,
  });

  final String sessionId;
  final String sessionName;
  final DateTime createdAt;
  final int equipmentItems;
  final int partsItems;
  final int labeledEquipmentItems;
  final int unlabeledEquipmentItems;
  final int lowStockParts;
  final String csvFile;
  final String pdfFile;
  final String notes;

  Map<String, String> toCsvRow() {
    return {
      'session_id': sessionId,
      'session_name': sessionName,
      'created_at': createdAt.toIso8601String(),
      'equipment_items': equipmentItems.toString(),
      'parts_items': partsItems.toString(),
      'labeled_equipment_items': labeledEquipmentItems.toString(),
      'unlabeled_equipment_items': unlabeledEquipmentItems.toString(),
      'low_stock_parts': lowStockParts.toString(),
      'csv_file': csvFile,
      'pdf_file': pdfFile,
      'notes': notes,
    };
  }
}
