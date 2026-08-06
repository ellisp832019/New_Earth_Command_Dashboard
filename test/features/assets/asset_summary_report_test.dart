import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/application/asset_treasury_links_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_summary_report.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';

void main() {
  test('asset summary report includes the key asset and treasury signals', () {
    final snapshot = AssetWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      assetsRootPath:
          'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
      isReady: false,
      issues: const <String>['Setup needed'],
      requiredFolders: AssetFolderService.requiredFolders,
      missingFolders: const <String>['01_EQUIPMENT_REGISTER'],
      missingFiles: const <String>[
        '01_EQUIPMENT_REGISTER/equipment_register.csv',
      ],
      summaryCards: const <AssetSummaryCard>[
        AssetSummaryCard(
          kind: AssetSummaryKind.available,
          title: 'Available',
          count: 4,
          subtitle: 'Items ready or settled in place.',
        ),
      ],
      equipmentCount: 4,
      partsCount: 2,
      guidanceNote: 'Connected.',
    );

    final syncStatus = const AssetSyncStatus(
      isConnected: true,
      entryCount: 7,
      conflictCount: 1,
      lastChangeAt: null,
      lastWriterLabel: 'Hayley',
      statusLabel: 'Journal active',
    );

    final treasurySummary = const AssetTreasuryLinkSummary(
      receiptsMissingCount: 3,
      purchaseCostTotal: 1200,
      reorderEstimatedSpend: 48,
      linkedFinanceIdCount: 5,
      brokenEquipmentCount: 1,
      repairReplacementValueTotal: 75,
    );

    final report = buildAssetSummaryReport(
      snapshot: snapshot,
      syncStatus: syncStatus,
      treasurySummary: treasurySummary,
      generatedAt: DateTime(2026, 5, 29, 10, 30),
    );

    expect(report, contains('# Asset Intelligence Summary'));
    expect(report, contains('- Ready: no'));
    expect(report, contains('- Journal status: Journal active'));
    expect(report, contains('- Receipts missing: 3'));
    expect(report, contains('## Missing setup data'));
    expect(report, contains('- Folder: 01_EQUIPMENT_REGISTER'));
    expect(
      report,
      contains('- File: 01_EQUIPMENT_REGISTER/equipment_register.csv'),
    );
  });
}
