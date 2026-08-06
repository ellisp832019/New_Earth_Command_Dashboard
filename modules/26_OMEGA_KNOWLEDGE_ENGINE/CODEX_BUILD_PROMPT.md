# CODEX BUILD PROMPT — 26_OMEGA_KNOWLEDGE_ENGINE

Copy/paste this into Codex after dropping the module into the Dashboard repo.

```text
I have added a new dashboard module:

modules/26_OMEGA_KNOWLEDGE_ENGINE/

Please inspect it and integrate it safely into the New Earth Dashboard.

Primary goal:
Build the Omega Knowledge Engine as a global project intelligence module that can scan and explain any New Earth repo without modifying source code by default.

Hard safety rules:
1. Do not mass-edit source files.
2. Do not apply generated comments automatically.
3. Default mode must remain scan/report/learning-notes only.
4. Any future source-code commenting must require backup + explicit user approval.
5. Ignore build folders, generated files, .git, node_modules, .dart_tool, build, dist, .venv, vendor, and output folders.

Build tasks:
1. Add this module to the Dashboard module registry/navigation.
2. Create a dashboard screen for it with tabs:
   - Overview
   - Repositories
   - Scan Results
   - Learning Notes
   - Architecture Map
   - Comment Suggestions
   - Project Memory
   - Obsidian Export
   - Settings
3. Wire the UI initially to static/sample output files if backend integration is not ready.
4. Preserve the Python scanner as a local tool.
5. Add a service layer that can call the scanner later via a safe command runner.
6. Add settings for repo paths so it can scan:
   - Dashboard repo
   - MicroGrow repo
   - BioCalm repo
   - New Earth Living repo
   - future repos
7. Add documentation to the main README explaining the module.
8. Add tests where practical.
9. Report what changed and what remains manual.

Expected generated files:
- output/repository_index.json
- output/repository_index.md
- output/code_learning_notes.md
- output/comment_suggestions.md
- output/architecture_map.md
- output/project_memory.md
- output/obsidian_export/

Future direction:
This should evolve into the Omega Knowledge Engine, a local-first AI learning and documentation layer for all New Earth projects.
```
