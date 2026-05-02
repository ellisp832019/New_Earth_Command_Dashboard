import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScreen(
      title: 'Daily Planner',
      description:
          'Plan the day, hold the main focus, and review what should carry forward.',
      icon: Icons.today_outlined,
    );
  }
}
