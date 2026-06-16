# Experiment API Contract

## GET /api/experiments

Returns experiment list.

## GET /api/experiments/:id

Returns full experiment record.

## POST /api/experiments

Creates experiment.

## POST /api/experiments/:id/evidence

Adds evidence reference.

## POST /api/experiments/:id/results/import-csv

Imports CSV result data.

## POST /api/experiments/:id/report

Generates report.

## POST /api/experiments/:id/sync/obsidian

Creates or updates Obsidian note.

## POST /api/experiments/:id/sync/github

Generates GitHub issue body or creates issue in future phase.
