import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart' as wm;

class DesktopWindowApi {
  static bool get isSupported {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.windows ||
      TargetPlatform.macOS ||
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  static Future<void> initialize() => wm.windowManager.ensureInitialized();

  static Future<void> waitUntilReadyToShow({
    required Size size,
    bool center = true,
    bool titleBarHidden = true,
    bool skipTaskbar = false,
    bool backgroundColorTransparent = true,
  }) {
    if (!isSupported) {
      return Future.value();
    }

    return wm.windowManager.waitUntilReadyToShow(
      wm.WindowOptions(
        size: size,
        center: center,
        titleBarStyle: titleBarHidden
            ? wm.TitleBarStyle.hidden
            : wm.TitleBarStyle.normal,
        skipTaskbar: skipTaskbar,
        backgroundColor: backgroundColorTransparent
            ? Colors.transparent
            : Colors.black,
      ),
      () async {
        await wm.windowManager.show();
        await wm.windowManager.maximize();
        await wm.windowManager.focus();
      },
    );
  }

  static Future<void> show() => wm.windowManager.show();

  static Future<void> hide() => wm.windowManager.hide();

  static Future<void> maximize() => wm.windowManager.maximize();

  static Future<void> minimize() => wm.windowManager.minimize();

  static Future<void> restore() => wm.windowManager.restore();

  static Future<void> close() => wm.windowManager.close();

  static Future<void> destroy() => wm.windowManager.destroy();

  static Future<void> setPreventClose(bool value) =>
      wm.windowManager.setPreventClose(value);

  static Future<void> focus() => wm.windowManager.focus();

  static Future<bool> isMaximized() => wm.windowManager.isMaximized();
}

class DesktopDragToMoveArea extends StatelessWidget {
  const DesktopDragToMoveArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!DesktopWindowApi.isSupported) {
      return child;
    }

    return wm.DragToMoveArea(child: child);
  }
}
