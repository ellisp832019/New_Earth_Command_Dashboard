# Functional Specification Document — New Earth Launchpad

## 1. Product Name

New Earth Launchpad

## 2. Product Type

Standalone dashboard module for crowdfunding, product launch planning, grants, investor outreach, and fulfilment tracking.

## 3. Primary User

Peter / New Earth project owner.

## 4. Main Objectives

- Turn project visions into structured campaigns.
- Track readiness before going public.
- Keep funding targets grounded in real costs.
- Avoid campaign failure through poor fulfilment planning.
- Export campaign material into Kickstarter, website pages, PDF packs, investor decks, and grant applications.

## 5. MVP Scope

### Must Have

- Campaign list
- Campaign detail page
- Campaign status pipeline
- Story block editor
- Prototype readiness checklist
- Reward tier manager
- Financial model
- Risk register
- Launch checklist
- Media asset index
- Backer update drafts
- Omega OS export/import paths

### Should Have

- Grant tracker
- Investor/partner CRM
- Manufacturing quote tracker
- Supplier list
- Fulfilment status board
- Campaign analytics placeholders

### Later

- Kickstarter API integration if available/appropriate
- Email list integration
- Website publishing integration
- AI campaign review assistant
- Automatic PDF pitch pack generation
- Supplier quote comparison
- Backer fulfilment shipping integration

## 6. Campaign Statuses

- Idea
- Research
- Prototype
- Pre-Launch
- Live
- Funded
- Manufacturing
- Fulfilment
- Complete
- Archived

## 7. Key Entities

- Campaign
- Reward Tier
- Story Block
- Readiness Item
- Cost Item
- Risk
- Media Asset
- Supplier
- Grant
- Investor
- Partner
- Backer Update
- Fulfilment Batch

## 8. MVP Screens

### `/launchpad`

Overview of all campaigns, status, target, launch readiness, funding target, and next action.

### `/launchpad/campaigns/:id`

Single campaign dashboard.

### `/launchpad/campaigns/:id/story`

Reusable story blocks.

### `/launchpad/campaigns/:id/rewards`

Reward tiers, quantities, COGS, shipping, margin.

### `/launchpad/campaigns/:id/finance`

Funding goal, fees, VAT/tax placeholder, manufacturing costs, contingency, actual usable funds.

### `/launchpad/campaigns/:id/readiness`

Prototype, firmware, app, documentation, media, manufacturing, legal, fulfilment readiness.

### `/launchpad/campaigns/:id/risks`

Risk register and public disclosure notes.

### `/launchpad/campaigns/:id/media`

Photos, videos, diagrams, screenshots, campaign graphics.

### `/launchpad/campaigns/:id/checklist`

Pre-launch, launch day, live campaign, post-campaign checklist.

## 9. Acceptance Criteria

The MVP is done when the user can:

- Create a campaign.
- Add reward tiers.
- Enter costs.
- See a calculated funding goal model.
- Track readiness percentage.
- Build Kickstarter story sections.
- See missing launch tasks.
- Export campaign pack to Omega OS.
