import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScreen(
      title: 'Tasks',
      description:
          'Manage actions across projects while protecting the Top 3 task rule.',
      icon: Icons.checklist_outlined,
    );
  }
}
