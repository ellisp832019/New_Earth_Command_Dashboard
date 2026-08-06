# Voice Assistant 10 Task Roadmap

This roadmap covers the next useful voice work after the current Voice Assistant slice is already working.

The aim is to keep Gaia review-first, local-first, and calm while making the voice path more reliable and more useful in daily work.

## 1. Desktop Voice Hardening
- Strengthen the Windows microphone path.
- Keep focus handling, fullscreen behavior, and startup gating smooth.
- Make sure one-shot capture stays stable on real machines.

## 2. Voice Capture History
- Add a clearer searchable history of recent voice captures.
- Let Hayley reuse a good command instead of re-speaking it.
- Keep the history review-first and local-only.

## 3. Voice Shortcut Templates
- Expand the starter templates for common voice jobs.
- Make templates easier to reuse for tasks, journal entries, projects, content, and business leads.
- Keep the language natural and low-effort.

## 4. Remembered Thread Polish
- Improve the continued-thread experience.
- Make the current thread card easier to pick back up from.
- Keep the assistant aware of the active conversation context.

## 5. Briefing Clarity Pass
- Tighten the voice briefing card so it explains the next step more clearly.
- Keep the briefing useful for quick review before save.
- Make the command path feel more conversational.

## 6. Quick Follow-Up Chips
- Improve the dashboard conversation dock follow-ups.
- Keep the chips focused on the next likely move.
- Reduce friction when Gaia wakes on the dashboard.

## 7. Project Capture Polish
- Make voice-created projects feel more intentional and less generic.
- Improve the project capture review fields where needed.
- Keep project saves local-first and easy to correct.

## 8. Voice Reply Tuning
- Refine the spoken reply and confirmation tone.
- Keep assistant speech short, calm, and useful.
- Make sure the reply matches the capture context.

## 9. Shared Session State Polish
- Keep the wake layer, dashboard dock, and full assistant aligned through one shared session state.
- Reduce route handoff edge cases.
- Make sure only one voice path owns listening or speaking at a time.

## 10. Voice Verification Pass
- Re-run the important tests.
- Check Windows startup, wake, capture, and review behavior together.
- Update the voice guide and user docs so the current experience stays accurate.

## Recommended Order
If we start building from this roadmap, the best order is:

1. Desktop Voice Hardening
2. Voice Capture History
3. Voice Shortcut Templates
4. Remembered Thread Polish
5. Briefing Clarity Pass

That sequence gives the most benefit first: stability, reuse, and then polish.
