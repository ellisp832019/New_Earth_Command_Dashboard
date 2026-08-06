export interface MeetingSummary {
  summary: string;
  decisions: string[];
  actions: string[];
  risks: string[];
  followUps: string[];
}

export function createMockMeetingSummary(transcript: string): MeetingSummary {
  return {
    summary: transcript ? 'Meeting summary generated from transcript.' : 'No transcript supplied.',
    decisions: [],
    actions: [],
    risks: [],
    followUps: []
  };
}
