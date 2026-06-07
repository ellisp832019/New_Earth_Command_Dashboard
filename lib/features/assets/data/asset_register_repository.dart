import 'dart:io';

import 'package:path/path.dart' as path;

import 'asset_change_journal.dart';
import 'asset_csv_service.dart';

class AssetRegisterRepository {
  AssetRegisterRepository({
    AssetCsvService? csvService,
    Directory? workingDirectory,
  }) : _csvService = csvService ?? AssetCsvService(),
       _workingDirectory = workingDirectory ?? Directory.current;

  static const equipmentHeaders = <String>[
    'asset_id',
    'name',
    'type',
    'project',
    'owner',
    'location',
    'condition',
    'status',
    'purchase_date',
    'purchase_cost',
    'replacement_value',
    'serial_number',
    'receipt_link',
    'warranty_until',
    'notes',
  ];

  static const partsHeaders = <String>[
    'part_id',
    'name',
    'category',
    'project',
    'quantity',
    'min_quantity',
    'location',
    'supplier',
    'last_ordered',
    'last_cost',
    'status',
    'datasheet_link',
    'notes',
  ];

  static const ordersHeaders = <String>[
    'order_id',
    'date',
    'supplier',
    'item',
    'project',
    'quantity',
    'total_cost',
    'status',
    'tracking',
    'receipt_link',
    'finance_record_id',
    'notes',
  ];

  static const supplierHeaders = <String>[
    'supplier_id',
    'name',
    'website',
    'category',
    'reliability',
    'delivery_speed',
    'quality',
    'preferred',
    'notes',
  ];

  static const maintenanceHeaders = <String>[
    'date',
    'asset_id',
    'item',
    'issue',
    'action',
    'status',
    'cost',
    'linked_finance_record',
    'notes',
  ];

  static const locationHeaders = <String>[
    'asset_id',
    'location_name',
    'description',
    'photo_link',
    'notes',
  ];

  static const reorderHeaders = <String>[
    'date',
    'item',
    'project',
    'quantity_needed',
    'estimated_cost',
    'priority',
    'status',
    'supplier',
    'notes',
  ];

  static const valuationHeaders = <String>[
    'asset_id',
    'item',
    'category',
    'purchase_cost',
    'replacement_value',
    'current_estimated_value',
    'valuation_reason',
    'evidence_link',
    'notes',
  ];

  static const qrLabelHeaders = <String>[
    'asset_id',
    'label_code',
    'qr_target',
    'file_or_url',
    'status',
    'printed_date',
    'notes',
  ];

  final AssetCsvService _csvService;
  final Directory _workingDirectory;

  Future<AssetCsvTable> readEquipmentRegister(String assetsRootPath) {
    return _csvService.readTable(
      _equipmentFile(assetsRootPath),
      expectedHeaders: equipmentHeaders,
    );
  }

  Future<AssetCsvTable> readPartsInventory(String assetsRootPath) {
    return _csvService.readTable(
      _partsFile(assetsRootPath),
      expectedHeaders: partsHeaders,
    );
  }

  Future<AssetCsvTable> readOrdersTracker(String assetsRootPath) {
    return _csvService.readTable(
      _ordersFile(assetsRootPath),
      expectedHeaders: ordersHeaders,
    );
  }

  Future<AssetCsvTable> readSupplierRegister(String assetsRootPath) {
    return _csvService.readTable(
      _supplierFile(assetsRootPath),
      expectedHeaders: supplierHeaders,
    );
  }

  Future<AssetCsvTable> readMaintenanceLog(String assetsRootPath) {
    return _csvService.readTable(
      _maintenanceFile(assetsRootPath),
      expectedHeaders: maintenanceHeaders,
    );
  }

  Future<AssetCsvTable> readLocationRegister(String assetsRootPath) {
    return _csvService.readTable(
      _locationFile(assetsRootPath),
      expectedHeaders: locationHeaders,
    );
  }

  Future<AssetCsvTable> readReorderList(String assetsRootPath) {
    return _csvService.readTable(
      _reorderFile(assetsRootPath),
      expectedHeaders: reorderHeaders,
    );
  }

  Future<AssetCsvTable> readValuationSummary(String assetsRootPath) {
    return _csvService.readTable(
      _valuationFile(assetsRootPath),
      expectedHeaders: valuationHeaders,
    );
  }

  Future<AssetCsvTable> readQrLabelRegister(String assetsRootPath) {
    return _csvService.readTable(
      _qrLabelFile(assetsRootPath),
      expectedHeaders: qrLabelHeaders,
    );
  }

  Future<AssetCsvTable> writeEquipmentRegister(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_equipmentFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> writePartsInventory(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_partsFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> writeOrdersTracker(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_ordersFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> writeSupplierRegister(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_supplierFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> writeMaintenanceLog(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_maintenanceFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> writeLocationRegister(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_locationFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> writeReorderList(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_reorderFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> writeValuationSummary(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_valuationFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> writeQrLabelRegister(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService
        .writeTable(_qrLabelFile(assetsRootPath), table)
        .then((_) => table);
  }

  Future<AssetCsvTable> appendEquipmentRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _equipmentFile(assetsRootPath),
      row,
      expectedHeaders: equipmentHeaders,
    );
  }

  Future<AssetCsvTable> updateEquipmentRecord(
    String assetsRootPath,
    Map<String, String> updatedRow,
  ) async {
    final table = await readEquipmentRegister(assetsRootPath);
    return _replaceRowByKey(
      file: _equipmentFile(assetsRootPath),
      headers: equipmentHeaders,
      rows: table.rows,
      keyColumn: 'asset_id',
      keyValue: updatedRow['asset_id'],
      updatedRow: updatedRow,
    );
  }

  Future<AssetCsvTable> deleteEquipmentRecord(
    String assetsRootPath,
    String assetId,
  ) async {
    final table = await readEquipmentRegister(assetsRootPath);
    return _removeRowByKey(
      file: _equipmentFile(assetsRootPath),
      headers: equipmentHeaders,
      rows: table.rows,
      keyColumn: 'asset_id',
      keyValue: assetId,
    );
  }

  Future<AssetCsvTable> appendPartRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _partsFile(assetsRootPath),
      row,
      expectedHeaders: partsHeaders,
    );
  }

  Future<AssetCsvTable> updatePartRecord(
    String assetsRootPath,
    Map<String, String> updatedRow,
  ) async {
    final table = await readPartsInventory(assetsRootPath);
    return _replaceRowByKey(
      file: _partsFile(assetsRootPath),
      headers: partsHeaders,
      rows: table.rows,
      keyColumn: 'part_id',
      keyValue: updatedRow['part_id'],
      updatedRow: updatedRow,
    );
  }

  Future<AssetCsvTable> deletePartRecord(
    String assetsRootPath,
    String partId,
  ) async {
    final table = await readPartsInventory(assetsRootPath);
    return _removeRowByKey(
      file: _partsFile(assetsRootPath),
      headers: partsHeaders,
      rows: table.rows,
      keyColumn: 'part_id',
      keyValue: partId,
    );
  }

  Future<AssetCsvTable> appendOrderRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _ordersFile(assetsRootPath),
      row,
      expectedHeaders: ordersHeaders,
    );
  }

  Future<AssetCsvTable> updateOrderRecord(
    String assetsRootPath,
    Map<String, String> updatedRow,
  ) async {
    final table = await readOrdersTracker(assetsRootPath);
    return _replaceRowByKey(
      file: _ordersFile(assetsRootPath),
      headers: ordersHeaders,
      rows: table.rows,
      keyColumn: 'order_id',
      keyValue: updatedRow['order_id'],
      updatedRow: updatedRow,
    );
  }

  Future<AssetCsvTable> appendSupplierRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _supplierFile(assetsRootPath),
      row,
      expectedHeaders: supplierHeaders,
    );
  }

  Future<AssetCsvTable> updateSupplierRecord(
    String assetsRootPath,
    Map<String, String> updatedRow,
  ) async {
    final table = await readSupplierRegister(assetsRootPath);
    return _replaceRowByKey(
      file: _supplierFile(assetsRootPath),
      headers: supplierHeaders,
      rows: table.rows,
      keyColumn: 'supplier_id',
      keyValue: updatedRow['supplier_id'],
      updatedRow: updatedRow,
    );
  }

  Future<AssetCsvTable> appendMaintenanceRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _maintenanceFile(assetsRootPath),
      row,
      expectedHeaders: maintenanceHeaders,
    );
  }

  Future<AssetCsvTable> appendLocationRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _locationFile(assetsRootPath),
      row,
      expectedHeaders: locationHeaders,
    );
  }

  Future<AssetCsvTable> appendReorderRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _reorderFile(assetsRootPath),
      row,
      expectedHeaders: reorderHeaders,
    );
  }

  Future<AssetCsvTable> appendValuationRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _valuationFile(assetsRootPath),
      row,
      expectedHeaders: valuationHeaders,
    );
  }

  Future<AssetCsvTable> appendQrLabelRecord(
    String assetsRootPath,
    Map<String, String> row,
  ) {
    return _csvService.appendRow(
      _qrLabelFile(assetsRootPath),
      row,
      expectedHeaders: qrLabelHeaders,
    );
  }

  Future<AssetCsvTable> readChangeJournal(String assetsRootPath) {
    return _csvService.readTable(
      _changeJournalFile(assetsRootPath),
      expectedHeaders: AssetChangeJournalEntry.headers,
    );
  }

  Future<AssetCsvTable> appendChangeJournalEntry(
    String assetsRootPath,
    AssetChangeJournalEntry entry,
  ) {
    return _csvService.appendJournalEntry(
      _changeJournalFile(assetsRootPath),
      entry,
    );
  }

  Future<AssetCsvTable> rebuildChangeJournalSnapshot(String assetsRootPath) {
    return readChangeJournal(assetsRootPath).then((table) {
      final entries = table.rows.map(AssetChangeJournalEntry.fromCsvRow);
      return _csvService.writeJournalSnapshot(
        _changeJournalFile(assetsRootPath),
        entries,
      );
    });
  }

  List<Map<String, String>> filterLowStockParts(
    List<Map<String, String>> rows,
  ) {
    return rows
        .where((row) {
          final status = _normalizedStatus(row['status']);
          if (status == 'low_stock' || status == 'reorder_needed') {
            return true;
          }

          final quantity = _parseInt(row['quantity']);
          final minQuantity = _parseInt(row['min_quantity']);
          return quantity != null &&
              minQuantity != null &&
              quantity <= minQuantity;
        })
        .toList(growable: false);
  }

  List<Map<String, String>> filterReorderNeededParts(
    List<Map<String, String>> rows,
  ) {
    return rows
        .where((row) {
          final status = _normalizedStatus(row['status']);
          if (status == 'reorder_needed') {
            return true;
          }

          final quantity = _parseInt(row['quantity']);
          final minQuantity = _parseInt(row['min_quantity']);
          return quantity != null &&
              minQuantity != null &&
              quantity <= minQuantity;
        })
        .toList(growable: false);
  }

  List<Map<String, String>> filterBrokenRepairEquipment(
    List<Map<String, String>> rows,
  ) {
    return rows
        .where((row) {
          final status = _normalizedStatus(row['status']);
          if (status == 'broken' || status == 'repairing') {
            return true;
          }

          final condition = _normalizedStatus(row['condition']);
          return condition == 'broken' || condition == 'repairing';
        })
        .toList(growable: false);
  }

  int estimateReorderSpend(List<Map<String, String>> rows) {
    var total = 0;
    for (final row in filterReorderNeededParts(rows)) {
      final quantity = _parseInt(row['quantity']) ?? 0;
      final minQuantity = _parseInt(row['min_quantity']) ?? 0;
      final difference = minQuantity - quantity;
      final quantityNeeded = difference > 0 ? difference : 1;
      final lastCost = _parseDouble(row['last_cost']) ?? 0;
      total += (quantityNeeded * lastCost).round();
    }

    return total;
  }

  File _equipmentFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '01_EQUIPMENT_REGISTER',
        'equipment_register.csv',
      ),
    );
  }

  File _partsFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '02_PARTS_INVENTORY',
        'parts_inventory.csv',
      ),
    );
  }

  File _ordersFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '07_SUPPLIERS_AND_ORDERS',
        'orders_tracker.csv',
      ),
    );
  }

  File _supplierFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '07_SUPPLIERS_AND_ORDERS',
        'supplier_register.csv',
      ),
    );
  }

  File _maintenanceFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '10_REPAIR_MAINTENANCE_AND_CALIBRATION',
        'maintenance_log.csv',
      ),
    );
  }

  File _locationFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '09_BORROWED_LENT_AND_LOCATION_TRACKING',
        'location_register.csv',
      ),
    );
  }

  File _reorderFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '11_REORDER_LOW_STOCK_AND_WISHLIST',
        'reorder_list.csv',
      ),
    );
  }

  File _valuationFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '13_VALUATION_AND_INSURANCE_EVIDENCE',
        'valuation_summary.csv',
      ),
    );
  }

  File _qrLabelFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '12_PHOTOS_QR_LABELS_AND_BINS',
        'qr_label_register.csv',
      ),
    );
  }

  File _changeJournalFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        'changes',
        'asset_change_journal.csv',
      ),
    );
  }

  String _normalizedRootPath(String assetsRootPath) {
    final trimmed = assetsRootPath.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    return _workingDirectory.path;
  }

  int? _parseInt(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    return int.tryParse(trimmed);
  }

  double? _parseDouble(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    return double.tryParse(trimmed);
  }

  String _normalizedStatus(String? value) {
    return (value ?? '').trim().toLowerCase().replaceAll(' ', '_');
  }

  Future<AssetCsvTable> _replaceRowByKey({
    required File file,
    required List<String> headers,
    required List<Map<String, String>> rows,
    required String keyColumn,
    required String? keyValue,
    required Map<String, String> updatedRow,
  }) async {
    final normalizedKey = (keyValue ?? '').trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(
        keyValue,
        keyColumn,
        'Key column cannot be empty',
      );
    }

    var replaced = false;
    final updatedRows = <Map<String, String>>[];
    for (final row in rows) {
      final currentKey = (row[keyColumn] ?? '').trim();
      if (currentKey == normalizedKey) {
        updatedRows.add(updatedRow);
        replaced = true;
      } else {
        updatedRows.add(row);
      }
    }

    if (!replaced) {
      updatedRows.add(updatedRow);
    }

    final table = AssetCsvTable(
      headers: _csvServiceHeaders(headers, updatedRows),
      rows: updatedRows,
    );
    await _csvService.writeTable(file, table);
    return table;
  }

  Future<AssetCsvTable> _removeRowByKey({
    required File file,
    required List<String> headers,
    required List<Map<String, String>> rows,
    required String keyColumn,
    required String? keyValue,
  }) async {
    final normalizedKey = (keyValue ?? '').trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(
        keyValue,
        keyColumn,
        'Key column cannot be empty',
      );
    }

    final updatedRows = <Map<String, String>>[];
    for (final row in rows) {
      final currentKey = (row[keyColumn] ?? '').trim();
      if (currentKey == normalizedKey) {
        continue;
      }
      updatedRows.add(row);
    }

    final table = AssetCsvTable(
      headers: _csvServiceHeaders(headers, updatedRows),
      rows: updatedRows,
    );
    await _csvService.writeTable(file, table);
    return table;
  }

  List<String> _csvServiceHeaders(
    List<String> headers,
    Iterable<Map<String, String>> rows,
  ) {
    final merged = <String>[];
    for (final header in headers) {
      final trimmed = header.trim();
      if (trimmed.isNotEmpty && !merged.contains(trimmed)) {
        merged.add(trimmed);
      }
    }
    for (final row in rows) {
      for (final key in row.keys) {
        final trimmed = key.trim();
        if (trimmed.isNotEmpty && !merged.contains(trimmed)) {
          merged.add(trimmed);
        }
      }
    }
    return merged;
  }
}
