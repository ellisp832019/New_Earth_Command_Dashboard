import 'package:flutter/material.dart';

import '../models/grant_record.dart';
import '../services/grant_totals_service.dart';

class GrantTotalsHeader extends StatelessWidget {
  final List<GrantRecord> grants;

  const GrantTotalsHeader({
    super.key,
    required this.grants,
  });

  @override
  Widget build(BuildContext context) {
    final totals = GrantTotalsService().calculate(grants);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _TotalChip(label: 'Requested', value: totals.requested),
          _TotalChip(label: 'Pending', value: totals.pending),
          _TotalChip(label: 'Approved', value: totals.approved),
          _TotalChip(label: 'Rejected', value: totals.rejected),
        ],
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final double value;

  const _TotalChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: £${value.toStringAsFixed(0)}'),
    );
  }
}
