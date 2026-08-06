# Module Manifest Schema

Every future module should have a `module_manifest.json` file.

## Required fields

```json
{
  "id": "newearth.example_module",
  "name": "Example Module",
  "version": "0.1.0",
  "category": "AI & Automation",
  "description": "Short description.",
  "status": "disabled",
  "dockable": true,
  "defaultDockPosition": "right",
  "permissions": [],
  "omegaOsPath": "OMEGA_OS/MODULES/EXAMPLE_MODULE"
}
```

## Recommended categories

- AI & Automation
- Knowledge & Research
- Project Management
- MicroGrow
- Finance & Treasury
- Backup & Recovery
- Voice & Hardware
- XR & Visual Systems
- Community & Outreach
- Security

## Recommended status values

- proposed
- installed
- disabled
- enabled
- running
- needs_configuration
- warning
- error
- archived
