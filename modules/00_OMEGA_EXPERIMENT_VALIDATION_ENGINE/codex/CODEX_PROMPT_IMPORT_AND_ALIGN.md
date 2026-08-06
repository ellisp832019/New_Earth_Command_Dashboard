# Codex Prompt — Import and Align Omega Experiment Validation Engine

You are working inside my New Earth Dashboard repository.

I have imported a module folder named:

```text
00_OMEGA_EXPERIMENT_VALIDATION_ENGINE
```

Your task is to integrate it cleanly into the existing dashboard architecture without breaking existing modules.

## Goals

1. Inspect the current dashboard repo structure.
2. Find the existing module registry / module hub / route system.
3. Register this module as an Omega-level engineering module.
4. Add routes for:
   - `/experiments`
   - `/experiments/new`
   - `/experiments/evidence`
   - `/experiments/results`
   - `/experiments/lessons`
   - `/experiments/integrations`
5. Add a dashboard card for “Experiment Validation”.
6. Wire the skeleton UI into the current style system.
7. Do not overwrite existing files unless necessary.
8. If there are existing patterns for module manifests, adapt this module to match them.
9. Create a small local sample data view using `sample_experiments.json`.
10. Add documentation links to the module detail screen.

## Omega OS paths to support

Use these paths as config defaults, not hard-coded everywhere:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\21_PROJECTS_AND_PROGRAMMES\_EXPERIMENTS
D:\NEW_EARTH_OMEGA_OS_PACK\22_KNOWLEDGE_AND_LEARNING\EXPERIMENT_KNOWLEDGE_BASE
D:\NEW_EARTH_OMEGA_OS_PACK\23_AI_AND_AUTOMATION\OMEGA_EXPERIMENT_ENGINE
D:\NEW_EARTH_OMEGA_OS_PACK\99_VISUAL_INDEX_AND_MAPS\EXPERIMENT_VISUAL_LIBRARY
```

## Required output

After implementation, give me:

1. Files changed.
2. Routes added.
3. How to run it.
4. Any missing dependencies.
5. Next recommended improvements.

## Important

This is not a small tracker. Treat it as the engineering memory system for New Earth.
It must support VS Code, GitHub, Obsidian, Proteus, KiCad, Fusion 360, PlatformIO, CSV/Excel, Python and future local AI review.
