# Safety Command Gateway

## Rule 1

The AI must never directly control hardware.

## Rule 2

All actions must be converted into explicit internal commands.

## Rule 3

Every command must be classified by risk.

## Risk Levels

### Low

Examples:

- create note
- create task
- summarise meeting
- read dashboard status

### Medium

Examples:

- change dashboard setting
- move file
- archive meeting
- send notification

### High

Examples:

- turn relay on/off
- run mist driver
- control heater
- control pump
- trigger electrical load
- update firmware

### Blocked

Examples:

- bypass safety checks
- disable audit logs
- control mains systems without safety validation
- run indefinite hardware commands

## V1 Policy

```json
{
  "hardwareWrites": "blocked",
  "microgrowStatusRead": "allowed",
  "taskCreate": "allowed",
  "noteCreate": "allowed",
  "meetingSummary": "allowed",
  "fileDelete": "blocked",
  "alwaysOnRecording": "blocked"
}
```

## Confirmation Rules

Later versions should require confirmation for:

- any hardware write
- file movement/deletion
- sending messages externally
- changing schedules
- firmware update actions

Example confirmation:

```text
I can turn relay 1 on for 30 seconds. This is a hardware action. Please confirm.
```

## Maximum Runtime Rules

Hardware actions must have a maximum runtime.

Examples:

```json
{
  "microgrow.mist.run": {
    "maxSeconds": 300,
    "requiresWaterLevelOk": true,
    "requiresConfirmation": true
  },
  "microgrow.relay.set": {
    "requiresNamedRelay": true,
    "requiresConfirmation": true,
    "blockedInV1": true
  }
}
```

## Audit Log Example

```json
{
  "timestamp": "2026-06-08T10:10:00+01:00",
  "userText": "Turn relay one on",
  "intent": "microgrow.relay.set",
  "riskLevel": "high",
  "decision": "blocked",
  "reason": "Hardware voice control disabled in V1"
}
```
