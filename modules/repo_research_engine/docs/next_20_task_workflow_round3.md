# Repo Research Engine - Post-Polish Workflow, Round 3

This workflow follows the route and UI polish pass for the Repo Research Engine module.

Rules:
- Finish one task at a time.
- Keep each slice local-first, read-only, and review-first.
- Prefer small, reviewable commits.
- Do not execute unknown repository code.

## Workflow

1. Split the home hub into clearer subpages.
- Move Scanner, Reports, Profiles, Exports, Prompts, and Settings into dedicated Flutter pages.
- Keep the home page as the calm overview.

2. Improve the repository comparison experience.
- Show clearer repo-to-repo deltas, dependency changes, and risk shifts.
- Keep comparisons local and readable.

3. Add a change-tracking timeline.
- Show file changes over time across recent runs.
- Keep the timeline compact and path-focused.

4. Expand dependency graph exploration.
- Add graph filters and clearer graph drilldowns.
- Keep graph output optional.

5. Add architecture graph review views.
- Show node groups, edge groups, and key anchors in a review-friendly layout.
- Keep graph generation read-only.

6. Add export review workflow controls.
- Show what will be exported before it is copied into the Knowledge Vault.
- Keep exports explicit and review-first.

7. Add prompt template picker controls.
- Let the user choose prompt families from the UI.
- Keep prompt generation local.

8. Add richer knowledge extraction views.
- Show project summary, architecture summary, risks, recommendations, and reusable components in separate blocks.
- Keep masking consistent.

9. Add report section deep links.
- Link the module cards to exact report sections and bundle views.
- Keep navigation calm and predictable.

10. Add a document indexing review page.
- Show the indexed documents, headings, links, tables, and notes that were discovered.
- Keep the index local.

11. Add image and diagram asset review pages.
- Show screenshots, icons, diagrams, and design assets from the scan inventory.
- Keep binaries flagged but not parsed.

12. Add profile template library controls.
- Make reusable profile presets easier to inspect and apply.
- Keep profile JSON editable.

13. Add export history filtering.
- Filter Omega OS export history by profile, repo, folder, and copied files.
- Keep history local-only.

14. Add report history filtering.
- Filter recent run history by output path, repo, profile, and generated outputs.
- Keep the view compact.

15. Add local source adapter registry pages.
- Surface GitHub, GitLab, and Bitbucket snapshot adapters more clearly in the UI.
- Keep them read-only and local-first.

16. Add document source review pages.
- Surface PDF, website, transcript, and documentation ingestion sources in a safer review layout.
- Keep network usage opt-in.

17. Add local AI and RAG controls.
- Expose the deterministic local provider and in-memory search index more clearly.
- Keep the module usable without any external provider.

18. Add bundle comparison previews.
- Show side-by-side summaries of main, security, and comparison outputs.
- Keep the previews local.

19. Add risk review refinements.
- Make suspicious scripts, binaries, and secret-like findings easier to scan.
- Keep values masked.

20. Add final dashboard UX polish.
- Tighten spacing, labels, and responsive behaviour across the module pages.
- Keep the feel calm and intentional.

## End Review

After round 3:
- verify which of the new pages users actually open most often
- decide whether any sections should return to the home hub
- confirm the module still feels local-first and low-friction

