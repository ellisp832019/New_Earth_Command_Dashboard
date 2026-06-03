# Codex Prompts

## First Setup Prompt

```text
I have added the NE_OBSIDIAN_SYNC_MODULE to this repo inside /obsidian_sync.
Please read /obsidian_sync/CODEX_OBSIDIAN_SYNC_TASK.md and complete the task.
Only update files inside /obsidian_sync/exports.
Do not modify source code.
```

## Weekly Sync Prompt

```text
Run the Obsidian sync task for this repo.
Scan the latest repo state and update /obsidian_sync/exports.
Focus on current state, architecture changes, roadmap, decisions, build log, risks, and next actions.
Do not modify source code.
```

## Build Log Only Prompt

```text
Update only /obsidian_sync/exports/BUILD_LOG.md and /obsidian_sync/exports/DECISIONS.md based on the latest repo changes.
Do not modify source code.
```

## Risk Review Prompt

```text
Review this repo for project risks and documentation gaps.
Update /obsidian_sync/exports/CURRENT_STATE.md and /obsidian_sync/exports/WEEKLY_REPORT.md only.
Do not modify source code.
```
