# Codex Prompt - Build Repo Research Engine

Create or integrate the New Earth Dashboard module at:

```text
modules/repo_research_engine/
```

Build a local-first repository research engine with reusable profiles and safe read-only analysis.

Requirements:

1. Keep the module safe and read-only by default.
2. Do not execute unknown repository code.
3. Accept a local repo path for MVP.
4. Load a project profile JSON file.
5. Scan files and classify docs, code, firmware, configs, scripts, hardware files, and binaries.
6. Flag risky files such as scripts, secrets, credentials, binaries, and destructive command names.
7. Generate `repo_inventory.json`, `analysis.json`, `repo_research_report.md`, and the related report bundle.
8. Make the architecture easy to connect to the New Earth Dashboard UI later.
9. Include tests for scanner, profile loading, security masking, and markdown export.
10. Ensure MicroGrow is one profile, not a hard-coded project.

Profiles to support first:

- MicroGrow
- New Earth Dashboard
- New Earth Living
- BioCalm
- New Earth Rehabilitation
- Omega OS
- Generic

After MVP, add Dashboard UI integration and Omega OS Knowledge Vault export.

