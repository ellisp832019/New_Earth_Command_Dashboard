import 'package:flutter/material.dart';
import 'calm_card.dart';
import '../core/theme/spacing.dart';

/// Compact Top-3 stack for dashboard summaries.
class Top3View extends StatelessWidget {
  final List<Widget> items;

  const Top3View({super.key, required this.items}) : assert(items.length <= 3);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items
          .map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CalmCard(child: w),
            ),
          )
          .toList(),
    );
  }
}
