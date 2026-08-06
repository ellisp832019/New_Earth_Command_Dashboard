import 'package:flutter/material.dart';

import '../models/grant_record.dart';
import '../models/grant_status.dart';

class GrantDetailScreen extends StatelessWidget {
  final GrantRecord grant;

  const GrantDetailScreen({
    super.key,
    required this.grant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(grant.grantName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(grant.project, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Funding body: ${grant.fundingBody}'),
          Text('Amount requested: £${grant.amountRequested.toStringAsFixed(0)}'),
          Text('Status: ${grant.status.label}'),
          Text('Deadline: ${grant.deadline}'),
          Text('Priority: ${grant.priority}'),
          Text('Risk: ${grant.riskLevel}'),
          const SizedBox(height: 16),
          Text('Next action', style: Theme.of(context).textTheme.titleMedium),
          Text(grant.nextAction),
          const SizedBox(height: 16),
          Text('Readiness score', style: Theme.of(context).textTheme.titleMedium),
          Text('${grant.readinessScore.total}/${grant.readinessScore.max} - ${grant.readinessScore.band}'),
          const SizedBox(height: 16),
          Text('Omega OS folder', style: Theme.of(context).textTheme.titleMedium),
          SelectableText(grant.folderPath),
          const SizedBox(height: 16),
          Text('Notes', style: Theme.of(context).textTheme.titleMedium),
          Text(grant.notes),
        ],
      ),
    );
  }
}
