import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: const AppPlaceholderScreen(
        title: 'Journal',
        description:
            'Capture build progress, lessons, decisions, and reflections.',
        icon: Icons.edit_note_outlined,
      ),
    );
  }
}
