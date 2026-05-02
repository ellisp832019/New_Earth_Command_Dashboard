import 'package:flutter/material.dart';

class TranscriptPreviewCard extends StatelessWidget {
  const TranscriptPreviewCard({
    super.key,
    required this.controller,
    required this.helperText,
  });

  final TextEditingController controller;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transcript Preview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(helperText, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Your spoken command will appear here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
