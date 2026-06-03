import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/meeting_folder_service.dart';

final meetingFolderServiceProvider = Provider<MeetingFolderService>((ref) {
  return MeetingFolderService();
});

final meetingWorkspaceProvider = FutureProvider<MeetingWorkspaceSnapshot>((
  ref,
) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.loadWorkspace();
});

final meetingDashboardSnapshotProvider =
    FutureProvider<MeetingDashboardSnapshot>((ref) {
      final service = ref.watch(meetingFolderServiceProvider);
      return service.loadDashboardSnapshot();
    });

final meetingListRowsProvider = FutureProvider<List<MeetingListRow>>((ref) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.listMeetingRows();
});

final meetingMeetingsProvider = FutureProvider<List<MeetingRecord>>((ref) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.listMeetings();
});

final meetingActionsProvider = FutureProvider<List<MeetingActionRecord>>((ref) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.listActions();
});

final meetingDecisionsProvider = FutureProvider<List<MeetingDecisionRecord>>((
  ref,
) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.listDecisions();
});

final meetingFollowUpsProvider = FutureProvider<List<MeetingFollowUpRecord>>((
  ref,
) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.listFollowUps();
});

final meetingTemplatesProvider = FutureProvider<MeetingTemplatesSnapshot>((
  ref,
) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.loadTemplates();
});

final meetingOmegaHubProvider = FutureProvider<MeetingOmegaHubSnapshot>((ref) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.loadOmegaHub();
});

final meetingMasterIndexProvider = FutureProvider<MeetingMasterIndexSnapshot>((
  ref,
) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.loadMasterIndexPreview();
});

final meetingLatestMeetingProvider = FutureProvider<MeetingRecord?>((ref) {
  final service = ref.watch(meetingFolderServiceProvider);
  return service.getLatestMeeting();
});

final meetingLatestBundleReviewProvider =
    FutureProvider.family<MeetingBundleReviewSnapshot?, String>((
      ref,
      meetingId,
    ) {
      final service = ref.watch(meetingFolderServiceProvider);
      return service.loadLatestBundleReview(meetingId);
    });

final meetingStatusSummaryProvider =
    FutureProvider<MeetingStatusSummarySnapshot>((ref) {
      final service = ref.watch(meetingFolderServiceProvider);
      return service.loadStatusSummary();
    });

final meetingDetailProvider =
    FutureProvider.family<MeetingDetailSnapshot, String>((ref, meetingId) {
      final service = ref.watch(meetingFolderServiceProvider);
      return service.readMeeting(meetingId);
    });
