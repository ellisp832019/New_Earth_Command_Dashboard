import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';

void main() {
  test('voice conversation context exposes stable thread labels', () {
    const context = VoiceConversationContext(
      label: 'MicroGrow · Project · Dashboard voice workflow',
      summary: 'Continuing the MicroGrow project thread.',
      type: VoiceCommandType.project,
      projectName: 'MicroGrow',
      title: 'Dashboard voice workflow',
      transcript: 'Project: Create a project for the dashboard voice workflow',
      entryCount: 2,
    );

    expect(context.threadScopeLabel, 'MicroGrow · Project');
    expect(context.latestEntryLabel, 'Dashboard voice workflow');
  });

  test('voice conversation context falls back to transcript when needed', () {
    const context = VoiceConversationContext(
      label: 'Task',
      summary: 'Starting a new task thread.',
      type: VoiceCommandType.task,
      transcript: 'Task: Review the dashboard cards',
      entryCount: 1,
    );

    expect(context.threadScopeLabel, 'Task');
    expect(context.latestEntryLabel, 'Task: Review the dashboard cards');
  });
}
