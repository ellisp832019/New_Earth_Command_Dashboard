import '../models/grant_record.dart';

abstract class GrantRepository {
  Future<List<GrantRecord>> loadGrants();
  Future<void> saveGrants(List<GrantRecord> grants);
  Future<void> addGrant(GrantRecord grant);
  Future<void> updateGrant(GrantRecord grant);
  Future<void> archiveGrant(String grantId);
}
