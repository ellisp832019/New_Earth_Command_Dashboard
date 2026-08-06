import 'dart:convert';

enum AssetChangeAction { create, update, delete }

extension AssetChangeActionCodec on AssetChangeAction {
  String get wireName => switch (this) {
        AssetChangeAction.create => 'create',
        AssetChangeAction.update => 'update',
        AssetChangeAction.delete => 'delete',
      };

  static AssetChangeAction fromWireName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'create':
        return AssetChangeAction.create;
      case 'delete':
        return AssetChangeAction.delete;
      case 'update':
      default:
        return AssetChangeAction.update;
    }
  }
}

class AssetChangeJournalEntry {
  const AssetChangeJournalEntry({
    required this.recordId,
    required this.recordType,
    required this.action,
    required this.timestamp,
    required this.machineId,
    required this.userLabel,
    required this.changedFields,
    required this.note,
  });

  static const headers = <String>[
    'record_id',
    'record_type',
    'action',
    'timestamp',
    'machine_id',
    'user_label',
    'changed_fields',
    'note',
  ];

  final String recordId;
  final String recordType;
  final AssetChangeAction action;
  final DateTime timestamp;
  final String machineId;
  final String userLabel;
  final Map<String, String> changedFields;
  final String note;

  Map<String, String> toCsvRow() {
    return <String, String>{
      'record_id': recordId,
      'record_type': recordType,
      'action': action.wireName,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'machine_id': machineId,
      'user_label': userLabel,
      'changed_fields': jsonEncode(changedFields),
      'note': note,
    };
  }

  factory AssetChangeJournalEntry.fromCsvRow(Map<String, String> row) {
    return AssetChangeJournalEntry(
      recordId: (row['record_id'] ?? '').trim(),
      recordType: (row['record_type'] ?? '').trim(),
      action: AssetChangeActionCodec.fromWireName(row['action'] ?? 'update'),
      timestamp: DateTime.tryParse((row['timestamp'] ?? '').trim()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      machineId: (row['machine_id'] ?? '').trim(),
      userLabel: (row['user_label'] ?? '').trim(),
      changedFields: _parseChangedFields(row['changed_fields']),
      note: (row['note'] ?? '').trim(),
    );
  }

  AssetChangeJournalEntry copyWith({
    String? recordId,
    String? recordType,
    AssetChangeAction? action,
    DateTime? timestamp,
    String? machineId,
    String? userLabel,
    Map<String, String>? changedFields,
    String? note,
  }) {
    return AssetChangeJournalEntry(
      recordId: recordId ?? this.recordId,
      recordType: recordType ?? this.recordType,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      machineId: machineId ?? this.machineId,
      userLabel: userLabel ?? this.userLabel,
      changedFields: changedFields ?? this.changedFields,
      note: note ?? this.note,
    );
  }

  static Map<String, String> _parseChangedFields(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return <String, String>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        );
      }
    } on FormatException {
      return <String, String>{};
    }

    return <String, String>{};
  }
}

class AssetChangeConflict {
  const AssetChangeConflict({
    required this.recordId,
    required this.recordType,
    required this.entryCount,
    required this.machineIds,
    required this.lastChangeAt,
  });

  final String recordId;
  final String recordType;
  final int entryCount;
  final List<String> machineIds;
  final DateTime lastChangeAt;

  String get summary {
    final machineCount = machineIds.length;
    final machineLabel = machineCount == 1
        ? '1 machine'
        : '$machineCount machines';
    return '$recordType $recordId changed $entryCount times across $machineLabel.';
  }
}
