# Build Log

## Current Build

- Added a JSON-backed template set registry with distinct vault note templates per supported profile.
- Refined the knowledge bundle with stronger profile focus, document highlights, and review-oriented implementation notes.
- Rebuilt the scanner into a structured safe inventory engine.
- Added a profile manager and supported profiles for the New Earth projects plus Generic.
- Added security analysis with masked secret handling.
- Added knowledge extraction for project summaries and implementation ideas.
- Added prompt generation for the main Codex workflows.
- Added Omega OS export bundling.
- Added repo comparison, change tracking, and graph export support.
- Added readable change-history output with explicit baseline-path history browsing.
- Added export-history markdown browsing with local preview and open actions.
- Added report search, history browsing, release notes, and bundle delta summaries.
- Added document, image, and diagram discovery.
- Added local repository source adapters for GitHub, GitLab, and Bitbucket.
- Added structured clone workspace importing for remote URLs and local repos.
- Added one-click clone-and-scan workflow in the dashboard scanner page.
- Added automatic opening of the cloned source folder after workspace import.
- Added recent clone history browsing and quick form reload support.
- Added comparison report drilldown for file-level added, removed, and modified views.
- Added local PDF, website, transcript, and documentation research source adapters.
- Added a read-only repository source adapter registry for GitHub, GitLab, and Bitbucket extension points.
- Added a read-only research source adapter registry for document, PDF, transcript, and website extension points.
- Added a deterministic local AI provider and in-memory RAG search index.
- Added module documentation for architecture, data flow, security, and roadmap.
- Added tests for scanning, profiles, analysis, exports, comparison, graph export handling, source adapters, and local AI/RAG behavior.

## What Was Tested

- Scanner path filtering and file classification
- Framework and dependency detection
- Profile loading by name
- Masked security findings
- Markdown and prompt export generation
- Repo comparison and change tracking
- Graph export bundling
- Omega OS export bundling
- Document index generation
- Report search indexing
- Release note generation
- Bundle delta summaries
- Read-only repository source adapters
- Research source adapters
- Local AI generation and RAG search

## Known Gaps

- The Flutter dashboard pages still need final app-shell polish and route verification.
- The current round is complete, so follow-on work should start from a fresh workflow list.

## Next Build Step

- Review the dashboard route integration and then begin the next scoped task set.
