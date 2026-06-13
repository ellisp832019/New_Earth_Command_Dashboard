import 'package:flutter/material.dart';
import '../../core/modules/module_manifest.dart';

class ModuleHealthPanel extends StatelessWidget {
  const ModuleHealthPanel({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _row('Runtime', 'Not connected yet'),
            _row('Backend', 'Not implemented'),
            _row('Last check', 'Placeholder'),
            _row('Action needed', module.status.label),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
