import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_inventory_session_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/inventory_session_screen.dart';

void main() {
  testWidgets('inventory session separates thermal and paper references', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith(
            (ref) async => const AssetWorkspaceSnapshot(
              configPath: 'config/local_paths.json',
              assetsRootPath:
                  'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
              isReady: true,
              issues: <String>[],
              requiredFolders: AssetFolderService.requiredFolders,
              missingFolders: <String>[],
              missingFiles: <String>[],
              summaryCards: <AssetSummaryCard>[],
              equipmentCount: 1,
              partsCount: 1,
              guidanceNote: 'Connected.',
            ),
          ),
          assetEquipmentRegisterProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: AssetRegisterRepository.equipmentHeaders,
              rows: const [
                {
                  'asset_id': 'NE-EQ-0001',
                  'name': 'Thermal label printer',
                  'type': 'Printer',
                  'project': 'Assets',
                  'owner': '',
                  'location': 'Desk',
                  'condition': 'Good',
                  'status': 'available',
                  'purchase_date': '',
                  'purchase_cost': '',
                  'replacement_value': '',
                  'serial_number': '',
                  'receipt_link': '',
                  'warranty_until': '',
                  'notes': '',
                },
              ],
            ),
          ),
          assetPartsRegisterProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: AssetRegisterRepository.partsHeaders,
              rows: const [
                {
                  'part_id': 'NE-PT-0001',
                  'name': 'Label roll',
                  'project': 'Assets',
                  'location': 'Shelf A',
                  'status': 'low',
                  'quantity': '2',
                  'notes': '',
                },
              ],
            ),
          ),
          assetQrLabelRegisterProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: AssetRegisterRepository.qrLabelHeaders,
              rows: const [
                {
                  'asset_id': 'NE-EQ-0001',
                  'label_code': 'NE-EQ-0001-QR',
                  'qr_target': 'asset-search:NE-EQ-0001',
                  'file_or_url': 'assets/NE-EQ-0001.md',
                  'status': 'pending',
                  'printed_date': '2026-05-28',
                  'notes': 'Print on durable stock.',
                },
              ],
            ),
          ),
          assetLowStockPartsProvider.overrideWith(
            (ref) async => <Map<String, String>>[
              {
                'part_id': 'NE-PT-0001',
                'name': 'Label roll',
                'project': 'Assets',
                'location': 'Shelf A',
                'status': 'low',
                'quantity': '2',
                'notes': '',
              },
            ],
          ),
          assetInventorySessionLogProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: AssetInventorySessionService.sessionLogHeaders,
              rows: const [
                {
                  'session_id': 'session-001',
                  'session_name': 'Hayley and Ellis inventory week',
                  'created_at': '2026-06-07 09:00',
                  'equipment_items': '1',
                  'parts_items': '1',
                  'labeled_equipment_items': '1',
                  'unlabeled_equipment_items': '0',
                  'low_stock_parts': '1',
                  'csv_file': 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS/12_PHOTOS_QR_LABELS_AND_BINS/04_INVENTORY_SESSIONS/session-001_checklist.csv',
                  'pdf_file': 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS/12_PHOTOS_QR_LABELS_AND_BINS/04_INVENTORY_SESSIONS/session-001_checklist.pdf',
                  'notes': 'Weekly pack.',
                },
              ],
            ),
          ),
        ],
        child: const MaterialApp(home: InventorySessionScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Inventory Session'), findsOneWidget);
    expect(find.text('Thermal print path'), findsOneWidget);
    expect(find.text('Paper references'), findsOneWidget);
    expect(find.text('QR History'), findsOneWidget);
    expect(find.text('Open checklist'), findsOneWidget);
    expect(find.text('Open QR guide'), findsOneWidget);
    expect(find.text('Equipment 1  |  Parts 1  |  QR missing 0'), findsOneWidget);
  });
}
