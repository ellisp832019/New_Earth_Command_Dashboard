import 'module_category.dart';
import 'module_manifest.dart';

class ModuleRegistry {
  ModuleRegistry({List<ModuleManifest>? seed})
    : _modules = List<ModuleManifest>.from(seed ?? const <ModuleManifest>[]);

  final List<ModuleManifest> _modules;

  List<ModuleManifest> get all => List.unmodifiable(_modules);

  ModuleManifest? byId(String id) {
    for (final module in _modules) {
      if (module.id == id) {
        return module;
      }
    }
    return null;
  }

  List<ModuleManifest> byCategory(ModuleCategory category) {
    return _modules.where((module) => module.category == category).toList();
  }
}
