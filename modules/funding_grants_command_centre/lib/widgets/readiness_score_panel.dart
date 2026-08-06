import 'package:flutter/material.dart';

import '../models/readiness_score.dart';

class ReadinessScorePanel extends StatelessWidget {
  final ReadinessScore score;

  const ReadinessScorePanel({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Readiness Score', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${score.total}/${score.max} - ${score.band}'),
            LinearProgressIndicator(value: score.total / score.max),
            const SizedBox(height: 8),
            Text('Project Summary: ${score.projectSummary}/10'),
            Text('Budget: ${score.budget}/10'),
            Text('Evidence: ${score.evidence}/10'),
            Text('Partner Support: ${score.partnerSupport}/10'),
            Text('Impact Case: ${score.impactCase}/10'),
            Text('Commercial Plan: ${score.commercialPlan}/10'),
            Text('Risk Management: ${score.riskManagement}/10'),
          ],
        ),
      ),
    );
  }
}
