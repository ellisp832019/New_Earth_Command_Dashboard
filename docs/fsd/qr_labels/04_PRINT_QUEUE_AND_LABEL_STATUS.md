# FSD — Print Queue and Label Status

## Goal

Make label printing calm and trackable.

## Print statuses

```text
draft
generated
queued
printed
applied
reprint_needed
archived
```

## Print queue file

```csv
queue_id,date_added,asset_id,label_type,label_size,priority,status,generated_file,printer_profile,notes
```

## Label register file

```csv
label_id,asset_id,label_type,label_size,qr_payload,label_text,generated_file,print_status,printed_date,applied_date,location,notes
```

## Calm UI rule

Show three sections only:

- Ready to print
- Printed, needs applying
- Applied
