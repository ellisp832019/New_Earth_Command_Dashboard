/**
 * Pseudocode adapter.
 * Codex should adapt this to the dashboard's actual filesystem/backend stack.
 */

import { MeetingRecord } from '../core/meeting_types';
import { buildMeetingFolderName, buildMeetingId, monthFolder } from '../core/meeting_paths';

export interface CreateMeetingInput {
  omegaRoot: string;
  date: string;
  project: string;
  title: string;
  person_or_group: string;
  meeting_type: string;
  purpose?: string;
  tags?: string[];
}

export async function createMeeting(input: CreateMeetingInput): Promise<MeetingRecord> {
  const year = input.date.slice(0, 4);
  const folderName = buildMeetingFolderName(input.date, input.project, input.person_or_group || input.title);
  const folderPath = `${input.omegaRoot}/21_PROJECTS_AND_PROGRAMMES/00_MEETINGS_AND_CALLS/${year}/${monthFolder(input.date)}/${folderName}`;

  // TODO: create folderPath
  // TODO: create attachments, audio_or_transcripts, exports_pdf
  // TODO: write 00_AGENDA.md
  // TODO: write 01_MEETING_NOTES.md
  // TODO: write 02_ACTIONS.md
  // TODO: write 03_DECISIONS.md
  // TODO: write 04_FOLLOW_UP.md
  // TODO: append/update meeting_index.json

  const now = new Date().toISOString();
  return {
    id: buildMeetingId(input.date, input.project, input.person_or_group || input.title),
    date: input.date,
    project: input.project,
    title: input.title,
    person_or_group: input.person_or_group,
    meeting_type: input.meeting_type,
    purpose: input.purpose,
    status: 'open',
    folder_path: folderPath,
    agenda_path: '00_AGENDA.md',
    notes_path: '01_MEETING_NOTES.md',
    actions_path: '02_ACTIONS.md',
    decisions_path: '03_DECISIONS.md',
    follow_up_path: '04_FOLLOW_UP.md',
    created_at: now,
    updated_at: now,
    tags: input.tags || []
  };
}
