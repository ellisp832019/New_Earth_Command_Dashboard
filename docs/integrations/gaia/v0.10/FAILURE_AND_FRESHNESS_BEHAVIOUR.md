# Failure and Freshness Behaviour

The programme intelligence surface fails closed.

## Supported States

- loading
- healthy / available
- stale
- unknown
- backend unavailable
- backend incompatible
- partial / missing data

## Behaviour

- loading does not imply success
- stale data stays visible and labelled stale
- unavailable data does not become healthy
- incompatible data does not become healthy
- missing fields are not invented locally
- parse failures do not manufacture a healthy state
- refresh failures preserve the last known state where possible

## Observed Signals

The host screen surfaces the controller state through status pills and the package views surface the detailed read-only content.

The user can still reach the GAIA Control Centre guidance when the backend is unavailable or incompatible.
