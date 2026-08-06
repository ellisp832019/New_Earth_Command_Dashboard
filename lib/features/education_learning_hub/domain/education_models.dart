import 'package:flutter/foundation.dart';

enum EducationAudience { all, student, mentor, parentGuardian, admin }

extension EducationAudienceLabel on EducationAudience {
  String get label {
    switch (this) {
      case EducationAudience.all:
        return 'All';
      case EducationAudience.student:
        return 'Student';
      case EducationAudience.mentor:
        return 'Mentor';
      case EducationAudience.parentGuardian:
        return 'Parent / Guardian';
      case EducationAudience.admin:
        return 'Admin';
    }
  }
}

class LearningPathway {
  const LearningPathway({
    required this.id,
    required this.title,
    required this.summary,
    required this.level,
    required this.estimatedHours,
    required this.domain,
    required this.audiences,
    required this.skillTags,
    required this.units,
  });

  final String id;
  final String title;
  final String summary;
  final String level;
  final int estimatedHours;
  final String domain;
  final List<String> audiences;
  final List<String> skillTags;
  final List<ModuleUnit> units;

  factory LearningPathway.fromJson(Map<String, dynamic> json) {
    return LearningPathway(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      estimatedHours: json['estimatedHours'] is int
          ? json['estimatedHours'] as int
          : int.tryParse(json['estimatedHours']?.toString() ?? '') ?? 0,
      domain: json['domain']?.toString() ?? '',
      audiences: _stringList(json['audiences']),
      skillTags: _stringList(json['skillTags']),
      units: _moduleUnits(json['units']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'level': level,
      'estimatedHours': estimatedHours,
      'domain': domain,
      'audiences': audiences,
      'skillTags': skillTags,
      'units': units.map((unit) => unit.toJson()).toList(growable: false),
    };
  }
}

class ModuleUnit {
  const ModuleUnit({
    required this.id,
    required this.title,
    required this.summary,
    required this.estimatedHours,
    required this.lessons,
  });

  final String id;
  final String title;
  final String summary;
  final int estimatedHours;
  final List<String> lessons;

  factory ModuleUnit.fromJson(Map<String, dynamic> json) {
    return ModuleUnit(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      estimatedHours: json['estimatedHours'] is int
          ? json['estimatedHours'] as int
          : int.tryParse(json['estimatedHours']?.toString() ?? '') ?? 0,
      lessons: _stringList(json['lessons']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'estimatedHours': estimatedHours,
      'lessons': lessons,
    };
  }
}

class Lesson {
  const Lesson({
    required this.id,
    required this.pathwayId,
    required this.unitId,
    required this.title,
    required this.summary,
    required this.objective,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.audiences,
    required this.tags,
    required this.steps,
    required this.resourceIds,
    required this.reflectionPrompt,
    this.sourceTitle = '',
    this.sourcePath = '',
    this.sourceKind = 'Seed',
  });

  final String id;
  final String pathwayId;
  final String unitId;
  final String title;
  final String summary;
  final String objective;
  final int estimatedMinutes;
  final String difficulty;
  final List<String> audiences;
  final List<String> tags;
  final List<String> steps;
  final List<String> resourceIds;
  final String reflectionPrompt;
  final String sourceTitle;
  final String sourcePath;
  final String sourceKind;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id']?.toString() ?? '',
      pathwayId: json['pathwayId']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      objective: json['objective']?.toString() ?? '',
      estimatedMinutes: json['estimatedMinutes'] is int
          ? json['estimatedMinutes'] as int
          : int.tryParse(json['estimatedMinutes']?.toString() ?? '') ?? 0,
      difficulty: json['difficulty']?.toString() ?? '',
      audiences: _stringList(json['audiences']),
      tags: _stringList(json['tags']),
      steps: _stringList(json['steps']),
      resourceIds: _stringList(json['resourceIds']),
      reflectionPrompt: json['reflectionPrompt']?.toString() ?? '',
      sourceTitle: json['sourceTitle']?.toString() ?? '',
      sourcePath: json['sourcePath']?.toString() ?? '',
      sourceKind: json['sourceKind']?.toString() ?? 'Seed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pathwayId': pathwayId,
      'unitId': unitId,
      'title': title,
      'summary': summary,
      'objective': objective,
      'estimatedMinutes': estimatedMinutes,
      'difficulty': difficulty,
      'audiences': audiences,
      'tags': tags,
      'steps': steps,
      'resourceIds': resourceIds,
      'reflectionPrompt': reflectionPrompt,
      'sourceTitle': sourceTitle,
      'sourcePath': sourcePath,
      'sourceKind': sourceKind,
    };
  }
}

class PracticalProject {
  const PracticalProject({
    required this.id,
    required this.title,
    required this.summary,
    required this.domain,
    required this.estimatedHours,
    required this.audiences,
    required this.skillTags,
    required this.materials,
    required this.steps,
    required this.resourceIds,
  });

  final String id;
  final String title;
  final String summary;
  final String domain;
  final int estimatedHours;
  final List<String> audiences;
  final List<String> skillTags;
  final List<String> materials;
  final List<String> steps;
  final List<String> resourceIds;

  factory PracticalProject.fromJson(Map<String, dynamic> json) {
    return PracticalProject(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
      estimatedHours: json['estimatedHours'] is int
          ? json['estimatedHours'] as int
          : int.tryParse(json['estimatedHours']?.toString() ?? '') ?? 0,
      audiences: _stringList(json['audiences']),
      skillTags: _stringList(json['skillTags']),
      materials: _stringList(json['materials']),
      steps: _stringList(json['steps']),
      resourceIds: _stringList(json['resourceIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'domain': domain,
      'estimatedHours': estimatedHours,
      'audiences': audiences,
      'skillTags': skillTags,
      'materials': materials,
      'steps': steps,
      'resourceIds': resourceIds,
    };
  }
}

class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.stage,
    required this.mentorName,
    required this.guardianName,
    required this.activePathwayId,
    required this.badgeIds,
  });

  final String id;
  final String name;
  final String role;
  final String stage;
  final String mentorName;
  final String guardianName;
  final String activePathwayId;
  final List<String> badgeIds;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      stage: json['stage']?.toString() ?? '',
      mentorName: json['mentorName']?.toString() ?? '',
      guardianName: json['guardianName']?.toString() ?? '',
      activePathwayId: json['activePathwayId']?.toString() ?? '',
      badgeIds: _stringList(json['badgeIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'stage': stage,
      'mentorName': mentorName,
      'guardianName': guardianName,
      'activePathwayId': activePathwayId,
      'badgeIds': badgeIds,
    };
  }

  StudentProfile copyWith({
    String? id,
    String? name,
    String? role,
    String? stage,
    String? mentorName,
    String? guardianName,
    String? activePathwayId,
    List<String>? badgeIds,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      stage: stage ?? this.stage,
      mentorName: mentorName ?? this.mentorName,
      guardianName: guardianName ?? this.guardianName,
      activePathwayId: activePathwayId ?? this.activePathwayId,
      badgeIds: badgeIds ?? this.badgeIds,
    );
  }
}

class ProgressRecord {
  const ProgressRecord({
    required this.id,
    required this.studentId,
    required this.entityId,
    required this.entityType,
    required this.status,
    required this.progressPercent,
    required this.updatedAt,
    this.note = '',
  });

  final String id;
  final String studentId;
  final String entityId;
  final String entityType;
  final String status;
  final int progressPercent;
  final DateTime updatedAt;
  final String note;

  factory ProgressRecord.fromJson(Map<String, dynamic> json) {
    return ProgressRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      entityId: json['entityId']?.toString() ?? '',
      entityType: json['entityType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      progressPercent: json['progressPercent'] is int
          ? json['progressPercent'] as int
          : int.tryParse(json['progressPercent']?.toString() ?? '') ?? 0,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now().toUtc(),
      note: json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'entityId': entityId,
      'entityType': entityType,
      'status': status,
      'progressPercent': progressPercent,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'note': note,
    };
  }
}

class Assessment {
  const Assessment({
    required this.id,
    required this.title,
    required this.kind,
    required this.summary,
    required this.maxScore,
    required this.score,
    required this.studentId,
    required this.pathwayId,
    required this.criteria,
    required this.completedAt,
    required this.audiences,
    this.mentorFeedback = '',
  });

  final String id;
  final String title;
  final String kind;
  final String summary;
  final int maxScore;
  final int score;
  final String studentId;
  final String pathwayId;
  final List<String> criteria;
  final DateTime? completedAt;
  final List<String> audiences;
  final String mentorFeedback;

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      maxScore: json['maxScore'] is int
          ? json['maxScore'] as int
          : int.tryParse(json['maxScore']?.toString() ?? '') ?? 0,
      score: json['score'] is int
          ? json['score'] as int
          : int.tryParse(json['score']?.toString() ?? '') ?? 0,
      studentId: json['studentId']?.toString() ?? '',
      pathwayId: json['pathwayId']?.toString() ?? '',
      criteria: _stringList(json['criteria']),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      audiences: _stringList(json['audiences']),
      mentorFeedback: json['mentorFeedback']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'kind': kind,
      'summary': summary,
      'maxScore': maxScore,
      'score': score,
      'studentId': studentId,
      'pathwayId': pathwayId,
      'criteria': criteria,
      'completedAt': completedAt?.toUtc().toIso8601String(),
      'audiences': audiences,
      'mentorFeedback': mentorFeedback,
    };
  }
}

class ReflectionEntry {
  const ReflectionEntry({
    required this.id,
    required this.studentId,
    required this.title,
    required this.body,
    required this.mood,
    required this.createdAt,
    required this.audiences,
    this.linkedLessonId = '',
    this.linkedProjectId = '',
  });

  final String id;
  final String studentId;
  final String title;
  final String body;
  final String mood;
  final DateTime createdAt;
  final List<String> audiences;
  final String linkedLessonId;
  final String linkedProjectId;

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) {
    return ReflectionEntry(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      mood: json['mood']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now().toUtc(),
      audiences: _stringList(json['audiences']),
      linkedLessonId: json['linkedLessonId']?.toString() ?? '',
      linkedProjectId: json['linkedProjectId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'body': body,
      'mood': mood,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'audiences': audiences,
      'linkedLessonId': linkedLessonId,
      'linkedProjectId': linkedProjectId,
    };
  }
}

class MentorNote {
  const MentorNote({
    required this.id,
    required this.studentId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.priority,
  });

  final String id;
  final String studentId;
  final String author;
  final String content;
  final DateTime createdAt;
  final String priority;

  factory MentorNote.fromJson(Map<String, dynamic> json) {
    return MentorNote(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now().toUtc(),
      priority: json['priority']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'author': author,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'priority': priority,
    };
  }
}

class MentorReviewRecord {
  const MentorReviewRecord({
    required this.id,
    required this.studentId,
    required this.reviewer,
    required this.status,
    required this.handoffStatus,
    required this.notes,
    required this.reviewedAt,
  });

  final String id;
  final String studentId;
  final String reviewer;
  final String status;
  final String handoffStatus;
  final String notes;
  final DateTime reviewedAt;

  factory MentorReviewRecord.fromJson(Map<String, dynamic> json) {
    return MentorReviewRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      reviewer: json['reviewer']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      handoffStatus: json['handoffStatus']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      reviewedAt:
          DateTime.tryParse(json['reviewedAt']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'reviewer': reviewer,
      'status': status,
      'handoffStatus': handoffStatus,
      'notes': notes,
      'reviewedAt': reviewedAt.toUtc().toIso8601String(),
    };
  }
}

class Certificate {
  const Certificate({
    required this.id,
    required this.studentId,
    required this.title,
    required this.summary,
    required this.badgeLevel,
    required this.issuedBy,
    required this.awardedAt,
  });

  final String id;
  final String studentId;
  final String title;
  final String summary;
  final String badgeLevel;
  final String issuedBy;
  final DateTime awardedAt;

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      badgeLevel: json['badgeLevel']?.toString() ?? '',
      issuedBy: json['issuedBy']?.toString() ?? '',
      awardedAt:
          DateTime.tryParse(json['awardedAt']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'summary': summary,
      'badgeLevel': badgeLevel,
      'issuedBy': issuedBy,
      'awardedAt': awardedAt.toUtc().toIso8601String(),
    };
  }
}

@immutable
class LearnerProgressScore {
  const LearnerProgressScore({
    required this.overall,
    required this.lessonCompletion,
    required this.projectCompletion,
    required this.assessmentCompletion,
    required this.reflectionEngagement,
    required this.mentorReviewCoverage,
    required this.badgeCoverage,
    required this.completedLessons,
    required this.totalLessons,
    required this.completedProjects,
    required this.totalProjects,
    required this.completedAssessments,
    required this.totalAssessments,
    required this.reflectionCount,
    required this.reviewCount,
    required this.certificateCount,
  });

  final double overall;
  final double lessonCompletion;
  final double projectCompletion;
  final double assessmentCompletion;
  final double reflectionEngagement;
  final double mentorReviewCoverage;
  final double badgeCoverage;
  final int completedLessons;
  final int totalLessons;
  final int completedProjects;
  final int totalProjects;
  final int completedAssessments;
  final int totalAssessments;
  final int reflectionCount;
  final int reviewCount;
  final int certificateCount;
}

class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.path,
    required this.description,
  });

  final String id;
  final String title;
  final String type;
  final String category;
  final String path;
  final String description;

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'category': category,
      'path': path,
      'description': description,
    };
  }
}

class ContentSourceEntry {
  const ContentSourceEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.kind,
    required this.path,
    required this.description,
    required this.exists,
  });

  final String id;
  final String title;
  final String category;
  final String kind;
  final String path;
  final String description;
  final bool exists;

  factory ContentSourceEntry.fromJson(Map<String, dynamic> json) {
    return ContentSourceEntry(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      exists: json['exists'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'kind': kind,
      'path': path,
      'description': description,
      'exists': exists,
    };
  }
}

@immutable
class ContentPackDraft {
  const ContentPackDraft({
    required this.title,
    required this.version,
    required this.audience,
    required this.summary,
    required this.template,
    required this.validationReady,
    required this.validationNotes,
    required this.updatedAt,
    this.bundleId = '',
    this.checksum = '',
  });

  final String title;
  final String version;
  final String audience;
  final String summary;
  final String template;
  final bool validationReady;
  final String validationNotes;
  final DateTime updatedAt;
  final String bundleId;
  final String checksum;

  bool get hasBundleMetadata =>
      bundleId.trim().isNotEmpty && checksum.trim().isNotEmpty;

  bool get hasSemverVersion =>
      RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version.trim());

  factory ContentPackDraft.defaults() {
    return ContentPackDraft(
      title: 'Education Content Pack',
      version: '0.1.0',
      audience: 'Student',
      summary:
          'Local-first pack for lessons, projects, reflections, and badges.',
      template: 'lesson_first',
      validationReady: false,
      validationNotes: 'Draft not saved yet.',
      updatedAt: DateTime.now().toUtc(),
      bundleId: '',
      checksum: '',
    );
  }

  factory ContentPackDraft.fromJson(Map<String, dynamic> json) {
    return ContentPackDraft(
      title: json['title']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      audience: json['audience']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      template: json['template']?.toString() ?? '',
      validationReady: json['validationReady'] == true,
      validationNotes: json['validationNotes']?.toString() ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now().toUtc(),
      bundleId: json['bundleId']?.toString() ?? '',
      checksum: json['checksum']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'version': version,
      'audience': audience,
      'summary': summary,
      'template': template,
      'validationReady': validationReady,
      'validationNotes': validationNotes,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'bundleId': bundleId,
      'checksum': checksum,
    };
  }

  ContentPackDraft copyWith({
    String? title,
    String? version,
    String? audience,
    String? summary,
    String? template,
    bool? validationReady,
    String? validationNotes,
    DateTime? updatedAt,
    String? bundleId,
    String? checksum,
  }) {
    return ContentPackDraft(
      title: title ?? this.title,
      version: version ?? this.version,
      audience: audience ?? this.audience,
      summary: summary ?? this.summary,
      template: template ?? this.template,
      validationReady: validationReady ?? this.validationReady,
      validationNotes: validationNotes ?? this.validationNotes,
      updatedAt: updatedAt ?? this.updatedAt,
      bundleId: bundleId ?? this.bundleId,
      checksum: checksum ?? this.checksum,
    );
  }
}

class EducationHubSettings {
  const EducationHubSettings({
    required this.moduleRootPath,
    required this.contentRootPath,
    required this.offlineOnly,
    required this.knowledgeEngineRoute,
    required this.gaiaAssistantRoute,
    required this.lastRefreshedLabel,
  });

  final String moduleRootPath;
  final String contentRootPath;
  final bool offlineOnly;
  final String knowledgeEngineRoute;
  final String gaiaAssistantRoute;
  final String lastRefreshedLabel;

  factory EducationHubSettings.defaults({required String moduleRootPath}) {
    return EducationHubSettings(
      moduleRootPath: moduleRootPath,
      contentRootPath: '$moduleRootPath/16_SAMPLE_DATA',
      offlineOnly: true,
      knowledgeEngineRoute: '/modules/omega-knowledge-engine',
      gaiaAssistantRoute: '/voice-assistant',
      lastRefreshedLabel: 'Ready locally',
    );
  }

  factory EducationHubSettings.fromJson(Map<String, dynamic> json) {
    return EducationHubSettings(
      moduleRootPath: json['moduleRootPath']?.toString() ?? '',
      contentRootPath: json['contentRootPath']?.toString() ?? '',
      offlineOnly: json['offlineOnly'] == true,
      knowledgeEngineRoute: json['knowledgeEngineRoute']?.toString() ?? '',
      gaiaAssistantRoute: json['gaiaAssistantRoute']?.toString() ?? '',
      lastRefreshedLabel: json['lastRefreshedLabel']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleRootPath': moduleRootPath,
      'contentRootPath': contentRootPath,
      'offlineOnly': offlineOnly,
      'knowledgeEngineRoute': knowledgeEngineRoute,
      'gaiaAssistantRoute': gaiaAssistantRoute,
      'lastRefreshedLabel': lastRefreshedLabel,
    };
  }
}

@immutable
class EducationHubSnapshot {
  const EducationHubSnapshot({
    required this.settings,
    required this.pathways,
    required this.lessons,
    required this.projects,
    required this.students,
    required this.progressRecords,
    required this.assessments,
    required this.reflections,
    required this.mentorNotes,
    required this.mentorReviews,
    required this.certificates,
    required this.resources,
    required this.contentSources,
    required this.skillLibrary,
    required this.contentPackDraft,
  });

  final EducationHubSettings settings;
  final List<LearningPathway> pathways;
  final List<Lesson> lessons;
  final List<PracticalProject> projects;
  final List<StudentProfile> students;
  final List<ProgressRecord> progressRecords;
  final List<Assessment> assessments;
  final List<ReflectionEntry> reflections;
  final List<MentorNote> mentorNotes;
  final List<MentorReviewRecord> mentorReviews;
  final List<Certificate> certificates;
  final List<ResourceItem> resources;
  final List<ContentSourceEntry> contentSources;
  final List<String> skillLibrary;
  final ContentPackDraft contentPackDraft;

  EducationHubSnapshot copyWith({
    EducationHubSettings? settings,
    List<LearningPathway>? pathways,
    List<Lesson>? lessons,
    List<PracticalProject>? projects,
    List<StudentProfile>? students,
    List<ProgressRecord>? progressRecords,
    List<Assessment>? assessments,
    List<ReflectionEntry>? reflections,
    List<MentorNote>? mentorNotes,
    List<MentorReviewRecord>? mentorReviews,
    List<Certificate>? certificates,
    List<ResourceItem>? resources,
    List<ContentSourceEntry>? contentSources,
    List<String>? skillLibrary,
    ContentPackDraft? contentPackDraft,
  }) {
    return EducationHubSnapshot(
      settings: settings ?? this.settings,
      pathways: pathways ?? this.pathways,
      lessons: lessons ?? this.lessons,
      projects: projects ?? this.projects,
      students: students ?? this.students,
      progressRecords: progressRecords ?? this.progressRecords,
      assessments: assessments ?? this.assessments,
      reflections: reflections ?? this.reflections,
      mentorNotes: mentorNotes ?? this.mentorNotes,
      mentorReviews: mentorReviews ?? this.mentorReviews,
      certificates: certificates ?? this.certificates,
      resources: resources ?? this.resources,
      contentSources: contentSources ?? this.contentSources,
      skillLibrary: skillLibrary ?? this.skillLibrary,
      contentPackDraft: contentPackDraft ?? this.contentPackDraft,
    );
  }

  int get pathwayCount => pathways.length;
  int get lessonCount => lessons.length;
  int get projectCount => projects.length;
  int get learnerCount => students.length;
  int get completedAssessments =>
      assessments.where((assessment) => assessment.completedAt != null).length;
  int get reflectionCount => reflections.length;
  int get certificateCount => certificates.length;
  int get resourceCount => resources.length;

  Map<String, dynamic> toJson() {
    return {
      'settings': settings.toJson(),
      'pathways': pathways
          .map((value) => value.toJson())
          .toList(growable: false),
      'lessons': lessons.map((value) => value.toJson()).toList(growable: false),
      'projects': projects
          .map((value) => value.toJson())
          .toList(growable: false),
      'students': students
          .map((value) => value.toJson())
          .toList(growable: false),
      'progressRecords': progressRecords
          .map((value) => value.toJson())
          .toList(growable: false),
      'assessments': assessments
          .map((value) => value.toJson())
          .toList(growable: false),
      'reflections': reflections
          .map((value) => value.toJson())
          .toList(growable: false),
      'mentorNotes': mentorNotes
          .map((value) => value.toJson())
          .toList(growable: false),
      'mentorReviews': mentorReviews
          .map((value) => value.toJson())
          .toList(growable: false),
      'certificates': certificates
          .map((value) => value.toJson())
          .toList(growable: false),
      'resources': resources
          .map((value) => value.toJson())
          .toList(growable: false),
      'contentSources': contentSources
          .map((value) => value.toJson())
          .toList(growable: false),
      'skillLibrary': skillLibrary,
      'contentPackDraft': contentPackDraft.toJson(),
    };
  }

  factory EducationHubSnapshot.fromJson(Map<String, dynamic> json) {
    return EducationHubSnapshot(
      settings: EducationHubSettings.fromJson(_jsonMap(json['settings'])),
      pathways: _pathwayList(json['pathways']),
      lessons: _lessonList(json['lessons']),
      projects: _projectList(json['projects']),
      students: _studentList(json['students']),
      progressRecords: _progressRecordList(json['progressRecords']),
      assessments: _assessmentList(json['assessments']),
      reflections: _reflectionList(json['reflections']),
      mentorNotes: _mentorNoteList(json['mentorNotes']),
      mentorReviews: _mentorReviewList(json['mentorReviews']),
      certificates: _certificateList(json['certificates']),
      resources: _resourceList(json['resources']),
      contentSources: _contentSourceList(json['contentSources']),
      skillLibrary: _stringList(json['skillLibrary']),
      contentPackDraft: _contentPackDraft(json['contentPackDraft']),
    );
  }

  ProgressRecord? progressFor(String studentId, String entityId) {
    for (final record in progressRecords) {
      if (record.studentId == studentId && record.entityId == entityId) {
        return record;
      }
    }
    return null;
  }

  List<ProgressRecord> progressForStudent(String studentId) {
    return progressRecords
        .where((record) => record.studentId == studentId)
        .toList(growable: false);
  }

  List<ReflectionEntry> reflectionsForStudent(String studentId) {
    return reflections
        .where((reflection) => reflection.studentId == studentId)
        .toList(growable: false);
  }

  List<MentorNote> notesForStudent(String studentId) {
    return mentorNotes
        .where((note) => note.studentId == studentId)
        .toList(growable: false);
  }

  List<MentorReviewRecord> reviewsForStudent(String studentId) {
    return mentorReviews
        .where((review) => review.studentId == studentId)
        .toList(growable: false);
  }

  List<Assessment> assessmentsForStudent(String studentId) {
    return assessments
        .where((assessment) => assessment.studentId == studentId)
        .toList(growable: false);
  }

  List<Certificate> certificatesForStudent(String studentId) {
    return certificates
        .where((certificate) => certificate.studentId == studentId)
        .toList(growable: false);
  }

  List<ProgressRecord> progressForProject(String projectId) {
    return progressRecords
        .where(
          (record) =>
              record.entityType == 'project' && record.entityId == projectId,
        )
        .toList(growable: false);
  }

  List<Assessment> completedAssessmentsForStudent(String studentId) {
    return assessmentsForStudent(studentId)
        .where((assessment) => assessment.completedAt != null)
        .toList(growable: false);
  }

  double assessmentCompletionForStudent(String studentId) {
    final studentAssessments = assessmentsForStudent(studentId);
    if (studentAssessments.isEmpty) {
      return 0;
    }
    final completed = studentAssessments
        .where((assessment) => assessment.completedAt != null)
        .length;
    return completed / studentAssessments.length;
  }

  LearnerProgressScore learnerProgressScoreForStudent(String studentId) {
    final studentProgress = progressForStudent(studentId);
    final lessonProgress = studentProgress
        .where((record) => record.entityType == 'lesson')
        .toList(growable: false);
    final projectProgress = studentProgress
        .where((record) => record.entityType == 'project')
        .toList(growable: false);
    final studentAssessments = assessmentsForStudent(studentId);
    final completedAssessments = studentAssessments
        .where((assessment) => assessment.completedAt != null)
        .length;
    final reflectionCount = reflectionsForStudent(studentId).length;
    final reviewCount = reviewsForStudent(studentId).length;
    final certificateCount = certificatesForStudent(studentId).length;
    final completedLessons = lessonProgress
        .where((record) => record.progressPercent >= 100)
        .length;
    final completedProjects = projectProgress
        .where((record) => record.progressPercent >= 100)
        .length;
    final lessonCompletion = lessonProgress.isEmpty
        ? 0.0
        : completedLessons / lessonProgress.length;
    final projectCompletion = projectProgress.isEmpty
        ? 0.0
        : completedProjects / projectProgress.length;
    final assessmentCompletion = studentAssessments.isEmpty
        ? 0.0
        : completedAssessments / studentAssessments.length;
    final reflectionEngagement =
        (reflectionCount / 3).clamp(0.0, 1.0).toDouble();
    final mentorReviewCoverage = (reviewCount / 2).clamp(0.0, 1.0).toDouble();
    final badgeCoverage = (certificateCount / 2).clamp(0.0, 1.0).toDouble();
    final overall = (
      lessonCompletion * 0.25 +
      projectCompletion * 0.15 +
      assessmentCompletion * 0.3 +
      reflectionEngagement * 0.15 +
      mentorReviewCoverage * 0.1 +
      badgeCoverage * 0.05
    ).clamp(0.0, 1.0);
    return LearnerProgressScore(
      overall: overall,
      lessonCompletion: lessonCompletion,
      projectCompletion: projectCompletion,
      assessmentCompletion: assessmentCompletion,
      reflectionEngagement: reflectionEngagement,
      mentorReviewCoverage: mentorReviewCoverage,
      badgeCoverage: badgeCoverage,
      completedLessons: completedLessons,
      totalLessons: lessonProgress.length,
      completedProjects: completedProjects,
      totalProjects: projectProgress.length,
      completedAssessments: completedAssessments,
      totalAssessments: studentAssessments.length,
      reflectionCount: reflectionCount,
      reviewCount: reviewCount,
      certificateCount: certificateCount,
    );
  }

  int earnedBadgeCountForStudent(String studentId) {
    for (final student in students) {
      if (student.id == studentId) {
        return student.badgeIds.length;
      }
    }
    return 0;
  }

  double badgeReadinessForStudent(String studentId) {
    return learnerProgressScoreForStudent(studentId).overall;
  }

  String progressLabelForStudent(String studentId) {
    final score = learnerProgressScoreForStudent(studentId);
    if (score.overall == 0) {
      return 'No progress yet';
    }
    final completedMilestones =
        score.completedLessons + score.completedProjects + score.completedAssessments;
    final totalMilestones =
        score.totalLessons + score.totalProjects + score.totalAssessments;
    final label = switch (score.overall) {
      >= 0.85 => 'Strong momentum',
      >= 0.65 => 'Steady progress',
      >= 0.35 => 'Building momentum',
      _ => 'Starting out',
    };
    return '$label - $completedMilestones of $totalMilestones milestones complete';
  }
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

Map<String, dynamic> _jsonMap(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

List<LearningPathway> _pathwayList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(LearningPathway.fromJson)
      .toList(growable: false);
}

List<Lesson> _lessonList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(Lesson.fromJson)
      .toList(growable: false);
}

List<PracticalProject> _projectList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(PracticalProject.fromJson)
      .toList(growable: false);
}

List<StudentProfile> _studentList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(StudentProfile.fromJson)
      .toList(growable: false);
}

List<ProgressRecord> _progressRecordList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(ProgressRecord.fromJson)
      .toList(growable: false);
}

List<Assessment> _assessmentList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(Assessment.fromJson)
      .toList(growable: false);
}

List<ReflectionEntry> _reflectionList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(ReflectionEntry.fromJson)
      .toList(growable: false);
}

List<MentorNote> _mentorNoteList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(MentorNote.fromJson)
      .toList(growable: false);
}

List<MentorReviewRecord> _mentorReviewList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(MentorReviewRecord.fromJson)
      .toList(growable: false);
}

List<Certificate> _certificateList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(Certificate.fromJson)
      .toList(growable: false);
}

List<ResourceItem> _resourceList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(ResourceItem.fromJson)
      .toList(growable: false);
}

List<ContentSourceEntry> _contentSourceList(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map>()
      .map(
        (value) => value.map((key, child) => MapEntry(key.toString(), child)),
      )
      .map(ContentSourceEntry.fromJson)
      .toList(growable: false);
}

ContentPackDraft _contentPackDraft(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return ContentPackDraft.fromJson(raw);
  }
  if (raw is Map) {
    return ContentPackDraft.fromJson(
      raw.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
  return ContentPackDraft.defaults();
}

List<ModuleUnit> _moduleUnits(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map<String, dynamic>>()
      .map(ModuleUnit.fromJson)
      .toList(growable: false);
}
