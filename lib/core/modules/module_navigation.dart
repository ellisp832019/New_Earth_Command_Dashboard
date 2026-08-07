import 'module_manifest.dart';
import '../routing/route_names.dart';

enum ModuleLaunchTarget { home, package }

extension ModuleLaunchTargetLabel on ModuleLaunchTarget {
  String get label {
    switch (this) {
      case ModuleLaunchTarget.home:
        return 'Home';
      case ModuleLaunchTarget.package:
        return 'Package';
    }
  }
}

String modulePackageRoute(ModuleManifest module) {
  return RouteNames.modulePackage(module.id);
}

String? moduleHomeRoute(ModuleManifest module) {
  if (module.routes.isEmpty) {
    return null;
  }

  return module.routes.first;
}

ModuleLaunchTarget moduleLaunchTargetFromStorage(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'home':
      return ModuleLaunchTarget.home;
    case 'package':
    case null:
    default:
      return ModuleLaunchTarget.package;
  }
}

String moduleLaunchTargetToStorage(ModuleLaunchTarget target) {
  return switch (target) {
    ModuleLaunchTarget.home => 'home',
    ModuleLaunchTarget.package => 'package',
  };
}

String moduleLaunchRoute(ModuleManifest module, ModuleLaunchTarget target) {
  return switch (target) {
    ModuleLaunchTarget.home =>
      moduleHomeRoute(module) ?? modulePackageRoute(module),
    ModuleLaunchTarget.package => modulePackageRoute(module),
  };
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
