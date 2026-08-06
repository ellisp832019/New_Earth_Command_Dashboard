# Repo Research Engine Data Flow

## Flow

```text
Remote Git URL or local repository path
  -> Structured workspace manager
  -> Workspace clone root
  -> Local source folder
  -> Safe scanner
  -> Repository inventory JSON
  -> Profile manager
  -> Profile-aware analysis
  -> Security analysis
  -> Knowledge extraction
  -> Markdown reports
  -> Generated Codex prompts
  -> Omega OS export adapter
```

## Step By Step

1. The user selects a remote Git URL or a local repository path.
2. The workspace manager clones the source into a structured local workspace with separate source, analysis, reports, exports, prompts, and metadata folders.
3. The scanner walks the source folder and ignores known generated folders.
4. File metadata is written into `repo_inventory.json`.
5. A profile JSON file is loaded and normalised.
6. The template set registry in `config/template_sets.json` supplies editable report template mappings.
7. The analyser scores the repository against the profile.
8. The security analyzer scans for secrets, keys, tokens, certificates, dangerous scripts, and suspicious binaries.
9. The knowledge extractor turns the scan into a project summary, architecture summary, learning notes, implementation ideas, risks, and recommendations.
10. The exporter writes the report set and records the selected template set in JSON and markdown.
11. The prompt exporter creates reusable Codex prompts.
12. The repository source adapter registry describes the supported read-only GitHub, GitLab, and Bitbucket extension points.
13. The research source adapter registry describes the supported PDF, website, transcript, and documentation ingestion extension points.
14. The local AI provider registry describes deterministic offline providers and future opt-in provider slots.
15. The local RAG index registry describes deterministic offline indexes and future opt-in index slots.
16. The comparison engine can compare another repo or a saved inventory.
17. The change-tracking history writer appends a local-only run record with the explicit baseline inventory path.
18. The graph exporter can write dependency and architecture graph bundles.
19. The Omega OS adapter can copy the safe bundle into the research library path.

## Output Set

- `repo_inventory.json`
- `scan_manifest.json`
- `repository_tree.json`
- `analysis.json`
- `repo_summary.md`
- `repo_research_report.md`
- `security_report.md`
- `risk_report.md`
- `knowledge_report.md`
- `implementation_opportunities.md`
- `learning_notes.md`
- `change_tracking.md`
- `change_history.md`
- `export_history.md`
- `generated_prompts/*.md`

## Design Notes

- Everything stays local.
- Sensitive values are masked before export.
- The scanner reads metadata first and content only for safe text inspection.
- Reports are meant for manual review, not automatic execution.
