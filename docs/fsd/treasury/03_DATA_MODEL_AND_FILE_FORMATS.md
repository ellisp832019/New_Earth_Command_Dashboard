# FSD — Treasury Data Model and File Formats

## Status enum
```text
safe
watch
stop
decision
future
archived
```

## Status display
| Status | Label | Symbol |
|---|---|---|
| safe | Safe | 🟢 |
| watch | Watch | 🟡 |
| stop | Pause | 🔴 |
| decision | Needs decision | 🔵 |
| future | Future investment | 🟣 |
| archived | Archived | ⚪ |

## CSV formats

### project_spend_tracker.csv
```csv
date,project,item,supplier,amount,category,receipt_saved,status,notes
```

### receipt_index.csv
```csv
date,item,supplier,amount,type,project,file_location,status,notes
```

### subscription_tracker.csv
```csv
service,purpose,cost,renewal_date,payment_source,status,keep_cancel_review,notes
```

### decisions_register.csv
```csv
date,decision_needed,amount,status,decision,owner,notes
```
