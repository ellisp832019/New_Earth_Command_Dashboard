# Repo Research Engine - Next 20 Task Workflow, Round 2

This is the next safe, local-first workflow after the first 20-task pass.

Rules:
- Finish one task at a time.
- Keep each slice local-first, read-only, and review-first.
- Build on the existing scanner, analyser, exporters, profiles, and dashboard integration.
- Do not add execution features unless they stay opt-in and explicitly safe.

## Workflow

1. Expand richer document indexing.
- Index markdown headings, links, tables, and reference-style notes.
- Keep the index local and read-only.

2. Add image asset discovery to the scan inventory.
- Track screenshots, icons, diagrams, and design assets.
- Keep binary files flagged but not parsed.

3. Add diagram and flowchart discovery.
- Detect Mermaid, PlantUML, draw.io, and similar diagram files.
- Keep the output in the safe inventory path.

4. Add a local document search index for generated reports.
- Search report bundles, knowledge notes, and comparison outputs.
- Keep the index fully local.

5. Add report history browsing in the dashboard.
- Show past report bundles and the current output path.
- Keep the list compact and readable.

6. Add export history browsing in the dashboard.
- Show what was exported to Omega OS and when.
- Keep export history local-only.

7. Add release note generation.
- Turn comparison and change tracking into release-ready notes.
- Keep release notes local and review-first.

8. Add bundle delta summaries.
- Summarise what changed between the latest two runs.
- Keep the summary short and useful.

9. Add architecture graph drilldown views.
- Show graph node groups, edge groups, and key file anchors.
- Keep graph generation optional.

10. Add dependency manifest drilldowns.
- Group manifests by framework and runtime.
- Keep the summary readable instead of exhaustive.

11. Add licence review panels.
- Highlight detected licence candidates and review status.
- Keep licence findings masked and safe.

12. Add profile editor UI.
- Edit profile JSON without leaving the dashboard.
- Keep validation local and explicit.

13. Add profile comparison tools.
- Compare two profile JSON files side by side.
- Keep the differences easy to review.

14. Add template selection controls.
- Let profiles choose report template sets in the UI.
- Keep the selection editable in JSON.

15. Add project notes export for the Knowledge Vault.
- Export curated notes into the vault template structure.
- Keep the vault export read-only and local.

16. Add read-only GitHub source adapters.
- Implement repository metadata and tree snapshot loading.
- Keep live network access opt-in and explicit.

17. Add read-only GitLab source adapters.
- Implement the same snapshot contract for GitLab.
- Keep the adapter local-first until a source is chosen.

18. Add read-only Bitbucket source adapters.
- Implement the same snapshot contract for Bitbucket.
- Keep the adapter surface consistent with the other providers.

19. Add local PDF, website, transcript, and docs ingestion adapters.
- Implement the document source interfaces behind opt-in boundaries.
- Keep network fetching explicit and separate.

20. Add local RAG and AI integration points.
- Implement local provider contracts for embeddings and generation.
- Keep the module fully usable without any AI provider enabled.

## Execution Plan

### Phase 1: Indexing and Search
- Tasks 1 to 4
- Build richer local discovery before adding new views.

### Phase 2: History and Reporting
- Tasks 5 to 8
- Surface past outputs and turn changes into readable summaries.

### Phase 3: Visual Review Tools
- Tasks 9 to 14
- Improve inspection and editing workflows inside the dashboard.

### Phase 4: External Read-Only Sources
- Tasks 15 to 19
- Add extension points for future sources without enabling live execution.

### Phase 5: Local Intelligence Interfaces
- Task 20
- Finish with local-first AI and RAG contracts that do not require a provider.

## End Review

After task 20, review:
- whether the second workflow still feels calm and useful
- which discovery views are actually used during analysis
- whether profile editing belongs in the dashboard or the module UI
- which adapters should stay interfaces-only until a safe integration slice is chosen

