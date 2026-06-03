# UI Integration Notes

These React components are intentionally standalone so Codex can adapt them to your Dashboard framework.

## Components

- `ProjectIntelligencePage.tsx`
- `ProjectRepoCard.tsx`

## Expected input

The page expects an array of `UnifiedProjectRecord` objects from:

```text
modules/project_repo_bridge/data/unified/unified_projects.json
```

## Integration approach

1. Add a route/page called `Projects Intelligence`.
2. Load `unified_projects.json` using your app's local data loading method.
3. Pass `data.projects` to `ProjectIntelligencePage`.
4. Keep the existing Dashboard Projects page untouched until the new view is tested.

## Codex instruction

Ask Codex to adapt these UI files to your Dashboard app structure rather than forcing the Dashboard to match these files exactly.
