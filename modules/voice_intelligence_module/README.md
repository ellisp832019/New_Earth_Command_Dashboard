# New Earth Dashboard - Voice Intelligence Module

A drop-in module pack for adding an AI voice layer to the New Earth Dashboard.

This module is designed for:

- voice notes
- meeting transcription
- spoken dashboard assistant
- MicroGrow read-only status queries
- future gated voice control through a safety command gateway

## Core principle

Do not give AI direct control of hardware.

All hardware actions must pass through:

1. intent detection
2. permission checks
3. safety rules
4. optional human confirmation
5. local command gateway
6. audit logging

## Suggested dashboard location

```text
new-earth-dashboard/
  modules/
    voice_intelligence/
```

## V1 build scope

V1 should be safe and practical:

- record voice notes
- transcribe audio
- save notes into dashboard logs / Omega OS paths
- ask dashboard questions
- read MicroGrow node status
- summarise meetings
- create tasks from spoken notes
- keep the shared `/voice/conversation` thread locally persisted so the dashboard can resume a calm conversation after relaunch
- keep audit logs local so every voice intent remains reviewable without cloud sync
- remember the last calm provider mode and voice flags locally so the module opens the same way next time

## Later build scope

V2/V3 can add:

- real-time spoken assistant
- wake-word mode
- command deck integration
- MicroGrow relay commands through safety gateway
- New Earth Living integration
- local-first memory and user preference profiles

## Recommended OpenAI layers

- Realtime voice model for live speech-to-speech sessions
- Speech-to-text for transcription and meeting notes
- Text-to-speech for spoken replies
- tool/function calls for dashboard actions

## Files in this pack

```text
docs/fsd/VOICE_INTELLIGENCE_FSD.md
docs/architecture/VOICE_ARCHITECTURE.md
docs/safety/SAFETY_COMMAND_GATEWAY.md
docs/contracts/VOICE_MODULE_API_CONTRACTS.md
docs/codex/CODEX_BUILD_PROMPT.md
docs/testing/TEST_PLAN.md
src/* starter module stubs
examples/config/voice_module.config.example.json
examples/prompts/system_prompts.md
scripts/install_module.ps1
scripts/install_module.sh
```
