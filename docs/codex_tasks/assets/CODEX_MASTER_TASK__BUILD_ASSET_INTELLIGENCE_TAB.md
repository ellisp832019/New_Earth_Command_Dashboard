# Codex Master Task — Build Asset Intelligence Tab

## Goal

Build a calm, productive Asset Intelligence tab inside the New Earth Dashboard.

This must integrate with the Treasury feature already being built, without breaking or rewriting it.

## Locked paths

Finance:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/17_FINANCE_AND_TREASURY
```

Assets:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS
```

## Critical rules

- Do not mirror the asset folder into the Dashboard repo.
- Do not duplicate the finance folder.
- Do not rewrite Treasury.
- Use `config/local_paths.json`.
- Treat Dashboard as the visual layer.
- Treat Omega OS folders as source of truth.
- Backup before writing.
- Never delete user files.

## Build phases

### Phase 1 — Config

Add support for:

```json
"assets_equipment_path": "D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS"
```

Keep existing finance path support.

### Phase 2 — Folder setup / health check

Validate `18_ASSETS_EQUIPMENT_AND_PARTS`, required subfolders, and required tracker files.

Create missing CSV/JSON templates only if missing.

### Phase 3 — Navigation

Add Dashboard tab:

```text
Assets
```

Optional subtitle:

```text
Equipment, Parts & Inventory
```

### Phase 4 — Asset Home UI

Cards:

- 🟢 Available
- 🟡 Low Stock
- 🔴 Broken / Repair
- 🔵 Needs Decision
- 🟣 Wishlist
- Project Asset Summary

### Phase 5 — Registers

Implement simple views for equipment, parts, orders, maintenance, reorders, locations, suppliers, valuation, and QR labels.

### Phase 6 — Treasury integration

Add cross-summary cards:

In Assets:
- receipts missing
- purchase cost
- reorder estimated spend
- linked Treasury receipt

In Treasury:
- purchases needing asset registration
- reorder decisions
- broken equipment requiring spend

### Phase 7 — Calm capture

Build one-minute quick capture form:

- item name
- type
- project
- location
- status
- notes

### Phase 8 — Valuation/insurance

Show summary from valuation CSV.

## UX instruction

This system must feel calm, simple and useful.

It should not feel like stock-control software.

Prioritise clarity and low cognitive load.
