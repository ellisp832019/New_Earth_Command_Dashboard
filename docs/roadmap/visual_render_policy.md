# Visual Render Policy

The New Earth Command Dashboard now treats visual assets as rendered PNG deliverables, not golden-test baselines.

## Rules

- Do not add new `matchesGoldenFile` tests.
- Do not add new `--update-goldens` workflows.
- Do not create new `goldens/` directories for visual verification.
- Keep rendered PNG assets in documentation or roadmap asset folders instead of test fixtures.

## How visuals should be handled

- Build the UI.
- Capture the rendered output as a PNG.
- Store the PNG in a documentation asset path.
- Reference the PNG from the relevant docs or module README.

## Why

Rendered visuals are easier to review, easier to share, and less brittle than snapshot-style golden assertions.
They remain useful as documentation while keeping the test suite focused on behaviour.
