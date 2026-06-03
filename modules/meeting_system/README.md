# New Earth Dashboard — Meeting System Module

This is a repo add-on module for building a **Meeting System** inside the New Earth Dashboard.

It is designed to manage documents, meetings, decisions, actions, follow-ups, transcripts, attachments and links into Omega OS.

## Omega OS source folder

The module treats this folder as the source of truth:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\21_PROJECTS_AND_PROGRAMMES
```

Main meeting area:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\21_PROJECTS_AND_PROGRAMMES\00_MEETINGS_AND_CALLS
```

Master indexes:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\21_PROJECTS_AND_PROGRAMMES\01_MASTER_INDEXES
```

## What this module should build in the dashboard

- Meeting dashboard
- Meeting index
- Create new meeting wizard
- Meeting notes editor
- Action tracker
- Decision tracker
- Follow-up tracker
- Template library
- Meeting settings
- Document links
- Attachment links
- Transcript/audio links
- Project filter
- Person/contact filter
- Status filter
- Search
- Export meeting summary to Markdown

## Recommended first implementation

Start simple:

1. Read/write local Markdown and JSON files.
2. Create meeting folders automatically.
3. Maintain a `meeting_index.json` file.
4. Build UI pages around that index.
5. Later add OCR, transcript import, Google Calendar/Gmail linking, and AI summaries.

## Folder structure in this repo add-on

```text
new_earth_dashboard_meeting_system_module/
  docs/
  codex/
  src/meeting_system/
  scripts/
  templates/
  omega_os_scaffold/
```

## Where to copy this in your repo

Copy this folder into your New Earth Dashboard repo under something like:

```text
modules/meeting_system/
```

or:

```text
packages/meeting_system/
```

Then give Codex the file:

```text
codex/CODEX_BUILD_PROMPT.md
```
