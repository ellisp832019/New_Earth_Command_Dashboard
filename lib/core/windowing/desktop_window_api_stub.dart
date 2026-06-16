import 'package:flutter/widgets.dart';

class DesktopWindowApi {
  static bool get isSupported => false;

  static Future<void> initialize() async {}

  static Future<void> waitUntilReadyToShow({
    required Size size,
    bool center = true,
    bool titleBarHidden = true,
    bool skipTaskbar = false,
    bool backgroundColorTransparent = true,
  }) async {}

  static Future<void> show() async {}

  static Future<void> hide() async {}

  static Future<void> maximize() async {}

  static Future<void> minimize() async {}

  static Future<void> restore() async {}

  static Future<void> close() async {}

  static Future<void> destroy() async {}

  static Future<void> setPreventClose(bool value) async {}

  static Future<void> focus() async {}

  static Future<bool> isMaximized() async => false;
}

class DesktopDragToMoveArea extends StatelessWidget {
  const DesktopDragToMoveArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
