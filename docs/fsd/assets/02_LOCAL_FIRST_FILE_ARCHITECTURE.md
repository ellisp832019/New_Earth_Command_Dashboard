# FSD — Local-First Asset File Architecture

## Source path

```text
D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS
```

## Config

Add to `config/local_paths.json`:

```json
"assets_equipment_path": "D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS"
```

## App-managed files

Recommended:

```text
00_ASSET_DASHBOARD/asset_dashboard_state.json
01_EQUIPMENT_REGISTER/equipment_register.csv
02_PARTS_INVENTORY/parts_inventory.csv
07_SUPPLIERS_AND_ORDERS/orders_tracker.csv
10_REPAIR_MAINTENANCE_AND_CALIBRATION/maintenance_log.csv
11_REORDER_LOW_STOCK_AND_WISHLIST/reorder_list.csv
09_BORROWED_LENT_AND_LOCATION_TRACKING/location_register.csv
13_VALUATION_AND_INSURANCE_EVIDENCE/valuation_summary.csv
07_SUPPLIERS_AND_ORDERS/supplier_register.csv
12_PHOTOS_QR_LABELS_AND_BINS/qr_label_register.csv
```

## Safety

- Backup before writing.
- Never delete user files.
- Create missing files from templates.
- Use CSV/JSON for structured data.
- Use Markdown for calm human guidance.
