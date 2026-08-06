# Architecture

## Layers

### Presentation
Screens, cards, dashboards, lesson player, progress visuals, tutor panel.

### Application
Use-cases such as start lesson, complete lesson, save reflection, generate assessment, assign pathway, update progress.

### Domain
Entities: Learner, Pathway, Lesson, Unit, Project, Assessment, Skill, Badge, Reflection, MentorNote, ContentPack.

### Data
Local repositories backed by SQLite/Hive/JSON/Markdown depending on the dashboard stack.

### Integrations
- Omega Knowledge Engine
- Engineering Studio
- MicroGrow
- BioCalm
- Calendar / planner
- Reports module
- File system content packs
- Local AI / GAIA assistant

## Design pattern
Feature-first module:

education_hub/
- presentation/
- application/
- domain/
- data/
- content/
- tests/

## Data flow
Learner opens dashboard → chooses pathway → opens lesson → completes activity → logs reflection → skills updated → report generated → mentor can review.

## Offline-first behaviour
All core lessons, progress, badges, notes, and project files should work without internet.
