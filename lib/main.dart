import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'app.dart';
import 'core/windowing/desktop_presence_controller.dart';
import 'core/windowing/desktop_window_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (DesktopWindowApi.isSupported) {
    try {
      await hotKeyManager.unregisterAll();
      await DesktopWindowApi.initialize();
      await DesktopWindowApi.waitUntilReadyToShow(
        size: const Size(1280, 720),
        center: true,
        titleBarHidden: true,
        skipTaskbar: false,
        backgroundColorTransparent: true,
      );
      await DesktopPresenceController.instance.initialize();
    } on MissingPluginException catch (error) {
      debugPrint('Desktop shell plugins were unavailable at startup: $error');
    }
  }

  runApp(const ProviderScope(child: NewEarthCommandDashboardApp()));
}
