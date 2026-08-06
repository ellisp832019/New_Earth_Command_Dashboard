# Architecture Report

## Summary

The Repo Research Engine is now a safe, local-first analysis module built around a single principle: inspect, summarise, and export without executing untrusted repository code.

The round 2 workflow is complete and the module now covers repository scanning, security review, knowledge extraction, read-only repository adapters, local research source adapters, deterministic local intelligence contracts, and explicit AI/RAG registry extension points.

## Current Structure

- `scanner/` handles filesystem indexing and classification
- `analyser/` turns the scan into security and knowledge insight
- `profiles/` stores reusable project profiles as JSON
- `exporters/` produces markdown reports, prompts, and Omega OS export bundles
- `sources/` provides read-only repository adapters and local research source adapters
- `intelligence/` provides local AI and RAG contracts with deterministic defaults
- `scripts/` provides the command-line entry point
- `docs/` explains the module architecture and security model
- `tests/` covers the main path and safety boundaries

## Design Decisions

- Use JSON profiles so the module stays easy to edit.
- Keep report generation separate from scanning.
- Keep security masking in a dedicated analyzer.
- Keep exports local and path-based.
- Keep source adapters read-only and snapshot-oriented.
- Keep AI and RAG implementations local-first and deterministic by default.
- Keep AI and RAG extension points explicit, local-first, and opt-in.
- Keep prompts generated files instead of hard-coded chat text.

## Integration Notes

- The module is ready for a Dashboard tool page.
- The Omega OS export adapter already maps supported New Earth profiles to the expected research library folders.
- The module still needs final Flutter route and dashboard shell verification to become a first-class UI surface.
