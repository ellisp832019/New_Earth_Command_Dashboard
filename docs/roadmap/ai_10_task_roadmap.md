# AI Assist 10 Task Roadmap

This roadmap covers the next safe step toward adding AI assistance to Gaia without losing the current review-first, local-first feel.

The goal is not to replace the Voice Assistant. The goal is to add an optional AI assist layer that helps with summaries, suggestions, and phrasing while Hayley still stays in control.

## Do First

Before we start the AI layer, it is worth finishing these voice items:

1. Remembered Thread Polish
2. Briefing Clarity Pass
3. Quick Follow-Up Chips
4. Voice Reply Tuning
5. Shared Session State Polish
6. Voice Verification Pass

Those steps make sure the AI layer plugs into a stable voice experience instead of amplifying rough edges.

## 1. AI Adapter Contract
- Define a small interface for AI help.
- Keep it provider-based so the implementation can be swapped later.
- Keep the adapter separate from the UI.

## 2. Local Stub Provider
- Add a no-op or rule-based fallback provider.
- Keep the app working with no external AI connected.
- Make the fallback safe and predictable.

## 3. Voice Briefing Assist
- Use AI to improve the voice briefing summary and next-step wording.
- Keep the current briefing card review-first.
- Let Hayley accept or ignore the suggestion.

## 4. Transcript Cleanup Assist
- Use AI to suggest a cleaner title or a shorter transcript summary.
- Keep the raw transcript visible.
- Never overwrite the original text without review.

## 5. Wizard Assist
- Use AI to help answer one wizard question at a time.
- Keep the manual wizard path available.
- Let Hayley fall back to manual entry whenever she wants.

## 6. History and Memory Assist
- Use AI to summarize recent captures or a remembered thread.
- Keep the command history searchable and reusable.
- Keep thread context local-first.

## 7. Follow-Up Suggestion Assist
- Use AI to propose the next calm action after wake, capture, or review.
- Keep the dashboard dock and quick follow-up chips in control.
- Make sure the suggestions stay short and relevant.

## 8. Opt-In Settings
- Add a clear setting for AI assist on or off.
- Add a provider choice later if needed.
- Keep AI optional and easy to disable.

## 9. Test and Safety Pass
- Add tests for the adapter contract.
- Add tests for the no-op fallback.
- Check that review-first behavior still holds.

## 10. First Real AI Provider
- Connect the adapter to the first real AI backend.
- Keep the prompt small and structured.
- Preserve local-first behavior where possible and never remove manual review.

## Recommended Order
If we start building this next, the best order is:

1. AI Adapter Contract
2. Local Stub Provider
3. Voice Briefing Assist
4. Transcript Cleanup Assist
5. Wizard Assist

That order keeps the first release safe, useful, and easy to extend.
