import 'dart:io';

import 'package:path/path.dart' as path;

import 'asset_csv_service.dart';

class AssetRegisterRepository {
  AssetRegisterRepository({
    AssetCsvService? csvService,
    Directory? workingDirectory,
  })  : _csvService = csvService ?? AssetCsvService(),
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

  Future<AssetCsvTable> readMaintenanceLog(String assetsRootPath) {
    return _csvService.readTable(
      _maintenanceFile(assetsRootPath),
      expectedHeaders: maintenanceHeaders,
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

  Future<AssetCsvTable> writeEquipmentRegister(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService.writeTable(_equipmentFile(assetsRootPath), table).then(
      (_) => table,
    );
  }

  Future<AssetCsvTable> writePartsInventory(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService.writeTable(_partsFile(assetsRootPath), table).then(
      (_) => table,
    );
  }

  Future<AssetCsvTable> writeOrdersTracker(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService.writeTable(_ordersFile(assetsRootPath), table).then(
      (_) => table,
    );
  }

  Future<AssetCsvTable> writeMaintenanceLog(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService.writeTable(_maintenanceFile(assetsRootPath), table).then(
      (_) => table,
    );
  }

  Future<AssetCsvTable> writeReorderList(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService.writeTable(_reorderFile(assetsRootPath), table).then(
      (_) => table,
    );
  }

  Future<AssetCsvTable> writeValuationSummary(
    String assetsRootPath,
    AssetCsvTable table,
  ) {
    return _csvService.writeTable(_valuationFile(assetsRootPath), table).then(
      (_) => table,
    );
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

  File _maintenanceFile(String assetsRootPath) {
    return File(
      path.join(
        _normalizedRootPath(assetsRootPath),
        '10_REPAIR_MAINTENANCE_AND_CALIBRATION',
        'maintenance_log.csv',
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

  String _normalizedRootPath(String assetsRootPath) {
    final trimmed = assetsRootPath.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    return _workingDirectory.path;
  }
}
