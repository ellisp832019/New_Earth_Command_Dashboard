# New Earth Launchpad

A standalone crowdfunding, grants, investor, and product launch module for the New Earth Dashboard.

This module is designed to manage projects such as MicroGrow, BioCalm, New Earth Living, and future New Earth ventures from:

**Vision -> Prototype -> Campaign -> Funding -> Manufacturing -> Fulfilment -> Impact**

## What This Module Does

- Manages Kickstarter / crowdfunding campaigns
- Tracks prototype readiness
- Builds campaign stories in reusable blocks
- Models funding targets, fees, VAT, costs, margin, and contingency
- Tracks reward tiers and fulfilment risk
- Stores media assets, launch checklists, and backer updates
- Tracks grants, partners, investors, and pilot opportunities
- Phase 2 adds local-first media, grant, investor, partner, manufacturing, community, timeline, and analytics records
- Integrates with the New Earth Dashboard and Omega OS folder system

## Recommended Dashboard Route

`/launchpad`

## Recommended Omega OS Folder

`D:\NEW_EARTH_OMEGA_OS_PACK\24_NEW_EARTH_LAUNCHPAD`

## First Campaign Seeded

`MICROGROW_KICKSTARTER_2026`

Suggested starting funding target: `GBP 35,000`

Seed data now includes a `phase2.json` file alongside rewards and readiness so the extra Launchpad sections open with working example records.

## Quick Start

1. Copy this module into your dashboard repo under `modules/new_earth_launchpad` or similar.
2. Copy `omega_os/24_NEW_EARTH_LAUNCHPAD` into your Omega OS pack.
3. Give `codex/CODEX_BUILD_PROMPT.md` to Codex.
4. Start by implementing the campaign list, campaign detail page, reward manager, readiness tracker, finance model, and Phase 2 section views.
5. Use the seeded MicroGrow campaign data as the first working example.

## Core Principle

Do not treat Kickstarter as a webpage. Treat it as a managed operation with tasks, proof, costs, risks, story, audience, and delivery.
