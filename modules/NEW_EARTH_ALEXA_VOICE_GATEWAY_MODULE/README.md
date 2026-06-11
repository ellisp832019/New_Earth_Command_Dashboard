# New Earth Alexa Voice Gateway Module

A local-first, safety-gated Alexa integration module for the New Earth Dashboard.

This module is designed to let Alexa act as a **voice doorway** into the dashboard, not the brain of the system. Alexa sends requests to a controlled gateway. The gateway checks permissions, safety rules, confirmation requirements, audit logging, and allowed dashboard APIs before anything reaches your local systems.

## Core idea

```text
Alexa Echo / Alexa App
  ↓
Alexa Custom Skill
  ↓
Skill Endpoint / Lambda Adapter
  ↓
New Earth Voice Gateway
  ↓
Permission + Safety Layer
  ↓
Dashboard API / MicroGrow / Notes / Tasks
```

## What this module includes

- Alexa custom skill interaction model for UK English
- Node.js Lambda adapter example
- Python FastAPI local Voice Gateway
- Permission tiers and blocked-action rules
- MicroGrow read-only command examples
- Dashboard task/note/status command examples
- Audit log format
- Hardware setup guide for Echo devices
- Secure deployment checklist
- Codex handoff prompts
- Mock dashboard API for testing
- Windows start and stop launcher helpers
- Python 3.14-compatible dependency pins

## First build target

Start with **read-only and low-risk actions**:

- Ask for today's dashboard summary
- Ask for a project status summary
- Ask for MicroGrow status
- Add a dashboard note
- Add a task
- Start focus mode
- List next tasks
- Check gateway health

Blocked by default:

- File deletion
- Shell commands
- Raw Obsidian vault access
- Finance details
- Permanent relay control
- AI agent execution
- Private document reads
- Any unsafe hardware action

## Recommended module path in your dashboard

```text
modules/voice_gateway_alexa/
```

In this repo the module currently lives at:

```text
modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE/
```

## Safety principle

Alexa should never directly control your local systems. Alexa talks to the gateway. The gateway decides what is safe.

## Runtime notes

- The current dependency pins are validated against Python `3.14` on Windows.
- Create a local virtual environment before running the gateway.
- Set `NEW_EARTH_VOICE_GATEWAY_SECRET` before local smoke testing or dashboard launch-helper testing.

## Local quick start

```text
cd modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE
python -m venv .venv
.\.venv\Scripts\python.exe -m ensurepip --upgrade
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

Set your local shared secret:

```text
set NEW_EARTH_VOICE_GATEWAY_SECRET=change-this-long-random-secret
```

Then use either:

```text
scripts\launch_voice_gateway.cmd
```

or:

```text
scripts\stop_voice_gateway.cmd
```

## Local smoke test

If `NEW_EARTH_VOICE_GATEWAY_SECRET` is set in your shell, the test helper now sends the secure header automatically:

```text
bash scripts/test_gateway.sh
```
