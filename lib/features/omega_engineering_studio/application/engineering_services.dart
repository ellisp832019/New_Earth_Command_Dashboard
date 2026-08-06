import '../domain/engineering_models.dart';

class EngineeringSearchHit {
  const EngineeringSearchHit({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.section,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String kind;
  final EngineeringSection section;
  final String status;
}

class ProjectService {
  const ProjectService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<EngineeringProject> projects({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.projects
        .where((project) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(project.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              project.title,
              project.summary,
              project.milestone,
              project.nextAction,
              project.system,
              project.priority,
              ...project.tags,
            ],
          );
        })
        .toList(growable: false);
  }
}

class CircuitLibraryService {
  const CircuitLibraryService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<CircuitBlock> blocks({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.circuitBlocks
        .where((block) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(block.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              block.title,
              block.category,
              block.function,
              block.nextAction,
              block.notes,
              ...block.tags,
            ],
          );
        })
        .toList(growable: false);
  }
}

class PCBService {
  const PCBService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<PCBRevision> revisions({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.pcbRevisions
        .where((pcb) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(pcb.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              pcb.boardName,
              pcb.revision,
              pcb.status,
              pcb.manufacturingPartner,
              pcb.nextAction,
              pcb.notes,
              ...pcb.tags,
            ],
          );
        })
        .toList(growable: false);
  }
}

class FirmwareBuildService {
  const FirmwareBuildService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<FirmwareBuild> builds({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.firmwareBuilds
        .where((build) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(build.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              build.targetDevice,
              build.version,
              build.status,
              build.buildType,
              build.nextAction,
              build.artifactPath,
              ...build.tags,
            ],
          );
        })
        .toList(growable: false);
  }
}

class DeviceFleetService {
  const DeviceFleetService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<DeviceNode> devices({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.deviceNodes
        .where((device) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(device.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              device.name,
              device.model,
              device.status,
              device.health,
              device.firmwareVersion,
              device.location,
              device.nextAction,
              device.notes,
              ...device.tags,
            ],
          );
        })
        .toList(growable: false);
  }
}

class ComponentInventoryService {
  const ComponentInventoryService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<ComponentItem> components({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.componentItems
        .where((item) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(item.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              item.sku,
              item.name,
              item.category,
              item.status,
              item.preferredVendor,
              item.storageLocation,
              item.nextAction,
              item.notes,
              ...item.tags,
            ],
          );
        })
        .toList(growable: false);
  }
}

class ExperimentService {
  const ExperimentService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<ExperimentRecord> experiments({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.experiments
        .where((experiment) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(experiment.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              experiment.title,
              experiment.hypothesis,
              experiment.status,
              experiment.resultSummary,
              experiment.nextAction,
              ...experiment.tags,
            ],
          );
        })
        .toList(growable: false);
  }
}

class ValidationService {
  const ValidationService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<TestProcedure> procedures({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.testProcedures
        .where((procedure) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(procedure.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              procedure.title,
              procedure.stage,
              procedure.status,
              procedure.owner,
              procedure.nextAction,
              ...procedure.tags,
            ],
          );
        })
        .toList(growable: false);
  }

  List<ValidationResult> results({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.validationResults
        .where((result) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(result.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              result.title,
              result.status,
              result.severity,
              result.verdict,
              result.summary,
              result.nextAction,
            ],
          );
        })
        .toList(growable: false);
  }
}

class ManufacturingService {
  const ManufacturingService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<ManufacturingStep> steps({String query = '', String? status}) {
    final needle = _normalise(query);
    return snapshot.manufacturingSteps
        .where((step) {
          if (status != null &&
              status.isNotEmpty &&
              !_matchesStatus(step.status, status)) {
            return false;
          }
          return _matchesQuery(
            query: needle,
            values: [
              step.title,
              step.stage,
              step.status,
              step.owner,
              step.station,
              step.nextAction,
              step.dueLabel,
              ...step.tags,
            ],
          );
        })
        .toList(growable: false);
  }
}

class EngineeringSearchService {
  const EngineeringSearchService(this.snapshot);

  final EngineeringSnapshot snapshot;

  List<EngineeringSearchHit> search(String query, {int limit = 18}) {
    final needle = _normalise(query);
    if (needle.isEmpty) {
      return const [];
    }

    final hits = <EngineeringSearchHit>[
      ..._projectHits(needle),
      ..._circuitHits(needle),
      ..._pcbHits(needle),
      ..._firmwareHits(needle),
      ..._deviceHits(needle),
      ..._componentHits(needle),
      ..._experimentHits(needle),
      ..._validationHits(needle),
      ..._manufacturingHits(needle),
      ..._documentHits(needle),
      ..._attachmentHits(needle),
      ..._decisionHits(needle),
    ];

    return hits.take(limit).toList(growable: false);
  }

  List<EngineeringSearchHit> _projectHits(String query) {
    return snapshot.projects
        .where(
          (project) => _matchesQuery(
            query: query,
            values: [
              project.title,
              project.summary,
              project.milestone,
              project.nextAction,
              project.system,
              ...project.tags,
            ],
          ),
        )
        .map(
          (project) => EngineeringSearchHit(
            title: project.title,
            subtitle: project.nextAction,
            kind: 'Project',
            section: EngineeringSection.projects,
            status: project.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _circuitHits(String query) {
    return snapshot.circuitBlocks
        .where(
          (block) => _matchesQuery(
            query: query,
            values: [
              block.title,
              block.category,
              block.function,
              block.nextAction,
              block.notes,
              ...block.tags,
            ],
          ),
        )
        .map(
          (block) => EngineeringSearchHit(
            title: block.title,
            subtitle: block.nextAction,
            kind: 'Circuit',
            section: EngineeringSection.circuitLibrary,
            status: block.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _pcbHits(String query) {
    return snapshot.pcbRevisions
        .where(
          (pcb) => _matchesQuery(
            query: query,
            values: [
              pcb.boardName,
              pcb.revision,
              pcb.status,
              pcb.manufacturingPartner,
              pcb.nextAction,
              pcb.notes,
              ...pcb.tags,
            ],
          ),
        )
        .map(
          (pcb) => EngineeringSearchHit(
            title: '${pcb.boardName} ${pcb.revision}',
            subtitle: pcb.nextAction,
            kind: 'PCB',
            section: EngineeringSection.pcbManager,
            status: pcb.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _firmwareHits(String query) {
    return snapshot.firmwareBuilds
        .where(
          (build) => _matchesQuery(
            query: query,
            values: [
              build.targetDevice,
              build.version,
              build.status,
              build.buildType,
              build.nextAction,
              build.artifactPath,
              ...build.tags,
            ],
          ),
        )
        .map(
          (build) => EngineeringSearchHit(
            title: '${build.targetDevice} ${build.version}',
            subtitle: build.nextAction,
            kind: 'Firmware',
            section: EngineeringSection.firmwareCentre,
            status: build.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _deviceHits(String query) {
    return snapshot.deviceNodes
        .where(
          (device) => _matchesQuery(
            query: query,
            values: [
              device.name,
              device.model,
              device.status,
              device.health,
              device.firmwareVersion,
              device.location,
              device.nextAction,
              device.notes,
              ...device.tags,
            ],
          ),
        )
        .map(
          (device) => EngineeringSearchHit(
            title: device.name,
            subtitle: device.nextAction,
            kind: 'Device',
            section: EngineeringSection.deviceFleet,
            status: device.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _componentHits(String query) {
    return snapshot.componentItems
        .where(
          (item) => _matchesQuery(
            query: query,
            values: [
              item.sku,
              item.name,
              item.category,
              item.status,
              item.preferredVendor,
              item.storageLocation,
              item.nextAction,
              item.notes,
              ...item.tags,
            ],
          ),
        )
        .map(
          (item) => EngineeringSearchHit(
            title: item.name,
            subtitle: item.nextAction,
            kind: 'Component',
            section: EngineeringSection.componentInventory,
            status: item.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _experimentHits(String query) {
    return snapshot.experiments
        .where(
          (experiment) => _matchesQuery(
            query: query,
            values: [
              experiment.title,
              experiment.hypothesis,
              experiment.status,
              experiment.resultSummary,
              experiment.nextAction,
              ...experiment.tags,
            ],
          ),
        )
        .map(
          (experiment) => EngineeringSearchHit(
            title: experiment.title,
            subtitle: experiment.resultSummary,
            kind: 'Experiment',
            section: EngineeringSection.experimentLab,
            status: experiment.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _validationHits(String query) {
    final validationItems = <EngineeringSearchHit>[
      ...snapshot.testProcedures
          .where(
            (procedure) => _matchesQuery(
              query: query,
              values: [
                procedure.title,
                procedure.stage,
                procedure.status,
                procedure.owner,
                procedure.nextAction,
                ...procedure.tags,
              ],
            ),
          )
          .map(
            (procedure) => EngineeringSearchHit(
              title: procedure.title,
              subtitle: procedure.nextAction,
              kind: 'Test',
              section: EngineeringSection.testValidation,
              status: procedure.status,
            ),
          ),
      ...snapshot.validationResults
          .where(
            (result) => _matchesQuery(
              query: query,
              values: [
                result.title,
                result.status,
                result.severity,
                result.verdict,
                result.summary,
                result.nextAction,
              ],
            ),
          )
          .map(
            (result) => EngineeringSearchHit(
              title: result.title,
              subtitle: result.nextAction,
              kind: 'Validation',
              section: EngineeringSection.testValidation,
              status: result.status,
            ),
          ),
    ];
    return validationItems;
  }

  List<EngineeringSearchHit> _manufacturingHits(String query) {
    return snapshot.manufacturingSteps
        .where(
          (step) => _matchesQuery(
            query: query,
            values: [
              step.title,
              step.stage,
              step.status,
              step.owner,
              step.station,
              step.nextAction,
              step.dueLabel,
              ...step.tags,
            ],
          ),
        )
        .map(
          (step) => EngineeringSearchHit(
            title: step.title,
            subtitle: step.nextAction,
            kind: 'Manufacturing',
            section: EngineeringSection.manufacturing,
            status: step.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _documentHits(String query) {
    return snapshot.documents
        .where(
          (document) => _matchesQuery(
            query: query,
            values: [
              document.title,
              document.documentType,
              document.status,
              document.summary,
              document.filePath,
              ...document.tags,
            ],
          ),
        )
        .map(
          (document) => EngineeringSearchHit(
            title: document.title,
            subtitle: document.summary,
            kind: 'Document',
            section: EngineeringSection.documentation,
            status: document.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _attachmentHits(String query) {
    return snapshot.attachments
        .where(
          (attachment) => _matchesQuery(
            query: query,
            values: [
              attachment.title,
              attachment.ownerType,
              attachment.ownerId,
              attachment.kind,
              attachment.filePath,
              attachment.status,
              attachment.notes,
              ...attachment.tags,
            ],
          ),
        )
        .map(
          (attachment) => EngineeringSearchHit(
            title: attachment.title,
            subtitle: attachment.filePath,
            kind: attachment.kind,
            section: EngineeringSection.documentation,
            status: attachment.status,
          ),
        )
        .toList(growable: false);
  }

  List<EngineeringSearchHit> _decisionHits(String query) {
    return snapshot.decisions
        .where(
          (decision) => _matchesQuery(
            query: query,
            values: [
              decision.title,
              decision.decision,
              decision.status,
              decision.confidence,
              decision.rationale,
              decision.nextAction,
              ...decision.tags,
            ],
          ),
        )
        .map(
          (decision) => EngineeringSearchHit(
            title: decision.title,
            subtitle: decision.nextAction,
            kind: 'Decision',
            section: EngineeringSection.documentation,
            status: decision.status,
          ),
        )
        .toList(growable: false);
  }
}

String _normalise(String value) => value.trim().toLowerCase();

bool _matchesQuery({required String query, required Iterable<String> values}) {
  if (query.isEmpty) {
    return true;
  }
  for (final value in values) {
    if (_normalise(value).contains(query)) {
      return true;
    }
  }
  return false;
}

bool _matchesStatus(String value, String filter) {
  final status = _normalise(value);
  final needle = _normalise(filter);
  if (needle.isEmpty || needle == 'all') {
    return true;
  }

  return switch (needle) {
    'active' =>
      status.contains('active') ||
          status.contains('running') ||
          status.contains('online') ||
          status.contains('building'),
    'ready' =>
      status.contains('ready') ||
          status.contains('fab') ||
          status.contains('complete') ||
          status.contains('pass') ||
          status.contains('available'),
    'blocked' =>
      status.contains('block') ||
          status.contains('attention') ||
          status.contains('offline') ||
          status.contains('critical'),
    'paused' => status.contains('paused') || status.contains('park'),
    'draft' => status.contains('draft') || status.contains('plan'),
    _ => status.contains(needle),
  };
}
