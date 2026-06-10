# Dashboard and Module Landscape

This page gives a calm, repo-wide view of where the Dashboard and major New Earth modules are right now, what each one is doing next, and what should stay parked until the system grows further.

It is a synthesis of the current roadmap and module docs, not a line-by-line code audit.

## Status Key

- `Active now` means the module is already part of the working system or has an active implementation slice.
- `In roadmap` means the module has a clear build plan and should be treated as a current target.
- `Parked` means it should wait until the local-first core is stronger or a future expansion trigger is met.

## Core Dashboard Surfaces

These are the main app areas from the FSD and app roadmap.

| Area | Where it is now | Next roadmap | Later direction |
| --- | --- | --- | --- |
| Dashboard | Main home and command centre for today's focus, top 3 tasks, active projects, and quick capture. | Keep the calm home loop stable and connected to the other modules. | Smarter summary cards and better cross-module surfacing. |
| Tasks | Core action system with the top 3 rule, parked work, and carry-forward language. | Keep the task flow reliable and tightly linked to Dashboard and Planner. | Deeper filtering, smarter review, and stronger project/task linkage. |
| Daily Planner | Morning intention and evening review layer for the working day. | Keep the plan/review loop simple and honest. | Better review history and stronger habit support. |
| Projects | Core project tracking surface for active New Earth work. | Keep project states, linked notes, and project actions clean. | Stronger repo bridge and module cross-links. |
| Journal | Build log and reflection space for decisions and progress. | Keep it easy to record and revisit. | Better search, filters, and structured retrospectives. |
| Inbox / Quick Capture | Fast capture entry point for ideas, notes, and follow-up items. | Keep capture first and sorting later. | Smarter routing into tasks, journal, and project records. |
| Learning | Support surface for skill growth and study. | Keep summaries visible where useful. | Better learning pathways and project-linked learning records. |
| Content | Content planning and output tracking. | Keep it lightweight and linked to the wider build. | More structured publishing pipelines later. |
| Business | Business actions and operating notes. | Keep it simple and visible from the dashboard. | Stronger planning and review helpers later. |
| Wellbeing | Personal steadiness and energy management. | Keep it calm and low friction. | More useful check-ins and review prompts later. |
| Settings | Local configuration and system options. | Keep path configuration and module settings clear. | More module-specific controls as the system grows. |

## Specialist Modules

These modules sit beside the core app and extend it into the wider New Earth system.

| Module | Where it is now | Next roadmap | Later direction |
| --- | --- | --- | --- |
| Treasury | Strong active roadmap with a 20-task plan focused on safe local drafts, folder health, receipts, spend, subscriptions, decisions, summaries, and calm state surfacing. | Finish the home, wizard, drafts, file safety, and review surfaces in order. | Keep it local-first and expand only after the calm workflow is stable. |
| Voice Assistant | Active roadmap with desktop hardening, history, templates, remembered threads, briefings, follow-up chips, and shared session state. | Finish the next 10-task voice roadmap in order, starting with reliability and reuse. | Add AI only through a safe adapter after the local voice flow is stable. |
| Knowledge Engine | Working local module for scanning, cataloguing, extracting, searching, and preparing the Omega OS PDF library. | Finish dashboard integration for library, search, item details, health, and extraction progress. | Add OCR, semantic search, summary generation, and audio later. |
| Repo Research Engine | Safe local-first repository analysis module; round 2 foundation is complete and dashboard integration is the current follow-on. | Polish the dashboard page, repo detail views, comparisons, and extraction/review flow. | Expand adapter coverage and richer research views later. |
| Backup Guardian | Phase 2 automation and verification are in place, with manifest-backed checking, history, restore points, and retention already surfaced. | Finish the remaining backup roadmap slices only where they make the module more self-sustaining. | Treat this as a long-lived system guardrail; expand again when the system grows. |
| Assets Intelligence | Planned calm asset register and health surface tied to Treasury and Omega OS asset folders. | Build config, folder health, home UI, register views, and quick capture. | Add valuation, insurance, and richer register views later. |
| QR Labels | Extension of Asset Intelligence for generation, preview, queueing, and manual print flow. | Finish QR generation, label preview, print queue, and printer profiles first. | Keep Bluetooth printer support parked until the safe adapter path is needed. |
| Visual Capture | Calm capture inbox for photos and evidence, linked to Treasury, Assets, and QR labels. | Build folder health, inbox/import, and linking to finance/assets/projects. | Add webcam capture, OCR queue, and privacy review later. |
| Meeting System | Planned add-on for meetings, decisions, actions, transcripts, and attachments. | Start with local Markdown/JSON meeting files and a meeting index. | Add OCR, transcript import, calendar/Gmail links, and AI summaries later. |
| Command Deck | Virtual command deck first, with physical deck and Stream Deck support later. | Keep the software deck, shortcut bridge, and workflow actions as the first milestone. | Add meeting automation, module shortcuts, and custom hardware later. |
| Launchpad | Standalone launch and funding module for campaigns, grants, investors, and fulfilment. | Keep the campaign, rewards, readiness, and finance model working locally. | Expand the operations, analytics, and polish layers later. |
| Project Repo Bridge | Read-only bridge between dashboard projects/tasks and local repositories. | Keep the adapter safe and lightweight while it maps current project data. | Expand into a richer projects intelligence layer later. |
| NE Obsidian Sync | Universal documentation export and sync module for long-term memory. | Use it as a reusable doc export layer rather than a core runtime dependency. | Expand it where long-form project memory is useful. |

## Best Cross-System Order

If the aim is to keep the Dashboard useful without creating more maintenance than necessary, the best order is:

1. Stabilize the core Dashboard, Tasks, Planner, Projects, and Quick Capture loop.
2. Finish Treasury so finance entry stays calm and safe.
3. Keep Backup Guardian self-sufficient and boring in the good sense.
4. Harden Assets, QR Labels, and Visual Capture as one connected operational lane.
5. Finish Knowledge Engine and Repo Research Engine as the two major knowledge tools.
6. Polish Voice Assistant so it feels reliable rather than experimental.
7. Leave AI, cloud sync, and broad live integrations parked until the local-first core is clearly ready.

## What Should Stay Parked For Now

- Cloud sync
- Login and account systems for V0.1
- Live GitHub, WordPress, and calendar integrations
- Native Bluetooth printing as the first QR path
- Heavy AI automation without a safe adapter layer
- Anything that adds maintenance before the local-first workflow is stable

## Read This With The Other Roadmaps

- [App Roadmap](app_roadmap.md)
- [Module Activation Roadmap](dashboard_module_activation_roadmap.md)
- [Voice Roadmap](voice_10_task_roadmap.md)
- [AI Roadmap](ai_10_task_roadmap.md)
- [Treasury Roadmap](treasury_20_task_roadmap.md)
