import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: const AppPlaceholderScreen(
        title: 'Inbox',
        description: 'Process quick captured ideas and notes.',
        icon: Icons.inbox_outlined,
      ),
    );
  }
}
