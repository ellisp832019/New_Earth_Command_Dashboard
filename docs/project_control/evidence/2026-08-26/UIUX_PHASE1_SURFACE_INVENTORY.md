# UI/UX Phase 1 Surface Inventory

Audit date: 2026-08-26
Repository: New Earth - Command Dashboard
Mode: Read-only audit

## Inventory Method

The inventory is grouped at meaningful user-facing workspace level. Leaf routes, create/edit screens, reports, settings pages, and specialist sub-pages are included in the route or notes column rather than counted as separate products. Sources inspected include `lib/core/routing/route_names.dart`, `lib/core/routing/app_router.dart`, `lib/core/widgets/app_shell.dart`, `lib/features/more/presentation/more_screen.dart`, and the feature presentation folders.

## Surface Inventory

| ID | Display name | Route / entry point | Purpose and primary action | Authority | Mode | Maturity | Daily value | Duplication risk | Classification |
|---|---|---|---|---|---|---|---|---|---|
| S01 | Dashboard Home | `/dashboard`; launch and Home nav | Orient on focus, Top 3, projects, next step, capture, review; open the next useful action | Dashboard-local operational state | Mixed | Established | Very high | Medium | CORE DAILY |
| S02 | Daily Flow | Dashboard `daily_flow` card | Set focus, choose Top 3, see active projects, capture, review and carry forward | Dashboard-local plans, tasks and projects | Mixed | Established | Very high | Low | CORE DAILY |
| S03 | Top 3 | Daily Flow and Tasks/Planner | Select and complete the three most important tasks | Dashboard-local tasks and daily plan | Mixed | Established | Very high | Medium | CORE DAILY |
| S04 | Next Step | Dashboard `next_step` card | Surface a practical recommended action | Dashboard-local project/task state | Read | Established | High | Medium | CORE DAILY |
| S05 | Active Projects | Daily Flow card and Projects | See projects needing attention and open detail | Local projects | Read | Established | High | Medium | CORE DAILY |
| S06 | Quick Capture | Dashboard card; Assets QR/Visual Capture variants | Save a thought, inbox item, asset or visual capture quickly | Local inbox/assets/files | Mixed | Established | High | High | CORE DAILY |
| S07 | Evening Review | Dashboard card; Planner review query | Record review, tomorrow focus and carry-forward | Local daily plans/journal/tasks | Mixed | Established | High | Medium | CORE DAILY |
| S08 | Tasks | `/tasks`; nav, Dashboard and command palette | Filter, create, edit, park, archive and manage tasks | Local task database | Mixed | Established | High | High | CORE DAILY |
| S09 | Planner | `/planner`; nav and Dashboard | Plan today, Top 3, carry-forward, tomorrow and review | Local daily plan database | Mixed | Established | High | High | CORE DAILY |
| S10 | Projects Workspace | `/projects`; nav and project actions | Browse active projects and create a project | Local project database | Mixed | Established | Medium | Medium | CORE OCCASIONAL |
| S11 | Project Detail | `/projects/:id`; project list, Dashboard and intelligence | Review project context, tasks, journal, modules and next action | Local project/task/journal state | Mixed | Established | Medium | Medium | CORE OCCASIONAL |
| S12 | Inbox | `/inbox`; Support nav, Dashboard and command palette | Process captured ideas and notes | Local inbox database | Mixed | Established | High | High | CORE DAILY |
| S13 | Treasury | `/treasury`; nav and Dashboard card | Review finances, decisions, pots, monthly summary and setup | Local Treasury folder and database | Mixed | Established | Medium | Medium | CORE OCCASIONAL |
| S14 | Assets | `/assets`; nav and Dashboard actions | Inventory equipment, parts, locations, orders and maintenance | Local asset database and Omega OS folders | Mixed | Established | Medium | Medium | SPECIALIST |
| S15 | QR Studio | `/assets/qr-studio`; Tools nav and Assets | Register, print, scan and review asset labels | Local asset register and files | Mixed | Established | Occasional | High | SPECIALIST |
| S16 | Meetings | `/more/meetings`; More and Dashboard | Plan meetings, decisions, actions, follow-ups and bundles | Local meeting database and folders | Mixed | Established | Medium | Medium | CORE OCCASIONAL |
| S17 | Knowledge Library | `/more/knowledge-library`; More and Dashboard | Search local PDF catalogue and open extractable items | Local Omega OS document catalogue | Read | Established | Occasional | High | SUPPORT |
| S18 | Engineering Studio | Module package route; Tools, More and module hub | Inspect engineering projects, circuits, PCBs, firmware, devices and validation | Engineering module mock/local data | Mixed | Specialist | Occasional | Medium | SPECIALIST |
| S19 | Project Intelligence | `/projects-intelligence`; More and project redirects | Review project and repository health through bridge views | Repo intelligence bridge and local project state | Read | Established | Occasional | High | SPECIALIST |
| S20 | Systems | `/more/systems`; More | Review local protection and recovery workspace | Backup/system services and folders | Mixed | Established | Occasional | Medium | ADMIN |
| S21 | Backup Guardian | `/more/systems/backup-guardian`; Systems | Review backup readiness, recovery and protection state | Backup Guardian local service | Mixed | Established | Occasional | Medium | ADMIN |
| S22 | Folder Health | `/more/omega-os-health`; More | Check Treasury, Assets, Visual Capture and reserved folders | Folder health service | Read | Established | Occasional | High | ADMIN |
| S23 | GAIA AI Employee | `/more/ai-employee`; More when enabled | Review recommendations and hand off execution | GAIA adapters and local context | Mixed | Integration-ready | Low | Medium | SPECIALIST |
| S24 | Voice Intelligence | `/voice`; Support nav and More | Use notes, meeting summaries, MicroGrow status and audit log | Local voice services and audit data | Mixed | Established | Occasional | Medium | SPECIALIST |
| S25 | Voice Assistant | `/voice-assistant`; More and dock | Review spoken commands before dashboard actions | Local voice assistant state | Mixed | Established | Occasional | High | SPECIALIST |
| S26 | Alexa Voice Gateway | `/more/alexa-voice-gateway`; More/sidebar | Review guarded Alexa doorway and audit trail | Local gateway/audit state | Read | Guarded | Low | High | SPECIALIST |
| S27 | Command Deck | `/more/command-deck`; Tools, More and Dashboard | Run local Stream Deck commands and shortcuts | Local command registry | Mixed | Established | Occasional | High | SPECIALIST |
| S28 | Company Command Centre | `/modules/company-command-centre`; Home, More and Dashboard | Coordinate company records, LinkedIn planning and reports | Company folder/index services | Mixed | Established | Occasional | High | SPECIALIST |
| S29 | Platform Core Status | `/more/platform-core`; More | Review declared architecture, identity, contracts and source status | Platform Core declaration source | Read | Established | Occasional | Medium | SPECIALIST |
| S30 | More | `/more`; nav | Entry registry for support, admin and specialist tools | Navigation registry | Mixed | Established | Low | Medium | SUPPORT |
| S31 | Module Hub | `/more/module-hub`; More | Inspect, enable, dock and govern modules | Local module registry/manifest | Mixed | Established | Occasional | Medium | ADMIN |
| S32 | Education and Learning Hub | `/modules/education-learning-hub`; More/module routes | Browse lessons, pathways, projects and progress | Local education content pack | Mixed | Integration-ready | Low | Medium | SUPPORT |
| S33 | Omega Knowledge Engine | Module package route; More/module hub | Scan repositories and build learning or architecture notes | Local scanner and knowledge outputs | Mixed | Integration-ready | Low | High | SPECIALIST |
| S34 | Experiment Workspace | `/experiments`; More | Manage experiments, evidence, results, lessons and reports | Local experiment data | Mixed | Established | Occasional | Medium | SPECIALIST |
| S35 | Launchpad | `/launchpad`; More and Dashboard | Manage campaigns, rewards, readiness, finance and risk | Local launchpad data | Mixed | Established | Low | Medium | SPECIALIST |
| S36 | Funding and Grants | `/more/funding-grants`; More | Track applications, readiness and folder packs | Local grant records and folders | Mixed | Established | Low | Medium | SPECIALIST |
| S37 | Repo Research Engine | `/more/repo-research-engine`; More | Scan repositories, compare changes and export research packs | Local repo research service | Mixed | Specialist | Low | High | SPECIALIST |
| S38 | Journal | `/journal`; Support nav and More | Record progress, lessons, decisions and reflections | Local journal database | Mixed | Established | Medium | Medium | SUPPORT |
| S39 | Learning | `/learning`; Support nav and More | Track skills and learning items | Local learning database | Mixed | Established | Low | Medium | SUPPORT |
| S40 | Content | `/content`; Support nav and More | Plan posts, website updates, videos and book ideas | Local content database | Mixed | Established | Low | Medium | SUPPORT |
| S41 | Business | `/business`; Support nav and More | Track opportunities, funding, jobs and partnerships | Local business database | Mixed | Established | Low | Medium | SUPPORT |
| S42 | Wellbeing | `/wellbeing`; Support nav and More | Record energy, mood, stress and balance | Local wellbeing database | Mixed | Established | Low | Low | SUPPORT |
| S43 | Visual Capture | `/visual-capture`; More and Assets | Review receipt, asset and capture inbox files | Local files and asset records | Mixed | Established | Occasional | High | SUPPORT |
| S44 | Users and Devices | `/users-devices`; sidebar Control | Manage users, devices, roles, approvals, permissions and audit | Local access-control database | Mixed | Established | Low | Medium | ADMIN |
| S45 | Settings | `/settings`; sidebar, More and module settings | Configure Dashboard cards and local preferences | Local settings database | Mixed | Established | Occasional | Medium | ADMIN |
| S46 | About and Help | `/more/about-help`; About sidebar and More | Explain Dashboard, links, templates and support | Local documentation | Read | Established | Occasional | Low | SUPPORT |
| S47 | Search / Command Palette | `/dashboard/search`; Tools, keyboard shortcut and Dashboard | Find routes, actions, projects and tasks | Dashboard-local state and route registry | Read / action launch | Established | High | High | CORE DAILY |
| S48 | Calm UI Demo | `/dashboard/calm-ui-demo`; internal route | Demonstrate visual language and calm patterns | Static sample data | Read | Demo | None | Medium | FUTURE / PLACEHOLDER |

## Classification Totals

- Total user-facing surfaces: 48 grouped surfaces.
- Core daily: S01-S09, S12, S47: 12.
- Core occasional: S10-S13 and S16: 5.
- Support: S17, S30, S32, S38-S43, S46: 10.
- Admin: S20-S22, S31, S44-S45: 6.
- Specialist: S14-S15, S18-S19, S23-S29, S33-S37: 16.
- Future / placeholder: S48: 1.

These are primary classifications. Duplication and hide/consolidate candidates are review labels, not deletions or current product decisions.

## Navigation Hierarchy

Desktop presents Home, Control, Work, Support, Tools and About in a persistent sidebar. Mobile presents Dashboard, Assets, Treasury, Projects, Tasks, Planner and More in the primary navigation bar. The Dashboard is the launch destination and the only surface that directly assembles focus, Top 3, active projects, capture and review.

The sidebar makes Projects, Tasks and Planner one click away. Inbox, Journal, Learning, Content, Business, Wellbeing and Voice are also one click away on desktop but are hidden under More on mobile. Platform Core Status is two steps on both layouts: More, then Platform Core Status. Company Command Centre is one desktop step but two steps on mobile through More or via a Dashboard card.

The route tree contains useful redirects for legacy Project Intelligence and several module aliases, but the number of leaf routes is materially larger than the primary navigation suggests. Back buttons are generally provided by `WorkspaceShell`; deep specialist screens often rely on parent-specific back destinations.

## Navigation Findings

- Daily priorities: immediate on Dashboard; one screen and zero extra clicks after launch.
- Active projects: immediate Daily Flow panel; one click to project detail.
- Current task and next action: immediate Top 3 and Next Step; one click to Tasks or project detail.
- Quick Capture: visible on Dashboard; one action opens a modal or route, but Inbox and asset/visual capture variants compete.
- Engineering health: one click desktop through Tools, two clicks mobile through More and the module package; Project Intelligence is a separate health concept.
- Platform Core Status: two clicks from More; discoverability is adequate for specialist use but not daily work.
- Treasury and Assets: one click from primary navigation on desktop/mobile.
- Meetings and Knowledge: two clicks through More; acceptable for occasional use.
- Systems and Backup: More then Systems, then Backup Guardian; three screens for deep recovery tools.
- Command Centre: Dashboard card, sidebar Company, or More; multiple labels and paths are present.
- Command Deck: Tools, More and Dashboard support stack; clear intent but duplicated entry points.
- Settings: one click desktop/sidebar or two clicks mobile/More; module settings add parallel configuration surfaces.

## Audit Boundary

No source, route, UI, database, configuration or generated file was changed. This inventory records the current product surface only.
