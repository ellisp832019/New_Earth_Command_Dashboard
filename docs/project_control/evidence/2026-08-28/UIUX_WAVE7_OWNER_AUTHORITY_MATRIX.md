# UIUX Wave 7 Owner and Authority Matrix

| Capability family | Canonical owner | Dashboard behavior | Local authored state | Write capability in Dashboard | Read-only / fallback evidence |
|---|---|---|---|---|---|
| Daily focus, Top 3, planning, review | Dashboard / Planner | Owns and edits local plan | Yes | Yes | Local repository tests |
| Tasks | Dashboard Tasks | Owns lifecycle and inventory | Yes | Yes | Task repository/controller tests |
| Projects | Dashboard Projects | Owns human project context | Yes | Yes | Project repository/detail tests |
| Engineering evidence | Engineering system | Presents specialist evidence | No for observed data | Specialist-defined | NEOS reader and engineering tests |
| Project Intelligence | NEOS / engineering observer | Read-only adapter | No | No | Snapshot/source tests; bounded fallback |
| Repo Intelligence | Repository observer / bridge | Read-only repository evidence | No | No | Bridge controller tests |
| Platform Core declarations | Platform Core | Presents declared status | No | No | Governed-status tests |
| GAIA recommendations | GAIA | Presents interpreted recommendations | No | No direct write | GAIA tests and provenance boundary |
| Command Centre operations | Command Centre | Launches/presents orchestration | No | No ownership transfer | Command Centre screen/service tests |
| Backup and recovery | Backup Guardian | Presents protected status | No | No | Backup/folder-health tests |
| Knowledge retrieval | CKCC / Librarian | Presents indexed results | No | No | Knowledge/retrieval tests |
| Command Deck | Dashboard support now; hardware owner later | Software preview/emulator only | Config and local logs only | Bounded local command behavior | Command Deck tests; no physical transport |
| Users, roles, approvals | Dashboard access control | Owns local access administration | Yes | Yes | Users/devices/security tests |
| Settings and personalization | Feature owners | Owns local preferences | Yes | Yes | Settings/layout tests |

## Authority Rules

- Dashboard is the human-facing operational workspace, not the owner of observed, declared, interpreted, operational, protected, or indexed external state.
- Command Deck is a future physical/tactile interface preview, not a second Dashboard, Command Centre, or system authority.
- Provenance labels remain vocabulary, not a new shared service.
- No Dashboard write affordance should mutate NEOS, Platform Core, GAIA, Command Centre, Backup Guardian, or CKCC state.
