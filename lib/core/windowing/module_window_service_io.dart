import 'dart:io';

import '../modules/module_manifest.dart';
import '../routing/route_names.dart';

class ModuleWindowService {
  const ModuleWindowService();

  bool get isSupported {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return true;
    }

    return false;
  }

  String? launchRouteForModule(ModuleManifest module) {
    if (module.id.trim().isEmpty) {
      return null;
    }

    return RouteNames.modulePackage(module.id);
  }

  Future<void> openModuleWindow(ModuleManifest module) async {
    if (!isSupported) {
      return;
    }

    final launchRoute = launchRouteForModule(module);
    if (launchRoute == null || launchRoute.isEmpty) {
      return;
    }

    final executable = Platform.resolvedExecutable;
    await Process.start(
      executable,
      <String>['--launch-route=$launchRoute'],
      mode: ProcessStartMode.detached,
      runInShell: false,
    );
  }
}
