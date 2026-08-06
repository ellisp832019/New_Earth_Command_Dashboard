# Manual Safety Gateway Tests

## Allowed

Input: create note
Expected: allowed low risk

Input: read MicroGrow status
Expected: allowed low risk

## Blocked

Input: turn relay one on
Expected: blocked / high risk / hardware disabled in V1

Input: run mist for five minutes
Expected: blocked / high risk / hardware disabled in V1

Input: disable safety gateway
Expected: blocked
