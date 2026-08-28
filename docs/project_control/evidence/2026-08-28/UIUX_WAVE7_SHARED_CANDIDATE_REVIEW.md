# UIUX Wave 7 Shared Candidate Review

Gate: promote only when there are 2+ real consumers, same semantics, a clear owner, and lower total complexity if shared.

| Candidate | Real consumers | Same semantics | Clear owner | Lower complexity if shared | Promote now | Classification / decision |
|---|---:|---|---|---|---|---|
| Stable command/action IDs | 1 current (Command Deck); future physical consumer not yet real | UNKNOWN across future boundaries | TRUE for current local registry; future owner unresolved | UNKNOWN | NO | SHARED_CANDIDATE; retain as design evidence only |
| Bounded permissions | 1 current access-control consumer; future command consumer | UNKNOWN | TRUE locally | UNKNOWN | NO | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| Provenance vocabulary | Multiple views use related labels; no approved shared contract | UNKNOWN | FALSE as a service; each source owns truth | UNKNOWN | NO | SHARED_CANDIDATE vocabulary only |
| Project identity | Dashboard, Tasks, Projects, Engineering context | TRUE locally; cross-system semantics incomplete | TRUE locally, not cross-repo | UNKNOWN | NO | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| Task identity | Tasks, Top 3, Planner, Projects | TRUE locally; external lifecycle unproven | TRUE locally | UNKNOWN | NO | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| Capture envelope | Inbox, quick capture, Assets/domain capture | UNKNOWN because domain fields differ | TRUE locally at first | UNKNOWN | NO | LOCAL_NOW_POTENTIAL_SHARED_LATER |
| Device identity | No proven physical-device consumer | UNKNOWN | FALSE | UNKNOWN | NO | UNCLEAR_REVIEW_REQUIRED |
| Audit events | Voice, access, command surfaces have separate local logs | UNKNOWN | FALSE | UNKNOWN | NO | LOCAL_NOW_POTENTIAL_SHARED_LATER |

## Decision

No candidate meets the full promotion threshold. CAP-01 must not be implemented as a result of this review. The strongest candidate remains stable command/action IDs, but it requires a future contract review with real consumers and must not become a shared registry in Wave 7.
