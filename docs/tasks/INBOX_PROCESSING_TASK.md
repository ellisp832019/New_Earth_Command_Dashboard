# Codex Task - Build Inbox Processing Foundation

## Task Title

Build the first useful Inbox triage flow for the New Earth Dashboard.

---

## Context

The app already captures ideas into Inbox and via Voice Capture. The next step is to help the user turn those captures into the right place without losing momentum.

Inbox should become the calm staging area for:

- Tasks
- Journal entries
- Content ideas
- Learning items
- Business opportunities

Do not add cloud sync, login, or automation. Keep the flow local-first and review-first.

---

## Current Objective

Add Inbox actions that let the user:

1. View unprocessed Inbox items.
2. Park an item for later.
3. Convert an item into a Task.
4. Convert an item into a Journal Entry.
5. Convert an item into a Content Idea.
6. Convert an item into a Learning Item.
7. Convert an item into a Business Opportunity.

---

## Required Repo Areas

Update the existing Inbox feature:

```text
lib/features/inbox/
├── application/
├── data/
└── presentation/
```

Use the existing target modules for the conversions:

```text
lib/features/tasks/
lib/features/journal/
lib/features/content/
lib/features/learning/
lib/features/business/
```

---

## Inbox Screen Requirements

The Inbox screen should:

- show unprocessed items only
- show a calm empty state
- allow each item to be parked
- allow each item to be converted
- keep the conversion flow explicit
- preserve the original text in the converted record

---

## Inbox Processing Behaviour

When an item is converted:

- status becomes `Processed`
- `processed_at` is set
- `converted_to_type` is set
- `converted_to_id` is set

When an item is parked:

- status becomes `Parked`
- the item stays in Inbox for later review

---

## Safety Requirements

- Do not auto-delete Inbox items.
- Do not hide captured text.
- Do not create background automation.
- Do not add cloud dependencies.
- Keep the flow simple enough to use every day.

---

## Acceptance Criteria

This task is complete when:

- Inbox shows only unprocessed items.
- Each Inbox item can be parked.
- Each Inbox item can be converted into at least one target module.
- Converted items disappear from the Inbox list.
- The target record is created locally.
- `flutter analyze` passes.
- `flutter test` passes.
- Windows build still works if possible.
