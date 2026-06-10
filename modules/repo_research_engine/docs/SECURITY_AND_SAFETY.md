# Security and Safety Rules

The Repo Research Engine must be safe by default.

## Never do these in MVP
- Do not run scripts from researched repos.
- Do not install dependencies from researched repos.
- Do not execute binaries.
- Do not flash firmware.
- Do not copy secret files into reports.
- Do not upload private repos to external services.

## Always do these
- Treat unknown repos as untrusted.
- Read files only.
- Flag scripts and binaries.
- Flag `.env` files and credential-looking paths.
- Check licence before adapting code.
- Prefer learning patterns over copying code.

## Hardware safety

For MicroGrow and electronics profiles, flag mains AC control, high-current loads, unsafe relay wiring, missing isolation, unknown power stages, battery charging circuits and mist driver power circuits.
