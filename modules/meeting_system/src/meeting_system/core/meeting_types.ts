export type MeetingStatus = 'planned' | 'open' | 'waiting' | 'complete' | 'archived';
export type ActionStatus = 'open' | 'doing' | 'waiting' | 'done' | 'blocked' | 'archived';
export type DecisionStatus = 'proposed' | 'agreed' | 'locked' | 'revisit_later' | 'replaced';

export interface MeetingRecord {
  id: string;
  date: string;
  project: string;
  title: string;
  person_or_group: string;
  meeting_type: string;
  purpose?: string;
  status: MeetingStatus;
  folder_path: string;
  agenda_path: string;
  notes_path: string;
  actions_path: string;
  decisions_path: string;
  follow_up_path: string;
  created_at: string;
  updated_at: string;
  tags: string[];
}

export interface MeetingAction {
  id: string;
  meeting_id: string;
  project: string;
  action: string;
  owner: string;
  due_date?: string;
  status: ActionStatus;
  notes?: string;
}

export interface MeetingDecision {
  id: string;
  meeting_id: string;
  project: string;
  decision: string;
  reason?: string;
  impact?: string;
  status: DecisionStatus;
}

export interface MeetingFollowUp {
  id: string;
  meeting_id: string;
  project: string;
  person: string;
  message_needed: boolean;
  sent: boolean;
  response_received: boolean;
  next_step?: string;
}
