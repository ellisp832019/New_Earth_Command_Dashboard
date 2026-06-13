import 'package:flutter/material.dart';
import '../../core/modules/module_manifest.dart';

class ModulePermissionsScreen extends StatelessWidget {
  const ModulePermissionsScreen({super.key, required this.module});

  final ModuleManifest module;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${module.name} Permissions')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: module.permissions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final permission = module.permissions[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(permission.label),
              subtitle: Text(permission.description.isEmpty ? permission.state.label : permission.description),
              trailing: DropdownButton<String>(
                value: permission.state.label,
                items: const [
                  DropdownMenuItem(value: 'Disabled', child: Text('Disabled')),
                  DropdownMenuItem(value: 'Ask every time', child: Text('Ask every time')),
                  DropdownMenuItem(value: 'Allowed', child: Text('Allowed')),
                ],
                onChanged: (_) {},
              ),
            ),
          );
        },
      ),
    );
  }
}
