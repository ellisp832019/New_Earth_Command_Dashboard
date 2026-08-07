import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'assets_controller.dart';

final assetTreasuryLinkSummaryProvider =
    FutureProvider<AssetTreasuryLinkSummary>((ref) async {
      final workspace = await ref.watch(assetWorkspaceProvider.future);
      if (workspace.assetsRootPath == null) {
        return const AssetTreasuryLinkSummary(
          receiptsMissingCount: 0,
          purchaseCostTotal: 0,
          reorderEstimatedSpend: 0,
          linkedFinanceIdCount: 0,
          brokenEquipmentCount: 0,
          repairReplacementValueTotal: 0,
        );
      }

      final repository = ref.watch(assetRegisterRepositoryProvider);
      final equipmentTable = await ref.watch(
        assetEquipmentRegisterProvider.future,
      );
      final partsTable = await ref.watch(assetPartsRegisterProvider.future);
      final ordersTable = await ref.watch(assetOrdersTrackerProvider.future);
      final maintenanceTable = await ref.watch(
        assetMaintenanceLogProvider.future,
      );

      final equipmentRows = equipmentTable.rows;
      final partsRows = partsTable.rows;
      final brokenRows = repository.filterBrokenRepairEquipment(equipmentRows);

      final receiptsMissingCount = [
        ...equipmentRows.where((row) {
          return _hasMoney(row['purchase_cost']) &&
              !_hasValue(row['receipt_link']);
        }),
        ...ordersTable.rows.where((row) {
          return _hasMoney(row['total_cost']) &&
              !_hasValue(row['receipt_link']);
        }),
      ].length;

      final purchaseCostTotal = _sumMoney(equipmentRows, 'purchase_cost');
      final reorderEstimatedSpend = repository.estimateReorderSpend(partsRows);
      final linkedFinanceIdCount = [
        ...ordersTable.rows.where((row) => _hasValue(row['finance_record_id'])),
        ...maintenanceTable.rows.where(
          (row) => _hasValue(row['linked_finance_record']),
        ),
      ].length;
      final repairReplacementValueTotal = brokenRows.fold<double>(
        0,
        (sum, row) =>
            sum +
            (_parseMoney(row['replacement_value']) ??
                _parseMoney(row['purchase_cost']) ??
                0),
      );

      return AssetTreasuryLinkSummary(
        receiptsMissingCount: receiptsMissingCount,
        purchaseCostTotal: purchaseCostTotal,
        reorderEstimatedSpend: reorderEstimatedSpend.toDouble(),
        linkedFinanceIdCount: linkedFinanceIdCount,
        brokenEquipmentCount: brokenRows.length,
        repairReplacementValueTotal: repairReplacementValueTotal,
      );
    });

class AssetTreasuryLinkSummary {
  const AssetTreasuryLinkSummary({
    required this.receiptsMissingCount,
    required this.purchaseCostTotal,
    required this.reorderEstimatedSpend,
    required this.linkedFinanceIdCount,
    required this.brokenEquipmentCount,
    required this.repairReplacementValueTotal,
  });

  final int receiptsMissingCount;
  final double purchaseCostTotal;
  final double reorderEstimatedSpend;
  final int linkedFinanceIdCount;
  final int brokenEquipmentCount;
  final double repairReplacementValueTotal;
}

bool _hasValue(String? value) {
  return (value ?? '').trim().isNotEmpty;
}

bool _hasMoney(String? value) {
  return _parseMoney(value) != null;
}

double? _parseMoney(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }

  return double.tryParse(trimmed);
}

double _sumMoney(List<Map<String, String>> rows, String field) {
  return rows.fold<double>(
    0,
    (sum, row) => sum + (_parseMoney(row[field]) ?? 0),
  );
}
