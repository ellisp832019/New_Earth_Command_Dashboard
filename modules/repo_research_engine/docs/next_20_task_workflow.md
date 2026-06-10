# Repo Research Engine - Next 20 Task Workflow

This workflow turns the current Repo Research Engine roadmap into 20 small, reviewable slices.

Rules:
- Finish one task at a time.
- Keep each slice local-first, read-only, and review-first.
- Reuse the existing scanner, analyser, exporter, and Dashboard page structure.
- Do not add execution features unless they stay opt-in and explicitly safe.

## Workflow

1. Add quick rerun actions to the recent-runs cards.
- Let a user rerun the same repo/profile pair from history.
- Keep the form refill action available.

2. Add recent-run filtering and search.
- Filter by repo path, profile, and success status.
- Keep the list compact on small screens.

3. Add recent-run detail expansion.
- Show the command, output files, and run flags.
- Keep the card calm and readable.

4. Add report bundle previews.
- Show the main report, security report, and comparison summary inline.
- Keep the files local and read-only.

5. Add report file open actions.
- Open a generated report from the dashboard page.
- Keep folder opening optional and explicit.

6. Add output bundle metadata.
- Show output path, timestamps, and run status in one place.
- Keep the bundle summary easy to scan.

7. Add profile presets and path presets.
- Give each supported profile a quick-start preset.
- Keep the presets editable and local.

8. Add profile editor validation.
- Validate required fields and report-template keys.
- Keep invalid profiles from breaking a run.

9. Add richer licence review.
- Highlight licence file candidates and detected licence names.
- Keep the licence data in the safe inventory path.

10. Add more useful dependency summaries.
- Group dependencies by manifest and framework.
- Keep the summary readable instead of exhaustive.

11. Add file-type drilldowns.
- Expand docs, scripts, firmware, hardware, and binary views.
- Keep the drilldown local to the current scan.

12. Add architecture graph viewer support.
- Show the graph JSON and a readable markdown companion.
- Keep graph generation optional.

13. Add comparison report drilldown.
- Show added, removed, and changed files in more detail.
- Keep comparison safe and local.

14. Add change-tracking history.
- Track how a repo changed between runs.
- Keep the baseline path explicit.

15. Add export history browsing.
- Show what was exported to Omega OS and when.
- Keep the export history local-only.

16. Add knowledge bundle refinements.
- Tighten the summary, learning notes, and implementation ideas.
- Keep masked security information out of the knowledge layer.

17. Add markdown template selection.
- Let a profile choose its report template set.
- Keep the template mapping editable in JSON.

18. Add adapter interfaces for external sources.
- Define read-only interfaces for GitHub, GitLab, and Bitbucket.
- Keep the adapters unimplemented until a safe integration slice is chosen.

19. Add research source adapters for documents.
- Define local PDF, website, transcript, and doc ingestion interfaces.
- Keep network access opt-in and future-facing.

20. Add local AI and RAG extension points.
- Define provider interfaces without forcing a provider.
- Keep the current safe local workflow fully usable without AI.

## End Review

After task 20, review:
- which report views are actually useful day to day
- whether the page still feels calm instead of busy
- which outputs should stay parked for later
- whether the module still obeys the read-only, local-first rule

