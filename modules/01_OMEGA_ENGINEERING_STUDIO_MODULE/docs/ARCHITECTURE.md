# Omega Engineering Studio Architecture

## Layering

- Presentation: Flutter screens, shared cards, empty states, and section selectors.
- Application: search, filtering, sorting, and readiness summaries.
- Domain: projects, circuit blocks, PCB revisions, firmware builds, devices, components, experiments, tests, validation, manufacturing, documents, and decisions.
- Data: local mock repository and future persistence boundary.

## Current shape

- One calm workspace shell with 12 section views.
- One local snapshot loaded from the repository.
- One route family under `/modules/omega-engineering-studio`.
- Integration-ready hooks for Omega Knowledge Engine and GAIA.

## Core entities

- EngineeringProject
- CircuitBlock
- PCBRevision
- FirmwareBuild
- DeviceNode
- ComponentItem
- ExperimentRecord
- TestProcedure
- ValidationResult
- ManufacturingStep
- EngineeringDocument
- EngineeringDecision
