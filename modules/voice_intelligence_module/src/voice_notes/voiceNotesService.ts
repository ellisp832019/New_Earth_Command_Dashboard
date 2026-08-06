export interface VoiceNoteDraft {
  id: string;
  createdAt: string;
  transcript: string;
  summary?: string;
  linkedProject?: string;
}

export function createVoiceNoteDraft(transcript: string, linkedProject = 'inbox'): VoiceNoteDraft {
  return {
    id: `voice_note_${Date.now()}`,
    createdAt: new Date().toISOString(),
    transcript,
    summary: transcript.length > 160 ? `${transcript.slice(0, 157)}...` : transcript,
    linkedProject
  };
}
