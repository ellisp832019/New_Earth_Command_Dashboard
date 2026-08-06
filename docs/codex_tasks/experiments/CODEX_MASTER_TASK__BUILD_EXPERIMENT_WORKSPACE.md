# Codex Master Task - Build Experiment Workspace

## Goal

Build a calm, local-first Omega Experiment Workspace that helps the user run small experiments, capture evidence, and carry lessons back into the dashboard.

## Scope

This workspace should make experiments feel like a practical learning loop, not a heavy lab tool.

The workspace should support:

- drafting an experiment
- linking it to a project
- tracking its status
- capturing evidence
- recording the result
- recording the lesson
- turning the result into the next useful action

## Core Rules

- Keep the workspace local-first.
- Keep it review-first.
- Keep the UI calm and simple.
- Do not add cloud sync.
- Do not add AI providers.
- Do not make it depend on live integrations.
- Reuse the existing dashboard and project system where possible.
- Do not build the whole feature at once.

## Build Phases

### Phase 1 - Lifecycle and labels

Add a simple workspace lifecycle so each experiment can be understood at a glance.

States:

- Draft
- Ready
- Running
- Review needed
- Lesson captured
- Parked

### Phase 2 - Project and task linking

Connect experiments back to the rest of the dashboard.

Support links to:

- one project
- related tasks
- related journal entries
- related content ideas or follow-up notes

### Phase 3 - Evidence capture

Make it easy to attach proof and review it later.

Support:

- file or note evidence
- evidence type tags
- verified state
- evidence presence filters

### Phase 4 - Templates and quick starts

Add a few reusable starters so the workspace feels ready from day one.

Suggested templates:

- project validation
- workflow test
- build or hardware check
- learning experiment
- research check

### Phase 5 - Results and reuse

Let the workspace turn findings into the next useful step.

Support:

- comparison view
- lesson summaries
- next-action suggestion
- conversion into a task, journal entry, or content idea

## UX Rule

The workspace should feel like a personal learning system:

one question,
one run,
one result,
one lesson,
one next step.

