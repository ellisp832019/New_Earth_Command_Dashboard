# Codex Master Task — Build QR Label Printing

## Goal

Build QR label generation and print queue support as an extension of the Asset Intelligence tab.

## Critical instruction

Do not build native Bluetooth printing first.

Build this order:

1. Asset ID based QR generation
2. QR PNG file output
3. Label preview
4. Label register
5. Print queue
6. Manual print/export workflow
7. Printer profile data model
8. Bluetooth printer adapter stub for later

## Source paths

Assets:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS
```

QR label folder:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS/12_PHOTOS_QR_LABELS_AND_BINS
```

## QR rule

QR code payload should contain only:

```text
asset_id
```

Example:

```text
NE-MG-ESP32-0007
```

## Required files

Read/write:

```text
12_PHOTOS_QR_LABELS_AND_BINS/02_LABEL_TEMPLATES/qr_label_register.csv
12_PHOTOS_QR_LABELS_AND_BINS/03_PRINT_QUEUE/print_queue.csv
12_PHOTOS_QR_LABELS_AND_BINS/10_PRINTER_SETUP_AND_PROFILES/printer_profiles.csv
```

Generated QR PNGs go in:

```text
12_PHOTOS_QR_LABELS_AND_BINS/01_GENERATED_QR_PNGS
```

## UI screens

- QR Label Generator
- Label Preview
- Print Queue
- Printed Label Log
- Printer Profiles
- Scan Lookup

## Integration

Do not rewrite Asset Intelligence.

Add QR label actions to asset detail pages:

- Generate label
- Add to print queue
- Mark printed
- Mark applied

## Acceptance

- QR PNG generation works.
- Print queue works.
- Manual print workflow exists.
- Bluetooth printer integration is stubbed but not required.
