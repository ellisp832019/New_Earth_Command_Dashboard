# Asset Intelligence Local Path Config

Add this value to:

```text
config/local_paths.json
```

```json
"assets_equipment_path": "D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS"
```

Full recommended config:

```json
{
  "omega_os_root": "D:/NEW_EARTH_OMEGA_OS_PACK",
  "finance_treasury_path": "D:/NEW_EARTH_OMEGA_OS_PACK/17_FINANCE_AND_TREASURY",
  "assets_equipment_path": "D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS"
}
```

Do not commit `config/local_paths.json`.

The asset health check also expects a `changes/` folder inside the external asset root, with `asset_change_journal.csv` inside it.
This journal is the first step toward safer multi-machine asset edits.
