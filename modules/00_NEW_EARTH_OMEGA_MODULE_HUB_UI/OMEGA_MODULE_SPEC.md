# Omega Module Hub Specification

## Purpose

The Module Hub is the dashboard layer that allows New Earth systems to grow without turning the app into one tangled codebase.

It provides the foundation for modules to be:

- registered
- displayed
- enabled
- disabled
- permission-gated
- docked
- monitored
- documented
- linked into Omega OS records

## Core concepts

### Module Manifest

Every module must have a manifest. The manifest describes what the module is, what permissions it requests, where it can dock, and what backend/service it may eventually use.

### Module Registry

The registry is the source of truth for installed or known modules.

The first version can use static mock data. Later versions can load manifests from local folders.

### Module Detail

Every module gets a detail page. This avoids hidden functionality and makes the dashboard feel like an operating system.

### Permission Gate

Powerful modules must request permissions instead of assuming access.

### Dock Manager

Dockable modules can be mounted into dashboard zones.

### Omega OS Link

Every major module should have a matching Omega OS record folder for decisions, security, tests, changes and governance.

## Module lifecycle

1. Proposed
2. Registered
3. Installed
4. Disabled
5. Enabled
6. Docked
7. Running
8. Warning
9. Error
10. Archived

## UI states

- Not installed
- Installed
- Disabled
- Enabled
- Running
- Needs configuration
- Needs review
- Error
- Archived

## Security principle

AI, automation, device control and file access modules must be treated as privileged capabilities.

The dashboard should act as the gatekeeper, not the assistant or module itself.
