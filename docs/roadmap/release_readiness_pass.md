# Release Readiness Pass

This pass turns the release-readiness summary into a practical working checklist for the current repo.

Use it when the goal is:

- reduce regressions
- prove persistence
- make builds more repeatable
- align docs with the app that actually exists

## Main Release-Readiness Gaps

These are the five active hardening lanes already called out elsewhere in the roadmap stack:

1. Manual persistence testing
2. Align stale docs with current app behavior
3. Inbox processing verification and polish
4. Voice polish and verification
5. Release-level build and regression checks

## Recommended Order

### 1. Build confidence first

Run:

- `flutter analyze`
- `flutter test`
- `flutter build windows`

Use:

- `scripts/run_release_readiness.ps1`

Why first:

- there is no point doing long manual checks if the build baseline is already unstable

## 2. Daily loop verification

Verify the core V0.1 loop end to end:

1. Open app
2. See Dashboard
3. Set focus
4. Capture a task or note
5. Select Top 3
6. Move through Dashboard, Tasks, and Projects
7. Record review items
8. Close app
9. Reopen app
10. Confirm the data is still there

Why second:

- this is the clearest real-world release gate in the docs

## 3. Persistence pass

Check:

- tasks survive restart
- projects survive restart
- planner focus survives restart
- journal survives restart
- quick capture / inbox survives restart

Why third:

- restart confidence is one of the main trust signals for a local-first app

## 4. Trust and session pass

Check:

- Security Lock opens cleanly
- unlock works with the correct user and PIN
- session countdown behaves correctly
- Users & Devices gated screens still behave correctly
- Treasury gate still explains allow/block paths clearly

Why fourth:

- access state now affects multiple modules and must feel stable

## 5. Inbox and voice pass

Check:

- quick capture still saves cleanly
- inbox conversion path is understandable
- voice capture path does not feel fragmented
- voice review / save flow remains local and calm

Why fifth:

- these are high-value user-facing flows and still called out as active hardening areas

## Automated Helper

Use this PowerShell helper from the repo root:

```powershell
./scripts/run_release_readiness.ps1
```

What it does:

- stops a running dashboard process by default
- runs `flutter analyze`
- runs `flutter test`
- runs `flutter build windows`
- saves logs to `tmp/release_readiness`

Useful options:

```powershell
./scripts/run_release_readiness.ps1 -SkipWindowsBuild
./scripts/run_release_readiness.ps1 -SkipTest
./scripts/run_release_readiness.ps1 -KeepRunningAppOpen
```

## Expected Output

After the automated pass, you should have:

- a clean analyzer result
- test output logs
- a Windows build log
- a known manual checklist to run next

## Exit Criteria

This pass is in good shape when:

- automated checks are repeatable
- restart persistence is confirmed
- docs match current app behavior
- the daily loop works without confusion
- lock, voice, and inbox flows feel trustworthy
