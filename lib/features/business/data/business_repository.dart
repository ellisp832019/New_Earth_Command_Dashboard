import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class BusinessListItem {
  const BusinessListItem({required this.item, this.projectName});

  final BusinessOpportunity item;
  final String? projectName;
}

class BusinessRepository {
  BusinessRepository(this._database, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _now;

  static const Map<String, String> _legacyTypeAliases = {
    'Other': 'Business Idea',
  };

  static const Map<String, String> _legacyStatusAliases = {
    'Contacted': 'Follow-up Needed',
    'Negotiating': 'Waiting',
    'Won': 'Accepted',
    'Lost': 'Rejected',
  };

  Future<List<BusinessListItem>> getItems() async {
    final items =
        await (_database.select(_database.businessOpportunities)
              ..where((table) => table.isArchived.equals(false))
              ..orderBy([
                (table) => OrderingTerm.desc(table.updatedAt),
                (table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();

    if (items.isEmpty) {
      return const [];
    }

    final normalizedItems = <BusinessOpportunity>[];
    for (final item in items) {
      normalizedItems.add(await _normalizeStoredItem(item));
    }

    final projectIds = normalizedItems
        .map((item) => item.projectId)
        .whereType<String>()
        .toSet()
        .toList();

    final projects = projectIds.isEmpty
        ? const <Project>[]
        : await (_database.select(
            _database.projects,
          )..where((table) => table.projectId.isIn(projectIds))).get();

    final projectNames = {
      for (final project in projects) project.projectId: project.name,
    };

    return normalizedItems
        .map(
          (item) => BusinessListItem(
            item: item,
            projectName: item.projectId == null
                ? null
                : projectNames[item.projectId],
          ),
        )
        .toList();
  }

  Future<BusinessOpportunity> createItem({
    required String name,
    String? projectId,
    String? type,
    String status = 'Researching',
    String? companyOrContact,
    DateTime? deadline,
    String? nextAction,
    DateTime? followUpDate,
    String? relatedDocumentLink,
    String? notes,
  }) async {
    final timestamp = _now();
    final businessOpportunityId = 'business-${_uuid.v4()}';
    final normalizedStatus = _normalizeStatus(status);

    await _database
        .into(_database.businessOpportunities)
        .insert(
          BusinessOpportunitiesCompanion.insert(
            businessOpportunityId: businessOpportunityId,
            name: name.trim(),
            projectId: Value(projectId),
            type: Value(_normalizeText(type)),
            status: Value(normalizedStatus),
            companyOrContact: Value(_normalizeText(companyOrContact)),
            deadline: Value(_dateOnlyOrNull(deadline)),
            nextAction: Value(_normalizeText(nextAction)),
            followUpDate: Value(_dateOnlyOrNull(followUpDate)),
            relatedDocumentLink: Value(_normalizeText(relatedDocumentLink)),
            notes: Value(_normalizeText(notes)),
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );

    return getById(businessOpportunityId);
  }

  Future<BusinessOpportunity> getById(String businessOpportunityId) {
    return (_database.select(_database.businessOpportunities)..where(
          (table) => table.businessOpportunityId.equals(businessOpportunityId),
        ))
        .getSingle()
        .then(_normalizeStoredItem);
  }

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  DateTime? _dateOnlyOrNull(DateTime? value) {
    if (value == null) {
      return null;
    }

    return DateTime(value.year, value.month, value.day);
  }

  Future<BusinessOpportunity> updateItem({
    required String businessOpportunityId,
    required String name,
    String? projectId,
    String? type,
    String status = 'Researching',
    String? companyOrContact,
    DateTime? deadline,
    String? nextAction,
    DateTime? followUpDate,
    String? relatedDocumentLink,
    String? notes,
  }) async {
    final timestamp = _now();
    final normalizedType = _normalizeType(type);
    final normalizedStatus = _normalizeStatus(status);

    await (_database.update(_database.businessOpportunities)..where(
          (table) => table.businessOpportunityId.equals(businessOpportunityId),
        ))
        .write(
          BusinessOpportunitiesCompanion(
            name: Value(name.trim()),
            projectId: Value(projectId),
            type: Value(normalizedType),
            status: Value(normalizedStatus),
            companyOrContact: Value(_normalizeText(companyOrContact)),
            deadline: Value(_dateOnlyOrNull(deadline)),
            nextAction: Value(_normalizeText(nextAction)),
            followUpDate: Value(_dateOnlyOrNull(followUpDate)),
            relatedDocumentLink: Value(_normalizeText(relatedDocumentLink)),
            notes: Value(_normalizeText(notes)),
            updatedAt: Value(timestamp),
          ),
        );

    return getById(businessOpportunityId);
  }

  Future<BusinessOpportunity> _normalizeStoredItem(
    BusinessOpportunity item,
  ) async {
    final normalizedType = _normalizeType(item.type);
    final normalizedStatus = _normalizeStatus(item.status);

    if (normalizedType == item.type && normalizedStatus == item.status) {
      return item;
    }

    await (_database.update(_database.businessOpportunities)..where(
          (table) =>
              table.businessOpportunityId.equals(item.businessOpportunityId),
        ))
        .write(
          BusinessOpportunitiesCompanion(
            type: Value(normalizedType),
            status: Value(normalizedStatus),
            updatedAt: Value(_now()),
          ),
        );

    return (_database.select(_database.businessOpportunities)..where(
          (table) =>
              table.businessOpportunityId.equals(item.businessOpportunityId),
        ))
        .getSingle();
  }

  String? _normalizeType(String? value) {
    final trimmed = _normalizeText(value);
    if (trimmed == null) {
      return null;
    }

    return _legacyTypeAliases[trimmed] ?? trimmed;
  }

  String _normalizeStatus(String value) {
    final trimmed = value.trim();
    return _legacyStatusAliases[trimmed] ?? trimmed;
  }
}
