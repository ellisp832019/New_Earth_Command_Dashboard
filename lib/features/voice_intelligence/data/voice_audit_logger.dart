import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'voice_audit_log_repository.dart';
import 'voice_models.dart';

class VoiceAuditLogger extends Notifier<List<VoiceAuditEntry>> {
  bool _hasHydrated = false;
  bool _hasDirtyChanges = false;

  @override
  List<VoiceAuditEntry> build() {
    unawaited(_hydratePersistedLog());
    return const <VoiceAuditEntry>[];
  }

  List<VoiceAuditEntry> get entries => state;

  void record(VoiceAuditEntry entry) {
    state = <VoiceAuditEntry>[entry, ...state];
    _hasDirtyChanges = true;
    _persistState();
  }

  void clear() {
    state = const <VoiceAuditEntry>[];
    _hasDirtyChanges = true;
    _clearPersistedState();
  }

  void removeById(String id) {
    state = state.where((entry) => entry.id != id).toList(growable: false);
    _hasDirtyChanges = true;
    _persistState();
  }

  Future<void> _hydratePersistedLog() async {
    if (_hasHydrated) {
      return;
    }

    _hasHydrated = true;
    final repository = VoiceAuditLogRepository(ref.read(appDatabaseProvider));
    final payloadJson = await repository.loadPersistedLogPayload();
    if (payloadJson == null || _hasDirtyChanges) {
      return;
    }

    final decoded = repository.decodePayload(payloadJson);
    state = _entriesFromJson(decoded);
    _hasDirtyChanges = false;
  }

  void _persistState() {
    unawaited(_savePersistedLog(state));
  }

  void _clearPersistedState() {
    unawaited(() async {
      final repository = VoiceAuditLogRepository(ref.read(appDatabaseProvider));
      await repository.clearPersistedLog();
    }());
  }

  Future<void> _savePersistedLog(List<VoiceAuditEntry> currentEntries) async {
    final repository = VoiceAuditLogRepository(ref.read(appDatabaseProvider));
    await repository.savePersistedLogPayload(
      repository.encodePayload(<String, dynamic>{
        'entries': currentEntries.map(_entryToJson).toList(growable: false),
      }),
    );
  }

  List<VoiceAuditEntry> _entriesFromJson(Map<String, dynamic> json) {
    final entries = json['entries'];
    if (entries is! List) {
      return const <VoiceAuditEntry>[];
    }

    return entries
        .whereType<Map>()
        .map((entry) => _entryFromJson(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }

  Map<String, dynamic> _entryToJson(VoiceAuditEntry entry) {
    return <String, dynamic>{
      'id': entry.id,
      'timestamp': entry.timestamp.toIso8601String(),
      'section': entry.section,
      'userText': entry.userText,
      'intent': entry.intent,
      'safetyDecision': <String, dynamic>{
        'allowed': entry.safetyDecision.allowed,
        'riskLevel': entry.safetyDecision.riskLevel.name,
        'requiresConfirmation': entry.safetyDecision.requiresConfirmation,
        'reason': entry.safetyDecision.reason,
      },
      'resultSummary': entry.resultSummary,
    };
  }

  VoiceAuditEntry _entryFromJson(Map<String, dynamic> json) {
    final safetyDecisionJson = json['safetyDecision'];
    final safetyDecisionMap = safetyDecisionJson is Map
        ? Map<String, dynamic>.from(safetyDecisionJson)
        : const <String, dynamic>{};
    final riskLevelName = safetyDecisionMap['riskLevel']?.toString() ?? 'low';
    final riskLevel = VoiceRiskLevel.values.firstWhere(
      (candidate) => candidate.name == riskLevelName,
      orElse: () => VoiceRiskLevel.low,
    );

    return VoiceAuditEntry(
      id:
          json['id']?.toString() ??
          'voice-audit-${DateTime.now().millisecondsSinceEpoch}',
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      section: json['section']?.toString() ?? 'Voice',
      userText: json['userText']?.toString() ?? '',
      intent: json['intent']?.toString() ?? 'voice.unknown',
      safetyDecision: SafetyDecision(
        allowed: safetyDecisionMap['allowed'] == true,
        riskLevel: riskLevel,
        requiresConfirmation: safetyDecisionMap['requiresConfirmation'] == true,
        reason: safetyDecisionMap['reason']?.toString() ?? '',
      ),
      resultSummary: json['resultSummary']?.toString() ?? '',
    );
  }
}
