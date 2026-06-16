# Codex Task 08 - Report Preview Pane

## Goal

Make saved experiment reports previewable in the workspace so they can be read without opening them externally.

## Requirements

- Show a preview of a saved report inside the Reports section.
- Let the user choose which saved report to preview.
- Keep the saved report archive list visible.
- Keep the feature local-first and review-first.

## Suggested UI changes

- Add a preview pane below the saved report archive.
- Show the selected report filename and path.
- Render the report markdown in a scrollable preview box.

## Acceptance Criteria

- The user can preview a saved report without leaving the workspace.
- The archive remains visible and easy to browse.
- The app still analyzes cleanly after the change.
