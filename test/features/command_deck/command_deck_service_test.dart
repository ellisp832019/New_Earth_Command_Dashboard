import 'package:flutter_test/flutter_test.dart';

import 'package:new_earth_command_dashboard/features/command_deck/data/command_deck_service.dart';

void main() {
  test('command deck service loads the example registry into workflow groups',
      () async {
    final service = CommandDeckService();
    final workspace = await service.loadWorkspace();

    final groupNames =
        workspace.registry.groupedCommands.map((group) => group.name).toList();
    final commandIds =
        workspace.registry.commands.map((command) => command.id).toList();

    expect(groupNames, contains('Core Flow'));
    expect(groupNames, contains('Project Shortcuts'));
    expect(groupNames, contains('Research & Ops'));
    expect(groupNames, contains('Recording'));
    expect(groupNames, contains('Setup'));
    expect(groupNames, contains('Dashboard Pages'));
    expect(commandIds, contains('start_meeting'));
    expect(commandIds, contains('start_build_session'));
    expect(commandIds, contains('create_codex_handoff'));
    expect(commandIds, contains('open_projects'));
    expect(commandIds, contains('open_meetings'));
    expect(commandIds, contains('open_planner'));
    expect(commandIds, contains('open_journal'));
    expect(commandIds, contains('open_voice_assistant'));
    expect(commandIds, contains('obs_recording'));
    expect(workspace.validationIssues, isEmpty);
  });

  test('command deck registry validation catches duplicate ids', () {
    final service = CommandDeckService();
    final registry = CommandDeckRegistry(
      source: 'test',
      commands: const [
        CommandDeckCommand(
          id: 'duplicate',
          label: 'Duplicate One',
          type: CommandDeckCommandType.openRoute,
          target: '/dashboard',
          source: 'test',
          group: 'Core Flow',
        ),
        CommandDeckCommand(
          id: 'duplicate',
          label: 'Duplicate Two',
          type: CommandDeckCommandType.openRoute,
          target: '/launchpad',
          source: 'test',
          group: 'Core Flow',
        ),
      ],
    );

    final issues = service.validateRegistry(registry);

    expect(issues, contains('Duplicate command id: duplicate'));
  });
}
