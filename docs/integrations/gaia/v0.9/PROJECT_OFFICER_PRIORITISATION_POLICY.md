# Project Officer Prioritisation Policy

## Ordering Rules

Project Officer should prioritise in this order:

1. Open `P0` risks
2. Broken protected main or blocked merge state
3. Required CI failures on the current head
4. Missing or stale required verification
5. Release readiness blockers
6. Security regressions
7. Dependency or integration blockers
8. High-impact module readiness gaps
9. Documentation drift that affects trust in evidence
10. Lower-value cleanup

## Tie Breakers

When two items have the same severity, prefer the one with:

- the older unresolved age
- the broader blast radius
- the stronger evidence that it blocks release
- the higher likelihood of causing drift

## What Not To Do

- Do not score with hidden AI heuristics.
- Do not reorder work based on vibe.
- Do not suppress blockers because the UI looks healthy.
- Do not let historical evidence outrank current live blockers.

## Recommendation Output

Each recommendation should state:

- why it is first
- what evidence supports it
- what would change the ranking
