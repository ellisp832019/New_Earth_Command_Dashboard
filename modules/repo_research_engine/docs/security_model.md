# Repo Research Engine Security Model

## Primary Rule

Analysis is read-only.

Unknown repository code must never be executed.

## Threat Model

The module treats all scanned repositories as untrusted.

Risks include:

- secrets in text files
- API keys and tokens in config files
- certificates and private keys
- malicious scripts
- suspicious binaries
- unsafe firmware or hardware patterns
- unclear or missing licensing

## Mandatory Controls

- Ignore generated folders and common build caches.
- Never launch scripts or binaries from the target repository.
- Never install dependencies from the target repository.
- Never upload scanned content to an external service.
- Mask secret-like values in every exported report.
- Flag risky paths for manual review.

## Secret Handling

The security analyzer:

- searches for secret-like patterns
- masks detected values in place
- stores only masked excerpts
- never writes raw secret values to reports

## Script Handling

Script files are treated as untrusted.

The scanner flags:

- shebang scripts
- shell scripts
- PowerShell scripts
- destructive command patterns
- download-and-execute patterns

## Binary Handling

Binary and asset files are not parsed as text.

They are only flagged for manual review.

## Hardware Safety

Hardware and firmware projects get extra caution around:

- mains control
- power stages
- relay wiring
- battery charging
- isolation boundaries

## Export Safety

Exports are safe if they:

- contain masked values only
- avoid raw secrets
- avoid executable content from the source repo
- preserve the read-only nature of the scan

