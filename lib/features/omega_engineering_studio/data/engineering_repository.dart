import 'dart:convert';
import 'dart:io';

import 'engineering_database.dart';
import 'package:path/path.dart' as path;

import '../domain/engineering_models.dart';

abstract class EngineeringSnapshotReader {
  Future<EngineeringSnapshot> loadSnapshot();
}

abstract class EngineeringRepository extends EngineeringSnapshotReader {
  Future<void> saveSnapshot(EngineeringSnapshot snapshot);

  Future<void> resetLocalState();

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
  });

  Future<EngineeringProject> updateProject(EngineeringProject project);

  Future<CircuitBlock> upsertCircuitBlock(CircuitBlock block);

  Future<PCBRevision> upsertPcbRevision(PCBRevision revision);

  Future<FirmwareBuild> upsertFirmwareBuild(FirmwareBuild build);

  Future<DeviceNode> upsertDeviceNode(DeviceNode device);

  Future<EngineeringDocument> upsertDocument(EngineeringDocument document);

  Future<EngineeringAttachment> upsertAttachment(
    EngineeringAttachment attachment,
  );

  Future<void> exportSnapshot(File destination);

  Future<EngineeringSnapshot> importSnapshot(File source);
}

class LocalEngineeringRepository implements EngineeringRepository {
  LocalEngineeringRepository({
    this.moduleRootPath = 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE',
    EngineeringLocalDatabase? database,
  }) : _database = database ?? EngineeringLocalDatabase();

  final String moduleRootPath;
  final EngineeringLocalDatabase _database;

  EngineeringSnapshot? _cachedSnapshot;

  @override
  Future<EngineeringSnapshot> loadSnapshot() async {
    final cached = _cachedSnapshot;
    if (cached != null) {
      return cached;
    }

    final settings = EngineeringModuleSettings.defaults(
      moduleRootPath: moduleRootPath,
    );
    final baseSnapshot = EngineeringSnapshot(
      settings: settings,
      projects: _buildProjects(),
      circuitBlocks: _buildCircuitBlocks(),
      pcbRevisions: _buildPcbRevisions(),
      firmwareBuilds: _buildFirmwareBuilds(),
      deviceNodes: _buildDeviceNodes(),
      componentItems: _buildComponentItems(),
      experiments: _buildExperiments(),
      testProcedures: _buildTestProcedures(),
      validationResults: _buildValidationResults(),
      manufacturingSteps: _buildManufacturingSteps(),
      documents: _buildDocuments(),
      attachments: _buildAttachments(),
      decisions: _buildDecisions(),
    );
    final snapshot = await _loadPersistedSnapshot(baseSnapshot);
    _cachedSnapshot = snapshot;
    return snapshot;
  }

  @override
  Future<void> saveSnapshot(EngineeringSnapshot snapshot) async {
    _cachedSnapshot = snapshot;
    await _persistSnapshot(snapshot);
  }

  @override
  Future<void> resetLocalState() async {
    await (_database.delete(
      _database.engineeringSnapshotRecords,
    )..where((table) => table.snapshotId.equals('default'))).go();
    _cachedSnapshot = null;
  }

  Future<EngineeringProject> upsertProject(EngineeringProject project) async {
    final snapshot = await loadSnapshot();
    final updated = snapshot.projects.toList(growable: true);
    final index = updated.indexWhere((item) => item.id == project.id);
    if (index >= 0) {
      updated[index] = project;
    } else {
      updated.add(project);
    }
    await saveSnapshot(snapshot.copyWith(projects: updated));
    return project;
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
    List<String> tags = const [],
  }) async {
    final project = EngineeringProject(
      id: 'project_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      summary: summary.trim(),
      status: status,
      priority: priority,
      progressPercent: progressPercent.clamp(0, 100),
      milestone: milestone.trim(),
      nextAction: nextAction.trim(),
      system: system.trim(),
      updatedAt: DateTime.now().toUtc(),
      openTaskCount: 0,
      blockedTaskCount: 0,
      tags: tags,
      targetDate: targetDate,
    );
    return upsertProject(project);
  }

  @override
  Future<EngineeringProject> updateProject(EngineeringProject project) {
    return upsertProject(
      EngineeringProject(
        id: project.id,
        title: project.title.trim(),
        summary: project.summary.trim(),
        status: project.status,
        priority: project.priority,
        progressPercent: project.progressPercent.clamp(0, 100),
        milestone: project.milestone.trim(),
        nextAction: project.nextAction.trim(),
        system: project.system.trim(),
        updatedAt: DateTime.now().toUtc(),
        openTaskCount: project.openTaskCount,
        blockedTaskCount: project.blockedTaskCount,
        tags: project.tags,
        targetDate: project.targetDate,
      ),
    );
  }

  @override
  Future<CircuitBlock> upsertCircuitBlock(CircuitBlock block) async {
    final snapshot = await loadSnapshot();
    final updated = snapshot.circuitBlocks.toList(growable: true);
    final index = updated.indexWhere((item) => item.id == block.id);
    if (index >= 0) {
      updated[index] = block;
    } else {
      updated.add(block);
    }
    await saveSnapshot(snapshot.copyWith(circuitBlocks: updated));
    return block;
  }

  @override
  Future<PCBRevision> upsertPcbRevision(PCBRevision revision) async {
    final snapshot = await loadSnapshot();
    final updated = snapshot.pcbRevisions.toList(growable: true);
    final index = updated.indexWhere((item) => item.id == revision.id);
    if (index >= 0) {
      updated[index] = revision;
    } else {
      updated.add(revision);
    }
    await saveSnapshot(snapshot.copyWith(pcbRevisions: updated));
    return revision;
  }

  @override
  Future<FirmwareBuild> upsertFirmwareBuild(FirmwareBuild build) async {
    final snapshot = await loadSnapshot();
    final updated = snapshot.firmwareBuilds.toList(growable: true);
    final index = updated.indexWhere((item) => item.id == build.id);
    if (index >= 0) {
      updated[index] = build;
    } else {
      updated.add(build);
    }
    await saveSnapshot(snapshot.copyWith(firmwareBuilds: updated));
    return build;
  }

  @override
  Future<DeviceNode> upsertDeviceNode(DeviceNode device) async {
    final snapshot = await loadSnapshot();
    final updated = snapshot.deviceNodes.toList(growable: true);
    final index = updated.indexWhere((item) => item.id == device.id);
    if (index >= 0) {
      updated[index] = device;
    } else {
      updated.add(device);
    }
    await saveSnapshot(snapshot.copyWith(deviceNodes: updated));
    return device;
  }

  @override
  Future<EngineeringDocument> upsertDocument(
    EngineeringDocument document,
  ) async {
    final snapshot = await loadSnapshot();
    final updated = snapshot.documents.toList(growable: true);
    final index = updated.indexWhere((item) => item.id == document.id);
    if (index >= 0) {
      updated[index] = document;
    } else {
      updated.add(document);
    }
    await saveSnapshot(snapshot.copyWith(documents: updated));
    return document;
  }

  @override
  Future<EngineeringAttachment> upsertAttachment(
    EngineeringAttachment attachment,
  ) async {
    final snapshot = await loadSnapshot();
    final updated = snapshot.attachments.toList(growable: true);
    final index = updated.indexWhere((item) => item.id == attachment.id);
    if (index >= 0) {
      updated[index] = attachment;
    } else {
      updated.add(attachment);
    }
    await saveSnapshot(snapshot.copyWith(attachments: updated));
    return attachment;
  }

  @override
  Future<void> exportSnapshot(File destination) async {
    final snapshot = await loadSnapshot();
    final payload = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'snapshot': _snapshotToJson(snapshot),
    };
    await destination.parent.create(recursive: true);
    await destination.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  @override
  Future<EngineeringSnapshot> importSnapshot(File source) async {
    final raw = await source.readAsString();
    final decoded = jsonDecode(raw);
    final map = decoded is Map<String, dynamic>
        ? decoded
        : decoded is Map
        ? decoded.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
    final snapshotData = map['snapshot'];
    if (snapshotData is! Map) {
      throw FormatException('Invalid engineering snapshot file.');
    }
    final snapshotMap = snapshotData.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final snapshot = _snapshotFromJson(snapshotMap);
    await saveSnapshot(snapshot);
    return snapshot;
  }

  Future<EngineeringSnapshot> _loadPersistedSnapshot(
    EngineeringSnapshot snapshot,
  ) async {
    final row =
        await (_database.select(_database.engineeringSnapshotRecords)
              ..where((table) => table.snapshotId.equals('default'))
              ..limit(1))
            .getSingleOrNull();

    if (row == null) {
      await _persistSnapshot(snapshot);
      return snapshot;
    }

    try {
      final decoded = jsonDecode(row.payload);
      final map = decoded is Map<String, dynamic>
          ? decoded
          : decoded is Map
          ? decoded.map((key, value) => MapEntry(key.toString(), value))
          : null;
      if (map == null) {
        return snapshot;
      }

      return snapshot.copyWith(
        settings: _settingsFromJson(map['settings']) ?? snapshot.settings,
        projects: _projectsFromJson(map['projects']) ?? snapshot.projects,
        circuitBlocks:
            _circuitBlocksFromJson(map['circuitBlocks']) ??
            snapshot.circuitBlocks,
        pcbRevisions:
            _pcbRevisionsFromJson(map['pcbRevisions']) ?? snapshot.pcbRevisions,
        firmwareBuilds:
            _firmwareBuildsFromJson(map['firmwareBuilds']) ??
            snapshot.firmwareBuilds,
        deviceNodes:
            _deviceNodesFromJson(map['deviceNodes']) ?? snapshot.deviceNodes,
        componentItems:
            _componentItemsFromJson(map['componentItems']) ??
            snapshot.componentItems,
        experiments:
            _experimentsFromJson(map['experiments']) ?? snapshot.experiments,
        testProcedures:
            _testProceduresFromJson(map['testProcedures']) ??
            snapshot.testProcedures,
        validationResults:
            _validationResultsFromJson(map['validationResults']) ??
            snapshot.validationResults,
        manufacturingSteps:
            _manufacturingStepsFromJson(map['manufacturingSteps']) ??
            snapshot.manufacturingSteps,
        documents: _documentsFromJson(map['documents']) ?? snapshot.documents,
        attachments:
            _attachmentsFromJson(map['attachments']) ?? snapshot.attachments,
        decisions: _decisionsFromJson(map['decisions']) ?? snapshot.decisions,
      );
    } catch (_) {
      return snapshot;
    }
  }

  Future<void> _persistSnapshot(EngineeringSnapshot snapshot) async {
    final payload = _snapshotToJson(snapshot);

    await (_database.into(
      _database.engineeringSnapshotRecords,
    )).insertOnConflictUpdate(
      EngineeringSnapshotRecordsCompanion.insert(
        snapshotId: 'default',
        payload: const JsonEncoder.withIndent('  ').convert(payload),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Map<String, dynamic> _snapshotToJson(EngineeringSnapshot snapshot) {
    return {
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': snapshot.settings.toJson(),
      'projects': snapshot.projects
          .map((item) => item.toJson())
          .toList(growable: false),
      'circuitBlocks': snapshot.circuitBlocks
          .map((item) => item.toJson())
          .toList(growable: false),
      'pcbRevisions': snapshot.pcbRevisions
          .map((item) => item.toJson())
          .toList(growable: false),
      'firmwareBuilds': snapshot.firmwareBuilds
          .map((item) => item.toJson())
          .toList(growable: false),
      'deviceNodes': snapshot.deviceNodes
          .map((item) => item.toJson())
          .toList(growable: false),
      'componentItems': snapshot.componentItems
          .map((item) => item.toJson())
          .toList(growable: false),
      'experiments': snapshot.experiments
          .map((item) => item.toJson())
          .toList(growable: false),
      'testProcedures': snapshot.testProcedures
          .map((item) => item.toJson())
          .toList(growable: false),
      'validationResults': snapshot.validationResults
          .map((item) => item.toJson())
          .toList(growable: false),
      'manufacturingSteps': snapshot.manufacturingSteps
          .map((item) => item.toJson())
          .toList(growable: false),
      'documents': snapshot.documents
          .map((item) => item.toJson())
          .toList(growable: false),
      'attachments': snapshot.attachments
          .map((item) => item.toJson())
          .toList(growable: false),
      'decisions': snapshot.decisions
          .map((item) => item.toJson())
          .toList(growable: false),
    };
  }

  EngineeringSnapshot _snapshotFromJson(Map<String, dynamic> json) {
    return EngineeringSnapshot(
      settings:
          _settingsFromJson(json['settings']) ??
          EngineeringModuleSettings.defaults(moduleRootPath: moduleRootPath),
      projects: _projectsFromJson(json['projects']) ?? _buildProjects(),
      circuitBlocks:
          _circuitBlocksFromJson(json['circuitBlocks']) ??
          _buildCircuitBlocks(),
      pcbRevisions:
          _pcbRevisionsFromJson(json['pcbRevisions']) ?? _buildPcbRevisions(),
      firmwareBuilds:
          _firmwareBuildsFromJson(json['firmwareBuilds']) ??
          _buildFirmwareBuilds(),
      deviceNodes:
          _deviceNodesFromJson(json['deviceNodes']) ?? _buildDeviceNodes(),
      componentItems:
          _componentItemsFromJson(json['componentItems']) ??
          _buildComponentItems(),
      experiments:
          _experimentsFromJson(json['experiments']) ?? _buildExperiments(),
      testProcedures:
          _testProceduresFromJson(json['testProcedures']) ??
          _buildTestProcedures(),
      validationResults:
          _validationResultsFromJson(json['validationResults']) ??
          _buildValidationResults(),
      manufacturingSteps:
          _manufacturingStepsFromJson(json['manufacturingSteps']) ??
          _buildManufacturingSteps(),
      documents: _documentsFromJson(json['documents']) ?? _buildDocuments(),
      attachments:
          _attachmentsFromJson(json['attachments']) ?? _buildAttachments(),
      decisions: _decisionsFromJson(json['decisions']) ?? _buildDecisions(),
    );
  }

  List<EngineeringProject> _buildProjects() {
    return [
      EngineeringProject.fromJson(
        _project(
          id: 'project_microgrow',
          title: 'MicroGrow',
          summary:
              'Grow automation, sensor orchestration, and safe field telemetry.',
          status: 'Active',
          priority: 'High',
          progressPercent: 72,
          milestone: 'Stabilise the field scanner and sensor routing.',
          nextAction:
              'Validate sensor telemetry against the latest field node.',
          system: 'MicroGrow',
          updatedAt: DateTime.utc(2026, 7, 2, 10, 15),
          openTaskCount: 8,
          blockedTaskCount: 1,
          tags: ['grow', 'telemetry', 'automation'],
          targetDate: DateTime.utc(2026, 8, 15),
        ),
      ),
      EngineeringProject.fromJson(
        _project(
          id: 'project_biocalm',
          title: 'BioCalm',
          summary:
              'Calm wearable sensing, ergonomics, and low-noise control loops.',
          status: 'Active',
          priority: 'High',
          progressPercent: 58,
          milestone: 'Complete the prototype board and comfort check.',
          nextAction:
              'Review the latest PCB revision before enclosure fit tests.',
          system: 'BioCalm',
          updatedAt: DateTime.utc(2026, 7, 1, 16, 42),
          openTaskCount: 6,
          blockedTaskCount: 0,
          tags: ['wearable', 'sensing', 'calm'],
          targetDate: DateTime.utc(2026, 8, 28),
        ),
      ),
      EngineeringProject.fromJson(
        _project(
          id: 'project_living',
          title: 'New Earth Living',
          summary:
              'Ambient systems for a calmer home and practical living support.',
          status: 'Paused',
          priority: 'Medium',
          progressPercent: 41,
          milestone:
              'Reduce the control surface into one stable living dashboard.',
          nextAction:
              'Park non-essential wiring and define the smallest usable board set.',
          system: 'New Earth Living',
          updatedAt: DateTime.utc(2026, 6, 29, 9, 5),
          openTaskCount: 4,
          blockedTaskCount: 1,
          tags: ['living', 'ambient', 'dashboard'],
          targetDate: DateTime.utc(2026, 9, 18),
        ),
      ),
      EngineeringProject.fromJson(
        _project(
          id: 'project_omega_dashboard',
          title: 'Omega Dashboard',
          summary:
              'The control centre shell for modules, telemetry, and calm operations.',
          status: 'Active',
          priority: 'High',
          progressPercent: 66,
          milestone: 'Align engineering workspace navigation and data hooks.',
          nextAction: 'Connect the engineering studio to the module registry.',
          system: 'Omega Dashboard',
          updatedAt: DateTime.utc(2026, 7, 2, 8, 35),
          openTaskCount: 5,
          blockedTaskCount: 0,
          tags: ['dashboard', 'platform', 'navigation'],
          targetDate: DateTime.utc(2026, 8, 5),
        ),
      ),
      EngineeringProject.fromJson(
        _project(
          id: 'project_field_nodes',
          title: 'ESP32 Field Nodes',
          summary:
              'Distributed sensor nodes for garden, workshop, and prototype telemetry.',
          status: 'Ready',
          priority: 'Medium',
          progressPercent: 84,
          milestone: 'Field deploy-ready firmware and enclosure checks.',
          nextAction: 'Run battery and radio validation before release.',
          system: 'ESP32 Nodes',
          updatedAt: DateTime.utc(2026, 7, 2, 14, 12),
          openTaskCount: 3,
          blockedTaskCount: 0,
          tags: ['esp32', 'sensors', 'field'],
          targetDate: DateTime.utc(2026, 7, 20),
        ),
      ),
    ];
  }

  List<CircuitBlock> _buildCircuitBlocks() {
    return [
      CircuitBlock.fromJson(
        _circuitBlock(
          id: 'circuit_power',
          projectId: 'project_microgrow',
          title: 'Power Regulation Block',
          category: 'Power',
          status: 'Ready',
          progressPercent: 88,
          function: 'Stable buck regulation and battery-safe cutover.',
          nextAction: 'Check thermal margin with the latest enclosure draft.',
          knowledgeHookRoute: '/modules/omega-knowledge-engine',
          gaiaHookRoute: '/voice-assistant',
          tags: ['power', 'regulation', 'battery'],
          notes: 'Keep traces short and protect the sensor rail.',
        ),
      ),
      CircuitBlock.fromJson(
        _circuitBlock(
          id: 'circuit_sensor',
          projectId: 'project_biocalm',
          title: 'Sensor Ingress Block',
          category: 'Sensors',
          status: 'Active',
          progressPercent: 74,
          function: 'Low-noise reading for skin-contact and motion sensors.',
          nextAction: 'Confirm filtering still behaves at motion peaks.',
          knowledgeHookRoute: '/modules/omega-knowledge-engine',
          gaiaHookRoute: '/voice-assistant',
          tags: ['sensor', 'low-noise', 'filter'],
          notes: 'Use calm board routing and shielded lines where possible.',
        ),
      ),
      CircuitBlock.fromJson(
        _circuitBlock(
          id: 'circuit_radio',
          projectId: 'project_field_nodes',
          title: 'Wireless Link Block',
          category: 'Comms',
          status: 'Ready',
          progressPercent: 91,
          function: 'ESP-NOW and Wi-Fi bridge path for field telemetry.',
          nextAction: 'Document the final pairing flow for deployment.',
          knowledgeHookRoute: '/modules/omega-knowledge-engine',
          gaiaHookRoute: '/voice-assistant',
          tags: ['radio', 'esp-now', 'bridge'],
          notes: 'Verify antenna keepout on the board edge.',
        ),
      ),
      CircuitBlock.fromJson(
        _circuitBlock(
          id: 'circuit_control',
          projectId: 'project_omega_dashboard',
          title: 'Control Plane Block',
          category: 'Control',
          status: 'Drafting',
          progressPercent: 56,
          function: 'Dashboard command ingress and local action dispatch.',
          nextAction: 'Align route hooks with the module registry.',
          knowledgeHookRoute: '/modules/omega-knowledge-engine',
          gaiaHookRoute: '/voice-assistant',
          tags: ['control', 'routing', 'module'],
          notes: 'Keep this block thin and easy to swap later.',
        ),
      ),
    ];
  }

  List<PCBRevision> _buildPcbRevisions() {
    return [
      PCBRevision.fromJson(
        _pcbRevision(
          id: 'pcb_microgrow_a',
          projectId: 'project_microgrow',
          boardName: 'MicroGrow Field Scanner',
          revision: 'Rev A',
          status: 'Fab Ready',
          layers: 4,
          progressPercent: 95,
          fabReady: true,
          manufacturingPartner: 'Local prototype house',
          nextAction: 'Release package for first pilot build.',
          tags: ['microgrow', 'fab', 'field'],
          notes: 'Check silkscreen readability for low-light field use.',
        ),
      ),
      PCBRevision.fromJson(
        _pcbRevision(
          id: 'pcb_biocalm_b',
          projectId: 'project_biocalm',
          boardName: 'BioCalm Core Board',
          revision: 'Rev B',
          status: 'Review',
          layers: 6,
          progressPercent: 76,
          fabReady: false,
          manufacturingPartner: 'Local prototype house',
          nextAction: 'Close the final analogue ground review.',
          tags: ['biocalm', 'wearable', 'review'],
          notes: 'Keep the comfort envelope compact.',
        ),
      ),
      PCBRevision.fromJson(
        _pcbRevision(
          id: 'pcb_omega_dashboard_c',
          projectId: 'project_omega_dashboard',
          boardName: 'Omega Dashboard Control Board',
          revision: 'Rev C',
          status: 'Prototype',
          layers: 4,
          progressPercent: 64,
          fabReady: false,
          manufacturingPartner: 'In-house test rig',
          nextAction: 'Validate the debug header and power LED logic.',
          tags: ['dashboard', 'control', 'prototype'],
          notes: 'Keep connector spacing friendly for hand assembly.',
        ),
      ),
      PCBRevision.fromJson(
        _pcbRevision(
          id: 'pcb_field_node_a',
          projectId: 'project_field_nodes',
          boardName: 'ESP32 Field Node',
          revision: 'Rev A',
          status: 'Fab Ready',
          layers: 2,
          progressPercent: 89,
          fabReady: true,
          manufacturingPartner: 'Local prototype house',
          nextAction: 'Approve the pack for the next batch.',
          tags: ['esp32', 'field', 'node'],
          notes: 'Battery and sensor header layout is stable.',
        ),
      ),
    ];
  }

  List<FirmwareBuild> _buildFirmwareBuilds() {
    return [
      FirmwareBuild.fromJson(
        _firmwareBuild(
          id: 'firmware_microgrow_main',
          projectId: 'project_microgrow',
          targetDevice: 'ESP32 MicroGrow node',
          version: '1.4.2',
          status: 'Ready',
          progressPercent: 93,
          buildType: 'Release',
          nextAction: 'Ship the signed binary with the pilot pack.',
          artifactPath: 'artifacts/microgrow/main.bin',
          lastBuiltAt: DateTime.utc(2026, 7, 2, 9, 10),
          tags: ['release', 'microgrow', 'binary'],
        ),
      ),
      FirmwareBuild.fromJson(
        _firmwareBuild(
          id: 'firmware_biocalm_probe',
          projectId: 'project_biocalm',
          targetDevice: 'BioCalm probe board',
          version: '0.9.8',
          status: 'Testing',
          progressPercent: 71,
          buildType: 'Debug',
          nextAction: 'Run a long-session comfort soak test.',
          artifactPath: 'artifacts/biocalm/probe-debug.bin',
          lastBuiltAt: DateTime.utc(2026, 7, 1, 18, 45),
          tags: ['debug', 'wearable', 'test'],
        ),
      ),
      FirmwareBuild.fromJson(
        _firmwareBuild(
          id: 'firmware_field_node',
          projectId: 'project_field_nodes',
          targetDevice: 'ESP32 field node',
          version: '2.0.0',
          status: 'Ready',
          progressPercent: 97,
          buildType: 'Release',
          nextAction: 'Tag the build for the next deployment ring.',
          artifactPath: 'artifacts/field-node/release.bin',
          lastBuiltAt: DateTime.utc(2026, 7, 2, 13, 0),
          tags: ['field', 'esp32', 'release'],
        ),
      ),
      FirmwareBuild.fromJson(
        _firmwareBuild(
          id: 'firmware_dashboard_bridge',
          projectId: 'project_omega_dashboard',
          targetDevice: 'Omega Dashboard bridge board',
          version: '0.8.1',
          status: 'Drafting',
          progressPercent: 52,
          buildType: 'Internal',
          nextAction: 'Wire the route callbacks into the bridge layer.',
          artifactPath: 'artifacts/dashboard/bridge.bin',
          lastBuiltAt: DateTime.utc(2026, 6, 30, 11, 25),
          tags: ['dashboard', 'bridge', 'internal'],
        ),
      ),
    ];
  }

  List<DeviceNode> _buildDeviceNodes() {
    return [
      DeviceNode.fromJson(
        _deviceNode(
          id: 'device_kitchen_node',
          projectId: 'project_living',
          name: 'Kitchen ambient node',
          model: 'ESP32-WROOM',
          status: 'Online',
          health: 'Healthy',
          firmwareVersion: '1.2.0',
          lastSeenAt: DateTime.utc(2026, 7, 3, 8, 10),
          location: 'Kitchen',
          nextAction: 'Keep monitoring temperature drift.',
          tags: ['ambient', 'living', 'sensor'],
          notes: 'Stable on the current power profile.',
        ),
      ),
      DeviceNode.fromJson(
        _deviceNode(
          id: 'device_field_node_a',
          projectId: 'project_field_nodes',
          name: 'Field node A',
          model: 'ESP32-S3',
          status: 'Online',
          health: 'Healthy',
          firmwareVersion: '2.0.0',
          lastSeenAt: DateTime.utc(2026, 7, 3, 9, 42),
          location: 'Greenhouse',
          nextAction: 'Confirm battery endurance after the next cycle.',
          tags: ['field', 'greenhouse', 'esp32'],
          notes: 'Telemetry link is solid.',
        ),
      ),
      DeviceNode.fromJson(
        _deviceNode(
          id: 'device_biocalm_prototype',
          projectId: 'project_biocalm',
          name: 'BioCalm prototype board',
          model: 'Custom wearable board',
          status: 'Attention',
          health: 'Needs review',
          firmwareVersion: '0.9.8',
          lastSeenAt: DateTime.utc(2026, 7, 2, 17, 20),
          location: 'Bench A',
          nextAction: 'Re-run the comfort and motion test.',
          tags: ['wearable', 'prototype', 'bench'],
          notes: 'Sensor drift needs one more check.',
        ),
      ),
      DeviceNode.fromJson(
        _deviceNode(
          id: 'device_dashboard_bridge',
          projectId: 'project_omega_dashboard',
          name: 'Dashboard bridge board',
          model: 'ESP32-S3',
          status: 'Maintenance',
          health: 'Calm',
          firmwareVersion: '0.8.1',
          lastSeenAt: DateTime.utc(2026, 7, 1, 14, 3),
          location: 'Workbench',
          nextAction: 'Complete route hook verification.',
          tags: ['dashboard', 'bridge', 'workbench'],
          notes: 'Used for module and telemetry experiments.',
        ),
      ),
      DeviceNode.fromJson(
        _deviceNode(
          id: 'device_storage_probe',
          projectId: 'project_living',
          name: 'Storage humidity probe',
          model: 'ESP32-C3',
          status: 'Offline',
          health: 'Needs attention',
          firmwareVersion: '1.0.4',
          lastSeenAt: DateTime.utc(2026, 6, 28, 7, 55),
          location: 'Storage',
          nextAction: 'Check power cable and resume telemetry.',
          tags: ['probe', 'storage', 'humidity'],
          notes: 'Likely a loose connector.',
        ),
      ),
    ];
  }

  List<ComponentItem> _buildComponentItems() {
    return [
      ComponentItem.fromJson(
        _componentItem(
          id: 'component_esp32_s3',
          sku: 'MCU-ESP32-S3',
          name: 'ESP32-S3 module',
          category: 'Compute',
          status: 'Available',
          quantityOnHand: 12,
          reorderLevel: 4,
          preferredVendor: 'Local electronics supplier',
          storageLocation: 'Shelf A2',
          nextAction: 'Reserve for the next field node batch.',
          tags: ['esp32', 'mcu'],
          notes: 'Good stock for the current run.',
          updatedAt: DateTime.utc(2026, 7, 2, 12, 0),
        ),
      ),
      ComponentItem.fromJson(
        _componentItem(
          id: 'component_temperature_sensor',
          sku: 'SNS-TH-01',
          name: 'Temperature and humidity sensor',
          category: 'Sensors',
          status: 'Available',
          quantityOnHand: 6,
          reorderLevel: 5,
          preferredVendor: 'Local electronics supplier',
          storageLocation: 'Shelf B1',
          nextAction: 'Allocate two units to BioCalm testing.',
          tags: ['sensor', 'humidity', 'temp'],
          notes: 'Stock is healthy but close to reorder threshold.',
          updatedAt: DateTime.utc(2026, 7, 2, 11, 20),
        ),
      ),
      ComponentItem.fromJson(
        _componentItem(
          id: 'component_buck_converter',
          sku: 'PWR-BUCK-05',
          name: '5V buck converter',
          category: 'Power',
          status: 'Low stock',
          quantityOnHand: 3,
          reorderLevel: 5,
          preferredVendor: 'Local electronics supplier',
          storageLocation: 'Shelf C3',
          nextAction: 'Reorder before the next MicroGrow batch.',
          tags: ['power', 'regulation'],
          notes: 'This part is below the comfort threshold.',
          updatedAt: DateTime.utc(2026, 7, 1, 9, 15),
        ),
      ),
      ComponentItem.fromJson(
        _componentItem(
          id: 'component_battery_holder',
          sku: 'PWR-BAT-HOLD',
          name: 'Battery holder',
          category: 'Power',
          status: 'Available',
          quantityOnHand: 9,
          reorderLevel: 3,
          preferredVendor: 'Local electronics supplier',
          storageLocation: 'Shelf C1',
          nextAction: 'Use in the next field node bundle.',
          tags: ['battery', 'holder'],
          notes: 'No immediate action needed.',
          updatedAt: DateTime.utc(2026, 7, 1, 10, 0),
        ),
      ),
      ComponentItem.fromJson(
        _componentItem(
          id: 'component_header_pack',
          sku: 'CONN-HDR-20',
          name: '20-pin header pack',
          category: 'Connectors',
          status: 'Critical',
          quantityOnHand: 2,
          reorderLevel: 6,
          preferredVendor: 'Local electronics supplier',
          storageLocation: 'Drawer D4',
          nextAction: 'Reorder before board assembly starts.',
          tags: ['connectors', 'headers'],
          notes: 'Keep a spare pack aside for experiments.',
          updatedAt: DateTime.utc(2026, 6, 30, 15, 12),
        ),
      ),
      ComponentItem.fromJson(
        _componentItem(
          id: 'component_esp_now_antenna',
          sku: 'RF-ANT-01',
          name: 'Compact antenna',
          category: 'Wireless',
          status: 'Available',
          quantityOnHand: 5,
          reorderLevel: 2,
          preferredVendor: 'Local electronics supplier',
          storageLocation: 'Shelf B4',
          nextAction: 'Assign to field nodes and dashboard bridge tests.',
          tags: ['radio', 'antenna'],
          notes: 'Track placement alongside enclosure changes.',
          updatedAt: DateTime.utc(2026, 6, 29, 18, 30),
        ),
      ),
    ];
  }

  List<ExperimentRecord> _buildExperiments() {
    return [
      ExperimentRecord.fromJson(
        _experiment(
          id: 'experiment_microgrow_noise',
          projectId: 'project_microgrow',
          title: 'Sensor noise baseline',
          hypothesis: 'Noise stays stable when the enclosure is sealed.',
          status: 'Running',
          progressPercent: 66,
          evidenceCount: 4,
          resultSummary:
              'Noise remains acceptable but spikes during pump start.',
          nextAction: 'Cross-check pump start timing with telemetry logs.',
          startedAt: DateTime.utc(2026, 7, 1, 9, 0),
          tags: ['noise', 'sensor', 'baseline'],
        ),
      ),
      ExperimentRecord.fromJson(
        _experiment(
          id: 'experiment_biocalm_comfort',
          projectId: 'project_biocalm',
          title: 'Wearable comfort soak',
          hypothesis: 'Comfort remains high after a long session.',
          status: 'Planned',
          progressPercent: 28,
          evidenceCount: 1,
          resultSummary:
              'Initial notes point to strap pressure as the main concern.',
          nextAction: 'Prepare a longer test with pressure markers.',
          startedAt: DateTime.utc(2026, 7, 3, 7, 30),
          tags: ['comfort', 'wearable', 'soak'],
        ),
      ),
      ExperimentRecord.fromJson(
        _experiment(
          id: 'experiment_field_radio',
          projectId: 'project_field_nodes',
          title: 'Field radio range',
          hypothesis: 'The node maintains a stable link across the greenhouse.',
          status: 'Complete',
          progressPercent: 100,
          evidenceCount: 7,
          resultSummary: 'Range is sufficient for all planned placements.',
          nextAction: 'Archive the notes and prepare deployment guidance.',
          startedAt: DateTime.utc(2026, 6, 30, 11, 0),
          tags: ['radio', 'range', 'field'],
        ),
      ),
      ExperimentRecord.fromJson(
        _experiment(
          id: 'experiment_dashboard_hook',
          projectId: 'project_omega_dashboard',
          title: 'Route hook test',
          hypothesis:
              'Dashboard module hooks stay stable under local navigation.',
          status: 'Running',
          progressPercent: 44,
          evidenceCount: 3,
          resultSummary:
              'Navigation works, but the section switcher needs calmer labels.',
          nextAction:
              'Refine the workspace entry points and verify handoff flow.',
          startedAt: DateTime.utc(2026, 7, 2, 16, 10),
          tags: ['routing', 'dashboard', 'hook'],
        ),
      ),
    ];
  }

  List<TestProcedure> _buildTestProcedures() {
    return [
      TestProcedure.fromJson(
        _testProcedure(
          id: 'test_boot_smoke',
          projectId: 'project_omega_dashboard',
          title: 'Boot smoke test',
          stage: 'Platform',
          status: 'Ready',
          progressPercent: 92,
          owner: 'Dashboard team',
          estimatedMinutes: 20,
          nextAction: 'Run on the next local build.',
          tags: ['boot', 'smoke', 'platform'],
        ),
      ),
      TestProcedure.fromJson(
        _testProcedure(
          id: 'test_sensor_calibration',
          projectId: 'project_microgrow',
          title: 'Sensor calibration',
          stage: 'Calibration',
          status: 'Running',
          progressPercent: 65,
          owner: 'MicroGrow team',
          estimatedMinutes: 35,
          nextAction: 'Capture a stable baseline at midday.',
          tags: ['sensor', 'calibration'],
        ),
      ),
      TestProcedure.fromJson(
        _testProcedure(
          id: 'test_power_stability',
          projectId: 'project_living',
          title: 'Power stability check',
          stage: 'Reliability',
          status: 'Blocked',
          progressPercent: 40,
          owner: 'Living systems',
          estimatedMinutes: 30,
          nextAction: 'Replace the temporary regulator on the bench.',
          tags: ['power', 'stability'],
        ),
      ),
      TestProcedure.fromJson(
        _testProcedure(
          id: 'test_enclosure_fit',
          projectId: 'project_biocalm',
          title: 'Enclosure fit test',
          stage: 'Mechanical',
          status: 'Planned',
          progressPercent: 18,
          owner: 'BioCalm team',
          estimatedMinutes: 25,
          nextAction: 'Cut the foam mock and review strap routing.',
          tags: ['enclosure', 'fit'],
        ),
      ),
    ];
  }

  List<ValidationResult> _buildValidationResults() {
    return [
      ValidationResult.fromJson(
        _validationResult(
          id: 'validation_boot_smoke',
          testProcedureId: 'test_boot_smoke',
          title: 'Boot smoke approval',
          status: 'Pass',
          severity: 'Info',
          verdict: 'Stable boot and clean module registration.',
          checkedAt: DateTime.utc(2026, 7, 2, 15, 40),
          evidenceCount: 4,
          summary: 'The core shell starts cleanly with no routing regressions.',
          nextAction: 'Keep watching for regressions when more routes land.',
        ),
      ),
      ValidationResult.fromJson(
        _validationResult(
          id: 'validation_power',
          testProcedureId: 'test_power_stability',
          title: 'Power stability review',
          status: 'Attention',
          severity: 'Warning',
          verdict: 'The bench regulator drifts under long idle load.',
          checkedAt: DateTime.utc(2026, 7, 1, 17, 5),
          evidenceCount: 2,
          summary: 'This needs one more calm pass before release.',
          nextAction: 'Swap the temporary regulator and rerun the test.',
        ),
      ),
      ValidationResult.fromJson(
        _validationResult(
          id: 'validation_radio',
          testProcedureId: 'test_sensor_calibration',
          title: 'Sensor calibration verdict',
          status: 'Pass',
          severity: 'Info',
          verdict: 'Radio and sensor calibration are inside tolerance.',
          checkedAt: DateTime.utc(2026, 7, 2, 11, 20),
          evidenceCount: 5,
          summary: 'Calibration drift is within the acceptable band.',
          nextAction: 'Document the calibration flow for the field pack.',
        ),
      ),
    ];
  }

  List<ManufacturingStep> _buildManufacturingSteps() {
    return [
      ManufacturingStep.fromJson(
        _manufacturingStep(
          id: 'manufacturing_bom_freeze',
          projectId: 'project_microgrow',
          title: 'Freeze BOM and assembly pack',
          stage: 'Planning',
          status: 'Ready',
          progressPercent: 90,
          owner: 'MicroGrow team',
          station: 'Pre-build review',
          nextAction: 'Release the pack for assembly.',
          dueLabel: 'This week',
          tags: ['bom', 'planning'],
        ),
      ),
      ManufacturingStep.fromJson(
        _manufacturingStep(
          id: 'manufacturing_pick_place',
          projectId: 'project_field_nodes',
          title: 'Pick and place run',
          stage: 'Assembly',
          status: 'Queued',
          progressPercent: 36,
          owner: 'Field node batch',
          station: 'Assembly bench',
          nextAction: 'Prep the stencil and feeder list.',
          dueLabel: 'Next slot',
          tags: ['assembly', 'pnp'],
        ),
      ),
      ManufacturingStep.fromJson(
        _manufacturingStep(
          id: 'manufacturing_final_qa',
          projectId: 'project_biocalm',
          title: 'Final QA review',
          stage: 'Quality',
          status: 'Running',
          progressPercent: 58,
          owner: 'BioCalm team',
          station: 'QA bench',
          nextAction: 'Repeat the comfort fit inspection.',
          dueLabel: 'Today',
          tags: ['qa', 'quality'],
        ),
      ),
      ManufacturingStep.fromJson(
        _manufacturingStep(
          id: 'manufacturing_packout',
          projectId: 'project_living',
          title: 'Field pack-out',
          stage: 'Shipping',
          status: 'Blocked',
          progressPercent: 22,
          owner: 'Living systems',
          station: 'Packing table',
          nextAction: 'Resolve the power stability issue first.',
          dueLabel: 'Parked',
          tags: ['packout', 'shipping'],
        ),
      ),
    ];
  }

  List<EngineeringDocument> _buildDocuments() {
    return [
      EngineeringDocument.fromJson(
        _document(
          id: 'document_architecture_notes',
          projectId: 'project_omega_dashboard',
          title: 'Engineering architecture notes',
          documentType: 'Architecture',
          status: 'Ready',
          updatedAt: DateTime.utc(2026, 7, 2, 12, 40),
          summary: 'Defines the feature-first structure and route hooks.',
          filePath: 'docs/engineering/architecture.md',
          tags: ['architecture', 'routes'],
        ),
      ),
      EngineeringDocument.fromJson(
        _document(
          id: 'document_field_wiring',
          projectId: 'project_microgrow',
          title: 'Field wiring guide',
          documentType: 'Guide',
          status: 'Draft',
          updatedAt: DateTime.utc(2026, 7, 1, 11, 15),
          summary: 'Keeps wiring steps calm and repeatable.',
          filePath: 'docs/engineering/microgrow_wiring.md',
          tags: ['wiring', 'field'],
        ),
      ),
      EngineeringDocument.fromJson(
        _document(
          id: 'document_pcb_release',
          projectId: 'project_field_nodes',
          title: 'PCB release checklist',
          documentType: 'Checklist',
          status: 'Ready',
          updatedAt: DateTime.utc(2026, 7, 2, 9, 45),
          summary: 'Tracks fab readiness and release criteria.',
          filePath: 'docs/engineering/pcb_release_checklist.md',
          tags: ['pcb', 'release'],
        ),
      ),
      EngineeringDocument.fromJson(
        _document(
          id: 'document_decision_log',
          projectId: 'project_biocalm',
          title: 'Decision log',
          documentType: 'Decision log',
          status: 'Ready',
          updatedAt: DateTime.utc(2026, 7, 1, 19, 10),
          summary: 'Stores engineering decisions with calm rationale.',
          filePath: 'docs/engineering/decision_log.md',
          tags: ['decision', 'log'],
        ),
      ),
      EngineeringDocument.fromJson(
        _document(
          id: 'document_validation_pack',
          projectId: 'project_omega_dashboard',
          title: 'Validation pack',
          documentType: 'Validation',
          status: 'Draft',
          updatedAt: DateTime.utc(2026, 7, 2, 17, 0),
          summary: 'Placeholder test evidence and future QA notes.',
          filePath: 'docs/engineering/validation_pack.md',
          tags: ['validation', 'qa'],
        ),
      ),
      EngineeringDocument.fromJson(
        _document(
          id: 'document_manufacturing_pack',
          projectId: 'project_field_nodes',
          title: 'Manufacturing pack',
          documentType: 'Manufacturing',
          status: 'Draft',
          updatedAt: DateTime.utc(2026, 7, 2, 18, 20),
          summary: 'Assembly notes for the first field batch.',
          filePath: 'docs/engineering/manufacturing_pack.md',
          tags: ['manufacturing', 'assembly'],
        ),
      ),
    ];
  }

  List<EngineeringAttachment> _buildAttachments() {
    return [
      EngineeringAttachment.fromJson(
        _attachment(
          id: 'attachment_microgrow_schematic',
          ownerType: 'pcb',
          ownerId: 'pcb_microgrow_a1',
          title: 'MicroGrow schematic',
          kind: 'Schematic',
          filePath: 'assets/engineering/microgrow/schematic.pdf',
          status: 'Linked',
          updatedAt: DateTime.utc(2026, 7, 2, 9, 15),
          notes: 'Primary field sensor schematic.',
          tags: ['schematic', 'microgrow'],
        ),
      ),
      EngineeringAttachment.fromJson(
        _attachment(
          id: 'attachment_biocalm_board',
          ownerType: 'pcb',
          ownerId: 'pcb_biocalm_a1',
          title: 'BioCalm board files',
          kind: 'Board File',
          filePath: 'assets/engineering/biocalm/board.zip',
          status: 'Linked',
          updatedAt: DateTime.utc(2026, 7, 2, 9, 25),
          notes: 'Fabrication package staged locally.',
          tags: ['board', 'pcb'],
        ),
      ),
      EngineeringAttachment.fromJson(
        _attachment(
          id: 'attachment_firmware_release',
          ownerType: 'firmware',
          ownerId: 'firmware_biocalm_010',
          title: 'BioCalm firmware artifact',
          kind: 'Firmware Artifact',
          filePath: 'build/firmware/biocalm_010.bin',
          status: 'Linked',
          updatedAt: DateTime.utc(2026, 7, 2, 13, 10),
          notes: 'Release artifact ready for deployment.',
          tags: ['firmware', 'artifact'],
        ),
      ),
      EngineeringAttachment.fromJson(
        _attachment(
          id: 'attachment_validation_evidence',
          ownerType: 'validation',
          ownerId: 'validation_power_cycle',
          title: 'Power cycle evidence pack',
          kind: 'Validation Evidence',
          filePath: 'docs/evidence/power_cycle_pack.zip',
          status: 'Linked',
          updatedAt: DateTime.utc(2026, 7, 2, 16, 5),
          notes: 'Captured results and logs for the validation pass.',
          tags: ['evidence', 'validation'],
        ),
      ),
    ];
  }

  List<EngineeringDecision> _buildDecisions() {
    return [
      EngineeringDecision.fromJson(
        _decision(
          id: 'decision_sensor_bus',
          projectId: 'project_microgrow',
          title: 'Sensor bus choice',
          decision: 'Keep the current bus layout for the pilot build.',
          status: 'Recorded',
          confidence: 'High',
          decidedAt: DateTime.utc(2026, 6, 30, 13, 15),
          rationale:
              'The current wiring is stable and easier to debug locally.',
          nextAction: 'Document the bus map in the field wiring guide.',
          tags: ['bus', 'sensors'],
        ),
      ),
      EngineeringDecision.fromJson(
        _decision(
          id: 'decision_board_stack',
          projectId: 'project_biocalm',
          title: 'Board stack layering',
          decision: 'Use the slimmer stack to preserve comfort.',
          status: 'Recorded',
          confidence: 'Medium',
          decidedAt: DateTime.utc(2026, 7, 1, 10, 20),
          rationale:
              'The wearable needs a calmer silhouette and lower pressure points.',
          nextAction: 'Update the enclosure drawings.',
          tags: ['stack', 'wearable'],
        ),
      ),
      EngineeringDecision.fromJson(
        _decision(
          id: 'decision_dashboard_hooks',
          projectId: 'project_omega_dashboard',
          title: 'Dashboard hook strategy',
          decision: 'Use placeholder hooks now and keep the interfaces stable.',
          status: 'Recorded',
          confidence: 'High',
          decidedAt: DateTime.utc(2026, 7, 2, 14, 50),
          rationale: 'The module shell should not wait on later integrations.',
          nextAction: 'Keep the hook names stable while the module grows.',
          tags: ['hooks', 'integration'],
        ),
      ),
      EngineeringDecision.fromJson(
        _decision(
          id: 'decision_packout_gate',
          projectId: 'project_living',
          title: 'Pack-out release gate',
          decision: 'Delay pack-out until power stability is cleared.',
          status: 'Parked',
          confidence: 'High',
          decidedAt: DateTime.utc(2026, 7, 1, 16, 0),
          rationale:
              'The pack should stay calm and not ship with an avoidable fault.',
          nextAction: 'Revisit after the stability test passes.',
          tags: ['packout', 'gate'],
        ),
      ),
    ];
  }

  EngineeringModuleSettings? _settingsFromJson(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.map((key, value) => MapEntry(key.toString(), value));
    return EngineeringModuleSettings(
      moduleRootPath: map['moduleRootPath']?.toString() ?? moduleRootPath,
      storagePath:
          map['storagePath']?.toString() ?? path.join(moduleRootPath, 'data'),
      offlineOnly: map['offlineOnly'] == true,
      knowledgeEngineRoute:
          map['knowledgeEngineRoute']?.toString() ??
          '/modules/omega-knowledge-engine',
      gaiaAssistantRoute:
          map['gaiaAssistantRoute']?.toString() ?? '/voice-assistant',
      lastRefreshedLabel:
          map['lastRefreshedLabel']?.toString() ?? 'Ready locally',
    );
  }

  List<EngineeringProject>? _projectsFromJson(dynamic raw) {
    return _listFromJson(raw, EngineeringProject.fromJson);
  }

  List<CircuitBlock>? _circuitBlocksFromJson(dynamic raw) {
    return _listFromJson(raw, CircuitBlock.fromJson);
  }

  List<PCBRevision>? _pcbRevisionsFromJson(dynamic raw) {
    return _listFromJson(raw, PCBRevision.fromJson);
  }

  List<FirmwareBuild>? _firmwareBuildsFromJson(dynamic raw) {
    return _listFromJson(raw, FirmwareBuild.fromJson);
  }

  List<DeviceNode>? _deviceNodesFromJson(dynamic raw) {
    return _listFromJson(raw, DeviceNode.fromJson);
  }

  List<ComponentItem>? _componentItemsFromJson(dynamic raw) {
    return _listFromJson(raw, ComponentItem.fromJson);
  }

  List<ExperimentRecord>? _experimentsFromJson(dynamic raw) {
    return _listFromJson(raw, ExperimentRecord.fromJson);
  }

  List<TestProcedure>? _testProceduresFromJson(dynamic raw) {
    return _listFromJson(raw, TestProcedure.fromJson);
  }

  List<ValidationResult>? _validationResultsFromJson(dynamic raw) {
    return _listFromJson(raw, ValidationResult.fromJson);
  }

  List<ManufacturingStep>? _manufacturingStepsFromJson(dynamic raw) {
    return _listFromJson(raw, ManufacturingStep.fromJson);
  }

  List<EngineeringDocument>? _documentsFromJson(dynamic raw) {
    return _listFromJson(raw, EngineeringDocument.fromJson);
  }

  List<EngineeringAttachment>? _attachmentsFromJson(dynamic raw) {
    return _listFromJson(raw, EngineeringAttachment.fromJson);
  }

  List<EngineeringDecision>? _decisionsFromJson(dynamic raw) {
    return _listFromJson(raw, EngineeringDecision.fromJson);
  }

  List<T>? _listFromJson<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (raw is! List) {
      return null;
    }
    return raw
        .whereType<Map>()
        .map(
          (entry) => entry.map((key, value) => MapEntry(key.toString(), value)),
        )
        .map(parser)
        .toList(growable: false);
  }

  Map<String, dynamic> _project({
    required String id,
    required String title,
    required String summary,
    required String status,
    required String priority,
    required int progressPercent,
    required String milestone,
    required String nextAction,
    required String system,
    required DateTime updatedAt,
    required int openTaskCount,
    required int blockedTaskCount,
    required List<String> tags,
    DateTime? targetDate,
  }) {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'status': status,
      'priority': priority,
      'progressPercent': progressPercent,
      'milestone': milestone,
      'nextAction': nextAction,
      'system': system,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'openTaskCount': openTaskCount,
      'blockedTaskCount': blockedTaskCount,
      'tags': tags,
      'targetDate': targetDate?.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _circuitBlock({
    required String id,
    required String projectId,
    required String title,
    required String category,
    required String status,
    required int progressPercent,
    required String function,
    required String nextAction,
    required String knowledgeHookRoute,
    required String gaiaHookRoute,
    required List<String> tags,
    required String notes,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'category': category,
      'status': status,
      'progressPercent': progressPercent,
      'function': function,
      'nextAction': nextAction,
      'knowledgeHookRoute': knowledgeHookRoute,
      'gaiaHookRoute': gaiaHookRoute,
      'tags': tags,
      'notes': notes,
    };
  }

  Map<String, dynamic> _pcbRevision({
    required String id,
    required String projectId,
    required String boardName,
    required String revision,
    required String status,
    required int layers,
    required int progressPercent,
    required bool fabReady,
    required String manufacturingPartner,
    required String nextAction,
    required List<String> tags,
    required String notes,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'boardName': boardName,
      'revision': revision,
      'status': status,
      'layers': layers,
      'progressPercent': progressPercent,
      'fabReady': fabReady,
      'manufacturingPartner': manufacturingPartner,
      'nextAction': nextAction,
      'tags': tags,
      'notes': notes,
    };
  }

  Map<String, dynamic> _firmwareBuild({
    required String id,
    required String projectId,
    required String targetDevice,
    required String version,
    required String status,
    required int progressPercent,
    required String buildType,
    required String nextAction,
    required String artifactPath,
    required DateTime lastBuiltAt,
    required List<String> tags,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'targetDevice': targetDevice,
      'version': version,
      'status': status,
      'progressPercent': progressPercent,
      'buildType': buildType,
      'nextAction': nextAction,
      'artifactPath': artifactPath,
      'lastBuiltAt': lastBuiltAt.toUtc().toIso8601String(),
      'tags': tags,
    };
  }

  Map<String, dynamic> _deviceNode({
    required String id,
    required String projectId,
    required String name,
    required String model,
    required String status,
    required String health,
    required String firmwareVersion,
    required DateTime lastSeenAt,
    required String location,
    required String nextAction,
    required List<String> tags,
    required String notes,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'model': model,
      'status': status,
      'health': health,
      'firmwareVersion': firmwareVersion,
      'lastSeenAt': lastSeenAt.toUtc().toIso8601String(),
      'location': location,
      'nextAction': nextAction,
      'tags': tags,
      'notes': notes,
    };
  }

  Map<String, dynamic> _componentItem({
    required String id,
    required String sku,
    required String name,
    required String category,
    required String status,
    required int quantityOnHand,
    required int reorderLevel,
    required String preferredVendor,
    required String storageLocation,
    required String nextAction,
    required List<String> tags,
    required String notes,
    required DateTime updatedAt,
  }) {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'status': status,
      'quantityOnHand': quantityOnHand,
      'reorderLevel': reorderLevel,
      'preferredVendor': preferredVendor,
      'storageLocation': storageLocation,
      'nextAction': nextAction,
      'tags': tags,
      'notes': notes,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _experiment({
    required String id,
    required String projectId,
    required String title,
    required String hypothesis,
    required String status,
    required int progressPercent,
    required int evidenceCount,
    required String resultSummary,
    required String nextAction,
    required DateTime startedAt,
    required List<String> tags,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'hypothesis': hypothesis,
      'status': status,
      'progressPercent': progressPercent,
      'evidenceCount': evidenceCount,
      'resultSummary': resultSummary,
      'nextAction': nextAction,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'tags': tags,
    };
  }

  Map<String, dynamic> _testProcedure({
    required String id,
    required String projectId,
    required String title,
    required String stage,
    required String status,
    required int progressPercent,
    required String owner,
    required int estimatedMinutes,
    required String nextAction,
    required List<String> tags,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'stage': stage,
      'status': status,
      'progressPercent': progressPercent,
      'owner': owner,
      'estimatedMinutes': estimatedMinutes,
      'nextAction': nextAction,
      'tags': tags,
    };
  }

  Map<String, dynamic> _validationResult({
    required String id,
    required String testProcedureId,
    required String title,
    required String status,
    required String severity,
    required String verdict,
    required DateTime checkedAt,
    required int evidenceCount,
    required String summary,
    required String nextAction,
  }) {
    return {
      'id': id,
      'testProcedureId': testProcedureId,
      'title': title,
      'status': status,
      'severity': severity,
      'verdict': verdict,
      'checkedAt': checkedAt.toUtc().toIso8601String(),
      'evidenceCount': evidenceCount,
      'summary': summary,
      'nextAction': nextAction,
    };
  }

  Map<String, dynamic> _manufacturingStep({
    required String id,
    required String projectId,
    required String title,
    required String stage,
    required String status,
    required int progressPercent,
    required String owner,
    required String station,
    required String nextAction,
    required String dueLabel,
    required List<String> tags,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'stage': stage,
      'status': status,
      'progressPercent': progressPercent,
      'owner': owner,
      'station': station,
      'nextAction': nextAction,
      'dueLabel': dueLabel,
      'tags': tags,
    };
  }

  Map<String, dynamic> _document({
    required String id,
    required String projectId,
    required String title,
    required String documentType,
    required String status,
    required DateTime updatedAt,
    required String summary,
    required String filePath,
    required List<String> tags,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'documentType': documentType,
      'status': status,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'summary': summary,
      'filePath': filePath,
      'tags': tags,
    };
  }

  Map<String, dynamic> _attachment({
    required String id,
    required String ownerType,
    required String ownerId,
    required String title,
    required String kind,
    required String filePath,
    required String status,
    required DateTime updatedAt,
    required String notes,
    required List<String> tags,
  }) {
    return {
      'id': id,
      'ownerType': ownerType,
      'ownerId': ownerId,
      'title': title,
      'kind': kind,
      'filePath': filePath,
      'status': status,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'notes': notes,
      'tags': tags,
    };
  }

  Map<String, dynamic> _decision({
    required String id,
    required String projectId,
    required String title,
    required String decision,
    required String status,
    required String confidence,
    required DateTime decidedAt,
    required String rationale,
    required String nextAction,
    required List<String> tags,
  }) {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'decision': decision,
      'status': status,
      'confidence': confidence,
      'decidedAt': decidedAt.toUtc().toIso8601String(),
      'rationale': rationale,
      'nextAction': nextAction,
      'tags': tags,
    };
  }
}
