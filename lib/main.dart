import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/windowing/desktop_presence_controller.dart';
import 'core/windowing/desktop_window_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (DesktopWindowApi.isSupported) {
    await DesktopWindowApi.initialize();
    await DesktopWindowApi.waitUntilReadyToShow(
      size: const Size(1280, 720),
      center: true,
      titleBarHidden: true,
      skipTaskbar: false,
      backgroundColorTransparent: true,
    );
    await DesktopPresenceController.instance.initialize();
  }

  runApp(const ProviderScope(child: NewEarthCommandDashboardApp()));
}
