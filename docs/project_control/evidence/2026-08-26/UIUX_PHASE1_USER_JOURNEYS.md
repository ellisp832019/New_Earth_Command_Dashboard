# UI/UX Phase 1 User Journeys

Audit date: 2026-08-26
Step counts are conceptual user actions after the app is open. A Dashboard card action or direct primary-nav selection counts as one step; opening a child route counts as another.

## J1 Morning Start

START: Launch to Dashboard.

STEPS: Read hero and Today's flow; set focus if missing; choose Top 3; inspect active projects; optionally open next step.

SCREENS: Dashboard Home, Daily Flow, optional Tasks or Project Detail.

FRICTION: The core flow is present immediately, but the Dashboard is long and optional cards can compete with the day anchor.

DUPLICATION: Daily Flow overlaps Planner and Tasks for planning actions.

AUTHORITY CLARITY: Good for authored operational state; status and specialist cards need provenance.

COGNITIVE LOAD: Moderate.

RECOMMENDED DIRECTION: Keep Daily Flow as the anchor; clarify the role of optional cards and stage secondary content.

## J2 Capture A New Idea

START: Dashboard Quick Capture or Inbox.

STEPS: Open capture; enter idea; save; later process Inbox.

SCREENS: Dashboard, Quick Capture modal/card, Inbox.

FRICTION: Asset and Visual Capture also use capture language, so destination choice is not always obvious.

DUPLICATION: Quick Capture and Inbox are a valid capture/process pair, but asset and visual variants are questionable duplication.

AUTHORITY CLARITY: Local inbox owns generic authored capture; asset and visual repositories own their domain records.

COGNITIVE LOAD: Moderate.

RECOMMENDED DIRECTION: One capture entry with clear type and context.

## J3 Pick And Start The Next Task

START: Dashboard Top 3 or Next Step.

STEPS: Choose task; open task or project; edit/status or begin work.

SCREENS: Dashboard, Tasks, Project Detail.

FRICTION: Next Step may recommend an action while Top 3 represents selected work; the relationship is not always explicit.

DUPLICATION: Tasks and Top 3 are different views of the same local task authority; valid multiple view with questionable wording overlap.

AUTHORITY CLARITY: Clear local task authority.

COGNITIVE LOAD: Low to moderate.

RECOMMENDED DIRECTION: Label selected work versus recommended action consistently.

## J4 Resume An Active Project

START: Dashboard Active Projects or Projects nav.

STEPS: Select project; inspect detail; open task, journal, module or next action.

SCREENS: Dashboard, Projects, Project Detail, optional specialist screen.

FRICTION: Project Intelligence and Engineering Studio can look like alternate project homes.

DUPLICATION: Projects is operational authority; Project Intelligence is observed/bridge context; Engineering is specialist context. Valid multiple views, currently under-explained.

AUTHORITY CLARITY: Review needed at handoff.

COGNITIVE LOAD: Moderate.

RECOMMENDED DIRECTION: Keep one operational project home and make specialist links contextual.

## J5 Check Engineering / Repository Health

START: Tools > Engineering, More > Projects Intelligence, or Dashboard support actions.

STEPS: Choose the relevant surface; inspect status; open repository or engineering detail.

SCREENS: Project Intelligence, Repo Research Engine, Engineering Studio.

FRICTION: Three specialist surfaces have overlapping health language and different depths.

DUPLICATION: Questionable duplication, not authority conflict if observed versus specialist scope is shown.

AUTHORITY CLARITY: NEOS/repo observation must remain distinct from Platform Core declared truth and local project records.

COGNITIVE LOAD: High for infrequent users.

RECOMMENDED DIRECTION: Provide a single engineering-health index with clearly scoped links later.

## J6 Check Platform Core Declared Status

START: More > Platform Core Status.

STEPS: Open More; choose Platform Core Status; read declaration state and provenance.

SCREENS: More, Platform Core Status.

FRICTION: Two steps and technical naming make it specialist-discoverable rather than obvious to general users.

DUPLICATION: Must not be merged with observed NEOS or project health.

AUTHORITY CLARITY: Clear and read-only: Platform Core is declared architecture/identity/contracts/topology.

COGNITIVE LOAD: Low once found; moderate to discover.

RECOMMENDED DIRECTION: Keep specialist placement and improve plain-language subtitle/provenance.

## J7 Review Money / Treasury

START: Treasury primary navigation or Dashboard Treasury card.

STEPS: Review overview; open decisions, pots, monthly summary or setup; update local record if needed.

SCREENS: Dashboard, Treasury, child Treasury screens.

FRICTION: Dashboard prominence is configurable, so finance visibility depends on personalization.

DUPLICATION: Treasury card and Treasury home are valid multiple views.

AUTHORITY CLARITY: Local Treasury data and folder state are appropriately scoped.

COGNITIVE LOAD: Moderate because Treasury has several secondary workspaces.

RECOMMENDED DIRECTION: Keep as optional home card for users who need daily finance visibility.

## J8 Find Knowledge Or Documentation

START: More > Knowledge Library, Omega Knowledge Engine, About & Help, or Command Palette.

STEPS: Choose source; search or browse; open item; optionally follow source path.

SCREENS: Knowledge Library, Omega Knowledge Engine, About & Help.

FRICTION: Library, engine and help have different purposes but similar document/search cues.

DUPLICATION: Valid multiple view with high discoverability cost.

AUTHORITY CLARITY: Local catalogue versus generated knowledge outputs versus product help should be labeled.

COGNITIVE LOAD: Moderate.

RECOMMENDED DIRECTION: Introduce source-oriented grouping and scoped search later.

## J9 Check Backups / System Health

START: More > Systems.

STEPS: Open Systems; inspect protection; open Backup Guardian or Folder Health; review recovery details.

SCREENS: More, Systems, Backup Guardian or Folder Health.

FRICTION: Three levels and related status surfaces make the scope of each health signal unclear.

DUPLICATION: Systems, Backup Guardian and Folder Health are related valid views, but overlap is questionable.

AUTHORITY CLARITY: Local protection/recovery services should remain distinct from engineering health.

COGNITIVE LOAD: Moderate.

RECOMMENDED DIRECTION: Present one system-health summary with scoped drill-downs.

## J10 End-Of-Day Review And Carry-Forward

START: Dashboard Evening Review or Planner review.

STEPS: Review progress; note carry-forward; set tomorrow focus; park or reopen work.

SCREENS: Dashboard, Planner review, Tasks for parked work.

FRICTION: The same review state is visible in Dashboard and Planner, which can make the canonical action unclear.

DUPLICATION: Valid multiple view, with role overlap.

AUTHORITY CLARITY: Local daily plan and task state are clear.

COGNITIVE LOAD: Low to moderate.

RECOMMENDED DIRECTION: Keep Dashboard summary and make Planner the detailed editing home.

## J11 Move From Dashboard Into Command Centre

START: Dashboard Command Centre card, desktop Company link, or More.

STEPS: Open Company Command Centre or Command Deck depending on need; choose operation.

SCREENS: Dashboard, Company Command Centre or Command Deck.

FRICTION: "Command" names do not sufficiently distinguish coordination from command execution.

DUPLICATION: Questionable duplication with authority-boundary risk.

AUTHORITY CLARITY: Command Centre orchestrates; Command Deck executes local commands; Dashboard launches.

COGNITIVE LOAD: Moderate.

RECOMMENDED DIRECTION: Rename/subtitle by job and preserve separate authority.

## J12 Return From A Specialist Module To Daily Work

START: Engineering, Voice, Assets, Meetings or another specialist screen.

STEPS: Complete review; use parent back; return to Dashboard or relevant project; continue Top 3.

SCREENS: Specialist module, parent hub, Dashboard or Project Detail.

FRICTION: Return destination varies by feature and deep route.

DUPLICATION: Specialist modules are valid separate views; repeated project summaries are questionable duplication.

AUTHORITY CLARITY: Strongest when the module states its source and context.

COGNITIVE LOAD: Moderate to high for deep modules.

RECOMMENDED DIRECTION: Standardize contextual back/return affordances and preserve the daily loop.

## Journey Conclusion

The Dashboard supports a credible daily workday, especially from launch through Top 3, capture and review. The main weakness is not missing capability; it is role ambiguity once users leave the daily anchor. Phase 2 should simplify labels and transitions before considering structural removal.
