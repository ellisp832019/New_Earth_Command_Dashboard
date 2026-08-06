# FSD — Scan Workflow and Mobile Future

## V1

Use external phone camera or QR scanner.

When scanned, user sees asset ID.

Dashboard can have a manual lookup field:

```text
Enter scanned code:
```

## V2

Add in-app QR scan if Flutter target supports camera.

## V3

QR opens a local deep link:

```text
newearth://asset/NE-MG-ESP32-0007
```

## Scan result actions

For an asset:

- Open asset page
- Mark location checked
- Add maintenance note
- Mark item moved
- Mark repair needed

For a bin:

- Show contents
- Add stock count
- Mark reorder needed

For a reorder tag:

- Create reorder request
- Send to Treasury decision list
