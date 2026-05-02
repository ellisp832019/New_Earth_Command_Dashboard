import 'package:flutter_test/flutter_test.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_model.dart';
import 'package:new_earth_command_dashboard/features/voice_assistant/voice_command_service.dart';

void main() {
  test('voice command service stores history in newest first order', () {
    var minute = 0;
    final service = VoiceCommandService(
      now: () => DateTime(2026, 5, 2, 9, minute++),
    );

    service.addCommand(
      transcript: 'Save this as a task',
      type: VoiceCommandType.task,
    );
    service.addCommand(
      transcript: 'Turn this into a journal entry',
      type: VoiceCommandType.journalEntry,
    );

    final history = service.getHistory();

    expect(history, hasLength(2));
    expect(history.first.transcript, 'Turn this into a journal entry');
    expect(history.last.transcript, 'Save this as a task');
  });

  test('voice command service creates the Codex-safe prompt wrapper', () {
    final service = VoiceCommandService();
    final prompt = service.createCodexPrompt('  Update the dashboard cards  ');

    expect(
      prompt,
      contains('You are working inside the New Earth Dashboard repo.'),
    );
    expect(prompt, contains('User voice command:\nUpdate the dashboard cards'));
    expect(prompt, contains('- Do not delete existing work.'));
    expect(prompt, contains('- Ask for approval before major rewrites.'));
  });
}
