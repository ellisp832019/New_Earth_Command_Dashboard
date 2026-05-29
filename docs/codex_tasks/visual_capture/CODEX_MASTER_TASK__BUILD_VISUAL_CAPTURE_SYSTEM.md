# Codex Master Task — Build Visual Capture System

## Goal

Build a calm Visual Capture system inside the New Earth Dashboard.

It must integrate with Treasury, Asset Intelligence and QR Labels without breaking them.

## Locked paths

Finance:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/17_FINANCE_AND_TREASURY
```

Assets:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/18_ASSETS_EQUIPMENT_AND_PARTS
```

Visual Capture:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/19_VISUAL_RECORDS_AND_CAPTURE
```

## Critical rules

- Do not store raw photos in the Dashboard repo.
- Do not rewrite Treasury.
- Do not rewrite Asset Intelligence.
- Do not break QR Label features.
- Use `config/local_paths.json`.
- Treat Omega OS as source of truth.
- Visual Capture stores photos/evidence.
- Treasury stores finance data.
- Assets stores asset records.
- QR stores label records.
- AI/OCR suggestions require human approval.

## Build order

### Phase 1 — Config

Add support for:

```json
"visual_capture_path": "D:/NEW_EARTH_OMEGA_OS_PACK/19_VISUAL_RECORDS_AND_CAPTURE"
```

### Phase 2 — Folder health check

Validate required folders and create missing indexes from templates.

### Phase 3 — Capture Inbox

Build inbox view for:

```text
19_VISUAL_RECORDS_AND_CAPTURE/14_TEMP_UPLOADS_AND_INBOX
```

### Phase 4 — Image import

Support:

- choose file
- drag/drop
- copy to inbox
- create index row
- preview image

### Phase 5 — Link image

Allow image to link to:

- receipt / Treasury
- asset
- part
- QR label
- project
- repair record

### Phase 6 — Webcam capture station

Add webcam capture if Flutter platform supports it.

Fallback to file picker if not.

### Phase 7 — OCR queue

Create OCR queue data model.

Do not implement final AI automation yet unless safe.

### Phase 8 — Privacy review

Add sensitive flag and redaction workflow notes.

## UX instruction

Keep it calm.

The main button should be:

```text
Quick Capture
```

Capture first. Sort later.
