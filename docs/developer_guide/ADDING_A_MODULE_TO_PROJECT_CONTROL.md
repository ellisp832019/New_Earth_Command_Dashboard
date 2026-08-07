# Adding A Module To Project Control

1. Add or update the module record in `project_control/module_registry.yaml`.
2. Add dependencies only to real, already-registered module ids.
3. Add tests and documentation paths that actually exist.
4. Update the risk register if the module introduces a new concern.
5. Run the CLI validation command.
