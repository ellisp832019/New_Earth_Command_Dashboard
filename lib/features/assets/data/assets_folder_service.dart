import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../core/constants/omega_os_folder_registry.dart';
import '../../../core/utils/folder_bootstrap_result.dart';
import 'asset_register_repository.dart';

enum AssetSummaryKind {
  available,
  lowStock,
  brokenRepair,
  needsDecision,
  wishlist,
  projectSummary,
}

class AssetSummaryCard {
  const AssetSummaryCard({
    required this.kind,
    required this.title,
    required this.count,
    required this.subtitle,
  });

  final AssetSummaryKind kind;
  final String title;
  final int count;
  final String subtitle;
}

class AssetWorkspaceSnapshot {
  const AssetWorkspaceSnapshot({
    required this.configPath,
    required this.assetsRootPath,
    required this.isReady,
    required this.issues,
    required this.requiredFolders,
    required this.missingFolders,
    required this.missingFiles,
    required this.summaryCards,
    required this.equipmentCount,
    required this.partsCount,
    required this.guidanceNote,
  });

  final String configPath;
  final String? assetsRootPath;
  final bool isReady;
  final List<String> issues;
  final List<String> requiredFolders;
  final List<String> missingFolders;
  final List<String> missingFiles;
  final List<AssetSummaryCard> summaryCards;
  final int equipmentCount;
  final int partsCount;
  final String guidanceNote;
}

class AssetFolderService {
  AssetFolderService({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current,
      _registerRepository = AssetRegisterRepository(
        workingDirectory: workingDirectory ?? Directory.current,
      );

  static const _configRelativePath = 'config/local_paths.json';
  static const _assetsRootKey = 'assets_equipment_path';

  static const requiredFolders = <String>[
    '00_ASSET_DASHBOARD',
    '01_EQUIPMENT_REGISTER',
    '02_PARTS_INVENTORY',
    'changes',
    '07_SUPPLIERS_AND_ORDERS',
    '09_BORROWED_LENT_AND_LOCATION_TRACKING',
    '10_REPAIR_MAINTENANCE_AND_CALIBRATION',
    '11_REORDER_LOW_STOCK_AND_WISHLIST',
    '12_PHOTOS_QR_LABELS_AND_BINS',
    '13_VALUATION_AND_INSURANCE_EVIDENCE',
  ];

  static const requiredFiles = <String>[
    '00_ASSET_DASHBOARD/asset_dashboard_state.json',
    '01_EQUIPMENT_REGISTER/equipment_register.csv',
    '02_PARTS_INVENTORY/parts_inventory.csv',
    'changes/asset_change_journal.csv',
    '07_SUPPLIERS_AND_ORDERS/orders_tracker.csv',
    '07_SUPPLIERS_AND_ORDERS/supplier_register.csv',
    '09_BORROWED_LENT_AND_LOCATION_TRACKING/location_register.csv',
    '10_REPAIR_MAINTENANCE_AND_CALIBRATION/maintenance_log.csv',
    '11_REORDER_LOW_STOCK_AND_WISHLIST/reorder_list.csv',
    '13_VALUATION_AND_INSURANCE_EVIDENCE/valuation_summary.csv',
    '12_PHOTOS_QR_LABELS_AND_BINS/qr_label_register.csv',
  ];

  final Directory _workingDirectory;
  final AssetRegisterRepository _registerRepository;

  Future<AssetWorkspaceSnapshot> loadWorkspace() async {
    final configFile = File(
      path.join(_workingDirectory.path, _configRelativePath),
    );
    final issues = <String>[];
    String? assetsRootPath;

    if (!await configFile.exists()) {
      issues.add(
        'config/local_paths.json was not found in the dashboard repo.',
      );
    } else {
      try {
        final decoded = jsonDecode(await configFile.readAsString());
        if (decoded is Map<String, dynamic>) {
          final value = decoded[_assetsRootKey];
          if (value is String && value.trim().isNotEmpty) {
            assetsRootPath = value.trim();
          } else {
            issues.add(
              'assets_equipment_path is missing from config/local_paths.json.',
            );
          }
        } else {
          issues.add('config/local_paths.json should contain a JSON object.');
        }
      } on FormatException {
        issues.add('config/local_paths.json could not be read as JSON.');
      } on FileSystemException {
        issues.add('config/local_paths.json could not be opened.');
      }
    }

    Directory? assetsRoot;
    if (assetsRootPath != null) {
      assetsRoot = Directory(assetsRootPath);
      if (!await assetsRoot.exists()) {
        issues.add('The asset folder does not exist at the configured path.');
      }
    }

    final missingFolders = <String>[];
    if (assetsRoot != null && await assetsRoot.exists()) {
      for (final relativeFolder in requiredFolders) {
        final candidate = Directory(path.join(assetsRoot.path, relativeFolder));
        if (!await candidate.exists()) {
          missingFolders.add(relativeFolder);
        }
      }
    }

    final missingFiles = <String>[];
    if (assetsRoot != null && await assetsRoot.exists()) {
      for (final relativeFile in requiredFiles) {
        final candidate = File(path.join(assetsRoot.path, relativeFile));
        if (!await candidate.exists()) {
          missingFiles.add(relativeFile);
        }
      }
    }

    final equipmentRows = assetsRoot == null
        ? <Map<String, String>>[]
        : (await _registerRepository.readEquipmentRegister(
            assetsRoot.path,
          )).rows;
    final partsRows = assetsRoot == null
        ? <Map<String, String>>[]
        : (await _registerRepository.readPartsInventory(assetsRoot.path)).rows;

    final summaryCards = _buildSummaryCards(
      equipmentRows: equipmentRows,
      partsRows: partsRows,
    );

    final equipmentCount = equipmentRows.length;
    final partsCount = partsRows.length;
    final guidanceNote = assetsRoot == null
        ? 'The Asset Intelligence area will calm down once the external Omega OS folder is linked. ${OmegaOsFolderRegistry.reservedSystemsNote}'
        : missingFolders.isEmpty && missingFiles.isEmpty
        ? 'The external asset folder is connected. Keep the system local-first and only write with care. ${OmegaOsFolderRegistry.reservedSystemsNote}'
        : 'The asset folder is present, but a few expected Omega OS folders or tracker files still need attention. ${OmegaOsFolderRegistry.reservedSystemsNote}';

    return AssetWorkspaceSnapshot(
      configPath: configFile.path,
      assetsRootPath: assetsRootPath,
      isReady:
          issues.isEmpty &&
          assetsRootPath != null &&
          missingFolders.isEmpty &&
          missingFiles.isEmpty,
      issues: issues,
      requiredFolders: requiredFolders,
      missingFolders: missingFolders,
      missingFiles: missingFiles,
      summaryCards: summaryCards,
      equipmentCount: equipmentCount,
      partsCount: partsCount,
      guidanceNote: guidanceNote,
    );
  }

  Future<FolderBootstrapCreationResult> createMissingRequiredStructure() async {
    final snapshot = await loadWorkspace();
    final assetsRootPath = snapshot.assetsRootPath;
    if (assetsRootPath == null) {
      return const FolderBootstrapCreationResult(
        createdFolders: <String>[],
        createdFiles: <String>[],
      );
    }

    final assetsRoot = Directory(assetsRootPath);
    if (!await assetsRoot.exists()) {
      return const FolderBootstrapCreationResult(
        createdFolders: <String>[],
        createdFiles: <String>[],
      );
    }

    final createdFolders = <String>[];
    for (final relativeFolder in requiredFolders) {
      final candidate = Directory(path.join(assetsRoot.path, relativeFolder));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.create(recursive: true);
      createdFolders.add(relativeFolder);
    }

    final createdFiles = <String>[];
    for (final relativeFile in requiredFiles) {
      final candidate = File(path.join(assetsRoot.path, relativeFile));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.parent.create(recursive: true);
      await candidate.writeAsString(_templateForRequiredFile(relativeFile));
      createdFiles.add(relativeFile);
    }

    return FolderBootstrapCreationResult(
      createdFolders: createdFolders,
      createdFiles: createdFiles,
    );
  }

  Future<List<String>> createMissingRequiredFolders() async {
    final snapshot = await loadWorkspace();
    final assetsRootPath = snapshot.assetsRootPath;
    if (assetsRootPath == null) {
      return <String>[];
    }

    final assetsRoot = Directory(assetsRootPath);
    if (!await assetsRoot.exists()) {
      return <String>[];
    }

    final createdFolders = <String>[];
    for (final relativeFolder in requiredFolders) {
      final candidate = Directory(path.join(assetsRoot.path, relativeFolder));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.create(recursive: true);
      createdFolders.add(relativeFolder);
    }

    return createdFolders;
  }

  Future<List<String>> createMissingRequiredFiles() async {
    final structure = await createMissingRequiredStructure();
    return structure.createdFiles;
  }

  AssetRegisterRepository get registerRepository => _registerRepository;

  Future<void> writeTextFileWithBackup(File file, String contents) async {
    if (await file.exists()) {
      final backupFile = File('${file.path}.bak');
      await file.copy(backupFile.path);
    } else {
      await file.parent.create(recursive: true);
    }

    await file.writeAsString(contents);
  }

  List<AssetSummaryCard> _buildSummaryCards({
    required List<Map<String, String>> equipmentRows,
    required List<Map<String, String>> partsRows,
  }) {
    final availableCount = equipmentRows.where((row) {
      final status = _normalized(row['status']);
      return status == 'available' ||
          status == 'in_use' ||
          status == 'in_storage';
    }).length;

    final lowStockCount = partsRows.where((row) {
      final status = _normalized(row['status']);
      if (status == 'low_stock' || status == 'reorder_needed') {
        return true;
      }

      final quantity = _parseInt(row['quantity']);
      final minQuantity = _parseInt(row['min_quantity']);
      return quantity != null && minQuantity != null && quantity <= minQuantity;
    }).length;

    final brokenCount = equipmentRows.where((row) {
      final status = _normalized(row['status']);
      return status == 'broken' || status == 'repairing';
    }).length;

    final needsDecisionCount = [
      ...equipmentRows,
      ...partsRows,
    ].where((row) => _normalized(row['status']) == 'reorder_needed').length;

    final wishlistCount = [
      ...equipmentRows,
      ...partsRows,
    ].where((row) => _normalized(row['status']) == 'wishlist').length;

    final projectNames = <String>{};
    for (final row in [...equipmentRows, ...partsRows]) {
      final project = row['project']?.trim() ?? '';
      if (project.isNotEmpty) {
        projectNames.add(project);
      }
    }

    return [
      AssetSummaryCard(
        kind: AssetSummaryKind.available,
        title: 'Available',
        count: availableCount,
        subtitle: 'Items ready or settled in place.',
      ),
      AssetSummaryCard(
        kind: AssetSummaryKind.lowStock,
        title: 'Low Stock',
        count: lowStockCount,
        subtitle: 'Parts that need a gentle reorder check.',
      ),
      AssetSummaryCard(
        kind: AssetSummaryKind.brokenRepair,
        title: 'Broken / Repair',
        count: brokenCount,
        subtitle: 'Items needing repair or replacement attention.',
      ),
      AssetSummaryCard(
        kind: AssetSummaryKind.needsDecision,
        title: 'Needs Decision',
        count: needsDecisionCount,
        subtitle: 'Items waiting for a clear next step.',
      ),
      AssetSummaryCard(
        kind: AssetSummaryKind.wishlist,
        title: 'Wishlist',
        count: wishlistCount,
        subtitle: 'Nice-to-have items to keep parked for now.',
      ),
      AssetSummaryCard(
        kind: AssetSummaryKind.projectSummary,
        title: 'Project Asset Summary',
        count: projectNames.length,
        subtitle: 'Projects currently linked to asset records.',
      ),
    ];
  }

  String _templateForRequiredFile(String relativePath) {
    switch (relativePath) {
      case '00_ASSET_DASHBOARD/asset_dashboard_state.json':
        return const JsonEncoder.withIndent('  ').convert({
          'updated_at': null,
          'available_count': 0,
          'low_stock_count': 0,
          'broken_count': 0,
          'needs_decision_count': 0,
          'wishlist_count': 0,
          'project_asset_count': 0,
          'notes': '',
        });
      case '01_EQUIPMENT_REGISTER/equipment_register.csv':
        return 'asset_id,name,type,project,owner,location,condition,status,purchase_date,purchase_cost,replacement_value,serial_number,receipt_link,warranty_until,notes\n';
      case '02_PARTS_INVENTORY/parts_inventory.csv':
        return 'part_id,name,category,project,quantity,min_quantity,location,supplier,last_ordered,last_cost,status,datasheet_link,notes\n';
      case 'changes/asset_change_journal.csv':
        return 'record_id,record_type,action,timestamp,machine_id,user_label,changed_fields,note\n';
      case '07_SUPPLIERS_AND_ORDERS/orders_tracker.csv':
        return 'order_id,date,supplier,item,project,quantity,total_cost,status,tracking,receipt_link,finance_record_id,notes\n';
      case '07_SUPPLIERS_AND_ORDERS/supplier_register.csv':
        return 'supplier_id,name,website,category,reliability,delivery_speed,quality,preferred,notes\n';
      case '09_BORROWED_LENT_AND_LOCATION_TRACKING/location_register.csv':
        return 'asset_id,location_name,description,photo_link,notes\n';
      case '10_REPAIR_MAINTENANCE_AND_CALIBRATION/maintenance_log.csv':
        return 'date,asset_id,item,issue,action,status,cost,linked_finance_record,notes\n';
      case '11_REORDER_LOW_STOCK_AND_WISHLIST/reorder_list.csv':
        return 'date,item,project,quantity_needed,estimated_cost,priority,status,supplier,notes\n';
      case '13_VALUATION_AND_INSURANCE_EVIDENCE/valuation_summary.csv':
        return 'asset_id,item,category,purchase_cost,replacement_value,current_estimated_value,valuation_reason,evidence_link,notes\n';
      case '12_PHOTOS_QR_LABELS_AND_BINS/qr_label_register.csv':
        return 'asset_id,label_code,qr_target,file_or_url,status,printed_date,notes\n';
      default:
        return '';
    }
  }

  String _normalized(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }

  int? _parseInt(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    return int.tryParse(trimmed);
  }
}
