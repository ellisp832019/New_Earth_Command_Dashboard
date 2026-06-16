# Codex Task 06 - Selected Comparison Export

## Goal

Let the user save a selected experiment comparison as a reusable local markdown file.

## Requirements

- Add an export action for the selected experiment pair.
- Save the exported comparison into the module reports folder.
- Keep the selected comparison copy action working.
- Use a file name that reflects the chosen experiment IDs.
- Keep the feature local-first and review-first.

## Suggested UI changes

- Add a `Save comparison` button near the selected comparison summary.
- Keep the existing copy summary action beside it.
- Show a clear success message after saving the file.

## Acceptance Criteria

- The user can export the selected comparison without leaving the workspace.
- The saved file lands in the local reports folder.
- The app still analyzes cleanly after the change.
