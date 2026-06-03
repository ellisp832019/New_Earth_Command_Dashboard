# Gaia Decisions

## Decision Log

| Date | Decision | Reason | Status |
|---|---|---|---|
| 2026-05-02 | Local-first and offline-first for V0.1 | The app is a personal command dashboard and must work without login or cloud sync | Active |
| 2026-05-02 | Feature-based Flutter structure with shared core services | Many modules need to stay simple and easy to understand | Active |
| 2026-05-02 | Use `go_router` for navigation | The app needs clear route names and nested navigation | Active |
| 2026-05-02 | Use Riverpod when state is needed | State should stay explicit, testable, and separate from UI | Active |
| 2026-05-02 | Use Drift and SQLite for local data | The MVP must keep durable local storage and offline behavior | Active |
| 2026-05-09 | Keep voice capture review-first | The user should always review transcript and intent before save | Active |
| 2026-05-10 | Share one voice session state machine across wake, dock, and assistant | Only one voice path should own listening or speaking at a time | Active |

## Key Technical Decisions

- Local-first and offline-first for V0.1
- Feature-based folder structure with shared core infrastructure
- `go_router` for navigation
- Riverpod for app state where needed
- Drift and SQLite for persistent local data
- Review-first voice capture and save flows
- Shared voice session coordination for wake, dock, and assistant paths

## Alternatives Considered

- Cloud-first storage and login were considered, but they conflict with the V0.1 local-first rule
- A flatter folder structure was possible, but the module count is too large for that to stay readable
- A different state management approach was possible, but Riverpod fits the explicit local-data flow better
- A single always-on voice path was possible, but it would make the experience harder to control and debug

## Open Decisions

- Which AI adapter shape should be used when the assist layer starts
- How much of the Obsidian sync folder should be copied into the root repo, if any
- Whether the next code slice should stay on voice polish or switch to asset intelligence
- How far the knowledge library and treasury modules should grow before the next integration pass

## Needs Peter Review

- The next priority after voice polish
- Whether AI should stay parked until the local voice path is fully calm
- Whether the sync module should be added to the root repo now or kept as a supporting module
- Any change in priority between voice, assets, and knowledge work
