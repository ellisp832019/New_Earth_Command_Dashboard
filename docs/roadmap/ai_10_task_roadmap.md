# AI Assistant Full Roadmap

This roadmap describes the path to the best AI assistant experience for New Earth Command Dashboard.

The goal is not a flashy chatbot.
The goal is a calm, high-trust workflow assistant that helps Hayley move faster without losing control.

## North Star

The final assistant should feel like this:

- one assistant brain
- one turn-taking flow
- one speech path
- one response contract
- one source of truth for saved data
- always review-first
- always local-first where possible
- always reversible

If the assistant cannot improve clarity, reduce effort, or help the next decision, it should stay quiet.

## What "Best" Means Here

The best assistant for this app is not the one that talks the most.
It is the one that:

- understands the current task quickly
- speaks briefly and clearly
- keeps the user oriented
- suggests the next useful action
- remembers the current thread
- never overwrites user intent silently
- never auto-saves as the default
- never owns the data layer

## Core Design Rules

1. One assistant coordinator owns the turn.
2. One response model carries summary, next step, and suggested action.
3. One speech engine handles output across wake, dock, and screen.
4. One memory model carries the current thread forward.
5. One review step protects the final save.
6. One provider seam keeps local fallback and optional AI separate.
7. One calm tone should be used across all assistant surfaces.

## Assistant Architecture

The assistant should be built as a layered system:

1. Input layer
2. Turn manager
3. Drafting layer
4. Memory layer
5. Response layer
6. Speech layer
7. Review and save layer

### Input Layer

Collect input from:

- typed transcript
- microphone capture
- wake phrase
- remembered thread continuation
- wizard answers
- quick follow-up chips

### Turn Manager

The turn manager should decide:

- who owns the current turn
- whether the assistant is listening or speaking
- whether the current path is wake, dock, assistant, or wizard
- when to hand off between surfaces

### Drafting Layer

The drafting layer should produce the assistant's working draft:

- cleaned transcript
- short summary
- next step
- suggested type
- suggested title
- suggested wizard answer
- suggested local action

### Memory Layer

The memory layer should hold:

- current thread summary
- active project context
- recent entries
- follow-up state
- reusable conversation context

### Response Layer

The response layer should output a compact response contract that can power:

- UI briefing cards
- spoken replies
- wizard prompts
- quick follow-up chips
- save confirmation

### Speech Layer

The speech layer should speak in one stable voice and one stable cadence.

It should support:

- wake acknowledgement
- briefing narration
- wizard guidance
- save confirmation
- follow-up prompts

### Review and Save Layer

The save layer should stay strict:

- user reviews before save
- edits stay visible
- local data remains the source of truth
- AI suggestions stay optional

## Phase 1 - Freeze The Core Turn Model

Make the assistant behavior predictable before adding more intelligence.

Goals:

- define one canonical assistant turn
- standardize wake, assistant, dock, and wizard behavior
- remove duplicate speech behavior
- make the session state machine the single owner of turn ownership

Deliverables:

- shared turn coordinator
- shared response contract
- shared speech entry point
- shared stop/cancel behavior
- clear ownership rules

Acceptance:

- only one path speaks at a time
- only one path listens at a time
- the assistant does not feel jumpy or layered

## Phase 2 - Make The Voice Calm And Consistent

The assistant should sound like a confident operator.

Goals:

- stabilize volume and cadence
- reduce dramatic pitch changes
- keep spoken replies short
- use clean pauses between summary and next step

Deliverables:

- one speech queue
- one stable voice profile
- tone-aware wording only
- no competing TTS fallbacks during the same turn

Acceptance:

- wake does not sound louder than briefing
- save does not sound more urgent than planning
- the voice feels even and dependable

## Phase 3 - Unify The Response Contract

Every assistant output should be built from the same shape.

Goals:

- keep summary and next step consistent
- keep suggested type and title available
- keep wizard answer suggestions separate from final text
- keep hints short and actionable

Deliverables:

- one response model used everywhere
- shared parser and fallback logic
- shared formatting rules

Acceptance:

- UI cards, speech, and suggestions all point to the same answer
- the assistant does not contradict itself across surfaces

## Phase 4 - Build The Review-First Briefing Flow

The briefing flow should be the assistant's main visible value.

Goals:

- explain what the transcript means
- show the next step
- show the suggested destination type
- keep the raw input visible

Deliverables:

- briefing card
- summary line
- next-step line
- reason line
- speak briefing action

Acceptance:

- the user can understand the assistant in a glance
- the assistant does not hide the source text

## Phase 5 - Make Wizard Mode Truly Helpful

Wizard mode should feel like a guided capture, not a form.

Goals:

- ask one question at a time
- keep the next question obvious
- draft the entry as answers arrive
- let the user switch back to manual mode at any time

Deliverables:

- wizard turn state
- per-step prompts
- answer drafts
- review stage before save
- spoken "next" guidance

Acceptance:

- the user never has to guess the next step
- the assistant keeps the wizard moving calmly

## Phase 6 - Build Thread Memory That Actually Helps

Memory should reduce repetition, not create confusion.

Goals:

- remember the current thread
- summarize the latest useful context
- surface the thread when the user comes back
- let the assistant continue the same thought across sessions

Deliverables:

- thread summary card
- remembered context model
- recent-entry highlights
- thread-resume actions

Acceptance:

- the assistant can pick up where the user left off
- memory stays short enough to scan quickly

## Phase 7 - Improve Follow-Up Suggestions

The assistant should guide the user to the next best action.

Goals:

- suggest the next small action
- offer sensible follow-up chips
- adapt suggestions to the current mode
- keep the options calm and practical

Deliverables:

- quick follow-up chips
- dock suggestions
- assistant follow-up text
- context-aware action ranking

Acceptance:

- the assistant reduces decision fatigue
- the user sees a clear next move

## Phase 8 - Add AI Provider Routing

The assistant should remain usable without any external provider.

Goals:

- keep the local provider as fallback
- keep OpenAI opt-in
- keep provider choice visible
- keep all AI calls behind a seam

Deliverables:

- provider routing
- environment-based selection
- local fallback
- response parsing and fallback defaults

Acceptance:

- the app still works offline
- the assistant can be tested without network dependencies

## Phase 9 - Move To A Real Realtime Voice Workflow

Once the text and turn flow are stable, the assistant can become more live.

Goals:

- use realtime voice where it actually helps
- keep audio output steady
- avoid audio overlap
- preserve the review-first flow even with better voice

Deliverables:

- realtime speech adapter
- speech queue
- tone-specific instructions
- clean cancel/interrupt behavior

Acceptance:

- the assistant sounds more alive without becoming noisy
- voice never fights the user or itself

## Phase 10 - Add Tool Use Carefully

Tool use should be narrow and predictable.

Goals:

- let the assistant open the right surface
- let it prepare drafts and suggestions
- keep final actions visible and confirmable
- do not let AI own hidden side effects

Deliverables:

- small action schema
- tool routing rules
- confirmation gates
- safe action previews

Acceptance:

- the assistant can help execute workflow
- it still cannot bypass review

## Phase 11 - Make The Assistant Better At Workflow

This is where the assistant becomes genuinely useful in daily work.

Goals:

- help start the day
- help recover context
- help finish a task
- help park a thought safely
- help decide what to do next

Deliverables:

- morning assistant flow
- task salvage flow
- project continuation flow
- idea parking flow
- quick recap flow

Acceptance:

- the assistant saves time in real daily use
- the assistant feels like an operational partner

## Phase 12 - Quality, Safety, And Trust

The assistant must earn trust over time.

Goals:

- add strong tests
- keep failure modes calm
- keep prompts small and explicit
- keep responses deterministic where possible

Deliverables:

- adapter contract tests
- prompt shape tests
- speech stability tests
- routing tests
- fallback tests

Acceptance:

- the assistant behaves predictably in normal use and in failure cases

## What To Avoid

- Do not make the AI the source of truth.
- Do not auto-save by default.
- Do not let multiple speech systems compete.
- Do not let the assistant speak at length when a short answer will do.
- Do not let the user lose the raw text.
- Do not let the assistant become a separate product inside the app.

## Recommended Build Order

If we are building toward the best assistant, the order should be:

1. Freeze The Core Turn Model
2. Make The Voice Calm And Consistent
3. Unify The Response Contract
4. Build The Review-First Briefing Flow
5. Make Wizard Mode Truly Helpful
6. Build Thread Memory That Actually Helps
7. Improve Follow-Up Suggestions
8. Add AI Provider Routing
9. Move To A Real Realtime Voice Workflow
10. Add Tool Use Carefully
11. Make The Assistant Better At Workflow
12. Quality, Safety, And Trust

## End State

When this roadmap is complete, Gaia should feel like:

- a calm assistant that knows what matters next
- a strong reviewer that never hides the truth
- a useful workflow partner that keeps the user moving
- a voice that is steady, clear, and trustworthy
- a system that is powerful without becoming noisy

That is the assistant experience worth building toward.
