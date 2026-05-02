import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class WellbeingScreen extends StatelessWidget {
  const WellbeingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wellbeing')),
      body: const AppPlaceholderScreen(
        title: 'Wellbeing',
        description: 'Check energy, mood, stress, and balance.',
        icon: Icons.self_improvement_outlined,
      ),
    );
  }
}
