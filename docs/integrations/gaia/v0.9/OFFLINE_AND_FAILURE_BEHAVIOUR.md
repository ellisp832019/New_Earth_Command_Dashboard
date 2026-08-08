# Offline And Failure Behaviour

## Local-First Behaviour

The architecture must still work when:

- GitHub is unavailable
- the GAIA backend is offline
- the network is blocked
- the repository is disconnected

## Expected Behaviour

- local Git state remains observable
- Project Control canonical records remain readable
- generated local reports remain available
- the response can say `unknown` instead of guessing
- GAIA stays read-only
- no fallback path should mutate state

## Failure Modes

### Live GitHub unavailable

Return a degraded context that uses local evidence only.

### Backend unreachable

Return a stale or unavailable state and explain the failure.

### Missing or stale data

Report the missing source, label freshness honestly, and keep the answer bounded.

### Conflicting state

Surface both values and identify which one is live versus recorded.

## User Experience

The user should always see:

- what is current
- what is recorded
- what is stale
- what is missing
- what evidence backs the recommendation
