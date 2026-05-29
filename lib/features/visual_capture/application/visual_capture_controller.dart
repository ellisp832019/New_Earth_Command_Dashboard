import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/visual_capture_folder_service.dart';

final visualCaptureFolderServiceProvider = Provider<VisualCaptureFolderService>(
  (ref) {
    return VisualCaptureFolderService();
  },
);

final visualCaptureWorkspaceProvider =
    FutureProvider<VisualCaptureWorkspaceSnapshot>((ref) {
      final service = ref.watch(visualCaptureFolderServiceProvider);
      return service.loadWorkspace();
    });
