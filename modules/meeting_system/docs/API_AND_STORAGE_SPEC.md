# API and Storage Spec

This module can be implemented either as local file services or as backend API routes.

## Required operations

### listMeetings()

Returns all meetings from `meeting_index.json`.

### createMeeting(input)

Creates a meeting folder and template files.

Input:

```json
{
  "date": "2026-06-03",
  "project": "BIOCALM",
  "title": "BioCalm Sahil Update",
  "person_or_group": "Sahil",
  "meeting_type": "Google Meet",
  "purpose": "Share current project status"
}
```

Output:

```json
{
  "ok": true,
  "meeting_id": "meet_2026_06_03_biocalm_sahil",
  "folder_path": "..."
}
```

### readMeeting(meetingId)

Reads metadata and Markdown files for one meeting.

### updateMeetingNotes(meetingId, markdown)

Updates `01_MEETING_NOTES.md`.

### addAction(meetingId, action)

Adds an action to the meeting and master action log.

### addDecision(meetingId, decision)

Adds a decision to the meeting and master decision log.

### updateFollowUp(meetingId, followUp)

Updates follow-up state.

### exportMeetingSummary(meetingId)

Creates a clean Markdown summary in `exports_pdf` or `exports`.

## Files to maintain

```text
01_MASTER_INDEXES/meeting_index.json
01_MASTER_INDEXES/MEETING_MASTER_INDEX.md
02_ACTIONS_AND_FOLLOW_UPS/action_index.json
02_ACTIONS_AND_FOLLOW_UPS/ACTION_MASTER_LOG.md
03_DECISIONS_AND_APPROVALS/decision_index.json
03_DECISIONS_AND_APPROVALS/DECISION_MASTER_LOG.md
```

## Local-first principle

The file system should remain readable even if the dashboard breaks.
The dashboard is a control layer, not a lock-in layer.
