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
6. The analyser scores the repository against the profile.
7. The security analyzer scans for secrets, keys, tokens, certificates, dangerous scripts, and suspicious binaries.
8. The knowledge extractor turns the scan into a project summary, architecture summary, learning notes, implementation ideas, risks, and recommendations.
9. The exporter writes the report set.
10. The prompt exporter creates reusable Codex prompts.
11. The comparison engine can compare another repo or a saved inventory.
12. The change-tracking history writer appends a local-only run record with the explicit baseline inventory path.
13. The graph exporter can write dependency and architecture graph bundles.
14. The Omega OS adapter can copy the safe bundle into the research library path.

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
