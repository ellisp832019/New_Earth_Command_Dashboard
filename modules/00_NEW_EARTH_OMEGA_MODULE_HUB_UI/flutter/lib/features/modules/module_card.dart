import 'package:flutter/material.dart';
import '../../core/modules/module_manifest.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({super.key, required this.module, required this.onOpen});

  final ModuleManifest module;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(module.name, style: Theme.of(context).textTheme.titleMedium)),
                Chip(label: Text(module.status.label)),
              ],
            ),
            const SizedBox(height: 8),
            Text(module.category, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Text(module.description, maxLines: 3, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                Text('v${module.version}'),
                const Spacer(),
                Text(module.dockable ? 'Dockable' : 'Page only'),
                const SizedBox(width: 12),
                FilledButton(onPressed: onOpen, child: const Text('Open')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
