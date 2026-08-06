# Local Paths Config

The Treasury tab reads from an external Omega OS finance folder.

## Source of truth

```text
D:\NEW_EARTH_OMEGA_OS_PACK\17_FINANCE_AND_TREASURY
```

## Asset and capture paths

Add these to `config/local_paths.json` when the linked Omega OS folders are ready:

```json
"assets_equipment_path": "D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS",
"visual_capture_path": "D:/NEW_EARTH_OMEGA_OS_PACK/19_VISUAL_RECORDS_AND_CAPTURE"
```

Omega OS also reserves `20_CONTACTS_AND_RELATIONSHIPS`, `21_PROJECTS_AND_PROGRAMMES`, `22_KNOWLEDGE_AND_LEARNING`, and `23_AI_AND_AUTOMATION` for later. The Dashboard should treat them as inactive until those systems are built.

## Rule

Commit:

```text
config/local_paths.example.json
```

Do not commit:

```text
config/local_paths.json
```
