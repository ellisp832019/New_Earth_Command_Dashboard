class ReadinessScore {
  const ReadinessScore({
    required this.projectSummary,
    required this.budget,
    required this.evidence,
    required this.partnerSupport,
    required this.impactCase,
    required this.commercialPlan,
    required this.riskManagement,
  });

  final int projectSummary;
  final int budget;
  final int evidence;
  final int partnerSupport;
  final int impactCase;
  final int commercialPlan;
  final int riskManagement;

  int get total =>
      projectSummary +
      budget +
      evidence +
      partnerSupport +
      impactCase +
      commercialPlan +
      riskManagement;

  int get max => 70;

  String get band {
    if (total <= 20) return 'Very weak';
    if (total <= 35) return 'Early draft';
    if (total <= 50) return 'Possible';
    if (total <= 60) return 'Good';
    return 'Strong';
  }

  factory ReadinessScore.fromJson(Map<String, dynamic> json) {
    return ReadinessScore(
      projectSummary: _readInt(json['project_summary']),
      budget: _readInt(json['budget']),
      evidence: _readInt(json['evidence']),
      partnerSupport: _readInt(json['partner_support']),
      impactCase: _readInt(json['impact_case']),
      commercialPlan: _readInt(json['commercial_plan']),
      riskManagement: _readInt(json['risk_management']),
    );
  }

  ReadinessScore copyWith({
    int? projectSummary,
    int? budget,
    int? evidence,
    int? partnerSupport,
    int? impactCase,
    int? commercialPlan,
    int? riskManagement,
  }) {
    return ReadinessScore(
      projectSummary: projectSummary ?? this.projectSummary,
      budget: budget ?? this.budget,
      evidence: evidence ?? this.evidence,
      partnerSupport: partnerSupport ?? this.partnerSupport,
      impactCase: impactCase ?? this.impactCase,
      commercialPlan: commercialPlan ?? this.commercialPlan,
      riskManagement: riskManagement ?? this.riskManagement,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_summary': projectSummary,
      'budget': budget,
      'evidence': evidence,
      'partner_support': partnerSupport,
      'impact_case': impactCase,
      'commercial_plan': commercialPlan,
      'risk_management': riskManagement,
      'total': total,
      'max': max,
      'band': band,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}
