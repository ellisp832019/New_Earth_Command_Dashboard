import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DesktopStartupBackdrop extends StatelessWidget {
  const DesktopStartupBackdrop({super.key, required this.child});

  final Widget child;

  bool get _showBackdrop {
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

  @override
  Widget build(BuildContext context) {
    if (!_showBackdrop) {
      return child;
    }

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF050B0E)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/branding/new_earth_command_dashboard_13_desktop_startup_background.png',
            fit: BoxFit.cover,
          ),
          const ColoredBox(color: Color(0xA6050B0E)),
          child,
        ],
      ),
    );
  }
}
