class LaunchpadPhase2Record {
  const LaunchpadPhase2Record({
    required this.id,
    required this.campaignId,
    required this.section,
    required this.title,
    required this.status,
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.secondaryValue,
    required this.notes,
    required this.order,
    this.dueDate,
  });

  final String id;
  final String campaignId;
  final String section;
  final String title;
  final String status;
  final String primaryLabel;
  final String primaryValue;
  final String secondaryLabel;
  final String secondaryValue;
  final String notes;
  final int order;
  final DateTime? dueDate;

  LaunchpadPhase2Record copyWith({
    String? id,
    String? campaignId,
    String? section,
    String? title,
    String? status,
    String? primaryLabel,
    String? primaryValue,
    String? secondaryLabel,
    String? secondaryValue,
    String? notes,
    int? order,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return LaunchpadPhase2Record(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      section: section ?? this.section,
      title: title ?? this.title,
      status: status ?? this.status,
      primaryLabel: primaryLabel ?? this.primaryLabel,
      primaryValue: primaryValue ?? this.primaryValue,
      secondaryLabel: secondaryLabel ?? this.secondaryLabel,
      secondaryValue: secondaryValue ?? this.secondaryValue,
      notes: notes ?? this.notes,
      order: order ?? this.order,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'campaign_id': campaignId,
      'section': section,
      'title': title,
      'status': status,
      'primary_label': primaryLabel,
      'primary_value': primaryValue,
      'secondary_label': secondaryLabel,
      'secondary_value': secondaryValue,
      'notes': notes,
      'order': order,
      'due_date': dueDate?.toIso8601String(),
    };
  }

  factory LaunchpadPhase2Record.fromJson(
    Map<String, dynamic> json, {
    required String campaignIdFallback,
    required String sectionFallback,
  }) {
    return LaunchpadPhase2Record(
      id: _stringValue(json['id']),
      campaignId: _firstNonEmpty([
        _stringValue(json['campaign_id']),
        _stringValue(json['campaignId']),
        campaignIdFallback,
      ]),
      section: _firstNonEmpty([
        _stringValue(json['section']),
        sectionFallback,
      ]),
      title: _stringValue(json['title']),
      status: _firstNonEmpty([_stringValue(json['status']), 'Draft']),
      primaryLabel: _firstNonEmpty([
        _stringValue(json['primary_label']),
        _stringValue(json['primaryLabel']),
      ]),
      primaryValue: _firstNonEmpty([
        _stringValue(json['primary_value']),
        _stringValue(json['primaryValue']),
      ]),
      secondaryLabel: _firstNonEmpty([
        _stringValue(json['secondary_label']),
        _stringValue(json['secondaryLabel']),
      ]),
      secondaryValue: _firstNonEmpty([
        _stringValue(json['secondary_value']),
        _stringValue(json['secondaryValue']),
      ]),
      notes: _stringValue(json['notes']),
      order: _intValue(json['order'], fallback: 0),
      dueDate: _parseDate(json['due_date']) ?? _parseDate(json['dueDate']),
    );
  }
}

String _stringValue(dynamic value) {
  return value?.toString() ?? '';
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

int _intValue(dynamic value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}
