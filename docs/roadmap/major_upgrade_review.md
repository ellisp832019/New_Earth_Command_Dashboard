# Major Upgrade Review

This review pulls together the current roadmap, release-readiness, and subsystem audit docs into one practical read on where the dashboard stands now and what the next major upgrade waves should be.

It is broader than `TASK.md`.
Use it when you want to answer:

- how mature the app is now
- which systems are truly ready for expansion
- which upgrades should come next
- which areas should stay parked

## Current Position

The dashboard is no longer just a scaffold.

Based on:

- `app_roadmap.md`
- `repo_upgrade_roadmap.md`
- `built_vs_planned_checklist.md`
- `release_readiness_summary.md`
- `subsystem_status_audit.md`
- `dashboard_future_roadmap.md`

the project is now in this state:

- the app shell is real and usable
- the local-first data foundation is in place
- the daily dashboard loop exists
- specialist modules are live enough to route into and test
- the planning stack is strong
- the biggest need is disciplined hardening, not broad expansion

## What Is Already Strong

### Core shell

- Flutter shell is established
- Material 3 structure is live
- local persistence foundation exists
- seeded data and module routing are working
- the Omega Knowledge Engine now has explicit output previews, local settings, and discovery paths from More and Module Hub

### Daily loop

- Dashboard
- Tasks
- Planner
- Quick Capture
- Top 3 flow

These are already meaningful parts of the product, not just placeholders.

### Specialist module direction

These lanes are no longer hypothetical:

- Users & Devices
- Treasury
- Assets / QR
- Voice
- Knowledge / repo intelligence
- Experiment workspace
- Module Hub

## What Still Needs Hardening

These are the recurring gaps across the roadmap docs.

### 1. Release-readiness discipline

Still needed:

- manual persistence testing
- app restart verification
- regression checks
- build verification discipline

Why this matters:

- the app is now big enough that trust depends on repeatable reopen-and-verify behavior

### 2. Documentation alignment

Still needed:

- reduce stale task language
- keep user guides aligned with actual app flow
- keep roadmap pages distinct instead of repetitive

Why this matters:

- the docs are strong, but drift is now one of the main maintenance risks

### 3. Voice polish

Still needed:

- remembered thread polish
- briefing clarity
- follow-up chips
- reply tuning
- session-state verification

Why this matters:

- voice is already prominent and useful, so rough state handling will be felt quickly

### 4. Access and session trust

Still needed:

- keep Users & Devices stable and understandable
- keep startup lock and session behavior predictable
- finish access-control polish before broader security growth

Why this matters:

- this layer is becoming the trust spine for the app

### 5. Real-world reliability

Still needed:

- print reliability
- asset evidence linking
- treasury traceability
- backup and recovery confidence

Why this matters:

- these are the modules that touch real-world decisions and physical workflows

## Major Upgrade Lanes

The repo docs point to five sensible upgrade lanes.

### Lane 1. Foundation hardening

Focus:

- release-readiness
- persistence testing
- inbox verification
- dashboard clarity
- build and restart confidence

This is the highest-value upgrade lane because it improves the whole product without adding sprawl.

### Lane 2. Trust and safety layer

Focus:

- Users & Devices
- Security Lock
- session visibility
- Treasury gating
- Backup Guardian reliability

This should stay ahead of broader module expansion.

### Lane 3. Operational modules

Focus:

- Assets
- QR labels
- evidence capture
- receipts / inventory / traceability

This makes the dashboard more useful in the real world, but only after the trust layer is calm.

### Lane 4. Knowledge and research

Focus:

- Knowledge Library
- Omega Knowledge Engine
- Repo research and exported memory

This lane is already useful, but it should keep growing in a safe, read-only, template-first way.
The current Knowledge Engine work is still in this lane, and the next upgrades should stay read-only unless a backup-first write workflow is explicitly approved.

### Lane 5. AI and integration layering

Focus:

- AI adapter contract
- local stub provider
- opt-in AI surfaces
- future integration adapters

This is still a later wave, not a current-core wave.

## What Should Stay Parked

Across the roadmap docs, these still read as intentionally deferred:

- cloud sync
- account/login systems
- live GitHub integration
- live WordPress integration
- live calendar integration
- broad AI automation without a safe adapter
- heavy analytics on the dashboard
- native Bluetooth printing as the first path

That still looks correct.

## Best Read On App Maturity

The repo appears to be:

- beyond prototype
- mid-way through hardening
- early in specialist-module maturity
- not yet in broad integration mode

That means the app is mature enough for:

- stronger internal testing
- focused operator workflows
- module-by-module hardening
- documentation curation

But not yet mature enough for:

- wide live integrations
- aggressive automation
- large parallel platform expansion

## Recommended Major Upgrade Order

If the goal is to make the app genuinely stronger, the cleanest order now is:

1. Finish release-readiness and persistence confidence
2. Keep Users & Devices, Treasury, and backup paths trustworthy
3. Stabilize voice session behavior
4. Harden asset / QR / evidence workflows
5. Keep knowledge-engine outputs, health checks, and exports reliable
6. Add AI only through the adapter-first path
7. Revisit broader integrations only after the core stays calm

## Strongest Immediate Candidates

If choosing the next major upgrades from the current repo state, the docs support these as the best candidates:

### A. Release-readiness pass

Because:

- it improves the whole product
- it is still clearly unfinished
- it reduces future debugging noise

### B. Users & Devices completion

Because:

- it is now visibly becoming the local trust layer
- it supports Treasury, voice, and gated modules
- it benefits from continued focused polish rather than a half-finished pause

### C. Voice verification pass

Because:

- the voice surfaces are already prominent
- the roadmap still flags session polish and response clarity as active work

## Bottom Line

The repo does not mainly need more modules.

It mainly needs:

- hardening
- trust
- restart confidence
- documentation curation
- tighter operational workflows

The dashboard is already rich enough that the most valuable upgrades now are the ones that make it calmer, safer, and easier to trust every day.
