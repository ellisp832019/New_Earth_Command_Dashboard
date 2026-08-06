# Quick Start

## 1. Copy module into dashboard

```text
<dashboard_repo>/modules/00_OMEGA_EXPERIMENT_VALIDATION_ENGINE
```

## 2. Copy config example

```bash
cp automation/config/local_paths.example.json automation/config/local_paths.json
```

Edit paths if needed.

## 3. Create first experiment

```bash
python automation/scripts/create_experiment.py \
  --root "D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/_EXPERIMENTS" \
  --id EXP-0003 \
  --title "MicroGrow PCB V0.1 Pin Validation" \
  --project MicroGrow \
  --category PCB_VALIDATION \
  --objective "Validate ESP32 pin map before KiCad schematic freeze." \
  --hypothesis "The selected pin map supports all required low-voltage functions safely."
```

## 4. Generate report

```bash
python automation/scripts/generate_report.py --experiment "D:/NEW_EARTH_OMEGA_OS_PACK/21_PROJECTS_AND_PROGRAMMES/_EXPERIMENTS/EXP-0003_MICROGROW_PCB_V0_1_PIN_VALIDATION"
```

## 5. Sync to Obsidian

```bash
python automation/scripts/sync_to_obsidian.py \
  --experiment "<experiment_folder>" \
  --vault "D:/NEW_EARTH_OBSIDIAN_VAULT"
```

## 6. Ask Codex to integrate

Paste `codex/CODEX_PROMPT_IMPORT_AND_ALIGN.md` into Codex.
