import 'package:flutter/material.dart';
import 'dart:io';

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
    expect(find.text('1 profile'), findsOneWidget);
    expect(find.text('PM260 preset ready'), findsOneWidget);
    expect(find.text('Printer profile: pm260_default'), findsOneWidget);
    expect(find.text('Printer profiles available: 1'), findsOneWidget);
    expect(find.text('Matched'), findsOneWidget);
    expect(find.text('PM260 is ready for direct print.'), findsOneWidget);
    expect(find.text('Print to printer'), findsOneWidget);
  });

  testWidgets('qr label studio can edit and delete register entries', (
    tester,
  ) async {
    final service = _FakeQrLabelPrintService();

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
          assetQrLabelPrintServiceProvider.overrideWithValue(service),
          assetQrLabelTemplateRegisterProvider.overrideWith(
            (ref) async => AssetCsvTable(
              headers: QrLabelPrintService.labelRegisterHeaders,
              rows: const [
                {
                  'label_id': '01_asset_2026-06-07T09-30-54.261780',
                  'asset_id': '01',
                  'label_type': 'asset',
                  'label_size': '50x30',
                  'qr_payload': '01',
                  'label_text': 'Asset label',
                  'generated_file':
                      'D:/labels/01_asset_2026-06-07T09-30-54.261780.pdf',
                  'manifest_file':
                      'D:/labels/01_asset_2026-06-07T09-30-54.261780.json',
                  'print_status': 'generated',
                  'printed_date': '',
                  'applied_date': '',
                  'location': 'microgrow',
                  'notes': 'dfvdsfdsf',
                },
              ],
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
            ],
          ),
        ],
        child: const MaterialApp(home: QrLabelStudioScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.scrollUntilVisible(
      find.text('Edit'),
      400.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Edit'), findsWidgets);
    expect(find.text('Delete'), findsWidgets);

    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();

    expect(find.text('Edit label entry'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);

    await tester.tap(find.text('Cancel').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete label entry?'), findsOneWidget);
    expect(find.text('Delete entry'), findsOneWidget);
  });
}

class _FakeQrLabelPrintService extends QrLabelPrintService {
  _FakeQrLabelPrintService()
      : super(csvService: AssetCsvService(), workingDirectory: Directory.current);

  String? updatedLabelId;
  String? deletedLabelId;

  @override
  Future<void> updateLabelRegisterEntry(
    String assetsRootPath,
    QrLabelRegisterEntry entry,
  ) async {
    updatedLabelId = entry.labelId;
  }

  @override
  Future<void> deleteLabelRegisterEntry(
    String assetsRootPath,
    String labelId,
  ) async {
    deletedLabelId = labelId;
  }
}
