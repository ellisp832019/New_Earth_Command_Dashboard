import 'dart:convert';

import '../../../core/database/app_database.dart';

class VoiceAuditLogRepository {
  VoiceAuditLogRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  static const String _logId = 'voice-audit-log';

  Future<String?> loadPersistedLogPayload() async {
    final row = await (_database.select(
      _database.voiceAuditLogs,
    )..where((table) => table.logId.equals(_logId))).getSingleOrNull();

    return row?.payloadJson;
  }

  Future<void> savePersistedLogPayload(String payloadJson) async {
    final timestamp = _now();

    await _database
        .into(_database.voiceAuditLogs)
        .insertOnConflictUpdate(
          VoiceAuditLogsCompanion.insert(
            logId: _logId,
            payloadJson: payloadJson,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
  }

  Future<void> clearPersistedLog() async {
    await (_database.delete(
      _database.voiceAuditLogs,
    )..where((table) => table.logId.equals(_logId))).go();
  }

  Map<String, dynamic> decodePayload(String payloadJson) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Voice audit payload was not a JSON object.');
    }

    return decoded;
  }

  String encodePayload(Map<String, dynamic> payload) {
    return jsonEncode(payload);
  }
}
