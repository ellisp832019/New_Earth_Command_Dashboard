import 'grant_status.dart';
import 'readiness_score.dart';

class GrantRecord {
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

  factory GrantRecord.fromJson(Map<String, dynamic> json) {
    return GrantRecord(
      id: json['id'] ?? '',
      grantName: json['grant_name'] ?? '',
      project: json['project'] ?? '',
      fundingBody: json['funding_body'] ?? '',
      fundingType: json['funding_type'] ?? '',
      amountRequested: (json['amount_requested'] ?? 0).toDouble(),
      matchFundingRequired: json['match_funding_required'] ?? '',
      status: GrantStatusLabel.fromLabel(json['status'] ?? 'Idea'),
      deadline: json['deadline'] ?? 'TBC',
      submissionDate: json['submission_date'],
      decisionDate: json['decision_date'],
      priority: json['priority'] ?? 'Medium',
      owner: json['owner'] ?? '',
      nextAction: json['next_action'] ?? '',
      riskLevel: json['risk_level'] ?? 'Medium',
      readinessScore: ReadinessScore.fromJson(json['readiness_score'] ?? {}),
      folderPath: json['folder_path'] ?? '',
      notes: json['notes'] ?? '',
      tags: List<String>.from(json['tags'] ?? const []),
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
}
