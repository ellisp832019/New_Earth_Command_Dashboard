# UI/UX Phase 2 Target Information Architecture

Audit date: 2026-08-26
This is a target design, not an implementation plan applied to source.

## Target Architecture

```text
COMMAND DASHBOARD
  HOME
    Dashboard Home
      Daily Flow [today focus capability]
      Top 3 [task selection view]
      Active Projects [project context view]
      Next Step [recommendation view]
      Quick Capture [capture action]
      Evening Review [review view]
      Optional cards: Treasury, Command Centre, Support Stack

  PRIMARY DAILY WORK
    Daily Flow
    Tasks
    Planner
    Projects
    Inbox

  SECONDARY / MORE
    Work: Treasury, Assets, Meetings
    Knowledge: Knowledge Library, About and Help
    Personal: Journal, Learning, Content, Business, Wellbeing
    Systems: Systems, Backup Guardian, Folder Health
    Integration views: Company Command Centre, Platform Core Status

  SPECIALIST
    Engineering Studio
    Project Intelligence
    Repo Research Engine
    Omega Knowledge Engine
    Experiments
    Launchpad
    Funding and Grants
    Voice Intelligence, Voice Assistant, Alexa Gateway
    Users and Devices
    Module Hub

  ADMIN / SETTINGS
    Settings
    Users and Devices administration
    Module governance and permissions

  HARDWARE / DEVELOPMENT
    Command Deck software support
    QR Studio
    Calm UI Demo

  FUTURE
    Physical Command Deck interaction
    CAP-01 capability registry
    LANE-01 lane board and workflow context
```

## Placement Decisions

Daily Flow remains the non-hideable home anchor. Tasks is the actionable inventory. Planner owns future scheduling and review. Projects owns human project context. Inbox processes captured input. Quick Capture is an action, not a destination or data owner.

Platform Core Status remains a specialist read-only adapter. NEOS/repository health remains observed engineering truth. Engineering Studio remains a technical workflow surface. Project Intelligence becomes contextual bridge material rather than a competing project home.

Command Centre remains the software orchestration destination. Command Deck is not merged into it; existing software surfaces move conceptually to Hardware / Development or Specialist and do not belong in primary daily navigation.

## Information Hierarchy Principles

- Put decisions needed every day closest to launch.
- Keep one clear owner for each authored state.
- Present external truth as an adapter with a short provenance label.
- Use More for occasional work, not as an unstructured archive.
- Keep specialist depth available without making it compete with Today.
- Make every deep route offer a clear return to its parent context or Dashboard.

## Target Outcomes

The target should answer, in order: what matters today, what is next, what project needs attention, where to capture, what needs review, and only then which specialist or administrative tool is relevant. This reduces simultaneous choices without deleting current capability.
