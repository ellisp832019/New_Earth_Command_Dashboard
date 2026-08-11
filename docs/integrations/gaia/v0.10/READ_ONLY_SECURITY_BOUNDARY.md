# Read Only Security Boundary

The Dashboard must remain read-only for GAIA programme intelligence.

Allowed:

- view programme summaries
- view project officer summaries
- refresh read-only data
- open the standalone GAIA Control Centre instructions

Forbidden:

- approve packages
- reject packages
- hand off work
- execute work
- run Codex
- run shell commands
- run Git commands
- commit or push repositories
- merge pull requests
- publish releases
- deploy software
- write directly to GAIA databases

Safety rules:

- backend unavailable is not healthy
- backend incompatible is not healthy
- missing data is not healthy
- stale evidence is explicitly labelled
- partial data remains partial
