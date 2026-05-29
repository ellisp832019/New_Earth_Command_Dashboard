# Voice Assistant Guide

The Voice Assistant is the app's local-first voice capture and command surface.
It is designed to help you speak something once, review it calmly, and then turn it into the right kind of action without losing the thread.

This guide is a living page. It will grow as the voice layer gets smarter.

---

## What This Is For

Voice capture is most useful when you already know the thought is worth keeping, but you do not want to stop and type it out.

Use the Voice Assistant when you want to:

- capture a task without losing momentum
- create a project with a clear first shape
- turn a passing idea into something useful later
- draft a journal entry while the thought is still fresh
- create a content seed or business lead quickly
- prepare a Codex prompt for review
- jump into the right part of the app from one spoken phrase

The tone is intentionally calm:

- speak
- review
- adjust
- save

That review step matters. It keeps the system trustworthy and easy to use.

---

## What It Does Today

The current Voice Assistant can:

- capture speech with explicit press-to-listen controls
- keep a lightweight handsfree wake listener armed while Gaia is open on Windows
- use a stronger local desktop speech bridge on Windows when available so the app can capture audio through Whisper instead of relying only on the system dictation path
- fall back to pasted text or mock transcripts when needed
- suggest a command type from the transcript
- extract useful details like project, task category, priority, and business hints
- create a project with guided status, priority, vision, and next-action fields
- preload ready-made voice templates
- show a command router with the next likely moves
- recognize wake phrases like `Hey Gaia` and strip them before parsing the command
- surface smart review macros such as `Summarize Today` and `What\'s Next`
- save reviewed captures into local dashboard data
- prepare Codex prompts for manual review only
- recall past voice commands from history
- search the command history by phrase or type and tap a result to restore it
- speak short assistant replies and voice briefings on Windows using the locally installed system voices
- greet once at startup on Windows when voice replies are enabled, so you know Gaia is ready before you speak
- speak the captured wake response back through the headset when the dashboard conversation dock appears
- surface quick follow-up chips in the dashboard dock so you can continue the conversation into a task, project, journal entry, or another assistant step without leaving the dashboard
- use shortcut templates for carry-forward, meeting notes, project checkpoints, quick reviews, and business follow-ups
- run action macros such as `Start Build Day`, `Plan Day`, `Summarize Today`, `Recall Memory`, `What's Next`, and `Continue Thread`
- keep the wake layer, dashboard dock, and full assistant aligned through one shared voice session so only one path owns speaking or listening at a time

It does not:

- run automatically in the background when Gaia is closed
- auto-execute Codex changes
- replace your judgment
- write to cloud services

---

## Where To Open It

You can open `Voice Assistant` from:

- `Dashboard` quick capture
- `More`

Use whichever path is closer to the work you are already doing.

If Gaia hears the wake phrase while you are on the dashboard, the conversation dock can appear in the bottom-right corner with the summary, next step, and captured transcript, and Gaia can speak that captured response back through the configured voice output. The dock also offers quick follow-up chips so you can keep the conversation moving into a task, project, journal entry, or another next step. Use `Open Assistant` if you want to jump into the full Voice Assistant screen from there.

---

## First-Time Flow

If you have not used it before, this is the simplest way to start:

1. Open `Voice Assistant`
2. Choose a starting point:
   - speak into the microphone
   - paste a transcript
   - use a mock transcript
   - tap a starter template
   - reuse something from command history
3. Review the transcript
4. Let the assistant suggest a type, title, and project
5. Check the `Command Router` for the next likely move
6. Edit the fields if needed
7. Save it into the right local module

The rule is simple: capture first, review second, save last.

---

## Screen Layout

The current screen has four main parts:

1. The capture controls
2. The transcript preview
3. The assistant reply, starter deck, and command router
4. The command history

Think of it as a small intake desk:

- the controls gather the raw thought
- the transcript shows you what the app heard
- the assistant reply gives you a plain-language read on what the command seems to be
- the router helps you decide what to do next
- history lets you reuse good phrasing later
- a small dashboard conversation dock can surface the wake response on the dashboard if the route handoff is still settling

---

## Capture Controls

The capture controls support a few different ways of getting words into the app.

### Start Listening

Use this when you want to speak live.

On Windows, Gaia first tries the local desktop speech bridge so it can record and transcribe your voice locally. If the bridge is not available, it falls back to native Windows voice typing inside the transcript field.

### Stop

Use this when you are done speaking and want to review the words.

### Cancel

Use this when you want to stop the current attempt and discard the capture flow.

### Paste Transcript

Use this when:

- Windows voice typing is not available
- you already have text copied somewhere else
- you want to move quickly without speaking

### Use Mock Transcript

Use this for testing or when you want to see the review flow without speaking.

---

## Voice Output

Voice Assistant can read short replies aloud on Windows using the system voices installed on your device.

You can tune voice output in `Settings`:

- turn assistant speech on or off
- choose a system voice
- preview the selected voice
- adjust speech rate
- keep the pitch preference saved for later tuning

The assistant uses voice output in a few places:

- `Speak Reply` for the short assistant response
- `Speak Briefing` for the numbered voice summary
- `Continue Thread` when a remembered thread is resumed
- the dashboard conversation dock can also speak the captured wake response when it appears on the dashboard
- the dashboard conversation dock can also offer quick follow-up chips that reopen the assistant with a preselected intent

If you do not want the app speaking back, turn off `Speak Assistant Replies` in `Settings`.

---

## Transcript Review

The transcript preview is the part that turns raw input into something safe to save.

You can:

- edit the text
- shorten it
- add missing detail
- correct a wrong word
- leave it alone if it already looks right

This is where the assistant earns your trust.

If the transcript is close but not quite right, fix it here before saving.

---

## Voice Starter Deck

The `Voice Starter Deck` gives you one-tap commands that are already shaped for common work.

Current presets:

- `Build Day`
- `Task`
- `Journal`
- `Content`
- `Business`
- `Codex`
- `Idea`

Use them when you want to move fast without inventing the structure from scratch.

### Good Uses

- `Build Day`: start the day with a calm planning prompt
- `Summarize Today`: turn the day into a review or journal shape
- `What\'s Next`: surface the next practical move
- `Task`: capture a concrete action
- `Journal`: log what moved forward
- `Content`: turn progress into a publishable idea
- `Business`: capture a follow-up or opportunity
- `Codex`: prepare a safe prompt for later review
- `Idea`: park a future thought without letting it take over today

### When To Use The Starter Deck

Use a starter when:

- you know the general shape of the command
- you want a faster entry point than speaking from scratch
- you keep using the same kind of capture over and over
- you want the app to guide you toward a stronger structure

---

## Action Macros

The `Action Macros` card is the quick-execution layer.

It gives you one-tap ways to run the most common assistant moves without rebuilding the prompt from scratch.

Current macros:

- `Start Build Day`
- `Plan Day`
- `Summarize Today`
- `Recall Memory`
- `What's Next`
- `Continue Thread` when a remembered thread is available

Use macros when you already know the move and want Gaia to preload the right assistant shape immediately.

### Good Uses

- `Start Build Day`: open a calm build-day planning flow
- `Plan Day`: turn the current thread into a short action plan
- `Summarize Today`: open the reflective day-review prompt
- `Recall Memory`: ask Gaia what she remembers about the current thread
- `What's Next`: open the next-step prompt for the current thread
- `Continue Thread`: keep the remembered conversation moving

### When To Use Action Macros

Use a macro when:

- you know the direction already
- you want the assistant to act immediately
- you keep returning to the same high-level moves
- you want a stronger shortcut than typing the full command again

---

## Command Router

The `Command Router` is the assistant's "next moves" layer.

It helps answer:

- What is this probably for?
- Where should I take it next?
- Do I need to open a screen before I save it?

Typical router actions include:

- Open Dashboard
- Open Tasks
- Open Planner
- Open Journal
- Open Content
- Open Business
- Open Inbox
- Open Projects
- Load a matching voice template
- Run the common action macros when the current thread already points to one

### How To Use It

Tap a router button when you want the assistant to take you to the right place or load a better command shape.

Use it as guidance, not as autopilot.

If you start with a wake phrase, the router can also give you a fast starting point for the next command instead of treating the wake phrase as the whole task.

### What It Feels Like In Practice

If you say something like:

- `Start my build day`
- `Review my tasks`
- `Draft a journal entry`
- `Prepare a business follow-up`
- `Open the project for MicroGrow`

the router will try to surface the most likely next move instead of leaving you to guess where the command belongs.

---

## Assistant Reply

The `Assistant Reply` card gives you a short plain-language read on what the app thinks you said.

It is not trying to sound clever for its own sake. It is there to make the flow feel clearer.

The reply usually includes:

- what kind of command it thinks this is
- what the app can do next
- what to check before saving
- project context when the transcript points to one
- thread context when you are continuing a voice conversation

Use it as a quick sanity check before you commit the capture.

When it helps most:

- you want a fast explanation before you choose a route
- the transcript is close but not completely obvious
- you want the app to feel more like a live assistant than a blank form

---

## Voice Briefing

The `Voice Briefing` card takes the reply one step further.

It turns the current command into a small guided sequence so you can move through the next likely actions in order.

The briefing usually includes:

- a short summary of the command
- the next practical step
- project context if one is detected
- a numbered suggested sequence of actions

This is the closest thing the current app has to a day-level spoken briefing.

Use it when you want the assistant to help you move from capture to action without making you think through the entire structure yourself.

Common examples:

- build day commands may guide you toward Planner, Tasks, and the build-day template
- task commands may guide you toward Tasks, Planner, and the task template
- journal commands may guide you toward Journal and the reflection template
- business commands may guide you toward Business and the opportunity template
- idea commands may guide you toward Inbox and a future-idea shape
- if the assistant has thread memory, the briefing will also point back to the current thread so you can continue it quickly

---

## Wizard Mode

`Wizard Mode` turns the assistant into a step-by-step conversation.

Instead of filling the whole transcript at once, the app asks one question at a time and builds the draft from each answer.

Typical flow:

1. Choose `Wizard`
2. Answer what kind of entry you want
3. Answer the title
4. Answer the project
5. Answer the details
6. Review the assembled draft
7. Save only when it reads right

This mode is useful when you want the app to slow the pace down and help you think through the entry as you go.

It is especially helpful for:

- business opportunities with several moving parts
- journal entries where you want a better reflection shape
- content ideas that need a title and a destination
- tasks that need more than one quick fact

You can still switch back to `Quick Capture` whenever you want the faster path.

### Current Thread

When Voice Assistant has a remembered thread, it shows a `Current Thread` card above the wizard and capture area.

That card is there to help you keep the conversation going instead of starting from scratch.

It shows:

- the current thread summary
- the thread label
- how many entries have been captured in that thread

From there, you can:

- `Continue Thread` to pick up the current voice thread in Wizard mode
- `New Thread` to clear the memory and start fresh

This makes the voice layer more useful for ongoing work like a project follow-up, a long task, or a sequence of related notes.

---

## Command History

Every reviewed command is stored in memory during the session.

You can tap a previous history item to bring it back into the transcript field.

This is useful when:

- you repeat the same kind of command often
- you want to reuse a good phrasing
- you want to edit a previously captured idea instead of starting over
- you want to reopen a thread and keep building on it

History is meant to save time, not create clutter.

### Good Habit

If a command was almost right, reuse it and refine it instead of starting again from a blank screen.

That keeps the app feeling responsive and human.

---

## Command Types

### Task

Use this when the voice capture is a concrete action.

Examples:

- review the dashboard cards
- fix the task flow
- move today's work into Top 3

### Project

Use this when the voice capture is a larger piece of work that needs a container of its own.

Examples:

- launch the voice workflow project
- set the first milestone for the dashboard assistant
- define the vision and next action for MicroGrow

### Journal Entry

Use this when the capture is reflective.

Examples:

- today I improved the voice assistant
- I learned why review-first capture matters

### Content Idea

Use this when the voice capture could become a post, draft, or note for the public-facing story.

Examples:

- draft a LinkedIn update about the voice workflow
- write a website journal about the build

### Business Opportunity

Use this when the voice capture is about jobs, partnerships, funding, or practical leads.

Examples:

- follow up with a contact
- track a grant idea
- note a partnership next step

### Idea

Use this when the thought is useful, but not for today.

Examples:

- build a morning voice flow
- add a better command summary later

### Codex Prompt

Use this when you want a review-first prompt for future code work.

The prompt is prepared locally and copied for your approval.

---

## What The Assistant Tries To Infer

When the transcript gives enough signal, the assistant can suggest:

- task category
- task priority
- project link
- project status
- project priority
- project vision
- project next action
- journal "worked on"
- journal "learned"
- journal next actions
- content platform
- content type
- business type
- business status
- business contact
- business next action

These fields are still editable before save.

---

## Example Sessions

### Example 1: Start a build day

1. Open `Voice Assistant`
2. Tap `Build Day`
3. Say what you want the day to be about
4. Review the router suggestions
5. Open `Tasks` or `Planner`
6. Save the useful parts

### Example 2: Capture a task quickly

1. Tap `Task`
2. Say the action
3. Check the suggested category and project
4. Fix the transcript if needed
5. Save it as a task

### Example 3: Turn a thought into a journal note

1. Tap `Journal`
2. Speak the reflection
3. Review the parsed title and details
4. Save it as a journal entry

### Example 4: Prepare a Codex prompt

1. Tap `Codex`
2. Speak the request
3. Review the prompt carefully
4. Copy it when it reads well

---

## Best Way To Use It Right Now

If you want a simple daily flow:

1. Open `Voice Assistant`
2. Tap `Build Day`
3. Speak your plan
4. Let the router guide you to Tasks, Planner, or Dashboard
5. Save the useful parts
6. Reuse the history item later if needed

If you want a capture flow:

1. Tap `Task`, `Journal`, `Content`, `Business`, or `Idea`
2. Speak the thought
3. Review the transcript
4. Save it to the right place

If you want a code flow:

1. Tap `Codex`
2. Review the prompt carefully
3. Copy it when it is ready
4. Use it only after you are happy with the wording

---

## Windows Notes

On Windows, `Start Listening` opens native Windows voice typing in the transcript field.

That means:

- the app stays stable
- fullscreen mode is preserved
- you can still review the text before saving
- Gaia waits for a connected headset or headset microphone before the app fully opens on Windows
- while the headset gate is showing, Gaia keeps rechecking automatically so you can connect a headset without restarting

Gaia also keeps a small wake listener armed while the app is open, so saying `Hey Gaia` can bring the Voice Assistant forward without first pressing a button. The wake listener stays local, review-first, and only active while Gaia is running.

If the voice path is unavailable on a machine, use:

- `Paste Transcript`
- `Use Mock Transcript`

---

## Safety Notes

- The app does not run voice commands automatically.
- Codex prompts are prepared for review, not executed on their own.
- The voice layer stays local-first.
- Hardware control is not part of this flow.
- If the transcript feels close but not quite right, edit it before saving.

---

## Troubleshooting

### I spoke, but the text looks wrong

Edit the transcript manually before saving. The assistant is meant to help, not to decide for you.

### The command router suggested the wrong thing

Use the suggested route as a shortcut, not a rule. Save the capture where it belongs.

### I just want to type

Use `Paste Transcript` and continue the same review flow.

### I want to reuse a good command

Tap it from history and adjust it instead of starting over.

---

## What Is Coming Next

The next steps for this guide are likely to include:

- voice replies or assistant-style confirmations
- stronger command routing from natural phrases
- quicker project-aware voice actions
- better summary prompts for the end of the day
- command reuse across tasks, planner, and inbox

As the voice layer grows, this guide will grow with it.
