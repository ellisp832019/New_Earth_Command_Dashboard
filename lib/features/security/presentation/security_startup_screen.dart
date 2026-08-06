import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/widgets/desktop_startup_backdrop.dart';

class SecurityStartupScreen extends StatefulWidget {
  const SecurityStartupScreen({
    super.key,
    this.delay = const Duration(seconds: 2),
  });

  final Duration delay;

  @override
  State<SecurityStartupScreen> createState() => _SecurityStartupScreenState();
}

class _SecurityStartupScreenState extends State<SecurityStartupScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, _openGate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openGate() {
    if (!mounted) {
      return;
    }

    context.go(RouteNames.securityLock);
  }

  @override
  Widget build(BuildContext context) {
    return DesktopStartupBackdrop(
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}
