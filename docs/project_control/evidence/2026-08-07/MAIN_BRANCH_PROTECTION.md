# Main Branch Protection Evidence

Date: 2026-08-07

## Controlled Baseline

- Repository: `ellisp832019/New_Earth_Command_Dashboard`
- Controlled main SHA: `5e7ccbc7aa057dd393b72b4d19c8c6d48398ba8b`
- Baseline tag: `dashboard-controlled-baseline-2026-08-07`
- Verified tag target: `5e7ccbc7aa057dd393b72b4d19c8c6d48398ba8b`

## Before State

- `main` was not protected.
- Branch protection query returned `404 Branch not protected`.
- No repository rulesets were configured for `main`.

## Applied Protection

Protection is now enabled on `main` with the following policy:

- Pull requests required before merging: yes
- Required approvals: 0
- Required status checks: yes
- Branches must be up to date before merging: yes
- Conversation resolution required: yes
- Force pushes blocked: yes
- Branch deletion blocked: yes
- Administrator recovery path: yes, via admin bypass because `enforce_admins` is disabled

## Required Checks

The exact GitHub-visible checks required on `main` are:

- `Flutter Quality`
- `Project Control Validation`
- `Windows Release Build`

Verified successful run IDs on the controlled baseline merge commit:

- Flutter Quality: `31180327461`
- Project Control Validation: `31180327474`
- Windows Release Build: `31180327431`

## Governance Notes

- This is a solo-maintainer repository, so the protection policy avoids an approval requirement that would make direct recovery impossible.
- The protection is intended to prevent accidental direct pushes while still leaving an administrator recovery path.
- No signed-commit, linear-history, deployment-gate, or external-review requirements were added.
- R-001 remains `mitigated`; the new protection reduces accidental direct changes, but it does not fully eliminate branch-history or remote-divergence risk.
- R-002 and R-006 were not modified in this task.

