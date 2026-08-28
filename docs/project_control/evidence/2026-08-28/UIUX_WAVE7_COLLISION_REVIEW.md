# UIUX Wave 7 Collision Review

This review records evidence and follow-up; it does not refactor cross-system architecture.

| Collision / overlap | Systems involved | Severity | Evidence | Action |
|---|---|---|---|---|
| Project identity and project status have different authority meanings | Dashboard Projects, Engineering, NEOS, Project Intelligence, GAIA | Medium | Project source owns human context; NEOS adapters own observed technical state | Keep identity local; label status by provenance; no shared model |
| Task identity may be reused across local execution and future external consumers | Dashboard Tasks, Planner, Projects, GAIA/Command Centre future | Medium | Local task repository and Top 3 semantics are proven; external lifecycle is not | Keep local; revisit after real consumer evidence |
| Capture concepts overlap but fields differ | Inbox, Assets, Visual Capture, Journal/Learning/Content/Business | Medium | Separate repositories and domain forms | Do not merge envelopes in Wave 7 |
| Command/action semantics overlap with future hardware control | Command Deck, Dashboard actions, Command Centre, future hardware | High if promoted prematurely | Command Deck registry exists; no physical consumer or shared contract | Keep bounded local registry; no CAP-01/shared registry |
| Provenance words occur across adapters and specialist views | Platform Core, NEOS, GAIA, Backup Guardian, CKCC, Dashboard | Medium | Phase 2 provenance standard; source authorities differ | Preserve vocabulary; do not centralize service |
| Audit/log state exists in multiple feature-local forms | Voice, Users and Devices, Command Deck | Low / review | Feature-local logs and tests | Record candidate; no cross-feature event model |
| Device identity is implied by future hardware/access concepts | Users and Devices, Command Deck, future hardware | High uncertainty | No current physical pairing/registry/protocol source | Mark unclear; defer to hardware programme |

## Controlled Review Items

- Establish a canonical cross-system project identity only after a real external consumer and contract exist.
- Establish shared action IDs only after a second real consumer and bounded permission/audit contract exist.
- Decide whether audit events are one semantic contract or separate local logs; do not infer from similar names.
- Clarify device ownership during the hardware programme, not in CAP-01 evidence.
