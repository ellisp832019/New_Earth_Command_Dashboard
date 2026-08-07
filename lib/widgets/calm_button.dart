import 'package:flutter/material.dart';
import '../core/theme/app_colours.dart';
import '../core/theme/spacing.dart';

class CalmButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const CalmButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColours.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
