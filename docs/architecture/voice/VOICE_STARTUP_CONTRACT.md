# Voice Startup Contract

This document describes the contract for the non-blocking voice startup flow.

## Purpose

The startup coordinator gives the app one explicit place to evaluate whether optional voice capabilities are ready.

It is designed to:

- keep the dashboard responsive
- probe voice readiness after the shell is up
- make failure states visible and retryable
- keep the logic testable in isolation

## Core Pieces

- `VoiceStartupCoordinator`
- `VoiceStartupState`
- `VoiceStartupStatus`
- `VoiceStartupProbe`
- `VoiceStartupStatusChip`

## Startup Inputs

The coordinator uses:

- the current settings snapshot
- `voiceAssistantEnabled`
- `voiceStartupGateEnabled`
- an injected voice probe implementation

The default probe may consult:

- platform availability
- Windows audio device discovery
- `speech_to_text` permission and initialization

## State Model

The visible states are:

- `disabled`
- `initializing`
- `ready`
- `unavailable`
- `permissionDenied`
- `hardwareMissing`
- `pluginUnavailable`
- `failed`

## Contract Rules

- If voice is disabled in settings, startup does not begin.
- If settings are still loading, the coordinator stays quiet and the shell continues normally.
- If voice is enabled, startup is asynchronous and bounded by timeout.
- Hardware, permission, and plugin failures are reported as explicit states.
- Retry is only exposed for states that can recover.

## Non-Goals

- Do not block dashboard rendering on voice startup.
- Do not require login or cloud services.
- Do not couple voice startup directly to assistant capture or turn routing.

## Implementation Notes

- The coordinator is driven by Riverpod.
- The status chip is only a presentation surface for the coordinator state.
- Detailed failure explanations live in `VOICE_FAILURE_STATES.md`.
