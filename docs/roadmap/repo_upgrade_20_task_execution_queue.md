# Repo Upgrade 20-Task Execution Queue

This queue turns the repo-wide upgrade program into one practical build order.

It is designed to:

- keep the app calm while it grows
- harden trust and persistence before broader expansion
- deepen one operating lane at a time
- avoid mixing too many risky concerns in one slice

Use it after:

- `docs/fsd/14_repo_upgrade_program.md`
- `docs/fsd/13_upgrade_execution_plan.md`

Use `TASK.md` for the exact active slice only.

## Queue

### 1. Users & Devices release verification pass

Finish the remaining release-confidence work around route trust, restart behavior, guide alignment, and manual proof.

Outcome:

- the local trust layer becomes easier to rely on day to day.

### 2. Users & Devices migration and legacy upgrade proof

Deepen migration coverage for PIN, approval, audit, and trust data across restart and upgrade scenarios.

Outcome:

- the trust spine feels safe under reload, reset, and older-data normalization.

### 3. Dashboard session visibility consistency

Standardize how session, access, timeout, and active user state are shown across the shell and protected screens.

Outcome:

- the session layer stays visible without making the app feel tense.

### 4. Dashboard card hierarchy restraint

Tighten primary, secondary, and support card rules so the home screen stays calm as more modules mature.

Outcome:

- the dashboard answers what matters now without becoming noisy.

### 5. Core daily loop inbox processing foundation

Bring inbox triage to a dependable first version that supports capture, review, and conversion without clutter.

Outcome:

- loose inputs start landing in a real review lane instead of building up as passive storage.

### 6. Core daily loop close-and-carry-forward completion

Finish the today-to-tomorrow handoff so planner review, tomorrow focus, and carry-forward behavior feel complete.

Outcome:

- the daily loop becomes more stable and emotionally lighter to use.

### 7. Company Command Centre tracker maturity

Deepen Website, LinkedIn, compliance, evidence, and action-board tracking so founder ops feel clearer and more actionable.

Outcome:

- the company module becomes a dependable read-first operating surface.

### 8. Company Command Centre safe write-mode design

Introduce explicit write-mode rules, source-link discipline, backup-first flow, and audit posture before real write-back.

Outcome:

- the module can evolve safely without losing trust.

### 9. Omega Knowledge Engine repository validation and scan health

Make repository path checks, scan readiness, health signals, and error posture clearer and easier to trust.

Outcome:

- the module becomes operational instead of just visually present.

### 10. Omega Knowledge Engine output previews and architecture quality

Improve output preview surfaces for learning notes, architecture map, project memory, and comment suggestion review.

Outcome:

- the engine teaches and explains instead of only listing generated files.

### 11. Assets and QR print reliability pass

Strengthen print queue clarity, retry behavior, profile handling, and label preview confidence.

Outcome:

- physical label work becomes predictable and boring in the best way.

### 12. Assets and evidence traceability pass

Improve capture-to-asset linking, receipt/evidence attachment paths, and visible traceability through the operational flows.

Outcome:

- the real-world asset lane becomes more trustworthy for support and review.

### 13. Voice startup and fallback polish

Tighten startup choice behavior, no-voice fallback clarity, and session continuity between lock, dashboard, and voice surfaces.

Outcome:

- voice feels optional, deliberate, and well-behaved.

### 14. Voice remembered thread and follow-up polish

Deepen thread continuity, follow-up chips, reply tuning, and briefing clarity without adding heavier AI behavior.

Outcome:

- the assistant becomes more helpful without becoming intrusive.

### 15. Backup Guardian health and restore confidence

Clarify backup health, mirror readiness, restore drill status, and local reporting signals.

Outcome:

- the system tools feel like real safety infrastructure, not just status cards.

### 16. Systems module cohesion pass

Align backup, restore, hardware/system health, and safe-close behavior into one calmer systems story.

Outcome:

- the user can understand operational safety from one place.

### 17. Shared reporting pattern across modules

Unify report structure, export actions, print-friendly output, and handoff packs across Users & Devices, Company, Treasury, and related modules.

Outcome:

- exports feel like one product family instead of separate module experiments.

### 18. Cross-module health visibility

Add a calmer, shared view of module posture, last review state, key risks, and actionable health summaries.

Outcome:

- operators can see what needs attention without hunting through multiple modules.

### 19. Adapter contract for future integrations

Define the safe local-first adapter layer for future LinkedIn, calendar, GitHub, WordPress, and AI surfaces.

Outcome:

- future integrations get a safe shape before implementation pressure arrives.

### 20. Opt-in integration and AI readiness settings

Add explicit settings, boundaries, and review-first controls for future external and AI-connected flows without enabling them fully yet.

Outcome:

- expansion stays controlled and reversible.

## Recommended Grouping

If you want to work this queue in calmer phases, use this grouping:

### Phase 1. Trust and shell

1. Users & Devices release verification pass
2. Users & Devices migration and legacy upgrade proof
3. Dashboard session visibility consistency
4. Dashboard card hierarchy restraint

### Phase 2. Daily operating loop

5. Core daily loop inbox processing foundation
6. Core daily loop close-and-carry-forward completion

### Phase 3. Safe operations

7. Company Command Centre tracker maturity
8. Company Command Centre safe write-mode design
9. Omega Knowledge Engine repository validation and scan health
10. Omega Knowledge Engine output previews and architecture quality

### Phase 4. Real-world reliability

11. Assets and QR print reliability pass
12. Assets and evidence traceability pass
13. Voice startup and fallback polish
14. Voice remembered thread and follow-up polish
15. Backup Guardian health and restore confidence
16. Systems module cohesion pass

### Phase 5. Shared platform layer

17. Shared reporting pattern across modules
18. Cross-module health visibility
19. Adapter contract for future integrations
20. Opt-in integration and AI readiness settings

## Best Next Active Slice

If choosing the best next build right now, start here:

- `1. Users & Devices release verification pass`

Reason:

- the trust spine is now strong enough that the biggest remaining risk is drift between runtime, tests, migration behavior, and guide language

After that, move to:

- `3. Dashboard session visibility consistency`

Reason:

- the shell should stay calm before more modules deepen further

## Build Rule

For each task in this queue:

1. define one narrow slice in `TASK.md`
2. keep commits small and reviewable
3. verify analyzer, focused tests, and Windows build when runtime changes
4. update the guide or roadmap only if the real flow changed
