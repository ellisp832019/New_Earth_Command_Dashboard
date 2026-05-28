# FSD — Integration With Treasury

## Goal

Connect Asset Intelligence to the Treasury system without mixing responsibilities.

## Finance owns

- budgets
- receipts
- spending
- subscriptions
- monthly summaries
- safe/watch/stop/decision money status

## Assets owns

- physical items
- equipment
- parts stock
- locations
- ownership
- condition
- replacement value
- repair status
- reorder needs
- valuation evidence

## Shared links

Asset records may reference finance records using:

```text
finance_record_id
receipt_link
linked_finance_record
```

Order records may link to Treasury receipts:

```text
17_FINANCE_AND_TREASURY/05_RECEIPTS_AND_INVOICES
```

## Dashboard integration cards

Treasury tab can show:

- Assets awaiting receipt
- Reorder estimated spend
- Broken equipment needing finance decision
- New purchases needing asset registration

Asset tab can show:

- Purchase cost from Treasury
- Receipt link
- Project budget impact
- Safe/watch/decision finance status

## Do not

- Do not move receipts out of Treasury.
- Do not duplicate full Treasury records into Assets.
- Do not let Asset tab overwrite finance budgets.
- Do not let Treasury tab manage asset locations.
