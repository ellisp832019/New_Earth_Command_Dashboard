import '../modules/module_manifest.dart';
import '../modules/module_navigation.dart';

class ModuleWindowService {
  const ModuleWindowService();

  bool get isSupported => false;

  String? launchRouteForModule(ModuleManifest module) {
    return moduleHomeRoute(module);
  }

  Future<void> openModuleWindow(ModuleManifest module) async {
    return;
  }
}
