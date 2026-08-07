import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart' as wm;
import 'package:tray_manager/tray_manager.dart';

import '../routing/router_keys.dart';
import 'desktop_window_api.dart';

class DesktopPresenceController with TrayListener, wm.WindowListener {
  DesktopPresenceController._();

  static final DesktopPresenceController instance =
      DesktopPresenceController._();

  static const String _trayAwakeTooltip = 'New Earth is awake';
  static const String _traySleepTooltip = 'New Earth is sleeping';
  static const String _trayAssetWindows =
      'windows/runner/resources/new_earth_command_dashboard_tray_icon_v8.ico';
  static const String _trayAssetOther =
      'assets/branding/new_earth_command_dashboard_tray_icon_v8.png';
  static final HotKey _wakeHotKey = HotKey(
    key: PhysicalKeyboardKey.keyW,
    modifiers: const [HotKeyModifier.control, HotKeyModifier.alt],
  );

  bool _initialized = false;
  bool _allowClose = false;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  Stream<String> get messages => _messageController.stream;

  bool get isSupported {
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

  Future<void> initialize() async {
    if (_initialized || !isSupported) {
      return;
    }

    _initialized = true;
    await DesktopWindowApi.setPreventClose(true);
    wm.windowManager.addListener(this);
    trayManager.addListener(this);
    await trayManager.setIcon(_trayIconAsset);
    await trayManager.setToolTip(_trayAwakeTooltip);
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'show_dashboard', label: 'Wake Dashboard'),
          MenuItem(key: 'sleep', label: 'Sleep Quietly'),
          MenuItem.separator(),
          MenuItem(key: 'shutdown', label: 'Exit Completely'),
        ],
      ),
    );
    await hotKeyManager.register(
      _wakeHotKey,
      keyDownHandler: (_) {
        unawaited(openDashboard());
      },
    );
  }

  String get _trayIconAsset {
    return Platform.isWindows ? _trayAssetWindows : _trayAssetOther;
  }

  Future<void> sleep() async {
    if (!isSupported) {
      return;
    }

    _emit('Dashboard is sleeping quietly in the tray.');
    await trayManager.setToolTip(_traySleepTooltip);
    await Future.delayed(const Duration(milliseconds: 350));
    await DesktopWindowApi.hide();
  }

  Future<void> openDashboard() async {
    if (!isSupported) {
      return;
    }

    await DesktopWindowApi.show();
    await DesktopWindowApi.maximize();
    await DesktopWindowApi.focus();
    await trayManager.setToolTip(_trayAwakeTooltip);
  }

  Future<void> requestShutdown() async {
    if (!isSupported) {
      return;
    }

    final context = rootNavigatorKey.currentContext;
    final shouldShutdown = context == null
        ? true
        : await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Exit completely?'),
                    content: const Text(
                      'This will close New Earth Command Dashboard completely. '
                      'Use Sleep Quietly if you just want to tuck it away for later.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Exit Completely'),
                      ),
                    ],
                  );
                },
              ) ??
              false;

    if (!shouldShutdown) {
      return;
    }

    await shutdown();
  }

  Future<void> shutdown() async {
    if (!isSupported) {
      return;
    }

    _allowClose = true;
    try {
      await trayManager.destroy();
    } catch (_) {
      // Best-effort cleanup only.
    }
    await DesktopWindowApi.destroy();
  }

  @override
  void onTrayIconMouseDown() {
    unawaited(openDashboard());
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_dashboard':
        unawaited(openDashboard());
        break;
      case 'sleep':
        unawaited(sleep());
        break;
      case 'shutdown':
        unawaited(requestShutdown());
        break;
    }
  }

  @override
  void onWindowClose() {
    if (_allowClose) {
      return;
    }

    unawaited(sleep());
  }

  @override
  void onWindowMinimize() {
    unawaited(sleep());
  }

  Future<void> dispose() async {
    if (!_initialized) {
      return;
    }

    await hotKeyManager.unregister(_wakeHotKey);
    wm.windowManager.removeListener(this);
    trayManager.removeListener(this);
    await _messageController.close();
    _initialized = false;
  }

  void _emit(String message) {
    if (_messageController.isClosed) {
      return;
    }

    _messageController.add(message);
  }
}
