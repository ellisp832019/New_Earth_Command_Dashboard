import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/application/asset_treasury_links_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';

void main() {
  test('asset treasury links summarize receipts, spend, and finance ids', () async {
    final container = ProviderContainer(
      overrides: [
        assetWorkspaceProvider.overrideWith(
          (ref) async => const AssetWorkspaceSnapshot(
            configPath: 'config/local_paths.json',
            assetsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
            isReady: true,
            issues: <String>[],
            requiredFolders: AssetFolderService.requiredFolders,
            missingFolders: <String>[],
            missingFiles: <String>[],
            summaryCards: <AssetSummaryCard>[],
            equipmentCount: 2,
            partsCount: 2,
            guidanceNote: 'Connected.',
          ),
        ),
        assetEquipmentRegisterProvider.overrideWith(
          (ref) async => AssetCsvTable(
            headers: AssetRegisterRepository.equipmentHeaders,
            rows: [
              {
                'asset_id': 'NE-EQ-0001',
                'name': 'Field scanner',
                'type': 'Scanner',
                'project': 'MicroGrow',
                'owner': 'Peter',
                'location': 'Workbench A',
                'condition': 'good',
                'status': 'available',
                'purchase_date': '2026-04-10',
                'purchase_cost': '120',
                'replacement_value': '140',
                'serial_number': 'SN-001',
                'receipt_link': '',
                'warranty_until': '',
                'notes': '',
              },
              {
                'asset_id': 'NE-EQ-0002',
                'name': 'Repair drone',
                'type': 'Drone',
                'project': 'MicroGrow',
                'owner': 'Hayley',
                'location': 'Bench',
                'condition': 'broken',
                'status': 'broken',
                'purchase_date': '2026-04-11',
                'purchase_cost': '250',
                'replacement_value': '320',
                'serial_number': 'SN-002',
                'receipt_link': 'receipt-001',
                'warranty_until': '',
                'notes': '',
              },
            ],
          ),
        ),
        assetPartsRegisterProvider.overrideWith(
          (ref) async => AssetCsvTable(
            headers: AssetRegisterRepository.partsHeaders,
            rows: [
              {
                'part_id': 'NE-PART-0001',
                'name': 'M3 screws',
                'category': 'Fasteners',
                'project': 'MicroGrow',
                'quantity': '4',
                'min_quantity': '10',
                'location': 'Drawer',
                'supplier': 'RS',
                'last_ordered': '2026-05-01',
                'last_cost': '1.25',
                'status': 'low_stock',
                'datasheet_link': '',
                'notes': '',
              },
              {
                'part_id': 'NE-PART-0002',
                'name': 'Labels',
                'category': 'Stationery',
                'project': 'New Earth HQ',
                'quantity': '20',
                'min_quantity': '5',
                'location': 'Shelf',
                'supplier': 'Office Depot',
                'last_ordered': '2026-05-01',
                'last_cost': '2',
                'status': 'available',
                'datasheet_link': '',
                'notes': '',
              },
            ],
          ),
        ),
        assetOrdersTrackerProvider.overrideWith(
          (ref) async => AssetCsvTable(
            headers: AssetRegisterRepository.ordersHeaders,
            rows: [
              {
                'order_id': 'NE-ORD-0001',
                'date': '2026-05-01',
                'supplier': 'RS',
                'item': 'M3 screws',
                'project': 'MicroGrow',
                'quantity': '10',
                'total_cost': '12.50',
                'status': 'received',
                'tracking': '',
                'receipt_link': '',
                'finance_record_id': 'FIN-001',
                'notes': '',
              },
            ],
          ),
        ),
        assetMaintenanceLogProvider.overrideWith(
          (ref) async => AssetCsvTable(
            headers: AssetRegisterRepository.maintenanceHeaders,
            rows: [
              {
                'date': '2026-05-02',
                'asset_id': 'NE-EQ-0002',
                'item': 'Repair drone',
                'issue': 'Motor issue',
                'action': 'Repairing',
                'status': 'repairing',
                'cost': '35',
                'linked_finance_record': 'FIN-002',
                'notes': '',
              },
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final summary = await container.read(assetTreasuryLinkSummaryProvider.future);

    expect(summary.receiptsMissingCount, 2);
    expect(summary.purchaseCostTotal, 370);
    expect(summary.reorderEstimatedSpend, greaterThan(0));
    expect(summary.linkedFinanceIdCount, 2);
    expect(summary.brokenEquipmentCount, 1);
    expect(summary.repairReplacementValueTotal, 320);
  });
}
