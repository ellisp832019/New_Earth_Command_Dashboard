import 'dart:convert';
import 'dart:io';

import '../models/grant_record.dart';
import 'grant_repository.dart';

class JsonGrantRepository implements GrantRepository {
  final String trackerPath;

  JsonGrantRepository({required this.trackerPath});

  @override
  Future<List<GrantRecord>> loadGrants() async {
    final file = File(trackerPath);
    if (!await file.exists()) {
      return [];
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final grants = decoded['grants'] as List<dynamic>? ?? [];

    return grants
        .map((item) => GrantRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveGrants(List<GrantRecord> grants) async {
    final file = File(trackerPath);
    await file.parent.create(recursive: true);

    final payload = {
      'version': '1.0.0',
      'updated': DateTime.now().toIso8601String(),
      'grants': grants.map((grant) => grant.toJson()).toList(),
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
  }

  @override
  Future<void> addGrant(GrantRecord grant) async {
    final grants = await loadGrants();
    grants.add(grant);
    await saveGrants(grants);
  }

  @override
  Future<void> updateGrant(GrantRecord grant) async {
    final grants = await loadGrants();
    final index = grants.indexWhere((item) => item.id == grant.id);

    if (index == -1) {
      grants.add(grant);
    } else {
      grants[index] = grant;
    }

    await saveGrants(grants);
  }

  @override
  Future<void> archiveGrant(String grantId) async {
    final grants = await loadGrants();
    final filtered = grants.where((grant) => grant.id != grantId).toList();
    await saveGrants(filtered);
  }
}
