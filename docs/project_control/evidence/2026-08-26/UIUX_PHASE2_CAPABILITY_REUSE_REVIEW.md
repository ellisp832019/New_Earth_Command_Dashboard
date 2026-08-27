# UI/UX Phase 2 Capability Reuse Review

Audit date: 2026-08-26
Reuse classification is evidence-based. Similar labels alone are not enough to create a shared capability.

| Capability | Really shared? | Canonical owner | Current consumers | Future consumers | Contract needed now? | Classification | Reason |
|---|---|---|---|---|---|---|---|
| Project identity | LATER | Dashboard Projects initially | Dashboard, Projects, Tasks, Project Detail | Engineering, NEOS adapters, GAIA | FALSE | LOCAL_NOW_POTENTIAL_SHARED_LATER | Same identity is useful across views, but canonical cross-repo identity evidence is incomplete |
| Project status | NO / LATER | Dashboard for authored status; NEOS for observation | Projects, Project Intelligence, Engineering | Command Centre, GAIA | FALSE | ADAPTER / VIEW ONLY | "Status" has multiple authority meanings |
| Task identity | LATER | Dashboard Tasks | Tasks, Top 3, Planner, Projects | GAIA, Command Centre | FALSE | LOCAL_NOW_POTENTIAL_SHARED_LATER | Semantics are stable locally but cross-system lifecycle is not proven |
| Capture envelope | LATER | Dashboard Capture initially | Dashboard Quick Capture, Inbox, Assets, Visual Capture | Voice, Command Deck | FALSE | LOCAL_NOW_POTENTIAL_SHARED_LATER | Generic capture and domain capture differ in required fields |
| Notifications | NO | Owning feature | Meeting/voice and feature-local surfaces | Dashboard summary later | FALSE | LOCAL_ONLY | No common semantics or owner evidence |
| Command/action IDs | YES candidate | Command Centre | Command Deck support, Dashboard command actions | Physical Command Deck, approved integrations | TRUE later | SHARED_CANDIDATE | Stable IDs and bounded invocation can reduce hardware/software coupling |
| Engineering status | NO / LATER | NEOS for observation, engineering owner for specialist evidence | Project Intelligence, Engineering | Dashboard, GAIA, Command Centre | TRUE at external boundary | CONSUMED_EXTERNAL_CAPABILITY | Dashboard must not own observed truth |
| Knowledge retrieval | YES external | CKCC / Librarian | Knowledge Library, Omega Knowledge Engine views | GAIA, future modules | TRUE at external boundary | CONSUMED_EXTERNAL_CAPABILITY | Retrieval is a separate system capability |
| Backup status | YES external | Backup Guardian | Systems, Backup Guardian, Dashboard summaries | Command Centre | TRUE at external boundary | CONSUMED_EXTERNAL_CAPABILITY | Recovery authority must remain external |
| Device identity | LATER | Users and Devices or hardware owner | Users and Devices | Command Deck, access control | TRUE later | SHARED_CANDIDATE | Multiple consumers are future, not yet proven |
| Settings | NO | Each feature owner | Settings and module settings | None justified | FALSE | LOCAL_ONLY | Similar UI does not mean identical setting semantics |
| User/device registry | LATER | Dashboard access control initially | Users and Devices | Command Deck permissions, Command Centre | TRUE later | LOCAL_NOW_POTENTIAL_SHARED_LATER | Future hardware permissions need a stable boundary |
| Audit events | LATER | Each owning system initially | Voice, Users and Devices, command surfaces | Command Centre, Command Deck | TRUE later | LOCAL_NOW_POTENTIAL_SHARED_LATER | Event semantics and retention are not unified |
| Workflow status | NO / LATER | Future Platform Core/LANE authority | Current features use local statuses | LANE-01, Command Centre, Dashboard | TRUE later | LOCAL_ONLY | Do not invent a global workflow service before CAP-01 |

## Shared Candidate Gate

Only command/action IDs currently meet the direction of a genuine shared candidate, and even that candidate remains design-only. It has a plausible future pair of consumers, stable identity semantics, and a bounded permission/audit boundary. No contract should be implemented in Phase 2.

## Reuse Decisions

- Reuse existing local task, project and capture capabilities inside Dashboard before extracting anything.
- Consume NEOS, Platform Core, CKCC/Librarian and Backup Guardian rather than recreating their authority.
- Keep provenance labels as a shared semantic vocabulary, not a global service yet.
- Treat Command Deck as a future consumer of stable, approved actions, never as a new authority.
- Do not create CAP-01 or LANE-01 registries from this review.
