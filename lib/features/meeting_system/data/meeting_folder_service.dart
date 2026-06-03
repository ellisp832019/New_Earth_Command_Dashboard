import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../core/constants/omega_os_folder_registry.dart';
import '../../../core/utils/folder_bootstrap_result.dart';

class MeetingCreateRequest {
  const MeetingCreateRequest({
    required this.date,
    required this.project,
    required this.title,
    required this.personOrGroup,
    required this.meetingType,
    required this.purpose,
    this.tags = const <String>[],
  });

  final String date;
  final String project;
  final String title;
  final String personOrGroup;
  final String meetingType;
  final String purpose;
  final List<String> tags;
}

class MeetingCreateResult {
  const MeetingCreateResult({
    required this.meetingId,
    required this.folderPath,
    required this.indexPath,
  });

  final String meetingId;
  final String folderPath;
  final String indexPath;
}

class MeetingBundleResult {
  const MeetingBundleResult({
    required this.bundlePath,
    required this.summaryPath,
    required this.filePaths,
  });

  final String bundlePath;
  final String summaryPath;
  final List<String> filePaths;
}

class MeetingRecord {
  const MeetingRecord({
    required this.id,
    required this.date,
    required this.project,
    required this.title,
    required this.personOrGroup,
    required this.meetingType,
    required this.status,
    required this.folderPath,
    required this.agendaPath,
    required this.notesPath,
    required this.actionsPath,
    required this.decisionsPath,
    required this.followUpPath,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.purpose,
  });

  final String id;
  final String date;
  final String project;
  final String title;
  final String personOrGroup;
  final String meetingType;
  final String status;
  final String folderPath;
  final String agendaPath;
  final String notesPath;
  final String actionsPath;
  final String decisionsPath;
  final String followUpPath;
  final String createdAt;
  final String updatedAt;
  final List<String> tags;
  final String purpose;

  MeetingRecord copyWith({
    String? id,
    String? date,
    String? project,
    String? title,
    String? personOrGroup,
    String? meetingType,
    String? status,
    String? folderPath,
    String? agendaPath,
    String? notesPath,
    String? actionsPath,
    String? decisionsPath,
    String? followUpPath,
    String? createdAt,
    String? updatedAt,
    List<String>? tags,
    String? purpose,
  }) {
    return MeetingRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      project: project ?? this.project,
      title: title ?? this.title,
      personOrGroup: personOrGroup ?? this.personOrGroup,
      meetingType: meetingType ?? this.meetingType,
      status: status ?? this.status,
      folderPath: folderPath ?? this.folderPath,
      agendaPath: agendaPath ?? this.agendaPath,
      notesPath: notesPath ?? this.notesPath,
      actionsPath: actionsPath ?? this.actionsPath,
      decisionsPath: decisionsPath ?? this.decisionsPath,
      followUpPath: followUpPath ?? this.followUpPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      purpose: purpose ?? this.purpose,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'project': project,
      'title': title,
      'person_or_group': personOrGroup,
      'meeting_type': meetingType,
      'status': status,
      'folder_path': folderPath,
      'agenda_path': agendaPath,
      'notes_path': notesPath,
      'actions_path': actionsPath,
      'decisions_path': decisionsPath,
      'follow_up_path': followUpPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'tags': tags,
      'purpose': purpose,
    };
  }

  factory MeetingRecord.fromJson(Map<String, dynamic> json) {
    return MeetingRecord(
      id: _stringValue(json['id']),
      date: _stringValue(json['date']),
      project: _stringValue(json['project']),
      title: _stringValue(json['title']),
      personOrGroup: _firstNonEmpty([
        _stringValue(json['person_or_group']),
        _stringValue(json['personOrGroup']),
      ]),
      meetingType: _firstNonEmpty([
        _stringValue(json['meeting_type']),
        _stringValue(json['meetingType']),
        'Meeting',
      ]),
      status: _firstNonEmpty([_stringValue(json['status']), 'open']),
      folderPath: _firstNonEmpty([
        _stringValue(json['folder_path']),
        _stringValue(json['folderPath']),
      ]),
      agendaPath: _firstNonEmpty([
        _stringValue(json['agenda_path']),
        _stringValue(json['agendaPath']),
      ]),
      notesPath: _firstNonEmpty([
        _stringValue(json['notes_path']),
        _stringValue(json['notesPath']),
      ]),
      actionsPath: _firstNonEmpty([
        _stringValue(json['actions_path']),
        _stringValue(json['actionsPath']),
      ]),
      decisionsPath: _firstNonEmpty([
        _stringValue(json['decisions_path']),
        _stringValue(json['decisionsPath']),
      ]),
      followUpPath: _firstNonEmpty([
        _stringValue(json['follow_up_path']),
        _stringValue(json['followUpPath']),
      ]),
      createdAt: _firstNonEmpty([
        _stringValue(json['created_at']),
        _stringValue(json['createdAt']),
      ]),
      updatedAt: _firstNonEmpty([
        _stringValue(json['updated_at']),
        _stringValue(json['updatedAt']),
      ]),
      tags: _stringListValue(json['tags']),
      purpose: _stringValue(json['purpose']),
    );
  }
}

class MeetingActionRecord {
  const MeetingActionRecord({
    required this.id,
    required this.meetingId,
    required this.meetingTitle,
    required this.meetingDate,
    required this.project,
    required this.action,
    required this.owner,
    required this.dueDate,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String meetingId;
  final String meetingTitle;
  final String meetingDate;
  final String project;
  final String action;
  final String owner;
  final String dueDate;
  final String status;
  final String notes;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'meeting_id': meetingId,
      'meeting_title': meetingTitle,
      'meeting_date': meetingDate,
      'project': project,
      'action': action,
      'owner': owner,
      'due_date': dueDate,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MeetingActionRecord.fromJson(Map<String, dynamic> json) {
    return MeetingActionRecord(
      id: _stringValue(json['id']),
      meetingId: _stringValue(json['meeting_id']),
      meetingTitle: _stringValue(json['meeting_title']),
      meetingDate: _stringValue(json['meeting_date']),
      project: _stringValue(json['project']),
      action: _stringValue(json['action']),
      owner: _stringValue(json['owner']),
      dueDate: _firstNonEmpty([
        _stringValue(json['due_date']),
        _stringValue(json['dueDate']),
      ]),
      status: _firstNonEmpty([_stringValue(json['status']), 'open']),
      notes: _stringValue(json['notes']),
      createdAt: _stringValue(json['created_at']),
      updatedAt: _stringValue(json['updated_at']),
    );
  }
}

class MeetingDecisionRecord {
  const MeetingDecisionRecord({
    required this.id,
    required this.meetingId,
    required this.meetingTitle,
    required this.meetingDate,
    required this.project,
    required this.decision,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String meetingId;
  final String meetingTitle;
  final String meetingDate;
  final String project;
  final String decision;
  final String reason;
  final String status;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'meeting_id': meetingId,
      'meeting_title': meetingTitle,
      'meeting_date': meetingDate,
      'project': project,
      'decision': decision,
      'reason': reason,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MeetingDecisionRecord.fromJson(Map<String, dynamic> json) {
    return MeetingDecisionRecord(
      id: _stringValue(json['id']),
      meetingId: _stringValue(json['meeting_id']),
      meetingTitle: _stringValue(json['meeting_title']),
      meetingDate: _stringValue(json['meeting_date']),
      project: _stringValue(json['project']),
      decision: _stringValue(json['decision']),
      reason: _stringValue(json['reason']),
      status: _firstNonEmpty([_stringValue(json['status']), 'proposed']),
      createdAt: _stringValue(json['created_at']),
      updatedAt: _stringValue(json['updated_at']),
    );
  }
}

class MeetingFollowUpRecord {
  const MeetingFollowUpRecord({
    required this.id,
    required this.meetingId,
    required this.meetingTitle,
    required this.meetingDate,
    required this.project,
    required this.person,
    required this.messageNeeded,
    required this.sent,
    required this.responseReceived,
    required this.nextStep,
    required this.notes,
    required this.messageDraft,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String meetingId;
  final String meetingTitle;
  final String meetingDate;
  final String project;
  final String person;
  final bool messageNeeded;
  final bool sent;
  final bool responseReceived;
  final String nextStep;
  final String notes;
  final String messageDraft;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'meeting_id': meetingId,
      'meeting_title': meetingTitle,
      'meeting_date': meetingDate,
      'project': project,
      'person': person,
      'message_needed': messageNeeded,
      'sent': sent,
      'response_received': responseReceived,
      'next_step': nextStep,
      'notes': notes,
      'message_draft': messageDraft,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MeetingFollowUpRecord.fromJson(Map<String, dynamic> json) {
    return MeetingFollowUpRecord(
      id: _stringValue(json['id']),
      meetingId: _stringValue(json['meeting_id']),
      meetingTitle: _stringValue(json['meeting_title']),
      meetingDate: _stringValue(json['meeting_date']),
      project: _stringValue(json['project']),
      person: _stringValue(json['person']),
      messageNeeded:
          _boolValue(json['message_needed']) ||
          _boolValue(json['messageNeeded']),
      sent: _boolValue(json['sent']),
      responseReceived:
          _boolValue(json['response_received']) ||
          _boolValue(json['responseReceived']),
      nextStep: _firstNonEmpty([
        _stringValue(json['next_step']),
        _stringValue(json['nextStep']),
      ]),
      notes: _stringValue(json['notes']),
      messageDraft: _firstNonEmpty([
        _stringValue(json['message_draft']),
        _stringValue(json['messageDraft']),
      ]),
      createdAt: _stringValue(json['created_at']),
      updatedAt: _stringValue(json['updated_at']),
    );
  }
}

class MeetingListRow {
  const MeetingListRow({
    required this.meeting,
    required this.actionCount,
    required this.decisionCount,
    required this.followUp,
  });

  final MeetingRecord meeting;
  final int actionCount;
  final int decisionCount;
  final MeetingFollowUpRecord? followUp;

  String get followUpLabel {
    if (followUp == null) {
      return 'None';
    }

    if (followUp!.sent && followUp!.responseReceived) {
      return 'Closed';
    }

    if (followUp!.sent) {
      return 'Sent';
    }

    if (followUp!.messageNeeded) {
      return 'Pending';
    }

    return 'Open';
  }
}

class MeetingDetailSnapshot {
  const MeetingDetailSnapshot({
    required this.meeting,
    required this.agendaMarkdown,
    required this.notesMarkdown,
    required this.actions,
    required this.decisions,
    required this.followUp,
    required this.attachmentsFolderPath,
    required this.transcriptsFolderPath,
    required this.exportsFolderPath,
    required this.summaryPath,
  });

  final MeetingRecord meeting;
  final String agendaMarkdown;
  final String notesMarkdown;
  final List<MeetingActionRecord> actions;
  final List<MeetingDecisionRecord> decisions;
  final MeetingFollowUpRecord? followUp;
  final String attachmentsFolderPath;
  final String transcriptsFolderPath;
  final String exportsFolderPath;
  final String summaryPath;
}

class MeetingWorkspaceSnapshot {
  const MeetingWorkspaceSnapshot({
    required this.configPath,
    required this.omegaRootPath,
    required this.meetingsRootPath,
    required this.isReady,
    required this.issues,
    required this.requiredFolders,
    required this.missingFolders,
    required this.missingFiles,
    required this.meetingCount,
    required this.actionCount,
    required this.decisionCount,
    required this.followUpCount,
    required this.guidanceNote,
  });

  final String configPath;
  final String? omegaRootPath;
  final String? meetingsRootPath;
  final bool isReady;
  final List<String> issues;
  final List<String> requiredFolders;
  final List<String> missingFolders;
  final List<String> missingFiles;
  final int meetingCount;
  final int actionCount;
  final int decisionCount;
  final int followUpCount;
  final String guidanceNote;
}

class MeetingDashboardSnapshot {
  const MeetingDashboardSnapshot({
    required this.workspace,
    required this.generatedAt,
    required this.recentMeetings,
    required this.openActions,
    required this.recentDecisions,
    required this.waitingFollowUps,
    required this.meetingsThisWeekCount,
    required this.openActionsCount,
    required this.waitingFollowUpsCount,
    required this.decisionsThisMonthCount,
  });

  final MeetingWorkspaceSnapshot workspace;
  final DateTime generatedAt;
  final List<MeetingRecord> recentMeetings;
  final List<MeetingActionRecord> openActions;
  final List<MeetingDecisionRecord> recentDecisions;
  final List<MeetingFollowUpRecord> waitingFollowUps;
  final int meetingsThisWeekCount;
  final int openActionsCount;
  final int waitingFollowUpsCount;
  final int decisionsThisMonthCount;
}

class MeetingTemplateDocument {
  const MeetingTemplateDocument({
    required this.fileName,
    required this.filePath,
    required this.displayName,
    required this.description,
    required this.preview,
    required this.exists,
  });

  final String fileName;
  final String filePath;
  final String displayName;
  final String description;
  final String preview;
  final bool exists;
}

class MeetingTemplatesSnapshot {
  const MeetingTemplatesSnapshot({
    required this.templateFolderPath,
    required this.documents,
    required this.issues,
  });

  final String? templateFolderPath;
  final List<MeetingTemplateDocument> documents;
  final List<String> issues;

  bool get isReady =>
      templateFolderPath != null &&
      issues.isEmpty &&
      documents.isNotEmpty &&
      documents.every((document) => document.exists);
}

class MeetingOmegaHubFolder {
  const MeetingOmegaHubFolder({
    required this.label,
    required this.path,
    required this.description,
  });

  final String label;
  final String path;
  final String description;
}

class MeetingOmegaHubSnapshot {
  const MeetingOmegaHubSnapshot({
    required this.omegaRootPath,
    required this.projectsRootPath,
    required this.coreFolders,
    required this.projectAreas,
    required this.issues,
  });

  final String? omegaRootPath;
  final String? projectsRootPath;
  final List<MeetingOmegaHubFolder> coreFolders;
  final List<MeetingOmegaHubFolder> projectAreas;
  final List<String> issues;
}

class MeetingMasterIndexSnapshot {
  const MeetingMasterIndexSnapshot({
    required this.indexPath,
    required this.masterLogPath,
    required this.meetingCount,
    required this.preview,
    required this.exists,
  });

  final String indexPath;
  final String masterLogPath;
  final int meetingCount;
  final String preview;
  final bool exists;
}

class MeetingStatusSummarySnapshot {
  const MeetingStatusSummarySnapshot({
    required this.totalCount,
    required this.plannedCount,
    required this.openCount,
    required this.waitingCount,
    required this.completeCount,
    required this.archivedCount,
  });

  final int totalCount;
  final int plannedCount;
  final int openCount;
  final int waitingCount;
  final int completeCount;
  final int archivedCount;
}

class MeetingFolderService {
  MeetingFolderService({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current;

  static const _configRelativePath = 'config/local_paths.json';
  static const _omegaRootKey = 'omega_os_root';
  static const _projectsRootName = '21_PROJECTS_AND_PROGRAMMES';
  static const _meetingsFolderName = '00_MEETINGS_AND_CALLS';
  static const _masterIndexesFolderName = '01_MASTER_INDEXES';
  static const _actionsFolderName = '02_ACTIONS_AND_FOLLOW_UPS';
  static const _decisionsFolderName = '03_DECISIONS_AND_APPROVALS';
  static const _meetingIndexFileName = 'meeting_index.json';
  static const _meetingMasterLogFileName = 'MEETING_MASTER_INDEX.md';
  static const _actionIndexFileName = 'action_index.json';
  static const _actionMasterLogFileName = 'ACTION_MASTER_LOG.md';
  static const _decisionIndexFileName = 'decision_index.json';
  static const _decisionMasterLogFileName = 'DECISION_MASTER_LOG.md';
  static const _followUpIndexFileName = 'follow_up_index.json';
  static const _followUpMasterLogFileName = 'FOLLOW_UP_MASTER_LOG.md';

  static const _agendaTemplateFileName = '00_AGENDA.md';
  static const _notesTemplateFileName = '01_MEETING_NOTES.md';
  static const _actionsTemplateFileName = '02_ACTIONS.md';
  static const _decisionsTemplateFileName = '03_DECISIONS.md';
  static const _followUpTemplateFileName = '04_FOLLOW_UP.md';

  static const _uuid = Uuid();
  static const _monthNames = <String>[
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  static const requiredFolders = <String>[
    '21_PROJECTS_AND_PROGRAMMES',
    '21_PROJECTS_AND_PROGRAMMES/00_MEETINGS_AND_CALLS',
    '21_PROJECTS_AND_PROGRAMMES/01_MASTER_INDEXES',
    '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS',
    '21_PROJECTS_AND_PROGRAMMES/03_DECISIONS_AND_APPROVALS',
    '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES',
    '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder',
  ];

  static const requiredFiles = <String>[
    '21_PROJECTS_AND_PROGRAMMES/01_MASTER_INDEXES/meeting_index.json',
    '21_PROJECTS_AND_PROGRAMMES/01_MASTER_INDEXES/MEETING_MASTER_INDEX.md',
    '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS/action_index.json',
    '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS/follow_up_index.json',
    '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS/ACTION_MASTER_LOG.md',
    '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS/FOLLOW_UP_MASTER_LOG.md',
    '21_PROJECTS_AND_PROGRAMMES/03_DECISIONS_AND_APPROVALS/decision_index.json',
    '21_PROJECTS_AND_PROGRAMMES/03_DECISIONS_AND_APPROVALS/DECISION_MASTER_LOG.md',
    '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/00_AGENDA.md',
    '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/01_MEETING_NOTES.md',
    '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/02_ACTIONS.md',
    '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/03_DECISIONS.md',
    '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/04_FOLLOW_UP.md',
  ];

  final Directory _workingDirectory;

  Future<MeetingWorkspaceSnapshot> loadWorkspace() async {
    final config = await _loadOmegaRootPath();
    final issues = [...config.issues];
    final omegaRootPath = config.omegaRootPath;
    final projectsRootPath = omegaRootPath == null
        ? null
        : path.join(omegaRootPath, _projectsRootName);

    Directory? projectsRoot;
    if (projectsRootPath != null) {
      projectsRoot = Directory(projectsRootPath);
      if (!await projectsRoot.exists()) {
        issues.add(
          'The Meeting System root folder does not exist at the configured Omega OS path.',
        );
      }
    }

    final missingFolders = <String>[];
    if (projectsRoot != null && await projectsRoot.exists()) {
      for (final relativePath in requiredFolders.skip(1)) {
        final candidate = Directory(path.join(omegaRootPath!, relativePath));
        if (!await candidate.exists()) {
          missingFolders.add(relativePath);
        }
      }
    }

    final missingFiles = <String>[];
    if (projectsRoot != null && await projectsRoot.exists()) {
      for (final relativePath in requiredFiles) {
        final candidate = File(path.join(omegaRootPath!, relativePath));
        if (!await candidate.exists()) {
          missingFiles.add(relativePath);
        }
      }
    }

    final meetings = projectsRoot == null
        ? <MeetingRecord>[]
        : await _readMeetingsFromRoot(omegaRootPath!);
    final actions = projectsRoot == null
        ? <MeetingActionRecord>[]
        : await _readActionsFromRoot(omegaRootPath!);
    final decisions = projectsRoot == null
        ? <MeetingDecisionRecord>[]
        : await _readDecisionsFromRoot(omegaRootPath!);
    final followUps = projectsRoot == null
        ? <MeetingFollowUpRecord>[]
        : await _readFollowUpsFromRoot(omegaRootPath!);

    final guidanceNote = projectsRoot == null
        ? 'The Meeting System will calm down once the external Omega OS folder is linked. ${OmegaOsFolderRegistry.reservedSystemsNote}'
        : missingFolders.isEmpty && missingFiles.isEmpty
        ? 'The meeting workspace is connected. Keep meetings local-first and link them to Omega OS rather than copying files around. ${OmegaOsFolderRegistry.reservedSystemsNote}'
        : 'The meeting workspace is present, but a few expected Omega OS folders or starter files still need attention. ${OmegaOsFolderRegistry.reservedSystemsNote}';

    return MeetingWorkspaceSnapshot(
      configPath: config.configPath,
      omegaRootPath: omegaRootPath,
      meetingsRootPath: projectsRootPath,
      isReady:
          issues.isEmpty &&
          omegaRootPath != null &&
          missingFolders.isEmpty &&
          missingFiles.isEmpty,
      issues: issues,
      requiredFolders: requiredFolders,
      missingFolders: missingFolders,
      missingFiles: missingFiles,
      meetingCount: meetings.length,
      actionCount: actions.length,
      decisionCount: decisions.length,
      followUpCount: followUps.length,
      guidanceNote: guidanceNote,
    );
  }

  Future<MeetingDashboardSnapshot> loadDashboardSnapshot() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    final meetings = omegaRootPath == null
        ? <MeetingRecord>[]
        : await _readMeetingsFromRoot(omegaRootPath);
    final actions = omegaRootPath == null
        ? <MeetingActionRecord>[]
        : await _readActionsFromRoot(omegaRootPath);
    final decisions = omegaRootPath == null
        ? <MeetingDecisionRecord>[]
        : await _readDecisionsFromRoot(omegaRootPath);
    final followUps = omegaRootPath == null
        ? <MeetingFollowUpRecord>[]
        : await _readFollowUpsFromRoot(omegaRootPath);

    final today = DateTime.now();
    final recentMeetings = [...meetings]..sort(_sortMeetingsDesc);
    final recentDecisions = [...decisions]..sort(_sortDecisionsDesc);
    final waitingFollowUps = followUps.where(_needsFollowUp).toList()
      ..sort(_sortFollowUpsDesc);
    final openActions = actions.where(_isOpenAction).toList()
      ..sort(_sortActionsAsc);

    return MeetingDashboardSnapshot(
      workspace: workspace,
      generatedAt: today,
      recentMeetings: recentMeetings.take(5).toList(growable: false),
      openActions: openActions.take(5).toList(growable: false),
      recentDecisions: recentDecisions.take(5).toList(growable: false),
      waitingFollowUps: waitingFollowUps.take(5).toList(growable: false),
      meetingsThisWeekCount: recentMeetings
          .where((meeting) => _isInCurrentWeek(meeting.date))
          .length,
      openActionsCount: openActions.length,
      waitingFollowUpsCount: waitingFollowUps.length,
      decisionsThisMonthCount: recentDecisions
          .where((decision) => _isInCurrentMonth(decision.meetingDate))
          .length,
    );
  }

  Future<List<MeetingRecord>> listMeetings() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return <MeetingRecord>[];
    }

    final meetings = await _readMeetingsFromRoot(omegaRootPath);
    meetings.sort(_sortMeetingsDesc);
    return meetings;
  }

  Future<List<MeetingListRow>> listMeetingRows() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return <MeetingListRow>[];
    }

    final meetings = await _readMeetingsFromRoot(omegaRootPath);
    final actions = await _readActionsFromRoot(omegaRootPath);
    final decisions = await _readDecisionsFromRoot(omegaRootPath);
    final followUps = await _readFollowUpsFromRoot(omegaRootPath);

    final actionCounts = <String, int>{};
    for (final action in actions) {
      actionCounts[action.meetingId] =
          (actionCounts[action.meetingId] ?? 0) + 1;
    }

    final decisionCounts = <String, int>{};
    for (final decision in decisions) {
      decisionCounts[decision.meetingId] =
          (decisionCounts[decision.meetingId] ?? 0) + 1;
    }

    final followUpByMeeting = <String, MeetingFollowUpRecord>{};
    for (final followUp in followUps) {
      followUpByMeeting[followUp.meetingId] = followUp;
    }

    final rows = meetings
        .map(
          (meeting) => MeetingListRow(
            meeting: meeting,
            actionCount: actionCounts[meeting.id] ?? 0,
            decisionCount: decisionCounts[meeting.id] ?? 0,
            followUp: followUpByMeeting[meeting.id],
          ),
        )
        .toList(growable: false);
    rows.sort((a, b) => _sortMeetingsDesc(a.meeting, b.meeting));
    return rows;
  }

  Future<List<MeetingActionRecord>> listActions() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return <MeetingActionRecord>[];
    }

    final actions = await _readActionsFromRoot(omegaRootPath);
    actions.sort(_sortActionsAsc);
    return actions;
  }

  Future<List<MeetingDecisionRecord>> listDecisions() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return <MeetingDecisionRecord>[];
    }

    final decisions = await _readDecisionsFromRoot(omegaRootPath);
    decisions.sort(_sortDecisionsDesc);
    return decisions;
  }

  Future<List<MeetingFollowUpRecord>> listFollowUps() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return <MeetingFollowUpRecord>[];
    }

    final followUps = await _readFollowUpsFromRoot(omegaRootPath);
    followUps.sort(_sortFollowUpsDesc);
    return followUps;
  }

  Future<MeetingRecord?> getLatestMeeting() async {
    final meetings = await listMeetings();
    if (meetings.isEmpty) {
      return null;
    }
    return meetings.first;
  }

  Future<MeetingStatusSummarySnapshot> loadStatusSummary() async {
    final meetings = await listMeetings();
    var plannedCount = 0;
    var openCount = 0;
    var waitingCount = 0;
    var completeCount = 0;
    var archivedCount = 0;

    for (final meeting in meetings) {
      switch (meeting.status.trim().toLowerCase()) {
        case 'planned':
          plannedCount++;
          break;
        case 'open':
          openCount++;
          break;
        case 'waiting':
          waitingCount++;
          break;
        case 'complete':
          completeCount++;
          break;
        case 'archived':
          archivedCount++;
          break;
      }
    }

    return MeetingStatusSummarySnapshot(
      totalCount: meetings.length,
      plannedCount: plannedCount,
      openCount: openCount,
      waitingCount: waitingCount,
      completeCount: completeCount,
      archivedCount: archivedCount,
    );
  }

  Future<MeetingTemplatesSnapshot> loadTemplates() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return MeetingTemplatesSnapshot(
        templateFolderPath: null,
        documents: const <MeetingTemplateDocument>[],
        issues: workspace.issues,
      );
    }

    final templateFolderPath = path.join(
      omegaRootPath,
      _projectsRootName,
      '06_TEMPLATES',
      'meeting_folder',
    );
    final folder = Directory(templateFolderPath);
    final documents = <MeetingTemplateDocument>[];
    final specs =
        <
          ({
            String fileName,
            String displayName,
            String description,
            String fallbackPreview,
          })
        >[
          (
            fileName: _agendaTemplateFileName,
            displayName: 'Agenda',
            description:
                'Meeting prep notes, questions, and the outcome you want.',
            fallbackPreview: 'Agenda template not loaded yet.',
          ),
          (
            fileName: _notesTemplateFileName,
            displayName: 'Meeting Notes',
            description:
                'Live notes, actions, and decisions captured during the meeting.',
            fallbackPreview: 'Meeting notes template not loaded yet.',
          ),
          (
            fileName: _actionsTemplateFileName,
            displayName: 'Actions',
            description:
                'Working action log for the meeting and the master action list.',
            fallbackPreview: 'Actions template not loaded yet.',
          ),
          (
            fileName: _decisionsTemplateFileName,
            displayName: 'Decisions',
            description: 'Shared decisions and the reason behind them.',
            fallbackPreview: 'Decisions template not loaded yet.',
          ),
          (
            fileName: _followUpTemplateFileName,
            displayName: 'Follow-up',
            description:
                'Reply draft and follow-up status for after the meeting.',
            fallbackPreview: 'Follow-up template not loaded yet.',
          ),
        ];

    for (final spec in specs) {
      final filePath = path.join(templateFolderPath, spec.fileName);
      final file = File(filePath);
      final exists = await file.exists();
      final content = exists ? await _readTextFile(file) : '';
      documents.add(
        MeetingTemplateDocument(
          fileName: spec.fileName,
          filePath: filePath,
          displayName: spec.displayName,
          description: spec.description,
          preview: _buildTemplatePreview(content, spec.fallbackPreview),
          exists: exists,
        ),
      );
    }

    final issues = <String>[...workspace.issues];
    if (!await folder.exists()) {
      issues.add('The shared meeting template folder is missing.');
    }

    return MeetingTemplatesSnapshot(
      templateFolderPath: templateFolderPath,
      documents: documents,
      issues: issues,
    );
  }

  Future<MeetingMasterIndexSnapshot> loadMasterIndexPreview() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    final indexPath = omegaRootPath == null
        ? path.join(
            _workingDirectory.path,
            _projectsRootName,
            _masterIndexesFolderName,
            _meetingIndexFileName,
          )
        : path.join(
            omegaRootPath,
            _projectsRootName,
            _masterIndexesFolderName,
            _meetingIndexFileName,
          );
    final masterLogPath = omegaRootPath == null
        ? path.join(
            _workingDirectory.path,
            _projectsRootName,
            _masterIndexesFolderName,
            _meetingMasterLogFileName,
          )
        : path.join(
            omegaRootPath,
            _projectsRootName,
            _masterIndexesFolderName,
            _meetingMasterLogFileName,
          );

    final meetings = omegaRootPath == null
        ? <MeetingRecord>[]
        : await listMeetings();
    final masterLogFile = File(masterLogPath);
    final exists = await masterLogFile.exists();
    final preview = exists
        ? _buildPreviewSnippet(await _readTextFile(masterLogFile))
        : _buildMasterIndexPreview(meetings);

    return MeetingMasterIndexSnapshot(
      indexPath: indexPath,
      masterLogPath: masterLogPath,
      meetingCount: meetings.length,
      preview: preview,
      exists: exists,
    );
  }

  Future<MeetingOmegaHubSnapshot> loadOmegaHub() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    final projectsRootPath = omegaRootPath == null
        ? null
        : path.join(omegaRootPath, _projectsRootName);
    final issues = <String>[...workspace.issues];

    final coreFolders = omegaRootPath == null
        ? <MeetingOmegaHubFolder>[]
        : <MeetingOmegaHubFolder>[
            MeetingOmegaHubFolder(
              label: '00_MEETINGS_AND_CALLS',
              path: path.join(
                omegaRootPath,
                _projectsRootName,
                _meetingsFolderName,
              ),
              description:
                  'The living meeting archive. New meetings are created here.',
            ),
            MeetingOmegaHubFolder(
              label: '01_MASTER_INDEXES',
              path: path.join(
                omegaRootPath,
                _projectsRootName,
                _masterIndexesFolderName,
              ),
              description:
                  'The meeting index and the master meeting log for fast lookup.',
            ),
            MeetingOmegaHubFolder(
              label: '02_ACTIONS_AND_FOLLOW_UPS',
              path: path.join(
                omegaRootPath,
                _projectsRootName,
                _actionsFolderName,
              ),
              description:
                  'Open actions, follow-up records, and master action logs.',
            ),
            MeetingOmegaHubFolder(
              label: '03_DECISIONS_AND_APPROVALS',
              path: path.join(
                omegaRootPath,
                _projectsRootName,
                _decisionsFolderName,
              ),
              description:
                  'Decisions and approval trail for the meeting system.',
            ),
            MeetingOmegaHubFolder(
              label: '06_TEMPLATES',
              path: path.join(omegaRootPath, _projectsRootName, '06_TEMPLATES'),
              description:
                  'Reusable starter templates that seed each meeting folder.',
            ),
          ];

    final projectAreas = <MeetingOmegaHubFolder>[];
    if (projectsRootPath != null) {
      final projectsRoot = Directory(projectsRootPath);
      if (await projectsRoot.exists()) {
        try {
          final entries = await projectsRoot.list().toList();
          final reservedNames = <String>{
            _meetingsFolderName,
            _masterIndexesFolderName,
            _actionsFolderName,
            _decisionsFolderName,
            '04_PROJECT_BRIEFS_AND_CURRENT_STATUS',
            '05_PROPOSALS_QUOTES_AND_OUTREACH',
            '06_TEMPLATES',
          };

          for (final entry in entries) {
            if (entry is! Directory) {
              continue;
            }

            final folderName = path.basename(entry.path);
            if (folderName.startsWith('.')) {
              continue;
            }
            if (reservedNames.contains(folderName)) {
              continue;
            }

            projectAreas.add(
              MeetingOmegaHubFolder(
                label: folderName,
                path: entry.path,
                description:
                    'Project area and source-of-truth folder inside Omega OS.',
              ),
            );
          }
          projectAreas.sort((a, b) => a.label.compareTo(b.label));
        } on FileSystemException {
          issues.add(
            'The project areas under 21_PROJECTS_AND_PROGRAMMES could not be listed.',
          );
        }
      }
    }

    return MeetingOmegaHubSnapshot(
      omegaRootPath: omegaRootPath,
      projectsRootPath: projectsRootPath,
      coreFolders: coreFolders,
      projectAreas: projectAreas,
      issues: issues,
    );
  }

  Future<MeetingDetailSnapshot> readMeeting(String meetingId) async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      throw StateError('Omega OS root path is not configured.');
    }

    final meeting = await _findMeetingById(omegaRootPath, meetingId);
    if (meeting == null) {
      throw StateError('Meeting $meetingId could not be found.');
    }

    final meetingDir = Directory(meeting.folderPath);
    final agendaMarkdown = await _readTextFile(
      File(path.join(meetingDir.path, _agendaTemplateFileName)),
    );
    final notesMarkdown = await _readTextFile(
      File(path.join(meetingDir.path, _notesTemplateFileName)),
    );

    final actions =
        (await _readActionsFromRoot(omegaRootPath))
            .where((action) => action.meetingId == meetingId)
            .toList(growable: false)
          ..sort(_sortActionsAsc);
    final decisions =
        (await _readDecisionsFromRoot(omegaRootPath))
            .where((decision) => decision.meetingId == meetingId)
            .toList(growable: false)
          ..sort(_sortDecisionsDesc);
    final followUp = (await _readFollowUpsFromRoot(omegaRootPath))
        .where((item) => item.meetingId == meetingId)
        .toList(growable: false)
        .cast<MeetingFollowUpRecord?>()
        .firstOrNull;

    final attachmentsFolderPath = path.join(meetingDir.path, 'attachments');
    final transcriptsFolderPath = path.join(
      meetingDir.path,
      'audio_or_transcripts',
    );
    final exportsFolderPath = path.join(meetingDir.path, 'exports_pdf');
    final summaryPath = path.join(exportsFolderPath, 'meeting_summary.md');

    return MeetingDetailSnapshot(
      meeting: meeting,
      agendaMarkdown: agendaMarkdown,
      notesMarkdown: notesMarkdown,
      actions: actions,
      decisions: decisions,
      followUp: followUp,
      attachmentsFolderPath: attachmentsFolderPath,
      transcriptsFolderPath: transcriptsFolderPath,
      exportsFolderPath: exportsFolderPath,
      summaryPath: summaryPath,
    );
  }

  Future<MeetingCreateResult> createMeeting(
    MeetingCreateRequest request,
  ) async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      throw StateError('Omega OS root path is not configured.');
    }

    await createMissingRequiredStructure();

    final parsedDate = DateTime.tryParse(request.date);
    if (parsedDate == null) {
      throw StateError('Meeting date must use yyyy-MM-dd.');
    }

    final meetingId = _buildMeetingId(
      request.date,
      request.project,
      request.personOrGroup,
    );
    final meetingFolder = Directory(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _meetingsFolderName,
        parsedDate.year.toString(),
        _monthFolderName(parsedDate),
        _buildMeetingFolderName(
          request.date,
          request.project,
          request.personOrGroup,
        ),
      ),
    );
    await meetingFolder.create(recursive: true);

    for (final folderName in <String>[
      'attachments',
      'audio_or_transcripts',
      'exports_pdf',
    ]) {
      await Directory(
        path.join(meetingFolder.path, folderName),
      ).create(recursive: true);
    }

    final now = DateTime.now().toIso8601String().split('.').first;
    final meeting = MeetingRecord(
      id: meetingId,
      date: request.date,
      project: request.project,
      title: request.title,
      personOrGroup: request.personOrGroup,
      meetingType: request.meetingType,
      status: 'open',
      folderPath: meetingFolder.path,
      agendaPath: path.join(meetingFolder.path, _agendaTemplateFileName),
      notesPath: path.join(meetingFolder.path, _notesTemplateFileName),
      actionsPath: path.join(meetingFolder.path, _actionsTemplateFileName),
      decisionsPath: path.join(meetingFolder.path, _decisionsTemplateFileName),
      followUpPath: path.join(meetingFolder.path, _followUpTemplateFileName),
      createdAt: now,
      updatedAt: now,
      tags: request.tags,
      purpose: request.purpose,
    );

    await File(
      meeting.agendaPath,
    ).writeAsString(_renderAgendaTemplate(meeting), flush: true);
    await File(
      meeting.notesPath,
    ).writeAsString(_renderNotesTemplate(meeting), flush: true);
    await File(meeting.actionsPath).writeAsString(
      _renderActionsTemplate(
        meeting: meeting,
        actions: const <MeetingActionRecord>[],
      ),
      flush: true,
    );
    await File(meeting.decisionsPath).writeAsString(
      _renderDecisionsTemplate(
        meeting: meeting,
        decisions: const <MeetingDecisionRecord>[],
      ),
      flush: true,
    );
    await File(meeting.followUpPath).writeAsString(
      _renderFollowUpTemplate(meeting: meeting, followUp: null),
      flush: true,
    );

    final meetings = await _readMeetingsFromRoot(omegaRootPath);
    meetings.removeWhere((item) => item.id == meeting.id);
    meetings.add(meeting);
    await _writeMeetingIndex(omegaRootPath, meetings);
    await _writeMeetingMasterLog(omegaRootPath, meetings);

    return MeetingCreateResult(
      meetingId: meetingId,
      folderPath: meetingFolder.path,
      indexPath: path.join(
        omegaRootPath,
        _projectsRootName,
        _masterIndexesFolderName,
        _meetingIndexFileName,
      ),
    );
  }

  Future<void> updateMeetingNotes(String meetingId, String markdown) async {
    final snapshot = await readMeeting(meetingId);
    await File(snapshot.meeting.notesPath).writeAsString(markdown, flush: true);
    await _touchMeeting(snapshot.meeting);
  }

  Future<MeetingActionRecord> addAction(
    String meetingId,
    MeetingActionInput input,
  ) async {
    final meeting = await _requireMeeting(meetingId);
    final now = DateTime.now().toIso8601String().split('.').first;
    final action = MeetingActionRecord(
      id: 'act_${_uuid.v4().replaceAll('-', '')}',
      meetingId: meeting.id,
      meetingTitle: meeting.title,
      meetingDate: meeting.date,
      project: meeting.project,
      action: input.action.trim(),
      owner: input.owner.trim(),
      dueDate: input.dueDate.trim(),
      status: input.status.trim().isEmpty ? 'open' : input.status.trim(),
      notes: input.notes.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final actions = await _readActionsFromRoot(_rootPath(meeting.folderPath));
    actions.removeWhere((item) => item.id == action.id);
    actions.add(action);
    await _writeActionsIndex(_rootPath(meeting.folderPath), actions);
    await _writeActionMasterLog(_rootPath(meeting.folderPath), actions);
    await _writeMeetingActionsFile(
      meeting,
      actions
          .where((item) => item.meetingId == meeting.id)
          .toList(growable: false),
    );
    await _touchMeeting(meeting);
    return action;
  }

  Future<MeetingDecisionRecord> addDecision(
    String meetingId,
    MeetingDecisionInput input,
  ) async {
    final meeting = await _requireMeeting(meetingId);
    final now = DateTime.now().toIso8601String().split('.').first;
    final decision = MeetingDecisionRecord(
      id: 'dec_${_uuid.v4().replaceAll('-', '')}',
      meetingId: meeting.id,
      meetingTitle: meeting.title,
      meetingDate: meeting.date,
      project: meeting.project,
      decision: input.decision.trim(),
      reason: input.reason.trim(),
      status: input.status.trim().isEmpty ? 'proposed' : input.status.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final decisions = await _readDecisionsFromRoot(
      _rootPath(meeting.folderPath),
    );
    decisions.removeWhere((item) => item.id == decision.id);
    decisions.add(decision);
    await _writeDecisionsIndex(_rootPath(meeting.folderPath), decisions);
    await _writeDecisionMasterLog(_rootPath(meeting.folderPath), decisions);
    await _writeMeetingDecisionsFile(
      meeting,
      decisions
          .where((item) => item.meetingId == meeting.id)
          .toList(growable: false),
    );
    await _touchMeeting(meeting);
    return decision;
  }

  Future<MeetingFollowUpRecord> updateFollowUp(
    String meetingId,
    MeetingFollowUpInput input,
  ) async {
    final meeting = await _requireMeeting(meetingId);
    final now = DateTime.now().toIso8601String().split('.').first;
    final followUp = MeetingFollowUpRecord(
      id: input.id ?? 'follow_${_uuid.v4().replaceAll('-', '')}',
      meetingId: meeting.id,
      meetingTitle: meeting.title,
      meetingDate: meeting.date,
      project: meeting.project,
      person: input.person.trim(),
      messageNeeded: input.messageNeeded,
      sent: input.sent,
      responseReceived: input.responseReceived,
      nextStep: input.nextStep.trim(),
      notes: input.notes.trim(),
      messageDraft: input.messageDraft.trim(),
      createdAt: input.createdAt ?? now,
      updatedAt: now,
    );

    final followUps = await _readFollowUpsFromRoot(
      _rootPath(meeting.folderPath),
    );
    followUps.removeWhere((item) => item.meetingId == meeting.id);
    followUps.add(followUp);
    await _writeFollowUpsIndex(_rootPath(meeting.folderPath), followUps);
    await _writeFollowUpMasterLog(_rootPath(meeting.folderPath), followUps);
    await _writeMeetingFollowUpFile(meeting, followUp);
    await _touchMeeting(meeting);
    return followUp;
  }

  Future<String> exportMeetingSummary(String meetingId) async {
    final detail = await readMeeting(meetingId);
    final summaryPath = detail.summaryPath;
    final summaryFile = File(summaryPath);
    await summaryFile.parent.create(recursive: true);
    await summaryFile.writeAsString(_renderMeetingSummary(detail), flush: true);
    return summaryPath;
  }

  Future<MeetingBundleResult> exportMeetingBundle(String meetingId) async {
    final detail = await readMeeting(meetingId);
    final bundleFolder = Directory(
      path.join(
        detail.exportsFolderPath,
        'bundles',
        _buildBundleFolderName(detail.meeting),
      ),
    );
    await bundleFolder.create(recursive: true);

    final summaryPath = path.join(bundleFolder.path, 'meeting_summary.md');
    final filePaths = <String>[summaryPath];
    await File(
      summaryPath,
    ).writeAsString(_renderMeetingSummary(detail), flush: true);

    final copies = <({String name, String content})>[
      (name: '00_AGENDA.md', content: detail.agendaMarkdown),
      (name: '01_MEETING_NOTES.md', content: detail.notesMarkdown),
      (
        name: '02_ACTIONS.md',
        content: _renderActionsTemplate(
          meeting: detail.meeting,
          actions: detail.actions,
        ),
      ),
      (
        name: '03_DECISIONS.md',
        content: _renderDecisionsTemplate(
          meeting: detail.meeting,
          decisions: detail.decisions,
        ),
      ),
      (
        name: '04_FOLLOW_UP.md',
        content: _renderFollowUpTemplate(
          meeting: detail.meeting,
          followUp: detail.followUp,
        ),
      ),
    ];

    for (final item in copies) {
      final filePath = path.join(bundleFolder.path, item.name);
      await File(filePath).writeAsString(item.content, flush: true);
      filePaths.add(filePath);
    }

    final manifestPath = path.join(bundleFolder.path, 'bundle_manifest.md');
    final manifest = _renderBundleManifest(
      meeting: detail.meeting,
      bundleFolderPath: bundleFolder.path,
      summaryPath: summaryPath,
      filePaths: filePaths,
    );
    await File(manifestPath).writeAsString(manifest, flush: true);
    filePaths.add(manifestPath);

    return MeetingBundleResult(
      bundlePath: bundleFolder.path,
      summaryPath: summaryPath,
      filePaths: filePaths,
    );
  }

  Future<List<String>> importTranscriptFiles(
    String meetingId,
    List<String> sourceFilePaths,
  ) async {
    final detail = await readMeeting(meetingId);
    final folder = Directory(detail.transcriptsFolderPath);
    await folder.create(recursive: true);

    final importedPaths = <String>[];
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '')
        .replaceAll('-', '');

    for (var index = 0; index < sourceFilePaths.length; index++) {
      final sourcePath = sourceFilePaths[index].trim();
      if (sourcePath.isEmpty) {
        continue;
      }

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        continue;
      }

      final extension = path.extension(sourcePath);
      final fileName = path.basenameWithoutExtension(sourcePath);
      final targetName =
          '${stamp}_${index + 1}_${_folderPart(fileName)}$extension';
      final targetPath = path.join(folder.path, targetName);
      await sourceFile.copy(targetPath);
      importedPaths.add(targetPath);
    }

    if (importedPaths.isNotEmpty) {
      await _touchMeeting(detail.meeting);
    }

    return importedPaths;
  }

  Future<void> openFolder(String folderPath) async {
    if (folderPath.trim().isEmpty) {
      return;
    }

    if (Platform.isWindows) {
      await Process.start('explorer.exe', [folderPath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [folderPath]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [folderPath]);
    }
  }

  Future<void> openFile(String filePath) async {
    if (filePath.trim().isEmpty) {
      return;
    }

    if (Platform.isWindows) {
      await Process.start('cmd.exe', ['/c', 'start', '', filePath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [filePath]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [filePath]);
    }
  }

  Future<FolderBootstrapCreationResult> createMissingRequiredStructure() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return const FolderBootstrapCreationResult(
        createdFolders: <String>[],
        createdFiles: <String>[],
      );
    }

    final omegaRoot = Directory(omegaRootPath);
    if (!await omegaRoot.exists()) {
      return const FolderBootstrapCreationResult(
        createdFolders: <String>[],
        createdFiles: <String>[],
      );
    }

    final createdFolders = <String>[];
    for (final relativeFolder in requiredFolders.skip(1)) {
      final candidate = Directory(path.join(omegaRootPath, relativeFolder));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.create(recursive: true);
      createdFolders.add(relativeFolder);
    }

    final createdFiles = <String>[];
    for (final relativeFile in requiredFiles) {
      final candidate = File(path.join(omegaRootPath, relativeFile));
      if (await candidate.exists()) {
        continue;
      }

      await candidate.parent.create(recursive: true);
      await candidate.writeAsString(_initialFileContent(relativeFile));
      createdFiles.add(relativeFile);
    }

    return FolderBootstrapCreationResult(
      createdFolders: createdFolders,
      createdFiles: createdFiles,
    );
  }

  Future<_ConfigLoadResult> _loadOmegaRootPath() async {
    final configFile = File(
      path.join(_workingDirectory.path, _configRelativePath),
    );
    final issues = <String>[];
    String? omegaRootPath;

    if (!await configFile.exists()) {
      issues.add(
        'config/local_paths.json was not found in the dashboard repo.',
      );
      return _ConfigLoadResult(
        configPath: configFile.path,
        omegaRootPath: null,
        issues: issues,
      );
    }

    try {
      final decoded = jsonDecode(await configFile.readAsString());
      if (decoded is Map<String, dynamic>) {
        final value = decoded[_omegaRootKey];
        if (value is String && value.trim().isNotEmpty) {
          omegaRootPath = value.trim();
        } else {
          issues.add('omega_os_root is missing from config/local_paths.json.');
        }
      } else {
        issues.add('config/local_paths.json should contain a JSON object.');
      }
    } on FormatException {
      issues.add('config/local_paths.json could not be read as JSON.');
    } on FileSystemException {
      issues.add('config/local_paths.json could not be opened.');
    }

    if (omegaRootPath != null) {
      final omegaRoot = Directory(omegaRootPath);
      if (!await omegaRoot.exists()) {
        issues.add('The configured Omega OS root folder does not exist.');
      }
    }

    return _ConfigLoadResult(
      configPath: configFile.path,
      omegaRootPath: omegaRootPath,
      issues: issues,
    );
  }

  Future<List<MeetingRecord>> _readMeetingsFromRoot(
    String omegaRootPath,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _masterIndexesFolderName,
        _meetingIndexFileName,
      ),
    );
    return _readMeetingIndex(file);
  }

  Future<List<MeetingActionRecord>> _readActionsFromRoot(
    String omegaRootPath,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _actionsFolderName,
        _actionIndexFileName,
      ),
    );
    return _readActionsIndex(file);
  }

  Future<List<MeetingDecisionRecord>> _readDecisionsFromRoot(
    String omegaRootPath,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _decisionsFolderName,
        _decisionIndexFileName,
      ),
    );
    return _readDecisionsIndex(file);
  }

  Future<List<MeetingFollowUpRecord>> _readFollowUpsFromRoot(
    String omegaRootPath,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _actionsFolderName,
        _followUpIndexFileName,
      ),
    );
    return _readFollowUpsIndex(file);
  }

  Future<MeetingRecord?> _findMeetingById(
    String omegaRootPath,
    String meetingId,
  ) async {
    final meetings = await _readMeetingsFromRoot(omegaRootPath);
    for (final meeting in meetings) {
      if (meeting.id == meetingId) {
        return meeting;
      }
    }
    return null;
  }

  Future<MeetingRecord> _requireMeeting(String meetingId) async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      throw StateError('Omega OS root path is not configured.');
    }

    final meeting = await _findMeetingById(omegaRootPath, meetingId);
    if (meeting == null) {
      throw StateError('Meeting $meetingId could not be found.');
    }
    return meeting;
  }

  Future<void> _touchMeeting(MeetingRecord meeting) async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return;
    }

    final meetings = await _readMeetingsFromRoot(omegaRootPath);
    final updated = <MeetingRecord>[];
    for (final existing in meetings) {
      if (existing.id == meeting.id) {
        updated.add(
          meeting.copyWith(
            updatedAt: DateTime.now().toIso8601String().split('.').first,
          ),
        );
      } else {
        updated.add(existing);
      }
    }
    await _writeMeetingIndex(omegaRootPath, updated);
    await _writeMeetingMasterLog(omegaRootPath, updated);
  }

  Future<List<MeetingRecord>> _readMeetingIndex(File file) async {
    if (!await file.exists()) {
      return <MeetingRecord>[];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return <MeetingRecord>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => MeetingRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on FormatException {
      return <MeetingRecord>[];
    } on FileSystemException {
      return <MeetingRecord>[];
    }
  }

  Future<List<MeetingActionRecord>> _readActionsIndex(File file) async {
    if (!await file.exists()) {
      return <MeetingActionRecord>[];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return <MeetingActionRecord>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                MeetingActionRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on FormatException {
      return <MeetingActionRecord>[];
    } on FileSystemException {
      return <MeetingActionRecord>[];
    }
  }

  Future<List<MeetingDecisionRecord>> _readDecisionsIndex(File file) async {
    if (!await file.exists()) {
      return <MeetingDecisionRecord>[];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return <MeetingDecisionRecord>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                MeetingDecisionRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on FormatException {
      return <MeetingDecisionRecord>[];
    } on FileSystemException {
      return <MeetingDecisionRecord>[];
    }
  }

  Future<List<MeetingFollowUpRecord>> _readFollowUpsIndex(File file) async {
    if (!await file.exists()) {
      return <MeetingFollowUpRecord>[];
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return <MeetingFollowUpRecord>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                MeetingFollowUpRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on FormatException {
      return <MeetingFollowUpRecord>[];
    } on FileSystemException {
      return <MeetingFollowUpRecord>[];
    }
  }

  Future<void> _writeMeetingIndex(
    String omegaRootPath,
    List<MeetingRecord> meetings,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _masterIndexesFolderName,
        _meetingIndexFileName,
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        meetings.map((meeting) => meeting.toJson()).toList(growable: false),
      ),
      flush: true,
    );
  }

  Future<void> _writeMeetingMasterLog(
    String omegaRootPath,
    List<MeetingRecord> meetings,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _masterIndexesFolderName,
        _meetingMasterLogFileName,
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(_renderMeetingMasterLog(meetings), flush: true);
  }

  Future<void> _writeActionsIndex(
    String omegaRootPath,
    List<MeetingActionRecord> actions,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _actionsFolderName,
        _actionIndexFileName,
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        actions.map((action) => action.toJson()).toList(growable: false),
      ),
      flush: true,
    );
  }

  Future<void> _writeActionMasterLog(
    String omegaRootPath,
    List<MeetingActionRecord> actions,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _actionsFolderName,
        _actionMasterLogFileName,
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(_renderActionMasterLog(actions), flush: true);
  }

  Future<void> _writeDecisionsIndex(
    String omegaRootPath,
    List<MeetingDecisionRecord> decisions,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _decisionsFolderName,
        _decisionIndexFileName,
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        decisions.map((decision) => decision.toJson()).toList(growable: false),
      ),
      flush: true,
    );
  }

  Future<void> _writeDecisionMasterLog(
    String omegaRootPath,
    List<MeetingDecisionRecord> decisions,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _decisionsFolderName,
        _decisionMasterLogFileName,
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(_renderDecisionMasterLog(decisions), flush: true);
  }

  Future<void> _writeFollowUpsIndex(
    String omegaRootPath,
    List<MeetingFollowUpRecord> followUps,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _actionsFolderName,
        _followUpIndexFileName,
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        followUps.map((followUp) => followUp.toJson()).toList(growable: false),
      ),
      flush: true,
    );
  }

  Future<void> _writeFollowUpMasterLog(
    String omegaRootPath,
    List<MeetingFollowUpRecord> followUps,
  ) async {
    final file = File(
      path.join(
        omegaRootPath,
        _projectsRootName,
        _actionsFolderName,
        _followUpMasterLogFileName,
      ),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(_renderFollowUpMasterLog(followUps), flush: true);
  }

  Future<void> _writeMeetingActionsFile(
    MeetingRecord meeting,
    List<MeetingActionRecord> actions,
  ) async {
    await File(meeting.actionsPath).writeAsString(
      _renderActionsTemplate(meeting: meeting, actions: actions),
      flush: true,
    );
  }

  Future<void> _writeMeetingDecisionsFile(
    MeetingRecord meeting,
    List<MeetingDecisionRecord> decisions,
  ) async {
    await File(meeting.decisionsPath).writeAsString(
      _renderDecisionsTemplate(meeting: meeting, decisions: decisions),
      flush: true,
    );
  }

  Future<void> _writeMeetingFollowUpFile(
    MeetingRecord meeting,
    MeetingFollowUpRecord? followUp,
  ) async {
    await File(meeting.followUpPath).writeAsString(
      _renderFollowUpTemplate(meeting: meeting, followUp: followUp),
      flush: true,
    );
  }

  Future<String> _readTextFile(File file) async {
    if (!await file.exists()) {
      return '';
    }

    try {
      return await file.readAsString();
    } on FileSystemException {
      return '';
    }
  }

  String _buildTemplatePreview(String content, String fallbackPreview) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return fallbackPreview;
    }

    final lines = trimmed
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trimRight())
        .toList(growable: false);
    final previewLines = <String>[];
    for (final line in lines) {
      if (line.trim().isEmpty && previewLines.isEmpty) {
        continue;
      }
      previewLines.add(line);
      if (previewLines.length >= 6) {
        break;
      }
    }

    final preview = previewLines.join('\n').trim();
    if (preview.isEmpty) {
      return fallbackPreview;
    }
    if (preview.length <= 320) {
      return preview;
    }
    return '${preview.substring(0, 317)}...';
  }

  String _buildPreviewSnippet(String content) {
    final lines = content
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trimRight())
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) {
      return 'No preview available yet.';
    }
    final previewLines = lines.take(8).toList(growable: false);
    final preview = previewLines.join('\n');
    if (preview.length <= 420) {
      return preview;
    }
    return '${preview.substring(0, 417)}...';
  }

  String _buildMasterIndexPreview(List<MeetingRecord> meetings) {
    if (meetings.isEmpty) {
      return 'No meetings have been added yet, so the master index is still empty.';
    }

    final buffer = StringBuffer()
      ..writeln('# Meeting Master Index Preview')
      ..writeln()
      ..writeln('| Date | Project | Title | Person / Group |')
      ..writeln('|---|---|---|---|');

    for (final meeting in meetings.take(5)) {
      buffer.writeln(
        '| ${meeting.date} | ${meeting.project} | ${meeting.title} | ${meeting.personOrGroup} |',
      );
    }

    if (meetings.length > 5) {
      buffer.writeln();
      buffer.writeln(
        '...and ${meetings.length - 5} more meeting${meetings.length - 5 == 1 ? '' : 's'}.',
      );
    }

    return buffer.toString();
  }

  String _initialFileContent(String relativePath) {
    switch (relativePath) {
      case '21_PROJECTS_AND_PROGRAMMES/01_MASTER_INDEXES/meeting_index.json':
      case '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS/action_index.json':
      case '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS/follow_up_index.json':
      case '21_PROJECTS_AND_PROGRAMMES/03_DECISIONS_AND_APPROVALS/decision_index.json':
        return '[]\n';
      case '21_PROJECTS_AND_PROGRAMMES/01_MASTER_INDEXES/MEETING_MASTER_INDEX.md':
        return _renderMeetingMasterLog(const <MeetingRecord>[]);
      case '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS/ACTION_MASTER_LOG.md':
        return _renderActionMasterLog(const <MeetingActionRecord>[]);
      case '21_PROJECTS_AND_PROGRAMMES/02_ACTIONS_AND_FOLLOW_UPS/FOLLOW_UP_MASTER_LOG.md':
        return _renderFollowUpMasterLog(const <MeetingFollowUpRecord>[]);
      case '21_PROJECTS_AND_PROGRAMMES/03_DECISIONS_AND_APPROVALS/DECISION_MASTER_LOG.md':
        return _renderDecisionMasterLog(const <MeetingDecisionRecord>[]);
      case '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/00_AGENDA.md':
        return _templateAgendaPlaceholder();
      case '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/01_MEETING_NOTES.md':
        return _templateNotesPlaceholder();
      case '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/02_ACTIONS.md':
        return _templateActionsPlaceholder();
      case '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/03_DECISIONS.md':
        return _templateDecisionsPlaceholder();
      case '21_PROJECTS_AND_PROGRAMMES/06_TEMPLATES/meeting_folder/04_FOLLOW_UP.md':
        return _templateFollowUpPlaceholder();
      default:
        return '';
    }
  }

  String _renderAgendaTemplate(MeetingRecord meeting) {
    return '''
# Agenda - ${meeting.title}

| Field | Details |
|---|---|
| Date | ${meeting.date} |
| Project | ${meeting.project} |
| Person / Group | ${meeting.personOrGroup} |
| Meeting Type | ${meeting.meetingType} |

## Purpose

${meeting.purpose.isEmpty ? '' : meeting.purpose}

## Questions

- 

## Documents to show

- 

## Outcome wanted

- 
''';
  }

  String _renderNotesTemplate(MeetingRecord meeting) {
    return '''
# Meeting Notes - ${meeting.title}

## Attendees

- ${meeting.personOrGroup}

## Summary


## Main points

- 

## Actions

| Action | Owner | Due | Status |
|---|---|---|---|
|  | ${meeting.personOrGroup} |  | Open |

## Decisions

- 

## Follow-up needed

- 
''';
  }

  String _renderActionsTemplate({
    required MeetingRecord meeting,
    required List<MeetingActionRecord> actions,
  }) {
    final rows = actions.isEmpty
        ? '|  | ${meeting.personOrGroup} |  | Open |  |'
        : actions
              .map(
                (action) =>
                    '| ${action.action} | ${action.owner} | ${action.dueDate} | ${action.status} | ${action.notes} |',
              )
              .join('\n');

    return '''
# Actions

| Action | Owner | Due Date | Status | Notes |
|---|---|---|---|---|
$rows
''';
  }

  String _renderDecisionsTemplate({
    required MeetingRecord meeting,
    required List<MeetingDecisionRecord> decisions,
  }) {
    final rows = decisions.isEmpty
        ? '|  |  |  | Proposed |'
        : decisions
              .map(
                (decision) =>
                    '| ${decision.decision} | ${decision.reason} | ${meeting.project} | ${decision.status} |',
              )
              .join('\n');

    return '''
# Decisions

| Decision | Reason | Impact | Status |
|---|---|---|---|
$rows
''';
  }

  String _renderFollowUpTemplate({
    required MeetingRecord meeting,
    required MeetingFollowUpRecord? followUp,
  }) {
    final followUpMessage = followUp?.messageDraft.isNotEmpty == true
        ? followUp!.messageDraft
        : '''
Hi ${meeting.personOrGroup},

Thank you for the meeting today.

The key points I took from it were:

- 

My next steps are:

1. 

Thanks,
${meeting.personOrGroup}
''';

    final statusRow = followUp == null
        ? '| No |  |  |  |'
        : '| ${followUp.sent ? 'Yes' : 'No'} | ${followUp.sent ? followUp.updatedAt : ''} | ${followUp.responseReceived ? 'Yes' : 'No'} | ${followUp.nextStep} |';

    return '''
# Follow-up

## Message to send

$followUpMessage

## Follow-up status

| Sent | Date Sent | Response | Next Step |
|---|---|---|---|
$statusRow
''';
  }

  String _renderMeetingMasterLog(List<MeetingRecord> meetings) {
    final rows = meetings.isEmpty
        ? '|  |  |  |  |  |  |  |'
        : meetings
              .map(
                (meeting) =>
                    '| ${meeting.date} | ${meeting.project} | ${meeting.title} | ${meeting.personOrGroup} | ${meeting.status} | ${meeting.folderPath} | 0 | ${meeting.purpose.isEmpty ? 'Open' : 'Open'} |',
              )
              .join('\n');

    return '''
# Meeting Master Index

| Date | Project | Title | Person / Group | Status | Folder | Actions | Follow-up |
|---|---|---|---|---|---|---|---|
$rows
''';
  }

  String _renderActionMasterLog(List<MeetingActionRecord> actions) {
    final rows = actions.isEmpty
        ? '|  |  |  |  |  |  |  |'
        : actions
              .map(
                (action) =>
                    '| ${action.meetingDate} | ${action.project} | ${action.meetingTitle} | ${action.action} | ${action.owner} | ${action.dueDate} | ${action.status} | ${action.notes} |',
              )
              .join('\n');

    return '''
# Action Master Log

| Date | Project | Meeting | Action | Owner | Due | Status | Notes |
|---|---|---|---|---|---|---|---|
$rows
''';
  }

  String _renderDecisionMasterLog(List<MeetingDecisionRecord> decisions) {
    final rows = decisions.isEmpty
        ? '|  |  |  |  |  |  |'
        : decisions
              .map(
                (decision) =>
                    '| ${decision.meetingDate} | ${decision.project} | ${decision.meetingTitle} | ${decision.decision} | ${decision.reason} | ${decision.status} |',
              )
              .join('\n');

    return '''
# Decision Master Log

| Date | Project | Meeting | Decision | Reason | Status |
|---|---|---|---|---|---|
$rows
''';
  }

  String _renderFollowUpMasterLog(List<MeetingFollowUpRecord> followUps) {
    final rows = followUps.isEmpty
        ? '|  |  |  |  |  |  |  |  |'
        : followUps
              .map(
                (followUp) =>
                    '| ${followUp.meetingDate} | ${followUp.project} | ${followUp.meetingTitle} | ${followUp.person} | ${followUp.messageNeeded ? 'Yes' : 'No'} | ${followUp.sent ? 'Yes' : 'No'} | ${followUp.responseReceived ? 'Yes' : 'No'} | ${followUp.nextStep} |',
              )
              .join('\n');

    return '''
# Follow-up Master Log

| Date | Project | Meeting | Person | Message needed | Sent | Response received | Next step |
|---|---|---|---|---|---|---|---|
$rows
''';
  }

  String _renderMeetingSummary(MeetingDetailSnapshot detail) {
    final buffer = StringBuffer()
      ..writeln('# Meeting Summary - ${detail.meeting.title}')
      ..writeln()
      ..writeln('## Metadata')
      ..writeln()
      ..writeln('| Field | Details |')
      ..writeln('|---|---|')
      ..writeln('| Date | ${detail.meeting.date} |')
      ..writeln('| Project | ${detail.meeting.project} |')
      ..writeln('| Person / Group | ${detail.meeting.personOrGroup} |')
      ..writeln('| Meeting Type | ${detail.meeting.meetingType} |')
      ..writeln('| Status | ${detail.meeting.status} |')
      ..writeln('| Folder | ${detail.meeting.folderPath} |')
      ..writeln()
      ..writeln('## Agenda')
      ..writeln()
      ..writeln(detail.agendaMarkdown)
      ..writeln()
      ..writeln('## Notes')
      ..writeln()
      ..writeln(detail.notesMarkdown)
      ..writeln()
      ..writeln('## Actions')
      ..writeln()
      ..writeln(
        _renderActionsTemplate(
          meeting: detail.meeting,
          actions: detail.actions,
        ),
      )
      ..writeln()
      ..writeln('## Decisions')
      ..writeln()
      ..writeln(
        _renderDecisionsTemplate(
          meeting: detail.meeting,
          decisions: detail.decisions,
        ),
      )
      ..writeln()
      ..writeln('## Follow-up')
      ..writeln()
      ..writeln(
        _renderFollowUpTemplate(
          meeting: detail.meeting,
          followUp: detail.followUp,
        ),
      );
    return buffer.toString();
  }

  String _renderBundleManifest({
    required MeetingRecord meeting,
    required String bundleFolderPath,
    required String summaryPath,
    required List<String> filePaths,
  }) {
    final buffer = StringBuffer()
      ..writeln('# Meeting Export Bundle')
      ..writeln()
      ..writeln('| Field | Value |')
      ..writeln('|---|---|')
      ..writeln('| Meeting | ${meeting.title} |')
      ..writeln('| Date | ${meeting.date} |')
      ..writeln('| Project | ${meeting.project} |')
      ..writeln('| Person / Group | ${meeting.personOrGroup} |')
      ..writeln('| Bundle folder | $bundleFolderPath |')
      ..writeln('| Summary | $summaryPath |')
      ..writeln()
      ..writeln('## Included files')
      ..writeln();

    for (final filePath in filePaths) {
      buffer.writeln('- $filePath');
    }

    buffer.writeln();
    buffer.writeln(
      'This bundle keeps the meeting export readable in Omega OS without moving the source meeting files.',
    );
    return buffer.toString();
  }

  String _templateAgendaPlaceholder() {
    return '''
# Agenda - YYYY-MM-DD Project / Person

## Purpose

- 

## What I want to explain

- 

## Questions to ask

- 

## Documents to show

- 

## Outcome wanted

- 
''';
  }

  String _templateNotesPlaceholder() {
    return '''
# Meeting Notes - YYYY-MM-DD Project / Person

## Attendees

- Peter
- 

## Summary


## Main points

- 

## Actions

| Action | Owner | Due | Status |
|---|---|---|---|
|  | Peter |  | Open |

## Decisions

- 

## Follow-up needed

-
''';
  }

  String _templateActionsPlaceholder() {
    return '''
# Actions

| Action | Owner | Due Date | Status | Notes |
|---|---|---|---|---|
|  | Peter |  | Open |  |
''';
  }

  String _templateDecisionsPlaceholder() {
    return '''
# Decisions

| Decision | Reason | Impact | Status |
|---|---|---|---|
|  |  |  | Proposed |
''';
  }

  String _templateFollowUpPlaceholder() {
    return '''
# Follow-up

## Message to send

Hi [Name],

Thank you for the meeting today.

The key points I took from it were:

- 

My next steps are:

1. 

Thanks,
Peter

## Follow-up status

| Sent | Date Sent | Response | Next Step |
|---|---|---|---|
| No |  |  |  |
''';
  }

  String _buildMeetingFolderName(
    String date,
    String project,
    String personOrGroup,
  ) {
    return '${date}_${_folderPart(project)}_${_folderPart(personOrGroup)}';
  }

  String _buildBundleFolderName(MeetingRecord meeting) {
    return '${meeting.date}_${_folderPart(meeting.project)}_${_folderPart(meeting.personOrGroup)}_${_folderPart(meeting.title)}_bundle';
  }

  String _buildMeetingId(String date, String project, String personOrGroup) {
    return 'meet_${date.replaceAll('-', '_')}_${_folderPart(project).toLowerCase()}_${_folderPart(personOrGroup).toLowerCase()}';
  }

  String _monthFolderName(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}_${_monthNames[date.month - 1]}';
  }

  String _folderPart(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    return cleaned
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String _rootPath(String folderPath) {
    return _omegaRootFromMeetingFolderPath(folderPath);
  }

  bool _needsFollowUp(MeetingFollowUpRecord followUp) {
    return followUp.messageNeeded ||
        !followUp.sent ||
        !followUp.responseReceived;
  }

  bool _isOpenAction(MeetingActionRecord action) {
    final status = action.status.trim().toLowerCase();
    return status.isEmpty ||
        status == 'open' ||
        status == 'doing' ||
        status == 'waiting' ||
        status == 'blocked';
  }

  bool _isInCurrentWeek(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) {
      return false;
    }

    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final target = DateTime(date.year, date.month, date.day);
    return !target.isBefore(startOfWeek) && target.isBefore(endOfWeek);
  }

  bool _isInCurrentMonth(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) {
      return false;
    }

    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  int _sortMeetingsDesc(MeetingRecord a, MeetingRecord b) {
    final dateCompare = _parseDate(b.date).compareTo(_parseDate(a.date));
    if (dateCompare != 0) {
      return dateCompare;
    }
    return _parseDate(b.updatedAt).compareTo(_parseDate(a.updatedAt));
  }

  int _sortActionsAsc(MeetingActionRecord a, MeetingActionRecord b) {
    final dueCompare = _parseDate(a.dueDate).compareTo(_parseDate(b.dueDate));
    if (dueCompare != 0) {
      return dueCompare;
    }
    return _parseDate(b.updatedAt).compareTo(_parseDate(a.updatedAt));
  }

  int _sortDecisionsDesc(MeetingDecisionRecord a, MeetingDecisionRecord b) {
    final meetingCompare = _parseDate(
      b.meetingDate,
    ).compareTo(_parseDate(a.meetingDate));
    if (meetingCompare != 0) {
      return meetingCompare;
    }
    return _parseDate(b.updatedAt).compareTo(_parseDate(a.updatedAt));
  }

  int _sortFollowUpsDesc(MeetingFollowUpRecord a, MeetingFollowUpRecord b) {
    final statusCompare = (a.sent ? 1 : 0).compareTo(b.sent ? 1 : 0);
    if (statusCompare != 0) {
      return statusCompare;
    }
    return _parseDate(b.updatedAt).compareTo(_parseDate(a.updatedAt));
  }

  DateTime _parseDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _omegaRootFromMeetingFolderPath(String folderPath) {
    var current = folderPath;
    for (var i = 0; i < 5; i++) {
      current = path.dirname(current);
    }
    return current;
  }
}

class MeetingActionInput {
  const MeetingActionInput({
    required this.action,
    required this.owner,
    required this.dueDate,
    required this.status,
    required this.notes,
  });

  final String action;
  final String owner;
  final String dueDate;
  final String status;
  final String notes;
}

class MeetingDecisionInput {
  const MeetingDecisionInput({
    required this.decision,
    required this.reason,
    required this.status,
  });

  final String decision;
  final String reason;
  final String status;
}

class MeetingFollowUpInput {
  const MeetingFollowUpInput({
    required this.person,
    required this.messageNeeded,
    required this.sent,
    required this.responseReceived,
    required this.nextStep,
    required this.notes,
    required this.messageDraft,
    this.id,
    this.createdAt,
  });

  final String? id;
  final String? createdAt;
  final String person;
  final bool messageNeeded;
  final bool sent;
  final bool responseReceived;
  final String nextStep;
  final String notes;
  final String messageDraft;
}

class _ConfigLoadResult {
  const _ConfigLoadResult({
    required this.configPath,
    required this.omegaRootPath,
    required this.issues,
  });

  final String configPath;
  final String? omegaRootPath;
  final List<String> issues;
}

String _stringValue(dynamic value) {
  if (value is String) {
    return value;
  }
  return '';
}

bool _boolValue(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final trimmed = value.trim().toLowerCase();
    return trimmed == 'true' || trimmed == 'yes' || trimmed == '1';
  }
  return false;
}

List<String> _stringListValue(dynamic value) {
  if (value is List) {
    return value.whereType<String>().toList(growable: false);
  }
  return <String>[];
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

extension _FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
