# Omega OS Bridge Spec

## Source path
`D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY`

## First mode
Read-only.

## Indexes to generate
- company_index.json
- action_items_index.json
- deadlines_index.json
- products_index.json
- grants_index.json
- ip_assets_index.json
- evidence_index.json

## Scanner rules
- Scan markdown files recursively.
- Extract title from first heading.
- Extract frontmatter if present.
- Detect checkboxes.
- Detect due dates in `YYYY-MM-DD` format.
- Store relative path back to Omega OS.

## Backup rules for future writes
Before changing any markdown file, copy the original into a timestamped `/backups/` folder.
