# FSD — Asset Intelligence Data Model

## Status values

```text
available
in_use
in_storage
low_stock
reorder_needed
broken
repairing
lost
lent_out
wishlist
archived
```

## Asset ID format

Use clear New Earth IDs:

```text
NE-EQ-0001
NE-PART-0001
NE-MG-ESP32-0001
NE-BC-SENSOR-0001
NE-TOOL-0001
```

## Equipment fields

```csv
asset_id,name,type,project,owner,location,condition,status,purchase_date,purchase_cost,replacement_value,serial_number,receipt_link,warranty_until,notes
```

## Parts fields

```csv
part_id,name,category,project,quantity,min_quantity,location,supplier,last_ordered,last_cost,status,datasheet_link,notes
```

## Order fields

```csv
order_id,date,supplier,item,project,quantity,total_cost,status,tracking,receipt_link,finance_record_id,notes
```
