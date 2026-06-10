# Dashboard Phase 1 Build Checklist

This checklist turns Phase 1 of the 20-task delivery plan into a practical build order.

Phase 1 is the operating core:

- Treasury
- Voice Assistant
- Backup Guardian

The goal is to make the core stable, visible, and safe before moving to asset, capture, and knowledge modules.

## Phase 1 Goal

By the end of this phase, the user should be able to:

- open Treasury and trust its folder state
- resume a finance draft without losing work
- reuse voice captures and continue a thread
- see backup health, history, and restore points clearly

## Build Order

### 1. Treasury folder health and path visibility

Start here.

Build checklist:

- confirm the finance path from local config
- show a visible health status on the Treasury home screen
- surface missing path or missing folder states clearly
- keep the empty state calm and helpful

Files to check first:

- `modules/system_backup/README.md`
- `modules/system_backup/docs/roadmap/BACKUP_GUARDIAN_STATUS_TABLE.md`
- `docs/codex_tasks/CODEX_MASTER_TASK__BUILD_TREASURY_TAB.md`

### 2. Treasury resumable draft and wizard flow

Once the path is visible, make the draft flow resumable.

Build checklist:

- keep the latest draft available locally
- allow the wizard to continue from the last saved state
- make sure save/review is always visible
- avoid overwriting finance files without explicit intent

Files to check first:

- `docs/roadmap/treasury_20_task_roadmap.md`
- `docs/codex_tasks/CODEX_MASTER_TASK__BUILD_TREASURY_TAB.md`

### 3. Treasury summary and decision surfaces

After drafts work, make Treasury read like an operating lane.

Build checklist:

- surface Safe, Watch, Pause, and Needs Decision states
- show clear summary cards on Treasury home
- keep monthly summary compact and readable
- make the state labels calm and non-shaming

Files to check first:

- `docs/roadmap/treasury_20_task_roadmap.md`
- `modules/system_backup/docs/roadmap/BACKUP_GUARDIAN_PRIORITY_MATRIX.md` if you want calm state language patterns

### 4. Voice Assistant capture history

Move to voice reuse next.

Build checklist:

- expose recent captures in a readable list
- let the user reopen a previous command quickly
- keep history local-first and review-first
- avoid making history feel like a log dump

Files to check first:

- `docs/roadmap/voice_10_task_roadmap.md`
- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`

### 5. Voice Assistant remembered thread and briefing flow

Keep the current thread and the next step visible.

Build checklist:

- show the remembered thread card
- make the briefing explain the next action clearly
- keep the raw transcript visible
- keep the assistant calm and short

Files to check first:

- `docs/roadmap/voice_10_task_roadmap.md`
- `docs/roadmap/ai_10_task_roadmap.md`

### 6. Voice Assistant shared session state polish

Make wake, dock, and assistant behave like one system.

Build checklist:

- confirm one shared session owner
- prevent overlapping listen/speak states
- keep wake handoff stable
- keep route handoff predictable

Files to check first:

- `docs/roadmap/voice_10_task_roadmap.md`
- `docs/roadmap/ai_10_task_roadmap.md`

### 7. Backup Guardian history and restore point surfacing

Then make the backup guardrail self-explanatory.

Build checklist:

- show latest backup activity
- show restore points clearly
- surface backup age and freshness in plain language
- keep the status area calm and direct

Files to check first:

- `modules/system_backup/README.md`
- `modules/system_backup/docs/roadmap/BACKUP_GUARDIAN_STATUS_TABLE.md`
- `modules/system_backup/docs/roadmap/BACKUP_GUARDIAN_20_TASK_PLAN.md`

### 8. Backup Guardian open-folder and report actions

Finish Phase 1 by making the backup module self-serve.

Build checklist:

- open the backup mirror folder from the dashboard
- open the latest backup report from the dashboard
- keep the report path readable
- keep the action buttons obvious and low-friction

Files to check first:

- `modules/system_backup/README.md`
- `modules/system_backup/docs/roadmap/BACKUP_GUARDIAN_STATUS_TABLE.md`

## Phase 1 Exit Check

Phase 1 is ready to move on when:

- Treasury shows a healthy local path and a resumable draft flow
- Voice Assistant has usable history and a remembered thread
- Backup Guardian shows history, restore points, and open actions cleanly
- the core dashboard still feels calm and easy to navigate

## Do Not Pull In Yet

- Asset Intelligence
- QR Labels
- Visual Capture
- Knowledge Engine
- Repo Research Engine
- Meeting System
- Command Deck

Those belong in later phases once the core operating loop is clearly stable.

