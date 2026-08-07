# Project Officer Authority Model

## Active Levels

### Level 0 - Observe

GAIA may:

- read approved structured context
- summarize state
- quote or reference evidence
- identify drift and blockers

GAIA may not:

- mutate files
- mutate Git history
- call shell commands
- call GitHub write APIs
- execute hardware actions

### Level 1 - Recommend

GAIA may:

- prioritise work
- suggest next tasks
- suggest validation plans
- propose follow-up evidence captures
- draft human-readable prompts or checklists

GAIA may not:

- approve its own recommendations as actions
- create PRs
- push commits
- change risk status
- change release status

## Future Levels

- Level 2 `Prepare` is reserved for future human-approved artefact preparation.
- Level 3 `Execute` is reserved for future explicit command execution with separate controls.

## Guardrails

- Read-only by default.
- Human review required for anything beyond recommendation.
- Evidence must accompany meaningful answers.
- No hidden side effects.
