class ReadinessScore {
  final int projectSummary;
  final int budget;
  final int evidence;
  final int partnerSupport;
  final int impactCase;
  final int commercialPlan;
  final int riskManagement;

  const ReadinessScore({
    required this.projectSummary,
    required this.budget,
    required this.evidence,
    required this.partnerSupport,
    required this.impactCase,
    required this.commercialPlan,
    required this.riskManagement,
  });

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
      projectSummary: json['project_summary'] ?? 0,
      budget: json['budget'] ?? 0,
      evidence: json['evidence'] ?? 0,
      partnerSupport: json['partner_support'] ?? 0,
      impactCase: json['impact_case'] ?? 0,
      commercialPlan: json['commercial_plan'] ?? 0,
      riskManagement: json['risk_management'] ?? 0,
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
    };
  }
}
