import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../domain/education_models.dart';

abstract class EducationRepository {
  Future<EducationHubSnapshot> loadSnapshot();

  Future<void> saveSnapshot(EducationHubSnapshot snapshot);

  Future<ProgressRecord> saveProgressRecord({
    required String studentId,
    required String entityId,
    required String entityType,
    required int progressPercent,
    required String status,
    String note = '',
  });

  Future<File> exportSnapshotBundle({String? exportPath});

  Future<EducationHubSnapshot> importSnapshotBundle({String? importPath});

  Future<File> exportMentorReport({
    required String studentId,
    String? exportPath,
  });

  Future<Certificate> issueCertificateFromAssessments({
    required String studentId,
    String? exportPath,
  });
}

class LocalEducationRepository implements EducationRepository {
  LocalEducationRepository({
    this.moduleRootPath = 'modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB',
    this.stateFilePath,
  });

  final String moduleRootPath;
  final String? stateFilePath;
  EducationHubSnapshot? _cachedSnapshot;

  @override
  Future<EducationHubSnapshot> loadSnapshot() async {
    final cachedSnapshot = _cachedSnapshot;
    if (cachedSnapshot != null) {
      return cachedSnapshot;
    }

    final settings = EducationHubSettings.defaults(
      moduleRootPath: moduleRootPath,
    );
    final baseSnapshot = EducationHubSnapshot(
      settings: settings,
      pathways: _buildPathways(),
      lessons: _buildLessons(),
      projects: _buildProjects(),
      students: _buildStudents(),
      progressRecords: _buildProgressRecords(),
      assessments: _buildAssessments(),
      reflections: _buildReflections(),
      mentorNotes: _buildMentorNotes(),
      certificates: _buildCertificates(),
      resources: _buildResources(),
      contentSources: _buildContentSources(),
      skillLibrary: _loadSkillLibrary(),
    );
    final snapshot = _mergePersistedState(baseSnapshot);
    _cachedSnapshot = snapshot;
    return snapshot;
  }

  @override
  Future<void> saveSnapshot(EducationHubSnapshot snapshot) async {
    _cachedSnapshot = snapshot;
    await _writeState(snapshot);
  }

  @override
  Future<ProgressRecord> saveProgressRecord({
    required String studentId,
    required String entityId,
    required String entityType,
    required int progressPercent,
    required String status,
    String note = '',
  }) async {
    final snapshot = await loadSnapshot();
    final records = snapshot.progressRecords.toList(growable: true);
    final now = DateTime.now().toUtc();
    final existingIndex = records.indexWhere(
      (record) => record.studentId == studentId && record.entityId == entityId,
    );
    final record = ProgressRecord(
      id: existingIndex >= 0 ? records[existingIndex].id : _buildProgressId(),
      studentId: studentId,
      entityId: entityId,
      entityType: entityType,
      status: status,
      progressPercent: progressPercent.clamp(0, 100),
      updatedAt: now,
      note: note.trim(),
    );

    if (existingIndex >= 0) {
      records[existingIndex] = record;
    } else {
      records.add(record);
    }

    final updated = snapshot.copyWith(progressRecords: records);
    await saveSnapshot(updated);
    return record;
  }

  Future<ProgressRecord?> latestProgressFor(String studentId, String entityId) async {
    final snapshot = await loadSnapshot();
    return snapshot.progressFor(studentId, entityId);
  }

  Future<void> clearPersistedState() async {
    final file = _stateFile();
    if (file.existsSync()) {
      await file.delete();
    }
    _cachedSnapshot = null;
  }

  @override
  Future<File> exportSnapshotBundle({String? exportPath}) async {
    final snapshot = await loadSnapshot();
    final file = File(exportPath ?? _exportFilePath());
    await file.parent.create(recursive: true);
    final payload = <String, dynamic>{
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'snapshot': snapshot.toJson(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  @override
  Future<EducationHubSnapshot> importSnapshotBundle({String? importPath}) async {
    final file = File(importPath ?? _exportFilePath());
    if (!file.existsSync()) {
      throw FileSystemException('Import bundle not found', file.path);
    }

    final decoded = jsonDecode(await file.readAsString());
    Map<String, dynamic>? snapshotJson;
    if (decoded is Map<String, dynamic>) {
      final nested = decoded['snapshot'];
      if (nested is Map<String, dynamic>) {
        snapshotJson = nested;
      } else if (nested is Map) {
        snapshotJson = nested.map((key, value) => MapEntry(key.toString(), value));
      } else {
        snapshotJson = decoded;
      }
    } else if (decoded is Map) {
      final map = decoded.map((key, value) => MapEntry(key.toString(), value));
      final nested = map['snapshot'];
      if (nested is Map<String, dynamic>) {
        snapshotJson = nested;
      } else if (nested is Map) {
        snapshotJson = nested.map((key, value) => MapEntry(key.toString(), value));
      } else {
        snapshotJson = map;
      }
    }

    if (snapshotJson == null) {
      throw const FormatException('Snapshot bundle was not valid JSON data.');
    }

    final imported = EducationHubSnapshot.fromJson(snapshotJson);
    await saveSnapshot(imported);
    return imported;
  }

  @override
  Future<File> exportMentorReport({
    required String studentId,
    String? exportPath,
  }) async {
    final snapshot = await loadSnapshot();
    final student = _studentById(snapshot, studentId);
    if (student == null) {
      throw ArgumentError.value(studentId, 'studentId', 'Student not found.');
    }

    final reportFile = File(exportPath ?? _mentorReportFilePath(studentId));
    await reportFile.parent.create(recursive: true);
    await reportFile.writeAsString(_mentorReportText(snapshot, student));
    return reportFile;
  }

  @override
  Future<Certificate> issueCertificateFromAssessments({
    required String studentId,
    String? exportPath,
  }) async {
    final snapshot = await loadSnapshot();
    final student = _studentById(snapshot, studentId);
    if (student == null) {
      throw ArgumentError.value(studentId, 'studentId', 'Student not found.');
    }

    final completedAssessments = snapshot.completedAssessmentsForStudent(studentId);
    final readiness = snapshot.badgeReadinessForStudent(studentId);
    final badgeLevel = readiness >= 0.8
        ? 'Gold'
        : readiness >= 0.6
            ? 'Silver'
            : readiness >= 0.4
                ? 'Bronze'
                : 'Draft';
    final completedCount = completedAssessments.length;
    final assessmentSummary = completedAssessments.isEmpty
        ? 'Draft certificate generated from local progress only.'
        : 'Completed assessments: ${completedAssessments.map((assessment) => assessment.title).join(', ')}.';
    final certificate = Certificate(
      id: 'cert_${studentId}_${DateTime.now().microsecondsSinceEpoch}',
      studentId: studentId,
      title: '${student.name} Learning Passport',
      summary:
          '$assessmentSummary Progress readiness ${(readiness * 100).round()}% with $completedCount completed assessment(s).',
      badgeLevel: badgeLevel,
      issuedBy: 'New Earth Learning Hub',
      awardedAt: DateTime.now().toUtc(),
    );

    final certificates = snapshot.certificates.toList(growable: true)
      ..add(certificate);
    final updatedStudents = snapshot.students.map((profile) {
      if (profile.id != studentId) {
        return profile;
      }
      final badgeIds = profile.badgeIds.toList(growable: true);
      if (!badgeIds.contains(certificate.id)) {
        badgeIds.add(certificate.id);
      }
      return profile.copyWith(badgeIds: badgeIds);
    }).toList(growable: false);

    final updated = snapshot.copyWith(
      certificates: certificates,
      students: updatedStudents,
    );
    await saveSnapshot(updated);

    final certificateFile = File(
      exportPath ?? _certificateDraftFilePath(studentId, certificate.id),
    );
    await certificateFile.parent.create(recursive: true);
    await certificateFile.writeAsString(_certificateDraftText(updated, student, certificate));
    return certificate;
  }

  EducationHubSnapshot _mergePersistedState(EducationHubSnapshot snapshot) {
    final file = _stateFile();
    if (!file.existsSync()) {
      return snapshot;
    }

    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        if (decoded['snapshot'] is Map<String, dynamic>) {
          return EducationHubSnapshot.fromJson(
            decoded['snapshot'] as Map<String, dynamic>,
          );
        }
        if (decoded['snapshot'] is Map) {
          return EducationHubSnapshot.fromJson(
            (decoded['snapshot'] as Map).map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          );
        }
        return snapshot.copyWith(
          progressRecords: _recordsFromJson(decoded['progressRecords']) ??
              snapshot.progressRecords,
        );
      }
      if (decoded is Map) {
        final map = decoded.map((key, value) => MapEntry(key.toString(), value));
        if (map['snapshot'] is Map<String, dynamic>) {
          return EducationHubSnapshot.fromJson(
            map['snapshot'] as Map<String, dynamic>,
          );
        }
        if (map['snapshot'] is Map) {
          return EducationHubSnapshot.fromJson(
            (map['snapshot'] as Map).map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          );
        }
        return snapshot.copyWith(
          progressRecords: _recordsFromJson(map['progressRecords']) ??
              snapshot.progressRecords,
        );
      }
    } catch (_) {
      // Use the seed snapshot if the persisted state cannot be read.
    }

    return snapshot;
  }

  Future<void> _writeState(EducationHubSnapshot snapshot) async {
    final file = _stateFile();
    await file.parent.create(recursive: true);
    final payload = <String, dynamic>{
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'snapshot': snapshot.toJson(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
  }

  File _stateFile() {
    final resolved = stateFilePath ?? 
        path.join(
          moduleRootPath,
          '10_LOCAL_FIRST_DATA',
          'learning_state.json',
        );
    return File(resolved);
  }

  String _exportFilePath() {
    return path.join(
      moduleRootPath,
      '10_LOCAL_FIRST_DATA',
      'exports',
      'education_snapshot_bundle.json',
    );
  }

  String _mentorReportFilePath(String studentId) {
    return path.join(
      moduleRootPath,
      '10_LOCAL_FIRST_DATA',
      'exports',
      'mentor_reports',
      '${studentId}_mentor_report.md',
    );
  }

  String _certificateDraftFilePath(String studentId, String certificateId) {
    return path.join(
      moduleRootPath,
      '10_LOCAL_FIRST_DATA',
      'exports',
      'certificates',
      '${studentId}_$certificateId.md',
    );
  }

  List<ProgressRecord>? _recordsFromJson(dynamic raw) {
    if (raw is! List) {
      return null;
    }
    final records = raw
        .whereType<Map>()
        .map((entry) => entry.map((key, value) => MapEntry(key.toString(), value)))
        .map(ProgressRecord.fromJson)
        .toList(growable: false);
    return records;
  }

  StudentProfile? _studentById(EducationHubSnapshot snapshot, String studentId) {
    for (final student in snapshot.students) {
      if (student.id == studentId) {
        return student;
      }
    }
    return null;
  }

  String _mentorReportText(EducationHubSnapshot snapshot, StudentProfile student) {
    final progress = snapshot.progressForStudent(student.id);
    final notes = snapshot.notesForStudent(student.id);
    final reflections = snapshot.reflectionsForStudent(student.id);
    final assessments = snapshot.assessmentsForStudent(student.id);
    final completedAssessments = assessments
        .where((assessment) => assessment.completedAt != null)
        .toList(growable: false);
    final certificates = snapshot.certificatesForStudent(student.id);
    final progressLabel = snapshot.progressLabelForStudent(student.id);
    final readiness = snapshot.badgeReadinessForStudent(student.id);
    final buffer = StringBuffer()
      ..writeln('# Mentor report: ${student.name}')
      ..writeln()
      ..writeln('- Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('- Mentor: ${student.mentorName}')
      ..writeln('- Guardian: ${student.guardianName}')
      ..writeln('- Role: ${student.role}')
      ..writeln('- Active pathway: ${student.activePathwayId}')
      ..writeln('- Progress: $progressLabel')
      ..writeln('- Badge readiness: ${(readiness * 100).round()}%')
      ..writeln('- Completed assessments: ${completedAssessments.length}/${assessments.length}')
      ..writeln('- Reflections: ${reflections.length}')
      ..writeln('- Mentor notes: ${notes.length}')
      ..writeln('- Certificates: ${certificates.length}')
      ..writeln();

    if (notes.isNotEmpty) {
      buffer.writeln('## Support notes');
      for (final note in notes.take(5)) {
        buffer.writeln(
          '- ${note.priority.isEmpty ? 'Note' : note.priority}: ${note.content}',
        );
      }
      buffer.writeln();
    }

    if (completedAssessments.isNotEmpty) {
      buffer.writeln('## Completed assessments');
      for (final assessment in completedAssessments.take(5)) {
        buffer.writeln(
          '- ${assessment.title} (${assessment.score}/${assessment.maxScore})',
        );
      }
      buffer.writeln();
    }

    if (progress.isNotEmpty) {
      buffer.writeln('## Progress checkpoints');
      for (final record in progress.take(5)) {
        buffer.writeln(
          '- ${record.entityType} ${record.entityId}: ${record.status} (${record.progressPercent}%)',
        );
      }
      buffer.writeln();
    }

    if (reflections.isNotEmpty) {
      buffer.writeln('## Reflections');
      for (final reflection in reflections.take(3)) {
        buffer.writeln('- ${reflection.title}: ${reflection.mood}');
      }
      buffer.writeln();
    }

    buffer
      ..writeln('## Mentor view')
      ..writeln(
        '- Classroom/guardian view: ${student.role == 'parentGuardian' ? 'Guardian check-in focus' : 'Mentor review focus'}',
      )
      ..writeln('- Suggested next step: Review one note, one assessment, and one support action.')
      ..writeln('- Keep all decisions local until sign-off is needed.');

    return buffer.toString().trim();
  }

  String _certificateDraftText(
    EducationHubSnapshot snapshot,
    StudentProfile student,
    Certificate certificate,
  ) {
    final completedAssessments = snapshot.completedAssessmentsForStudent(student.id);
    final progressLabel = snapshot.progressLabelForStudent(student.id);
    final readiness = snapshot.badgeReadinessForStudent(student.id);
    final buffer = StringBuffer()
      ..writeln('# Certificate draft: ${certificate.title}')
      ..writeln()
      ..writeln('- Student: ${student.name}')
      ..writeln('- Badge level: ${certificate.badgeLevel}')
      ..writeln('- Issued by: ${certificate.issuedBy}')
      ..writeln('- Awarded at: ${certificate.awardedAt.toIso8601String()}')
      ..writeln('- Progress: $progressLabel')
      ..writeln('- Readiness: ${(readiness * 100).round()}%')
      ..writeln('- Completed assessments: ${completedAssessments.length}')
      ..writeln()
      ..writeln('## Summary')
      ..writeln(certificate.summary);
    if (completedAssessments.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## Completed assessments');
      for (final assessment in completedAssessments.take(5)) {
        buffer.writeln('- ${assessment.title} (${assessment.score}/${assessment.maxScore})');
      }
    }
    return buffer.toString().trim();
  }

  String _buildProgressId() {
    return 'progress_${DateTime.now().microsecondsSinceEpoch}';
  }

  List<LearningPathway> _buildPathways() {
    final seedFile = File(
      path.join(moduleRootPath, '16_SAMPLE_DATA', 'pathways.json'),
    );
    final samplePathways = <Map<String, dynamic>>[];
    if (seedFile.existsSync()) {
      try {
        final decoded = jsonDecode(seedFile.readAsStringSync());
        if (decoded is List) {
          samplePathways.addAll(
            decoded.whereType<Map>().map((item) {
              return item.map((key, value) => MapEntry(key.toString(), value));
            }),
          );
        }
      } catch (_) {
        // Fall back to the embedded seeds below.
      }
    }

    final seeded = samplePathways.isEmpty ? _pathwaySeeds() : samplePathways;
    return seeded
        .map((entry) => LearningPathway.fromJson(entry))
        .toList(growable: false);
  }

  List<Lesson> _buildLessons() {
    final lessons = <Lesson>[
      ..._lessonSeeds().map((entry) => Lesson.fromJson(entry)),
      ..._importedLessonsFromDocs(),
    ];

    final unique = <String, Lesson>{};
    for (final lesson in lessons) {
      unique[lesson.id] = lesson;
    }
    return unique.values.toList(growable: false);
  }

  List<Lesson> _importedLessonsFromDocs() {
    final directory = Directory(path.join(moduleRootPath, '04_LEARNING_PATHWAYS'));
    if (!directory.existsSync()) {
      return const [];
    }

    final lessons = <Lesson>[];
    final pathwayDocs = directory
        .listSync()
        .whereType<File>()
        .where((file) => path.extension(file.path).toLowerCase() == '.md')
        .where((file) => path.basename(file.path).toUpperCase() != 'PATHWAYS_OVERVIEW.MD')
        .toList(growable: false);

    for (final file in pathwayDocs) {
      final fileName = path.basenameWithoutExtension(file.path);
      final pathwayId = _pathwayIdForFile(fileName);
      final content = _readText(file);
      final title = _markdownHeading(content) ?? _friendlyLabel(fileName);
      final goal = _markdownSection(content, 'Goal') ??
          _markdownSection(content, 'Summary') ??
          'Imported pathway lesson for $title.';
      final skills = _markdownBulletList(content, 'Skills gained');
      final evidence = _markdownBulletList(content, 'Evidence');
      final units = _markdownNumberedList(content, 'Units');
      lessons.add(
        Lesson(
          id: 'import_${fileName.toLowerCase()}',
          pathwayId: pathwayId,
          unitId: '${pathwayId}_overview',
          title: '$title overview',
          summary: goal,
          objective: goal,
          estimatedMinutes: 25,
          difficulty: fileName.contains('ADVANCED') ? 'Intermediate' : 'Beginner',
          audiences: const ['student', 'mentor', 'parentGuardian', 'admin'],
          tags: [
            'imported',
            ...skills.take(3).map((item) => item.toLowerCase()),
          ],
          steps: [
            if (units.isNotEmpty) ...units.take(4),
            'Review the pathway notes.',
            'Choose one practical action.',
            'Record a calm reflection.',
          ],
          resourceIds: _resourceIdsForPathway(pathwayId),
          reflectionPrompt: evidence.isNotEmpty
              ? evidence.first
              : 'What would help this pathway feel practical and usable?',
          sourceTitle: title,
          sourcePath: file.path,
          sourceKind: 'Pathway document',
        ),
      );
    }

    final contentLibrary = Directory(path.join(moduleRootPath, '05_CONTENT_LIBRARY'));
    if (contentLibrary.existsSync()) {
      for (final file in contentLibrary.listSync().whereType<File>()) {
        if (path.extension(file.path).toLowerCase() != '.md') {
          continue;
        }
        final basename = path.basename(file.path);
        if (!basename.startsWith('SAMPLE_LESSON_')) {
          continue;
        }

        final fileName = path.basenameWithoutExtension(file.path);
        final content = _readText(file);
        final title = _markdownHeading(content) ?? _friendlyLabel(fileName);
        final summary = _markdownSection(content, 'Summary') ??
            'Imported sample lesson from the module docs.';
        final outcomes = _markdownBulletList(content, 'Learning outcomes');
        final materials = _markdownBulletList(content, 'Materials');
        final activitySteps = _markdownNumberedList(content, 'Activity');
        final reflectionPrompt = _markdownSection(content, 'Reflection') ??
            'What did this sample lesson help you notice?';
        lessons.add(
          Lesson(
            id: 'import_${fileName.toLowerCase()}',
            pathwayId: _pathwayIdForLessonFile(fileName),
            unitId: '${_pathwayIdForLessonFile(fileName)}_lesson_pack',
            title: title,
            summary: summary,
            objective: outcomes.isNotEmpty
                ? outcomes.first
                : 'Practice a small, practical learning step.',
            estimatedMinutes: 25,
            difficulty: 'Beginner',
            audiences: const ['student', 'mentor', 'parentGuardian'],
            tags: [
              'imported',
              ..._keywordsFrom(fileName, summary),
            ],
            steps: [
              if (materials.isNotEmpty) 'Materials: ${materials.take(4).join(', ')}',
              if (activitySteps.isNotEmpty) ...activitySteps.take(5),
              'Save one note or photo as evidence.',
            ],
            resourceIds: const ['res_calm_build_checklist'],
            reflectionPrompt: reflectionPrompt,
            sourceTitle: title,
            sourcePath: file.path,
            sourceKind: 'Sample lesson',
          ),
        );
      }
    }

    return lessons;
  }

  List<PracticalProject> _buildProjects() {
    return _projectSeeds()
        .map((entry) => PracticalProject.fromJson(entry))
        .toList(growable: false);
  }

  List<StudentProfile> _buildStudents() {
    return _studentSeeds()
        .map((entry) => StudentProfile.fromJson(entry))
        .toList(growable: false);
  }

  List<ProgressRecord> _buildProgressRecords() {
    return _progressSeeds()
        .map((entry) => ProgressRecord.fromJson(entry))
        .toList(growable: false);
  }

  List<Assessment> _buildAssessments() {
    return _assessmentSeeds()
        .map((entry) => Assessment.fromJson(entry))
        .toList(growable: false);
  }

  List<ReflectionEntry> _buildReflections() {
    return _reflectionSeeds()
        .map((entry) => ReflectionEntry.fromJson(entry))
        .toList(growable: false);
  }

  List<MentorNote> _buildMentorNotes() {
    return _mentorNoteSeeds()
        .map((entry) => MentorNote.fromJson(entry))
        .toList(growable: false);
  }

  List<Certificate> _buildCertificates() {
    return _certificateSeeds()
        .map((entry) => Certificate.fromJson(entry))
        .toList(growable: false);
  }

  List<ResourceItem> _buildResources() {
    return _resourceSeeds()
        .map((entry) => ResourceItem.fromJson(entry))
        .toList(growable: false);
  }

  List<ContentSourceEntry> _buildContentSources() {
    final rootDirectory = Directory(moduleRootPath);
    if (!rootDirectory.existsSync()) {
      return _contentSourceFallback();
    }

    final entries = <ContentSourceEntry>[];
    for (final entity in rootDirectory.listSync(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }

      final normalizedPath = path.normalize(entity.path);
      final extension = path.extension(normalizedPath).toLowerCase();
      if (extension != '.md' && extension != '.json') {
        continue;
      }

      if (path.basename(normalizedPath).toLowerCase() == 'module_manifest.json') {
        continue;
      }

      final relativePath = path.relative(normalizedPath, from: moduleRootPath);
      final pathParts = path.split(relativePath);
      final category = pathParts.length > 1
          ? _friendlyLabel(pathParts.first)
          : 'Module';
      final kind = extension == '.json' ? 'Sample data' : 'Documentation';
      final title = _friendlyLabel(path.basenameWithoutExtension(normalizedPath));
      entries.add(
        ContentSourceEntry(
          id: relativePath.replaceAll('\\', '/'),
          title: title,
          category: category,
          kind: kind,
          path: normalizedPath,
          description: _contentDescriptionFor(relativePath),
          exists: entity.existsSync(),
        ),
      );
    }

    if (entries.isEmpty) {
      return _contentSourceFallback();
    }

    entries.sort(
      (a, b) => a.category.compareTo(b.category) != 0
          ? a.category.compareTo(b.category)
          : a.title.compareTo(b.title),
    );
    return entries.toList(growable: false);
  }

  List<String> _loadSkillLibrary() {
    final seedFile = File(
      path.join(moduleRootPath, '16_SAMPLE_DATA', 'skills.json'),
    );
    if (seedFile.existsSync()) {
      try {
        final decoded = jsonDecode(seedFile.readAsStringSync());
        if (decoded is List) {
          final values = decoded
              .whereType<Map>()
              .map(
                (item) => (item['name'] ?? item['title'] ?? '')
                    .toString()
                    .trim(),
              )
              .where((item) => item.isNotEmpty)
              .toList(growable: false);
          if (values.isNotEmpty) {
            return values;
          }
        }
      } catch (_) {
        // Fall back to the embedded list below.
      }
    }

    return const [
      'Safe Low-Voltage Working',
      'Sensor Observation',
      'Reflective Learning',
      'Systems Thinking',
      'Responsible AI Use',
    ];
  }

  String _readText(File file) {
    try {
      return file.readAsStringSync();
    } catch (_) {
      return '';
    }
  }

  String? _markdownHeading(String content) {
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        return trimmed.substring(2).trim();
      }
    }
    return null;
  }

  String? _markdownSection(String content, String heading) {
    final lines = content.split('\n');
    var inSection = false;
    final buffer = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('## ')) {
        final currentHeading = trimmed.substring(3).trim();
        if (inSection && currentHeading != heading) {
          break;
        }
        inSection = currentHeading.toLowerCase() == heading.toLowerCase();
        continue;
      }
      if (inSection) {
        if (trimmed.isNotEmpty) {
          buffer.add(trimmed);
        }
      }
    }
    if (buffer.isEmpty) {
      return null;
    }
    return buffer.join(' ');
  }

  List<String> _markdownBulletList(String content, String heading) {
    final lines = content.split('\n');
    var inSection = false;
    final items = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('## ')) {
        final currentHeading = trimmed.substring(3).trim();
        if (inSection && currentHeading != heading) {
          break;
        }
        inSection = currentHeading.toLowerCase() == heading.toLowerCase();
        continue;
      }
      if (inSection && trimmed.startsWith('- ')) {
        items.add(trimmed.substring(2).trim());
      }
    }
    return items;
  }

  List<String> _markdownNumberedList(String content, String heading) {
    final lines = content.split('\n');
    var inSection = false;
    final items = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('## ')) {
        final currentHeading = trimmed.substring(3).trim();
        if (inSection && currentHeading != heading) {
          break;
        }
        inSection = currentHeading.toLowerCase() == heading.toLowerCase();
        continue;
      }
      if (inSection && RegExp(r'^\d+\.\s+').hasMatch(trimmed)) {
        items.add(trimmed.replaceFirst(RegExp(r'^\d+\.\s+'), '').trim());
      }
    }
    return items;
  }

  List<String> _keywordsFrom(String fileName, String summary) {
    final source = '$fileName $summary'.toLowerCase();
    final keywords = <String>{};
    if (source.contains('electronics')) keywords.add('electronics');
    if (source.contains('microgrow')) keywords.add('microgrow');
    if (source.contains('biocalm')) keywords.add('biocalm');
    if (source.contains('ai ' ) || source.contains('ai-') || source.contains('ai_')) {
      keywords.add('ai');
    }
    if (source.contains('food')) keywords.add('food resilience');
    if (source.contains('youth')) keywords.add('leadership');
    if (source.contains('safety')) keywords.add('safety');
    return keywords.toList(growable: false);
  }

  String _pathwayIdForFile(String fileName) {
    final normalized = fileName.toLowerCase();
    if (normalized.contains('electronics')) return 'electronics_foundations';
    if (normalized.contains('embedded')) return 'embedded_systems';
    if (normalized.contains('microgrow')) return 'microgrow_operator';
    if (normalized.contains('biocalm')) return 'biocalm_foundations';
    if (normalized.contains('ai')) return 'ai_literacy';
    if (normalized.contains('food')) return 'food_resilience';
    if (normalized.contains('youth')) return 'youth_innovation';
    if (normalized.contains('workshop')) return 'workshop_safety';
    if (normalized.contains('business')) return 'business_enterprise';
    if (normalized.contains('systems')) return 'sustainability_regeneration';
    return 'electronics_foundations';
  }

  String _pathwayIdForLessonFile(String fileName) {
    final normalized = fileName.toLowerCase();
    if (normalized.contains('electronics')) return 'electronics_foundations';
    if (normalized.contains('microgrow')) return 'microgrow_operator';
    return _pathwayIdForFile(fileName);
  }

  List<String> _resourceIdsForPathway(String pathwayId) {
    return switch (pathwayId) {
      'electronics_foundations' => ['res_electronics_intro', 'res_parts_reference'],
      'embedded_systems' => ['res_board_setup', 'res_pin_map', 'res_debug_notes'],
      'microgrow_operator' => ['res_microgrow_intro', 'res_microgrow_checklist'],
      'biocalm_foundations' => ['res_biocalm_intro'],
      'ai_literacy' => ['res_ai_prompting'],
      'food_resilience' => ['res_food_systems'],
      'workshop_safety' => ['res_calm_build_checklist'],
      'business_enterprise' => ['res_tool_safety'],
      _ => ['res_calm_build_checklist'],
    };
  }

  List<Map<String, dynamic>> _pathwaySeeds() {
    return [
      _pathway(
        id: 'electronics_foundations',
        title: 'Electronics Foundations',
        summary: 'Learn the calm basics of circuits, components, and safe build habits.',
        level: 'Beginner',
        estimatedHours: 12,
        domain: 'Electronics',
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Safe Low-Voltage Working', 'Sensor Observation'],
        units: [
          _unit(
            id: 'electronics_basics',
            title: 'Electronics basics',
            summary: 'Voltage, current, resistance, and breadboard habits.',
            estimatedHours: 4,
            lessons: const ['lesson_circuits_intro', 'lesson_component_identification'],
          ),
          _unit(
            id: 'electronics_build',
            title: 'First calm build',
            summary: 'Read a diagram, wire a simple circuit, and reflect.',
            estimatedHours: 8,
            lessons: const ['lesson_led_calm_build', 'lesson_multimeter_intro'],
          ),
        ],
      ),
      _pathway(
        id: 'embedded_systems',
        title: 'Embedded Systems',
        summary: 'Work with microcontrollers, sensors, and practical debugging.',
        level: 'Beginner to Intermediate',
        estimatedHours: 20,
        domain: 'Engineering',
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Sensor Observation', 'Systems Thinking'],
        units: [
          _unit(
            id: 'embedded_setup',
            title: 'Setup and sensing',
            summary: 'Board setup, pin mapping, and signal reading.',
            estimatedHours: 8,
            lessons: const ['lesson_board_setup', 'lesson_pin_mapping'],
          ),
          _unit(
            id: 'embedded_debug',
            title: 'Debug calmly',
            summary: 'Check logs, isolate faults, and capture evidence.',
            estimatedHours: 12,
            lessons: const ['lesson_serial_monitor', 'lesson_fault_isolation'],
          ),
        ],
      ),
      _pathway(
        id: 'microgrow_operator',
        title: 'MicroGrow Operator',
        summary: 'Run and support the MicroGrow learning path and field workflow.',
        level: 'Beginner',
        estimatedHours: 10,
        domain: 'MicroGrow',
        audiences: const ['student', 'mentor', 'parentGuardian', 'admin'],
        skillTags: const ['Systems Thinking', 'Reflective Learning'],
        units: [
          _unit(
            id: 'microgrow_overview',
            title: 'System overview',
            summary: 'Understand the grow cycle and local operating checks.',
            estimatedHours: 4,
            lessons: const ['lesson_microgrow_intro', 'lesson_microgrow_checks'],
          ),
          _unit(
            id: 'microgrow_actions',
            title: 'Daily operator actions',
            summary: 'Read the dashboard, record observations, and keep the system steady.',
            estimatedHours: 6,
            lessons: const ['lesson_microgrow_routine', 'lesson_microgrow_reflection'],
          ),
        ],
      ),
      _pathway(
        id: 'biocalm_foundations',
        title: 'BioCalm Foundations',
        summary: 'Explore calm wearable concepts, sensing, and human-centered design.',
        level: 'Beginner',
        estimatedHours: 8,
        domain: 'BioCalm',
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Systems Thinking', 'Responsible AI Use'],
        units: [
          _unit(
            id: 'biocalm_basics',
            title: 'Foundations',
            summary: 'Signals, comfort, and safe design thinking.',
            estimatedHours: 4,
            lessons: const ['lesson_biocalm_intro', 'lesson_biocalm_safety'],
          ),
          _unit(
            id: 'biocalm_practice',
            title: 'Practice build',
            summary: 'Build a calm prototype and document what it teaches.',
            estimatedHours: 4,
            lessons: const ['lesson_biocalm_practice', 'lesson_biocalm_reflection'],
          ),
        ],
      ),
      _pathway(
        id: 'ai_literacy',
        title: 'AI Literacy',
        summary: 'Use AI safely, understand limitations, and ask better questions.',
        level: 'Beginner',
        estimatedHours: 6,
        domain: 'AI',
        audiences: const ['student', 'mentor', 'parentGuardian', 'admin'],
        skillTags: const ['Responsible AI Use', 'Reflective Learning'],
        units: [
          _unit(
            id: 'ai_basics',
            title: 'AI basics',
            summary: 'What AI can and cannot do, in calm language.',
            estimatedHours: 3,
            lessons: const ['lesson_ai_intro', 'lesson_ai_prompting'],
          ),
          _unit(
            id: 'ai_safety',
            title: 'Safety and checking',
            summary: 'Verify outputs, avoid over-trust, and keep adults in the loop.',
            estimatedHours: 3,
            lessons: const ['lesson_ai_safety', 'lesson_ai_checking'],
          ),
        ],
      ),
      _pathway(
        id: 'food_resilience',
        title: 'Food Resilience',
        summary: 'Link growing, food systems, and practical resilience learning.',
        level: 'Beginner',
        estimatedHours: 10,
        domain: 'Regeneration',
        audiences: const ['student', 'mentor', 'parentGuardian'],
        skillTags: const ['Systems Thinking', 'Reflective Learning'],
        units: [
          _unit(
            id: 'food_systems',
            title: 'Food systems',
            summary: 'Observe growing cycles and resource needs.',
            estimatedHours: 5,
            lessons: const ['lesson_food_systems', 'lesson_food_observation'],
          ),
          _unit(
            id: 'food_actions',
            title: 'Small practical actions',
            summary: 'Plan local actions that help resilience feel achievable.',
            estimatedHours: 5,
            lessons: const ['lesson_food_practice', 'lesson_food_reflection'],
          ),
        ],
      ),
      _pathway(
        id: 'sustainability_regeneration',
        title: 'Sustainability & Regeneration',
        summary: 'Connect projects to stewardship, repair, reuse, and gentle systems change.',
        level: 'Intermediate',
        estimatedHours: 14,
        domain: 'Regeneration',
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Systems Thinking', 'Reflective Learning'],
        units: [
          _unit(
            id: 'regeneration_foundations',
            title: 'Regeneration foundations',
            summary: 'Understand cycles, waste, and repair.',
            estimatedHours: 7,
            lessons: const ['lesson_regeneration_intro', 'lesson_regeneration_cycles'],
          ),
          _unit(
            id: 'regeneration_projects',
            title: 'Practical projects',
            summary: 'Link small repairs and stewardship to daily actions.',
            estimatedHours: 7,
            lessons: const ['lesson_regeneration_practice', 'lesson_regeneration_review'],
          ),
        ],
      ),
      _pathway(
        id: 'youth_innovation',
        title: 'Youth Innovation & Leadership',
        summary: 'Support young people to build, present, and lead with confidence.',
        level: 'Beginner to Intermediate',
        estimatedHours: 12,
        domain: 'Community',
        audiences: const ['student', 'mentor', 'parentGuardian', 'admin'],
        skillTags: const ['Reflective Learning', 'Systems Thinking'],
        units: [
          _unit(
            id: 'innovation_skills',
            title: 'Innovation skills',
            summary: 'Idea to prototype, one gentle step at a time.',
            estimatedHours: 6,
            lessons: const ['lesson_innovation_intro', 'lesson_innovation_prototype'],
          ),
          _unit(
            id: 'leadership_skills',
            title: 'Leadership habits',
            summary: 'Communication, decision making, and peer support.',
            estimatedHours: 6,
            lessons: const ['lesson_leadership_intro', 'lesson_leadership_reflection'],
          ),
        ],
      ),
      _pathway(
        id: 'workshop_safety',
        title: 'Workshop Safety',
        summary: 'Keep builds calm, careful, and safe in physical learning spaces.',
        level: 'Beginner',
        estimatedHours: 5,
        domain: 'Safety',
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Safe Low-Voltage Working', 'Reflective Learning'],
        units: [
          _unit(
            id: 'safety_basics',
            title: 'Safety basics',
            summary: 'Simple habits for handling tools and equipment.',
            estimatedHours: 3,
            lessons: const ['lesson_safety_intro', 'lesson_safety_habits'],
          ),
          _unit(
            id: 'safety_review',
            title: 'Review and readiness',
            summary: 'Check what is ready before the build begins.',
            estimatedHours: 2,
            lessons: const ['lesson_safety_review'],
          ),
        ],
      ),
      _pathway(
        id: 'business_enterprise',
        title: 'Business & Enterprise Basics',
        summary: 'Connect learning to practical value, planning, and delivery.',
        level: 'Beginner',
        estimatedHours: 8,
        domain: 'Enterprise',
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Systems Thinking', 'Reflective Learning'],
        units: [
          _unit(
            id: 'enterprise_basics',
            title: 'Enterprise basics',
            summary: 'Turn ideas into a practical plan.',
            estimatedHours: 4,
            lessons: const ['lesson_enterprise_intro', 'lesson_enterprise_value'],
          ),
          _unit(
            id: 'enterprise_delivery',
            title: 'Delivery and evidence',
            summary: 'Track what was made, learned, and proven.',
            estimatedHours: 4,
            lessons: const ['lesson_enterprise_delivery', 'lesson_enterprise_review'],
          ),
        ],
      ),
    ];
  }

  List<Map<String, dynamic>> _lessonSeeds() {
    return [
      _lesson(
        id: 'lesson_circuits_intro',
        pathwayId: 'electronics_foundations',
        unitId: 'electronics_basics',
        title: 'Circuits in calm steps',
        summary: 'Understand a simple circuit without overload.',
        objective: 'Identify the path of power and the role of each component.',
        estimatedMinutes: 20,
        difficulty: 'Beginner',
        audiences: const ['student', 'mentor'],
        tags: const ['circuits', 'safety'],
        steps: const [
          'Look at the diagram.',
          'Name each component.',
          'Trace the flow of power.',
          'Record one thing you noticed.',
        ],
        resourceIds: const ['res_electronics_intro'],
        reflectionPrompt: 'What made the circuit easier to understand?',
      ),
      _lesson(
        id: 'lesson_component_identification',
        pathwayId: 'electronics_foundations',
        unitId: 'electronics_basics',
        title: 'Component spotting',
        summary: 'Learn the names and roles of common parts.',
        objective: 'Match a part to its purpose.',
        estimatedMinutes: 25,
        difficulty: 'Beginner',
        audiences: const ['student', 'mentor', 'parentGuardian'],
        tags: const ['components', 'identification'],
        steps: const ['Sort parts.', 'Read the label.', 'Write the purpose.'],
        resourceIds: const ['res_parts_reference'],
        reflectionPrompt: 'Which part felt most familiar after the exercise?',
      ),
      _lesson(
        id: 'lesson_led_calm_build',
        pathwayId: 'electronics_foundations',
        unitId: 'electronics_build',
        title: 'LED calm build',
        summary: 'Complete a gentle first build and log the evidence.',
        objective: 'Wire a simple LED circuit safely.',
        estimatedMinutes: 30,
        difficulty: 'Beginner',
        audiences: const ['student', 'mentor'],
        tags: const ['build', 'evidence'],
        steps: const ['Prepare the board.', 'Wire the LED.', 'Test power.', 'Capture a photo.'],
        resourceIds: const ['res_calm_build_checklist'],
        reflectionPrompt: 'What helped you stay steady while building?',
      ),
      _lesson(
        id: 'lesson_multimeter_intro',
        pathwayId: 'electronics_foundations',
        unitId: 'electronics_build',
        title: 'Introduce the multimeter',
        summary: 'Measure a few values and compare them to expectation.',
        objective: 'Use a multimeter with care and confidence.',
        estimatedMinutes: 30,
        difficulty: 'Beginner',
        audiences: const ['student', 'mentor'],
        tags: const ['measurement', 'tools'],
        steps: const ['Choose the setting.', 'Measure the value.', 'Note the reading.', 'Compare it calmly.'],
        resourceIds: const ['res_tool_safety'],
        reflectionPrompt: 'What changed when you started measuring rather than guessing?',
      ),
      _lesson(
        id: 'lesson_board_setup',
        pathwayId: 'embedded_systems',
        unitId: 'embedded_setup',
        title: 'Board setup',
        summary: 'Prepare the board and understand the pins.',
        objective: 'Set up a microcontroller for a clean first run.',
        estimatedMinutes: 25,
        difficulty: 'Beginner',
        audiences: const ['student', 'mentor', 'admin'],
        tags: const ['embedded', 'setup'],
        steps: const ['Check the board.', 'Review the pins.', 'Connect power.', 'Confirm the toolchain.'],
        resourceIds: const ['res_board_setup'],
        reflectionPrompt: 'Which step felt most important to check twice?',
      ),
      _lesson(
        id: 'lesson_pin_mapping',
        pathwayId: 'embedded_systems',
        unitId: 'embedded_setup',
        title: 'Pin mapping basics',
        summary: 'Map a board pin to a practical task.',
        objective: 'Relate a physical pin to a software label.',
        estimatedMinutes: 30,
        difficulty: 'Beginner',
        audiences: const ['student', 'mentor'],
        tags: const ['pins', 'mapping'],
        steps: const ['Open the pin map.', 'Match the label.', 'Mark the intended use.'],
        resourceIds: const ['res_pin_map'],
        reflectionPrompt: 'What made the pin map easier to read?',
      ),
      _lesson(
        id: 'lesson_serial_monitor',
        pathwayId: 'embedded_systems',
        unitId: 'embedded_debug',
        title: 'Reading serial output',
        summary: 'Use logs as a calm debugging companion.',
        objective: 'Spot useful information in the serial log.',
        estimatedMinutes: 25,
        difficulty: 'Beginner to Intermediate',
        audiences: const ['student', 'mentor'],
        tags: const ['debugging', 'logs'],
        steps: const ['Start the monitor.', 'Read the output.', 'Identify a signal.', 'Write the next action.'],
        resourceIds: const ['res_debug_notes'],
        reflectionPrompt: 'Which line in the log helped you most?',
      ),
      _lesson(
        id: 'lesson_fault_isolation',
        pathwayId: 'embedded_systems',
        unitId: 'embedded_debug',
        title: 'Fault isolation',
        summary: 'Break a problem into small checks.',
        objective: 'Use a step-by-step debugging flow.',
        estimatedMinutes: 35,
        difficulty: 'Intermediate',
        audiences: const ['student', 'mentor', 'admin'],
        tags: const ['debugging', 'analysis'],
        steps: const ['Observe the issue.', 'Check power.', 'Check signal.', 'Document the fix.'],
        resourceIds: const ['res_debug_flow'],
        reflectionPrompt: 'What helped you narrow the fault down?',
      ),
      ..._genericLessonSeeds(),
    ];
  }

  List<Map<String, dynamic>> _projectSeeds() {
    return [
      _project(
        id: 'project_microgrow_sensor_calibration',
        title: 'MicroGrow Sensor Calibration',
        summary: 'Calibrate sensor readings and keep the grow system steady.',
        domain: 'MicroGrow',
        estimatedHours: 6,
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Sensor Observation', 'Systems Thinking'],
        materials: const ['Microcontroller board', 'Sensor', 'Notebook'],
        steps: const ['Check the sensor.', 'Capture a baseline.', 'Compare readings.', 'Record the result.'],
        resourceIds: const ['res_microgrow_intro', 'res_microgrow_checklist'],
      ),
      _project(
        id: 'project_biocalm_signal_glance',
        title: 'BioCalm Signal Glance',
        summary: 'Prototype a calm signal-view concept with safe feedback.',
        domain: 'BioCalm',
        estimatedHours: 5,
        audiences: const ['student', 'mentor'],
        skillTags: const ['Responsible AI Use', 'Systems Thinking'],
        materials: const ['Prototype board', 'Paper sketch', 'Colour markers'],
        steps: const ['Sketch the flow.', 'Define the signal.', 'Review the safety note.'],
        resourceIds: const ['res_biocalm_intro'],
      ),
      _project(
        id: 'project_food_resilience_observation',
        title: 'Food Resilience Observation Log',
        summary: 'Track simple observations from a growing space and reflect on patterns.',
        domain: 'Regeneration',
        estimatedHours: 4,
        audiences: const ['student', 'mentor', 'parentGuardian'],
        skillTags: const ['Reflective Learning', 'Systems Thinking'],
        materials: const ['Notebook', 'Camera', 'Observation sheet'],
        steps: const ['Observe the space.', 'Write one note.', 'Capture evidence.', 'Reflect on the pattern.'],
        resourceIds: const ['res_food_systems'],
      ),
      _project(
        id: 'project_ai_prompt_practice',
        title: 'AI Prompt Practice',
        summary: 'Learn to ask for help without handing over judgment.',
        domain: 'AI',
        estimatedHours: 3,
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Responsible AI Use'],
        materials: const ['Prompt cards', 'Reflection log'],
        steps: const ['Ask a question.', 'Check the response.', 'List what still needs human review.'],
        resourceIds: const ['res_ai_prompting'],
      ),
      _project(
        id: 'project_workshop_ready_check',
        title: 'Workshop Ready Check',
        summary: 'Confirm tools, space, and safety before a build session.',
        domain: 'Safety',
        estimatedHours: 2,
        audiences: const ['student', 'mentor', 'admin'],
        skillTags: const ['Safe Low-Voltage Working'],
        materials: const ['Checklist', 'Safety notes'],
        steps: const ['Open the checklist.', 'Check the space.', 'Confirm readiness.'],
        resourceIds: const ['res_tool_safety'],
      ),
    ];
  }

  List<Map<String, dynamic>> _studentSeeds() {
    return [
      _student(
        id: 'student_hayley',
        name: 'Hayley Arthur',
        role: 'Student',
        stage: 'Project learner',
        mentorName: 'Peter Ellis',
        guardianName: 'Mia Arthur',
        activePathwayId: 'electronics_foundations',
        badgeIds: const ['badge_safe_starter', 'badge_reflector'],
      ),
      _student(
        id: 'student_peter',
        name: 'Peter Ellis',
        role: 'Mentor',
        stage: 'Founder support',
        mentorName: 'Peter Ellis',
        guardianName: 'Not set',
        activePathwayId: 'ai_literacy',
        badgeIds: const ['badge_mentor_support'],
      ),
      _student(
        id: 'student_mia',
        name: 'Mia Arthur',
        role: 'Parent / Guardian',
        stage: 'Support view',
        mentorName: 'Peter Ellis',
        guardianName: 'Mia Arthur',
        activePathwayId: 'workshop_safety',
        badgeIds: const ['badge_guardian_support'],
      ),
    ];
  }

  List<Map<String, dynamic>> _progressSeeds() {
    return [
      _progress(
        id: 'progress_pathway_electronics',
        studentId: 'student_hayley',
        entityId: 'electronics_foundations',
        entityType: 'pathway',
        status: 'in progress',
        progressPercent: 68,
        updatedAt: DateTime.utc(2026, 7, 1, 9, 0),
        note: 'Comfortable with the first two lessons.',
      ),
      _progress(
        id: 'progress_lesson_led',
        studentId: 'student_hayley',
        entityId: 'lesson_led_calm_build',
        entityType: 'lesson',
        status: 'complete',
        progressPercent: 100,
        updatedAt: DateTime.utc(2026, 6, 30, 16, 0),
        note: 'Completed with a clean reflection.',
      ),
      _progress(
        id: 'progress_project_microgrow',
        studentId: 'student_hayley',
        entityId: 'project_microgrow_sensor_calibration',
        entityType: 'project',
        status: 'in progress',
        progressPercent: 45,
        updatedAt: DateTime.utc(2026, 7, 2, 10, 0),
        note: 'Need one more baseline reading.',
      ),
      _progress(
        id: 'progress_ai',
        studentId: 'student_peter',
        entityId: 'ai_literacy',
        entityType: 'pathway',
        status: 'planned',
        progressPercent: 18,
        updatedAt: DateTime.utc(2026, 7, 1, 8, 30),
        note: 'Preparing a safe prompt pack.',
      ),
    ];
  }

  List<Map<String, dynamic>> _assessmentSeeds() {
    return [
      _assessment(
        id: 'assessment_led_check',
        title: 'LED build check',
        kind: 'Practical checklist',
        summary: 'Confirm safe wiring and clear evidence capture.',
        maxScore: 10,
        score: 9,
        studentId: 'student_hayley',
        pathwayId: 'electronics_foundations',
        criteria: const ['Safe wiring', 'Clear evidence', 'Calm reflection'],
        completedAt: DateTime.utc(2026, 6, 30, 16, 20),
        audiences: const ['student', 'mentor'],
        mentorFeedback: 'Steady pace and strong observation.',
      ),
      _assessment(
        id: 'assessment_ai_reflection',
        title: 'AI reflection check',
        kind: 'Reflection review',
        summary: 'Explain what the AI helped with and what still needs a human check.',
        maxScore: 8,
        score: 0,
        studentId: 'student_peter',
        pathwayId: 'ai_literacy',
        criteria: const ['Safe use', 'Human review', 'Clear notes'],
        completedAt: null,
        audiences: const ['mentor', 'admin'],
      ),
    ];
  }

  List<Map<String, dynamic>> _reflectionSeeds() {
    return [
      _reflection(
        id: 'reflection_hayley_1',
        studentId: 'student_hayley',
        title: 'First calm build',
        body: 'The build felt easier once I broke it into tiny steps.',
        mood: 'Calm',
        createdAt: DateTime.utc(2026, 6, 30, 16, 40),
        audiences: const ['student', 'mentor', 'parentGuardian'],
        linkedLessonId: 'lesson_led_calm_build',
      ),
      _reflection(
        id: 'reflection_hayley_2',
        studentId: 'student_hayley',
        title: 'Sensor reading day',
        body: 'I noticed that careful checking helped me trust the sensor result.',
        mood: 'Focused',
        createdAt: DateTime.utc(2026, 7, 2, 10, 30),
        audiences: const ['student', 'mentor'],
        linkedProjectId: 'project_microgrow_sensor_calibration',
      ),
      _reflection(
        id: 'reflection_peter_1',
        studentId: 'student_peter',
        title: 'Prompt checking',
        body: 'The best prompts leave space for human judgement.',
        mood: 'Thoughtful',
        createdAt: DateTime.utc(2026, 7, 1, 9, 10),
        audiences: const ['mentor', 'admin'],
      ),
    ];
  }

  List<Map<String, dynamic>> _mentorNoteSeeds() {
    return [
      _mentorNote(
        id: 'note_hayley_1',
        studentId: 'student_hayley',
        author: 'Peter Ellis',
        content: 'Good pace today. Keep the next lesson short and practical.',
        createdAt: DateTime.utc(2026, 7, 2, 10, 45),
        priority: 'medium',
      ),
      _mentorNote(
        id: 'note_hayley_2',
        studentId: 'student_hayley',
        author: 'Peter Ellis',
        content: 'Add one more evidence photo before sign-off.',
        createdAt: DateTime.utc(2026, 7, 2, 11, 15),
        priority: 'high',
      ),
      _mentorNote(
        id: 'note_peter_1',
        studentId: 'student_peter',
        author: 'System',
        content: 'Mentor view ready for pathway review and reflection capture.',
        createdAt: DateTime.utc(2026, 7, 1, 9, 30),
        priority: 'low',
      ),
    ];
  }

  List<Map<String, dynamic>> _certificateSeeds() {
    return [
      _certificate(
        id: 'certificate_safe_starter',
        studentId: 'student_hayley',
        title: 'Safe Starter Badge',
        summary: 'Completed the workshop safety introduction and evidence review.',
        badgeLevel: 'Bronze',
        issuedBy: 'New Earth Learning Hub',
        awardedAt: DateTime.utc(2026, 6, 30, 16, 50),
      ),
      _certificate(
        id: 'certificate_reflector',
        studentId: 'student_hayley',
        title: 'Reflective Learner Badge',
        summary: 'Captured useful reflections across multiple sessions.',
        badgeLevel: 'Bronze',
        issuedBy: 'New Earth Learning Hub',
        awardedAt: DateTime.utc(2026, 7, 2, 11, 45),
      ),
      _certificate(
        id: 'certificate_mentor_support',
        studentId: 'student_peter',
        title: 'Mentor Support Badge',
        summary: 'Maintained calm support, notes, and sign-off guidance.',
        badgeLevel: 'Silver',
        issuedBy: 'New Earth Learning Hub',
        awardedAt: DateTime.utc(2026, 7, 1, 10, 0),
      ),
    ];
  }

  List<Map<String, dynamic>> _resourceSeeds() {
    return [
      _resource(
        id: 'res_electronics_intro',
        title: 'Electronics foundations note',
        type: 'lesson',
        category: 'Electronics',
        path: '$moduleRootPath/04_LEARNING_PATHWAYS/ELECTRONICS_FOUNDATIONS.md',
        description: 'Read before the first circuit walkthrough.',
      ),
      _resource(
        id: 'res_parts_reference',
        title: 'Component reference',
        type: 'reference',
        category: 'Electronics',
        path: '$moduleRootPath/05_CONTENT_LIBRARY/LESSON_TEMPLATE.md',
        description: 'Use this to keep a lesson structure calm and repeatable.',
      ),
      _resource(
        id: 'res_calm_build_checklist',
        title: 'Calm build checklist',
        type: 'checklist',
        category: 'Workshop',
        path: '$moduleRootPath/13_SECURITY_AND_SAFETY/LEARNER_SAFETY.md',
        description: 'A simple checklist for safe physical work.',
      ),
      _resource(
        id: 'res_board_setup',
        title: 'Embedded setup notes',
        type: 'lesson',
        category: 'Embedded',
        path: '$moduleRootPath/04_LEARNING_PATHWAYS/EMBEDDED_SYSTEMS.md',
        description: 'A safe starting point for board setup.',
      ),
      _resource(
        id: 'res_microgrow_intro',
        title: 'MicroGrow pathway',
        type: 'pathway',
        category: 'MicroGrow',
        path: '$moduleRootPath/04_LEARNING_PATHWAYS/MICROGROW_OPERATOR.md',
        description: 'Follow the operator flow and keep observations steady.',
      ),
      _resource(
        id: 'res_biocalm_intro',
        title: 'BioCalm foundations',
        type: 'pathway',
        category: 'BioCalm',
        path: '$moduleRootPath/04_LEARNING_PATHWAYS/BIOCALM_FOUNDATIONS.md',
        description: 'Calm wearable concepts and safe design thinking.',
      ),
      _resource(
        id: 'res_ai_prompting',
        title: 'AI prompt library',
        type: 'prompt',
        category: 'AI',
        path: '$moduleRootPath/06_AI_TUTOR/PROMPT_LIBRARY.md',
        description: 'Prompt starters for a safe AI tutor experience.',
      ),
      _resource(
        id: 'res_food_systems',
        title: 'Food resilience pathway',
        type: 'pathway',
        category: 'Regeneration',
        path: '$moduleRootPath/04_LEARNING_PATHWAYS/FOOD_RESILIENCE.md',
        description: 'Use for practical food and resilience learning.',
      ),
    ];
  }

  List<Map<String, dynamic>> _genericLessonSeeds() {
    const lessonData = [
      (
        id: 'lesson_microgrow_intro',
        pathwayId: 'microgrow_operator',
        unitId: 'microgrow_overview',
        title: 'MicroGrow overview',
        summary: 'Understand the system and the learner role.',
      ),
      (
        id: 'lesson_microgrow_checks',
        pathwayId: 'microgrow_operator',
        unitId: 'microgrow_overview',
        title: 'Daily checks',
        summary: 'Notice the calm daily operator checks.',
      ),
      (
        id: 'lesson_microgrow_routine',
        pathwayId: 'microgrow_operator',
        unitId: 'microgrow_actions',
        title: 'Operator routine',
        summary: 'Track the steady sequence of actions.',
      ),
      (
        id: 'lesson_microgrow_reflection',
        pathwayId: 'microgrow_operator',
        unitId: 'microgrow_actions',
        title: 'Operator reflection',
        summary: 'Record what the system taught you.',
      ),
      (
        id: 'lesson_biocalm_intro',
        pathwayId: 'biocalm_foundations',
        unitId: 'biocalm_basics',
        title: 'BioCalm introduction',
        summary: 'Introduce the wearable concept gently.',
      ),
      (
        id: 'lesson_biocalm_safety',
        pathwayId: 'biocalm_foundations',
        unitId: 'biocalm_basics',
        title: 'BioCalm safety',
        summary: 'Keep the first design decisions safe and human-led.',
      ),
      (
        id: 'lesson_biocalm_practice',
        pathwayId: 'biocalm_foundations',
        unitId: 'biocalm_practice',
        title: 'Practice prototype',
        summary: 'Draft one calm prototype step.',
      ),
      (
        id: 'lesson_biocalm_reflection',
        pathwayId: 'biocalm_foundations',
        unitId: 'biocalm_practice',
        title: 'BioCalm reflection',
        summary: 'Reflect on comfort and usefulness.',
      ),
      (
        id: 'lesson_ai_intro',
        pathwayId: 'ai_literacy',
        unitId: 'ai_basics',
        title: 'AI basics',
        summary: 'What AI is for and where it needs help.',
      ),
      (
        id: 'lesson_ai_prompting',
        pathwayId: 'ai_literacy',
        unitId: 'ai_basics',
        title: 'Prompt crafting',
        summary: 'Ask a good question and keep the output in context.',
      ),
      (
        id: 'lesson_ai_safety',
        pathwayId: 'ai_literacy',
        unitId: 'ai_safety',
        title: 'AI safety',
        summary: 'Verify, annotate, and involve a human reviewer.',
      ),
      (
        id: 'lesson_ai_checking',
        pathwayId: 'ai_literacy',
        unitId: 'ai_safety',
        title: 'Checking outputs',
        summary: 'Separate useful hints from final decisions.',
      ),
      (
        id: 'lesson_food_systems',
        pathwayId: 'food_resilience',
        unitId: 'food_systems',
        title: 'Food systems observation',
        summary: 'Notice how inputs and outputs move through the system.',
      ),
      (
        id: 'lesson_food_observation',
        pathwayId: 'food_resilience',
        unitId: 'food_systems',
        title: 'Observation log',
        summary: 'Write down a small, useful observation.',
      ),
      (
        id: 'lesson_food_practice',
        pathwayId: 'food_resilience',
        unitId: 'food_actions',
        title: 'Small resilience action',
        summary: 'Choose one action that is realistic today.',
      ),
      (
        id: 'lesson_food_reflection',
        pathwayId: 'food_resilience',
        unitId: 'food_actions',
        title: 'Resilience reflection',
        summary: 'Capture what changed and why it matters.',
      ),
      (
        id: 'lesson_regeneration_intro',
        pathwayId: 'sustainability_regeneration',
        unitId: 'regeneration_foundations',
        title: 'Regeneration intro',
        summary: 'Understand stewardship and repair as practical habits.',
      ),
      (
        id: 'lesson_regeneration_cycles',
        pathwayId: 'sustainability_regeneration',
        unitId: 'regeneration_foundations',
        title: 'Cycles and reuse',
        summary: 'Spot cycles in materials and learning.',
      ),
      (
        id: 'lesson_regeneration_practice',
        pathwayId: 'sustainability_regeneration',
        unitId: 'regeneration_projects',
        title: 'Practical stewardship',
        summary: 'Complete one local stewardship step.',
      ),
      (
        id: 'lesson_regeneration_review',
        pathwayId: 'sustainability_regeneration',
        unitId: 'regeneration_projects',
        title: 'Stewardship review',
        summary: 'Review what the project changed locally.',
      ),
      (
        id: 'lesson_innovation_intro',
        pathwayId: 'youth_innovation',
        unitId: 'innovation_skills',
        title: 'Idea to prototype',
        summary: 'Move one idea into a tiny prototype.',
      ),
      (
        id: 'lesson_innovation_prototype',
        pathwayId: 'youth_innovation',
        unitId: 'innovation_skills',
        title: 'Prototype practice',
        summary: 'Try a simple version and record the result.',
      ),
      (
        id: 'lesson_leadership_intro',
        pathwayId: 'youth_innovation',
        unitId: 'leadership_skills',
        title: 'Leadership basics',
        summary: 'Use calm language to support others.',
      ),
      (
        id: 'lesson_leadership_reflection',
        pathwayId: 'youth_innovation',
        unitId: 'leadership_skills',
        title: 'Leadership reflection',
        summary: 'Notice what helped the group move forward.',
      ),
      (
        id: 'lesson_safety_intro',
        pathwayId: 'workshop_safety',
        unitId: 'safety_basics',
        title: 'Safety introduction',
        summary: 'Set the tone for a careful workshop session.',
      ),
      (
        id: 'lesson_safety_habits',
        pathwayId: 'workshop_safety',
        unitId: 'safety_basics',
        title: 'Safety habits',
        summary: 'Build a short safety routine.',
      ),
      (
        id: 'lesson_safety_review',
        pathwayId: 'workshop_safety',
        unitId: 'safety_review',
        title: 'Readiness review',
        summary: 'Confirm the workspace is ready.',
      ),
      (
        id: 'lesson_enterprise_intro',
        pathwayId: 'business_enterprise',
        unitId: 'enterprise_basics',
        title: 'Enterprise intro',
        summary: 'Connect a learning project to value and audience.',
      ),
      (
        id: 'lesson_enterprise_value',
        pathwayId: 'business_enterprise',
        unitId: 'enterprise_basics',
        title: 'Value thinking',
        summary: 'State why the work matters in one sentence.',
      ),
      (
        id: 'lesson_enterprise_delivery',
        pathwayId: 'business_enterprise',
        unitId: 'enterprise_delivery',
        title: 'Delivery tracking',
        summary: 'Track evidence and next steps clearly.',
      ),
      (
        id: 'lesson_enterprise_review',
        pathwayId: 'business_enterprise',
        unitId: 'enterprise_delivery',
        title: 'Review and handoff',
        summary: 'Review the work and prepare the handoff.',
      ),
    ];

    return lessonData
        .map(
          (lesson) => _lesson(
            id: lesson.id,
            pathwayId: lesson.pathwayId,
            unitId: lesson.unitId,
            title: lesson.title,
            summary: lesson.summary,
            objective: 'Practice the learning step in a calm, practical way.',
            estimatedMinutes: 25,
            difficulty: 'Beginner',
            audiences: const ['student', 'mentor', 'admin'],
            tags: const ['learning', 'practice'],
            steps: const ['Read the note.', 'Do the activity.', 'Write a reflection.'],
            resourceIds: const ['res_calm_build_checklist'],
            reflectionPrompt: 'What helped this lesson feel manageable?',
          ),
        )
        .toList(growable: false);
  }

  Map<String, dynamic> _pathway({
    required String id,
    required String title,
    required String summary,
    required String level,
    required int estimatedHours,
    required String domain,
    required List<String> audiences,
    required List<String> skillTags,
    required List<Map<String, dynamic>> units,
  }) {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'level': level,
      'estimatedHours': estimatedHours,
      'domain': domain,
      'audiences': audiences,
      'skillTags': skillTags,
      'units': units,
    };
  }

  Map<String, dynamic> _unit({
    required String id,
    required String title,
    required String summary,
    required int estimatedHours,
    required List<String> lessons,
  }) {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'estimatedHours': estimatedHours,
      'lessons': lessons,
    };
  }

  Map<String, dynamic> _lesson({
    required String id,
    required String pathwayId,
    required String unitId,
    required String title,
    required String summary,
    required String objective,
    required int estimatedMinutes,
    required String difficulty,
    required List<String> audiences,
    required List<String> tags,
    required List<String> steps,
    required List<String> resourceIds,
    required String reflectionPrompt,
  }) {
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

  Map<String, dynamic> _project({
    required String id,
    required String title,
    required String summary,
    required String domain,
    required int estimatedHours,
    required List<String> audiences,
    required List<String> skillTags,
    required List<String> materials,
    required List<String> steps,
    required List<String> resourceIds,
  }) {
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

  Map<String, dynamic> _student({
    required String id,
    required String name,
    required String role,
    required String stage,
    required String mentorName,
    required String guardianName,
    required String activePathwayId,
    required List<String> badgeIds,
  }) {
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

  Map<String, dynamic> _progress({
    required String id,
    required String studentId,
    required String entityId,
    required String entityType,
    required String status,
    required int progressPercent,
    required DateTime updatedAt,
    required String note,
  }) {
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

  Map<String, dynamic> _assessment({
    required String id,
    required String title,
    required String kind,
    required String summary,
    required int maxScore,
    required int score,
    required String studentId,
    required String pathwayId,
    required List<String> criteria,
    required DateTime? completedAt,
    required List<String> audiences,
    String mentorFeedback = '',
  }) {
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

  Map<String, dynamic> _reflection({
    required String id,
    required String studentId,
    required String title,
    required String body,
    required String mood,
    required DateTime createdAt,
    required List<String> audiences,
    String linkedLessonId = '',
    String linkedProjectId = '',
  }) {
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

  Map<String, dynamic> _mentorNote({
    required String id,
    required String studentId,
    required String author,
    required String content,
    required DateTime createdAt,
    required String priority,
  }) {
    return {
      'id': id,
      'studentId': studentId,
      'author': author,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'priority': priority,
    };
  }

  Map<String, dynamic> _certificate({
    required String id,
    required String studentId,
    required String title,
    required String summary,
    required String badgeLevel,
    required String issuedBy,
    required DateTime awardedAt,
  }) {
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

  Map<String, dynamic> _resource({
    required String id,
    required String title,
    required String type,
    required String category,
    required String path,
    required String description,
  }) {
    return {
      'id': id,
      'title': title,
      'type': type,
      'category': category,
      'path': path,
      'description': description,
    };
  }

  List<ContentSourceEntry> _contentSourceFallback() {
    return [
      ContentSourceEntry(
        id: '04_LEARNING_PATHWAYS/EMBEDDED_SYSTEMS.md',
        title: 'Embedded Systems',
        category: 'Learning pathways',
        kind: 'Documentation',
        path: path.join(moduleRootPath, '04_LEARNING_PATHWAYS', 'EMBEDDED_SYSTEMS.md'),
        description: 'Fallback content index for the embedded systems pathway.',
        exists: false,
      ),
      ContentSourceEntry(
        id: '05_CONTENT_LIBRARY/LESSON_TEMPLATE.md',
        title: 'Lesson Template',
        category: 'Content library',
        kind: 'Documentation',
        path: path.join(moduleRootPath, '05_CONTENT_LIBRARY', 'LESSON_TEMPLATE.md'),
        description: 'Fallback content index for lesson structure and reuse.',
        exists: false,
      ),
      ContentSourceEntry(
        id: '16_SAMPLE_DATA/pathways.json',
        title: 'Pathways Sample Data',
        category: 'Sample data',
        kind: 'Sample data',
        path: path.join(moduleRootPath, '16_SAMPLE_DATA', 'pathways.json'),
        description: 'Fallback content index for local pathway samples.',
        exists: false,
      ),
    ];
  }

  String _friendlyLabel(String raw) {
    final value = raw
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (value.isEmpty) {
      return 'Module';
    }
    return value
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          return lower[0].toUpperCase() + lower.substring(1);
        })
        .join(' ');
  }

  String _contentDescriptionFor(String relativePath) {
    if (relativePath.startsWith('04_LEARNING_PATHWAYS')) {
      return 'Pathway guidance and curriculum notes.';
    }
    if (relativePath.startsWith('05_CONTENT_LIBRARY')) {
      return 'Reusable lesson and content structure.';
    }
    if (relativePath.startsWith('06_AI_TUTOR')) {
      return 'Tutor prompts and safety guidance.';
    }
    if (relativePath.startsWith('07_ASSESSMENTS')) {
      return 'Assessment and review material.';
    }
    if (relativePath.startsWith('08_PROJECT_BASED_LEARNING')) {
      return 'Project workspace and evidence notes.';
    }
    if (relativePath.startsWith('09_ADMIN_AND_GUARDIANS')) {
      return 'Role guidance for mentors and guardians.';
    }
    if (relativePath.startsWith('10_LOCAL_FIRST_DATA')) {
      return 'Offline content pack notes and storage rules.';
    }
    if (relativePath.startsWith('11_INTEGRATIONS')) {
      return 'Future integration hooks and boundaries.';
    }
    if (relativePath.startsWith('12_TESTING_AND_QA')) {
      return 'Testing and quality assurance guidance.';
    }
    if (relativePath.startsWith('13_SECURITY_AND_SAFETY')) {
      return 'Safety and learner protection rules.';
    }
    if (relativePath.startsWith('14_ROADMAP')) {
      return 'Roadmap and future build sequencing.';
    }
    if (relativePath.startsWith('15_CODEX')) {
      return 'Codex build instructions and prompts.';
    }
    if (relativePath.startsWith('16_SAMPLE_DATA')) {
      return 'Local mock content used by the first build.';
    }
    if (relativePath.startsWith('17_SRC_SCAFFOLD')) {
      return 'Source scaffold notes for future code generation.';
    }
    if (relativePath.startsWith('18_TEMPLATES')) {
      return 'Reusable module templates for new content.';
    }
    if (relativePath.startsWith('19_DEPLOYMENT')) {
      return 'Route and deployment guidance.';
    }
    if (relativePath.startsWith('20_DOCUMENTATION')) {
      return 'User-facing and developer-facing docs.';
    }
    return 'Local module content source.';
  }
}
