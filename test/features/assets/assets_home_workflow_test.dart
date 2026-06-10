import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/application/asset_treasury_links_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/assets_screen.dart';

void main() {
  testWidgets('assets home highlights the highest priority next action', (
    tester,
  ) async {
    final fixture = _fixture();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetSyncStatusProvider.overrideWith(
            (ref) async => fixture.syncStatus,
          ),
          assetTreasuryLinkSummaryProvider.overrideWith(
            (ref) async => fixture.treasurySummary,
          ),
        ],
        child: const MaterialApp(home: AssetsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Priority focus'), findsOneWidget);
    expect(find.text('Low stock needs attention'), findsOneWidget);
    expect(find.text('Top 3 focus'), findsOneWidget);
    expect(find.text('CONFIG'), findsOneWidget);
    expect(find.text('local_paths.json'), findsWidgets);
    expect(find.text('17 required folders'), findsOneWidget);
    expect(find.text('0 missing folders'), findsOneWidget);
    expect(find.text('0 missing files'), findsOneWidget);
    expect(find.text('1. Open Equipment Register'), findsOneWidget);
    expect(find.text('2. Open Parts Inventory'), findsOneWidget);
    expect(find.textContaining('Open Low Stock / Reorder'), findsWidgets);
    expect(find.text('Dashboard / Assets'), findsOneWidget);
    expect(find.text('LOW STOCK'), findsOneWidget);
    expect(find.text('REPAIR'), findsOneWidget);
    expect(find.text('PROJECTS'), findsOneWidget);
    expect(find.text('Decision bridge'), findsOneWidget);
    expect(find.text('Asset sync'), findsOneWidget);
    expect(find.text('Journal active'), findsOneWidget);
    expect(find.text('1 conflicts'), findsOneWidget);
    expect(find.text('Review Conflicts'), findsOneWidget);
    expect(find.text('Refresh journal'), findsOneWidget);
    expect(find.text('Export summary report'), findsOneWidget);
    expect(find.text('Receipts / Warranties / Manuals'), findsOneWidget);
    expect(find.text('Bin Map'), findsOneWidget);
    expect(find.text('Open QR Labels'), findsOneWidget);
    expect(find.text('Open QR Studio'), findsOneWidget);
  });

  testWidgets('assets home surfaces missing setup data clearly', (
    tester,
  ) async {
    final fixture = _fixture(
      snapshotOverride: const AssetWorkspaceSnapshot(
        configPath: 'config/local_paths.json',
        assetsRootPath:
            'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
        isReady: false,
        issues: <String>['Setup needed'],
        requiredFolders: AssetFolderService.requiredFolders,
        missingFolders: <String>['01_EQUIPMENT_REGISTER', '02_PARTS_INVENTORY'],
        missingFiles: <String>['01_EQUIPMENT_REGISTER/equipment_register.csv'],
        summaryCards: <AssetSummaryCard>[
          AssetSummaryCard(
            kind: AssetSummaryKind.available,
            title: 'Available',
            count: 0,
            subtitle: 'Items ready or settled in place.',
          ),
        ],
        equipmentCount: 0,
        partsCount: 0,
        guidanceNote: 'The asset folder still needs a little setup.',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => fixture.snapshot),
          assetSyncStatusProvider.overrideWith(
            (ref) async => fixture.syncStatus,
          ),
          assetTreasuryLinkSummaryProvider.overrideWith(
            (ref) async => fixture.treasurySummary,
          ),
        ],
        child: const MaterialApp(home: AssetsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Missing data'), findsOneWidget);
    expect(find.text('17 required folders'), findsOneWidget);
    expect(find.text('2 folders missing'), findsOneWidget);
    expect(find.text('1 file missing'), findsOneWidget);
    expect(find.text('Finish setup first'), findsOneWidget);
    expect(find.text('3. Create starter files'), findsOneWidget);
  });
}

_AssetsHomeFixture _fixture({AssetWorkspaceSnapshot? snapshotOverride}) {
  return _AssetsHomeFixture(
    snapshot:
        snapshotOverride ??
        const AssetWorkspaceSnapshot(
          configPath: 'config/local_paths.json',
          assetsRootPath:
              'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
          isReady: true,
          issues: <String>[],
          requiredFolders: AssetFolderService.requiredFolders,
          missingFolders: <String>[],
          missingFiles: <String>[],
          summaryCards: <AssetSummaryCard>[
            AssetSummaryCard(
              kind: AssetSummaryKind.available,
              title: 'Available',
              count: 4,
              subtitle: 'Items ready or settled in place.',
            ),
            AssetSummaryCard(
              kind: AssetSummaryKind.lowStock,
              title: 'Low Stock',
              count: 2,
              subtitle: 'Parts that need a gentle reorder check.',
            ),
            AssetSummaryCard(
              kind: AssetSummaryKind.brokenRepair,
              title: 'Broken / Repair',
              count: 1,
              subtitle: 'Items needing repair or replacement attention.',
            ),
            AssetSummaryCard(
              kind: AssetSummaryKind.needsDecision,
              title: 'Needs Decision',
              count: 0,
              subtitle: 'Items waiting for a clear next step.',
            ),
            AssetSummaryCard(
              kind: AssetSummaryKind.wishlist,
              title: 'Wishlist',
              count: 0,
              subtitle: 'Nice-to-have items to keep parked for now.',
            ),
            AssetSummaryCard(
              kind: AssetSummaryKind.projectSummary,
              title: 'Project Asset Summary',
              count: 2,
              subtitle: 'Projects currently linked to asset records.',
            ),
          ],
          equipmentCount: 4,
          partsCount: 8,
          guidanceNote: 'The external asset folder is connected.',
        ),
    treasurySummary: const AssetTreasuryLinkSummary(
      receiptsMissingCount: 3,
      purchaseCostTotal: 1200,
      reorderEstimatedSpend: 48,
      linkedFinanceIdCount: 5,
      brokenEquipmentCount: 1,
      repairReplacementValueTotal: 75,
    ),
    syncStatus: const AssetSyncStatus(
      isConnected: true,
      entryCount: 0,
      conflictCount: 1,
      lastChangeAt: null,
      lastWriterLabel: 'No writer recorded yet',
      statusLabel: 'Journal active',
    ),
  );
}

class _AssetsHomeFixture {
  const _AssetsHomeFixture({
    required this.snapshot,
    required this.treasurySummary,
    required this.syncStatus,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetTreasuryLinkSummary treasurySummary;
  final AssetSyncStatus syncStatus;
}
