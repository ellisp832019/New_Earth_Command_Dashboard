# 24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB

Omega-standard Education & Learning Hub module for the New Earth Dashboard.

## Purpose
Create a calm, local-first learning environment for New Earth projects, young people, families, schools, rehabilitation programmes, engineering education, food resilience, embedded systems, AI literacy, nature connection, and practical skills.

## Core vision
This module turns the dashboard into a guided learning operating system:

- Learn electronics, coding, embedded systems, MicroGrow, BioCalm, AI, food resilience, sustainability, project leadership, and practical workshop skills.
- Build real projects instead of only reading theory.
- Track learner progress locally.
- Surface learner search, role views, and badge readiness in a calm local passport.
- Support young people safely.
- Provide AI tutor support without replacing human guidance.
- Connect lessons to real New Earth modules, hardware, experiments, and products.

## Main workspaces
1. Learning Dashboard
2. Pathways
3. Lessons
4. Project Studio
5. AI Tutor
6. Skills Passport
7. Assessments
8. Lab Notebook
9. Mentor / Guardian View
10. Content Builder
11. Reports
12. Community / Classroom Mode
13. Settings

## Dashboard route
- App route: `/modules/education-learning-hub`
- Module manifest: `modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB/module_manifest.json`
- More screen entry: `Education & Learning Hub`

## First Omega build
The first implementation is read-only and mock-data driven.
It is designed to prove the navigation, the calm UI shell, and the content structure before any live integrations are added.
Current placeholders include:

- local search across lessons, pathways, projects, learners, certificates, and source notes
- role-aware tutor prompts for student, mentor, parent/guardian, and admin views
- badge and certificate readiness summaries based on local progress data
- mentor report export for learner handoff and classroom review
- mentor review workflow with local sign-off and handoff status
- mentor review workflow with review breakdown chips, sign-off notes, and handoff status
- draft certificate issuance from completed assessment evidence
- latest local mentor/certificate outputs surfaced in Settings
- latest content-pack draft surfaced in Settings with PDF shortcut
- Reports workspace for mentor report, certificate draft, and content pack outputs
- Reports workspace with learner and time-window filters
- Community / Classroom Mode for group support and guardian handoff
- learner progress review summary with next-step guidance
- filter reset controls for pathways and lessons
- reflection journal prompts and mentor note starter flow
- local reflection entry creation with mood, title, and body capture
- reflection entries can link back to the related lesson or project
- assessment review guide with clearer status labels
- assessment audience and status filters with calm review chips
- assessment cards surface mentor notes, rubric bands, and evidence refs
- project workspaces with local evidence checkpoints and linked source items
- pathway cards with unit and lesson completion cues for the active learner
- offline snapshot export/import for content packs and local restore
- settings now surface the offline pack import/export controls directly
- content builder workspace for drafting offline learning packs, version tags, and validation checks
- content-pack export creates markdown, PDF preview, and manifest artifacts
- passport summary copy flow for certificates and badges
- certificate preview card with local eligibility rules before draft issuance
- certificate PDF draft export alongside the markdown note
- content pack draft save flow so version, checksum, and validation survive export/import

## Future content areas
- Electronics
- Embedded systems
- MicroGrow
- BioCalm
- AI literacy
- Food resilience
- Sustainability
- Youth leadership
- Workshop safety
- Business basics

## Suggested build style
- Feature-first architecture
- Local-first storage
- Calm, accessible UI
- Role-based access
- Offline-friendly content packs
- Modular lesson engine
- Reusable cards and progress widgets
- AI tutor with safety guardrails

## Recommended repo location
`modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB/`

## Omega principle
The module should teach people how to think, build, reflect, repair, grow, and lead.
