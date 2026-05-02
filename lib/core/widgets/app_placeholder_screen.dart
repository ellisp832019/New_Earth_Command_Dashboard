import 'package:flutter/material.dart';

class AppPlaceholderScreen extends StatelessWidget {
  const AppPlaceholderScreen({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(icon, size: 44, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Placeholder for the first app shell. Real data and editing flows will arrive in later tasks.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
