import 'package:flutter/material.dart';
import '../../core/modules/module_registry.dart';
import 'module_card.dart';
import 'module_detail_screen.dart';

class ModulesScreen extends StatelessWidget {
  ModulesScreen({super.key, ModuleRegistry? registry}) : registry = registry ?? ModuleRegistry();

  final ModuleRegistry registry;

  @override
  Widget build(BuildContext context) {
    final modules = registry.all;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modules'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Future install'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 420,
            mainAxisExtent: 240,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];
            return ModuleCard(
              module: module,
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ModuleDetailScreen(module: module)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
