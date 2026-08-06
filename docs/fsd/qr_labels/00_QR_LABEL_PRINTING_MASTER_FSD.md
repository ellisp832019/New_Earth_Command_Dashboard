# FSD — QR Label Printing for Asset Intelligence

## Purpose

Add QR label generation and label printing workflows to the New Earth Dashboard Asset Intelligence system.

This should help Peter and Hayley label, locate, scan and manage physical assets calmly and productively.

## Source paths

Assets:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS
```

QR labels:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS/12_PHOTOS_QR_LABELS_AND_BINS
```

## Core principle

The QR code stores only the asset ID.

Example:

```text
NE-MG-ESP32-0007
```

The Dashboard resolves this ID to:

- asset name
- project
- location
- receipt
- supplier
- maintenance
- notes
- valuation
- reorder info

## Main screens

1. QR Label Generator
2. Label Preview
3. Print Queue
4. Printer Profiles
5. Bin / Drawer Labels
6. Maintenance Tags
7. Reorder Point Labels
8. Scan Lookup
9. Printed Label Log

## Non-goals for v1

- Native Bluetooth printing
- Cloud printing
- Direct printer driver support
- Complex label design studio

## V1 goal

Generate QR PNGs and printable label sheets/files first. Bluetooth thermal printing comes later as a modular adapter.
