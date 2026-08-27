# UI/UX Phase 2 Module And Capability Map

Audit date: 2026-08-26

## Module Map

| Module ID | Module | System | Main capabilities | Current owner | Canonical owner | Authority | Consumers | Reuse potential | Maturity |
|---|---|---|---|---|---|---|---|---|---|
| M01 | Daily Work | Command Dashboard | today focus, Top 3, next step, review | Dashboard | Dashboard | Local | Dashboard | Local only | Established |
| M02 | Tasks | Command Dashboard | task identity, status, filtering, execution | Dashboard | Dashboard | Local | Dashboard, Projects, Planner | Potential shared later | Established |
| M03 | Planning | Command Dashboard | schedule, tomorrow, carry-forward, review | Dashboard | Dashboard | Local | Dashboard, Planner | Local only | Established |
| M04 | Projects | Command Dashboard | project identity, context, progress | Dashboard | Dashboard | Local | Dashboard, Tasks, Engineering links | Potential shared later | Established |
| M05 | Capture and Inbox | Command Dashboard | capture envelope, inbox processing | Dashboard | Dashboard initially | Local | Dashboard, Inbox, domain capture | Potential shared later | Established |
| M06 | Treasury | Command Dashboard | finance overview, decisions, pots | Dashboard | Dashboard Treasury | Local | Dashboard, Treasury | Local only | Established |
| M07 | Assets | Command Dashboard | inventory, labels, maintenance, orders | Dashboard | Dashboard Assets | Local/specialist | Assets, Dashboard | Potential shared later | Established |
| M08 | Meetings | Command Dashboard | meeting, decisions, actions, follow-ups | Dashboard | Dashboard Meetings | Local | Meetings, Dashboard | Potential shared later | Established |
| M09 | Knowledge | Dashboard / CKCC | catalogue, retrieval, indexed items | Mixed | CKCC/Librarian for retrieval | Indexed | Knowledge views, future consumers | Consumed external | Integration-ready |
| M10 | Engineering | Engineering system / Dashboard adapter | technical evidence, engineering workflows | Engineering owner | Engineering system | Specialist/observed | Engineering, Projects | Consumed external | Specialist |
| M11 | Governed Status | Dashboard / Platform Core adapter | declared status presentation | Dashboard view | Platform Core | Declared | Platform Core Status | Adapter only | Established |
| M12 | Command Centre Integration | Dashboard / Command Centre | orchestration launch and status view | Command Centre | Command Centre | Operational | Dashboard, Company views | Consumed external | Established |
| M13 | Command Deck Support | Dashboard / hardware boundary | stable command invocation support | Dashboard support | Command Centre plus hardware owner | Operational | Future device, Dashboard support | Potential shared later | Development |
| M14 | Systems and Backup | Dashboard / Backup Guardian | protection, recovery, folder health | Backup services | Backup Guardian | Protected | Systems, Dashboard | Consumed external | Established |
| M15 | Users and Devices | Dashboard | users, devices, roles, approvals, audit | Dashboard | Dashboard access control | Admin | Admin surfaces | Potential shared later | Established |
| M16 | Business | Dashboard | opportunities, funding, partnerships | Dashboard | Dashboard Business | Local | Business, Company views | Local only | Established |
| M17 | Wellbeing | Dashboard | energy, mood, stress, balance | Dashboard | Dashboard Wellbeing | Local | Wellbeing | Local only | Established |
| M18 | Settings | Dashboard | preferences, card layout, module settings | Dashboard/features | Each owning feature | Local/admin | All configurable surfaces | Local only | Established |
| M19 | Learning and Content | Dashboard | learning items, content planning | Dashboard | Dashboard domains | Local | Learning, Content, Company links | Local only | Established |
| M20 | Visual Capture | Dashboard / Assets | image/file capture and review | Dashboard | Dashboard Assets/files | Local/files | Visual Capture, Assets | Potential shared later | Established |
| M21 | Voice | Dashboard / voice systems | notes, assistant, gateway, audit | Voice owner | Voice systems | Local/controlled | Voice surfaces, Dashboard | Consumed external | Established |
| M22 | GAIA | Dashboard / GAIA | interpretation, recommendation, handoff | GAIA | GAIA | Interpreted | GAIA view, future consumers | Consumed external | Integration-ready |

## Target Capability Set

The target map contains 30 capability concepts: daily focus, Top 3 selection, next-step recommendation, task identity, task inventory, planning, review/carry-forward, project identity, project context, capture envelope, inbox processing, treasury summary, asset identity, meeting actions, indexed retrieval, engineering evidence, declared status, observed status, provenance labeling, orchestration launch, stable command IDs, bounded permissions, device identity, audit events, backup status, folder health, access registry, user preferences, domain capture and contextual navigation.

These are concepts, not new services. Most remain local. No capability registry or global service is proposed in this phase.

## Consumer Rule

Dashboard cards and navigation are adapters/views of module capabilities. A card must not become the owner of task, project, treasury, Platform Core, NEOS, GAIA, Command Centre or Backup Guardian data.
