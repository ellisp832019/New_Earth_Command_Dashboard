# FSD — Receipt Photo and OCR Workflow

## V1

- Save receipt photo.
- Add receipt photo to index.
- Link manually to Treasury.
- Mark status as `needs_review`.

## V2

Add OCR extraction.

Extract:

- supplier
- date
- total amount
- VAT if visible
- item lines if possible

## V3

AI-assisted suggestion.

Suggest:

- finance category
- project
- asset/parts entries
- supplier
- whether QR labels are needed

## Hayley flow

1. Photograph receipt.
2. It appears in Capture Inbox.
3. Dashboard suggests receipt details.
4. Hayley approves or edits.
5. Treasury entry is linked.
6. Done.

## Calm rule

OCR suggestions are suggestions only.

Hayley approves the final record.
