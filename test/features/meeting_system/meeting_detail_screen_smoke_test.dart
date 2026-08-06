import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/meeting_system/presentation/meeting_detail_screen.dart';

void main() {
  test('meeting detail screen attachment preview code compiles', () {
    final widget = MeetingDetailScreen(meetingId: 'demo');
    expect(widget, isA<MeetingDetailScreen>());
  });
}
