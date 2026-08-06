import 'package:flutter/material.dart';
import '../core/theme/app_colours.dart';
import '../core/theme/spacing.dart';

class CalmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CalmCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColours.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColours.outline),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}
