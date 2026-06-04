# Codex Build Prompt — New Earth Launchpad Module

You are working inside the New Earth Dashboard repo. Build a standalone module called **New Earth Launchpad**.

## Goal

Create a local-first dashboard module for crowdfunding, Kickstarter planning, grants, investor outreach, manufacturing planning, and fulfilment tracking.

## Source Files

Use this repo pack as the source of truth.

Important files:

- `README.md`
- `docs/01_fsd/FSD_NEW_EARTH_LAUNCHPAD.md`
- `docs/02_architecture/ARCHITECTURE.md`
- `docs/03_data_models/DATA_MODELS.md`
- `dashboard_module/config/module.json`
- `dashboard_module/src/launchpad_models.ts`
- `dashboard_module/src/funding_calculator.ts`
- `dashboard_module/data/campaigns/MICROGROW_KICKSTARTER_2026/`

## Implementation Requirements

1. Add a `/launchpad` route.
2. Create a Launchpad overview page.
3. Load campaigns from local JSON seed data first.
4. Show campaign cards with status, funding target, readiness, and next action.
5. Add campaign detail page for `MICROGROW_KICKSTARTER_2026`.
6. Add tabs:
   - Overview
   - Story
   - Readiness
   - Rewards
   - Finance
   - Risks
   - Media
   - Checklist
7. Implement finance calculator from `funding_calculator.ts`.
8. Keep all data local-first.
9. Add export buttons later for Markdown, JSON, and CSV.
10. Do not connect to Kickstarter API yet. This is a planning/operations module first.

## MVP Screens

### Launchpad Overview

Cards:

- MicroGrow Kickstarter 2026
- BioCalm Future Campaign placeholder
- New Earth Living placeholder

### MicroGrow Campaign Detail

Show:

- Funding goal: £35,000
- Status: Prototype
- Readiness checklist
- Reward tiers
- Finance model
- Story blocks
- Risk register

## Design Tone

Professional, calm, grounded, New Earth aligned.

Avoid hype. Make it feel like a serious campaign operations centre.

## Safety / Business Logic

The module must clearly separate:

- Planned features
- Working prototype proof
- Future vision
- Risks and dependencies

Do not present unbuilt features as completed.
