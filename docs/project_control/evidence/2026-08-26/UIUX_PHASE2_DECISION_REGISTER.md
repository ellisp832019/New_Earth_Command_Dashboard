# UI/UX Phase 2 Decision Register

Audit date: 2026-08-26
Mode: Decision and design only
Source evidence: Phase 1 UI/UX evidence documents dated 2026-08-26

## Decision Rules

Every decision identifies system, module, capability, canonical owner, authority, consumers, reuse classification, dependencies and evidence. No decision authorizes source, route, database, schema, runtime, Platform Core, NEOS, GAIA, Command Centre or Command Deck changes.

| ID | Area | System / module | Capability | Current state | Target state | Canonical owner | Authority | Reuse | Decision | Priority | Risk / reversibility |
|---|---|---|---|---|---|---|---|---|---|---|---|
| D-01 | Daily Flow | Command Dashboard / Daily Work | Today focus and working view | Protected Dashboard card containing focus, Top 3, projects, capture and review | Keep as the canonical focused workday view | Command Dashboard | Local authored operational state | Local only | KEEP | P1 | Low / highly reversible |
| D-02 | Planner | Command Dashboard / Planning | Future scheduling and review | Overlaps Daily Flow actions | Reserve for future scheduling, tomorrow planning and detailed review | Command Dashboard | Local authored operational state | Local only | CHANGE ROLE | P1 | Low / reversible |
| D-03 | Tasks | Command Dashboard / Tasks | Actionable work inventory | Task list and Top 3 actions overlap | Make Tasks the underlying actionable inventory and execution view | Command Dashboard | Local authored operational state | Local now, potential shared later | CHANGE ROLE | P1 | Medium / reversible |
| D-04 | Projects | Command Dashboard / Projects | Project context and progress | Operational project home with detail screens | Keep as human project context and grouping; link specialist evidence contextually | Command Dashboard | Local authored operational state | Local now, potential shared later | KEEP | P1 | Medium / reversible |
| D-05 | Quick Capture | Command Dashboard / Capture | Universal fast input | Several capture variants exist | Define universal capture semantics; keep current UI local until two real consumers share a contract | Command Dashboard initially | Local authored input | Local now, potential shared later | KEEP / DEFINE | P1 | Medium / reversible |
| D-06 | Inbox | Command Dashboard / Capture | Temporary processing destination | Inbox is a separate route and repository | Keep as processing destination, not a second capture authority | Command Dashboard | Local authored operational state | Local only for now | KEEP / CLARIFY | P1 | Low / reversible |
| D-07 | Project Intelligence | Command Dashboard / Engineering | Repository observation view | Separate project/repo health bridge | Keep as adapter/view of observed truth, not project authority | NEOS or owning observation source | Observed | Consumed external capability | ADAPTER / VIEW | P1 | High authority sensitivity |
| D-08 | Engineering | Command Dashboard / Engineering Studio | Technical evidence and workflows | Specialist engineering module | Keep specialist and project-context aware; do not merge with Projects | Engineering system owner | Specialist engineering evidence | Consumed or local module capability | KEEP | P2 | Medium / reversible |
| D-09 | Platform Core Status | Command Dashboard / Governed Status | Declared architecture status | Read-only specialist view under More | Keep read-only and separate from observed health | Platform Core | Declared | Adapter/view only | KEEP | P1 | High authority sensitivity |
| D-10 | Command Centre | Command Dashboard / Integration | Orchestration entry | Dashboard, Home and More entry points | Keep software orchestration destination; describe by coordination job | Command Centre | Operational | Consumed external capability | ADAPTER / VIEW | P1 | High / reversible labels only |
| D-11 | Command Deck | Command Dashboard / Hardware Support | Stable command invocation support | Current software command screen appears alongside daily tools | Classify as future/specialist hardware interface; keep out of primary daily navigation | Command Centre for orchestration; hardware owner for device | Operational command boundary | Local now, potential shared later | DEMOTE | P1 | High if permissions blur |
| D-12 | Treasury | Command Dashboard / Treasury | Finance overview and decisions | Primary nav and optional home card | Retain as core occasional; home prominence remains user-dependent | Command Dashboard Treasury domain | Local authored financial state | Local only | KEEP / REVIEW CARD | P2 | Medium |
| D-13 | Knowledge | Command Dashboard / Knowledge | Catalogue and retrieval views | Library, Knowledge Engine and Help overlap in search cues | Separate indexed retrieval, generated analysis and product help | CKCC/Librarian for retrieval; Dashboard for view | Indexed / local documentation | Consumed external capability | GROUP / LABEL | P2 | Medium |
| D-14 | Systems / Backup | Command Dashboard / Systems | Protection and recovery status | Systems, Backup Guardian and Folder Health are layered | Keep separate scopes under one systems group | Backup Guardian for recovery; Dashboard for view | Protected | Consumed external capability | GROUP / LABEL | P2 | Medium |
| D-15 | More | Command Dashboard / Navigation | Secondary surface registry | Flat mixed registry | Group by user intent and demote specialist/development surfaces | Command Dashboard | Navigation | Local only | REORGANIZE | P1 | Low / reversible |
| D-16 | Home cards | Command Dashboard / Daily Work | Card layout views | Five customizable cards | Keep Daily Flow; retain others as optional/contextual with sharper jobs | Command Dashboard | Local authored presentation state | Local only | REDEFINE | P1 | Low / reversible |
| D-17 | Settings / Admin | Command Dashboard / Settings | Preferences and access controls | Global and module settings are distributed | Keep domain ownership, add a future settings map; do not merge stores | Dashboard for preferences; domain owners for domain settings | Local/admin | Local only | KEEP / MAP | P2 | Medium |
| D-18 | Calm UI Demo | Command Dashboard / Demo | Visual pattern demonstration | Reachable demo route | Keep development/demo only and remove from normal prominence later | Dashboard design owner | Static/demo | Local only | DEMOTE | P3 | Low / reversible |

## Capability Decision Summary

- Shared canonical now: none proven by Phase 1 evidence.
- Shared candidates later: project identity, task identity, capture envelope, command IDs, audit events, device identity and status provenance.
- Consumed external capabilities: NEOS observed health, Platform Core declarations, CKCC/Librarian retrieval, Backup Guardian recovery, Command Centre orchestration and GAIA recommendations.
- Adapter/view only: Dashboard status cards, Project Intelligence bridge, Platform Core Status screen, Command Centre launch card and Backup/Folders summaries.

## Evidence Basis

The Phase 1 inventory found 48 grouped surfaces, no P0 friction, and P1 overlap in daily planning, capture, navigation, commands and project/engineering boundaries. These decisions preserve authority and prefer reversible labels, grouping and contextual links before structural consolidation.
