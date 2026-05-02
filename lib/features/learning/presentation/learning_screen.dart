import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning')),
      body: const AppPlaceholderScreen(
        title: 'Learning',
        description: 'Track skills that help build New Earth.',
        icon: Icons.school_outlined,
      ),
    );
  }
}
