import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/meeting_system_controller.dart';
import '../data/meeting_folder_service.dart';

class MeetingNotificationBridge extends ConsumerStatefulWidget {
  const MeetingNotificationBridge({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MeetingNotificationBridge> createState() =>
      _MeetingNotificationBridgeState();
}

class _MeetingNotificationBridgeState
    extends ConsumerState<MeetingNotificationBridge> {
  ProviderSubscription<AsyncValue<MeetingDashboardSnapshot>>?
  _dashboardSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    final service = ref.read(meetingNotificationServiceProvider);

    _dashboardSubscription = ref
        .listenManual<AsyncValue<MeetingDashboardSnapshot>>(
          meetingDashboardSnapshotProvider,
          (previous, next) {
            next.whenData((snapshot) {
              unawaited(service.syncNotifications(snapshot.notifications));
            });
          },
          fireImmediately: true,
        );

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.invalidate(meetingDashboardSnapshotProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _dashboardSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
