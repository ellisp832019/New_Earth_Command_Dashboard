import 'dart:io';

import 'package:new_earth_command_dashboard/features/omega_engineering_studio/data/engineering_repository.dart';
import 'package:new_earth_command_dashboard/features/omega_engineering_studio/domain/engineering_models.dart';

class EngineeringStudioFakeRepository implements EngineeringRepository {
  EngineeringStudioFakeRepository(this._snapshot);

  EngineeringSnapshot _snapshot;

  @override
  Future<EngineeringSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<void> resetLocalState() async {}

  @override
  Future<void> saveSnapshot(EngineeringSnapshot snapshot) async {
    _snapshot = snapshot;
  }

  @override
  Future<EngineeringProject> createProject({
    required String title,
    required String summary,
    required String status,
    required String priority,
    required int progressPercent,
    required String milestone,
    required String nextAction,
    required String system,
    DateTime? targetDate,
    required List<String> tags,
  }) async {
    final project = EngineeringProject(
      id: 'project_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      summary: summary,
      status: status,
      priority: priority,
      progressPercent: progressPercent,
      milestone: milestone,
      nextAction: nextAction,
      system: system,
      updatedAt: DateTime.now().toUtc(),
      openTaskCount: 0,
      blockedTaskCount: 0,
      tags: tags,
      targetDate: targetDate,
    );
    await updateProject(project);
    return project;
  }

  @override
  Future<EngineeringProject> updateProject(EngineeringProject project) async {
    _snapshot = _snapshot.copyWith(
      projects: _upsert(
        _snapshot.projects,
        project,
        (item) => item.id == project.id,
      ),
    );
    return project;
  }

  @override
  Future<CircuitBlock> upsertCircuitBlock(CircuitBlock block) async {
    _snapshot = _snapshot.copyWith(
      circuitBlocks: _upsert(
        _snapshot.circuitBlocks,
        block,
        (item) => item.id == block.id,
      ),
    );
    return block;
  }

  @override
  Future<PCBRevision> upsertPcbRevision(PCBRevision revision) async {
    _snapshot = _snapshot.copyWith(
      pcbRevisions: _upsert(
        _snapshot.pcbRevisions,
        revision,
        (item) => item.id == revision.id,
      ),
    );
    return revision;
  }

  @override
  Future<FirmwareBuild> upsertFirmwareBuild(FirmwareBuild build) async {
    _snapshot = _snapshot.copyWith(
      firmwareBuilds: _upsert(
        _snapshot.firmwareBuilds,
        build,
        (item) => item.id == build.id,
      ),
    );
    return build;
  }

  @override
  Future<DeviceNode> upsertDeviceNode(DeviceNode device) async {
    _snapshot = _snapshot.copyWith(
      deviceNodes: _upsert(
        _snapshot.deviceNodes,
        device,
        (item) => item.id == device.id,
      ),
    );
    return device;
  }

  @override
  Future<EngineeringDocument> upsertDocument(
    EngineeringDocument document,
  ) async {
    _snapshot = _snapshot.copyWith(
      documents: _upsert(
        _snapshot.documents,
        document,
        (item) => item.id == document.id,
      ),
    );
    return document;
  }

  @override
  Future<EngineeringAttachment> upsertAttachment(
    EngineeringAttachment attachment,
  ) async {
    _snapshot = _snapshot.copyWith(
      attachments: _upsert(
        _snapshot.attachments,
        attachment,
        (item) => item.id == attachment.id,
      ),
    );
    return attachment;
  }

  @override
  Future<void> exportSnapshot(File destination) async {}

  @override
  Future<EngineeringSnapshot> importSnapshot(File source) async {
    return _snapshot;
  }

  List<T> _upsert<T>(List<T> items, T value, bool Function(T item) matches) {
    final updated = items.toList(growable: true);
    final index = updated.indexWhere(matches);
    if (index >= 0) {
      updated[index] = value;
    } else {
      updated.add(value);
    }
    return updated;
  }
}

EngineeringSnapshot buildEngineeringStudioSnapshot() {
  return EngineeringSnapshot(
    settings: EngineeringModuleSettings.defaults(
      moduleRootPath: 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
    ),
    projects: [
      EngineeringProject(
        id: 'project_microgrow',
        title: 'MicroGrow',
        summary: 'Grow automation, sensors, and field control.',
        status: 'Active',
        priority: 'High',
        progressPercent: 72,
        milestone: 'Stabilise field telemetry',
        nextAction: 'Review the latest sensor routing.',
        system: 'MicroGrow',
        updatedAt: DateTime.utc(2026, 7, 1, 10),
        openTaskCount: 8,
        blockedTaskCount: 1,
        tags: const ['grow', 'telemetry', 'automation'],
        targetDate: DateTime.utc(2026, 8, 15),
      ),
      EngineeringProject(
        id: 'project_biocalm',
        title: 'BioCalm',
        summary: 'Wearable sensing with calm controls.',
        status: 'Active',
        priority: 'High',
        progressPercent: 58,
        milestone: 'Complete prototype board',
        nextAction: 'Review the PCB revision.',
        system: 'BioCalm',
        updatedAt: DateTime.utc(2026, 7, 1, 16),
        openTaskCount: 6,
        blockedTaskCount: 0,
        tags: const ['wearable', 'sensing'],
      ),
      EngineeringProject(
        id: 'project_omega_dashboard',
        title: 'Omega Dashboard',
        summary: 'Command dashboard with local-first modules.',
        status: 'Ready',
        priority: 'Medium',
        progressPercent: 84,
        milestone: 'Prepare production hardening',
        nextAction: 'Add offline import/export.',
        system: 'Omega Dashboard',
        updatedAt: DateTime.utc(2026, 7, 2, 9),
        openTaskCount: 4,
        blockedTaskCount: 0,
        tags: const ['dashboard', 'local-first'],
      ),
    ],
    circuitBlocks: [
      CircuitBlock(
        id: 'circuit_sensor_mesh',
        projectId: 'project_microgrow',
        title: 'Sensor mesh input block',
        category: 'Sensors',
        status: 'Draft',
        progressPercent: 55,
        function: 'Read and normalise field sensor input.',
        nextAction: 'Validate the signal path.',
        knowledgeHookRoute: '/modules/omega-knowledge-engine',
        gaiaHookRoute: '/voice-assistant',
        tags: const ['sensor', 'esp32'],
        notes: 'Local mock block for dashboard coverage.',
      ),
    ],
    pcbRevisions: [
      PCBRevision(
        id: 'pcb_biocalm_a1',
        projectId: 'project_biocalm',
        boardName: 'BioCalm Core',
        revision: 'A1',
        status: 'Fab ready',
        layers: 4,
        progressPercent: 90,
        fabReady: true,
        manufacturingPartner: 'Local Fab Partner',
        nextAction: 'Release fabrication package.',
        tags: const ['pcb', 'fab'],
        notes: 'Ready for manufacturing.',
      ),
    ],
    firmwareBuilds: [
      FirmwareBuild(
        id: 'firmware_biocalm_010',
        projectId: 'project_biocalm',
        targetDevice: 'ESP32 Node',
        version: '0.1.0',
        status: 'Ready',
        progressPercent: 88,
        buildType: 'Release',
        nextAction: 'Tag the build artifact.',
        artifactPath: 'build/firmware/biocalm_010.bin',
        lastBuiltAt: DateTime.utc(2026, 7, 2, 13),
        tags: const ['firmware', 'esp32'],
      ),
    ],
    deviceNodes: [
      DeviceNode(
        id: 'device_field_01',
        projectId: 'project_microgrow',
        name: 'Field Node 01',
        model: 'ESP32 Node',
        status: 'Online',
        health: 'Good',
        firmwareVersion: '0.1.0',
        lastSeenAt: DateTime.utc(2026, 7, 2, 14),
        location: 'Grow bay',
        nextAction: 'Check the next telemetry batch.',
        tags: const ['node', 'field'],
        notes: 'Online and healthy.',
      ),
    ],
    componentItems: [
      ComponentItem(
        id: 'component_sensor_01',
        sku: 'SEN-001',
        name: 'Temperature sensor',
        category: 'Sensors',
        status: 'Available',
        quantityOnHand: 24,
        reorderLevel: 8,
        preferredVendor: 'Omega Supplies',
        storageLocation: 'Bin A1',
        nextAction: 'Allocate to MicroGrow board.',
        tags: const ['sensor', 'inventory'],
        notes: 'Healthy stock.',
        updatedAt: DateTime.utc(2026, 7, 2, 10),
      ),
    ],
    experiments: [
      ExperimentRecord(
        id: 'experiment_growth_curve',
        projectId: 'project_microgrow',
        title: 'Growth curve tuning',
        hypothesis: 'Calmer control windows improve yield stability.',
        status: 'Running',
        progressPercent: 48,
        evidenceCount: 3,
        resultSummary: 'Early data is promising.',
        nextAction: 'Collect one more cycle.',
        startedAt: DateTime.utc(2026, 7, 1),
        tags: const ['lab'],
      ),
    ],
    testProcedures: [
      TestProcedure(
        id: 'test_power_cycle',
        projectId: 'project_biocalm',
        title: 'Power cycle soak test',
        stage: 'Validation',
        status: 'Ready',
        progressPercent: 100,
        owner: 'QA',
        estimatedMinutes: 45,
        nextAction: 'Review pass report.',
        tags: const ['test'],
      ),
    ],
    validationResults: [
      ValidationResult(
        id: 'validation_power_cycle',
        testProcedureId: 'test_power_cycle',
        title: 'Power cycle validation',
        status: 'Pass',
        severity: 'Info',
        verdict: 'Stable under repeated cycles.',
        checkedAt: DateTime.utc(2026, 7, 2, 15),
        evidenceCount: 2,
        summary: 'No regressions detected.',
        nextAction: 'Archive the result.',
      ),
      ValidationResult(
        id: 'validation_noise_floor',
        testProcedureId: 'test_power_cycle',
        title: 'Noise floor validation',
        status: 'Attention',
        severity: 'Medium',
        verdict: 'Needs one more data pass.',
        checkedAt: DateTime.utc(2026, 7, 2, 16),
        evidenceCount: 1,
        summary: 'Signal is slightly variable.',
        nextAction: 'Collect more samples.',
      ),
    ],
    manufacturingSteps: [
      ManufacturingStep(
        id: 'manufacturing_packout',
        projectId: 'project_biocalm',
        title: 'Pack-out sequence',
        stage: 'Packout',
        status: 'Ready',
        progressPercent: 95,
        owner: 'Ops',
        station: 'Station 2',
        nextAction: 'Prepare the final kit.',
        dueLabel: 'This week',
        tags: const ['manufacturing'],
      ),
      ManufacturingStep(
        id: 'manufacturing_review',
        projectId: 'project_microgrow',
        title: 'Assembly review',
        stage: 'Assembly',
        status: 'Blocked',
        progressPercent: 60,
        owner: 'Ops',
        station: 'Station 1',
        nextAction: 'Resolve the parked issue.',
        dueLabel: 'Tomorrow',
        tags: const ['manufacturing', 'blocked'],
      ),
    ],
    documents: [
      EngineeringDocument(
        id: 'doc_biocalm_brief',
        projectId: 'project_biocalm',
        title: 'BioCalm design brief',
        documentType: 'Brief',
        status: 'Draft',
        updatedAt: DateTime.utc(2026, 7, 2, 11),
        summary: 'Living design brief for the BioCalm line.',
        filePath: 'docs/biocalm_design_brief.md',
        tags: const ['doc'],
      ),
    ],
    attachments: [
      EngineeringAttachment(
        id: 'attachment_microgrow_schematic',
        ownerType: 'pcb',
        ownerId: 'pcb_microgrow_a1',
        title: 'MicroGrow schematic',
        kind: 'Schematic',
        filePath: 'assets/engineering/microgrow/schematic.pdf',
        status: 'Linked',
        updatedAt: DateTime.utc(2026, 7, 2, 9, 15),
        notes: 'Primary field sensor schematic.',
        tags: const ['schematic', 'microgrow'],
      ),
      EngineeringAttachment(
        id: 'attachment_biocalm_board',
        ownerType: 'pcb',
        ownerId: 'pcb_biocalm_a1',
        title: 'BioCalm board files',
        kind: 'Board File',
        filePath: 'assets/engineering/biocalm/board.zip',
        status: 'Linked',
        updatedAt: DateTime.utc(2026, 7, 2, 9, 25),
        notes: 'Fabrication package staged locally.',
        tags: const ['board', 'pcb'],
      ),
      EngineeringAttachment(
        id: 'attachment_firmware_release',
        ownerType: 'firmware',
        ownerId: 'firmware_biocalm_010',
        title: 'BioCalm firmware artifact',
        kind: 'Firmware Artifact',
        filePath: 'build/firmware/biocalm_010.bin',
        status: 'Linked',
        updatedAt: DateTime.utc(2026, 7, 2, 13, 10),
        notes: 'Release artifact ready for deployment.',
        tags: const ['firmware', 'artifact'],
      ),
      EngineeringAttachment(
        id: 'attachment_validation_evidence',
        ownerType: 'validation',
        ownerId: 'validation_power_cycle',
        title: 'Power cycle evidence pack',
        kind: 'Validation Evidence',
        filePath: 'docs/evidence/power_cycle_pack.zip',
        status: 'Linked',
        updatedAt: DateTime.utc(2026, 7, 2, 16, 5),
        notes: 'Captured results and logs for the validation pass.',
        tags: const ['evidence', 'validation'],
      ),
    ],
    decisions: [
      EngineeringDecision(
        id: 'decision_microgrow_node',
        projectId: 'project_microgrow',
        title: 'Keep the field node local-first',
        decision: 'Do not add cloud sync for the first release.',
        status: 'Recorded',
        confidence: 'High',
        decidedAt: DateTime.utc(2026, 7, 1, 12),
        rationale: 'The module needs to stay simple and offline-friendly.',
        nextAction: 'Document the offline backup path.',
        tags: const ['decision'],
      ),
    ],
  );
}
