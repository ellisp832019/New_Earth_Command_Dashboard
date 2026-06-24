# Architecture Map

## Top-level view

- `lib/` contains the Flutter dashboard shell and feature screens.
- `modules/26_OMEGA_KNOWLEDGE_ENGINE/` contains the local knowledge engine pack.
- `output/` stores generated reports and export-ready notes.

## Knowledge flow

1. Scan local repositories.
2. Build a repository index.
3. Generate learning notes.
4. Generate architecture maps.
5. Prepare Obsidian exports.

## Safety boundary

- Scan/report only by default.
- Comment suggestions require review.
- Source edits require explicit approval and backup.
