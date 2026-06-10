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
- Improved the repo comparison view with summary chips, repo context, and delta snapshots.
- Reworked change history into a compact timeline-style review view.
- Added dependency and architecture graph filters with drilldown panels for node groups, edge groups, and anchors.
- Added a dedicated architecture graph review card with grouped node, edge, and key-anchor views.
- Added explicit export review workflow controls with review-first bundle, vault handoff, and prompt pack inspection.
- Added prompt template family picker controls inside the Codex Prompt Generator card.
- Split knowledge extraction into dedicated summary, architecture, risk, recommendation, and learning-note blocks.
- Added report section deep links to jump directly to report and export review cards.
- Added a document index review page with headings, links, tables, notes, and local asset context.
- Added an image and diagram asset review page with screenshot, icon, design, and binary flags.
- Added profile template library controls with inspect-and-apply preset cards.
- Added export history filtering with explicit profile, repo, folder, and file scopes.
- Added report history filtering with explicit output, repo, profile, and generated-file scopes.
- Added local PDF, website, transcript, and documentation research source adapters.
- Added a read-only repository source adapter registry for GitHub, GitLab, and Bitbucket extension points.
- Added a read-only research source adapter registry for document, PDF, transcript, and website extension points.
- Added a deterministic local AI provider and in-memory RAG search index.
- Added local AI and RAG registries for explicit future provider and index extension points.
- Added dashboard discoverability for the local AI and RAG registry via the module nav and Settings.
- Split the Repo Research Engine home hub into a calmer section launcher plus recent activity cards.
- Added module documentation for architecture, data flow, security, and roadmap.
- Added tests for scanning, profiles, analysis, exports, comparison, graph export handling, source adapters, and local AI/RAG behavior.

## What Was Tested

- Scanner path filtering and file classification
- Framework and dependency detection
- Profile loading by name
- Masked security findings
- Markdown and prompt export generation
- Repo comparison and change tracking
- Comparison insight summary and timeline-style change history
- Dependency graph filters and drilldowns
- Architecture graph review views
- Graph export bundling
- Omega OS export bundling
- Document index generation
- Report search indexing
- Release note generation
- Bundle delta summaries
- Read-only repository source adapters
- Research source adapters
- Local AI generation and RAG search
- Local AI and RAG registry extension points
- Home hub split into section launcher and overview cards

## Known Gaps

- The Flutter dashboard pages still need final app-shell polish and route verification.
- The current round is complete, so follow-on work should start from a fresh workflow list.

## Next Build Step

- Review the dashboard route integration and then begin the next scoped task set.
