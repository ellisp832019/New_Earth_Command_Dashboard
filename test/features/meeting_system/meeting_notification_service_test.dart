import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:new_earth_command_dashboard/features/meeting_system/application/meeting_notification_service.dart';
import 'package:new_earth_command_dashboard/features/meeting_system/data/meeting_folder_service.dart';

void main() {
  group('MeetingNotificationHistoryStore', () {
    test('persists sent notification ids', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'meeting_notification_store_',
      );
      final store = MeetingNotificationHistoryStore(
        File(path.join(tempDir.path, 'history.json')),
      );

      await store.markShown('soon_meeting_1');
      await store.markShown('starting_meeting_2');

      final shown = await store.loadShownIds();
      expect(shown, contains('soon_meeting_1'));
      expect(shown, contains('starting_meeting_2'));
    });
  });

  group('MeetingNotificationService', () {
    test('shows only unseen notifications once', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'meeting_notification_service_',
      );
      final store = MeetingNotificationHistoryStore(
        File(path.join(tempDir.path, 'history.json')),
      );
      final client = _FakeMeetingNotificationClient();
      final service = MeetingNotificationService(
        client: client,
        historyStore: store,
        enabled: true,
      );

      final notifications = <MeetingNotificationRecord>[
        _notification(
          id: 'soon_1',
          meetingId: 'meeting-1',
          title: 'Meeting in 15 min',
        ),
        _notification(
          id: 'starting_1',
          meetingId: 'meeting-2',
          title: 'Meeting starting now',
        ),
      ];

      await service.syncNotifications(notifications);
      expect(client.shownIds, ['soon_1', 'starting_1']);

      await service.syncNotifications(notifications);
      expect(client.shownIds, ['soon_1', 'starting_1']);

      await service.syncNotifications([
        ...notifications,
        _notification(
          id: 'soon_2',
          meetingId: 'meeting-3',
          title: 'Meeting in 30 min',
        ),
      ]);
      expect(client.shownIds, ['soon_1', 'starting_1', 'soon_2']);
    });
  });
}

class _FakeMeetingNotificationClient implements MeetingNotificationClient {
  final List<String> shownIds = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> show(MeetingNotificationRecord notification) async {
    shownIds.add(notification.id);
  }
}

MeetingNotificationRecord _notification({
  required String id,
  required String meetingId,
  required String title,
}) {
  return MeetingNotificationRecord(
    id: id,
    meetingId: meetingId,
    title: title,
    message: 'Body for $title',
    severity: 'info',
    meetingDate: '2026-06-04',
    meetingTime: '09:30',
    myTimeLabel: '10:30',
    timezoneLabel: 'UTC+00:00',
    createdAt: '2026-06-04T09:00:00.000Z',
    actionLabel: 'Open meeting',
  );
}
