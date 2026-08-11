# GAIA v0.10 C7B Architecture

## Baseline

- Dashboard repository: `ellisp832019/New_Earth_Command_Dashboard`
- Dashboard worktree: `D:\Dev\Worktrees\New-Earth-Command-Dashboard-GAIA-C7B`
- Dashboard starting SHA: `96c1d09c94f790a27afa4d5f593ae76d3a808ddf`
- GAIA repository: `ellisp832019/New-Earth-AI-Employee`
- GAIA merged C7A SHA: `3a7d316f66aabf9cd677200c55fd5be05a4d6afe`

## Structure

The Dashboard extends the existing `lib/features/gaia/` feature tree.

The host screen now presents two read-only tabs:

- `Operations`
- `Programme intelligence`

The existing operations surface continues to use the GAIA dashboard module.
The programme intelligence tab uses the merged GAIA programme summary view from the approved package surface.

## Boundary

The Dashboard is a consumer surface only.

- no mutation of GAIA repositories
- no approval or rejection controls
- no direct Git operations
- no shell execution
- no Codex execution
- no release publishing

## Data Flow

1. Dashboard resolves the backend URI through the existing GAIA provider graph.
2. Dashboard creates the approved GAIA integration client.
3. Dashboard creates the GAIA dashboard controller.
4. The controller refreshes the read-only programme summary and the existing operations surface.
5. The host screen renders package-owned widgets inside the Dashboard shell.
