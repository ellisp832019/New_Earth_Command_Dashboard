# Install This Module Into The New Earth Dashboard Repo

## Step 1 — Extract zip

Extract this folder somewhere temporary.

## Step 2 — Copy module into your dashboard repo

Recommended destination:

```text
<your-dashboard-repo>/modules/meeting_system
```

or, if your repo already uses `src/features`:

```text
<your-dashboard-repo>/src/features/meeting_system
```

## Step 3 — Open repo in VS Code

Open the dashboard repo root in VS Code.

## Step 4 — Open Codex

Use Codex in your editor or terminal. Codex can read and change code in the selected directory, so open it at the repo root. Official OpenAI docs describe Codex CLI as a local coding agent that can read, change and run code on your machine in the selected directory.

## Step 5 — Give Codex the build prompt

Paste this into Codex:

```text
Read modules/meeting_system/codex/CODEX_BUILD_PROMPT.md and build Phase 1 of the Meeting System. Inspect the repo first and adapt to the existing framework. Do not change unrelated modules. Keep it local-first and use Omega OS as the source of truth.
```

## Step 6 — Review before accepting

Use:

```text
modules/meeting_system/codex/CODEX_REVIEW_CHECKLIST.md
```

## Step 7 — Test with one meeting

Use the dashboard or run:

```bash
python modules/meeting_system/scripts/create_meeting.py --omega-root "D:/NEW_EARTH_OMEGA_OS_PACK" --date 2026-06-03 --project BIOCALM --person "Sahil" --title "BioCalm Sahil Update" --type "Google Meet"
```
