# PIN Security Preflight

Date: 2026-08-06

Branch: `security/users-devices-control-pin-hardening-2026-08-06`

## Purpose

Record the starting state for the Users & Devices PIN hardening pass before any source edits.

## Evidence Collected

- Repo status was clean on the security branch before work started.
- The Users & Devices PIN registry still stores plaintext `pin_code` values in SQLite and in the demo seed JSON.
- Recovery PIN issuance currently returns and displays the raw PIN once in the UI.
- Validation still compares plaintext PIN values directly.
- Lockout state is already separate from the PIN records and can be preserved.
- The project-control inventory still flags `users_devices_control` with a P0 risk about PIN storage and access-control handling.
- The current release-readiness baseline is still blocked.

## Current PIN Storage State

- Database table: `users_devices_control_pin_records`
- Current columns include plaintext `pin_code`
- Schema version is currently `15`
- Seed data file:
  - `modules/01_USERS_AND_DEVICES_CONTROL/data/pins.example.json`

## Current Service State

- `setPrimaryPin` writes plaintext PINs.
- `issueRecoveryPin` generates a plaintext recovery PIN and stores it directly.
- `validatePinForUser` compares plaintext values.
- Legacy JSON migration rewrites plaintext PINs into SQLite without hashing.
- Seed fallback generation uses `Random()` for numeric PINs.

## Current UI / Export Exposure

- PIN registry screens still render record values with masking helpers.
- The recovery PIN flow shows the raw generated PIN once to the operator.
- The report service counts PIN records but must be kept free of secret material.

## Current Desktop Plugin State

- `window_manager` is present in the Flutter dependencies and generated registrants.
- No `window_size` reference was found in the current repo sources.
- The PIN hardening work should not modify unrelated desktop windowing files.

## Risk Notes

- The existing plaintext PIN model is not acceptable for the hardened baseline.
- The migration must preserve lockouts and avoid leaking PINs into reports, logs, or exports.
- Recovery PINs still need a one-time reveal path for the operator, but not persistent plaintext storage.
