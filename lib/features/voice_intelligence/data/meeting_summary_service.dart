import 'voice_models.dart';
import 'voice_ai_provider.dart';

class MeetingSummaryService {
  const MeetingSummaryService({this.provider = const MockVoiceAiProvider()});

  final VoiceAiProvider provider;

  Future<MeetingSummaryResult> createMockSummary({
    required String transcript,
    required String meetingTitle,
  }) async {
    return provider.summarizeMeeting(
      transcript: transcript,
      meetingTitle: meetingTitle,
    );
  }
}
