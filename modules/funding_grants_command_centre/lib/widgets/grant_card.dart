import 'package:flutter/material.dart';

import '../models/grant_record.dart';
import '../models/grant_status.dart';

class GrantCard extends StatelessWidget {
  final GrantRecord grant;

  const GrantCard({
    super.key,
    required this.grant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ListTile(
        title: Text(grant.grantName),
        subtitle: Text('${grant.project} • ${grant.status.label}\nNext: ${grant.nextAction}'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('£${grant.amountRequested.toStringAsFixed(0)}'),
            Text('${grant.readinessScore.total}/70'),
          ],
        ),
      ),
    );
  }
}
