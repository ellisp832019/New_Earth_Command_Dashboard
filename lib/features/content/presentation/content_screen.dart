import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Content')),
      body: const AppPlaceholderScreen(
        title: 'Content',
        description:
            'Plan LinkedIn posts, website updates, videos, and book ideas.',
        icon: Icons.campaign_outlined,
      ),
    );
  }
}
