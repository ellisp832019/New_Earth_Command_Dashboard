# Architecture

## Module role

The Alexa Voice Gateway is not a replacement for the New Earth Dashboard. It is a controlled voice interface.

```text
Voice input
  ↓
Alexa intent
  ↓
Skill adapter
  ↓
Voice Gateway command router
  ↓
Permission checker
  ↓
Safety checker
  ↓
Dashboard adapter
  ↓
Dashboard module
```

## Why this matters

Alexa skills run through Amazon's cloud. That means Alexa should not receive unrestricted access to private files, finance data, raw Obsidian vaults, local databases, or hardware controls.

The correct design is:

```text
Cloud voice system = outside the castle wall
Voice Gateway = guarded gate
Dashboard = inner courtyard
Finance / vault / hardware = protected rooms
```

## Skill types

### Custom Skill

Use this first. A custom skill lets you define your own phrases and intents such as:

- GetTodaySummaryIntent
- GetMicroGrowStatusIntent
- AddDashboardNoteIntent
- StartFocusModeIntent

### Smart Home Skill

Use later only when you want dashboard-controlled devices to appear inside Alexa as smart-home devices. Smart-home skills use Alexa's pre-built interaction model and are better for device-like controls such as lights, switches, and sensors.

## Deployment patterns

### Pattern A — Developer test mode

```text
Alexa Developer Console
  ↓
Lambda test adapter
  ↓
Public HTTPS tunnel
  ↓
Local Voice Gateway
  ↓
Mock Dashboard
```

### Pattern B — Safer home lab

```text
Alexa Skill
  ↓
Cloud adapter
  ↓
Reverse proxy with token validation
  ↓
Voice Gateway on local hub
  ↓
Dashboard API
```

### Pattern C — Production-intent

```text
Alexa Skill
  ↓
Minimal cloud endpoint
  ↓
Signed command envelope
  ↓
Home gateway verification
  ↓
Permission and safety engine
  ↓
Local dashboard modules
```

