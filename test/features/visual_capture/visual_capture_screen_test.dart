import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_earth_command_dashboard/core/routing/route_names.dart';
import 'package:new_earth_command_dashboard/features/visual_capture/application/visual_capture_controller.dart';
import 'package:new_earth_command_dashboard/features/visual_capture/data/visual_capture_folder_service.dart';
import 'package:new_earth_command_dashboard/features/visual_capture/presentation/visual_capture_screen.dart';

void main() {
  testWidgets('visual capture opens as a first-class route', (tester) async {
    final snapshot = VisualCaptureWorkspaceSnapshot(
      configPath: 'config/local_paths.json',
      visualCaptureRootPath:
          'D:/NEW_EARTH_OMEGA_OS_PACK/19_VISUAL_RECORDS_AND_CAPTURE',
      isReady: true,
      issues: const <String>[],
      requiredFolders: VisualCaptureFolderService.requiredFolders,
      missingFolders: const <String>[],
      missingFiles: const <String>[],
      guidanceNote: 'Connected and calm.',
    );

    final router = GoRouter(
      initialLocation: RouteNames.visualCapture,
      routes: [
        GoRoute(
          path: RouteNames.visualCapture,
          builder: (context, state) => const VisualCaptureScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          visualCaptureWorkspaceProvider.overrideWith((ref) async => snapshot),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Visual Capture'), findsOneWidget);
    expect(find.text('Folder health'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });
}
