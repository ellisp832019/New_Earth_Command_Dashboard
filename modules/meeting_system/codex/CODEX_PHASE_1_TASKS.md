# Codex Phase 1 Task List

## Task 1 — Inspect repo

Find the dashboard framework:

- React / Next / Vite
- Flutter
- Tauri
- Electron
- Python backend
- Node backend

Do not assume. Inspect files first.

## Task 2 — Add module folder

Create a meeting module in the correct project convention.

Suggested names:

```text
meeting_system
meetings
project_meetings
```

## Task 3 — Add data models

Create models for:

- Meeting
- MeetingAction
- MeetingDecision
- MeetingFollowUp

## Task 4 — Add local storage service

Implement:

- listMeetings
- createMeeting
- readMeeting
- updateMeetingNotes
- addAction
- addDecision
- updateFollowUp

## Task 5 — Add UI pages

Create pages:

- MeetingDashboard
- MeetingList
- NewMeetingWizard
- MeetingDetail
- ActionTracker
- DecisionTracker
- FollowUpTracker

## Task 6 — Add settings

Add configurable Omega OS path:

```text
D:\NEW_EARTH_OMEGA_OS_PACK
```

Do not bury this path deep in code.

## Task 7 — Test

Create one test meeting:

```text
2026-06-03_BIOCALM_Sahil_Update
```

Confirm folder and template files are created.

## Task 8 — Document

Update dashboard README with Meeting System usage.
