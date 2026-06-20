# TASK - Company Command Centre Ops Tabs

## Status

In progress. The Company Command Centre shell exists, and this slice is turning the read-only tabs into useful ops surfaces with real module notes and checklist content.

## Goal

Make the most important company tabs useful first: Compliance & Deadlines, Website & Brand, LinkedIn & Marketing, and Director Action Board.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/07_non_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/09_mvp_roadmap.md`
- `modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/AGENTS.md`
- `modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/MODULE_SPEC.md`
- `modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/ui/UI_SPEC.md`
- `modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/docs/legal_finance/UK_COMPANY_ADMIN_CHECKLIST.md`
- `modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/website_next_steps.md`
- `modules/00_COMPANY_COMMAND_CENTRE_OMEGA_MODULE/data/checklists/linkedin_next_steps.md`

## Requirements

1. Keep the company module read-only in this slice.
2. Show the imported checklist and next-step content in calm cards.
3. Preserve the existing route and module registration.
4. Keep Omega OS source path visibility in Settings.
5. Keep the overview, product portfolio, grants, and action board readable without adding write actions.
6. Do not break existing modules.

## Expected Result

The Company Command Centre feels like a proper founder ops dashboard. Compliance, website, and LinkedIn work are visible, source-linked, and easy to scan without adding write complexity yet.
