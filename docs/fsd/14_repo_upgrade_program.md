# Repo Upgrade Program

This document turns the existing roadmap and review material into one FSD-level program view.

Use it when the question is:

- where is the app really up to now
- which systems are mature enough to deepen
- which upgrade streams should come next
- what order should we use for major work
- what must be true before we widen the platform further

It sits below the broader product FSD and above the narrower stream plans and `TASK.md`.

## Source Inputs

This program view is derived from:

- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/roadmap/app_roadmap.md`
- `docs/roadmap/mvp_execution_plan.md`
- `docs/roadmap/major_upgrade_review.md`
- `docs/roadmap/built_vs_planned_checklist.md`
- `docs/roadmap/subsystem_status_audit.md`
- `docs/roadmap/repo_upgrade_roadmap.md`

## 1. Current Maturity Read

The dashboard is now beyond a prototype shell.

The repo already shows:

- a stable Flutter shell
- local-first persistence
- a real dashboard and daily loop surface
- a growing set of specialist modules
- active route protection and session behavior
- a stronger build rhythm with analyzer, tests, and Windows verification

The app is best described as:

- `usable core product`
- `mid-hardening`
- `early specialist-platform`

It is not yet best described as:

- `broadly integrated`
- `automation-heavy`
- `operator-complete across every module`

## 2. What Is Strong Today

### 2.1 Core shell and local base

Strong now:

- app shell and navigation
- Material 3 structure
- SQLite and local-first data model
- seeded startup data and route structure

Meaning:

- the base is solid enough to support real hardening work instead of repeated scaffolding

### 2.2 Daily working loop

Strong now:

- dashboard
- tasks
- planner
- quick capture
- top 3 flow

Meaning:

- the product already supports a real daily usage pattern, even though the loop still needs polish and release-grade verification

### 2.3 Trust and access foundation

Strong now:

- startup security lock
- session layer
- users and devices flow
- treasury gating
- access review and PIN governance direction

Meaning:

- the app has a real trust spine, not just placeholder route blocking

### 2.4 Specialist module direction

Strong enough to deepen:

- Users & Devices Control
- Treasury
- Assets and QR
- Company Command Centre
- Omega Knowledge Engine
- Voice and voice intelligence
- Module Hub

Meaning:

- these modules are now real program lanes and should be managed as upgrade streams

## 3. What Still Needs Hardening

### 3.1 Release-readiness discipline

Still needed:

- repeatable manual persistence checks
- restart and reopen confidence
- route regression checks
- doc-to-runtime alignment

Why it matters:

- the product is now large enough that trust depends on consistency, not just feature presence

### 3.2 Session and security clarity

Still needed:

- clearer operator recovery flow
- stronger lockout and support behavior
- route-level trust consistency across all protected areas

Why it matters:

- this layer affects startup, Treasury, and every future protected workflow

### 3.3 Calm dashboard hierarchy

Still needed:

- restrained snapshots
- clearer session visibility rules
- deliberate home-card hierarchy

Why it matters:

- more module maturity will create noise unless the shell stays intentionally calm

### 3.4 Read-only to safe-write progression

Still needed:

- safe write-mode design
- source-linked edits
- backup-first write flows
- audit visibility around admin changes

Why it matters:

- several modules now hold meaningful operational value, but write-back must be earned carefully

### 3.5 Shared reporting pattern

Still needed:

- consistent exports
- printable handoff packs
- calmer admin summaries
- module-level health reporting

Why it matters:

- reports exist in pockets, but the repo still lacks one stable cross-module pattern

## 4. Repo-Wide Upgrade Rules

Every major upgrade stream should follow these rules:

1. Keep local-first and offline-first by default.
2. Prefer read-only and review-first before write-back.
3. Harden one operator loop at a time.
4. Keep route protection ahead of convenience.
5. Keep the dashboard calm even as modules deepen.
6. Add focused tests when state, routing, or persistence changes.
7. Run `flutter analyze` for every meaningful slice.
8. Run `flutter build windows` whenever runtime code changes.
9. Keep `TASK.md` narrow even when the stream is broad.
10. Use documentation as part of release quality, not as an afterthought.

## 5. Recommended Major Upgrade Streams

These are the streams the repo is mature enough to support now.

### Stream 1. Users & Devices Trust Completion

Purpose:

- finish the trust spine for startup, protected routes, Treasury, and operator recovery

Current read:

- far enough along to matter
- still important enough that any weakness affects the whole app

Done looks like:

- route trust is consistent
- PIN lifecycle is clear
- lockout and recovery are calm
- migration and reload behavior are dependable
- audit and review surfaces are easy to use

### Stream 2. Dashboard Calm Session Layer

Purpose:

- protect the home screen from becoming noisy as the rest of the app matures

Current read:

- the dashboard is useful now
- more module surfacing will raise cognitive load if not controlled

Done looks like:

- quiet session visibility
- deliberate quick actions
- clear primary versus secondary cards
- module snapshots that inform without shouting

### Stream 3. Core Daily Loop Completion

Purpose:

- finish the product’s main operating loop so daily use feels complete and dependable

Current read:

- core loop exists
- release-grade completion is still incomplete

Done looks like:

- inbox triage is usable
- planner close-and-carry-forward feels complete
- task/project handoff is clearer
- dashboard still answers what matters today

### Stream 4. Company Command Centre Safe Operations

Purpose:

- move founder and admin ops from strong read-only visibility into safe, auditable action

Current read:

- read-only value is already present
- the next risk is unsafe write-back, not lack of more screens

Done looks like:

- website and LinkedIn tracking are actionable
- evidence remains source-linked
- write mode is explicit
- backups and review gates exist before changes land

### Stream 5. Omega Knowledge Engine Completion

Purpose:

- turn the knowledge shell into a dependable repo intelligence layer

Current read:

- strong shell and direction
- still needs operational maturity

Done looks like:

- repositories validate cleanly
- scan health is readable
- outputs preview clearly
- failures explain themselves
- project memory and exports feel useful, not just decorative

### Stream 6. Assets, QR, and Visual Capture Reliability

Purpose:

- strengthen physical-world workflows where mistakes carry practical cost

Current read:

- useful already
- depends on reliability, print confidence, and traceable evidence

Done looks like:

- print path is predictable
- retries are understandable
- evidence linking is visible
- capture-to-asset handoff is trustworthy

### Stream 7. Voice and Assistant Polish

Purpose:

- finish the voice experience before broader AI layering

Current read:

- already prominent enough that rough state behavior is noticeable

Done looks like:

- startup choices are clear
- no-voice fallback is calm
- threads and follow-up are readable
- voice never steals focus from the main workflow

### Stream 8. Backup, Recovery, and System Confidence

Purpose:

- make system safety tools feel like real recovery infrastructure

Current read:

- visible enough to matter
- still needs deeper health and restore confidence

Done looks like:

- backup state is honest
- restore readiness is visible
- support tools are safe to trust under pressure

### Stream 9. Shared Reporting and Export Layer

Purpose:

- unify the repo’s growing set of printable and handoff outputs

Current read:

- several modules already produce useful local summaries
- the pattern is still fragmented

Done looks like:

- export quality is consistent
- reports are traceable to source state
- admin review packs feel intentional across modules

### Stream 10. Adapter and Integration Layer

Purpose:

- prepare the app for future external services without breaking local-first principles

Current read:

- still later-stage work
- important to design now, risky to rush

Done looks like:

- adapters are optional
- local mode still works fully without network access
- future services are isolated from core workflows

## 6. Recommended Program Order

The cleanest order from the current repo state is:

1. Users & Devices Trust Completion
2. Dashboard Calm Session Layer
3. Core Daily Loop Completion
4. Company Command Centre Safe Operations
5. Omega Knowledge Engine Completion
6. Assets, QR, and Visual Capture Reliability
7. Voice and Assistant Polish
8. Backup, Recovery, and System Confidence
9. Shared Reporting and Export Layer
10. Adapter and Integration Layer

## 7. Why This Order

### 7.1 Trust before convenience

The app is now gated by local trust behavior in meaningful places.
That means security and session consistency should stay ahead of broader expansion.

### 7.2 Calm shell before more surface area

The dashboard can already become crowded.
That means shell discipline should improve before more modules compete for attention.

### 7.3 Safe operations before broad automation

Company, knowledge, and admin modules already hold real value.
They should gain safer operating depth before any broad automation or live integrations.

### 7.4 Reporting before externalization

The repo will benefit more from strong internal reports and exports than from rushed network adapters.

## 8. Release Gates Between Streams

Do not advance from one major stream to the next until:

1. `flutter analyze` passes
2. focused tests for the changed stream pass
3. `flutter build windows` passes for runtime slices
4. restart and persistence behavior has been checked where relevant
5. route protection is manually checked where relevant
6. affected guides and roadmap wording match the real app
7. the stream leaves the dashboard calmer or unchanged, not noisier

## 9. What Should Stay Parked

These still belong outside the next active waves:

- cloud sync
- full account/login systems
- live GitHub integration as a core dependency
- live WordPress integration
- live calendar integration
- heavy AI automation without an adapter layer
- broad external write-back without backup and audit discipline
- platform expansion that outruns Windows stability

## 10. Best Immediate Recommendation

The repo should keep treating the current moment as a hardening phase, not a breadth phase.

That means the best program-level next moves are:

1. finish the remaining Users & Devices trust completion slices cleanly
2. tighten dashboard calmness and session hierarchy next
3. only then widen deeper into company operations and knowledge-engine maturity

## 11. Working Rule For `TASK.md`

Use this document to choose the stream.

Then:

- use `13_upgrade_execution_plan.md` to choose the next slice in that stream
- use `TASK.md` for the exact active build only

That keeps planning broad, execution narrow, and commits easier to review.
