# UI/UX Phase 1 Simplification Register

Audit date: 2026-08-26
These are candidate directions only. Nothing in this register was implemented.

| ID | Recommendation | Current state | Proposed direction | Why | User value | Risk | Dependencies | Authority impact |
|---|---|---|---|---|---|---|---|---|
| S-01 | KEEP / PROMOTE Daily Flow | Daily Flow is the protected Dashboard card and contains the core day loop | Keep it non-hideable and make its role explicit as the daily anchor | It is the only view that joins focus, Top 3, projects, capture and review | Very high | Low | Dashboard content audit | Preserves Dashboard as workspace |
| S-02 | CONSOLIDATE daily planning language | Tasks, Planner and Daily Flow all discuss focus, Top 3 and carry-forward | Define Daily Flow as orientation, Planner as planning, Tasks as execution, with consistent verbs and links | Reduces uncertainty without removing valid views | High | Medium | Shared UX vocabulary | Keeps one local operational authority |
| S-03 | MAKE CONTEXTUAL Quick Capture | Dashboard, Inbox, Assets and Visual Capture expose capture actions | Use one primary capture action with explicit destination type; retain domain capture when context is known | Prevents misrouting and duplicate entry | High | Medium | Capture taxonomy | Keeps domain repositories authoritative |
| S-04 | GROUP More by intent | More is a flat registry of support, admin and specialist tools | Group as Support, Operations, Specialist, Governance and Reference, with progressive disclosure | Lowers scan cost while retaining every route | High | Low | Information architecture review | No authority change |
| S-05 | RENAME or subtitle control surfaces | Command Centre, Command Deck and GAIA all use control language | Use plain-language subtitles and distinct action verbs such as coordinate, execute and advise | Makes orchestration roles obvious | High | Medium | Authority glossary | Reinforces Command Centre/GAIA boundaries |
| S-06 | PROMOTE provenance labels | Status screens are distributed and may use similar health terms | Standardize labels for Declared, Observed, Local, Configured and Recommended | Prevents false equivalence between authorities | High | Low | Shared status component | Strengthens authority separation |
| S-07 | MAKE project context reusable | Projects, Project Intelligence and Engineering Studio each have project context | Add contextual links and a shared project identity summary rather than merge data | Lets users move between operational and technical views safely | Medium | Medium | Project identity mapping | Keeps local, observed and specialist ownership distinct |
| S-08 | DEMOTE specialist tools from daily competition | Tools and More expose many specialist modules alongside daily routes | Keep accessible but visually subordinate to daily work | Protects attention and reduces first-run overwhelm | Medium | Low | More grouping | No data authority change |
| S-09 | REUSE shared empty/error state language | Each feature has its own loading, empty and error wording | Adopt a calm state vocabulary with next action and provenance | Reduces interpretation effort | Medium | Low | Content and component review | Makes bounded states clearer |
| S-10 | REDUCE route ambiguity for Company and Business | Company Command Centre appears in Home, More and Dashboard while Business is separate | Clarify Company as coordination and Business as authored opportunity tracking | Removes conceptual overlap | Medium | Medium | Domain decision | Requires explicit authority ownership |
| S-11 | KEEP Platform Core specialist and read-only | Platform Core Status is under More and is clearly read-only | Retain location, improve subtitle and provenance rather than promote it to daily navigation | Declared architecture is important but not a daily action | Medium | Low | Status language | Preserves Platform Core authority |
| S-12 | MAKE Search scoped | Command Palette is route/action heavy and content search is distributed | Keep command search, add future scopes for records and knowledge | Helps retrieval without turning palette into an overloaded home | Medium | Medium | Search model | Must respect source authority |
| S-13 | ARCHIVE LATER only after usage evidence | Calm UI Demo and several integration-ready modules are accessible | Use usage evidence before hiding or archiving any surface | Avoids premature deletion of valid future hooks | Low | Low | Analytics or review evidence | No immediate change |

## Recommended Sequence

1. Shared labels and provenance.
2. More grouping and mobile discoverability.
3. Daily Flow versus Tasks versus Planner role clarification.
4. Quick Capture destination clarity.
5. Command and project authority boundaries.
6. Specialist demotion or consolidation decisions only after usage review.

## Explicit Non-Decisions

No route should be deleted, no database should be merged, no authority should be reassigned, and no LANE-01 UI should be implemented based on this Phase 1 audit.
