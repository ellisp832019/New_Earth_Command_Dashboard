import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScreen(
      title: 'Projects',
      description:
          'Track active New Earth projects, milestones, progress, and next actions.',
      icon: Icons.folder_outlined,
    );
  }
}
