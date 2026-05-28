# New Earth Dashboard — Asset Intelligence FSD Import Pack

This pack adds the **Asset Intelligence / Equipment / Parts / Inventory** system to the New Earth Dashboard repo.

It is designed to work beside the Treasury build that Codex is already working on.

## Locked Omega OS paths

Finance source of truth:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/17_FINANCE_AND_TREASURY
```

Asset source of truth:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS
```

## Core architecture

```text
17_FINANCE_AND_TREASURY
= money, receipts, spend, budgets

18_ASSETS_EQUIPMENT_AND_PARTS
= what New Earth owns, where it is, condition, parts, equipment, tools, stock

Dashboard
= calm visual layer for Hayley and Peter
```

## Import into Dashboard repo

Copy these into the Dashboard repo root:

```text
docs/
config/
assets/
.gitignore_additions_for_asset_intelligence.txt
README_IMPORT_THIS_PACK.md
```

## Codex entry point

Start Codex with:

```text
docs/codex_tasks/assets/CODEX_MASTER_TASK__BUILD_ASSET_INTELLIGENCE_TAB.md
```
