# UIUX Wave 7 Module Inventory

Audit date: 2026-08-28  
Method: route declarations, feature source, providers/models, repositories, module manifests, and focused tests. Presentation-only Waves 3-6 were treated as non-module changes.

## Inventory

| ID / module | System | Purpose | User-facing | Routes / surfaces | Owning area | Primary user | Status / evidence |
|---|---|---|---|---|---|---|---|
| M01 Daily Work | Command Dashboard | Today focus, Top 3, next useful action, review | TRUE | `/dashboard` | Dashboard | All dashboard users | Established; `dashboard_screen.dart`, `widget_test.dart` |
| M02 Tasks | Command Dashboard | Actionable work inventory and lifecycle | TRUE | `/tasks` | Tasks | All dashboard users | Established; task repositories and widget tests |
| M03 Planning | Command Dashboard | Tomorrow, carry-forward, and review planning | TRUE | `/planner` | Planner | All dashboard users | Established; `daily_plan_repository_test.dart`, `widget_test.dart` |
| M04 Projects | Command Dashboard | Human project identity, context, progress, next action | TRUE | `/projects`, project detail/edit | Projects | Project owners | Established; project repository/controller tests |
| M05 Capture and Inbox | Command Dashboard | Capture, triage, and handoff into work | TRUE | `/inbox`, quick-capture surfaces | Inbox / capture | All dashboard users | Established; inbox and capture tests |
| M06 Treasury | Command Dashboard | Finance overview, pots, decisions, and settings | TRUE | `/treasury` and child surfaces | Treasury | Finance user | Established; treasury screen/controller tests |
| M07 Assets | Command Dashboard | Inventory, labels, maintenance, orders | TRUE | `/assets` and child surfaces | Assets | Asset operator | Established; asset screen/service tests |
| M08 Meetings | Command Dashboard | Meetings, decisions, actions, follow-ups | TRUE | `/more/meetings` and child surfaces | Meetings | Meeting owner | Established; meeting workflow tests |
| M09 Knowledge | Dashboard / CKCC | Catalogue and retrieval views | TRUE | Knowledge Library / Omega Knowledge Engine | Dashboard adapter; CKCC retrieval authority | Knowledge user | Integration-ready; knowledge screen/service tests |
| M10 Engineering | Engineering system / Dashboard adapter | Specialist technical evidence and workflows | TRUE | `/more/omega-engineering-studio` and sections | Engineering | Technical user | Specialist; route, scope, repository, and NEOS tests |
| M11 Governed Status | Dashboard / Platform Core adapter | Declared status presentation | TRUE | Platform Core Status | Dashboard view | Operator / reviewer | Established adapter; governed-status tests |
| M12 Command Centre Integration | Dashboard / Command Centre | Orchestration launch and status view | TRUE | Company Command Centre surfaces | Command Centre | Operator | Established integration view; screen/service tests |
| M13 Command Deck Support | Dashboard / hardware boundary | Software preview and bounded local command support for future hardware | TRUE | `/more/command-deck` | Dashboard support; future hardware owner | Developer / hardware designer | Development; Command Deck screen/service tests |
| M14 Systems and Backup | Dashboard / Backup Guardian | Protection, recovery, and folder health | TRUE | Systems / Backup Guardian surfaces | Backup services | Operator | Established protected view; backup/system tests |
| M15 Users and Devices | Command Dashboard | Users, devices, roles, approvals, access audit | TRUE | `/users-devices` and child surfaces | Dashboard access control | Administrator | Established; users/devices tests |
| M16 Business | Command Dashboard | Opportunities, funding, partnerships | TRUE | `/business` | Business | Business user | Established; business tests |
| M17 Wellbeing | Command Dashboard | Energy, mood, stress, balance | TRUE | `/wellbeing` | Wellbeing | Individual user | Established; wellbeing tests |
| M18 Settings | Command Dashboard | Preferences, card layout, and feature settings | TRUE | `/settings` and module settings | Feature owners / admin | Administrator | Established; settings and dashboard layout tests |
| M19 Learning and Content | Command Dashboard | Learning items and content planning | TRUE | `/learning`, `/content` | Learning / Content | Creator / learner | Established; repository and screen tests |
| M20 Visual Capture | Dashboard / Assets | Image/file capture and review | TRUE | `/visual-capture` | Assets / files | Capture user | Established; visual-capture tests |
| M21 Voice | Dashboard / voice systems | Notes, assistant, gateway, and audit | TRUE | `/voice` and child surfaces | Voice systems | Voice user | Established / controlled; voice tests |
| M22 GAIA | Dashboard / GAIA | Interpreted recommendations and handoff | TRUE | GAIA employee surface | GAIA | Operator seeking recommendations | Integration-ready; GAIA screen/controller tests |

## Comparison

| Measure | Phase 2 baseline | Current | Result |
|---|---:|---:|---|
| Modules | 22 | 22 | Unchanged |
| Added | - | 0 | None |
| Removed | - | 0 | None |
| Renamed | - | 0 | None |
| Merged | - | 0 | None |
| Split | - | 0 | None |

Waves 3-6 removed duplicate entry points and clarified presentation hierarchy, but did not add, remove, rename, merge, or split a module. Route declarations remain unchanged at the audited count of 163.

## Notes

- A module is listed only where source and/or route evidence exists.
- Future hardware, LANE, and CAP-01 concepts are not counted as modules.
- “System” identifies the authority boundary, not merely the Flutter folder containing the view.
