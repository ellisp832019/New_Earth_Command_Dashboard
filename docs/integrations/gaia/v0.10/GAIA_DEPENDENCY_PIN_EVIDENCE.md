# GAIA Dependency Pin Evidence

## Updated Pins

Both GAIA git dependencies in `pubspec.yaml` are pinned to the exact merged C7A SHA:

- `gaia_integration_client`
- `gaia_dashboard_module`

Pinned revision:

- `3a7d316f66aabf9cd677200c55fd5be05a4d6afe`

## Lockfile Resolution

`pubspec.lock` resolves both packages from the same exact git revision.

This keeps the Dashboard aligned to the merged GAIA main commit and avoids floating branch drift.

## Consumer Rule

The Dashboard must not use:

- `main`
- a floating `feature/` branch
- an older pre-merge SHA
- `HEAD`

The Dashboard should always pin to the exact merged SHA that the C7A PR produced on GAIA main.
