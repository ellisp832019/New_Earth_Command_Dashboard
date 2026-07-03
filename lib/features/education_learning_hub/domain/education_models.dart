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
    required this.certificates,
    required this.resources,
    required this.skillLibrary,
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
  final List<Certificate> certificates;
  final List<ResourceItem> resources;
  final List<String> skillLibrary;

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
    List<Certificate>? certificates,
    List<ResourceItem>? resources,
    List<String>? skillLibrary,
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
      certificates: certificates ?? this.certificates,
      resources: resources ?? this.resources,
      skillLibrary: skillLibrary ?? this.skillLibrary,
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

List<ModuleUnit> _moduleUnits(dynamic raw) {
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map<String, dynamic>>()
      .map(ModuleUnit.fromJson)
      .toList(growable: false);
}
