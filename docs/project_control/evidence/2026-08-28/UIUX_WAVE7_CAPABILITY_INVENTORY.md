# UIUX Wave 7 Capability Inventory

Audit date: 2026-08-28. Classification uses only the Wave 7 vocabulary. Counts are capability concepts, not new services.

| # | Capability | Module / system | Purpose | Owner | Consumers | Authority / provenance | Current implementation / evidence | Classification |
|---:|---|---|---|---|---|---|---|---|
| 1 | Daily focus | Daily Work / Dashboard | Define today's focus | Dashboard | Dashboard, Planner | Local - Dashboard | Daily plan repository and dashboard tests | LOCAL_ONLY |
| 2 | Top 3 selection | Daily Work / Dashboard | Select today's highest-value tasks | Dashboard | Dashboard, Tasks, Planner | Local - Dashboard | Task selection service and widget tests | LOCAL_ONLY |
| 3 | Next-step recommendation | Daily Work / Dashboard | Surface one useful next move | Dashboard | Dashboard | Local - Dashboard | Dashboard presentation logic and tests | LOCAL_ONLY |
| 4 | Task identity | Tasks / Dashboard | Identify actionable work | Dashboard Tasks | Tasks, Dashboard, Projects, Planner | Local - Dashboard | Task model/repository | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| 5 | Task inventory | Tasks / Dashboard | Filter and execute work | Dashboard Tasks | Tasks, Dashboard | Local - Dashboard | Tasks screen/repository tests | LOCAL_ONLY |
| 6 | Planning | Planning / Dashboard | Plan tomorrow and future work | Planner | Planner, Dashboard | Local - Dashboard | Daily plan repository/screen | LOCAL_ONLY |
| 7 | Review and carry-forward | Planning / Dashboard | Review completed day and carry work | Planner | Planner, Dashboard, Tasks | Local - Dashboard | Planner fields and handoffs | LOCAL_ONLY |
| 8 | Project identity | Projects / Dashboard | Identify human projects | Dashboard Projects | Projects, Tasks, Dashboard, Engineering context | Local - Dashboard | Project model/repository/detail screen | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| 9 | Project context | Projects / Dashboard | Explain progress, milestone, next action | Dashboard Projects | Projects, Tasks, Engineering | Local - Dashboard | Project detail and project-aware routes | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| 10 | Capture envelope | Capture / Dashboard | Turn an input into a reviewable item | Dashboard Capture | Inbox, Assets, domain capture | Local - Dashboard | Capture/inbox surfaces | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| 11 | Inbox processing | Inbox / Dashboard | Triage captured work | Dashboard Inbox | Dashboard, Tasks, domain screens | Local - Dashboard | Inbox repository/controller | LOCAL_ONLY |
| 12 | Treasury summary | Treasury / Dashboard | Present finance state and decisions | Dashboard Treasury | Treasury, Dashboard | Local - Dashboard | Treasury controllers/screens | LOCAL_ONLY |
| 13 | Asset identity | Assets / Dashboard | Identify tracked items and locations | Dashboard Assets | Assets, Visual Capture | Local - Dashboard | Asset repositories/screens | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| 14 | Meeting actions | Meetings / Dashboard | Record decisions, actions, follow-ups | Dashboard Meetings | Meetings, Dashboard | Local - Dashboard | Meeting repositories/services | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| 15 | Indexed retrieval | Knowledge / CKCC | Find indexed knowledge | CKCC / Librarian | Knowledge views, Omega Knowledge Engine | Indexed - CKCC/Librarian | Knowledge screens and retrieval services | CONSUMED_EXTERNAL |
| 16 | Engineering evidence | Engineering / Engineering system | Present specialist technical truth | Engineering | Engineering, Projects, Project Intelligence | Specialist / Observed - NEOS where sourced | Engineering repository and NEOS reader tests | CONSUMED_EXTERNAL |
| 17 | Declared status | Governed Status / Platform Core | Present declared architecture status | Platform Core | Dashboard governed-status view | Declared - Platform Core | Runtime config/composition/status tests | ADAPTER_VIEW_ONLY |
| 18 | Observed status | Project/Repo Intelligence / NEOS | Present observed repository/engineering state | NEOS / engineering observer | Project Intelligence, Repo Intelligence, Engineering | Observed - NEOS | Read-only adapters and snapshot tests | ADAPTER_VIEW_ONLY |
| 19 | Provenance labeling | Cross-surface vocabulary | Distinguish Local, Declared, Observed, etc. | Each authority; vocabulary is shared later | Governed status, intelligence, GAIA, specialist views | Source-specific labels | Phase 2 provenance standard and UI copy | SHARED_CANDIDATE |
| 20 | Orchestration launch | Command Centre Integration / Command Centre | Enter operational orchestration | Command Centre | Dashboard, Company views | Operational - Command Centre | Command Centre launch/status views | CONSUMED_EXTERNAL |
| 21 | Stable command IDs | Command Deck / Dashboard support | Identify bounded actions for future surfaces | Dashboard support now; future hardware owner | Command Deck, Dashboard, future device | Local/configured now; candidate shared contract later | Command Deck registry and service tests | SHARED_CANDIDATE |
| 22 | Bounded permissions | Users and Devices / Dashboard | Restrict access and approvals | Dashboard access control | Admin, future Command Deck, Command Centre | Local/admin | Users/devices and security surfaces | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| 23 | Device identity | Users and Devices / future hardware | Identify a physical device | Unclear: access control or future hardware owner | Users and Devices, future Command Deck | No current physical-device contract | No proven current hardware model | UNCLEAR_REVIEW_REQUIRED |
| 24 | Audit events | Voice / Users and Devices / command surfaces | Record controlled actions | Feature-local owners today | Voice, access, command surfaces | Local/controlled | Multiple feature-local audit/log models | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| 25 | Backup status | Systems / Backup Guardian | Present protection/recovery state | Backup Guardian | Systems, Dashboard summaries | Protected - Backup Guardian | Backup Guardian services and screens | CONSUMED_EXTERNAL |
| 26 | Folder health | Systems / Backup Guardian | Show local folder readiness | Backup Guardian / local system | Systems, Dashboard | Protected or local system evidence | Folder health services/tests | CONSUMED_EXTERNAL |
| 27 | Access registry | Users and Devices / Dashboard | Manage users, roles, approvals | Dashboard access control | Admin surfaces | Local/admin | Users/devices repository and screens | LOCAL_ONLY |
| 28 | User preferences | Settings / Dashboard | Store user and presentation preferences | Feature owners | Dashboard, all configurable views | Local - Dashboard | Settings repository and dashboard personalization | LOCAL_ONLY |
| 29 | Domain capture | Journal, Learning, Content, Business, Wellbeing / Dashboard | Capture domain-specific records | Each domain owner | Domain screens, Dashboard | Local - Dashboard | Domain repositories/screens | LOCAL_ONLY |
| 30 | Contextual navigation | Dashboard shell / all modules | Move between owned surfaces without changing ownership | Owning surface | Dashboard, Projects, Tasks, Planner, Engineering | Local navigation | Router and focused widget tests | LOCAL_ONLY |

## Boundary Findings

Dashboard-local capabilities are authored local state and local presentation. External capabilities are presented or consumed without being re-owned. Adapter/view-only capabilities must preserve source authority, read-only behavior, and bounded fallback; they are not candidates for a Dashboard registry yet.
