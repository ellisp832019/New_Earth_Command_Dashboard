import 'package:intl/intl.dart';

import '../application/assets_controller.dart';
import '../application/asset_treasury_links_controller.dart';
import 'assets_folder_service.dart';

String buildAssetSummaryReport({
  required AssetWorkspaceSnapshot snapshot,
  required AssetSyncStatus syncStatus,
  required AssetTreasuryLinkSummary treasurySummary,
  DateTime? generatedAt,
}) {
  final now = DateFormat('yyyy-MM-dd HH:mm').format(
    generatedAt ?? DateTime.now(),
  );
  final buffer = StringBuffer()
    ..writeln('# Asset Intelligence Summary')
    ..writeln()
    ..writeln('- Generated: $now')
    ..writeln('- Asset root: ${snapshot.assetsRootPath ?? 'Not linked'}')
    ..writeln('- Ready: ${snapshot.isReady ? 'yes' : 'no'}')
    ..writeln('- Equipment count: ${snapshot.equipmentCount}')
    ..writeln('- Parts count: ${snapshot.partsCount}')
    ..writeln('- Journal status: ${syncStatus.statusLabel}')
    ..writeln('- Journal entries: ${syncStatus.entryCount}')
    ..writeln('- Journal conflicts: ${syncStatus.conflictCount}')
    ..writeln('- Receipts missing: ${treasurySummary.receiptsMissingCount}')
    ..writeln(
      '- Purchase cost total: ${treasurySummary.purchaseCostTotal.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Reorder estimated spend: ${treasurySummary.reorderEstimatedSpend.toStringAsFixed(2)}',
    )
    ..writeln(
      '- Linked finance IDs: ${treasurySummary.linkedFinanceIdCount}',
    )
    ..writeln(
      '- Broken equipment count: ${treasurySummary.brokenEquipmentCount}',
    )
    ..writeln(
      '- Repair replacement value total: ${treasurySummary.repairReplacementValueTotal.toStringAsFixed(2)}',
    )
    ..writeln()
    ..writeln('## Summary cards');

  for (final card in snapshot.summaryCards) {
    buffer
      ..writeln('- ${card.title}: ${card.count}')
      ..writeln('  - ${card.subtitle}');
  }

  if (snapshot.missingFolders.isNotEmpty || snapshot.missingFiles.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Missing setup data');
    for (final folder in snapshot.missingFolders) {
      buffer.writeln('- Folder: $folder');
    }
    for (final file in snapshot.missingFiles) {
      buffer.writeln('- File: $file');
    }
  }

  return buffer.toString();
}
