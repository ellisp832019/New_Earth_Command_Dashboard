# Repo Research Engine Architecture

## Overview

The Repo Research Engine is a local-first, read-only repository analysis module for the New Earth Dashboard ecosystem.

It turns a local Git repository into:

- a structured inventory
- a repository tree
- a structured clone workspace when a source URL or local repo is imported
- a security risk snapshot
- a profile-aware knowledge pack
- generated Codex prompts
- Omega OS export bundles

## Main Components

### Scanner

`scanner/safe_scanner.py`

- Walks the repository recursively
- Ignores build caches and other generated folders
- Classifies files by type
- Detects languages, frameworks, docs, licences, dependencies, firmware and hardware design files
- Builds a JSON inventory and repository tree
- Never executes repository code

### Workspace Manager

`sources/repository_workspace.py`

- Clones a repository into a structured workspace layout
- Separates the checked-out source from analysis, reports, exports, prompts, and metadata folders
- Writes a workspace manifest so the dashboard can resume from a known local path
- Keeps clone activity explicit and opt-in

### Profile Manager

`profiles/profile_manager.py`

- Loads JSON profiles from disk
- Normalises missing optional fields
- Validates the profile shape
- Resolves profiles by file path or profile name

### Profile Analysis

`analyser/profile_analyser.py`

- Combines inventory data with the selected profile
- Calculates a relevance score
- Identifies useful files
- Flags risk files
- Attaches security and knowledge summaries

### Security Analyzer

`analyser/security_analyser.py`

- Scans file contents for secret-like patterns
- Flags dangerous scripts and suspicious binaries
- Masks all detected values
- Produces a risk-safe security report

### Knowledge Extractor

`analyser/knowledge_extractor.py`

- Summarises the repository
- Produces architecture and learning notes
- Extracts reusable components and implementation ideas
- Builds calm, AI-ready notes without exposing secrets

### Local AI and RAG Registry

`intelligence/registry.py`

- Describes the supported local AI providers and RAG indexes
- Creates the deterministic default provider and in-memory index
- Keeps future provider and index integrations explicit and opt-in
- Preserves the local-first default when no external provider is configured

### Markdown Exporter

`exporters/markdown_exporter.py`

- Writes the main research report
- Writes the repo summary
- Writes security, risk, knowledge, implementation, and learning note reports

### Prompt Exporter

`exporters/prompt_exporter.py`

- Generates Codex prompts for the supported workflows
- Stores the prompts in `generated_prompts/`

### Omega OS Export Adapter

`exporters/omega_os_exporter.py`

- Copies the safe output bundle into the configured Omega OS research library
- Organises exports by profile and repository

### Comparison Engine

`analyser/comparison_engine.py`

- Compares two scans or snapshots
- Tracks file additions, removals, and simple change groups
- Surfaces high-level recommendations for manual review

### Repository Source Adapter Registry

`sources/source_registry.py`

- Describes the supported read-only repository providers
- Creates the concrete GitHub, GitLab, and Bitbucket adapter classes
- Keeps external repository integration explicit and snapshot-oriented
- Avoids implying any live network integration beyond future adapter slices

### Research Source Adapter Registry

`sources/research_source_registry.py`

- Describes the supported document ingestion adapters
- Creates the concrete PDF, website, transcript, and documentation adapter classes
- Keeps network access opt-in for the website adapter
- Keeps the local document research surface explicit and future-ready

### Graph Exporter

`exporters/graph_exporter.py`

- Builds dependency graphs from manifests and frameworks
- Builds architecture graphs from categories, languages, directories, and risk flags
- Writes JSON and markdown graph bundles

## Data Stores

- Local repo path
- Structured workspace clone root
- Scan inventory JSON
- Repository tree JSON
- Analysis JSON
- Markdown reports
- Generated prompts
- Omega OS export bundle

## Safety Boundary

This module is analysis-only.

It must not:

- run scripts from the researched repository
- install packages
- flash firmware
- contact external services
- copy secrets into exports

## Integration Points

- Dashboard tool page
- Omega OS knowledge vault
- Codex prompt handoff
- Future comparison and graphing tools
- Future live source integrations built on the read-only adapter registry
- Future document research integrations built on the read-only research source registry
- Future AI provider integrations built on the local AI registry
- Future RAG index integrations built on the local RAG registry
