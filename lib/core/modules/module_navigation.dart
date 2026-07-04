import 'module_manifest.dart';
import '../routing/route_names.dart';

String modulePackageRoute(ModuleManifest module) {
  return RouteNames.modulePackage(module.id);
}

String? moduleHomeRoute(ModuleManifest module) {
  if (module.routes.isEmpty) {
    return null;
  }

  return module.routes.first;
}

bool moduleMatchesPath(ModuleManifest module, String path) {
  final currentPath = path.trim();
  if (currentPath.isEmpty) {
    return false;
  }

  for (final route in module.routes) {
    final normalizedRoute = route.trim();
    if (normalizedRoute.isEmpty) {
      continue;
    }

    if (currentPath == normalizedRoute ||
        currentPath.startsWith('$normalizedRoute/')) {
      return true;
    }
  }

  final packageRoute = modulePackageRoute(module);
  if (currentPath == packageRoute || currentPath.startsWith('$packageRoute/')) {
    return true;
  }

  return false;
}

ModuleManifest? moduleForPath(Iterable<ModuleManifest> modules, String path) {
  for (final module in modules) {
    if (moduleMatchesPath(module, path)) {
      return module;
    }
  }

  return null;
}
