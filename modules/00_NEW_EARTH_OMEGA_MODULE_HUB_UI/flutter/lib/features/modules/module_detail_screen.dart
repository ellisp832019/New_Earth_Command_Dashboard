import 'package:flutter/material.dart';
import '../../core/modules/module_manifest.dart';
import 'module_health_panel.dart';
import 'module_permissions_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(module.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(module.description, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(module.category)),
              Chip(label: Text(module.status.label)),
              Chip(label: Text('v${module.version}')),
              Chip(label: Text('Dock: ${module.defaultDockPosition.label}')),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              title: const Text('Omega OS Record'),
              subtitle: Text(module.omegaOsPath),
              trailing: const Icon(Icons.folder_open),
            ),
          ),
          const SizedBox(height: 16),
          ModuleHealthPanel(module: module),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Permissions'),
              subtitle: Text('${module.permissions.length} requested permissions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ModulePermissionsScreen(module: module)),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.view_sidebar),
              title: const Text('Dock Options'),
              subtitle: Text(module.dockable ? 'Can mount in dashboard dock zones.' : 'Not dockable.'),
              trailing: FilledButton(onPressed: () {}, child: const Text('Mount placeholder')),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.article),
              title: Text('Logs'),
              subtitle: Text('No live logs yet. Backend integration comes later.'),
            ),
          ),
        ],
      ),
    );
  }
}
