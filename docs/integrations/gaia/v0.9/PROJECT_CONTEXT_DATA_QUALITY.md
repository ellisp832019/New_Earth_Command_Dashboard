# Project Context Data Quality

## Quality Dimensions

- `completeness`
- `consistency`
- `freshness`
- `provenance`
- `redaction`
- `observability`

## Quality States

- `good`
- `degraded`
- `stale`
- `conflicting`
- `missing`

## Rules

- A snapshot may be complete enough for recommendation even when some fields are missing.
- A snapshot is not `good` if stale live state is being presented as current.
- A snapshot is `degraded` if GitHub enrichment is unavailable but local evidence is still useful.
- A snapshot is `conflicting` when canonical records disagree with live observation and the difference matters.
- A snapshot is `missing` only when a required field cannot be produced at all.

## Warnings GAIA Should Surface

- recorded state differs from live state
- CI evidence is stale or unavailable
- verification is present but not current
- risk review is old
- module documentation is partial or missing
- live GitHub data could not be fetched

## Recommendation Discipline

GAIA must not hide uncertainty.
If the data quality is degraded, the response should say why and what evidence is missing.
