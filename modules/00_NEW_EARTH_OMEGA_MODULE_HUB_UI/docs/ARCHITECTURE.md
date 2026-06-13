# Architecture

## Recommended shape

```text
Flutter Dashboard
  └── Module Hub UI
       ├── Module Registry
       ├── Module Cards
       ├── Module Detail Screens
       ├── Permission UI
       ├── Health UI
       └── Dock Manager Placeholder

Future Services
  ├── Python AI Assistant Service
  ├── Backup Service
  ├── Obsidian Sync Service
  ├── Repo Research Service
  ├── Grants Tracker Service
  └── MicroGrow Local Device Bridge
```

## First build scope

The first build should not launch real backend services.

It should create:

- models
- mock data
- screens
- navigation routes
- dock placeholders
- permission display
- health placeholders

## Future backend integration

Backend-capable modules should communicate through a local service bridge:

- HTTP for commands and configuration
- WebSocket for logs and live events
- file-based manifests for metadata
- local config files for module settings

## Why this matters

This keeps the dashboard from becoming a single giant app. Instead, the dashboard becomes an operating layer that can host independent capabilities.
