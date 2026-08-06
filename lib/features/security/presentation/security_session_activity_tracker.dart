import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/security_session_controller.dart';

class SecuritySessionActivityTracker extends ConsumerStatefulWidget {
  const SecuritySessionActivityTracker({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SecuritySessionActivityTracker> createState() =>
      _SecuritySessionActivityTrackerState();
}

class _SecuritySessionActivityTrackerState
    extends ConsumerState<SecuritySessionActivityTracker> {
  bool _keyboardHandlerRegistered = false;

  @override
  void dispose() {
    if (_keyboardHandlerRegistered) {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
    super.dispose();
  }

  void _markActivity() {
    ref.read(securitySessionProvider.notifier).recordActivity();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _markActivity();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_keyboardHandlerRegistered) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
      _keyboardHandlerRegistered = true;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _markActivity(),
      onPointerMove: (_) => _markActivity(),
      onPointerSignal: (_) => _markActivity(),
      onPointerUp: (_) => _markActivity(),
      onPointerCancel: (_) => _markActivity(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _markActivity(),
        onTapUp: (_) => _markActivity(),
        onTapCancel: _markActivity,
        onPanDown: (_) => _markActivity(),
        onPanStart: (_) => _markActivity(),
        child: widget.child,
      ),
    );
  }
}
