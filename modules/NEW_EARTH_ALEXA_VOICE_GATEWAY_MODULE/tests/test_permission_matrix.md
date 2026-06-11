# Manual Test Matrix

## Allowed reads

- dashboard.summary.today should return allowed.
- dashboard.project.status.read should return allowed.
- microgrow.status.read should return allowed.
- dashboard.tasks.next should return allowed.

## Low-risk writes

- dashboard.note.add should return allowed and include note text.
- dashboard.task.add should return allowed and include task text.
- dashboard.focus.start should return allowed.

## Blocked commands

- filesystem.delete should return blocked.
- finance.private.read should return blocked.
- ai.agent.run should return blocked.
- system.shell.exec should return blocked.
- microgrow.relay.permanent_control should return blocked.
- obsidian.private_notes.read should return blocked.
- database.raw.read should return blocked.
- hardware.dangerous.control should return blocked.

## Unknown commands

- any unregistered command should return denied.
