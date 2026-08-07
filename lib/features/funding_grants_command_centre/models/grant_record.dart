import 'grant_status.dart';
import 'readiness_score.dart';

class GrantRecord {
  const GrantRecord({
    required this.id,
    required this.grantName,
    required this.project,
    required this.fundingBody,
    required this.fundingType,
    required this.amountRequested,
    required this.matchFundingRequired,
    required this.status,
    required this.deadline,
    required this.submissionDate,
    required this.decisionDate,
    required this.priority,
    required this.owner,
    required this.nextAction,
    required this.riskLevel,
    required this.readinessScore,
    required this.folderPath,
    required this.notes,
    required this.tags,
  });

  final String id;
  final String grantName;
  final String project;
  final String fundingBody;
  final String fundingType;
  final double amountRequested;
  final String matchFundingRequired;
  final GrantStatus status;
  final String deadline;
  final String? submissionDate;
  final String? decisionDate;
  final String priority;
  final String owner;
  final String nextAction;
  final String riskLevel;
  final ReadinessScore readinessScore;
  final String folderPath;
  final String notes;
  final List<String> tags;

  GrantRecord copyWith({
    String? id,
    String? grantName,
    String? project,
    String? fundingBody,
    String? fundingType,
    double? amountRequested,
    String? matchFundingRequired,
    GrantStatus? status,
    String? deadline,
    String? submissionDate,
    String? decisionDate,
    String? priority,
    String? owner,
    String? nextAction,
    String? riskLevel,
    ReadinessScore? readinessScore,
    String? folderPath,
    String? notes,
    List<String>? tags,
  }) {
    return GrantRecord(
      id: id ?? this.id,
      grantName: grantName ?? this.grantName,
      project: project ?? this.project,
      fundingBody: fundingBody ?? this.fundingBody,
      fundingType: fundingType ?? this.fundingType,
      amountRequested: amountRequested ?? this.amountRequested,
      matchFundingRequired: matchFundingRequired ?? this.matchFundingRequired,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      submissionDate: submissionDate ?? this.submissionDate,
      decisionDate: decisionDate ?? this.decisionDate,
      priority: priority ?? this.priority,
      owner: owner ?? this.owner,
      nextAction: nextAction ?? this.nextAction,
      riskLevel: riskLevel ?? this.riskLevel,
      readinessScore: readinessScore ?? this.readinessScore,
      folderPath: folderPath ?? this.folderPath,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  bool get hasDeadline =>
      deadline.trim().isNotEmpty && deadline.trim() != 'TBC';

  DateTime? get deadlineDate {
    if (!hasDeadline) {
      return null;
    }
    return DateTime.tryParse(deadline.trim());
  }

  factory GrantRecord.fromJson(Map<String, dynamic> json) {
    final readiness = json['readiness_score'];
    return GrantRecord(
      id: _stringValue(json['id']),
      grantName: _stringValue(json['grant_name']),
      project: _stringValue(json['project']),
      fundingBody: _stringValue(json['funding_body']),
      fundingType: _stringValue(json['funding_type']),
      amountRequested: _doubleValue(json['amount_requested']),
      matchFundingRequired: _stringValue(json['match_funding_required']),
      status: GrantStatusLabel.fromLabel(_stringValue(json['status'])),
      deadline: _stringValue(json['deadline'], fallback: 'TBC'),
      submissionDate: _nullableString(json['submission_date']),
      decisionDate: _nullableString(json['decision_date']),
      priority: _stringValue(json['priority'], fallback: 'Medium'),
      owner: _stringValue(json['owner']),
      nextAction: _stringValue(json['next_action']),
      riskLevel: _stringValue(json['risk_level'], fallback: 'Medium'),
      readinessScore: readiness is Map<String, dynamic>
          ? ReadinessScore.fromJson(readiness)
          : const ReadinessScore(
              projectSummary: 0,
              budget: 0,
              evidence: 0,
              partnerSupport: 0,
              impactCase: 0,
              commercialPlan: 0,
              riskManagement: 0,
            ),
      folderPath: _stringValue(json['folder_path']),
      notes: _stringValue(json['notes']),
      tags: _readTags(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grant_name': grantName,
      'project': project,
      'funding_body': fundingBody,
      'funding_type': fundingType,
      'amount_requested': amountRequested,
      'match_funding_required': matchFundingRequired,
      'status': status.label,
      'deadline': deadline,
      'submission_date': submissionDate,
      'decision_date': decisionDate,
      'priority': priority,
      'owner': owner,
      'next_action': nextAction,
      'risk_level': riskLevel,
      'readiness_score': readinessScore.toJson(),
      'folder_path': folderPath,
      'notes': notes,
      'tags': tags,
    };
  }

  static String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static List<String> _readTags(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }
}
