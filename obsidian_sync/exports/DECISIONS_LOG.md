# New Earth Command Dashboard Decisions Log

The decision block is generated from repo docs and architecture notes.

<!-- AUTO-GENERATED:START -->
## Decision Log
| Decision | Reason | Status |
| --- | --- | --- |
| Local-first and offline-first for V0.1 | The app must work without login, cloud sync, or external services. | Active |
| Feature-based Flutter structure | Large module count stays understandable when each feature is isolated. | Active |
| Use go_router for navigation | The app needs clear route names and nested navigation. | Active |
| Use Riverpod when state is needed | State should stay explicit and testable. | Active |
| Separate documentation visuals from app UI | The brand assets are bold while the app UI must stay calm. | Active |

## Key Technical Decisions
- Local-first and offline-first for V0.1
- Feature-based Flutter structure
- Use go_router for navigation
- Use Riverpod when state is needed
- Separate documentation visuals from app UI

## Alternatives Considered
- Cloud-first storage and login were rejected for V0.1.
- A flatter folder structure was considered but would not scale well for the current module count.
- A different state management approach was considered, but Riverpod fits the local data flow well.

## Open Decisions
- How much of the Obsidian sync module should be copied into each downstream repo.
- When to activate the AI adapter beyond the current roadmap stub.
- Whether the next active slice should stay on voice polish or move to asset intelligence.

## Decisions That Need Peter's Review
- The next priority after voice polish.
- How quickly AI should move beyond the adapter contract.
- Whether the sync module should remain a repo-local tool or be copied into every downstream project.
<!-- AUTO-GENERATED:END -->
