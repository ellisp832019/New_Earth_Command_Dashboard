# Developer Notes

## Where to add new content

- Add domain entities in `lib/features/omega_engineering_studio/domain/engineering_models.dart`.
- Add repository seed data and persistence helpers in `lib/features/omega_engineering_studio/data/engineering_repository.dart`.
- Add query and summary logic in `lib/features/omega_engineering_studio/application/engineering_services.dart`.
- Add UI cards, tabs, and empty states in `lib/features/omega_engineering_studio/presentation/engineering_studio_screen.dart`.

## Integration hooks

- Omega Knowledge Engine opens through the existing local route at `RouteNames.omegaKnowledgeEngine`.
- GAIA assistant opens through the existing local route at `RouteNames.voiceAssistant`.
- Replace the placeholder routes with richer handoffs later, but keep the same buttons and hook labels.
- The global module switcher in the app title bar should use the module registry and each module's first registered route as the home launch target.
- When a module grows into multiple section screens, keep the module home route stable and add children underneath it.

## Local storage

- The repository currently seeds mock data in code.
- Persisted state can later live under `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/data/`.
- Keep the repository interface stable so a Drift-backed implementation can replace the mock layer later.

## UI guidance

- Keep the dashboard calm and practical.
- Prefer concise status chips over dense tables.
- Show one next action for each workspace card.
- Keep progress tracking visible but not noisy.

## Adding future features

- Split a screen into its own route only when the shell starts to feel crowded.
- Add new integration hooks as buttons or cards first, then wire the backend later.
- Keep engineering wording neutral and calm. Use `Parked`, `Ready`, `Needs attention`, and `Carry forward` instead of failure language.
- If the title-bar dropdown needs another module, add its manifest routes first, then let the module registry pick it up automatically.
