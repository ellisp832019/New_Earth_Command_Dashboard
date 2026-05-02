enum VoiceCommandType { task, journalEntry, codexPrompt, idea }

extension VoiceCommandTypeLabel on VoiceCommandType {
  String get label {
    switch (this) {
      case VoiceCommandType.task:
        return 'Task';
      case VoiceCommandType.journalEntry:
        return 'Journal Entry';
      case VoiceCommandType.codexPrompt:
        return 'Codex Prompt';
      case VoiceCommandType.idea:
        return 'Idea';
    }
  }
}

class VoiceCommand {
  VoiceCommand({
    required this.id,
    required this.transcript,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String transcript;
  final VoiceCommandType type;
  final DateTime createdAt;
}
