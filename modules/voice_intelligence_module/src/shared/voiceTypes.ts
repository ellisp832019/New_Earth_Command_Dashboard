export interface VoiceSession {
  id: string;
  startedAt: string;
  endedAt?: string;
  mode: 'voice_note' | 'meeting' | 'assistant' | 'microgrow_status';
  transcript?: string;
  summary?: string;
  status: 'recording' | 'processing' | 'saved' | 'failed';
}

export interface VoiceFeatureFlags {
  voiceNotesEnabled: boolean;
  meetingTranscriberEnabled: boolean;
  dashboardAssistantEnabled: boolean;
  microgrowReadOnlyEnabled: boolean;
  microgrowVoiceControlEnabled: boolean;
  alwaysOnWakeWordEnabled: boolean;
  cloudSyncVoiceLogsEnabled: boolean;
}
