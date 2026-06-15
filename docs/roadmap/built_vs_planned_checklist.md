# Built Vs Planned Checklist

This checklist separates what is already built, what is actively being hardened, and what is still future work.

It is a companion to:

- `docs/roadmap/project_now_next_later.md`
- `docs/roadmap/app_roadmap.md`
- `docs/roadmap/mvp_execution_plan.md`

## Built

### App Core

- [x] Flutter app shell
- [x] Material 3 theme
- [x] Bottom navigation
- [x] More screen links
- [x] Drift and SQLite foundation
- [x] Seeded default projects and app settings
- [x] Dashboard reads local data
- [x] Projects list reads seeded data
- [x] Tasks list reads local data
- [x] Planner reads today's DailyPlan

### Core Daily Loop

- [x] Top 3 selection
- [x] Dashboard Top 3 actions
- [x] Quick-edit focus flow
- [x] Focus reason and clear focus flow
- [x] Project create/edit/archive flows
- [x] Task create/edit/status/filter/search/archive flows
- [x] Quick Capture saves to Inbox
- [x] Voice Capture saves reviewed transcripts locally

### Module Hub

- [x] Module registry browsing
- [x] Module detail depth
- [x] Module operations
- [x] Docking preview
- [x] Safety and governance surfaces
- [x] Polish and release pass

### Knowledge And Docs

- [x] Knowledge Library scanning and catalogue work
- [x] Repo Intelligence Bridge templating and cleanup
- [x] Obsidian sync templating and cleanup

## In Progress Or Hardening

### Dashboard And MVP

- [ ] V0.1 release-readiness pass
- [ ] Manual persistence testing
- [ ] Align stale docs with current app behavior
- [ ] Inbox processing foundation
- [ ] Project detail linked module surfacing

### Voice

- [ ] Remembered thread polish
- [ ] Briefing clarity pass
- [ ] Quick follow-up chips
- [ ] Voice reply tuning
- [ ] Shared session state polish
- [ ] Voice verification pass

### Assets And Print

- [ ] QR generation and printing reliability pass
- [ ] Print queue readability improvements
- [ ] Printer preset configuration polish

### Knowledge Library

- [ ] Richer search and filters
- [ ] Per-item manifests
- [ ] Failure handling improvements

### Repo Intelligence

- [ ] Template-first setup remains consistent
- [ ] Dashboard export stability stays intact
- [ ] Reusable profiles across repos

## Planned For Later

### AI

- [ ] AI adapter contract
- [ ] Local stub provider
- [ ] Voice briefing assist
- [ ] Transcript cleanup assist
- [ ] Wizard assist
- [ ] History and memory assist
- [ ] Follow-up suggestion assist
- [ ] Opt-in settings
- [ ] Safety and test pass
- [ ] First real AI provider

### Integrations

- [ ] Calendar
- [ ] GitHub
- [ ] WordPress
- [ ] MicroGrow live links
- [ ] Cloud sync

### Module Hub Future

- [ ] Shell-level live dock host
- [ ] First real docked module
- [ ] Persisted dock position
- [ ] Second docked module
- [ ] Drag-and-drop docking
- [ ] Multi-window behavior

### Assets And Treasury Future

- [ ] Receipts and warranty evidence links
- [ ] Location and bin map
- [ ] Valuation and insurance views
- [ ] Repair resolution handoff

## Reading Guide

- If it is checked, it exists in the project now.
- If it is unchecked under "In Progress Or Hardening", it is active but not finished.
- If it is unchecked under "Planned For Later", it is intentionally parked.

