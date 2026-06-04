import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../../../core/constants/omega_os_folder_registry.dart';
import '../../../core/utils/folder_bootstrap_result.dart';
import '../../voice_assistant/desktop_speech_bridge_service.dart';

class MeetingCreateRequest {
  const MeetingCreateRequest({
    required this.date,
    required this.time,
    required this.timezoneLabel,
    required this.timezoneOffsetMinutes,
    required this.durationMinutes,
    required this.project,
    required this.title,
    required this.personOrGroup,
    required this.meetingType,
    required this.purpose,
    this.tags = const <String>[],
  });

  final String date;
  final String time;
  final String timezoneLabel;
  final int timezoneOffsetMinutes;
  final int durationMinutes;
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

class MeetingBundleReviewSnapshot {
  const MeetingBundleReviewSnapshot({
    required this.bundlePath,
    required this.summaryPath,
    required this.manifestPath,
    required this.fileCount,
    required this.exists,
  });

  final String bundlePath;
  final String summaryPath;
  final String manifestPath;
  final int fileCount;
  final bool exists;
}

class MeetingRecordingImportResult {
  const MeetingRecordingImportResult({
    required this.meeting,
    required this.recordingSourcePath,
    required this.recordingStoredPath,
    required this.transcriptPath,
    required this.recordingModifiedAt,
    required this.minutesFromScheduledWindow,
    required this.matchConfidenceLabel,
    required this.matchExplanation,
    required this.harvestedActionCount,
    required this.harvestedDecisionCount,
    required this.harvestedFollowUpCount,
    required this.transcriptLength,
  });

  final MeetingRecord meeting;
  final String recordingSourcePath;
  final String recordingStoredPath;
  final String transcriptPath;
  final DateTime recordingModifiedAt;
  final int minutesFromScheduledWindow;
  final String matchConfidenceLabel;
  final String matchExplanation;
  final int harvestedActionCount;
  final int harvestedDecisionCount;
  final int harvestedFollowUpCount;
  final int transcriptLength;
}

abstract interface class MeetingRecordingTranscriber {
  Future<MeetingRecordingTranscriptionJob?> startTranscribeFile(
    String sourcePath,
    {String? draftOutputPath}
  );
}

class MeetingRecordingTranscriptionJob {
  const MeetingRecordingTranscriptionJob({
    required this.result,
    required this.cancel,
  });

  final Future<String?> result;
  final VoidCallback cancel;
}

class DesktopMeetingRecordingTranscriber
    implements MeetingRecordingTranscriber {
  DesktopMeetingRecordingTranscriber({
    DesktopSpeechBridgeService? bridgeService,
  }) : _bridgeService = bridgeService ?? DesktopSpeechBridgeService();

  final DesktopSpeechBridgeService _bridgeService;

  @override
  Future<MeetingRecordingTranscriptionJob?> startTranscribeFile(
    String sourcePath,
    {String? draftOutputPath}
  ) async {
    final bridgeJob = await _bridgeService.startTranscribeFile(
      sourcePath,
      draftOutputPath: draftOutputPath,
    );
    return MeetingRecordingTranscriptionJob(
      result: bridgeJob.result.then((capture) {
        final transcript = capture?.transcript.trim() ?? '';
        if (transcript.isEmpty) {
          return null;
        }
        if (capture == null || capture.segments.isEmpty) {
          return transcript;
        }
        return _renderTimestampedTranscript(capture.segments, transcript);
      }),
      cancel: bridgeJob.cancel,
    );
  }

  String _renderTimestampedTranscript(
    List<DesktopSpeechBridgeSegment> segments,
    String transcript,
  ) {
    final buffer = StringBuffer()
      ..writeln('## Timestamped Transcript')
      ..writeln();
    for (final segment in segments) {
      final startLabel = _formatTranscriptTimestamp(segment.startSeconds);
      final endLabel = _formatTranscriptTimestamp(segment.endSeconds);
      buffer.writeln('[$startLabel - $endLabel] ${segment.text}');
    }
    if (buffer.isEmpty) {
      return transcript;
    }
    return buffer.toString().trimRight();
  }

  String _formatTranscriptTimestamp(double seconds) {
    final totalSeconds = seconds.isFinite && seconds > 0 ? seconds.floor() : 0;
    final minutes = totalSeconds ~/ 60;
    final remainingSeconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _RecordingFileCandidate {
  const _RecordingFileCandidate({
    required this.path,
    required this.modifiedAt,
  });

  final String path;
  final DateTime modifiedAt;
}

class _MeetingRecordingMatchCandidate {
  const _MeetingRecordingMatchCandidate({
    required this.meeting,
    required this.meetingStartLocal,
    required this.meetingEndLocal,
    required this.minutesFromScheduledWindow,
    required this.matchConfidenceLabel,
    required this.matchExplanation,
  });

  final MeetingRecord meeting;
  final DateTime? meetingStartLocal;
  final DateTime? meetingEndLocal;
  final int minutesFromScheduledWindow;
  final String matchConfidenceLabel;
  final String matchExplanation;
}

class MeetingAttachmentRecord {
  const MeetingAttachmentRecord({
    required this.path,
    required this.fileName,
    required this.extension,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.preview,
    required this.canPreviewInline,
  });

  final String path;
  final String fileName;
  final String extension;
  final int sizeBytes;
  final DateTime modifiedAt;
  final String? preview;
  final bool canPreviewInline;
}

class MeetingRecord {
  const MeetingRecord({
    required this.id,
    required this.date,
    required this.time,
    required this.timezoneLabel,
    required this.timezoneOffsetMinutes,
    required this.durationMinutes,
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
  final String time;
  final String timezoneLabel;
  final int timezoneOffsetMinutes;
  final int durationMinutes;
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
    String? time,
    String? timezoneLabel,
    int? timezoneOffsetMinutes,
    int? durationMinutes,
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
      time: time ?? this.time,
      timezoneLabel: timezoneLabel ?? this.timezoneLabel,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
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
      'time': time,
      'timezone_label': timezoneLabel,
      'timezone_offset_minutes': timezoneOffsetMinutes,
      'duration_minutes': durationMinutes,
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
      time: _firstNonEmpty([
        _stringValue(json['time']),
        _stringValue(json['meeting_time']),
        _stringValue(json['meetingTime']),
      ]),
      timezoneLabel: _firstNonEmpty([
        _stringValue(json['timezone_label']),
        _stringValue(json['timezoneLabel']),
        _stringValue(json['time_zone']),
        _stringValue(json['timeZone']),
        'Local',
      ]),
      timezoneOffsetMinutes: _intValue(
        json['timezone_offset_minutes'],
        fallback: _intValue(json['timezoneOffsetMinutes'], fallback: 0),
      ),
      durationMinutes: _intValue(
        json['duration_minutes'],
        fallback: _intValue(json['durationMinutes'], fallback: 60),
      ),
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

  bool get hasScheduledTime => time.trim().isNotEmpty;

  String get timezoneDisplayLabel {
    final label = timezoneLabel.trim();
    if (label.isNotEmpty) {
      return label;
    }
    return formatUtcOffsetLabel(timezoneOffsetMinutes);
  }

  String get scheduleDisplayLabel {
    if (!hasScheduledTime) {
      return date;
    }
    return '$date $time ${timezoneDisplayLabel.isEmpty ? '' : timezoneDisplayLabel}';
  }

  DateTime? get scheduledStartUtc => _parseScheduledStartUtc(
    date: date,
    time: time,
    timezoneOffsetMinutes: timezoneOffsetMinutes,
  );

  DateTime? get scheduledEndUtc {
    return _parseScheduledEndUtc(this);
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

  MeetingActionRecord copyWith({
    String? id,
    String? meetingId,
    String? meetingTitle,
    String? meetingDate,
    String? project,
    String? action,
    String? owner,
    String? dueDate,
    String? status,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return MeetingActionRecord(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      meetingTitle: meetingTitle ?? this.meetingTitle,
      meetingDate: meetingDate ?? this.meetingDate,
      project: project ?? this.project,
      action: action ?? this.action,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

class MeetingNotificationRecord {
  const MeetingNotificationRecord({
    required this.id,
    required this.meetingId,
    required this.title,
    required this.message,
    required this.severity,
    required this.meetingDate,
    required this.meetingTime,
    required this.myTimeLabel,
    required this.timezoneLabel,
    required this.createdAt,
    required this.actionLabel,
  });

  final String id;
  final String meetingId;
  final String title;
  final String message;
  final String severity;
  final String meetingDate;
  final String meetingTime;
  final String myTimeLabel;
  final String timezoneLabel;
  final String createdAt;
  final String actionLabel;
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
    required this.upcomingMeetings,
    required this.notifications,
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
  final List<MeetingRecord> upcomingMeetings;
  final List<MeetingNotificationRecord> notifications;
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
  MeetingFolderService({
    Directory? workingDirectory,
    MeetingRecordingTranscriber? recordingTranscriber,
  }) : _workingDirectory = workingDirectory ?? Directory.current,
       _recordingTranscriber =
           recordingTranscriber ?? DesktopMeetingRecordingTranscriber();

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
  static const _supportedRecordingExtensions = <String>{
    '.mkv',
    '.mp4',
    '.mov',
    '.m4v',
    '.webm',
    '.avi',
    '.wmv',
    '.mp3',
    '.m4a',
    '.wav',
    '.flac',
    '.aac',
    '.ogg',
  };

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
  final MeetingRecordingTranscriber _recordingTranscriber;
  MeetingRecordingTranscriptionJob? _activeRecordingTranscriptionJob;

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
    final upcomingMeetings = [...meetings]
      ..removeWhere((meeting) {
        final start = meeting.scheduledStartUtc;
        if (start == null) {
          return true;
        }
        return start.isBefore(today.toUtc().subtract(const Duration(hours: 1)));
      })
      ..sort(_sortMeetingsAscBySchedule);
    final recentDecisions = [...decisions]..sort(_sortDecisionsDesc);
    final waitingFollowUps = followUps.where(_needsFollowUp).toList()
      ..sort(_sortFollowUpsDesc);
    final openActions = actions.where(_isOpenAction).toList()
      ..sort(_sortActionsAsc);
    final notifications = _buildMeetingNotifications(meetings, today);

    return MeetingDashboardSnapshot(
      workspace: workspace,
      generatedAt: today,
      recentMeetings: recentMeetings.take(5).toList(growable: false),
      upcomingMeetings: upcomingMeetings.take(6).toList(growable: false),
      notifications: notifications.take(6).toList(growable: false),
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

  Future<List<MeetingNotificationRecord>> listNotifications() async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      return <MeetingNotificationRecord>[];
    }

    final meetings = await _readMeetingsFromRoot(omegaRootPath);
    return _buildMeetingNotifications(meetings, DateTime.now());
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
    final notesFile = File(path.join(meetingDir.path, _notesTemplateFileName));
    final notesMarkdown = await _readTextFile(notesFile);
    final normalizedNotesMarkdown = _ensureQuestionsForAttendeeSection(
      notesMarkdown,
    );
    if (normalizedNotesMarkdown != notesMarkdown) {
      await notesFile.writeAsString(normalizedNotesMarkdown, flush: true);
      await _touchMeeting(meeting);
    }

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
      notesMarkdown: normalizedNotesMarkdown,
      actions: actions,
      decisions: decisions,
      followUp: followUp,
      attachmentsFolderPath: attachmentsFolderPath,
      transcriptsFolderPath: transcriptsFolderPath,
      exportsFolderPath: exportsFolderPath,
      summaryPath: summaryPath,
    );
  }

  String _ensureQuestionsForAttendeeSection(String markdown) {
    if (markdown.contains('## Questions for attendee')) {
      return markdown;
    }

    final normalized = markdown.replaceAll('\r\n', '\n');
    final lines = normalized.split('\n');
    final summaryIndex = lines.indexWhere(
      (line) => line.trim() == '## Summary',
    );

    final sectionLines = <String>[
      '',
      '## Questions for attendee',
      '',
      '- ',
      '',
    ];

    if (summaryIndex == -1) {
      return '$normalized\n\n## Questions for attendee\n\n- \n';
    }

    final updated = <String>[
      ...lines.take(summaryIndex),
      ...sectionLines,
      ...lines.skip(summaryIndex),
    ];
    return updated.join('\n').replaceFirst(RegExp(r'\n+$'), '\n');
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

    final parsedTime = _parseClockValue(request.time);
    if (parsedTime == null) {
      throw StateError('Meeting time must use HH:mm.');
    }

    if (request.durationMinutes <= 0) {
      throw StateError('Meeting duration must be at least 1 minute.');
    }

    final scheduledStartUtc = _parseScheduledStartUtc(
      date: request.date,
      time: request.time,
      timezoneOffsetMinutes: request.timezoneOffsetMinutes,
    );
    if (scheduledStartUtc == null) {
      throw StateError('Meeting schedule could not be parsed.');
    }
    final scheduledEndUtc = scheduledStartUtc.add(
      Duration(minutes: request.durationMinutes),
    );

    final existingMeetings = await _readMeetingsFromRoot(omegaRootPath);
    for (final existing in existingMeetings) {
      final existingStart = existing.scheduledStartUtc;
      final existingEnd = existing.scheduledEndUtc;
      if (existingStart == null || existingEnd == null) {
        continue;
      }

      final overlaps =
          scheduledStartUtc.isBefore(existingEnd) &&
          existingStart.isBefore(scheduledEndUtc);
      if (overlaps) {
        throw StateError(
          'This meeting overlaps with "${existing.title}" on ${existing.date} at ${existing.time.isEmpty ? 'an unscheduled time' : existing.time}.',
        );
      }
    }

    final meetingId = _buildMeetingId(
      request.date,
      request.project,
      request.personOrGroup,
      request.time,
      request.timezoneOffsetMinutes,
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
          request.time,
          request.timezoneOffsetMinutes,
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
      time: request.time,
      timezoneLabel: request.timezoneLabel,
      timezoneOffsetMinutes: request.timezoneOffsetMinutes,
      durationMinutes: request.durationMinutes,
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

    existingMeetings.removeWhere((item) => item.id == meeting.id);
    existingMeetings.add(meeting);
    await _writeMeetingIndex(omegaRootPath, existingMeetings);
    await _writeMeetingMasterLog(omegaRootPath, existingMeetings);

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
    final actions = await _readActionsFromRoot(_rootPath(meeting.folderPath));
    final actionText = input.action.trim();
    final owner = input.owner.trim();
    final dueDate = input.dueDate.trim();
    final status = input.status.trim().isEmpty ? 'open' : input.status.trim();
    final notes = input.notes.trim();

    final duplicateExists = actions.any(
      (item) =>
          item.meetingId == meeting.id &&
          _isDuplicateAction(item, action: actionText, owner: owner),
    );
    if (duplicateExists) {
      throw StateError('This action already exists for this meeting.');
    }

    final action = MeetingActionRecord(
      id: 'act_${_uuid.v4().replaceAll('-', '')}',
      meetingId: meeting.id,
      meetingTitle: meeting.title,
      meetingDate: meeting.date,
      project: meeting.project,
      action: actionText,
      owner: owner,
      dueDate: dueDate,
      status: status,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final updatedActions = <MeetingActionRecord>[...actions, action];
    final dedupedActions = _dedupeActions(updatedActions);
    await _writeActionsIndex(_rootPath(meeting.folderPath), dedupedActions);
    await _writeActionMasterLog(_rootPath(meeting.folderPath), dedupedActions);
    await _writeMeetingActionsFile(
      meeting,
      dedupedActions
          .where((item) => item.meetingId == meeting.id)
          .toList(growable: false),
    );
    await _touchMeeting(meeting);
    return action;
  }

  Future<MeetingActionRecord> updateAction(
    String meetingId,
    String actionId,
    MeetingActionInput input,
  ) async {
    final meeting = await _requireMeeting(meetingId);
    final now = DateTime.now().toIso8601String().split('.').first;
    final actions = await _readActionsFromRoot(_rootPath(meeting.folderPath));
    final existingIndex = actions.indexWhere((item) => item.id == actionId);
    if (existingIndex == -1) {
      throw StateError('Action $actionId could not be found.');
    }

    final actionText = input.action.trim();
    final owner = input.owner.trim();
    final dueDate = input.dueDate.trim();
    final status = input.status.trim().isEmpty ? 'open' : input.status.trim();
    final notes = input.notes.trim();

    final duplicate = actions.any(
      (item) =>
          item.meetingId == meeting.id &&
          item.id != actionId &&
          _isDuplicateAction(item, action: actionText, owner: owner),
    );
    if (duplicate) {
      throw StateError('This action already exists for this meeting.');
    }

    final updatedAction = actions[existingIndex].copyWith(
      meetingTitle: meeting.title,
      meetingDate: meeting.date,
      project: meeting.project,
      action: actionText,
      owner: owner,
      dueDate: dueDate,
      status: status,
      notes: notes,
      updatedAt: now,
    );

    final updatedActions = <MeetingActionRecord>[
      for (var i = 0; i < actions.length; i++)
        if (i == existingIndex) updatedAction else actions[i],
    ];
    final dedupedActions = _dedupeActions(updatedActions);
    await _writeActionsIndex(_rootPath(meeting.folderPath), dedupedActions);
    await _writeActionMasterLog(_rootPath(meeting.folderPath), dedupedActions);
    await _writeMeetingActionsFile(
      meeting,
      dedupedActions
          .where((item) => item.meetingId == meeting.id)
          .toList(growable: false),
    );
    await _touchMeeting(meeting);
    return updatedAction;
  }

  Future<void> deleteAction(String meetingId, String actionId) async {
    final meeting = await _requireMeeting(meetingId);
    final actions = await _readActionsFromRoot(_rootPath(meeting.folderPath));
    final existingIndex = actions.indexWhere((item) => item.id == actionId);
    if (existingIndex == -1) {
      throw StateError('Action $actionId could not be found.');
    }

    final updatedActions = <MeetingActionRecord>[
      for (var i = 0; i < actions.length; i++)
        if (i != existingIndex) actions[i],
    ];
    final dedupedActions = _dedupeActions(updatedActions);
    await _writeActionsIndex(_rootPath(meeting.folderPath), dedupedActions);
    await _writeActionMasterLog(_rootPath(meeting.folderPath), dedupedActions);
    await _writeMeetingActionsFile(
      meeting,
      dedupedActions
          .where((item) => item.meetingId == meeting.id)
          .toList(growable: false),
    );
    await _touchMeeting(meeting);
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

  Future<MeetingDecisionRecord> updateDecision(
    String meetingId,
    String decisionId,
    MeetingDecisionInput input,
  ) async {
    final meeting = await _requireMeeting(meetingId);
    final now = DateTime.now().toIso8601String().split('.').first;
    final decisions = await _readDecisionsFromRoot(
      _rootPath(meeting.folderPath),
    );
    final existingIndex = decisions.indexWhere((item) => item.id == decisionId);
    if (existingIndex == -1) {
      throw StateError('Decision $decisionId could not be found.');
    }

    final updatedDecision = MeetingDecisionRecord(
      id: decisions[existingIndex].id,
      meetingId: meeting.id,
      meetingTitle: meeting.title,
      meetingDate: meeting.date,
      project: meeting.project,
      decision: input.decision.trim(),
      reason: input.reason.trim(),
      status: input.status.trim().isEmpty ? 'proposed' : input.status.trim(),
      createdAt: decisions[existingIndex].createdAt,
      updatedAt: now,
    );

    decisions[existingIndex] = updatedDecision;
    await _writeDecisionsIndex(_rootPath(meeting.folderPath), decisions);
    await _writeDecisionMasterLog(_rootPath(meeting.folderPath), decisions);
    await _writeMeetingDecisionsFile(
      meeting,
      decisions
          .where((item) => item.meetingId == meeting.id)
          .toList(growable: false),
    );
    await _touchMeeting(meeting);
    return updatedDecision;
  }

  Future<void> deleteDecision(String meetingId, String decisionId) async {
    final meeting = await _requireMeeting(meetingId);
    final decisions = await _readDecisionsFromRoot(
      _rootPath(meeting.folderPath),
    );
    final existingIndex = decisions.indexWhere((item) => item.id == decisionId);
    if (existingIndex == -1) {
      throw StateError('Decision $decisionId could not be found.');
    }

    decisions.removeAt(existingIndex);
    await _writeDecisionsIndex(_rootPath(meeting.folderPath), decisions);
    await _writeDecisionMasterLog(_rootPath(meeting.folderPath), decisions);
    await _writeMeetingDecisionsFile(
      meeting,
      decisions
          .where((item) => item.meetingId == meeting.id)
          .toList(growable: false),
    );
    await _touchMeeting(meeting);
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

  Future<void> deleteFollowUp(String meetingId) async {
    final meeting = await _requireMeeting(meetingId);
    final followUps = await _readFollowUpsFromRoot(
      _rootPath(meeting.folderPath),
    );
    final before = followUps.length;
    followUps.removeWhere((item) => item.meetingId == meeting.id);
    if (followUps.length == before) {
      throw StateError('No follow-up record was found for this meeting.');
    }

    await _writeFollowUpsIndex(_rootPath(meeting.folderPath), followUps);
    await _writeFollowUpMasterLog(_rootPath(meeting.folderPath), followUps);
    await _writeMeetingFollowUpFile(meeting, null);
    await _touchMeeting(meeting);
  }

  Future<MeetingRecord> updateMeetingSchedule(
    String meetingId,
    MeetingScheduleInput input,
  ) async {
    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      throw StateError('Omega OS root path is not configured.');
    }

    final existingMeeting = await _requireMeeting(meetingId);
    final parsedDate = DateTime.tryParse(input.date);
    if (parsedDate == null) {
      throw StateError('Meeting date must use yyyy-MM-dd.');
    }

    final parsedTime = _parseClockValue(input.time);
    if (parsedTime == null) {
      throw StateError('Meeting time must use HH:mm.');
    }

    if (input.durationMinutes <= 0) {
      throw StateError('Meeting duration must be at least 1 minute.');
    }

    final scheduledStartUtc = _parseScheduledStartUtc(
      date: input.date,
      time: input.time,
      timezoneOffsetMinutes: input.timezoneOffsetMinutes,
    );
    if (scheduledStartUtc == null) {
      throw StateError('Meeting schedule could not be parsed.');
    }
    final scheduledEndUtc = scheduledStartUtc.add(
      Duration(minutes: input.durationMinutes),
    );

    final existingMeetings = await _readMeetingsFromRoot(omegaRootPath);
    for (final other in existingMeetings) {
      if (other.id == existingMeeting.id) {
        continue;
      }

      final otherStart = other.scheduledStartUtc;
      final otherEnd = other.scheduledEndUtc;
      if (otherStart == null || otherEnd == null) {
        continue;
      }

      final overlaps =
          scheduledStartUtc.isBefore(otherEnd) &&
          otherStart.isBefore(scheduledEndUtc);
      if (overlaps) {
        throw StateError(
          'This meeting overlaps with "${other.title}" on ${other.date} at ${other.time.isEmpty ? 'an unscheduled time' : other.time}.',
        );
      }
    }

    final oldFolder = Directory(existingMeeting.folderPath);
    final newFolderPath = path.join(
      omegaRootPath,
      _projectsRootName,
      _meetingsFolderName,
      parsedDate.year.toString(),
      _monthFolderName(parsedDate),
      _buildMeetingFolderName(
        input.date,
        existingMeeting.project,
        existingMeeting.personOrGroup,
        input.time,
        input.timezoneOffsetMinutes,
      ),
    );

    if (path.normalize(existingMeeting.folderPath) !=
        path.normalize(newFolderPath)) {
      await Directory(path.dirname(newFolderPath)).create(recursive: true);
      if (await oldFolder.exists()) {
        await oldFolder.rename(newFolderPath);
      } else {
        await Directory(newFolderPath).create(recursive: true);
      }
    }

    final updatedMeeting = existingMeeting.copyWith(
      date: input.date,
      time: input.time,
      timezoneLabel: input.timezoneLabel,
      timezoneOffsetMinutes: input.timezoneOffsetMinutes,
      durationMinutes: input.durationMinutes,
      folderPath: newFolderPath,
      agendaPath: path.join(newFolderPath, _agendaTemplateFileName),
      notesPath: path.join(newFolderPath, _notesTemplateFileName),
      actionsPath: path.join(newFolderPath, _actionsTemplateFileName),
      decisionsPath: path.join(newFolderPath, _decisionsTemplateFileName),
      followUpPath: path.join(newFolderPath, _followUpTemplateFileName),
      updatedAt: DateTime.now().toIso8601String().split('.').first,
    );

    final updatedMeetings = <MeetingRecord>[];
    for (final meeting in existingMeetings) {
      if (meeting.id == existingMeeting.id) {
        updatedMeetings.add(updatedMeeting);
      } else {
        updatedMeetings.add(meeting);
      }
    }

    await _writeMeetingIndex(omegaRootPath, updatedMeetings);
    await _writeMeetingMasterLog(omegaRootPath, updatedMeetings);
    return updatedMeeting;
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

  Future<MeetingBundleReviewSnapshot?> loadLatestBundleReview(
    String meetingId,
  ) async {
    final detail = await readMeeting(meetingId);
    final bundlesFolder = Directory(
      path.join(detail.exportsFolderPath, 'bundles'),
    );
    if (!await bundlesFolder.exists()) {
      return null;
    }

    final bundleFolders = bundlesFolder
        .listSync()
        .whereType<Directory>()
        .toList(growable: false);
    if (bundleFolders.isEmpty) {
      return null;
    }

    bundleFolders.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      final modifiedCompare = bStat.modified.compareTo(aStat.modified);
      if (modifiedCompare != 0) {
        return modifiedCompare;
      }
      return path.basename(b.path).compareTo(path.basename(a.path));
    });

    final latest = bundleFolders.first;
    final summaryPath = path.join(latest.path, 'meeting_summary.md');
    final manifestPath = path.join(latest.path, 'bundle_manifest.md');
    final fileCount = latest.listSync().whereType<File>().length;
    final exists =
        await File(summaryPath).exists() && await File(manifestPath).exists();

    return MeetingBundleReviewSnapshot(
      bundlePath: latest.path,
      summaryPath: summaryPath,
      manifestPath: manifestPath,
      fileCount: fileCount,
      exists: exists,
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

  Future<List<String>> importAttachmentFiles(
    String meetingId,
    List<String> sourceFilePaths,
  ) async {
    final detail = await readMeeting(meetingId);
    final folder = Directory(detail.attachmentsFolderPath);
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

  Future<List<MeetingAttachmentRecord>> listTranscriptFiles(
    String meetingId,
  ) async {
    final detail = await readMeeting(meetingId);
    final folder = Directory(detail.transcriptsFolderPath);
    if (!await folder.exists()) {
      return <MeetingAttachmentRecord>[];
    }

    final transcripts = <MeetingAttachmentRecord>[];
    for (final entity in folder.listSync().whereType<File>()) {
      final stat = await entity.stat();
      final extension = path.extension(entity.path).toLowerCase();
      transcripts.add(
        MeetingAttachmentRecord(
          path: entity.path,
          fileName: path.basename(entity.path),
          extension: extension,
          sizeBytes: stat.size,
          modifiedAt: stat.modified,
          preview: await _attachmentPreview(entity, extension),
          canPreviewInline: _isInlinePreviewExtension(extension),
        ),
      );
    }

    transcripts.sort((a, b) {
      final modifiedCompare = b.modifiedAt.compareTo(a.modifiedAt);
      if (modifiedCompare != 0) {
        return modifiedCompare;
      }
      return a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase());
    });

    return transcripts;
  }

  Future<MeetingRecordingImportResult> importLatestRecordingFromFolder(
    String folderPath,
    {
    void Function(String status)? onStatus,
    bool Function()? isCancelled,
  }
  ) async {
    onStatus?.call('Scanning recording folder...');
    if (isCancelled?.call() == true) {
      throw StateError('Import cancelled.');
    }
    final folder = Directory(folderPath.trim());
    if (!await folder.exists()) {
      throw StateError('The selected recording folder does not exist.');
    }

    final candidates = await _listRecordingFiles(folder);
    if (candidates.isEmpty) {
      throw StateError(
        'No supported audio or video files were found in the selected folder.',
      );
    }

    onStatus?.call('Matching recording to the closest meeting...');
    if (isCancelled?.call() == true) {
      throw StateError('Import cancelled.');
    }
    return importRecordingFile(
      candidates.first.path,
      onStatus: onStatus,
      isCancelled: isCancelled,
    );
  }

  void cancelActiveRecordingImport() {
    _activeRecordingTranscriptionJob?.cancel();
  }

  Future<MeetingRecordingImportResult> importRecordingFile(
    String sourceFilePath,
    {
    void Function(String status)? onStatus,
    bool Function()? isCancelled,
  }
  ) async {
    onStatus?.call('Reading meeting schedule...');
    if (isCancelled?.call() == true) {
      throw StateError('Import cancelled.');
    }
    final sourceFile = File(sourceFilePath.trim());
    if (!await sourceFile.exists()) {
      throw StateError('The selected recording file does not exist.');
    }

    final workspace = await loadWorkspace();
    final omegaRootPath = workspace.omegaRootPath;
    if (omegaRootPath == null) {
      throw StateError('Omega OS root path is not configured.');
    }

    final meetings = await _readMeetingsFromRoot(omegaRootPath);
    final recordingStat = await sourceFile.stat();
    final recordingModifiedAt = recordingStat.modified.toLocal();
    final match = _matchRecordingToMeeting(meetings, recordingModifiedAt);
    if (match == null) {
      throw StateError(
        'No meeting could be matched to the selected recording timestamp.',
      );
    }

    final detail = await readMeeting(match.meeting.id);
    final transcriptsFolder = Directory(detail.transcriptsFolderPath);
    await transcriptsFolder.create(recursive: true);

    final stamp = _timestampSlug(recordingModifiedAt);
    final sourceName = _folderPart(path.basenameWithoutExtension(sourceFile.path));
    final extension = path.extension(sourceFile.path).toLowerCase();
    final recordingTargetPath = path.join(
      transcriptsFolder.path,
      '$stamp' '_' '$sourceName$extension',
    );
    final transcriptTargetPath = path.join(
      transcriptsFolder.path,
      '$stamp' '_' '$sourceName' '_transcript.md',
    );
    final draftTranscriptPath = '$transcriptTargetPath.draft.md';

    onStatus?.call('Transcribing recording with Whisper...');
    if (isCancelled?.call() == true) {
      throw StateError('Import cancelled.');
    }
    final transcriptionJob = await _recordingTranscriber.startTranscribeFile(
      sourceFile.path,
      draftOutputPath: draftTranscriptPath,
    );
    _activeRecordingTranscriptionJob = transcriptionJob;
    String? transcript;
    try {
      transcript = await transcriptionJob?.result;
    } finally {
      _activeRecordingTranscriptionJob = null;
    }
    final cleanedTranscript = transcript?.trim() ?? '';
    if (cleanedTranscript.isEmpty) {
      throw StateError('The recording could not be transcribed.');
    }
    if (isCancelled?.call() == true) {
      throw StateError('Import cancelled.');
    }

    onStatus?.call('Saving transcript into the meeting folder...');
    if (isCancelled?.call() == true) {
      throw StateError('Import cancelled.');
    }
    await sourceFile.copy(recordingTargetPath);
    final transcriptMarkdown = _renderImportedRecordingTranscript(
      meeting: match.meeting,
      sourcePath: sourceFile.path,
      storedRecordingPath: recordingTargetPath,
      recordingModifiedAt: recordingModifiedAt,
      minutesFromScheduledWindow: match.minutesFromScheduledWindow,
      transcript: cleanedTranscript,
    );
    await File(transcriptTargetPath).writeAsString(
      transcriptMarkdown,
      flush: true,
    );

    final harvest = await _harvestTranscriptArtifacts(
      meeting: match.meeting,
      transcriptMarkdown: transcriptMarkdown,
    );

    await _touchMeeting(match.meeting);

    return MeetingRecordingImportResult(
      meeting: match.meeting,
      recordingSourcePath: sourceFile.path,
      recordingStoredPath: recordingTargetPath,
      transcriptPath: transcriptTargetPath,
      recordingModifiedAt: recordingModifiedAt,
      minutesFromScheduledWindow: match.minutesFromScheduledWindow,
      matchConfidenceLabel: match.matchConfidenceLabel,
      matchExplanation: match.matchExplanation,
      harvestedActionCount: harvest.actionCount,
      harvestedDecisionCount: harvest.decisionCount,
      harvestedFollowUpCount: harvest.followUpCount,
      transcriptLength: cleanedTranscript.length,
    );
  }

  Future<List<MeetingAttachmentRecord>> listAttachmentFiles(
    String meetingId,
  ) async {
    final detail = await readMeeting(meetingId);
    final folder = Directory(detail.attachmentsFolderPath);
    if (!await folder.exists()) {
      return <MeetingAttachmentRecord>[];
    }

    final attachments = <MeetingAttachmentRecord>[];
    for (final entity in folder.listSync().whereType<File>()) {
      final stat = await entity.stat();
      final extension = path.extension(entity.path).toLowerCase();
      attachments.add(
        MeetingAttachmentRecord(
          path: entity.path,
          fileName: path.basename(entity.path),
          extension: extension,
          sizeBytes: stat.size,
          modifiedAt: stat.modified,
          preview: await _attachmentPreview(entity, extension),
          canPreviewInline: _isInlinePreviewExtension(extension),
        ),
      );
    }

    attachments.sort((a, b) {
      final modifiedCompare = b.modifiedAt.compareTo(a.modifiedAt);
      if (modifiedCompare != 0) {
        return modifiedCompare;
      }
      return a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase());
    });

    return attachments;
  }

  Future<void> openFolder(String folderPath) async {
    if (folderPath.trim().isEmpty) {
      return;
    }

    final normalizedPath = path.normalize(folderPath.trim());

    if (Platform.isWindows) {
      await Process.start('explorer.exe', [normalizedPath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [normalizedPath]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [normalizedPath]);
    }
  }

  Future<void> openFile(String filePath) async {
    if (filePath.trim().isEmpty) {
      return;
    }

    final normalizedPath = path.normalize(filePath.trim());

    if (Platform.isWindows) {
      await Process.start('cmd.exe', ['/c', 'start', '', normalizedPath]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.start('open', [normalizedPath]);
      return;
    }

    if (Platform.isLinux) {
      await Process.start('xdg-open', [normalizedPath]);
    }
  }

  Future<String?> _attachmentPreview(File file, String extension) async {
    if (_isDocxExtension(extension)) {
      return _docxPreview(file);
    }

    if (_isInlinePreviewExtension(extension)) {
      try {
        final content = await file.readAsString();
        final lines = content
            .replaceAll('\r\n', '\n')
            .split('\n')
            .map((line) => line.trimRight())
            .where((line) => line.trim().isNotEmpty)
            .toList(growable: false);
        if (lines.isEmpty) {
          return 'No text preview available yet.';
        }

        final previewLines = lines.take(12).toList(growable: false);
        final preview = previewLines.join('\n');
        if (preview.length <= 600) {
          return preview;
        }
        return '${preview.substring(0, 597)}...';
      } on FileSystemException {
        return null;
      } on FormatException {
        return null;
      }
    }

    return null;
  }

  Future<String?> _docxPreview(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final documentEntry = archive.findFile('word/document.xml');
      if (documentEntry == null) {
        return null;
      }

      final documentBytes = documentEntry.content as List<int>;

      final xml = XmlDocument.parse(utf8.decode(documentBytes));
      final paragraphs = xml.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == 'p')
          .map((paragraph) {
            final text = paragraph.descendants
                .whereType<XmlElement>()
                .where((element) => element.name.local == 't')
                .map((node) => node.innerText)
                .join();
            return text.trim();
          })
          .where((line) => line.isNotEmpty)
          .toList(growable: false);

      if (paragraphs.isEmpty) {
        return null;
      }

      final preview = paragraphs.take(12).join('\n\n');
      if (preview.length <= 600) {
        return preview;
      }
      return '${preview.substring(0, 597)}...';
    } on FileSystemException {
      return null;
    } on ArchiveException {
      return null;
    } on FormatException {
      return null;
    } on XmlException {
      return null;
    }
  }

  bool _isInlinePreviewExtension(String extension) {
    switch (extension.toLowerCase()) {
      case '.txt':
      case '.md':
      case '.csv':
      case '.json':
      case '.log':
      case '.yaml':
      case '.yml':
        return true;
      default:
        return false;
    }
  }

  bool _isDocxExtension(String extension) {
    return extension.toLowerCase() == '.docx';
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
          omegaRootPath = path.normalize(value.trim());
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
          .toList();
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

      return _dedupeActions(
        decoded
            .whereType<Map>()
            .map(
              (item) =>
                  MeetingActionRecord.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );
    } on FormatException {
      return <MeetingActionRecord>[];
    } on FileSystemException {
      return <MeetingActionRecord>[];
    }
  }

  List<MeetingActionRecord> _dedupeActions(List<MeetingActionRecord> actions) {
    if (actions.length < 2) {
      return actions;
    }

    final bySignature = <String, MeetingActionRecord>{};
    for (final action in actions) {
      final signature = _actionSignature(action);
      final existing = bySignature[signature];
      if (existing == null) {
        bySignature[signature] = action;
        continue;
      }

      if (_isNewerAction(action, existing)) {
        bySignature[signature] = action;
      }
    }

    final deduped = bySignature.values.toList(growable: false);
    deduped.sort(_sortActionsAsc);
    return deduped;
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
          .toList();
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
          .toList();
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

## Questions for attendee

- 

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
        ? '|  |  |  |  |  |  |  |  |  |'
        : meetings
              .map(
                (meeting) =>
                    '| ${meeting.date} | ${meeting.time.isEmpty ? '—' : meeting.time} | ${meeting.timezoneDisplayLabel} | ${meeting.project} | ${meeting.title} | ${meeting.personOrGroup} | ${meeting.status} | ${meeting.folderPath} | 0 | ${meeting.purpose.isEmpty ? 'Open' : 'Open'} |',
              )
              .join('\n');

    return '''
# Meeting Master Index

| Date | Time | Timezone | Project | Title | Person / Group | Status | Folder | Actions | Follow-up |
|---|---|---|---|---|---|---|---|---|---|
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
      ..writeln(
        '| Time | ${detail.meeting.time.isEmpty ? 'Not scheduled' : detail.meeting.time} |',
      )
      ..writeln('| Timezone | ${detail.meeting.timezoneDisplayLabel} |')
      ..writeln('| Duration | ${detail.meeting.durationMinutes} min |')
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
      ..writeln(
        '| Time | ${meeting.time.isEmpty ? 'Not scheduled' : meeting.time} |',
      )
      ..writeln('| Timezone | ${meeting.timezoneDisplayLabel} |')
      ..writeln('| Duration | ${meeting.durationMinutes} min |')
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

  Future<List<_RecordingFileCandidate>> _listRecordingFiles(
    Directory folder,
  ) async {
    final candidates = <_RecordingFileCandidate>[];

    try {
      await for (final entity in folder.list(recursive: true, followLinks: false)) {
        if (entity is! File) {
          continue;
        }

        if (!_isSupportedRecordingFile(entity.path)) {
          continue;
        }

        final stat = await entity.stat();
        candidates.add(
          _RecordingFileCandidate(
            path: entity.path,
            modifiedAt: stat.modified.toLocal(),
          ),
        );
      }
    } on FileSystemException {
      return <_RecordingFileCandidate>[];
    }

    candidates.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return candidates;
  }

  bool _isSupportedRecordingFile(String filePath) {
    return _supportedRecordingExtensions.contains(
      path.extension(filePath).toLowerCase(),
    );
  }

  _MeetingRecordingMatchCandidate? _matchRecordingToMeeting(
    List<MeetingRecord> meetings,
    DateTime recordingModifiedAt,
  ) {
    final recordingDay = DateTime(
      recordingModifiedAt.year,
      recordingModifiedAt.month,
      recordingModifiedAt.day,
    );

    final candidates = <_MeetingRecordingMatchCandidate>[];
    for (final meeting in meetings) {
      final meetingStartLocal = meeting.scheduledStartUtc?.toLocal();
      final meetingEndLocal = meeting.scheduledEndUtc?.toLocal();
      if (meetingStartLocal == null || meetingEndLocal == null) {
        continue;
      }

      final meetingDay = DateTime(
        meetingStartLocal.year,
        meetingStartLocal.month,
        meetingStartLocal.day,
      );
      final dayDistance = recordingDay.difference(meetingDay).inDays.abs();
      if (dayDistance > 1) {
        continue;
      }

      candidates.add(
        _MeetingRecordingMatchCandidate(
          meeting: meeting,
          meetingStartLocal: meetingStartLocal,
          meetingEndLocal: meetingEndLocal,
          minutesFromScheduledWindow: _minutesFromWindow(
            recordingModifiedAt,
            meetingStartLocal,
            meetingEndLocal,
          ),
          matchConfidenceLabel: _matchConfidenceLabel(
            recordingModifiedAt,
            meetingStartLocal,
            meetingEndLocal,
          ),
          matchExplanation: _matchConfidenceExplanation(
            recordingModifiedAt,
            meetingStartLocal,
            meetingEndLocal,
          ),
        ),
      );
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) {
      final windowCompare = a.minutesFromScheduledWindow.compareTo(
        b.minutesFromScheduledWindow,
      );
      if (windowCompare != 0) {
        return windowCompare;
      }

      final aStartDistance = _absoluteDuration(
        recordingModifiedAt.difference(a.meetingStartLocal!),
      );
      final bStartDistance = _absoluteDuration(
        recordingModifiedAt.difference(b.meetingStartLocal!),
      );
      final startCompare = aStartDistance.compareTo(bStartDistance);
      if (startCompare != 0) {
        return startCompare;
      }

      return _parseDate(b.meeting.date).compareTo(_parseDate(a.meeting.date));
    });

    return candidates.first;
  }

  String _matchConfidenceLabel(
    DateTime recordingModifiedAt,
    DateTime windowStart,
    DateTime windowEnd,
  ) {
    final minutesFromWindow = _minutesFromWindow(
      recordingModifiedAt,
      windowStart,
      windowEnd,
    );
    if (minutesFromWindow == 0) {
      return 'High';
    }
    if (minutesFromWindow <= 20) {
      return 'Medium';
    }
    return 'Low';
  }

  String _matchConfidenceExplanation(
    DateTime recordingModifiedAt,
    DateTime windowStart,
    DateTime windowEnd,
  ) {
    final minutesFromWindow = _minutesFromWindow(
      recordingModifiedAt,
      windowStart,
      windowEnd,
    );
    if (minutesFromWindow == 0) {
      return 'The recording timestamp lands inside the scheduled meeting window.';
    }
    if (minutesFromWindow <= 20) {
      return 'The recording timestamp is close to the scheduled window.';
    }
    return 'The recording timestamp is farther from the meeting window, so review the match before relying on it.';
  }

  int _minutesFromWindow(
    DateTime recordingModifiedAt,
    DateTime windowStart,
    DateTime windowEnd,
  ) {
    if (!recordingModifiedAt.isBefore(windowStart) &&
        !recordingModifiedAt.isAfter(windowEnd)) {
      return 0;
    }

    final distance = recordingModifiedAt.isBefore(windowStart)
        ? windowStart.difference(recordingModifiedAt)
        : recordingModifiedAt.difference(windowEnd);
    return distance.inMinutes.abs();
  }

  Duration _absoluteDuration(Duration duration) {
    return Duration(milliseconds: duration.inMilliseconds.abs());
  }

  String _renderImportedRecordingTranscript({
    required MeetingRecord meeting,
    required String sourcePath,
    required String storedRecordingPath,
    required DateTime recordingModifiedAt,
    required int minutesFromScheduledWindow,
    required String transcript,
  }) {
    final buffer = StringBuffer()
      ..writeln('# Imported Recording Transcript')
      ..writeln()
      ..writeln('| Field | Value |')
      ..writeln('|---|---|')
      ..writeln('| Meeting | ${meeting.title} |')
      ..writeln('| Date | ${meeting.date} |')
      ..writeln(
        '| Time | ${meeting.time.isEmpty ? 'Not scheduled' : meeting.time} |',
      )
      ..writeln('| Project | ${meeting.project} |')
      ..writeln('| Person / Group | ${meeting.personOrGroup} |')
      ..writeln('| Source file | $sourcePath |')
      ..writeln('| Stored recording | $storedRecordingPath |')
      ..writeln(
        '| File modified | ${_formatTimestampLabel(recordingModifiedAt)} |',
      )
      ..writeln('| Distance from window | $minutesFromScheduledWindow min |')
      ..writeln()
      ..writeln('## Transcript')
      ..writeln()
      ..writeln(transcript.trim());
    return buffer.toString().replaceFirst(RegExp(r'\s+$'), '\n');
  }

  Future<_HarvestResult> _harvestTranscriptArtifacts({
    required MeetingRecord meeting,
    required String transcriptMarkdown,
  }) async {
    final plainTranscript = _plainTranscriptFromMarkdown(transcriptMarkdown);
    if (plainTranscript.trim().isEmpty) {
      return const _HarvestResult();
    }

    final sentences = _splitTranscriptSentences(plainTranscript);
    var actionCount = 0;
    var decisionCount = 0;
    var followUpCount = 0;

    for (final sentence in sentences) {
      final normalized = sentence.toLowerCase();

      if (actionCount < 3 && _looksLikeAction(sentence, normalized)) {
        try {
          await addAction(
            meeting.id,
            MeetingActionInput(
              action: sentence,
              owner: meeting.personOrGroup,
              dueDate: '',
              status: 'open',
              notes: 'Auto-harvested from imported transcript.',
            ),
          );
          actionCount += 1;
        } on StateError {
          // Ignore duplicates or malformed suggestions.
        }
      }

      if (decisionCount < 3 && _looksLikeDecision(sentence, normalized)) {
        try {
          await addDecision(
            meeting.id,
            MeetingDecisionInput(
              decision: sentence,
              reason: 'Auto-harvested from imported transcript.',
              status: 'proposed',
            ),
          );
          decisionCount += 1;
        } on StateError {
          // Ignore duplicates or malformed suggestions.
        }
      }

      if (followUpCount < 3 && _looksLikeFollowUp(sentence, normalized)) {
        try {
          await updateFollowUp(
            meeting.id,
            MeetingFollowUpInput(
              person: meeting.personOrGroup,
              messageNeeded: true,
              sent: false,
              responseReceived: false,
              nextStep: sentence,
              notes: 'Auto-harvested from imported transcript.',
              messageDraft: sentence,
            ),
          );
          followUpCount += 1;
        } on StateError {
          // Ignore duplicates or malformed suggestions.
        }
      }
    }

    return _HarvestResult(
      actionCount: actionCount,
      decisionCount: decisionCount,
      followUpCount: followUpCount,
    );
  }

  String _plainTranscriptFromMarkdown(String transcriptMarkdown) {
    final lines = transcriptMarkdown.replaceAll('\r\n', '\n').split('\n');
    final plainLines = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      if (trimmed.startsWith('## ')) {
        continue;
      }
      if (trimmed.startsWith('[') && trimmed.contains('] ')) {
        final closingIndex = trimmed.indexOf('] ');
        if (closingIndex != -1 && closingIndex + 2 < trimmed.length) {
          plainLines.add(trimmed.substring(closingIndex + 2));
          continue;
        }
      }
      plainLines.add(trimmed);
    }
    return plainLines.join(' ');
  }

  List<String> _splitTranscriptSentences(String transcript) {
    final normalized = transcript.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return const <String>[];
    }
    final matches = RegExp(r'[^.!?]+[.!?]?').allMatches(normalized);
    final sentences = <String>[];
    for (final match in matches) {
      final sentence = match.group(0)?.trim() ?? '';
      if (sentence.isNotEmpty) {
        sentences.add(sentence);
      }
    }
    return sentences;
  }

  bool _looksLikeAction(String sentence, String normalized) {
    if (sentence.length < 12) {
      return false;
    }
    return normalized.contains('action') ||
        normalized.contains('next step') ||
        normalized.contains('follow up') ||
        normalized.contains('we need to') ||
        normalized.contains("we'll") ||
        normalized.contains('we should') ||
        normalized.contains('please') ||
        normalized.contains('can you') ||
        normalized.contains('i will');
  }

  bool _looksLikeDecision(String sentence, String normalized) {
    if (sentence.length < 12) {
      return false;
    }
    return normalized.contains('decid') ||
        normalized.contains('agreed') ||
        normalized.contains('decision') ||
        normalized.contains('we will proceed');
  }

  bool _looksLikeFollowUp(String sentence, String normalized) {
    if (sentence.length < 12) {
      return false;
    }
    return normalized.contains('follow up') ||
        normalized.contains('follow-up') ||
        normalized.contains('message') ||
        normalized.contains('email') ||
        normalized.contains('check in');
  }

  String _formatTimestampLabel(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  String _timestampSlug(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$year$month$day-$hour$minute$second';
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

## Questions for attendee

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
    String time,
    int timezoneOffsetMinutes,
  ) {
    final timePart = time.replaceAll(':', '');
    final offsetPart = _folderPart(formatUtcOffsetLabel(timezoneOffsetMinutes));
    return '${date}_${_folderPart(project)}_${_folderPart(personOrGroup)}_${timePart}_$offsetPart';
  }

  String _buildBundleFolderName(MeetingRecord meeting) {
    final timePart = meeting.time.replaceAll(':', '');
    final offsetPart = _folderPart(
      formatUtcOffsetLabel(meeting.timezoneOffsetMinutes),
    );
    return '${meeting.date}_${_folderPart(meeting.project)}_${_folderPart(meeting.personOrGroup)}_${timePart}_${offsetPart}_${_folderPart(meeting.title)}_bundle';
  }

  String _buildMeetingId(
    String date,
    String project,
    String personOrGroup,
    String time,
    int timezoneOffsetMinutes,
  ) {
    final timePart = time.replaceAll(':', '_');
    final offsetPart = _folderPart(
      formatUtcOffsetLabel(timezoneOffsetMinutes),
    ).toLowerCase();
    final datePart = date.replaceAll('-', '_');
    final projectPart = _folderPart(project).toLowerCase();
    final personPart = _folderPart(personOrGroup).toLowerCase();
    return <String>[
      'meet',
      datePart,
      projectPart,
      personPart,
      timePart,
      offsetPart,
    ].join('_');
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

  List<MeetingNotificationRecord> _buildMeetingNotifications(
    List<MeetingRecord> meetings,
    DateTime now,
  ) {
    final nowUtc = now.toUtc();
    final notifications = <MeetingNotificationRecord>[];

    for (final meeting in meetings) {
      final start = meeting.scheduledStartUtc;
      if (start == null) {
        notifications.add(
          MeetingNotificationRecord(
            id: 'missing_${meeting.id}',
            meetingId: meeting.id,
            title: 'Add a time',
            message: '${meeting.title} still needs a start time and timezone.',
            severity: 'warning',
            meetingDate: meeting.date,
            meetingTime: 'TBD',
            myTimeLabel: 'TBD',
            timezoneLabel: meeting.timezoneDisplayLabel,
            createdAt: now.toIso8601String(),
            actionLabel: 'Open meeting',
          ),
        );
        continue;
      }

      final minutesUntil = start.difference(nowUtc).inMinutes;
      if (minutesUntil <= 0 && minutesUntil > -30) {
        notifications.add(
          MeetingNotificationRecord(
            id: 'starting_${meeting.id}',
            meetingId: meeting.id,
            title: 'Meeting starting now',
            message: '${meeting.title} is happening now.',
            severity: 'high',
            meetingDate: meeting.date,
            meetingTime: meeting.time,
            myTimeLabel: _formatClock(start.toLocal()),
            timezoneLabel: meeting.timezoneDisplayLabel,
            createdAt: now.toIso8601String(),
            actionLabel: 'Open meeting',
          ),
        );
        continue;
      }

      if (minutesUntil > 0 && minutesUntil <= 60) {
        notifications.add(
          MeetingNotificationRecord(
            id: 'soon_${meeting.id}',
            meetingId: meeting.id,
            title: 'Meeting in $minutesUntil min',
            message:
                '${meeting.title} starts at ${meeting.time} ${meeting.timezoneDisplayLabel}.',
            severity: minutesUntil <= 15 ? 'high' : 'info',
            meetingDate: meeting.date,
            meetingTime: meeting.time,
            myTimeLabel: _formatClock(start.toLocal()),
            timezoneLabel: meeting.timezoneDisplayLabel,
            createdAt: now.toIso8601String(),
            actionLabel: 'Open meeting',
          ),
        );
      }
    }

    notifications.sort((a, b) => a.severity.compareTo(b.severity));
    return notifications;
  }

  int _sortMeetingsDesc(MeetingRecord a, MeetingRecord b) {
    final aStart = a.scheduledStartUtc;
    final bStart = b.scheduledStartUtc;

    if (aStart != null && bStart != null) {
      final scheduleCompare = bStart.compareTo(aStart);
      if (scheduleCompare != 0) {
        return scheduleCompare;
      }
    } else if (aStart != null) {
      return -1;
    } else if (bStart != null) {
      return 1;
    }

    final dateCompare = _parseDate(b.date).compareTo(_parseDate(a.date));
    if (dateCompare != 0) {
      return dateCompare;
    }
    return _parseDate(b.updatedAt).compareTo(_parseDate(a.updatedAt));
  }

  int _sortMeetingsAscBySchedule(MeetingRecord a, MeetingRecord b) {
    final aStart = a.scheduledStartUtc;
    final bStart = b.scheduledStartUtc;

    if (aStart != null && bStart != null) {
      final scheduleCompare = aStart.compareTo(bStart);
      if (scheduleCompare != 0) {
        return scheduleCompare;
      }
    } else if (aStart != null) {
      return -1;
    } else if (bStart != null) {
      return 1;
    }

    final dateCompare = _parseDate(a.date).compareTo(_parseDate(b.date));
    if (dateCompare != 0) {
      return dateCompare;
    }
    return _parseDate(a.updatedAt).compareTo(_parseDate(b.updatedAt));
  }

  int _sortActionsAsc(MeetingActionRecord a, MeetingActionRecord b) {
    final dueCompare = _parseDate(a.dueDate).compareTo(_parseDate(b.dueDate));
    if (dueCompare != 0) {
      return dueCompare;
    }
    return _parseDate(b.updatedAt).compareTo(_parseDate(a.updatedAt));
  }

  bool _isDuplicateAction(
    MeetingActionRecord existing, {
    required String action,
    required String owner,
  }) {
    return _normalizeActionKey(existing.action) ==
            _normalizeActionKey(action) &&
        _normalizeActionKey(existing.owner) == _normalizeActionKey(owner);
  }

  bool _isNewerAction(
    MeetingActionRecord candidate,
    MeetingActionRecord current,
  ) {
    final candidateUpdated = DateTime.tryParse(candidate.updatedAt);
    final currentUpdated = DateTime.tryParse(current.updatedAt);
    if (candidateUpdated != null && currentUpdated != null) {
      return candidateUpdated.isAfter(currentUpdated);
    }
    if (candidateUpdated != null) {
      return true;
    }
    if (currentUpdated != null) {
      return false;
    }
    return candidate.id.compareTo(current.id) > 0;
  }

  String _actionSignature(MeetingActionRecord action) {
    return [
      action.meetingId.trim().toLowerCase(),
      _normalizeActionKey(action.action),
      _normalizeActionKey(action.owner),
    ].join('|');
  }

  String _normalizeActionKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
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

class MeetingScheduleInput {
  const MeetingScheduleInput({
    required this.date,
    required this.time,
    required this.timezoneLabel,
    required this.timezoneOffsetMinutes,
    required this.durationMinutes,
  });

  final String date;
  final String time;
  final String timezoneLabel;
  final int timezoneOffsetMinutes;
  final int durationMinutes;
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

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
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

String formatUtcOffsetLabel(int offsetMinutes) {
  final totalMinutes = offsetMinutes.abs();
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  final sign = offsetMinutes >= 0 ? '+' : '-';
  final minuteText = minutes.toString().padLeft(2, '0');
  return 'UTC$sign${hours.toString().padLeft(2, '0')}:$minuteText';
}

String _formatClock(DateTime dateTime) {
  final hours = dateTime.hour.toString().padLeft(2, '0');
  final minutes = dateTime.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

DateTime? _parseScheduledStartUtc({
  required String date,
  required String time,
  required int timezoneOffsetMinutes,
}) {
  final parsedDate = DateTime.tryParse(date);
  final parsedTime = _parseClockValue(time);
  if (parsedDate == null || parsedTime == null) {
    return null;
  }

  final utcDateTime = DateTime.utc(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    parsedTime.hour,
    parsedTime.minute,
  );
  return utcDateTime.subtract(Duration(minutes: timezoneOffsetMinutes));
}

DateTime? _parseScheduledEndUtc(MeetingRecord meeting) {
  final start = _parseScheduledStartUtc(
    date: meeting.date,
    time: meeting.time,
    timezoneOffsetMinutes: meeting.timezoneOffsetMinutes,
  );
  if (start == null) {
    return null;
  }
  final minutes = meeting.durationMinutes <= 0 ? 60 : meeting.durationMinutes;
  return start.add(Duration(minutes: minutes));
}

DateTime? _parseClockValue(String value) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
  if (match == null) {
    return null;
  }

  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    return null;
  }

  return DateTime(1970, 1, 1, hour, minute);
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

class _HarvestResult {
  const _HarvestResult({
    this.actionCount = 0,
    this.decisionCount = 0,
    this.followUpCount = 0,
  });

  final int actionCount;
  final int decisionCount;
  final int followUpCount;
}
