import '../modules/module_manifest.dart';
import '../routing/route_names.dart';

class ModuleWindowService {
  const ModuleWindowService();

  bool get isSupported => false;

  String? launchRouteForModule(ModuleManifest module) {
    if (module.id.trim().isEmpty) {
      return null;
    }

    return RouteNames.modulePackage(module.id);
  }

  Future<void> openModuleWindow(ModuleManifest module) async {
    return;
  }
}
