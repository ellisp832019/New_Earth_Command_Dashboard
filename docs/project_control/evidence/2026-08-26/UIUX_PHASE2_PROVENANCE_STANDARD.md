# UI/UX Phase 2 Provenance Standard

Audit date: 2026-08-26
These labels are design standards only. No UI was changed.

| Label | Meaning | Source authority | Editable | Display when |
|---|---|---|---|---|
| Declared | Architecture, identity, contract or topology stated by the canonical declaration | Platform Core | Read-only in Dashboard | Platform Core status and declared architecture views |
| Observed | Engineering or repository condition read from an observation source | NEOS or owning engineering observer | Read-only in Dashboard | Repository, engineering and project intelligence views |
| Local | Authored operational state stored by Dashboard | Command Dashboard local database | Editable where feature permits | Tasks, plans, projects, inbox, journal, finance and preferences |
| Interpreted | Recommendation or explanation derived from source information | GAIA | Read-only recommendation; action may be separately approved | GAIA and recommendation surfaces |
| Operational | Control or orchestration state used to coordinate work | Command Centre | Controlled by owning system | Command Centre integration views |
| Protected | Backup, recovery or safety state | Backup Guardian | Read-only summary in Dashboard | Systems and recovery views |
| Indexed | Retrieved or organized knowledge catalogue state | CKCC / Librarian | Read-only in Dashboard view | Knowledge Library and retrieval results |
| Specialist | Technical workflow state owned by a specialist module | Engineering or domain owner | Defined by module | Engineering, Assets, Meetings and other specialist workspaces |
| Demo | Static or development-only presentation state | Dashboard development owner | Not operational | Calm UI Demo and development surfaces |

## Display Pattern

Use a short label near the value: `Observed - NEOS`, `Declared - Platform Core`, `Local - Dashboard`, or `Protected - Backup Guardian`. A status label must not imply another authority's data is owned by Dashboard.

## Authority Rules

- Do not call Platform Core declarations "live health".
- Do not call NEOS observations "declared architecture".
- Do not present GAIA recommendations as facts without the underlying source label.
- Do not present Command Centre operational state as a user-authored Dashboard record.
- Do not edit read-only adapter data in the Dashboard.
- Keep local write affordances limited to explicitly local domains.

## Reuse

The provenance vocabulary is a shared semantic candidate, but not yet a shared service. It can be reused after two real consumers adopt the same labels and a stable contract is approved.
