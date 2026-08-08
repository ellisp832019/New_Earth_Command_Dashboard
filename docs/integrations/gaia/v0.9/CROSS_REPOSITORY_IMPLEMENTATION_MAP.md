# Cross Repository Implementation Map

## Dashboard Repository

| Slice | Responsibility | Inputs | Outputs | Tests | Risk |
| --- | --- | --- | --- | --- | --- |
| A | Project Context models and parsers | Project Control files, git state | typed snapshot model | unit tests for parsers | schema drift |
| B | Project Control context adapter | canonical YAML and generated reports | context records | adapter tests | stale manifest semantics |
| C | local Git observation adapter | git status, refs, tags | live repo context | git-state tests | remote divergence |
| D | provenance/freshness assembler | live + recorded + derived inputs | quality-tagged snapshot | snapshot assembly tests | mislabelled freshness |
| E | response composition | snapshot model | response contract payloads | response contract tests | unsupported answer shapes |
| F | Dashboard UI surface | response payloads | Project Officer screen | widget tests | UI overstatement |

## GAIA Repository

| Slice | Responsibility | Inputs | Outputs | Tests | Risk |
| --- | --- | --- | --- | --- | --- |
| G | integration client contract extension | Project Context payloads | typed client models | package tests | version skew |
| H | backend Project Officer reasoning endpoint | Project Context snapshot | read-only recommendation payloads | backend contract tests | accidental write surface |
| I | dashboard module view updates | new response fields | richer read-only UI | module widget tests | confusing affordances |
| J | compatibility fixtures and examples | contract schemas | pinned examples and fixtures | fixture validation | stale samples |

## Compatibility Assessment

- `CURRENTLY POSSIBLE`: read-only Dashboard UI, basic GAIA embedding, live loopback restriction.
- `REQUIRES DASHBOARD CHANGE`: explicit Project Context assembly, provenance model, freshness tags, local Git observation.
- `REQUIRES GAIA PACKAGE CHANGE`: typed response support for Project Context and Project Officer response shapes.
- `REQUIRES GAIA BACKEND CHANGE`: Project Officer reasoning endpoint and contract-aware summaries.
- `FUTURE ONLY`: execution, approval, rollback, mutation, and command dispatch.
