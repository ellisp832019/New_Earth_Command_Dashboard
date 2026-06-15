# Future Architecture Map

This map shows how the project is intended to fit together over time.

## Shell Layer

The shell is the calm outer frame of the product.

Includes:
- Dashboard
- Tasks
- Planner
- Projects
- Journal
- Inbox
- Learning
- Content
- Business
- Wellbeing

Purpose:
- keep the daily workflow simple
- avoid overwhelm
- make today's useful action easy to find

## Module Layer

The Module Hub is the control surface for module discovery and handling.

Includes:
- module registry
- module detail views
- module operations
- permission checks
- dock planning
- health and governance

Future role:
- host modules without hard-coding them into the shell
- allow local module registration through manifests
- support live docking when the shell needs it

## Voice Layer

Voice is the conversational input and review layer.

Includes:
- voice capture
- wizard flows
- briefing cards
- remembered threads
- wake phrase handling
- shared session state

Future role:
- let users capture and review by speech
- keep one shared voice session path
- add safe AI assist only through a stubbed adapter

## Knowledge Layer

Knowledge is the documentation and repo-awareness layer.

Includes:
- Knowledge Library scanning
- Obsidian sync
- Repo Intelligence Bridge
- dashboard exports

Future role:
- make repo folders easier to read
- keep project memory local
- support multiple New Earth repos with the same structure

## Operational Layer

This layer is where physical or practical work lives.

Includes:
- Treasury
- Assets
- QR labels
- print queue
- evidence links

Future role:
- keep operational data traceable
- support receipts, warranties, locations, and handoffs

## AI Layer

AI is intentionally downstream of the stable local system.

Planned shape:
- adapter contract
- local stub provider
- opt-in settings
- safe permission gates
- later real provider, if needed

Principle:
- AI should support the local workflow, not replace it

## Integration Layer

External integrations are postponed until the core is strong enough.

Examples:
- calendar
- GitHub
- WordPress
- MicroGrow live links
- cloud sync

Principle:
- integrate only when the local workflow is already calm and trustworthy

## Long-Term Shape

The project is aiming for:

- one calm dashboard shell
- many locally registered modules
- voice as a safe control path
- knowledge as a local memory fabric
- AI as an optional assistant layer
- integrations only after the core is stable
