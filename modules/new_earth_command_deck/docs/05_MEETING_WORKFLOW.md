# Meeting Workflow

## One-button meeting start

When Peter presses `Start Meeting`, the system should:

1. Create a dated meeting folder
2. Create meeting notes markdown
3. Create transcript placeholder
4. Create decisions log
5. Create action tracker
6. Open Google Meet or meeting link
7. Open OBS
8. Prepare recording scene
9. Open Dashboard meeting page

## Folder output

```text
MEETINGS/YYYY/YYYY-MM-DD_meeting_title/
├── 00_MEETING_NOTE.md
├── 01_TRANSCRIPT.md
├── 02_SUMMARY.md
├── 03_ACTIONS.md
├── 04_DECISIONS.md
├── 05_ATTACHMENTS/
├── 06_RECORDINGS/
└── 99_EXPORTS/
```

## Meeting end workflow

When meeting ends:

1. Stop recording
2. Move recording to meeting folder
3. Add transcript
4. Summarise key points
5. Extract actions
6. Extract decisions
7. Link to projects
8. Store in Omega OS

## Dashboard fields

- Meeting title
- Date
- Attendees
- Project
- Purpose
- Outcome
- Decisions
- Actions
- Follow-up date
- Recording path
- Transcript path
- Status
