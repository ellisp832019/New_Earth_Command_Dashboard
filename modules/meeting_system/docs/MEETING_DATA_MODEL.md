# Meeting Data Model

## Meeting

```json
{
  "id": "meet_2026_06_03_biocalm_sahil",
  "date": "2026-06-03",
  "project": "BIOCALM",
  "title": "BioCalm Sahil Update",
  "person_or_group": "Sahil",
  "meeting_type": "Google Meet",
  "status": "open",
  "folder_path": "D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/00_MEETINGS_AND_CALLS/2026/06_JUNE/2026-06-03_BIOCALM_Sahil",
  "agenda_path": "00_AGENDA.md",
  "notes_path": "01_MEETING_NOTES.md",
  "actions_path": "02_ACTIONS.md",
  "decisions_path": "03_DECISIONS.md",
  "follow_up_path": "04_FOLLOW_UP.md",
  "created_at": "2026-06-03T09:00:00",
  "updated_at": "2026-06-03T09:00:00",
  "tags": ["partner", "wearable", "update"]
}
```

## Action

```json
{
  "id": "act_001",
  "meeting_id": "meet_2026_06_03_biocalm_sahil",
  "project": "BIOCALM",
  "action": "Send Sahil update document",
  "owner": "Peter",
  "due_date": "2026-06-03",
  "status": "open",
  "notes": "Include development watch and New Earth Living app integration"
}
```

## Decision

```json
{
  "id": "dec_001",
  "meeting_id": "meet_2026_06_03_biocalm_sahil",
  "project": "BIOCALM",
  "decision": "Use development watch as demonstration hardware direction",
  "reason": "It gives Sahil something clear and tangible to understand",
  "status": "proposed"
}
```

## Follow-up

```json
{
  "id": "follow_001",
  "meeting_id": "meet_2026_06_03_biocalm_sahil",
  "project": "BIOCALM",
  "person": "Sahil",
  "message_needed": true,
  "sent": false,
  "response_received": false,
  "next_step": "Send update document after review"
}
```

## Status values

Meeting status:

- planned
- open
- waiting
- complete
- archived

Action status:

- open
- doing
- waiting
- done
- blocked
- archived

Decision status:

- proposed
- agreed
- locked
- revisit_later
- replaced
