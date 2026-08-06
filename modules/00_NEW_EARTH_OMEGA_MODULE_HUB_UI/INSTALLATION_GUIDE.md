# Installation Guide

## Step 1 — Copy the pack into the dashboard repo

Place this folder somewhere inside or beside your New Earth Dashboard repo.

Recommended:

```text
new_earth_dashboard/
  docs/imports/NEW_EARTH_OMEGA_MODULE_HUB_UI/
```

## Step 2 — Ask Codex to import it

Use `CODEX_IMPORT_PROMPT.md`.

## Step 3 — Merge Flutter files

Copy the files from:

```text
flutter/lib/
```

into your dashboard app `lib/` folder, adapting paths if your app already has a preferred architecture.

## Step 4 — Add route/navigation

Add a route or sidebar entry called:

```text
Modules
```

It should open `ModulesScreen`.

## Step 5 — Build UI only first

Do not connect real backends on the first pass.

## Step 6 — Register current modules

Use the manifests in `/modules` as the initial source of truth.

## Step 7 — Connect real modules one by one

Recommended order:

1. Backup System
2. Obsidian Sync
3. Grants Tracker
4. Repo Research Engine
5. AI Assistant Dock
6. MicroGrow Control
