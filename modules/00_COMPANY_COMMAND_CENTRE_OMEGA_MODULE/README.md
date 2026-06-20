# 00_COMPANY_COMMAND_CENTRE

Omega Dashboard module for **New Earth Advanced Technologies Ltd**.

This module turns the Omega OS company folder at:

`D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY`

into a live command centre inside the dashboard.

## Dashboard route

Open the first read-only shell at:

`/modules/company-command-centre`

The Module Hub also exposes the module tile automatically from the module manifest.

## Purpose
Track company records, Companies House deadlines, Tide banking tasks, website/domain/email status, LinkedIn/company profile actions, grants, partnerships, IP, assets, product portfolio, evidence, marketing, and director actions.

## Recommended repo location

```text
modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE
```

or:

```text
src/modules/00_COMPANY_COMMAND_CENTRE
```

## Build order
1. Drop this module into the dashboard repo.
2. Register it in the Module Hub.
3. Build the UI shell using mock data first.
4. Add read-only loading from `D:\NEW_EARTH_OMEGA_OS_PACK\00_COMPANY`.
5. Add write-back only later, with backup and audit logging.

## Running it

1. Start the dashboard app.
2. Open the Module Hub from `More`.
3. Select `Company Command Centre`, or open `/modules/company-command-centre` directly.
4. Use the `Settings` tab to confirm the Omega OS source path.
