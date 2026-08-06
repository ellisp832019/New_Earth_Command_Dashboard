# Production Hardening TODO

## Safety
- Add explicit approval before any write-back to source learning packs
- Add learner-safe gating for any future AI tutor responses
- Add role-aware visibility rules for student, mentor, parent, and admin views

## Data
- Replace mock repository output with local persistence
- Add import/export for offline content packs
- Add checksum or versioning for content bundles

## UX
- Add richer empty states per tab
- Add lesson player stepper and completion flow
- Add assessment scoring breakdowns

## QA
- Add repository tests for future pack loading
- Add widget tests for each tab shell
- Add golden snapshots once the design stabilises
