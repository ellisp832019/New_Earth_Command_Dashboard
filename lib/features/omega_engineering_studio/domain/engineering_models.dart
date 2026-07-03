import 'package:flutter/foundation.dart';

enum EngineeringSection {
  dashboard,
  projects,
  circuitLibrary,
  pcbManager,
  firmwareCentre,
  deviceFleet,
  componentInventory,
  experimentLab,
  testValidation,
  manufacturing,
  documentation,
  settings;

  String get label {
    return switch (this) {
      EngineeringSection.dashboard => 'Dashboard',
      EngineeringSection.projects => 'Projects',
      EngineeringSection.circuitLibrary => 'Circuit Library',
      EngineeringSection.pcbManager => 'PCB Manager',
      EngineeringSection.firmwareCentre => 'Firmware Centre',
      EngineeringSection.deviceFleet => 'Device Fleet',
      EngineeringSection.componentInventory => 'Component Inventory',
      EngineeringSection.experimentLab => 'Experiment Lab',
      EngineeringSection.testValidation => 'Test & Validation',
      EngineeringSection.manufacturing => 'Manufacturing',
      EngineeringSection.documentation => 'Documentation',
      EngineeringSection.settings => 'Settings',
    };
  }

  String get routeSegment {
    return switch (this) {
      EngineeringSection.dashboard => '',
      EngineeringSection.projects => 'projects',
      EngineeringSection.circuitLibrary => 'circuit-library',
      EngineeringSection.pcbManager => 'pcb-manager',
      EngineeringSection.firmwareCentre => 'firmware-centre',
      EngineeringSection.deviceFleet => 'device-fleet',
      EngineeringSection.componentInventory => 'component-inventory',
      EngineeringSection.experimentLab => 'experiment-lab',
      EngineeringSection.testValidation => 'test-validation',
      EngineeringSection.manufacturing => 'manufacturing',
      EngineeringSection.documentation => 'documentation',
      EngineeringSection.settings => 'settings',
    };
  }

  static EngineeringSection fromRouteSegment(String? segment) {
    return switch (segment) {
      'projects' => EngineeringSection.projects,
      'circuit-library' => EngineeringSection.circuitLibrary,
      'pcb-manager' => EngineeringSection.pcbManager,
      'firmware-centre' => EngineeringSection.firmwareCentre,
      'device-fleet' => EngineeringSection.deviceFleet,
      'component-inventory' => EngineeringSection.componentInventory,
      'experiment-lab' => EngineeringSection.experimentLab,
      'test-validation' => EngineeringSection.testValidation,
      'manufacturing' => EngineeringSection.manufacturing,
      'documentation' => EngineeringSection.documentation,
      'settings' => EngineeringSection.settings,
      _ => EngineeringSection.dashboard,
    };
  }
}

@immutable
class EngineeringModuleSettings {
  const EngineeringModuleSettings({
    required this.moduleRootPath,
    required this.storagePath,
    required this.offlineOnly,
    required this.knowledgeEngineRoute,
    required this.gaiaAssistantRoute,
    required this.lastRefreshedLabel,
  });

  final String moduleRootPath;
  final String storagePath;
  final bool offlineOnly;
  final String knowledgeEngineRoute;
  final String gaiaAssistantRoute;
  final String lastRefreshedLabel;

  factory EngineeringModuleSettings.defaults({
    required String moduleRootPath,
    String storagePath = 'modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/data',
    String knowledgeEngineRoute = '/modules/omega-knowledge-engine',
    String gaiaAssistantRoute = '/voice-assistant',
  }) {
    return EngineeringModuleSettings(
      moduleRootPath: moduleRootPath,
      storagePath: storagePath,
      offlineOnly: true,
      knowledgeEngineRoute: knowledgeEngineRoute,
      gaiaAssistantRoute: gaiaAssistantRoute,
      lastRefreshedLabel: 'Ready locally',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleRootPath': moduleRootPath,
      'storagePath': storagePath,
      'offlineOnly': offlineOnly,
      'knowledgeEngineRoute': knowledgeEngineRoute,
      'gaiaAssistantRoute': gaiaAssistantRoute,
      'lastRefreshedLabel': lastRefreshedLabel,
    };
  }
}

class EngineeringProject {
  const EngineeringProject({
    required this.id,
    required this.title,
    required this.summary,
    required this.status,
    required this.priority,
    required this.progressPercent,
    required this.milestone,
    required this.nextAction,
    required this.system,
    required this.updatedAt,
    required this.openTaskCount,
    required this.blockedTaskCount,
    required this.tags,
    this.targetDate,
  });

  final String id;
  final String title;
  final String summary;
  final String status;
  final String priority;
  final int progressPercent;
  final String milestone;
  final String nextAction;
  final String system;
  final DateTime updatedAt;
  final int openTaskCount;
  final int blockedTaskCount;
  final List<String> tags;
  final DateTime? targetDate;

  factory EngineeringProject.fromJson(Map<String, dynamic> json) {
    return EngineeringProject(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Idea',
      priority: json['priority']?.toString() ?? 'Medium',
      progressPercent: _intValue(json['progressPercent']).clamp(0, 100),
      milestone: json['milestone']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      system: json['system']?.toString() ?? '',
      updatedAt: _dateTime(json['updatedAt']),
      openTaskCount: _intValue(json['openTaskCount']),
      blockedTaskCount: _intValue(json['blockedTaskCount']),
      tags: _stringList(json['tags']),
      targetDate: DateTime.tryParse(json['targetDate']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
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
}

class CircuitBlock {
  const CircuitBlock({
    required this.id,
    required this.projectId,
    required this.title,
    required this.category,
    required this.status,
    required this.progressPercent,
    required this.function,
    required this.nextAction,
    required this.knowledgeHookRoute,
    required this.gaiaHookRoute,
    required this.tags,
    required this.notes,
  });

  final String id;
  final String projectId;
  final String title;
  final String category;
  final String status;
  final int progressPercent;
  final String function;
  final String nextAction;
  final String knowledgeHookRoute;
  final String gaiaHookRoute;
  final List<String> tags;
  final String notes;

  factory CircuitBlock.fromJson(Map<String, dynamic> json) {
    return CircuitBlock(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Draft',
      progressPercent: _intValue(json['progressPercent']).clamp(0, 100),
      function: json['function']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      knowledgeHookRoute: json['knowledgeHookRoute']?.toString() ?? '',
      gaiaHookRoute: json['gaiaHookRoute']?.toString() ?? '',
      tags: _stringList(json['tags']),
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
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
}

class PCBRevision {
  const PCBRevision({
    required this.id,
    required this.projectId,
    required this.boardName,
    required this.revision,
    required this.status,
    required this.layers,
    required this.progressPercent,
    required this.fabReady,
    required this.manufacturingPartner,
    required this.nextAction,
    required this.tags,
    required this.notes,
  });

  final String id;
  final String projectId;
  final String boardName;
  final String revision;
  final String status;
  final int layers;
  final int progressPercent;
  final bool fabReady;
  final String manufacturingPartner;
  final String nextAction;
  final List<String> tags;
  final String notes;

  factory PCBRevision.fromJson(Map<String, dynamic> json) {
    return PCBRevision(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      boardName: json['boardName']?.toString() ?? '',
      revision: json['revision']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Draft',
      layers: _intValue(json['layers']),
      progressPercent: _intValue(json['progressPercent']).clamp(0, 100),
      fabReady: _boolValue(json['fabReady']),
      manufacturingPartner: json['manufacturingPartner']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      tags: _stringList(json['tags']),
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
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
}

class FirmwareBuild {
  const FirmwareBuild({
    required this.id,
    required this.projectId,
    required this.targetDevice,
    required this.version,
    required this.status,
    required this.progressPercent,
    required this.buildType,
    required this.nextAction,
    required this.artifactPath,
    required this.lastBuiltAt,
    required this.tags,
  });

  final String id;
  final String projectId;
  final String targetDevice;
  final String version;
  final String status;
  final int progressPercent;
  final String buildType;
  final String nextAction;
  final String artifactPath;
  final DateTime lastBuiltAt;
  final List<String> tags;

  factory FirmwareBuild.fromJson(Map<String, dynamic> json) {
    return FirmwareBuild(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      targetDevice: json['targetDevice']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Draft',
      progressPercent: _intValue(json['progressPercent']).clamp(0, 100),
      buildType: json['buildType']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      artifactPath: json['artifactPath']?.toString() ?? '',
      lastBuiltAt: _dateTime(json['lastBuiltAt']),
      tags: _stringList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
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
}

class DeviceNode {
  const DeviceNode({
    required this.id,
    required this.projectId,
    required this.name,
    required this.model,
    required this.status,
    required this.health,
    required this.firmwareVersion,
    required this.lastSeenAt,
    required this.location,
    required this.nextAction,
    required this.tags,
    required this.notes,
  });

  final String id;
  final String projectId;
  final String name;
  final String model;
  final String status;
  final String health;
  final String firmwareVersion;
  final DateTime lastSeenAt;
  final String location;
  final String nextAction;
  final List<String> tags;
  final String notes;

  factory DeviceNode.fromJson(Map<String, dynamic> json) {
    return DeviceNode(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Offline',
      health: json['health']?.toString() ?? 'Unknown',
      firmwareVersion: json['firmwareVersion']?.toString() ?? '',
      lastSeenAt: _dateTime(json['lastSeenAt']),
      location: json['location']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      tags: _stringList(json['tags']),
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
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
}

class ComponentItem {
  const ComponentItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.status,
    required this.quantityOnHand,
    required this.reorderLevel,
    required this.preferredVendor,
    required this.storageLocation,
    required this.nextAction,
    required this.tags,
    required this.notes,
    required this.updatedAt,
  });

  final String id;
  final String sku;
  final String name;
  final String category;
  final String status;
  final int quantityOnHand;
  final int reorderLevel;
  final String preferredVendor;
  final String storageLocation;
  final String nextAction;
  final List<String> tags;
  final String notes;
  final DateTime updatedAt;

  bool get isLowStock => quantityOnHand <= reorderLevel;

  factory ComponentItem.fromJson(Map<String, dynamic> json) {
    return ComponentItem(
      id: json['id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Available',
      quantityOnHand: _intValue(json['quantityOnHand']),
      reorderLevel: _intValue(json['reorderLevel']),
      preferredVendor: json['preferredVendor']?.toString() ?? '',
      storageLocation: json['storageLocation']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      tags: _stringList(json['tags']),
      notes: json['notes']?.toString() ?? '',
      updatedAt: _dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
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
}

class ExperimentRecord {
  const ExperimentRecord({
    required this.id,
    required this.projectId,
    required this.title,
    required this.hypothesis,
    required this.status,
    required this.progressPercent,
    required this.evidenceCount,
    required this.resultSummary,
    required this.nextAction,
    required this.startedAt,
    required this.tags,
  });

  final String id;
  final String projectId;
  final String title;
  final String hypothesis;
  final String status;
  final int progressPercent;
  final int evidenceCount;
  final String resultSummary;
  final String nextAction;
  final DateTime startedAt;
  final List<String> tags;

  factory ExperimentRecord.fromJson(Map<String, dynamic> json) {
    return ExperimentRecord(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      hypothesis: json['hypothesis']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Planned',
      progressPercent: _intValue(json['progressPercent']).clamp(0, 100),
      evidenceCount: _intValue(json['evidenceCount']),
      resultSummary: json['resultSummary']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      startedAt: _dateTime(json['startedAt']),
      tags: _stringList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
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
}

class TestProcedure {
  const TestProcedure({
    required this.id,
    required this.projectId,
    required this.title,
    required this.stage,
    required this.status,
    required this.progressPercent,
    required this.owner,
    required this.estimatedMinutes,
    required this.nextAction,
    required this.tags,
  });

  final String id;
  final String projectId;
  final String title;
  final String stage;
  final String status;
  final int progressPercent;
  final String owner;
  final int estimatedMinutes;
  final String nextAction;
  final List<String> tags;

  factory TestProcedure.fromJson(Map<String, dynamic> json) {
    return TestProcedure(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      stage: json['stage']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Planned',
      progressPercent: _intValue(json['progressPercent']).clamp(0, 100),
      owner: json['owner']?.toString() ?? '',
      estimatedMinutes: _intValue(json['estimatedMinutes']),
      nextAction: json['nextAction']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
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
}

class ValidationResult {
  const ValidationResult({
    required this.id,
    required this.testProcedureId,
    required this.title,
    required this.status,
    required this.severity,
    required this.verdict,
    required this.checkedAt,
    required this.evidenceCount,
    required this.summary,
    required this.nextAction,
  });

  final String id;
  final String testProcedureId;
  final String title;
  final String status;
  final String severity;
  final String verdict;
  final DateTime checkedAt;
  final int evidenceCount;
  final String summary;
  final String nextAction;

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      id: json['id']?.toString() ?? '',
      testProcedureId: json['testProcedureId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      severity: json['severity']?.toString() ?? 'Info',
      verdict: json['verdict']?.toString() ?? '',
      checkedAt: _dateTime(json['checkedAt']),
      evidenceCount: _intValue(json['evidenceCount']),
      summary: json['summary']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
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
}

class ManufacturingStep {
  const ManufacturingStep({
    required this.id,
    required this.projectId,
    required this.title,
    required this.stage,
    required this.status,
    required this.progressPercent,
    required this.owner,
    required this.station,
    required this.nextAction,
    required this.dueLabel,
    required this.tags,
  });

  final String id;
  final String projectId;
  final String title;
  final String stage;
  final String status;
  final int progressPercent;
  final String owner;
  final String station;
  final String nextAction;
  final String dueLabel;
  final List<String> tags;

  factory ManufacturingStep.fromJson(Map<String, dynamic> json) {
    return ManufacturingStep(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      stage: json['stage']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Queued',
      progressPercent: _intValue(json['progressPercent']).clamp(0, 100),
      owner: json['owner']?.toString() ?? '',
      station: json['station']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      dueLabel: json['dueLabel']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
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
}

class EngineeringDocument {
  const EngineeringDocument({
    required this.id,
    required this.projectId,
    required this.title,
    required this.documentType,
    required this.status,
    required this.updatedAt,
    required this.summary,
    required this.filePath,
    required this.tags,
  });

  final String id;
  final String projectId;
  final String title;
  final String documentType;
  final String status;
  final DateTime updatedAt;
  final String summary;
  final String filePath;
  final List<String> tags;

  factory EngineeringDocument.fromJson(Map<String, dynamic> json) {
    return EngineeringDocument(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Draft',
      updatedAt: _dateTime(json['updatedAt']),
      summary: json['summary']?.toString() ?? '',
      filePath: json['filePath']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
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
}

class EngineeringDecision {
  const EngineeringDecision({
    required this.id,
    required this.projectId,
    required this.title,
    required this.decision,
    required this.status,
    required this.confidence,
    required this.decidedAt,
    required this.rationale,
    required this.nextAction,
    required this.tags,
  });

  final String id;
  final String projectId;
  final String title;
  final String decision;
  final String status;
  final String confidence;
  final DateTime decidedAt;
  final String rationale;
  final String nextAction;
  final List<String> tags;

  factory EngineeringDecision.fromJson(Map<String, dynamic> json) {
    return EngineeringDecision(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      decision: json['decision']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Recorded',
      confidence: json['confidence']?.toString() ?? 'Medium',
      decidedAt: _dateTime(json['decidedAt']),
      rationale: json['rationale']?.toString() ?? '',
      nextAction: json['nextAction']?.toString() ?? '',
      tags: _stringList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
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

@immutable
class EngineeringSnapshot {
  const EngineeringSnapshot({
    required this.settings,
    required this.projects,
    required this.circuitBlocks,
    required this.pcbRevisions,
    required this.firmwareBuilds,
    required this.deviceNodes,
    required this.componentItems,
    required this.experiments,
    required this.testProcedures,
    required this.validationResults,
    required this.manufacturingSteps,
    required this.documents,
    required this.decisions,
  });

  final EngineeringModuleSettings settings;
  final List<EngineeringProject> projects;
  final List<CircuitBlock> circuitBlocks;
  final List<PCBRevision> pcbRevisions;
  final List<FirmwareBuild> firmwareBuilds;
  final List<DeviceNode> deviceNodes;
  final List<ComponentItem> componentItems;
  final List<ExperimentRecord> experiments;
  final List<TestProcedure> testProcedures;
  final List<ValidationResult> validationResults;
  final List<ManufacturingStep> manufacturingSteps;
  final List<EngineeringDocument> documents;
  final List<EngineeringDecision> decisions;

  EngineeringSnapshot copyWith({
    EngineeringModuleSettings? settings,
    List<EngineeringProject>? projects,
    List<CircuitBlock>? circuitBlocks,
    List<PCBRevision>? pcbRevisions,
    List<FirmwareBuild>? firmwareBuilds,
    List<DeviceNode>? deviceNodes,
    List<ComponentItem>? componentItems,
    List<ExperimentRecord>? experiments,
    List<TestProcedure>? testProcedures,
    List<ValidationResult>? validationResults,
    List<ManufacturingStep>? manufacturingSteps,
    List<EngineeringDocument>? documents,
    List<EngineeringDecision>? decisions,
  }) {
    return EngineeringSnapshot(
      settings: settings ?? this.settings,
      projects: projects ?? this.projects,
      circuitBlocks: circuitBlocks ?? this.circuitBlocks,
      pcbRevisions: pcbRevisions ?? this.pcbRevisions,
      firmwareBuilds: firmwareBuilds ?? this.firmwareBuilds,
      deviceNodes: deviceNodes ?? this.deviceNodes,
      componentItems: componentItems ?? this.componentItems,
      experiments: experiments ?? this.experiments,
      testProcedures: testProcedures ?? this.testProcedures,
      validationResults: validationResults ?? this.validationResults,
      manufacturingSteps: manufacturingSteps ?? this.manufacturingSteps,
      documents: documents ?? this.documents,
      decisions: decisions ?? this.decisions,
    );
  }

  int get projectCount => projects.length;
  int get activeProjectCount =>
      projects.where((project) => _isActiveStatus(project.status)).length;
  int get blockedProjectCount =>
      projects.where((project) => _isBlockedStatus(project.status)).length;
  int get readyProjectCount =>
      projects.where((project) => _isReadyStatus(project.status)).length;
  int get lowStockCount =>
      componentItems.where((item) => item.isLowStock).length;
  int get fabReadyPcbCount => pcbRevisions.where((pcb) => pcb.fabReady).length;
  int get firmwareReadyCount =>
      firmwareBuilds.where((build) => _isReadyStatus(build.status)).length;
  int get liveDeviceCount =>
      deviceNodes.where((device) => _isActiveStatus(device.status)).length;
  int get validationPassCount => validationResults
      .where((result) => result.status.toLowerCase().contains('pass'))
      .length;
  int get manufacturingReadyCount =>
      manufacturingSteps.where((step) => _isReadyStatus(step.status)).length;

  double get averageProjectProgress {
    if (projects.isEmpty) {
      return 0;
    }
    final total = projects.fold<int>(
      0,
      (sum, project) => sum + project.progressPercent,
    );
    return total / projects.length;
  }

  EngineeringProject? projectById(String id) {
    for (final project in projects) {
      if (project.id == id) {
        return project;
      }
    }
    return null;
  }
}

bool _isActiveStatus(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('active') ||
      normalized.contains('running') ||
      normalized.contains('building') ||
      normalized.contains('testing') ||
      normalized.contains('open');
}

bool _isBlockedStatus(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('block') ||
      normalized.contains('risk') ||
      normalized.contains('attention') ||
      normalized.contains('offline');
}

bool _isReadyStatus(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('ready') ||
      normalized.contains('complete') ||
      normalized.contains('signed off') ||
      normalized.contains('validated') ||
      normalized.contains('pass');
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Object?>()
      .map((value) => value.toString().trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

int _intValue(dynamic raw, [int fallback = 0]) {
  if (raw is int) {
    return raw;
  }
  if (raw is double) {
    return raw.round();
  }
  return int.tryParse(raw?.toString() ?? '') ?? fallback;
}

bool _boolValue(dynamic raw) {
  if (raw is bool) {
    return raw;
  }
  final value = raw?.toString().toLowerCase();
  return value == 'true' || value == '1' || value == 'yes';
}

DateTime _dateTime(dynamic raw) {
  final parsed = DateTime.tryParse(raw?.toString() ?? '');
  if (parsed != null) {
    return parsed;
  }
  return DateTime.now().toUtc();
}
