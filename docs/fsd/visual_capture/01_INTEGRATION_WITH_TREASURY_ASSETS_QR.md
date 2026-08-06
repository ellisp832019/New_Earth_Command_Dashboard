# FSD — Integration With Treasury, Assets and QR Labels

## Treasury integration

Receipt photos link to Treasury records.

Visual Capture stores the image.  
Treasury stores the finance record.

Shared fields:

```text
capture_id
file_path
linked_finance_record
supplier
amount
ocr_status
```

## Asset integration

Asset photos link to Asset Register records.

Visual Capture stores the image.  
Assets stores ownership/location/status.

Shared fields:

```text
capture_id
asset_id
file_path
photo_type
location
```

## QR integration

QR label proof photos link to QR label register.

Use for:

- label printed proof
- label applied proof
- bin label proof
- reprint evidence

## Do not

- Do not move finance records into Visual Capture.
- Do not move asset records into Visual Capture.
- Do not store sensitive receipts in the Dashboard repo.
- Do not commit raw personal photos.
