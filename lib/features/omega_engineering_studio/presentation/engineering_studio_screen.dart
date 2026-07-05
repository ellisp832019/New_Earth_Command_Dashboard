import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_colours.dart';
import '../../../core/routing/route_names.dart';
import '../application/engineering_services.dart';
import '../application/engineering_integration_adapters.dart';
import '../data/engineering_repository.dart';
import '../domain/engineering_models.dart';
import 'widgets/engineering_widgets.dart';

class EngineeringStudioScreen extends StatefulWidget {
  const EngineeringStudioScreen({
    super.key,
    this.repository,
    this.initialSection = EngineeringSection.dashboard,
  });

  final EngineeringRepository? repository;
  final EngineeringSection initialSection;

  @override
  State<EngineeringStudioScreen> createState() =>
      _EngineeringStudioScreenState();
}

class _EngineeringStudioScreenState extends State<EngineeringStudioScreen> {
  late final EngineeringRepository _repository =
      widget.repository ?? LocalEngineeringRepository();
  late final EngineeringKnowledgeEngineAdapter _knowledgeEngineAdapter =
      const LocalEngineeringKnowledgeEngineAdapter();
  late final EngineeringGaiaAssistantAdapter _gaiaAssistantAdapter =
      const LocalEngineeringGaiaAssistantAdapter();
  late final EngineeringAccessPolicy _accessPolicy =
      const EngineeringAccessPolicy.localOnly();
  late final TextEditingController _searchController;

  EngineeringSnapshot? _snapshot;
  EngineeringSection _section = EngineeringSection.dashboard;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _searchController = TextEditingController();
    unawaited(_loadSnapshot());
  }

  @override
  void didUpdateWidget(covariant EngineeringStudioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection &&
        widget.initialSection != _section) {
      setState(() {
        _section = widget.initialSection;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSnapshot() async {
    try {
      final snapshot = await _repository.loadSnapshot();
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  EngineeringSnapshot get _snapshotOrThrow {
    final snapshot = _snapshot;
    if (snapshot == null) {
      throw StateError('Engineering snapshot not loaded.');
    }
    return snapshot;
  }

  void _setSection(EngineeringSection section) {
    if (_section == section) {
      return;
    }
    setState(() {
      _section = section;
    });
    context.go(_routeFor(section));
  }

  String _routeFor(EngineeringSection section) {
    return RouteNames.omegaEngineeringStudioSection(section.routeSegment);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  Future<void> _openCommandPalette() async {
    final snapshot = _snapshotOrThrow;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _EngineeringCommandPaletteDialog(
          snapshot: snapshot,
          currentSection: _section,
          actions: _commandPaletteActions(dialogContext, snapshot),
        );
      },
    );
  }

  List<_EngineeringPaletteAction> _commandPaletteActions(
    BuildContext dialogContext,
    EngineeringSnapshot snapshot,
  ) {
    return [
      for (final section in EngineeringSection.values)
        _EngineeringPaletteAction(
          id: 'open_${section.routeSegment.isEmpty ? 'dashboard' : section.routeSegment}',
          label: 'Open ${section.label}',
          subtitle: section == EngineeringSection.dashboard
              ? 'Return to the calm overview.'
              : 'Jump to ${section.label.toLowerCase()}.',
          icon: Icons.arrow_forward_outlined,
          onSelected: () {
            Navigator.of(dialogContext).pop();
            _setSection(section);
          },
        ),
      _EngineeringPaletteAction(
        id: 'new_project',
        label: 'Add project',
        subtitle: 'Create a local engineering project draft.',
        icon: Icons.create_new_folder_outlined,
        onSelected: () async {
          Navigator.of(dialogContext).pop();
          await _editProject();
        },
      ),
      _EngineeringPaletteAction(
        id: 'new_pcb',
        label: 'Add PCB revision',
        subtitle: 'Create a board record for fabrication.',
        icon: Icons.view_in_ar_outlined,
        onSelected: () async {
          Navigator.of(dialogContext).pop();
          await _editPcbRevision();
        },
      ),
      _EngineeringPaletteAction(
        id: 'new_firmware',
        label: 'Add firmware build',
        subtitle: 'Track a release candidate locally.',
        icon: Icons.memory_outlined,
        onSelected: () async {
          Navigator.of(dialogContext).pop();
          await _editFirmwareBuild();
        },
      ),
      _EngineeringPaletteAction(
        id: 'new_device',
        label: 'Add device node',
        subtitle: 'Record a new ESP32 or field node.',
        icon: Icons.devices_other_outlined,
        onSelected: () async {
          Navigator.of(dialogContext).pop();
          await _editDeviceNode();
        },
      ),
      _EngineeringPaletteAction(
        id: 'new_document',
        label: 'Add document',
        subtitle: 'Capture a note, brief, or release pack.',
        icon: Icons.description_outlined,
        onSelected: () async {
          Navigator.of(dialogContext).pop();
          await _editDocument();
        },
      ),
      _EngineeringPaletteAction(
        id: 'export_snapshot',
        label: 'Export snapshot',
        subtitle: 'Write the local module state to JSON.',
        icon: Icons.download_outlined,
        onSelected: () async {
          Navigator.of(dialogContext).pop();
          await _exportSnapshot();
        },
      ),
      _EngineeringPaletteAction(
        id: 'import_snapshot',
        label: 'Import snapshot',
        subtitle: 'Restore local engineering state from JSON.',
        icon: Icons.upload_file_outlined,
        onSelected: () async {
          Navigator.of(dialogContext).pop();
          await _importSnapshot();
        },
      ),
      _EngineeringPaletteAction(
        id: 'open_knowledge',
        label: 'Open Knowledge Engine',
        subtitle: 'Jump to the Omega Knowledge Engine hook.',
        icon: Icons.travel_explore_outlined,
        onSelected: () {
          Navigator.of(dialogContext).pop();
          unawaited(_knowledgeEngineAdapter.open(context));
        },
      ),
      _EngineeringPaletteAction(
        id: 'open_gaia',
        label: 'Open GAIA',
        subtitle: 'Jump to the GAIA assistant hook.',
        icon: Icons.auto_awesome_outlined,
        onSelected: () {
          Navigator.of(dialogContext).pop();
          unawaited(_gaiaAssistantAdapter.open(context));
        },
      ),
      if (snapshot.attachments.isNotEmpty)
        _EngineeringPaletteAction(
          id: 'attachment_count',
          label: 'Review attachments',
          subtitle: 'See schematics, board files, firmware, and evidence.',
          icon: Icons.attach_file_outlined,
          onSelected: () {
            Navigator.of(dialogContext).pop();
            _setSection(EngineeringSection.documentation);
          },
        ),
    ];
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refreshSnapshot() async {
    try {
      final snapshot = await _repository.loadSnapshot();
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
      });
    }
  }

  Future<void> _exportSnapshot() async {
    final directory = Directory(
      '${_snapshotOrThrow.settings.moduleRootPath}\\data\\backups',
    );
    final file = File(
      '${directory.path}\\engineering_snapshot_${DateTime.now().toUtc().toIso8601String().replaceAll(':', '-').replaceAll('.', '-')}.json',
    );
    await _repository.exportSnapshot(file);
    _showSnackBar('Snapshot exported to ${file.path}.');
  }

  Future<void> _importSnapshot() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      allowMultiple: false,
    );
    final path = picked?.files.single.path;
    if (path == null) {
      return;
    }
    await _repository.importSnapshot(File(path));
    await _refreshSnapshot();
    _showSnackBar('Snapshot imported from local file.');
  }

  List<String> _tagsFromText(String text) {
    return text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  DateTime? _tryParseDate(String text) {
    final parsed = DateTime.tryParse(text.trim());
    return parsed?.toUtc();
  }

  String _dateText(DateTime? value) {
    return value?.toUtc().toIso8601String().split('T').first ?? '';
  }

  Future<void> _editProject([EngineeringProject? project]) async {
    final titleController = TextEditingController(text: project?.title ?? '');
    final summaryController = TextEditingController(
      text: project?.summary ?? '',
    );
    final statusController = TextEditingController(
      text: project?.status ?? 'Active',
    );
    final priorityController = TextEditingController(
      text: project?.priority ?? 'Medium',
    );
    final progressController = TextEditingController(
      text: '${project?.progressPercent ?? 0}',
    );
    final milestoneController = TextEditingController(
      text: project?.milestone ?? '',
    );
    final nextActionController = TextEditingController(
      text: project?.nextAction ?? '',
    );
    final systemController = TextEditingController(text: project?.system ?? '');
    final targetDateController = TextEditingController(
      text: _dateText(project?.targetDate),
    );
    final tagsController = TextEditingController(
      text: project?.tags.join(', ') ?? '',
    );

    try {
      final draft = await showDialog<EngineeringProject>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(project == null ? 'Add project' : 'Edit project'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: summaryController,
                      decoration: const InputDecoration(labelText: 'Summary'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    TextField(
                      controller: priorityController,
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    TextField(
                      controller: progressController,
                      decoration: const InputDecoration(
                        labelText: 'Progress percent',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: milestoneController,
                      decoration: const InputDecoration(labelText: 'Milestone'),
                    ),
                    TextField(
                      controller: nextActionController,
                      decoration: const InputDecoration(
                        labelText: 'Next action',
                      ),
                    ),
                    TextField(
                      controller: systemController,
                      decoration: const InputDecoration(labelText: 'System'),
                    ),
                    TextField(
                      controller: targetDateController,
                      decoration: const InputDecoration(
                        labelText: 'Target date (YYYY-MM-DD)',
                      ),
                    ),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags, comma separated',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    return;
                  }
                  final draft = EngineeringProject(
                    id:
                        project?.id ??
                        'project_${DateTime.now().microsecondsSinceEpoch}',
                    title: title,
                    summary: summaryController.text.trim(),
                    status: statusController.text.trim(),
                    priority: priorityController.text.trim(),
                    progressPercent:
                        int.tryParse(progressController.text.trim()) ?? 0,
                    milestone: milestoneController.text.trim(),
                    nextAction: nextActionController.text.trim(),
                    system: systemController.text.trim(),
                    updatedAt: DateTime.now().toUtc(),
                    openTaskCount: project?.openTaskCount ?? 0,
                    blockedTaskCount: project?.blockedTaskCount ?? 0,
                    tags: _tagsFromText(tagsController.text),
                    targetDate: _tryParseDate(targetDateController.text),
                  );
                  Navigator.of(dialogContext).pop(draft);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      if (draft == null) {
        return;
      }
      if (project == null) {
        await _repository.createProject(
          title: draft.title,
          summary: draft.summary,
          status: draft.status,
          priority: draft.priority,
          progressPercent: draft.progressPercent,
          milestone: draft.milestone,
          nextAction: draft.nextAction,
          system: draft.system,
          targetDate: draft.targetDate,
          tags: draft.tags,
        );
      } else {
        await _repository.updateProject(draft);
      }
      await _refreshSnapshot();
      _showSnackBar(
        project == null ? 'Project added locally.' : 'Project updated locally.',
      );
    } finally {
      titleController.dispose();
      summaryController.dispose();
      statusController.dispose();
      priorityController.dispose();
      progressController.dispose();
      milestoneController.dispose();
      nextActionController.dispose();
      systemController.dispose();
      targetDateController.dispose();
      tagsController.dispose();
    }
  }

  Future<void> _editPcbRevision([PCBRevision? pcb]) async {
    final boardController = TextEditingController(text: pcb?.boardName ?? '');
    final revisionController = TextEditingController(text: pcb?.revision ?? '');
    final projectController = TextEditingController(text: pcb?.projectId ?? '');
    final statusController = TextEditingController(
      text: pcb?.status ?? 'Draft',
    );
    final layersController = TextEditingController(text: '${pcb?.layers ?? 2}');
    final progressController = TextEditingController(
      text: '${pcb?.progressPercent ?? 0}',
    );
    final partnerController = TextEditingController(
      text: pcb?.manufacturingPartner ?? '',
    );
    final nextActionController = TextEditingController(
      text: pcb?.nextAction ?? '',
    );
    final notesController = TextEditingController(text: pcb?.notes ?? '');
    final tagsController = TextEditingController(
      text: pcb?.tags.join(', ') ?? '',
    );
    var fabReady = pcb?.fabReady ?? false;

    try {
      final draft = await showDialog<PCBRevision>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  pcb == null ? 'Add PCB revision' : 'Edit PCB revision',
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 560,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: boardController,
                          decoration: const InputDecoration(
                            labelText: 'Board name',
                          ),
                        ),
                        TextField(
                          controller: revisionController,
                          decoration: const InputDecoration(
                            labelText: 'Revision',
                          ),
                        ),
                        TextField(
                          controller: projectController,
                          decoration: const InputDecoration(
                            labelText: 'Project ID',
                          ),
                        ),
                        TextField(
                          controller: statusController,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                        ),
                        TextField(
                          controller: layersController,
                          decoration: const InputDecoration(
                            labelText: 'Layers',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: progressController,
                          decoration: const InputDecoration(
                            labelText: 'Progress percent',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: partnerController,
                          decoration: const InputDecoration(
                            labelText: 'Manufacturing partner',
                          ),
                        ),
                        TextField(
                          controller: nextActionController,
                          decoration: const InputDecoration(
                            labelText: 'Next action',
                          ),
                        ),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(labelText: 'Notes'),
                          maxLines: 2,
                        ),
                        TextField(
                          controller: tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags, comma separated',
                          ),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: fabReady,
                          onChanged: (value) =>
                              setDialogState(() => fabReady = value ?? false),
                          title: const Text('Fab ready'),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (boardController.text.trim().isEmpty ||
                          revisionController.text.trim().isEmpty) {
                        return;
                      }
                      Navigator.of(dialogContext).pop(
                        PCBRevision(
                          id:
                              pcb?.id ??
                              'pcb_${DateTime.now().microsecondsSinceEpoch}',
                          projectId: projectController.text.trim(),
                          boardName: boardController.text.trim(),
                          revision: revisionController.text.trim(),
                          status: statusController.text.trim(),
                          layers:
                              int.tryParse(layersController.text.trim()) ?? 2,
                          progressPercent:
                              int.tryParse(progressController.text.trim()) ?? 0,
                          fabReady: fabReady,
                          manufacturingPartner: partnerController.text.trim(),
                          nextAction: nextActionController.text.trim(),
                          tags: _tagsFromText(tagsController.text),
                          notes: notesController.text.trim(),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (draft == null) {
        return;
      }
      await _repository.upsertPcbRevision(draft);
      await _refreshSnapshot();
      _showSnackBar(
        pcb == null ? 'PCB added locally.' : 'PCB updated locally.',
      );
    } finally {
      boardController.dispose();
      revisionController.dispose();
      projectController.dispose();
      statusController.dispose();
      layersController.dispose();
      progressController.dispose();
      partnerController.dispose();
      nextActionController.dispose();
      notesController.dispose();
      tagsController.dispose();
    }
  }

  Future<void> _editFirmwareBuild([FirmwareBuild? build]) async {
    final projectController = TextEditingController(
      text: build?.projectId ?? '',
    );
    final targetController = TextEditingController(
      text: build?.targetDevice ?? '',
    );
    final versionController = TextEditingController(text: build?.version ?? '');
    final statusController = TextEditingController(
      text: build?.status ?? 'Draft',
    );
    final progressController = TextEditingController(
      text: '${build?.progressPercent ?? 0}',
    );
    final typeController = TextEditingController(text: build?.buildType ?? '');
    final nextActionController = TextEditingController(
      text: build?.nextAction ?? '',
    );
    final artifactController = TextEditingController(
      text: build?.artifactPath ?? '',
    );
    final builtAtController = TextEditingController(
      text: _dateText(build?.lastBuiltAt),
    );
    final tagsController = TextEditingController(
      text: build?.tags.join(', ') ?? '',
    );

    try {
      final draft = await showDialog<FirmwareBuild>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              build == null ? 'Add firmware build' : 'Edit firmware build',
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: projectController,
                      decoration: const InputDecoration(
                        labelText: 'Project ID',
                      ),
                    ),
                    TextField(
                      controller: targetController,
                      decoration: const InputDecoration(
                        labelText: 'Target device',
                      ),
                    ),
                    TextField(
                      controller: versionController,
                      decoration: const InputDecoration(labelText: 'Version'),
                    ),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    TextField(
                      controller: progressController,
                      decoration: const InputDecoration(
                        labelText: 'Progress percent',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Build type',
                      ),
                    ),
                    TextField(
                      controller: nextActionController,
                      decoration: const InputDecoration(
                        labelText: 'Next action',
                      ),
                    ),
                    TextField(
                      controller: artifactController,
                      decoration: const InputDecoration(
                        labelText: 'Artifact path',
                      ),
                    ),
                    TextField(
                      controller: builtAtController,
                      decoration: const InputDecoration(
                        labelText: 'Last built date (YYYY-MM-DD)',
                      ),
                    ),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags, comma separated',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (targetController.text.trim().isEmpty ||
                      versionController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(
                    FirmwareBuild(
                      id:
                          build?.id ??
                          'firmware_${DateTime.now().microsecondsSinceEpoch}',
                      projectId: projectController.text.trim(),
                      targetDevice: targetController.text.trim(),
                      version: versionController.text.trim(),
                      status: statusController.text.trim(),
                      progressPercent:
                          int.tryParse(progressController.text.trim()) ?? 0,
                      buildType: typeController.text.trim(),
                      nextAction: nextActionController.text.trim(),
                      artifactPath: artifactController.text.trim(),
                      lastBuiltAt:
                          _tryParseDate(builtAtController.text) ??
                          DateTime.now().toUtc(),
                      tags: _tagsFromText(tagsController.text),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      if (draft == null) {
        return;
      }
      await _repository.upsertFirmwareBuild(draft);
      await _refreshSnapshot();
      _showSnackBar(
        build == null
            ? 'Firmware build added locally.'
            : 'Firmware build updated locally.',
      );
    } finally {
      projectController.dispose();
      targetController.dispose();
      versionController.dispose();
      statusController.dispose();
      progressController.dispose();
      typeController.dispose();
      nextActionController.dispose();
      artifactController.dispose();
      builtAtController.dispose();
      tagsController.dispose();
    }
  }

  Future<void> _editDeviceNode([DeviceNode? device]) async {
    final projectController = TextEditingController(
      text: device?.projectId ?? '',
    );
    final nameController = TextEditingController(text: device?.name ?? '');
    final modelController = TextEditingController(text: device?.model ?? '');
    final statusController = TextEditingController(
      text: device?.status ?? 'Offline',
    );
    final healthController = TextEditingController(
      text: device?.health ?? 'Unknown',
    );
    final firmwareController = TextEditingController(
      text: device?.firmwareVersion ?? '',
    );
    final locationController = TextEditingController(
      text: device?.location ?? '',
    );
    final nextActionController = TextEditingController(
      text: device?.nextAction ?? '',
    );
    final notesController = TextEditingController(text: device?.notes ?? '');
    final tagsController = TextEditingController(
      text: device?.tags.join(', ') ?? '',
    );

    try {
      final draft = await showDialog<DeviceNode>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              device == null ? 'Add device node' : 'Edit device node',
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: projectController,
                      decoration: const InputDecoration(
                        labelText: 'Project ID',
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    TextField(
                      controller: healthController,
                      decoration: const InputDecoration(labelText: 'Health'),
                    ),
                    TextField(
                      controller: firmwareController,
                      decoration: const InputDecoration(
                        labelText: 'Firmware version',
                      ),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    TextField(
                      controller: nextActionController,
                      decoration: const InputDecoration(
                        labelText: 'Next action',
                      ),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags, comma separated',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(
                    DeviceNode(
                      id:
                          device?.id ??
                          'device_${DateTime.now().microsecondsSinceEpoch}',
                      projectId: projectController.text.trim(),
                      name: nameController.text.trim(),
                      model: modelController.text.trim(),
                      status: statusController.text.trim(),
                      health: healthController.text.trim(),
                      firmwareVersion: firmwareController.text.trim(),
                      lastSeenAt: device?.lastSeenAt ?? DateTime.now().toUtc(),
                      location: locationController.text.trim(),
                      nextAction: nextActionController.text.trim(),
                      tags: _tagsFromText(tagsController.text),
                      notes: notesController.text.trim(),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      if (draft == null) {
        return;
      }
      await _repository.upsertDeviceNode(draft);
      await _refreshSnapshot();
      _showSnackBar(
        device == null ? 'Device added locally.' : 'Device updated locally.',
      );
    } finally {
      projectController.dispose();
      nameController.dispose();
      modelController.dispose();
      statusController.dispose();
      healthController.dispose();
      firmwareController.dispose();
      locationController.dispose();
      nextActionController.dispose();
      notesController.dispose();
      tagsController.dispose();
    }
  }

  Future<void> _editDocument([EngineeringDocument? document]) async {
    final projectController = TextEditingController(
      text: document?.projectId ?? '',
    );
    final titleController = TextEditingController(text: document?.title ?? '');
    final typeController = TextEditingController(
      text: document?.documentType ?? '',
    );
    final statusController = TextEditingController(
      text: document?.status ?? 'Draft',
    );
    final summaryController = TextEditingController(
      text: document?.summary ?? '',
    );
    final fileController = TextEditingController(
      text: document?.filePath ?? '',
    );
    final tagsController = TextEditingController(
      text: document?.tags.join(', ') ?? '',
    );
    final updatedAtController = TextEditingController(
      text: _dateText(document?.updatedAt),
    );

    try {
      final draft = await showDialog<EngineeringDocument>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(document == null ? 'Add document' : 'Edit document'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: projectController,
                      decoration: const InputDecoration(
                        labelText: 'Project ID',
                      ),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Document type',
                      ),
                    ),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    TextField(
                      controller: summaryController,
                      decoration: const InputDecoration(labelText: 'Summary'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: fileController,
                      decoration: const InputDecoration(labelText: 'File path'),
                    ),
                    TextField(
                      controller: updatedAtController,
                      decoration: const InputDecoration(
                        labelText: 'Updated at (YYYY-MM-DD)',
                      ),
                    ),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags, comma separated',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(
                    EngineeringDocument(
                      id:
                          document?.id ??
                          'document_${DateTime.now().microsecondsSinceEpoch}',
                      projectId: projectController.text.trim(),
                      title: titleController.text.trim(),
                      documentType: typeController.text.trim(),
                      status: statusController.text.trim(),
                      updatedAt:
                          _tryParseDate(updatedAtController.text) ??
                          DateTime.now().toUtc(),
                      summary: summaryController.text.trim(),
                      filePath: fileController.text.trim(),
                      tags: _tagsFromText(tagsController.text),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      if (draft == null) {
        return;
      }
      await _repository.upsertDocument(draft);
      await _refreshSnapshot();
      _showSnackBar(
        document == null
            ? 'Document added locally.'
            : 'Document updated locally.',
      );
    } finally {
      projectController.dispose();
      titleController.dispose();
      typeController.dispose();
      statusController.dispose();
      summaryController.dispose();
      fileController.dispose();
      tagsController.dispose();
      updatedAtController.dispose();
    }
  }

  Future<void> _editAttachment([EngineeringAttachment? attachment]) async {
    final ownerTypeController = TextEditingController(
      text: attachment?.ownerType ?? 'Project',
    );
    final ownerIdController = TextEditingController(
      text: attachment?.ownerId ?? '',
    );
    final titleController = TextEditingController(
      text: attachment?.title ?? '',
    );
    final kindController = TextEditingController(
      text: attachment?.kind ?? 'Attachment',
    );
    final filePathController = TextEditingController(
      text: attachment?.filePath ?? '',
    );
    final statusController = TextEditingController(
      text: attachment?.status ?? 'Linked',
    );
    final notesController = TextEditingController(
      text: attachment?.notes ?? '',
    );
    final tagsController = TextEditingController(
      text: attachment?.tags.join(', ') ?? '',
    );
    final updatedAtController = TextEditingController(
      text: _dateText(attachment?.updatedAt),
    );

    try {
      final draft = await showDialog<EngineeringAttachment>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              attachment == null ? 'Add attachment' : 'Edit attachment',
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: ownerTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Owner type',
                      ),
                    ),
                    TextField(
                      controller: ownerIdController,
                      decoration: const InputDecoration(
                        labelText: 'Owner ID',
                      ),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: kindController,
                      decoration: const InputDecoration(labelText: 'Kind'),
                    ),
                    TextField(
                      controller: filePathController,
                      decoration: InputDecoration(
                        labelText: 'File path',
                        suffixIcon: IconButton(
                          tooltip: 'Pick local file',
                          icon: const Icon(Icons.folder_open_outlined),
                          onPressed: () async {
                            final picked = await FilePicker.pickFiles(
                              allowMultiple: false,
                            );
                            final path = picked?.files.single.path;
                            if (path != null) {
                              filePathController.text = path;
                            }
                          },
                        ),
                      ),
                    ),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    TextField(
                      controller: updatedAtController,
                      decoration: const InputDecoration(
                        labelText: 'Updated at (YYYY-MM-DD)',
                      ),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags, comma separated',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      filePathController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(
                    EngineeringAttachment(
                      id:
                          attachment?.id ??
                          'attachment_${DateTime.now().microsecondsSinceEpoch}',
                      ownerType: ownerTypeController.text.trim(),
                      ownerId: ownerIdController.text.trim(),
                      title: titleController.text.trim(),
                      kind: kindController.text.trim(),
                      filePath: filePathController.text.trim(),
                      status: statusController.text.trim(),
                      updatedAt:
                          _tryParseDate(updatedAtController.text) ??
                          DateTime.now().toUtc(),
                      notes: notesController.text.trim(),
                      tags: _tagsFromText(tagsController.text),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      if (draft == null) {
        return;
      }
      await _repository.upsertAttachment(draft);
      await _refreshSnapshot();
      _showSnackBar(
        attachment == null
            ? 'Attachment added locally.'
            : 'Attachment updated locally.',
      );
    } finally {
      ownerTypeController.dispose();
      ownerIdController.dispose();
      titleController.dispose();
      kindController.dispose();
      filePathController.dispose();
      statusController.dispose();
      notesController.dispose();
      tagsController.dispose();
      updatedAtController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: EngineeringLoadingState());
    }

    if (_error != null && _snapshot == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Omega Engineering Studio'),
          leading: BackButton(onPressed: () => context.go(RouteNames.more)),
        ),
        body: EngineeringErrorState(
          message: _error!,
          onRetry: () {
            setState(() {
              _loading = true;
              _error = null;
            });
            unawaited(_loadSnapshot());
          },
        ),
      );
    }

    final snapshot = _snapshotOrThrow;
    final projectService = ProjectService(snapshot);
    final circuitService = CircuitLibraryService(snapshot);
    final pcbService = PCBService(snapshot);
    final firmwareService = FirmwareBuildService(snapshot);
    final deviceService = DeviceFleetService(snapshot);
    final componentService = ComponentInventoryService(snapshot);
    final experimentService = ExperimentService(snapshot);
    final validationService = ValidationService(snapshot);
    final manufacturingService = ManufacturingService(snapshot);
    final searchService = EngineeringSearchService(snapshot);
    final searchHits = searchService.search(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text('Omega Engineering Studio · ${_section.label}'),
        leading: BackButton(onPressed: () => context.go(RouteNames.more)),
        actions: [
          IconButton(
            onPressed: _openCommandPalette,
            tooltip: 'Command palette',
            icon: const Icon(Icons.search_rounded),
          ),
          TextButton.icon(
            onPressed: () => _knowledgeEngineAdapter.open(context),
            icon: const Icon(Icons.travel_explore_outlined),
            label: const Text('Knowledge Engine'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _gaiaAssistantAdapter.open(context),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('GAIA'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyK &&
              HardwareKeyboard.instance.isControlPressed) {
            unawaited(_openCommandPalette());
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: CustomScrollView(
          key: const Key('engineeringStudioScrollView'),
          cacheExtent: 3000,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _HeroPanel(
                  snapshot: snapshot,
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  statusFilter: _statusFilter,
                  onSearchChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onStatusFilterChanged: (value) {
                    setState(() {
                      _statusFilter = value;
                    });
                  },
                  onClearSearch: _clearSearch,
                  onOpenKnowledgeEngine: () =>
                      _knowledgeEngineAdapter.open(context),
                  onOpenGaiaAssistant: () =>
                      _gaiaAssistantAdapter.open(context),
                ),
              ),
            ),
            if (_searchQuery.trim().isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: EngineeringSectionShell(
                    title: 'Search results',
                    subtitle:
                        'A quiet local scan across projects, circuits, boards, devices, and docs.',
                    child: searchHits.isEmpty
                        ? EngineeringEmptyState(
                            title: 'No matches yet',
                            subtitle:
                                'Try a project title, board name, device name, or document keyword.',
                            actionLabel: 'Clear search',
                            onAction: _clearSearch,
                          )
                        : _SearchHitsView(
                            hits: searchHits,
                            onOpenSection: _setSection,
                          ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              sliver: SliverToBoxAdapter(
                child: _EngineeringWorkspaceFrame(
                  snapshot: snapshot,
                  currentSection: _section,
                  searchQuery: _searchQuery,
                  statusFilter: _statusFilter,
                  onSectionSelected: _setSection,
                  onClearSearch: _clearSearch,
                  onOpenKnowledgeEngine: () =>
                      _knowledgeEngineAdapter.open(context),
                  onOpenGaiaAssistant: () =>
                      _gaiaAssistantAdapter.open(context),
                  onOpenPalette: _openCommandPalette,
                  overview: _buildWorkspaceOverview(snapshot, _section),
                  child: _buildSection(
                    snapshot: snapshot,
                    projectService: projectService,
                    circuitService: circuitService,
                    pcbService: pcbService,
                    firmwareService: firmwareService,
                    deviceService: deviceService,
                    componentService: componentService,
                    experimentService: experimentService,
                    validationService: validationService,
                    manufacturingService: manufacturingService,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required EngineeringSnapshot snapshot,
    required ProjectService projectService,
    required CircuitLibraryService circuitService,
    required PCBService pcbService,
    required FirmwareBuildService firmwareService,
    required DeviceFleetService deviceService,
    required ComponentInventoryService componentService,
    required ExperimentService experimentService,
    required ValidationService validationService,
    required ManufacturingService manufacturingService,
  }) {
    return switch (_section) {
      EngineeringSection.dashboard => _buildDashboardSection(snapshot),
      EngineeringSection.projects => _buildProjectsSection(projectService),
      EngineeringSection.circuitLibrary => _buildCircuitLibrarySection(
        circuitService,
      ),
      EngineeringSection.pcbManager => _buildPcbSection(pcbService),
      EngineeringSection.firmwareCentre => _buildFirmwareSection(
        firmwareService,
      ),
      EngineeringSection.deviceFleet => _buildDeviceFleetSection(deviceService),
      EngineeringSection.componentInventory => _buildComponentSection(
        componentService,
      ),
      EngineeringSection.experimentLab => _buildExperimentSection(
        experimentService,
      ),
      EngineeringSection.testValidation => _buildValidationSection(
        validationService,
      ),
      EngineeringSection.manufacturing => _buildManufacturingSection(
        manufacturingService,
      ),
      EngineeringSection.documentation => _buildDocumentationSection(snapshot),
      EngineeringSection.settings => _buildSettingsSection(snapshot),
    };
  }

  Widget _buildWorkspaceOverview(
    EngineeringSnapshot snapshot,
    EngineeringSection section,
  ) {
    return switch (section) {
      EngineeringSection.dashboard => Column(
          children: [
            _InfoTileCard(
              title: 'Projects',
              value: '${snapshot.projectCount}',
              subtitle:
                  '${snapshot.activeProjectCount} active, ${snapshot.blockedProjectCount} parked',
              icon: Icons.folder_outlined,
            ),
            const SizedBox(height: 12),
            _InfoTileCard(
              title: 'Readiness',
              value: '${snapshot.validationPassCount}',
              subtitle: 'Validation checks passing',
              icon: Icons.verified_outlined,
            ),
          ],
        ),
      EngineeringSection.projects => Column(
          children: [
            _SummaryLine(
              label: 'Active',
              value: '${snapshot.activeProjectCount}',
            ),
            _SummaryLine(
              label: 'Ready',
              value: '${snapshot.readyProjectCount}',
            ),
            _SummaryLine(
              label: 'Parked',
              value: '${snapshot.blockedProjectCount}',
            ),
            _SummaryLine(
              label: 'Open tasks',
              value:
                  '${snapshot.projects.fold<int>(0, (sum, project) => sum + project.openTaskCount)}',
            ),
          ],
        ),
      EngineeringSection.circuitLibrary => Column(
          children: [
            _SummaryLine(label: 'Blocks', value: '${snapshot.circuitBlocks.length}'),
            _SummaryLine(
              label: 'Search hits',
              value: '${CircuitLibraryService(snapshot).blocks(query: _searchQuery, status: _statusFilter).length}',
            ),
          ],
        ),
      EngineeringSection.pcbManager => Column(
          children: [
            _SummaryLine(
              label: 'Ready',
              value: '${snapshot.fabReadyPcbCount}',
            ),
            _SummaryLine(
              label: 'Board files',
              value: '${snapshot.boardFileAttachmentCount}',
            ),
            _SummaryLine(
              label: 'Attachments',
              value: '${snapshot.attachmentCount}',
            ),
          ],
        ),
      EngineeringSection.firmwareCentre => Column(
          children: [
            _SummaryLine(
              label: 'Ready builds',
              value: '${snapshot.firmwareReadyCount}',
            ),
            _SummaryLine(
              label: 'Artifacts',
              value: '${snapshot.firmwareAttachmentCount}',
            ),
          ],
        ),
      EngineeringSection.deviceFleet => Column(
          children: [
            _SummaryLine(label: 'Online', value: '${snapshot.liveDeviceCount}'),
            _SummaryLine(
              label: 'Last seen',
              value: snapshot.deviceNodes.isEmpty
                  ? 'None'
                  : snapshot.deviceNodes.first.lastSeenAt.toLocal().toIso8601String().split('T').first,
            ),
          ],
        ),
      EngineeringSection.componentInventory => Column(
          children: [
            _SummaryLine(
              label: 'Low stock',
              value: '${snapshot.lowStockCount}',
            ),
            _SummaryLine(
              label: 'Items',
              value: '${snapshot.componentItems.length}',
            ),
          ],
        ),
      EngineeringSection.experimentLab => Column(
          children: [
            _SummaryLine(
              label: 'Experiments',
              value: '${snapshot.experiments.length}',
            ),
            _SummaryLine(
              label: 'Open evidence',
              value: '${snapshot.evidenceAttachmentCount}',
            ),
          ],
        ),
      EngineeringSection.testValidation => Column(
          children: [
            _SummaryLine(
              label: 'Pass rate',
              value: '${(snapshot.validationPassRate * 100).toStringAsFixed(0)}%',
            ),
            _SummaryLine(
              label: 'Attention',
              value: '${snapshot.validationAttentionCount}',
            ),
            _SummaryLine(
              label: 'Coverage',
              value: '${(snapshot.validationCoverageRate * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      EngineeringSection.manufacturing => Column(
          children: [
            _SummaryLine(
              label: 'Ready',
              value: '${snapshot.manufacturingReadyCount}',
            ),
            _SummaryLine(
              label: 'Blocked',
              value: '${snapshot.manufacturingBlockedCount}',
            ),
          ],
        ),
      EngineeringSection.documentation => Column(
          children: [
            _SummaryLine(
              label: 'Docs',
              value: '${snapshot.documents.length}',
            ),
            _SummaryLine(
              label: 'Evidence',
              value: '${snapshot.evidenceAttachmentCount}',
            ),
          ],
        ),
      EngineeringSection.settings => Column(
          children: [
            _SummaryLine(
              label: 'Offline',
              value: snapshot.settings.offlineOnly ? 'Yes' : 'No',
            ),
            _SummaryLine(
              label: 'Modules',
              value: '${EngineeringSection.values.length}',
            ),
          ],
        ),
    };
  }

  Widget _buildDashboardSection(EngineeringSnapshot snapshot) {
    final topProjects = _topProjects(snapshot);
    final searchService = EngineeringSearchService(snapshot);
    final hooks = snapshot.settings;
    final searchHits = searchService.search(_searchQuery, limit: 6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EngineeringSectionShell(
          title: 'Engineering dashboard',
          subtitle:
              'A calm glance at the build system, with the next useful action surfaced first.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1200
                      ? 4
                      : constraints.maxWidth >= 760
                      ? 2
                      : 1;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Projects',
                          value: '${snapshot.projectCount}',
                          subtitle:
                              '${snapshot.activeProjectCount} active, ${snapshot.blockedProjectCount} parked',
                          icon: Icons.folder_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'PCB readiness',
                          value: '${snapshot.fabReadyPcbCount}',
                          subtitle: 'Boards ready for fabrication',
                          icon: Icons.view_in_ar_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Devices online',
                          value: '${snapshot.liveDeviceCount}',
                          subtitle: 'Fleet nodes reporting locally',
                          icon: Icons.devices_other_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Average progress',
                          value:
                              '${snapshot.averageProjectProgress.toStringAsFixed(0)}%',
                          subtitle: 'Across the active engineering portfolio',
                          icon: Icons.monitor_heart_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Validation pass rate',
                          value:
                              '${(snapshot.validationPassRate * 100).toStringAsFixed(0)}%',
                          subtitle:
                              '${snapshot.validationAttentionCount} need attention',
                          icon: Icons.verified_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Manufacturing blockers',
                          value: '${snapshot.manufacturingBlockedCount}',
                          subtitle: 'Steps parked for review',
                          icon: Icons.precision_manufacturing_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _cardWidth(constraints.maxWidth, columns),
                        child: EngineeringMetricCard(
                          label: 'Attachments',
                          value: '${snapshot.attachmentCount}',
                          subtitle: 'Schematics, board files, evidence',
                          icon: Icons.attach_file_outlined,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000 ? 2 : 1;
                  final width = _cardWidth(constraints.maxWidth, columns);
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: width,
                        child: EngineeringSectionShell(
                          title: 'Top 3 build priorities',
                          subtitle: 'Keep the mission narrow and visible.',
                          child: Column(
                            children: [
                              for (final project in topProjects)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ProjectCard(project: project),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: EngineeringSectionShell(
                          title: 'Integration hooks',
                          subtitle:
                              'Open the local knowledge engine and GAIA assistant without leaving the workspace.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HookActionCard(
                                title: 'Omega Knowledge Engine',
                                subtitle:
                                    'Read-only search, repository scan, and architecture notes.',
                                icon: Icons.travel_explore_outlined,
                                onOpen: () =>
                                    context.push(hooks.knowledgeEngineRoute),
                              ),
                              const SizedBox(height: 12),
                              _HookActionCard(
                                title: 'GAIA assistant',
                                subtitle:
                                    'Future conversational support stays local and easy to swap later.',
                                icon: Icons.auto_awesome_outlined,
                                onOpen: () =>
                                    context.push(hooks.gaiaAssistantRoute),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Last refreshed: ${hooks.lastRefreshedLabel}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1100 ? 2 : 1;
                  final width = _cardWidth(constraints.maxWidth, columns);
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: width,
                        child: EngineeringTrendChart(
                          title: 'Validation trend pulse',
                          subtitle:
                              'A calm read on pass rate, attention, defect load, and coverage.',
                          series: _validationTrendSeries(snapshot),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: EngineeringTrendChart(
                          title: 'Manufacturing trend pulse',
                          subtitle:
                              'A calm read on ready, active, parked, and average completion.',
                          series: _manufacturingTrendSeries(snapshot),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (searchHits.isNotEmpty) ...[
                const SizedBox(height: 16),
                EngineeringSectionShell(
                  title: 'Focused matches',
                  subtitle: 'Quick scan results related to the current search.',
                  child: _SearchHitsView(
                    hits: searchHits,
                    onOpenSection: _setSection,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1000 ? 2 : 1;
                  final width = _cardWidth(constraints.maxWidth, columns);
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: width,
                        child: EngineeringSectionShell(
                          title: 'Readiness pulse',
                          subtitle:
                              'What is ready, what is blocked, and what needs review.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SummaryLine(
                                label: 'PCB revs ready',
                                value: '${snapshot.fabReadyPcbCount}',
                              ),
                              _SummaryLine(
                                label: 'Firmware builds ready',
                                value: '${snapshot.firmwareReadyCount}',
                              ),
                              _SummaryLine(
                                label: 'Validation passes',
                                value: '${snapshot.validationPassCount}',
                              ),
                              _SummaryLine(
                                label: 'Manufacturing steps ready',
                                value: '${snapshot.manufacturingReadyCount}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: EngineeringSectionShell(
                          title: 'Design note',
                          subtitle:
                              'Keep the engineering surface calm and reusable.',
                          child: Text(
                            'Use the search bar to jump across projects, boards, firmware, devices, experiments, and documentation. '
                            'Keep the first version intentionally small and easy to connect later.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsSection(ProjectService service) {
    final snapshot = _snapshotOrThrow;
    final projects = service.projects(
      query: _searchQuery,
      status: _statusFilter,
    );
    final topProjects = _topProjects(snapshot);
    return EngineeringSectionShell(
      title: 'Projects',
      subtitle:
          'MicroGrow, BioCalm, New Earth Living, Omega Dashboard, and future engineering workspaces.',
      trailing: FilledButton.icon(
        onPressed: () => _editProject(),
        icon: const Icon(Icons.add),
        label: const Text('Add project'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _responsiveCards([
            _InfoTileCard(
              title: 'Total projects',
              value: '${_snapshotOrThrow.projectCount}',
              subtitle: '${_snapshotOrThrow.activeProjectCount} active',
              icon: Icons.folder_outlined,
            ),
            _InfoTileCard(
              title: 'Average progress',
              value:
                  '${_snapshotOrThrow.averageProjectProgress.toStringAsFixed(0)}%',
              subtitle: 'Across the engineering portfolio',
              icon: Icons.monitor_heart_outlined,
            ),
            _InfoTileCard(
              title: 'Parked work',
              value: '${_snapshotOrThrow.blockedProjectCount}',
              subtitle: 'Projects needing review',
              icon: Icons.pause_circle_outline,
            ),
            _InfoTileCard(
              title: 'Open tasks',
              value:
                  '${_snapshotOrThrow.projects.fold<int>(0, (sum, project) => sum + project.openTaskCount)}',
              subtitle: 'Tracked locally in draft state',
              icon: Icons.checklist_outlined,
            ),
          ]),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1100;
              final cardWidth = isWide
                  ? _cardWidth(constraints.maxWidth, 2)
                  : constraints.maxWidth;

              final priorityPanel = EngineeringSectionShell(
                title: 'Top 3 build priorities',
                subtitle: 'Keep the mission narrow and visible.',
                child: topProjects.isEmpty
                    ? EngineeringEmptyState(
                        title: 'No project priorities yet',
                        subtitle:
                            'Add a project to start surfacing the calm next move.',
                        actionLabel: 'Add project',
                        onAction: _editProject,
                      )
                    : Column(
                        children: [
                          for (final project in topProjects)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ProjectCard(project: project),
                            ),
                        ],
                      ),
              );

              final insightsPanel = EngineeringSectionShell(
                title: 'Project insights',
                subtitle: 'A quick read on the portfolio state and next move.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryLine(
                      label: 'Active',
                      value: '${_snapshotOrThrow.activeProjectCount}',
                    ),
                    _SummaryLine(
                      label: 'Ready',
                      value: '${_snapshotOrThrow.readyProjectCount}',
                    ),
                    _SummaryLine(
                      label: 'Parked',
                      value: '${_snapshotOrThrow.blockedProjectCount}',
                    ),
                    _SummaryLine(
                      label: 'Average progress',
                      value:
                          '${_snapshotOrThrow.averageProjectProgress.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current focus',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      projects.isEmpty
                          ? 'No projects match the current search or filter.'
                          : 'Showing ${projects.length} project${projects.length == 1 ? '' : 's'} for the current view.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        EngineeringStatusChip(label: _statusFilter),
                        EngineeringStatusChip(label: 'Search ready'),
                        EngineeringStatusChip(label: 'Offline-first'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _HookActionCard(
                      title: 'Open Knowledge Engine',
                      subtitle:
                          'Scan local project context, architecture notes, and linked workspaces.',
                      icon: Icons.travel_explore_outlined,
                      onOpen: () => context.push(
                        _snapshotOrThrow.settings.knowledgeEngineRoute,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _HookActionCard(
                      title: 'Open GAIA',
                      subtitle:
                          'Keep assistant support local when you want a quick follow-up.',
                      icon: Icons.auto_awesome_outlined,
                      onOpen: () => context.push(
                        _snapshotOrThrow.settings.gaiaAssistantRoute,
                      ),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(width: cardWidth, child: priorityPanel),
                    SizedBox(width: cardWidth, child: insightsPanel),
                  ],
                );
              }

              return Column(
                children: [
                  priorityPanel,
                  insightsPanel,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          EngineeringSectionShell(
            title: 'All projects',
            subtitle:
                projects.isEmpty
                    ? 'No project matches the current search or filter.'
                    : 'A calm grid of every engineering project in the local workspace.',
            child: projects.isEmpty
                ? EngineeringEmptyState(
                    title: 'No project matches',
                    subtitle:
                        'Try a different search or clear the current filter.',
                    actionLabel: 'Clear search',
                    onAction: _clearSearch,
                  )
                : _responsiveCards(
                    projects
                        .map(
                          (project) => _ProjectCard(
                            project: project,
                            onEdit: () => _editProject(project),
                          ),
                        )
                        .toList(growable: false),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircuitLibrarySection(CircuitLibraryService service) {
    final blocks = service.blocks(query: _searchQuery, status: _statusFilter);
    return EngineeringSectionShell(
      title: 'Circuit Library',
      subtitle:
          'Reusable circuit blocks, system functions, and integration hooks.',
      child: blocks.isEmpty
          ? EngineeringEmptyState(
              title: 'No circuit blocks match',
              subtitle: 'Try a circuit name, category, or functional keyword.',
              actionLabel: 'Reset search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              blocks
                  .map((block) => _CircuitCard(block: block))
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildPcbSection(PCBService service) {
    final pcbRevisions = service.revisions(
      query: _searchQuery,
      status: _statusFilter,
    );
    return EngineeringSectionShell(
      title: 'PCB Manager',
      subtitle:
          'Track revision state, fabrication readiness, and board-level progress.',
      trailing: FilledButton.icon(
        onPressed: () => _editPcbRevision(),
        icon: const Icon(Icons.add),
        label: const Text('Add PCB'),
      ),
      child: pcbRevisions.isEmpty
          ? EngineeringEmptyState(
              title: 'No PCB revisions match',
              subtitle: 'Check the search term or clear the current filter.',
              actionLabel: 'Clear filter',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              pcbRevisions
                  .map(
                    (pcb) =>
                        _PcbCard(pcb: pcb, onEdit: () => _editPcbRevision(pcb)),
                  )
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildFirmwareSection(FirmwareBuildService service) {
    final builds = service.builds(query: _searchQuery, status: _statusFilter);
    return EngineeringSectionShell(
      title: 'Firmware Centre',
      subtitle: 'Builds, versions, artifacts, and the next release action.',
      trailing: FilledButton.icon(
        onPressed: () => _editFirmwareBuild(),
        icon: const Icon(Icons.add),
        label: const Text('Add build'),
      ),
      child: builds.isEmpty
          ? EngineeringEmptyState(
              title: 'No firmware builds match',
              subtitle: 'Try a device name, version, or build type.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              builds
                  .map(
                    (build) => _FirmwareCard(
                      buildModel: build,
                      onEdit: () => _editFirmwareBuild(build),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildDeviceFleetSection(DeviceFleetService service) {
    final devices = service.devices(query: _searchQuery, status: _statusFilter);
    return EngineeringSectionShell(
      title: 'Device Fleet',
      subtitle:
          'Field nodes, bench boards, health labels, and last-seen status.',
      trailing: FilledButton.icon(
        onPressed: () => _editDeviceNode(),
        icon: const Icon(Icons.add),
        label: const Text('Add device'),
      ),
      child: devices.isEmpty
          ? EngineeringEmptyState(
              title: 'No device nodes match',
              subtitle: 'Try a device name, model, or location.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              devices
                  .map(
                    (device) => _DeviceCard(
                      device: device,
                      onEdit: () => _editDeviceNode(device),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildComponentSection(ComponentInventoryService service) {
    final items = service.components(
      query: _searchQuery,
      status: _statusFilter,
    );
    return EngineeringSectionShell(
      title: 'Component Inventory',
      subtitle:
          'Stock health, reorder pressure, preferred vendors, and storage locations.',
      child: items.isEmpty
          ? EngineeringEmptyState(
              title: 'No components match',
              subtitle: 'Search by SKU, category, or vendor.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              items.map((item) => _ComponentCard(item: item)).toList(),
            ),
    );
  }

  Widget _buildExperimentSection(ExperimentService service) {
    final experiments = service.experiments(
      query: _searchQuery,
      status: _statusFilter,
    );
    return EngineeringSectionShell(
      title: 'Experiment Lab',
      subtitle:
          'Capture hypothesis, evidence, results, and the next intentional test.',
      child: experiments.isEmpty
          ? EngineeringEmptyState(
              title: 'No experiments match',
              subtitle: 'Search by hypothesis, result summary, or tag.',
              actionLabel: 'Reset search',
              onAction: _clearSearch,
            )
          : _responsiveCards(
              experiments
                  .map((experiment) => _ExperimentCard(experiment: experiment))
                  .toList(),
            ),
    );
  }

  Widget _buildValidationSection(ValidationService service) {
    final procedures = service.procedures(
      query: _searchQuery,
      status: _statusFilter,
    );
    final results = service.results(query: _searchQuery, status: _statusFilter);
    return Column(
      children: [
        EngineeringSectionShell(
          title: 'Test & Validation',
          subtitle: 'Procedures, checks, verdicts, and calm evidence review.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveCards([
                _InfoTileCard(
                  title: 'Pass rate',
                  value:
                      '${(_snapshotOrThrow.validationPassRate * 100).toStringAsFixed(0)}%',
                  subtitle:
                      '${_snapshotOrThrow.validationDefectCount} defect signals',
                  icon: Icons.verified_outlined,
                ),
                _InfoTileCard(
                  title: 'Coverage',
                  value:
                      '${(_snapshotOrThrow.validationCoverageRate * 100).toStringAsFixed(0)}%',
                  subtitle:
                      '${_snapshotOrThrow.validationCoveredProcedureCount} procedures covered',
                  icon: Icons.fact_check_outlined,
                ),
                _InfoTileCard(
                  title: 'Attention rate',
                  value:
                      '${(_snapshotOrThrow.validationAttentionRate * 100).toStringAsFixed(0)}%',
                  subtitle: 'Items parked for review.',
                  icon: Icons.report_outlined,
                ),
              ]),
              const SizedBox(height: 16),
              _responsiveCards(
                procedures
                    .map((procedure) => _ProcedureCard(procedure: procedure))
                    .toList(),
              ),
              const SizedBox(height: 16),
              _responsiveCards(
                results
                    .map((result) => _ValidationCard(result: result))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManufacturingSection(ManufacturingService service) {
    final steps = service.steps(query: _searchQuery, status: _statusFilter);
    return EngineeringSectionShell(
      title: 'Manufacturing',
      subtitle: 'Assembly readiness, station flow, and pack-out status.',
      child: steps.isEmpty
          ? EngineeringEmptyState(
              title: 'No manufacturing steps match',
              subtitle: 'Search by stage, owner, or station.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _responsiveCards([
                  _InfoTileCard(
                    title: 'Ready rate',
                    value:
                        '${(_snapshotOrThrow.manufacturingReadyRate * 100).toStringAsFixed(0)}%',
                    subtitle:
                        '${_snapshotOrThrow.manufacturingReadyCount} steps ready to move',
                    icon: Icons.precision_manufacturing_outlined,
                  ),
                  _InfoTileCard(
                    title: 'Blocked steps',
                    value: '${_snapshotOrThrow.manufacturingBlockedCount}',
                    subtitle: 'Parked for review.',
                    icon: Icons.pause_circle_outline,
                  ),
                ]),
                const SizedBox(height: 16),
                _responsiveCards(
                  steps.map((step) => _ManufacturingCard(step: step)).toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildDocumentationSection(EngineeringSnapshot snapshot) {
    final docs = snapshot.documents
        .where(
          (document) => _matchesLocalQuery(
            document.title,
            document.documentType,
            document.status,
            document.summary,
            document.filePath,
            document.tags,
          ),
        )
        .toList(growable: false);
    final attachments = snapshot.attachments
        .where(
          (attachment) => _matchesLocalQuery(
            attachment.title,
            attachment.ownerType,
            attachment.ownerId,
            attachment.kind,
            attachment.filePath,
            attachment.tags,
          ),
        )
        .toList(growable: false);
    final decisions = snapshot.decisions
        .where(
          (decision) => _matchesLocalQuery(
            decision.title,
            decision.decision,
            decision.status,
            decision.rationale,
            decision.nextAction,
            decision.tags,
          ),
        )
        .toList(growable: false);

    return Column(
      children: [
        EngineeringSectionShell(
          title: 'Documentation',
          subtitle:
              'Architecture notes, guides, checklists, decision logs, and release packs.',
          trailing: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _editAttachment(),
                icon: const Icon(Icons.attach_file_outlined),
                label: const Text('Add attachment'),
              ),
              FilledButton.icon(
                onPressed: () => _editDocument(),
                icon: const Icon(Icons.add),
                label: const Text('Add doc'),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AttachmentDropZone(
                onPickFile: () async {
                  final picked = await FilePicker.pickFiles(
                    allowMultiple: false,
                  );
                  final path = picked?.files.single.path;
                  if (path == null) {
                    return;
                  }
                  await _editAttachment(
                    EngineeringAttachment(
                      id: 'attachment_${DateTime.now().microsecondsSinceEpoch}',
                      ownerType: 'Project',
                      ownerId: '',
                      title: path.split('\\').last,
                      kind: 'Attachment',
                      filePath: path,
                      status: 'Linked',
                      updatedAt: DateTime.now().toUtc(),
                      notes: 'Added from local picker.',
                      tags: const ['local', 'attachment'],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _responsiveCards(
                docs
                    .map(
                      (doc) => _DocumentCard(
                        document: doc,
                        onEdit: () => _editDocument(doc),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              _responsiveCards(
                attachments
                    .map(
                      (attachment) => _AttachmentCard(
                        attachment: attachment,
                        onTap: () => _editAttachment(attachment),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              _responsiveCards(
                decisions
                    .map((decision) => _DecisionCard(decision: decision))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(EngineeringSnapshot snapshot) {
    final settings = snapshot.settings;
    return Column(
      children: [
        EngineeringSectionShell(
          title: 'Engineering settings',
          subtitle:
              'Local storage, integration hooks, and the production hardening note.',
          trailing: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _importSnapshot,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Import'),
              ),
              FilledButton.icon(
                onPressed: _exportSnapshot,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export'),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _responsiveCards([
                _InfoTileCard(
                  title: 'Module root',
                  value: settings.moduleRootPath,
                  subtitle: 'Module source folder and manifest location.',
                  icon: Icons.folder_copy_outlined,
                ),
                _InfoTileCard(
                  title: 'Storage path',
                  value: settings.storagePath,
                  subtitle: 'Local JSON state and future persistence home.',
                  icon: Icons.save_outlined,
                ),
                _InfoTileCard(
                  title: 'Knowledge hook',
                  value: settings.knowledgeEngineRoute,
                  subtitle: 'Omega Knowledge Engine route placeholder.',
                  icon: Icons.travel_explore_outlined,
                ),
                _InfoTileCard(
                  title: 'GAIA hook',
                  value: settings.gaiaAssistantRoute,
                  subtitle: 'Assistant route placeholder for future wiring.',
                  icon: Icons.auto_awesome_outlined,
                ),
                _InfoTileCard(
                  title: 'Access role',
                  value: _accessPolicy.label,
                  subtitle:
                      'Edit: ${_accessPolicy.canEdit ? 'yes' : 'no'} · Export: ${_accessPolicy.canExport ? 'yes' : 'no'} · Import: ${_accessPolicy.canImport ? 'yes' : 'no'}',
                  icon: Icons.admin_panel_settings_outlined,
                ),
              ]),
              const SizedBox(height: 16),
              _responsiveCards([
                _InfoTileCard(
                  title: 'Validation pass rate',
                  value:
                      '${(snapshot.validationPassRate * 100).toStringAsFixed(0)}%',
                  subtitle:
                      '${snapshot.validationAttentionCount} items need review.',
                  icon: Icons.verified_outlined,
                ),
                _InfoTileCard(
                  title: 'Manufacturing blockers',
                  value: '${snapshot.manufacturingBlockedCount}',
                  subtitle: 'Queued steps waiting for resolution.',
                  icon: Icons.report_gmailerrorred_outlined,
                ),
                _InfoTileCard(
                  title: 'Attachments',
                  value: '${snapshot.attachmentCount}',
                  subtitle: 'Linked assets across the module.',
                  icon: Icons.attach_file_outlined,
                ),
              ]),
              const SizedBox(height: 16),
              Text(
                'Production hardening TODO',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const _BulletLine('Move the mock snapshot into Drift tables.'),
              const _BulletLine('Add export and import for offline backups.'),
              const _BulletLine(
                'Persist edit flows for projects, boards, and devices.',
              ),
              const _BulletLine(
                'Add screenshot and golden tests for the finished UI.',
              ),
              const _BulletLine(
                'Keep the integration hooks stable while the backend grows.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<EngineeringProject> _topProjects(EngineeringSnapshot snapshot) {
    final projects = snapshot.projects.toList(growable: false);
    projects.sort((left, right) {
      final priorityLeft = _priorityRank(left.priority);
      final priorityRight = _priorityRank(right.priority);
      if (priorityLeft != priorityRight) {
        return priorityLeft.compareTo(priorityRight);
      }
      return right.progressPercent.compareTo(left.progressPercent);
    });
    return projects.take(3).toList(growable: false);
  }

  List<EngineeringTrendPoint> _validationTrendSeries(
    EngineeringSnapshot snapshot,
  ) {
    final total = snapshot.validationResults.length;
    final percent = total == 0 ? 0.0 : 100 / total;
    return [
      EngineeringTrendPoint(
        label: 'Pass',
        value: snapshot.validationPassCount * percent,
        valueLabel: '${snapshot.validationPassCount}',
      ),
      EngineeringTrendPoint(
        label: 'Attention',
        value: snapshot.validationAttentionCount * percent,
        valueLabel: '${snapshot.validationAttentionCount}',
      ),
      EngineeringTrendPoint(
        label: 'Defect',
        value: snapshot.validationDefectCount * percent,
        valueLabel: '${snapshot.validationDefectCount}',
      ),
      EngineeringTrendPoint(
        label: 'Coverage',
        value: snapshot.validationCoverageRate * 100,
        valueLabel:
            '${(snapshot.validationCoverageRate * 100).toStringAsFixed(0)}%',
      ),
    ];
  }

  List<EngineeringTrendPoint> _manufacturingTrendSeries(
    EngineeringSnapshot snapshot,
  ) {
    final total = snapshot.manufacturingSteps.length;
    final percent = total == 0 ? 0.0 : 100 / total;
    final readyCount = snapshot.manufacturingReadyCount;
    final blockedCount = snapshot.manufacturingBlockedCount;
    final activeCount = snapshot.manufacturingSteps.where(
      (step) {
        final status = step.status.toLowerCase();
        return status.contains('active') ||
            status.contains('progress') ||
            status.contains('building') ||
            status.contains('working');
      },
    ).length;
    final averageProgress = snapshot.manufacturingSteps.isEmpty
        ? 0.0
        : snapshot.manufacturingSteps.fold<int>(
              0,
              (sum, step) => sum + step.progressPercent,
            ) /
            snapshot.manufacturingSteps.length;

    return [
      EngineeringTrendPoint(
        label: 'Ready',
        value: readyCount * percent,
        valueLabel: '$readyCount',
      ),
      EngineeringTrendPoint(
        label: 'Active',
        value: activeCount * percent,
        valueLabel: '$activeCount',
      ),
      EngineeringTrendPoint(
        label: 'Parked',
        value: blockedCount * percent,
        valueLabel: '$blockedCount',
      ),
      EngineeringTrendPoint(
        label: 'Avg progress',
        value: averageProgress,
        valueLabel: '${averageProgress.toStringAsFixed(0)}%',
      ),
    ];
  }

  int _priorityRank(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 0;
      case 'medium':
        return 1;
      case 'low':
        return 2;
      default:
        return 3;
    }
  }

  bool _matchesLocalQuery(
    String title,
    String a,
    String b,
    String c,
    String d,
    List<String> tags,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    final values = [title, a, b, c, d, ...tags];
    return values.any((value) => value.toLowerCase().contains(query));
  }

  double _cardWidth(double maxWidth, int columns) {
    if (columns <= 1) {
      return maxWidth;
    }
    return (maxWidth - ((columns - 1) * 14)) / columns;
  }

  Widget _responsiveCards(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 2
            : constraints.maxWidth >= 900
            ? 2
            : 1;
        final width = _cardWidth(constraints.maxWidth, columns);
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.snapshot,
    required this.searchController,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onClearSearch,
    required this.onOpenKnowledgeEngine,
    required this.onOpenGaiaAssistant,
  });

  final EngineeringSnapshot snapshot;
  final TextEditingController searchController;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenKnowledgeEngine;
  final VoidCallback onOpenGaiaAssistant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: engineeringPanelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Omega Engineering Studio',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(today, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Build the next useful thing, keep the system calm, and surface only the work that matters most today.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  EngineeringStatusChip(label: 'Offline-first'),
                  const SizedBox(height: 8),
                  EngineeringStatusChip(
                    label: snapshot.settings.lastRefreshedLabel,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final children = [
                TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    labelText: 'Search engineering workspaces',
                    hintText:
                        'Projects, circuits, boards, firmware, devices, docs...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: onClearSearch,
                            icon: const Icon(Icons.clear),
                          ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('engineeringStatusFilter'),
                  initialValue: statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Status filter',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Ready', child: Text('Ready')),
                    DropdownMenuItem(value: 'Blocked', child: Text('Blocked')),
                    DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onStatusFilterChanged(value);
                    }
                  },
                ),
              ];
              if (narrow) {
                return Column(children: children);
              }
              return Row(
                children: [
                  Expanded(flex: 4, child: children[0]),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: children[1]),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onOpenKnowledgeEngine,
                icon: const Icon(Icons.travel_explore_outlined),
                label: const Text('Open Knowledge Engine'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenGaiaAssistant,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Open GAIA'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchHitsView extends StatelessWidget {
  const _SearchHitsView({required this.hits, required this.onOpenSection});

  final List<EngineeringSearchHit> hits;
  final ValueChanged<EngineeringSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final hit in hits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onOpenSection(hit.section),
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hit.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(hit.subtitle),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        EngineeringStatusChip(label: hit.kind),
                        const SizedBox(height: 4),
                        Text(hit.section.label),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EngineeringWorkspaceFrame extends StatelessWidget {
  const _EngineeringWorkspaceFrame({
    required this.snapshot,
    required this.currentSection,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSectionSelected,
    required this.onClearSearch,
    required this.onOpenKnowledgeEngine,
    required this.onOpenGaiaAssistant,
    required this.onOpenPalette,
    required this.overview,
    required this.child,
  });

  final EngineeringSnapshot snapshot;
  final EngineeringSection currentSection;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<EngineeringSection> onSectionSelected;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenKnowledgeEngine;
  final VoidCallback onOpenGaiaAssistant;
  final VoidCallback onOpenPalette;
  final Widget overview;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColours.darkBackground.withValues(alpha: 0.52),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.82),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1240;
          final leftRailWidth = 210.0;
          final rightRailWidth = 320.0;
          final centerWidth = wide
              ? constraints.maxWidth - leftRailWidth - rightRailWidth - 36
              : constraints.maxWidth;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WorkspaceHeaderCard(
                snapshot: snapshot,
                currentSection: currentSection,
                searchQuery: searchQuery,
                statusFilter: statusFilter,
                onClearSearch: onClearSearch,
                onOpenKnowledgeEngine: onOpenKnowledgeEngine,
                onOpenGaiaAssistant: onOpenGaiaAssistant,
                onOpenPalette: onOpenPalette,
              ),
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: leftRailWidth,
                      child: _WorkspaceRail(
                        currentSection: currentSection,
                        onSectionSelected: onSectionSelected,
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(width: centerWidth, child: child),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: rightRailWidth,
                      child: _WorkspaceInsightsRail(
                        currentSection: currentSection,
                        overview: overview,
                        snapshot: snapshot,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WorkspaceRail(
                      currentSection: currentSection,
                      onSectionSelected: onSectionSelected,
                    ),
                    const SizedBox(height: 14),
                    child,
                    const SizedBox(height: 14),
                    _WorkspaceInsightsRail(
                      currentSection: currentSection,
                      overview: overview,
                      snapshot: snapshot,
                    ),
                  ],
                ),
            ],
          );

          return content;
        },
      ),
    );
  }
}

class _WorkspaceHeaderCard extends StatelessWidget {
  const _WorkspaceHeaderCard({
    required this.snapshot,
    required this.currentSection,
    required this.searchQuery,
    required this.statusFilter,
    required this.onClearSearch,
    required this.onOpenKnowledgeEngine,
    required this.onOpenGaiaAssistant,
    required this.onOpenPalette,
  });

  final EngineeringSnapshot snapshot;
  final EngineeringSection currentSection;
  final String searchQuery;
  final String statusFilter;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenKnowledgeEngine;
  final VoidCallback onOpenGaiaAssistant;
  final VoidCallback onOpenPalette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = MaterialLocalizations.of(context)
        .formatFullDate(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColours.darkSurface.withValues(alpha: 0.94),
        border: Border.all(
          color: AppColours.darkSecondary.withValues(alpha: 0.18),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          final hero = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Omega Engineering Studio',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColours.darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                currentSection.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColours.darkSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                today,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Build the next useful thing, keep the system calm, and surface only the work that matters most today.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColours.darkMutedText,
                  height: 1.35,
                ),
              ),
            ],
          );

          final actionRow = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onOpenPalette,
                icon: const Icon(Icons.search),
                label: const Text('Command Palette'),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenKnowledgeEngine,
                icon: const Icon(Icons.travel_explore_outlined),
                label: const Text('Knowledge Engine'),
              ),
              FilledButton.tonalIcon(
                onPressed: onOpenGaiaAssistant,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('GAIA'),
              ),
              TextButton.icon(
                onPressed: onClearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          );

          final metrics = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeaderMetricChip(
                label: 'Projects',
                value: '${snapshot.projectCount}',
              ),
              _HeaderMetricChip(
                label: 'Search',
                value: searchQuery.trim().isEmpty ? 'Idle' : 'Filtered',
              ),
              _HeaderMetricChip(label: 'Status', value: statusFilter),
              _HeaderMetricChip(
                label: 'Energy',
                value: snapshot.settings.lastRefreshedLabel,
              ),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hero,
                const SizedBox(height: 14),
                actionRow,
                const SizedBox(height: 14),
                metrics,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: hero),
              const SizedBox(width: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    metrics,
                    const SizedBox(height: 14),
                    actionRow,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderMetricChip extends StatelessWidget {
  const _HeaderMetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColours.darkSurfaceAlt.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColours.darkOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColours.darkSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceRail extends StatelessWidget {
  const _WorkspaceRail({
    required this.currentSection,
    required this.onSectionSelected,
  });

  final EngineeringSection currentSection;
  final ValueChanged<EngineeringSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColours.darkSurface.withValues(alpha: 0.92),
        border: Border.all(
          color: AppColours.darkOutline.withValues(alpha: 0.82),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sections',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColours.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final section in EngineeringSection.values) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _WorkspaceRailButton(
                label: section.label,
                selected: section == currentSection,
                onPressed: () => onSectionSelected(section),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkspaceRailButton extends StatelessWidget {
  const _WorkspaceRailButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.24,
                ),
          foregroundColor: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }
}

class _WorkspaceInsightsRail extends StatelessWidget {
  const _WorkspaceInsightsRail({
    required this.currentSection,
    required this.snapshot,
    required this.overview,
  });

  final EngineeringSection currentSection;
  final EngineeringSnapshot snapshot;
  final Widget overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EngineeringSectionShell(
          title: 'Workspace insight',
          subtitle: 'A calm read on the selected tab.',
          child: overview,
        ),
        const SizedBox(height: 14),
        EngineeringSectionShell(
          title: 'Workspace status',
          subtitle: 'Local-only module state and cross-cutting signals.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryLine(label: 'Section', value: currentSection.label),
              _SummaryLine(
                label: 'Projects',
                value: '${snapshot.projectCount}',
              ),
              _SummaryLine(
                label: 'Ready',
                value: '${snapshot.readyProjectCount}',
              ),
              _SummaryLine(
                label: 'Blocked',
                value: '${snapshot.blockedProjectCount}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EngineeringPaletteAction {
  const _EngineeringPaletteAction({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onSelected,
  });

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final FutureOr<void> Function() onSelected;
}

class _EngineeringCommandPaletteDialog extends StatefulWidget {
  const _EngineeringCommandPaletteDialog({
    required this.snapshot,
    required this.currentSection,
    required this.actions,
  });

  final EngineeringSnapshot snapshot;
  final EngineeringSection currentSection;
  final List<_EngineeringPaletteAction> actions;

  @override
  State<_EngineeringCommandPaletteDialog> createState() =>
      _EngineeringCommandPaletteDialogState();
}

class _EngineeringCommandPaletteDialogState
    extends State<_EngineeringCommandPaletteDialog> {
  late final TextEditingController _queryController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = widget.actions
        .where((action) {
          if (query.isEmpty) {
            return true;
          }
          return action.label.toLowerCase().contains(query) ||
              action.subtitle.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return AlertDialog(
      title: const Text('Command Palette'),
      content: SizedBox(
        width: 640,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('engineeringCommandPaletteSearchField'),
              controller: _queryController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Search engineering actions',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 360,
              child: filtered.isEmpty
                  ? const EngineeringEmptyState(
                      title: 'No actions found',
                      subtitle:
                          'Try a section name, create action, or integration hook.',
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final action = filtered[index];
                        final isCurrentSection = action.label
                            .toLowerCase()
                            .contains(
                              widget.currentSection.label.toLowerCase(),
                            );
                        return InkWell(
                          onTap: () async {
                            await action.onSelected();
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(
                                      alpha: isCurrentSection ? 0.9 : 0.55,
                                    ),
                              ),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(
                                    alpha: isCurrentSection ? 0.44 : 0.24,
                                  ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(action.icon),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(action.label),
                                      const SizedBox(height: 4),
                                      Text(
                                        action.subtitle,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, this.onEdit});

  final EngineeringProject project;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                EngineeringStatusChip(label: project.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(project.summary),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: project.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${project.progressPercent}% complete'),
            const SizedBox(height: 8),
            Text('Milestone: ${project.milestone}'),
            const SizedBox(height: 4),
            Text('Next action: ${project.nextAction}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EngineeringStatusChip(label: project.priority),
                EngineeringStatusChip(label: project.system),
                EngineeringStatusChip(label: '${project.openTaskCount} open'),
              ],
            ),
            if (project.targetDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Target: ${project.targetDate!.toLocal().toIso8601String().split('T').first}',
              ),
            ],
            if (onEdit != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CircuitCard extends StatelessWidget {
  const _CircuitCard({required this.block});

  final CircuitBlock block;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    block.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: block.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(block.function),
            const SizedBox(height: 8),
            Text('Next action: ${block.nextAction}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: block.progressPercent / 100),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EngineeringStatusChip(label: block.category),
                for (final tag in block.tags.take(2))
                  EngineeringStatusChip(label: tag),
              ],
            ),
            if (block.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(block.notes, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _PcbCard extends StatelessWidget {
  const _PcbCard({required this.pcb, this.onEdit});

  final PCBRevision pcb;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${pcb.boardName} ${pcb.revision}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: pcb.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Layers: ${pcb.layers}'),
            const SizedBox(height: 4),
            Text('Manufacturing partner: ${pcb.manufacturingPartner}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: pcb.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${pcb.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Next action: ${pcb.nextAction}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EngineeringStatusChip(
                  label: pcb.fabReady ? 'Fab ready' : 'Not ready',
                ),
                for (final tag in pcb.tags.take(2))
                  EngineeringStatusChip(label: tag),
              ],
            ),
            if (onEdit != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FirmwareCard extends StatelessWidget {
  const _FirmwareCard({required this.buildModel, this.onEdit});

  final FirmwareBuild buildModel;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${buildModel.targetDevice} ${buildModel.version}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: buildModel.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Build type: ${buildModel.buildType}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: buildModel.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${buildModel.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Next action: ${buildModel.nextAction}'),
            const SizedBox(height: 4),
            Text(
              'Artifact: ${buildModel.artifactPath}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (onEdit != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, this.onEdit});

  final DeviceNode device;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: device.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('${device.model} · ${device.location}'),
            const SizedBox(height: 4),
            Text('Health: ${device.health}'),
            const SizedBox(height: 4),
            Text('Firmware: ${device.firmwareVersion}'),
            const SizedBox(height: 8),
            Text('Next action: ${device.nextAction}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in device.tags.take(3))
                  EngineeringStatusChip(label: tag),
              ],
            ),
            if (onEdit != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.item});

  final ComponentItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: item.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(item.sku),
            const SizedBox(height: 4),
            Text('Category: ${item.category}'),
            const SizedBox(height: 4),
            Text(
              'Stock: ${item.quantityOnHand} / reorder ${item.reorderLevel}',
            ),
            const SizedBox(height: 8),
            Text('Vendor: ${item.preferredVendor}'),
            const SizedBox(height: 4),
            Text('Next action: ${item.nextAction}'),
            const SizedBox(height: 8),
            EngineeringStatusChip(
              label: item.isLowStock ? 'Needs attention' : 'In stock',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({required this.experiment});

  final ExperimentRecord experiment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    experiment.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: experiment.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(experiment.hypothesis),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: experiment.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${experiment.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Evidence items: ${experiment.evidenceCount}'),
            const SizedBox(height: 4),
            Text('Result: ${experiment.resultSummary}'),
            const SizedBox(height: 4),
            Text('Next action: ${experiment.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  const _ProcedureCard({required this.procedure});

  final TestProcedure procedure;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    procedure.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: procedure.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Stage: ${procedure.stage}'),
            const SizedBox(height: 4),
            Text('Owner: ${procedure.owner}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: procedure.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${procedure.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Next action: ${procedure.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.result});

  final ValidationResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: result.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Verdict: ${result.verdict}'),
            const SizedBox(height: 4),
            Text('Severity: ${result.severity}'),
            const SizedBox(height: 4),
            Text('Evidence items: ${result.evidenceCount}'),
            const SizedBox(height: 4),
            Text('Summary: ${result.summary}'),
            const SizedBox(height: 4),
            Text('Next action: ${result.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _ManufacturingCard extends StatelessWidget {
  const _ManufacturingCard({required this.step});

  final ManufacturingStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: step.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Stage: ${step.stage}'),
            const SizedBox(height: 4),
            Text('Owner: ${step.owner}'),
            const SizedBox(height: 4),
            Text('Station: ${step.station}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: step.progressPercent / 100),
            const SizedBox(height: 8),
            Text('${step.progressPercent}% complete'),
            const SizedBox(height: 4),
            Text('Due: ${step.dueLabel}'),
            const SizedBox(height: 4),
            Text('Next action: ${step.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, this.onEdit});

  final EngineeringDocument document;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    document.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: document.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(document.documentType),
            const SizedBox(height: 4),
            Text(document.summary),
            const SizedBox(height: 4),
            Text(
              document.filePath,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (onEdit != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttachmentDropZone extends StatelessWidget {
  const _AttachmentDropZone({required this.onPickFile});

  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPickFile,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.22,
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drop or pick a local attachment',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep schematics, board files, firmware artifacts, and validation evidence local first.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              onPressed: onPickFile,
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Pick file'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.attachment, this.onTap});

  final EngineeringAttachment attachment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    attachment.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: attachment.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(attachment.kind),
            const SizedBox(height: 4),
            Text(
              attachment.filePath,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(attachment.notes),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EngineeringStatusChip(label: attachment.ownerType),
                EngineeringStatusChip(label: attachment.ownerId),
                for (final tag in attachment.tags.take(2))
                  EngineeringStatusChip(label: tag),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision});

  final EngineeringDecision decision;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    decision.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                EngineeringStatusChip(label: decision.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(decision.decision),
            const SizedBox(height: 4),
            Text('Confidence: ${decision.confidence}'),
            const SizedBox(height: 4),
            Text('Rationale: ${decision.rationale}'),
            const SizedBox(height: 4),
            Text('Next action: ${decision.nextAction}'),
          ],
        ),
      ),
    );
  }
}

class _HookActionCard extends StatelessWidget {
  const _HookActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.32,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTileCard extends StatelessWidget {
  const _InfoTileCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.30,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.labelLarge)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
