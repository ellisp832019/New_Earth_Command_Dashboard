# UI/UX Phase 2 Navigation Model

Audit date: 2026-08-26

## Navigation Layers

| Layer | Target destinations | Entry rule | Rationale |
|---|---|---|---|
| Home | Dashboard | Launch and persistent Home | One place to orient |
| Primary daily | Daily Flow, Tasks, Planner, Projects, Inbox | One action from primary navigation | Supports the daily loop |
| Secondary / More | Treasury, Assets, Meetings, Knowledge, Journal, Learning, Content, Business, Wellbeing, Systems, Company, Platform Core | Grouped by intent | Keeps occasional work accessible |
| Specialist | Engineering, Project Intelligence, Repo Research, Voice, Experiments, Launchpad, Grants, Module Hub, GAIA | More or contextual links | Prevents specialist competition with daily work |
| Admin / Settings | Settings, Users and Devices, module permissions | More or admin grouping | Separates configuration from work |
| Hardware / Development | Command Deck support, QR Studio, Calm UI Demo | Development or specialist grouping | Protects future hardware boundary |
| Future | Physical Command Deck, CAP-01, LANE-01 | Not normal navigation | Explicitly unimplemented |

## Key Route Decisions

- Dashboard to Daily Flow: zero additional route; the card is the home view.
- Dashboard to task execution: one action from Top 3 or Next Step, then Tasks or Project Detail.
- Dashboard to capture: one universal action; destination type is explicit.
- Dashboard to Project Detail: one action from Active Projects.
- Dashboard to Platform Core Status: More, then read-only status; specialist placement is intentional.
- Dashboard to Command Centre: one card action or a grouped integration entry; labels must distinguish coordination from command execution.
- Dashboard to Command Deck: no primary daily route; development/support entry only.

## Mobile Versus Desktop

The target should preserve a small mobile primary bar and use a more structured More screen rather than adding every specialist tool to primary navigation. Desktop may show more direct links, but categories should remain consistent across layouts.

## Back Navigation

Parent workspaces own return destinations. Contextual child screens should return to the originating project, meeting, asset or parent hub where known; direct deep links should fall back to the relevant hub, then Dashboard. This is a later implementation rule, not a current source change.

## Capability Boundary

Navigation is a view of capabilities. It must not create a second owner for tasks, project status, Platform Core declarations, NEOS observation, Command Centre orchestration, or Command Deck actions.
