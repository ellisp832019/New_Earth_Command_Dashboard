# Architecture — New Earth Launchpad

## Recommended Integration

The module should live independently inside the New Earth Dashboard repository.

Suggested path:

```text
modules/new_earth_launchpad/
```

It should read/write campaign records to local JSON or SQLite first. Keep it local-first and file-backed to align with the New Earth Dashboard and Omega OS design.

## High-Level Flow

```text
Dashboard UI
  ↓
Launchpad Module
  ↓
Local Data Store
  ↓
Omega OS Export Folder
  ↓
Kickstarter / Website / PDF / Deck / Grant / Investor Materials
```

## Local-First Design

No cloud dependency is required for MVP.

Data should be exportable as:

- JSON
- Markdown
- CSV
- PDF later

## Suggested Tech Shape

Adapt to your current dashboard stack, but keep this module separated into:

```text
src/
├── models/
├── services/
├── components/
├── pages/
├── calculators/
├── exporters/
└── seed/
```

## Calculator Services

### Funding Calculator

Inputs:

- Funding target
- Kickstarter fee percentage
- Payment fee percentage
- VAT/tax placeholder
- Reward cost of goods
- Packaging
- Shipping
- Contingency

Outputs:

- Gross funding
- Platform fees
- Payment fees
- Estimated tax reserve
- Reward delivery cost
- Contingency reserve
- Usable build funds
- Break-even backer count

## Data Storage Recommendation

MVP:

- JSON files for campaigns
- CSV exports for reward tiers and finance

Later:

- SQLite for dashboard queries
- Indexed local search
- Omega OS document sync
