import 'voice_command_model.dart';

class VoiceCommandService {
  VoiceCommandService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final List<VoiceCommand> _commands = [];

  List<VoiceCommand> getHistory() {
    return List.unmodifiable(_commands.reversed);
  }

  VoiceCommand addCommand({
    required String transcript,
    required VoiceCommandType type,
  }) {
    final timestamp = _now();
    final command = VoiceCommand(
      id: timestamp.microsecondsSinceEpoch.toString(),
      transcript: transcript.trim(),
      type: type,
      createdAt: timestamp,
    );

    _commands.add(command);
    return command;
  }

  String createCodexPrompt(String transcript) {
    return '''
You are working inside the New Earth Dashboard repo.

User voice command:
${transcript.trim()}

Rules:
- Make minimal, high-confidence changes.
- Explain what files you changed.
- Do not delete existing work.
- Do not make destructive changes.
- Ask for approval before major rewrites.
''';
  }
}
