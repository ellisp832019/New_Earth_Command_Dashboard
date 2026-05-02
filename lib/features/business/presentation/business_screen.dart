import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_screen.dart';

class BusinessScreen extends StatelessWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business')),
      body: const AppPlaceholderScreen(
        title: 'Business',
        description:
            'Track funding, job applications, partnerships, and opportunities.',
        icon: Icons.handshake_outlined,
      ),
    );
  }
}
