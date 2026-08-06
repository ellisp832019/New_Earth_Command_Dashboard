import 'dart:convert';

import '../../../core/database/app_database.dart';

class VoiceConversationThreadRepository {
  VoiceConversationThreadRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  static const String _threadId = 'voice-shared-thread';

  Future<String?> loadPersistedThreadPayload() async {
    final row = await (_database.select(
      _database.voiceConversationThreads,
    )..where((table) => table.threadId.equals(_threadId))).getSingleOrNull();

    return row?.payloadJson;
  }

  Future<void> savePersistedThreadPayload(String payloadJson) async {
    final timestamp = _now();

    await _database
        .into(_database.voiceConversationThreads)
        .insertOnConflictUpdate(
          VoiceConversationThreadsCompanion.insert(
            threadId: _threadId,
            payloadJson: payloadJson,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
  }

  Future<void> clearPersistedThread() async {
    await (_database.delete(
      _database.voiceConversationThreads,
    )..where((table) => table.threadId.equals(_threadId))).go();
  }

  Map<String, dynamic> decodePayload(String payloadJson) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Voice thread payload was not a JSON object.');
    }

    return decoded;
  }

  String encodePayload(Map<String, dynamic> payload) {
    return jsonEncode(payload);
  }
}
