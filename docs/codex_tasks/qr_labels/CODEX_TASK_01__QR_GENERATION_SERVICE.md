# Codex Task 01 — QR Generation Service

## Goal

Create a service that generates QR PNG files from Asset IDs.

## Requirements

- Input: asset ID string.
- Output: PNG file.
- Save to generated QR folder.
- Use stable filename:

```text
asset_id_qr.png
```

Example:

```text
NE-MG-ESP32-0007_qr.png
```

## Safety

- If file exists, create version or ask before overwrite.
- Never delete previous QR files.
