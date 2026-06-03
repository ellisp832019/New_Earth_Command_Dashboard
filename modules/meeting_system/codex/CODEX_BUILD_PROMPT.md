# Codex Build Prompt — New Earth Dashboard Meeting System

You are working inside the New Earth Dashboard repo.

Build a local-first Meeting System module using the files in this folder as the source specification.

## Context

The user uses Omega OS at:

```text
D:\NEW_EARTH_OMEGA_OS_PACK
```

The meeting system source-of-truth folder is:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\21_PROJECTS_AND_PROGRAMMES
```

The dashboard should help manage:

- meetings
- meeting notes
- meeting documents
- actions
- decisions
- follow-ups
- attachments
- linked visuals
- linked project records

## First build scope

Build Phase 1 only.

### Phase 1 requirements

1. Add a Meeting System module to the dashboard.
2. Add routes/pages for:
   - Meeting Dashboard
   - All Meetings
   - New Meeting
   - Meeting Detail
   - Actions
   - Decisions
   - Follow-ups
3. Add a local storage service that reads/writes:
   - `meeting_index.json`
   - meeting folders
   - Markdown template files
4. Add create-meeting flow that creates:

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

5. Add searchable/filterable meeting table.
6. Add open-folder action where supported by the platform.
7. Keep all code local-first and simple.

## Do not do yet

Do not add cloud sync.
Do not add payment or subscription logic.
Do not add AI summarisation yet.
Do not change unrelated dashboard modules.
Do not hard-code only one project; support multiple projects.

## Data model

Use `docs/MEETING_DATA_MODEL.md`.

## UI spec

Use `docs/UI_WIREFRAME.md`.

## Storage spec

Use `docs/API_AND_STORAGE_SPEC.md`.

## Expected output

When complete, provide:

- list of files changed
- how to run the dashboard
- how to test creating a meeting
- any assumptions made
- next recommended phase
