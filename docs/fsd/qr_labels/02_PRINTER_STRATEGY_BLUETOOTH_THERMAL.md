# FSD — Bluetooth Thermal Printer Strategy

## Recommended approach

Do not start with direct Bluetooth printing.

Start with:

1. Generate QR PNG.
2. Generate printable label preview.
3. Save label file.
4. Add to print queue.
5. Print manually using printer app or OS dialog.

Then later add Bluetooth integration.

## Why

Bluetooth printer protocols vary by brand.

Some use:

- ESC/POS
- CPCL
- TSPL
- proprietary SDKs
- mobile-only apps

A modular approach prevents the Dashboard being locked to one printer.

## Future printer adapter interface

Create a printer service boundary:

```text
LabelPrinterAdapter
```

Methods:

```text
listPrinters()
connectPrinter()
printLabel(labelJob)
printTestLabel()
getPrinterStatus()
```

## Supported later modes

- Manual export
- OS print dialog
- Bluetooth ESC/POS
- Bluetooth CPCL
- USB printer
- Mobile share sheet
