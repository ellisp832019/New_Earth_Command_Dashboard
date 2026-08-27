# UI/UX Phase 2 Implementation Waves

Audit date: 2026-08-26
All waves are proposals. No implementation was performed.

| Wave | Goal | Modules / capabilities | Surfaces | Likely files | Risk | Dependencies | Rollback ease | Validation |
|---|---|---|---|---|---|---|---|---|
| W1 | Clarify language and provenance | status vocabulary, role labels, capture wording | Dashboard, More, Platform Core, Project Intelligence, Command surfaces | screen copy and shared presentation components | Low | Approved provenance standard | High | widget tests, copy review, analyze |
| W2 | Organize secondary navigation | navigation grouping, contextual entry | More, sidebar, mobile More | app shell, More screen, route tests | Low | Target navigation model | High | route tests, mobile/desktop review |
| W3 | Reduce duplicate entry ambiguity | contextual links, command labels, capture entry | Quick Capture, Inbox, Command Centre, Command Deck | Dashboard cards, More, command palette | Medium | Authority decisions | High | journey tests and manual route audit |
| W4 | Improve home hierarchy | card roles, optional visibility, active project attention | Dashboard cards, personalization | Dashboard screen, card layout/personalization | Medium | W1 role definitions | High | widget tests, small-window review |
| W5 | Connect planning and engineering context | task/project context, observed/declaration adapters | Tasks, Planner, Projects, Engineering, Project Intelligence | feature presentation and adapter boundaries | Medium/high | Authority map, project identity decision | Medium | integration/widget tests, provenance review |
| W6 | Demote Command Deck development surfaces | hardware boundary, action vocabulary, permissions labels | Command Deck, Tools, More, future device support | command deck UI only; no runtime contract yet | High | Command Centre and hardware ownership | Medium | permission/state review, no live device behavior |
| W7 | Stabilize capability evidence | evidence records for reusable candidates | project, task, capture, command and status views | documentation/tests first | Medium | CAP-01 decision, two real consumers | High | contract review, consumer tests |
| W8 | Validate daily usability | workday journey, accessibility, cognitive load | Whole Dashboard | test and evidence files | Low | W1-W7 decisions | High | journey walkthrough, widget tests, analyze |

## Wave 1 Readiness

Wave 1 is ready for a separate implementation decision because it is reversible, does not require a new cross-repo contract, and directly addresses the highest-value ambiguity. It must remain limited to wording, descriptions and provenance presentation.

## Explicit Exclusions

No wave authorizes route deletion, database/schema changes, global capability services, Platform Core registry changes, NEOS changes, GAIA runtime changes, Command Centre runtime changes, Command Deck runtime behavior, MCP operations, CAP-01 or LANE-01 implementation.
