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
    final inboxSnapshot = VisualCaptureInboxSnapshot(
      inboxPath:
          'D:/NEW_EARTH_OMEGA_OS_PACK/19_VISUAL_RECORDS_AND_CAPTURE/14_TEMP_UPLOADS_AND_INBOX',
      indexPath:
          'D:/NEW_EARTH_OMEGA_OS_PACK/19_VISUAL_RECORDS_AND_CAPTURE/00_VISUAL_DASHBOARD/visual_capture_index.csv',
      items: const [
        VisualCaptureInboxItem(
          captureId: 'VC-20260529-00000001',
          sourcePath: 'local_import',
          filePath:
              'D:/NEW_EARTH_OMEGA_OS_PACK/19_VISUAL_RECORDS_AND_CAPTURE/14_TEMP_UPLOADS_AND_INBOX/vc-20260529-00000001.jpg',
          captureType: 'receipt',
          project: 'MicroGrow',
          status: 'inbox',
          dateAdded: '2026-05-29T12:00:00.000Z',
          notes: 'Ready for review.',
        ),
      ],
      queuedFileCount: 1,
      issues: const <String>[],
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
          visualCaptureWorkspaceProvider.overrideWithValue(
            AsyncData(snapshot),
          ),
          visualCaptureInboxProvider.overrideWithValue(
            AsyncData(inboxSnapshot),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Visual Capture'), findsOneWidget);
    expect(find.text('Folder health'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Source path'), findsOneWidget);
    expect(find.text('Visual Capture is linked and calm'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Inbox summary', skipOffstage: false),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('Inbox summary'), findsOneWidget);
    expect(find.text('1 file in inbox'), findsOneWidget);
    expect(find.text('1 indexed capture'), findsOneWidget);
    expect(find.text('9 capture types'), findsOneWidget);
  });
}
