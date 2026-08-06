# Security and Safety Model

## Default Safety Position

The engine must never rewrite project source code by default.

## Rules

1. Scan-only is the default mode.
2. Generated comments are suggestions only.
3. Source modifications require explicit approval.
4. Backups are required before any source rewrite.
5. Secrets must not be copied into learning notes.
6. `.env`, private keys, certificates, tokens, and credential files should be ignored.
7. Dependency and build folders must be ignored.
8. Reports should identify sensitive-looking files without printing secrets.

## Future Source Commenting Flow

```text
Scan repo
Generate comment suggestions
Create patch preview
User reviews patch
Create backup
Apply patch
Generate change report
```

## Recommended Ignore Additions

```text
.env
.env.*
*.pem
*.key
*.p12
*.crt
secrets.*
credentials.*
```
