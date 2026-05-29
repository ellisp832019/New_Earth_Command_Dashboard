# FSD — QR Payload and Lookup System

## QR payload rule

Keep QR payload simple.

Use only the Asset ID or Bin ID.

Examples:

```text
NE-MG-ESP32-0007
NE-TOOL-0003
BIN-MG-004
REORDER-JST-XH-001
```

## Why not URLs first?

Local-first systems may not always have a web server running.

Asset IDs are stable, portable and simple.

## Lookup workflow

1. User scans QR.
2. Dashboard receives payload.
3. Dashboard searches registers.
4. Dashboard opens matching item page.
5. If no match, show “Unregistered label” flow.

## Future option

Later, QR can become a local deep link:

```text
newearth://asset/NE-MG-ESP32-0007
```

But v1 should stay ID-only.
