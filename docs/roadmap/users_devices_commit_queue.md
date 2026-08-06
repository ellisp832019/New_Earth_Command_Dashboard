# Users & Devices Commit Queue

This queue turns the Users & Devices commit split plan into a ready-to-use order for the next code pass.

Use it when the next implementation slice starts.

Pair it with:

- [`users_devices_upgrade_roadmap.md`](users_devices_upgrade_roadmap.md)

## Queue Rule

Land one commit at a time.

After each commit:

1. Run `flutter analyze`.
2. Start the app once.
3. Test the touched flow.
4. Stop before the next commit if the current slice still feels unclear.

## Commit 1 - Security gate and session cleanup

Goal:

- make the startup lock path the single clear entry point
- keep the remembered identity flow stable
- remove duplicate unlock affordances
- keep the security session box readable

Suggested commit message:

- `feat(security): tighten session gate and unlock flow`

Files most likely to change:

- `lib/features/security/presentation/security_lock_screen.dart`
- `lib/features/security/application/security_session_controller.dart`
- `lib/features/users_devices_control/presentation/users_devices_control_screen.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/USER_GUIDE.md`

Check:

- app opens to `Security Lock`
- unlock succeeds with the correct local identity
- session countdown, active user, and online state still make sense

## Commit 2 - PIN registry and per-user PIN handling

Goal:

- keep one clear primary PIN per user
- support recovery PIN issuance and revocation
- keep the PIN registry layout stable
- keep PIN audit events visible

Suggested commit message:

- `feat(users-devices): harden per-user pin registry`

Files most likely to change:

- `lib/features/users_devices_control/data/users_devices_pin_registry_service.dart`
- `lib/features/users_devices_control/presentation/users_devices_pins_screen.dart`
- `lib/features/security/presentation/security_lock_screen.dart`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/USER_GUIDE.md`

Check:

- one user can have a clear primary PIN record
- recovery PINs can be issued and revoked
- PIN masking stays readable in the lock screen
- audit entries still appear after a PIN change

## Commit 3 - Device trust and onboarding polish

Goal:

- make onboarding and trust posture easier to understand
- keep trusted device selection clear
- surface trust state cleanly in the module

Suggested commit message:

- `feat(users-devices): refine device trust onboarding`

Files most likely to change:

- `lib/features/users_devices_control/presentation/users_devices_control_screen.dart`
- `lib/features/users_devices_control/data/users_devices_control_repository.dart`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/USER_GUIDE.md`

Check:

- onboarding still opens from the module home
- trust state reads clearly on the device cards
- no new route breaks the current gate flow

## Commit 4 - Module hub and dashboard surfacing

Goal:

- keep the module easy to reach from the dashboard
- preserve the calm summary card on the home screen
- keep labels and shortcuts consistent

Suggested commit message:

- `feat(navigation): surface users-devices module more clearly`

Files most likely to change:

- `lib/features/modules/modules_screen.dart`
- `lib/features/more/presentation/more_screen.dart`
- `lib/features/dashboard/presentation/dashboard_screen.dart`
- `lib/core/routing/route_names.dart`

Check:

- the module is still visible where expected
- dashboard surfacing stays calm and not noisy
- the module tile and shortcut labels still match the route names

## Commit 5 - Documentation and visuals

Goal:

- refresh the user guide
- keep the click-by-click flow current
- keep the access diagrams and onboarding visuals aligned
- capture the test checklist

Suggested commit message:

- `docs(users-devices): refresh guide and visual flow docs`

Files most likely to change:

- `modules/01_USERS_AND_DEVICES_CONTROL/docs/USER_GUIDE.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/ACCESS_CONTROL_MODEL.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/DEVICE_TRUST_MODEL.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/DEVICE_ONBOARDING_FLOW.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/APPROVAL_WORKFLOWS.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/assets/*.svg`

Check:

- the guide matches the final interaction flow
- the diagrams match what the app actually does
- the testing steps still point at the right screens

## Recommended Order If Time Is Tight

If only two commits fit into one session, do these first:

1. Security gate and session cleanup
2. PIN registry and per-user PIN handling

That gives the most visible safety improvement with the least ambiguity.
