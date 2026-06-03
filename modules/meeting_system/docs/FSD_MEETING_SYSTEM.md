# Functional Specification Document — Meeting System

## 1. Purpose

The Meeting System gives the New Earth Dashboard one calm place to manage meetings, meeting documents, actions, decisions, follow-ups and linked project evidence.

It prevents meeting information from getting scattered across folders, chat, email, screenshots and project notes.

## 2. User goals

The user needs to be able to:

- Create a new meeting record quickly.
- Link it to a project such as MicroGrow, BioCalm, New Earth Living, Dashboard, Website or Prison Rehabilitation.
- Store agenda, notes, actions, decisions, follow-up messages and attachments.
- See every open action from all meetings.
- See every decision made across projects.
- Search meetings by project, date, person, status or topic.
- Export meeting summaries as Markdown.
- Keep the Omega OS folder as the source of truth.

## 3. Core folders

```text
21_PROJECTS_AND_PROGRAMMES/
  00_MEETINGS_AND_CALLS/
  01_MASTER_INDEXES/
  02_ACTIONS_AND_FOLLOW_UPS/
  03_DECISIONS_AND_APPROVALS/
  06_TEMPLATES/
```

## 4. Core dashboard pages

### 4.1 Meeting Dashboard

Shows:

- next/upcoming meetings
- recent meetings
- open follow-ups
- open actions
- recent decisions
- project meeting counts

### 4.2 Meeting Index

A searchable table with:

- date
- project
- title
- person/group
- status
- folder path
- actions count
- follow-up status

### 4.3 New Meeting Wizard

Fields:

- date
- project
- meeting title
- person/group
- meeting type
- purpose
- linked calendar event optional
- linked contact optional
- linked documents optional

Creates:

```text
YYYY-MM-DD_Project_PersonOrTopic/
  00_AGENDA.md
  01_MEETING_NOTES.md
  02_ACTIONS.md
  03_DECISIONS.md
  04_FOLLOW_UP.md
  attachments/
  audio_or_transcripts/
  exports_pdf/
```

### 4.4 Meeting Detail Page

Shows:

- metadata
- agenda
- notes
- actions
- decisions
- follow-up
- attachments
- linked visuals
- linked project docs

### 4.5 Action Tracker

Shows all meeting actions across all projects.

### 4.6 Decision Tracker

Shows all decisions across all meetings and projects.

### 4.7 Follow-up Tracker

Shows people who need replies, email drafts, documents to send, or next contact dates.

## 5. Data model

See:

```text
docs/MEETING_DATA_MODEL.md
```

## 6. Storage model

Phase 1:

- Markdown files for human-readable notes
- JSON index for dashboard speed
- file paths linking to Omega OS

Phase 2:

- optional SQLite database
- calendar/email/contact integration
- AI summaries
- audio transcript import

## 7. Acceptance criteria

The system is working when:

- a meeting can be created from the dashboard
- the matching folder appears in Omega OS
- the meeting appears in the dashboard index
- actions appear in the action tracker
- decisions appear in the decision tracker
- follow-up status can be changed
- the user can open the folder from the dashboard
- the user can export a meeting summary to Markdown

## 8. Do not overbuild at first

First version should be local-first, simple and reliable.

Avoid cloud sync, complex permissions, heavy databases or AI automation until the basic file workflow is solid.
