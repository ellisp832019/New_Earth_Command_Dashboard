import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';

import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/qr_label_printing_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/qr_label_studio_screen.dart';

void main() {
  testWidgets('qr label studio surfaces connected printers', (tester) async {
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
              partsCount: 0,
              guidanceNote: 'Connected.',
            ),
          ),
          assetEquipmentRegisterProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: AssetRegisterRepository.equipmentHeaders,
              rows: const [
                {
                  'asset_id': 'NE-EQ-0001',
                  'name': 'Thermal printer',
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
          assetQrLabelTemplateRegisterProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.labelRegisterHeaders,
              rows: const [],
            ),
          ),
          assetQrPrintQueueProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.queueHeaders,
              rows: const [],
            ),
          ),
          assetQrPrinterProfilesProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.printerProfileHeaders,
              rows: const [
                {
                  'profile_id': 'pm260_default',
                  'printer_name': 'ETIKEZ PM260',
                  'driver_name': 'Labelnice-compatible Bluetooth',
                  'paper_size': '50 x 30 mm',
                  'dpi': '203',
                  'notes': '',
                },
              ],
            ),
          ),
          assetQrBulkTemplatesProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.bulkTemplateHeaders,
              rows: const [],
            ),
          ),
          assetPrintingInfoProvider.overrideWith(
            (ref) async => const PrintingInfo(canListPrinters: true),
          ),
          assetAvailablePrintersProvider.overrideWith(
            (ref) async => const [
              Printer(
                url: 'usb://etikez-pm260',
                name: 'ETIKEZ PM260',
                location: 'Desk',
                isDefault: true,
                isAvailable: true,
              ),
              Printer(
                url: 'network://xp-3200',
                name: 'XP-3200 Series(Network)',
                location: 'Office',
                isDefault: false,
                isAvailable: true,
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: QrLabelStudioScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Connected printer'), findsOneWidget);
    expect(find.text('Windows sees printers'), findsOneWidget);
    expect(find.text('ETIKEZ PM260 (Default)'), findsOneWidget);
    expect(find.text('PM260 profile selected'), findsOneWidget);
    expect(find.text('PM260 printer detected'), findsOneWidget);
    expect(find.text('Matched'), findsOneWidget);
    expect(find.text('PM260 is ready for direct print.'), findsOneWidget);
    expect(find.text('Print to printer'), findsOneWidget);
  });
}
