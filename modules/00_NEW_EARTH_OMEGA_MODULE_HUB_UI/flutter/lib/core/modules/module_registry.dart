import '../../demo/demo_modules.dart';
import 'module_manifest.dart';

class ModuleRegistry {
  ModuleRegistry({List<ModuleManifest>? seed}) : _modules = seed ?? DemoModules.all;

  final List<ModuleManifest> _modules;

  List<ModuleManifest> get all => List.unmodifiable(_modules);

  ModuleManifest? byId(String id) {
    for (final module in _modules) {
      if (module.id == id) return module;
    }
    return null;
  }

  List<ModuleManifest> byCategory(String category) {
    return _modules.where((module) => module.category == category).toList();
  }
}
