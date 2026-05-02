import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const AppPlaceholderScreen(
        title: 'Settings',
        description: 'Configure the dashboard.',
        icon: Icons.settings_outlined,
      ),
    );
  }
}
