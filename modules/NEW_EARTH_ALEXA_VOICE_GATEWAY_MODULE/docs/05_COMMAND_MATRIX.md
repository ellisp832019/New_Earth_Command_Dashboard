# Command Matrix

| Voice command | Intent | Internal command | Level | Default |
|---|---|---:|---:|---|
| Ask for my summary | GetTodaySummaryIntent | dashboard.summary.today | 1 | Allowed |
| Ask for project status | GetProjectStatusIntent | dashboard.project.status.read | 1 | Allowed |
| Ask for MicroGrow status | GetMicroGrowStatusIntent | microgrow.status.read | 1 | Allowed |
| Add a note | AddDashboardNoteIntent | dashboard.note.add | 2 | Allowed |
| Add a task | AddTaskIntent | dashboard.task.add | 2 | Allowed |
| Start focus mode | StartFocusModeIntent | dashboard.focus.start | 2 | Allowed |
| List next tasks | ListNextTasksIntent | dashboard.tasks.next | 1 | Allowed |
| Trigger relay | ControlRelayIntent | microgrow.relay.control | 3 | Blocked |
| Read finance details | FinanceReadIntent | finance.private.read | 4 | Blocked |
| Run AI agent | RunAgentIntent | ai.agent.run | 4 | Blocked |
| Delete a file | DeleteFileIntent | filesystem.delete | 4 | Blocked |
| Run terminal command | ShellCommandIntent | system.shell.exec | 4 | Blocked |
| Open private Obsidian notes | OpenPrivateNoteIntent | obsidian.private_notes.read | 4 | Blocked |
| Access raw local databases | DatabaseReadIntent | database.raw.read | 4 | Blocked |
| Control dangerous hardware | DangerousHardwareIntent | hardware.dangerous.control | 4 | Blocked |
