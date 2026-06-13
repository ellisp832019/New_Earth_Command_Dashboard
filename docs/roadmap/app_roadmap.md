# New Earth Command Dashboard Roadmap

This document is the top-level roadmap for the app as it stands now.

It sits above the narrower topic roadmaps and gives a calm view of the whole product:

- what is already working
- what needs to be hardened next
- what should stay parked for now
- what comes later once the local-first core is stable

## Current Shape

The app already has working surfaces for:

- Dashboard
- Tasks
- Planner
- Projects
- Journal
- Inbox
- Learning
- Content
- Business
- Wellbeing
- Treasury
- Assets and QR labels
- Knowledge Library
- Voice Assistant and Voice Intelligence

The strongest active systems right now are:

- the local-first Dashboard and task loop
- the Knowledge Engine module for PDF library scanning and catalogue work
- the QR label and print queue workflow
- the Windows voice capture, legacy voice assistant, and new voice intelligence path

## Working Principles

1. Keep the app local-first and offline-first.
2. Keep review-first behavior where capture or automation is involved.
3. Make one useful slice better at a time.
4. Prefer small, safe changes over broad rewrites.
5. Park work that is not ready instead of forcing it into the main path.

## Current Priority Order

### 1. Stabilize The Foundation

Keep the current core surfaces reliable and pleasant:

- Dashboard
- Tasks
- Planner
- Projects
- Quick Capture
- Voice capture

Focus here:

- preserve local data
- keep navigation calm
- keep the top three task flow honest
- keep voice capture and review predictable

### 2. Finish The Voice Clean-up

The voice path should be polished before any AI assist layer is added.

The next voice steps are:

1. Remembered Thread Polish
2. Briefing Clarity Pass
3. Quick Follow-Up Chips
4. Voice Reply Tuning
5. Shared Session State Polish
6. Voice Verification Pass

### 3. Harden Asset Intelligence

The Assets and QR label system should keep growing carefully.

Current priorities:

- keep QR generation and printing reliable
- keep the print queue readable
- keep label manifests and history useful
- keep printer presets configurable
- keep direct Bluetooth printing parked until the safe adapter path is ready

### 4. Finish The Knowledge Library Loop

The Knowledge Engine should stay focused on:

- scanning PDFs recursively
- building catalogue files safely
- extracting text in resumable batches
- surfacing health and progress to the Dashboard
- keeping Omega OS as the source of truth

Future steps here should stay incremental:

- richer search and filters
- per-item manifests
- failure handling
- optional audio pipeline later

### 5. Add AI Only Through A Safe Adapter

AI should be optional and layered in after the local experience is stable.

The roadmap for AI is:

1. AI Adapter Contract
2. Local Stub Provider
3. Voice Briefing Assist
4. Transcript Cleanup Assist
5. Wizard Assist
6. History and Memory Assist
7. Follow-Up Suggestion Assist
8. Opt-In Settings
9. Test and Safety Pass
10. First Real AI Provider

### 6. Expand Integrations Only After The Core Is Stable

Park these until the local-first core is strong enough:

- calendar
- GitHub
- WordPress
- MicroGrow live links
- cloud sync

### 7. Grow The Module Hub

The Module Hub has now been taken through its first full slice set and hardened:

1. Browsing and search
2. Module detail depth
3. Module operations
4. Layout and docking
5. Safety and governance
6. Polish and release

The current Module Hub work is complete for now. Revisit it when a new module slice or new docking requirement appears.

## Topic Roadmaps

Use these docs for the detailed slices:

- [`docs/roadmap/dashboard_module_landscape.md`](dashboard_module_landscape.md)
- [`docs/roadmap/dashboard_module_map.md`](dashboard_module_map.md)
- [`docs/roadmap/dashboard_ranked_roadmap.md`](dashboard_ranked_roadmap.md)
- [`docs/roadmap/dashboard_module_activation_roadmap.md`](dashboard_module_activation_roadmap.md)
- [`docs/roadmap/dashboard_module_first_week_plan.md`](dashboard_module_first_week_plan.md)
- [`docs/roadmap/dashboard_module_20_task_execution_queue.md`](dashboard_module_20_task_execution_queue.md)
- [`docs/roadmap/dashboard_module_20_task_delivery_phases.md`](dashboard_module_20_task_delivery_phases.md)
- [`docs/roadmap/dashboard_phase_1_build_checklist.md`](dashboard_phase_1_build_checklist.md)
- [`docs/roadmap/module_hub_roadmap.md`](module_hub_roadmap.md)
- [`docs/roadmap/mvp_roadmap.md`](mvp_roadmap.md)
- [`docs/roadmap/mvp_execution_plan.md`](mvp_execution_plan.md)
- [`docs/roadmap/future_tasks.md`](future_tasks.md)
- [`docs/roadmap/voice_10_task_roadmap.md`](voice_10_task_roadmap.md)
- [`docs/roadmap/ai_10_task_roadmap.md`](ai_10_task_roadmap.md)
- [`docs/roadmap/treasury_20_task_roadmap.md`](treasury_20_task_roadmap.md)

## What "Done" Means For A Slice

A slice is only done when:

1. The UI exists.
2. Data saves locally.
3. Data reloads correctly.
4. Related screens stay in sync.
5. The behavior stays calm and review-first.
6. `flutter analyze` passes.
7. `flutter build windows` passes when the change affects the app runtime.

## Sequence Rule

When a slice is finished:

1. Verify it.
2. Update the relevant topic roadmap if priorities changed.
3. Rewrite `TASK.md` only for the next active slice.
4. Keep the repo history clean and easy to review.

## Near-Term Summary

The best next order is:

1. Finish voice polish.
2. Harden the QR and print flows.
3. Keep Knowledge Library reliable and useful.
4. Add the AI adapter contract and stub.
5. Layer on AI assist features only after the stub is stable.
6. Treat the Module Hub as complete for the moment unless a new module slice needs it.
