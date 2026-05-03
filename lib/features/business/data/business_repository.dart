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

    final projectIds = items
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

    return items
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

    await _database
        .into(_database.businessOpportunities)
        .insert(
          BusinessOpportunitiesCompanion.insert(
            businessOpportunityId: businessOpportunityId,
            name: name.trim(),
            projectId: Value(projectId),
            type: Value(_normalizeText(type)),
            status: Value(status),
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
        .getSingle();
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
}
