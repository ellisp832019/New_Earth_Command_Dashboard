import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/assets/application/assets_controller.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_csv_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/asset_register_repository.dart';
import 'package:new_earth_command_dashboard/features/assets/data/assets_folder_service.dart';
import 'package:new_earth_command_dashboard/features/assets/data/qr_label_printing_service.dart';
import 'package:new_earth_command_dashboard/features/assets/presentation/qr_label_lifecycle_screen.dart';

void main() {
  testWidgets('qr label lifecycle shows the main flow and route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: RouteNames.assetQrLifecycle,
      routes: [
        GoRoute(
          path: RouteNames.assetQrLifecycle,
          builder: (context, state) => const QrLabelLifecycleScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assetWorkspaceProvider.overrideWith((ref) async => _fixture.snapshot),
          assetQrLabelRegisterProvider.overrideWith(
            (ref) async => _fixture.labelRegisterTable,
          ),
          assetQrLabelTemplateRegisterProvider.overrideWith(
            (ref) async => _fixture.historyTable,
          ),
          assetQrPrintQueueProvider.overrideWith(
            (ref) async => _fixture.queueTable,
          ),
          assetQrBulkTemplatesProvider.overrideWith(
            (ref) async => _fixture.templatesTable,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('QR Label Lifecycle'), findsAtLeastNWidgets(1));
    expect(find.text('Lifecycle flow'), findsAtLeastNWidgets(1));
    expect(find.text('Register labels'), findsAtLeastNWidgets(1));
    expect(find.text('1. Register'), findsAtLeastNWidgets(1));
    expect(find.text('Open Register'), findsAtLeastNWidgets(1));
    expect(find.text('Open Studio'), findsAtLeastNWidgets(1));
    expect(find.text('Open Queue'), findsAtLeastNWidgets(1));
    expect(find.text('Open History'), findsAtLeastNWidgets(1));
    expect(find.text('Inventory Session'), findsAtLeastNWidgets(1));
    expect(find.text('Scan Lookup'), findsAtLeastNWidgets(1));
  });
}

final _fixture = _QrLifecycleFixture(
  snapshot: const AssetWorkspaceSnapshot(
    configPath: 'config/local_paths.json',
    assetsRootPath: 'D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS',
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
  labelRegisterTable: AssetCsvTable(
    headers: AssetRegisterRepository.qrLabelHeaders,
    rows: const [
      {
        'asset_id': 'NE-EQ-0001',
        'label_code': 'NE-EQ-0001-QR',
        'qr_target': 'asset-search:NE-EQ-0001',
        'file_or_url': 'assets/NE-EQ-0001.md',
        'status': 'pending',
        'printed_date': '',
        'notes': '',
      },
    ],
  ),
  historyTable: AssetCsvTable(
    headers: QrLabelPrintService.labelRegisterHeaders,
    rows: const [
      {
        'label_id': '01_asset_2026-06-07T09-30-54.261780',
        'asset_id': '01',
        'label_type': 'asset',
        'label_size': '50x30',
        'qr_payload': '01',
        'label_text': 'Asset label',
        'generated_file': 'D:/labels/01_asset_2026-06-07T09-30-54.261780.pdf',
        'manifest_file': 'D:/labels/01_asset_2026-06-07T09-30-54.261780.json',
        'print_status': 'generated',
        'printed_date': '',
        'applied_date': '',
        'location': 'microgrow',
        'notes': '',
      },
    ],
  ),
  queueTable: AssetCsvTable(
    headers: QrLabelPrintService.queueHeaders,
    rows: const [
      {
        'queue_id': 'q1',
        'date_added': '2026-06-07',
        'asset_id': 'NE-EQ-0001',
        'label_type': 'asset',
        'label_size': '50x30',
        'priority': 'normal',
        'status': 'queued',
        'generated_file': 'D:/labels/q1.pdf',
        'manifest_file': 'D:/labels/q1.json',
        'printer_profile': 'pm260_etikez',
        'notes': '',
      },
      {
        'queue_id': 'q2',
        'date_added': '2026-06-07',
        'asset_id': 'NE-EQ-0002',
        'label_type': 'asset',
        'label_size': '50x30',
        'priority': 'normal',
        'status': 'printed',
        'generated_file': 'D:/labels/q2.pdf',
        'manifest_file': 'D:/labels/q2.json',
        'printer_profile': 'pm260_etikez',
        'notes': '',
      },
      {
        'queue_id': 'q3',
        'date_added': '2026-06-07',
        'asset_id': 'NE-EQ-0003',
        'label_type': 'asset',
        'label_size': '50x30',
        'priority': 'normal',
        'status': 'applied',
        'generated_file': 'D:/labels/q3.pdf',
        'manifest_file': 'D:/labels/q3.json',
        'printer_profile': 'pm260_etikez',
        'notes': '',
      },
      {
        'queue_id': 'q4',
        'date_added': '2026-06-07',
        'asset_id': 'NE-EQ-0004',
        'label_type': 'asset',
        'label_size': '50x30',
        'priority': 'normal',
        'status': 'reprint_needed',
        'generated_file': 'D:/labels/q4.pdf',
        'manifest_file': 'D:/labels/q4.json',
        'printer_profile': 'pm260_etikez',
        'notes': '',
      },
    ],
  ),
  templatesTable: AssetCsvTable(
    headers: QrLabelPrintService.bulkTemplateHeaders,
    rows: const [
      {
        'template_id': 'tpl-01',
        'template_name': 'Asset starter',
        'search_query': 'microgrow',
        'label_type': 'asset',
        'label_size': '50x30',
        'printer_profile_id': 'pm260_etikez',
        'priority': 'normal',
        'notes': '',
        'created_at': '2026-06-07',
      },
    ],
  ),
);

class _QrLifecycleFixture {
  const _QrLifecycleFixture({
    required this.snapshot,
    required this.labelRegisterTable,
    required this.historyTable,
    required this.queueTable,
    required this.templatesTable,
  });

  final AssetWorkspaceSnapshot snapshot;
  final AssetCsvTable labelRegisterTable;
  final AssetCsvTable historyTable;
  final AssetCsvTable queueTable;
  final AssetCsvTable templatesTable;
}
