// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortDescriptionMeta = const VerificationMeta(
    'shortDescription',
  );
  @override
  late final GeneratedColumn<String> shortDescription = GeneratedColumn<String>(
    'short_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longDescriptionMeta = const VerificationMeta(
    'longDescription',
  );
  @override
  late final GeneratedColumn<String> longDescription = GeneratedColumn<String>(
    'long_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visionMeta = const VerificationMeta('vision');
  @override
  late final GeneratedColumn<String> vision = GeneratedColumn<String>(
    'vision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Idea'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Medium'),
  );
  static const VerificationMeta _progressPercentageMeta =
      const VerificationMeta('progressPercentage');
  @override
  late final GeneratedColumn<int> progressPercentage = GeneratedColumn<int>(
    'progress_percentage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentMilestoneMeta = const VerificationMeta(
    'currentMilestone',
  );
  @override
  late final GeneratedColumn<String> currentMilestone = GeneratedColumn<String>(
    'current_milestone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    projectId,
    name,
    shortDescription,
    longDescription,
    vision,
    status,
    priority,
    progressPercentage,
    currentMilestone,
    nextAction,
    startDate,
    targetDate,
    createdAt,
    updatedAt,
    notes,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_description')) {
      context.handle(
        _shortDescriptionMeta,
        shortDescription.isAcceptableOrUnknown(
          data['short_description']!,
          _shortDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('long_description')) {
      context.handle(
        _longDescriptionMeta,
        longDescription.isAcceptableOrUnknown(
          data['long_description']!,
          _longDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('vision')) {
      context.handle(
        _visionMeta,
        vision.isAcceptableOrUnknown(data['vision']!, _visionMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('progress_percentage')) {
      context.handle(
        _progressPercentageMeta,
        progressPercentage.isAcceptableOrUnknown(
          data['progress_percentage']!,
          _progressPercentageMeta,
        ),
      );
    }
    if (data.containsKey('current_milestone')) {
      context.handle(
        _currentMilestoneMeta,
        currentMilestone.isAcceptableOrUnknown(
          data['current_milestone']!,
          _currentMilestoneMeta,
        ),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectId};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      shortDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_description'],
      ),
      longDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}long_description'],
      ),
      vision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vision'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      progressPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_percentage'],
      )!,
      currentMilestone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_milestone'],
      ),
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String projectId;
  final String name;
  final String? shortDescription;
  final String? longDescription;
  final String? vision;
  final String status;
  final String priority;
  final int progressPercentage;
  final String? currentMilestone;
  final String? nextAction;
  final DateTime? startDate;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final bool isArchived;
  const Project({
    required this.projectId,
    required this.name,
    this.shortDescription,
    this.longDescription,
    this.vision,
    required this.status,
    required this.priority,
    required this.progressPercentage,
    this.currentMilestone,
    this.nextAction,
    this.startDate,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || shortDescription != null) {
      map['short_description'] = Variable<String>(shortDescription);
    }
    if (!nullToAbsent || longDescription != null) {
      map['long_description'] = Variable<String>(longDescription);
    }
    if (!nullToAbsent || vision != null) {
      map['vision'] = Variable<String>(vision);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    map['progress_percentage'] = Variable<int>(progressPercentage);
    if (!nullToAbsent || currentMilestone != null) {
      map['current_milestone'] = Variable<String>(currentMilestone);
    }
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      projectId: Value(projectId),
      name: Value(name),
      shortDescription: shortDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(shortDescription),
      longDescription: longDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(longDescription),
      vision: vision == null && nullToAbsent
          ? const Value.absent()
          : Value(vision),
      status: Value(status),
      priority: Value(priority),
      progressPercentage: Value(progressPercentage),
      currentMilestone: currentMilestone == null && nullToAbsent
          ? const Value.absent()
          : Value(currentMilestone),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isArchived: Value(isArchived),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      shortDescription: serializer.fromJson<String?>(json['shortDescription']),
      longDescription: serializer.fromJson<String?>(json['longDescription']),
      vision: serializer.fromJson<String?>(json['vision']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      progressPercentage: serializer.fromJson<int>(json['progressPercentage']),
      currentMilestone: serializer.fromJson<String?>(json['currentMilestone']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'shortDescription': serializer.toJson<String?>(shortDescription),
      'longDescription': serializer.toJson<String?>(longDescription),
      'vision': serializer.toJson<String?>(vision),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'progressPercentage': serializer.toJson<int>(progressPercentage),
      'currentMilestone': serializer.toJson<String?>(currentMilestone),
      'nextAction': serializer.toJson<String?>(nextAction),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Project copyWith({
    String? projectId,
    String? name,
    Value<String?> shortDescription = const Value.absent(),
    Value<String?> longDescription = const Value.absent(),
    Value<String?> vision = const Value.absent(),
    String? status,
    String? priority,
    int? progressPercentage,
    Value<String?> currentMilestone = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> targetDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
  }) => Project(
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    shortDescription: shortDescription.present
        ? shortDescription.value
        : this.shortDescription,
    longDescription: longDescription.present
        ? longDescription.value
        : this.longDescription,
    vision: vision.present ? vision.value : this.vision,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    progressPercentage: progressPercentage ?? this.progressPercentage,
    currentMilestone: currentMilestone.present
        ? currentMilestone.value
        : this.currentMilestone,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    startDate: startDate.present ? startDate.value : this.startDate,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      shortDescription: data.shortDescription.present
          ? data.shortDescription.value
          : this.shortDescription,
      longDescription: data.longDescription.present
          ? data.longDescription.value
          : this.longDescription,
      vision: data.vision.present ? data.vision.value : this.vision,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      progressPercentage: data.progressPercentage.present
          ? data.progressPercentage.value
          : this.progressPercentage,
      currentMilestone: data.currentMilestone.present
          ? data.currentMilestone.value
          : this.currentMilestone,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('longDescription: $longDescription, ')
          ..write('vision: $vision, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('progressPercentage: $progressPercentage, ')
          ..write('currentMilestone: $currentMilestone, ')
          ..write('nextAction: $nextAction, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    projectId,
    name,
    shortDescription,
    longDescription,
    vision,
    status,
    priority,
    progressPercentage,
    currentMilestone,
    nextAction,
    startDate,
    targetDate,
    createdAt,
    updatedAt,
    notes,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.shortDescription == this.shortDescription &&
          other.longDescription == this.longDescription &&
          other.vision == this.vision &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.progressPercentage == this.progressPercentage &&
          other.currentMilestone == this.currentMilestone &&
          other.nextAction == this.nextAction &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> projectId;
  final Value<String> name;
  final Value<String?> shortDescription;
  final Value<String?> longDescription;
  final Value<String?> vision;
  final Value<String> status;
  final Value<String> priority;
  final Value<int> progressPercentage;
  final Value<String?> currentMilestone;
  final Value<String?> nextAction;
  final Value<DateTime?> startDate;
  final Value<DateTime?> targetDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.shortDescription = const Value.absent(),
    this.longDescription = const Value.absent(),
    this.vision = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.progressPercentage = const Value.absent(),
    this.currentMilestone = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String projectId,
    required String name,
    this.shortDescription = const Value.absent(),
    this.longDescription = const Value.absent(),
    this.vision = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.progressPercentage = const Value.absent(),
    this.currentMilestone = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<String>? shortDescription,
    Expression<String>? longDescription,
    Expression<String>? vision,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<int>? progressPercentage,
    Expression<String>? currentMilestone,
    Expression<String>? nextAction,
    Expression<DateTime>? startDate,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (shortDescription != null) 'short_description': shortDescription,
      if (longDescription != null) 'long_description': longDescription,
      if (vision != null) 'vision': vision,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (progressPercentage != null) 'progress_percentage': progressPercentage,
      if (currentMilestone != null) 'current_milestone': currentMilestone,
      if (nextAction != null) 'next_action': nextAction,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? projectId,
    Value<String>? name,
    Value<String?>? shortDescription,
    Value<String?>? longDescription,
    Value<String?>? vision,
    Value<String>? status,
    Value<String>? priority,
    Value<int>? progressPercentage,
    Value<String?>? currentMilestone,
    Value<String?>? nextAction,
    Value<DateTime?>? startDate,
    Value<DateTime?>? targetDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      vision: vision ?? this.vision,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      currentMilestone: currentMilestone ?? this.currentMilestone,
      nextAction: nextAction ?? this.nextAction,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortDescription.present) {
      map['short_description'] = Variable<String>(shortDescription.value);
    }
    if (longDescription.present) {
      map['long_description'] = Variable<String>(longDescription.value);
    }
    if (vision.present) {
      map['vision'] = Variable<String>(vision.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (progressPercentage.present) {
      map['progress_percentage'] = Variable<int>(progressPercentage.value);
    }
    if (currentMilestone.present) {
      map['current_milestone'] = Variable<String>(currentMilestone.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('longDescription: $longDescription, ')
          ..write('vision: $vision, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('progressPercentage: $progressPercentage, ')
          ..write('currentMilestone: $currentMilestone, ')
          ..write('nextAction: $nextAction, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Medium'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Inbox'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyLevelMeta = const VerificationMeta(
    'energyLevel',
  );
  @override
  late final GeneratedColumn<String> energyLevel = GeneratedColumn<String>(
    'energy_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualMinutesMeta = const VerificationMeta(
    'actualMinutes',
  );
  @override
  late final GeneratedColumn<int> actualMinutes = GeneratedColumn<int>(
    'actual_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTopThreeMeta = const VerificationMeta(
    'isTopThree',
  );
  @override
  late final GeneratedColumn<bool> isTopThree = GeneratedColumn<bool>(
    'is_top_three',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_top_three" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    taskId,
    projectId,
    title,
    description,
    category,
    priority,
    status,
    dueDate,
    energyLevel,
    estimatedMinutes,
    actualMinutes,
    createdAt,
    updatedAt,
    completedAt,
    notes,
    isTopThree,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('energy_level')) {
      context.handle(
        _energyLevelMeta,
        energyLevel.isAcceptableOrUnknown(
          data['energy_level']!,
          _energyLevelMeta,
        ),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('actual_minutes')) {
      context.handle(
        _actualMinutesMeta,
        actualMinutes.isAcceptableOrUnknown(
          data['actual_minutes']!,
          _actualMinutesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_top_three')) {
      context.handle(
        _isTopThreeMeta,
        isTopThree.isAcceptableOrUnknown(
          data['is_top_three']!,
          _isTopThreeMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      energyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}energy_level'],
      ),
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
      actualMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_minutes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isTopThree: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_top_three'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String taskId;
  final String? projectId;
  final String title;
  final String? description;
  final String? category;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final String? energyLevel;
  final int? estimatedMinutes;
  final int? actualMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? notes;
  final bool isTopThree;
  final bool isArchived;
  const Task({
    required this.taskId,
    this.projectId,
    required this.title,
    this.description,
    this.category,
    required this.priority,
    required this.status,
    this.dueDate,
    this.energyLevel,
    this.estimatedMinutes,
    this.actualMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.notes,
    required this.isTopThree,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || energyLevel != null) {
      map['energy_level'] = Variable<String>(energyLevel);
    }
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    if (!nullToAbsent || actualMinutes != null) {
      map['actual_minutes'] = Variable<int>(actualMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_top_three'] = Variable<bool>(isTopThree);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      taskId: Value(taskId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      priority: Value(priority),
      status: Value(status),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      energyLevel: energyLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(energyLevel),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      actualMinutes: actualMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(actualMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isTopThree: Value(isTopThree),
      isArchived: Value(isArchived),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      taskId: serializer.fromJson<String>(json['taskId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      energyLevel: serializer.fromJson<String?>(json['energyLevel']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      actualMinutes: serializer.fromJson<int?>(json['actualMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      isTopThree: serializer.fromJson<bool>(json['isTopThree']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'projectId': serializer.toJson<String?>(projectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String?>(category),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'energyLevel': serializer.toJson<String?>(energyLevel),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'actualMinutes': serializer.toJson<int?>(actualMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
      'isTopThree': serializer.toJson<bool>(isTopThree),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Task copyWith({
    String? taskId,
    Value<String?> projectId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? priority,
    String? status,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<String?> energyLevel = const Value.absent(),
    Value<int?> estimatedMinutes = const Value.absent(),
    Value<int?> actualMinutes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isTopThree,
    bool? isArchived,
  }) => Task(
    taskId: taskId ?? this.taskId,
    projectId: projectId.present ? projectId.value : this.projectId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    category: category.present ? category.value : this.category,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    energyLevel: energyLevel.present ? energyLevel.value : this.energyLevel,
    estimatedMinutes: estimatedMinutes.present
        ? estimatedMinutes.value
        : this.estimatedMinutes,
    actualMinutes: actualMinutes.present
        ? actualMinutes.value
        : this.actualMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes.present ? notes.value : this.notes,
    isTopThree: isTopThree ?? this.isTopThree,
    isArchived: isArchived ?? this.isArchived,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      energyLevel: data.energyLevel.present
          ? data.energyLevel.value
          : this.energyLevel,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      actualMinutes: data.actualMinutes.present
          ? data.actualMinutes.value
          : this.actualMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      isTopThree: data.isTopThree.present
          ? data.isTopThree.value
          : this.isTopThree,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('taskId: $taskId, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('isTopThree: $isTopThree, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    projectId,
    title,
    description,
    category,
    priority,
    status,
    dueDate,
    energyLevel,
    estimatedMinutes,
    actualMinutes,
    createdAt,
    updatedAt,
    completedAt,
    notes,
    isTopThree,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.taskId == this.taskId &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.dueDate == this.dueDate &&
          other.energyLevel == this.energyLevel &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.actualMinutes == this.actualMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes &&
          other.isTopThree == this.isTopThree &&
          other.isArchived == this.isArchived);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> taskId;
  final Value<String?> projectId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> category;
  final Value<String> priority;
  final Value<String> status;
  final Value<DateTime?> dueDate;
  final Value<String?> energyLevel;
  final Value<int?> estimatedMinutes;
  final Value<int?> actualMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  final Value<bool> isTopThree;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const TasksCompanion({
    this.taskId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.isTopThree = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String taskId,
    this.projectId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.isTopThree = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? taskId,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<DateTime>? dueDate,
    Expression<String>? energyLevel,
    Expression<int>? estimatedMinutes,
    Expression<int>? actualMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
    Expression<bool>? isTopThree,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (dueDate != null) 'due_date': dueDate,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (actualMinutes != null) 'actual_minutes': actualMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (isTopThree != null) 'is_top_three': isTopThree,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? taskId,
    Value<String?>? projectId,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? category,
    Value<String>? priority,
    Value<String>? status,
    Value<DateTime?>? dueDate,
    Value<String?>? energyLevel,
    Value<int?>? estimatedMinutes,
    Value<int?>? actualMinutes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? notes,
    Value<bool>? isTopThree,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      energyLevel: energyLevel ?? this.energyLevel,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      isTopThree: isTopThree ?? this.isTopThree,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<String>(energyLevel.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (actualMinutes.present) {
      map['actual_minutes'] = Variable<int>(actualMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isTopThree.present) {
      map['is_top_three'] = Variable<bool>(isTopThree.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('taskId: $taskId, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('isTopThree: $isTopThree, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyPlansTable extends DailyPlans
    with TableInfo<$DailyPlansTable, DailyPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dailyPlanIdMeta = const VerificationMeta(
    'dailyPlanId',
  );
  @override
  late final GeneratedColumn<String> dailyPlanId = GeneratedColumn<String>(
    'daily_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _mainFocusMeta = const VerificationMeta(
    'mainFocus',
  );
  @override
  late final GeneratedColumn<String> mainFocus = GeneratedColumn<String>(
    'main_focus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusReasonMeta = const VerificationMeta(
    'focusReason',
  );
  @override
  late final GeneratedColumn<String> focusReason = GeneratedColumn<String>(
    'focus_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _morningIntentionMeta = const VerificationMeta(
    'morningIntention',
  );
  @override
  late final GeneratedColumn<String> morningIntention = GeneratedColumn<String>(
    'morning_intention',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topTask1IdMeta = const VerificationMeta(
    'topTask1Id',
  );
  @override
  late final GeneratedColumn<String> topTask1Id = GeneratedColumn<String>(
    'top_task_1_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topTask2IdMeta = const VerificationMeta(
    'topTask2Id',
  );
  @override
  late final GeneratedColumn<String> topTask2Id = GeneratedColumn<String>(
    'top_task_2_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topTask3IdMeta = const VerificationMeta(
    'topTask3Id',
  );
  @override
  late final GeneratedColumn<String> topTask3Id = GeneratedColumn<String>(
    'top_task_3_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _learningFocusIdMeta = const VerificationMeta(
    'learningFocusId',
  );
  @override
  late final GeneratedColumn<String> learningFocusId = GeneratedColumn<String>(
    'learning_focus_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentFocusIdMeta = const VerificationMeta(
    'contentFocusId',
  );
  @override
  late final GeneratedColumn<String> contentFocusId = GeneratedColumn<String>(
    'content_focus_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessFocusIdMeta = const VerificationMeta(
    'businessFocusId',
  );
  @override
  late final GeneratedColumn<String> businessFocusId = GeneratedColumn<String>(
    'business_focus_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wellbeingCheckinIdMeta =
      const VerificationMeta('wellbeingCheckinId');
  @override
  late final GeneratedColumn<String> wellbeingCheckinId =
      GeneratedColumn<String>(
        'wellbeing_checkin_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _eveningReviewMeta = const VerificationMeta(
    'eveningReview',
  );
  @override
  late final GeneratedColumn<String> eveningReview = GeneratedColumn<String>(
    'evening_review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatMovedForwardMeta = const VerificationMeta(
    'whatMovedForward',
  );
  @override
  late final GeneratedColumn<String> whatMovedForward = GeneratedColumn<String>(
    'what_moved_forward',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatWasCompletedMeta = const VerificationMeta(
    'whatWasCompleted',
  );
  @override
  late final GeneratedColumn<String> whatWasCompleted = GeneratedColumn<String>(
    'what_was_completed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatWasLearnedMeta = const VerificationMeta(
    'whatWasLearned',
  );
  @override
  late final GeneratedColumn<String> whatWasLearned = GeneratedColumn<String>(
    'what_was_learned',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockersMeta = const VerificationMeta(
    'blockers',
  );
  @override
  late final GeneratedColumn<String> blockers = GeneratedColumn<String>(
    'blockers',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carryForwardNotesMeta = const VerificationMeta(
    'carryForwardNotes',
  );
  @override
  late final GeneratedColumn<String> carryForwardNotes =
      GeneratedColumn<String>(
        'carry_forward_notes',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tomorrowFocusMeta = const VerificationMeta(
    'tomorrowFocus',
  );
  @override
  late final GeneratedColumn<String> tomorrowFocus = GeneratedColumn<String>(
    'tomorrow_focus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    dailyPlanId,
    date,
    mainFocus,
    focusReason,
    morningIntention,
    topTask1Id,
    topTask2Id,
    topTask3Id,
    learningFocusId,
    contentFocusId,
    businessFocusId,
    wellbeingCheckinId,
    eveningReview,
    whatMovedForward,
    whatWasCompleted,
    whatWasLearned,
    blockers,
    carryForwardNotes,
    tomorrowFocus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('daily_plan_id')) {
      context.handle(
        _dailyPlanIdMeta,
        dailyPlanId.isAcceptableOrUnknown(
          data['daily_plan_id']!,
          _dailyPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyPlanIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('main_focus')) {
      context.handle(
        _mainFocusMeta,
        mainFocus.isAcceptableOrUnknown(data['main_focus']!, _mainFocusMeta),
      );
    }
    if (data.containsKey('focus_reason')) {
      context.handle(
        _focusReasonMeta,
        focusReason.isAcceptableOrUnknown(
          data['focus_reason']!,
          _focusReasonMeta,
        ),
      );
    }
    if (data.containsKey('morning_intention')) {
      context.handle(
        _morningIntentionMeta,
        morningIntention.isAcceptableOrUnknown(
          data['morning_intention']!,
          _morningIntentionMeta,
        ),
      );
    }
    if (data.containsKey('top_task_1_id')) {
      context.handle(
        _topTask1IdMeta,
        topTask1Id.isAcceptableOrUnknown(
          data['top_task_1_id']!,
          _topTask1IdMeta,
        ),
      );
    }
    if (data.containsKey('top_task_2_id')) {
      context.handle(
        _topTask2IdMeta,
        topTask2Id.isAcceptableOrUnknown(
          data['top_task_2_id']!,
          _topTask2IdMeta,
        ),
      );
    }
    if (data.containsKey('top_task_3_id')) {
      context.handle(
        _topTask3IdMeta,
        topTask3Id.isAcceptableOrUnknown(
          data['top_task_3_id']!,
          _topTask3IdMeta,
        ),
      );
    }
    if (data.containsKey('learning_focus_id')) {
      context.handle(
        _learningFocusIdMeta,
        learningFocusId.isAcceptableOrUnknown(
          data['learning_focus_id']!,
          _learningFocusIdMeta,
        ),
      );
    }
    if (data.containsKey('content_focus_id')) {
      context.handle(
        _contentFocusIdMeta,
        contentFocusId.isAcceptableOrUnknown(
          data['content_focus_id']!,
          _contentFocusIdMeta,
        ),
      );
    }
    if (data.containsKey('business_focus_id')) {
      context.handle(
        _businessFocusIdMeta,
        businessFocusId.isAcceptableOrUnknown(
          data['business_focus_id']!,
          _businessFocusIdMeta,
        ),
      );
    }
    if (data.containsKey('wellbeing_checkin_id')) {
      context.handle(
        _wellbeingCheckinIdMeta,
        wellbeingCheckinId.isAcceptableOrUnknown(
          data['wellbeing_checkin_id']!,
          _wellbeingCheckinIdMeta,
        ),
      );
    }
    if (data.containsKey('evening_review')) {
      context.handle(
        _eveningReviewMeta,
        eveningReview.isAcceptableOrUnknown(
          data['evening_review']!,
          _eveningReviewMeta,
        ),
      );
    }
    if (data.containsKey('what_moved_forward')) {
      context.handle(
        _whatMovedForwardMeta,
        whatMovedForward.isAcceptableOrUnknown(
          data['what_moved_forward']!,
          _whatMovedForwardMeta,
        ),
      );
    }
    if (data.containsKey('what_was_completed')) {
      context.handle(
        _whatWasCompletedMeta,
        whatWasCompleted.isAcceptableOrUnknown(
          data['what_was_completed']!,
          _whatWasCompletedMeta,
        ),
      );
    }
    if (data.containsKey('what_was_learned')) {
      context.handle(
        _whatWasLearnedMeta,
        whatWasLearned.isAcceptableOrUnknown(
          data['what_was_learned']!,
          _whatWasLearnedMeta,
        ),
      );
    }
    if (data.containsKey('blockers')) {
      context.handle(
        _blockersMeta,
        blockers.isAcceptableOrUnknown(data['blockers']!, _blockersMeta),
      );
    }
    if (data.containsKey('carry_forward_notes')) {
      context.handle(
        _carryForwardNotesMeta,
        carryForwardNotes.isAcceptableOrUnknown(
          data['carry_forward_notes']!,
          _carryForwardNotesMeta,
        ),
      );
    }
    if (data.containsKey('tomorrow_focus')) {
      context.handle(
        _tomorrowFocusMeta,
        tomorrowFocus.isAcceptableOrUnknown(
          data['tomorrow_focus']!,
          _tomorrowFocusMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dailyPlanId};
  @override
  DailyPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyPlan(
      dailyPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_plan_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      mainFocus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}main_focus'],
      ),
      focusReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus_reason'],
      ),
      morningIntention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}morning_intention'],
      ),
      topTask1Id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_task_1_id'],
      ),
      topTask2Id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_task_2_id'],
      ),
      topTask3Id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_task_3_id'],
      ),
      learningFocusId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_focus_id'],
      ),
      contentFocusId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_focus_id'],
      ),
      businessFocusId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_focus_id'],
      ),
      wellbeingCheckinId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wellbeing_checkin_id'],
      ),
      eveningReview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evening_review'],
      ),
      whatMovedForward: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_moved_forward'],
      ),
      whatWasCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_was_completed'],
      ),
      whatWasLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_was_learned'],
      ),
      blockers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blockers'],
      ),
      carryForwardNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}carry_forward_notes'],
      ),
      tomorrowFocus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tomorrow_focus'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyPlansTable createAlias(String alias) {
    return $DailyPlansTable(attachedDatabase, alias);
  }
}

class DailyPlan extends DataClass implements Insertable<DailyPlan> {
  final String dailyPlanId;
  final DateTime date;
  final String? mainFocus;
  final String? focusReason;
  final String? morningIntention;
  final String? topTask1Id;
  final String? topTask2Id;
  final String? topTask3Id;
  final String? learningFocusId;
  final String? contentFocusId;
  final String? businessFocusId;
  final String? wellbeingCheckinId;
  final String? eveningReview;
  final String? whatMovedForward;
  final String? whatWasCompleted;
  final String? whatWasLearned;
  final String? blockers;
  final String? carryForwardNotes;
  final String? tomorrowFocus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyPlan({
    required this.dailyPlanId,
    required this.date,
    this.mainFocus,
    this.focusReason,
    this.morningIntention,
    this.topTask1Id,
    this.topTask2Id,
    this.topTask3Id,
    this.learningFocusId,
    this.contentFocusId,
    this.businessFocusId,
    this.wellbeingCheckinId,
    this.eveningReview,
    this.whatMovedForward,
    this.whatWasCompleted,
    this.whatWasLearned,
    this.blockers,
    this.carryForwardNotes,
    this.tomorrowFocus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['daily_plan_id'] = Variable<String>(dailyPlanId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || mainFocus != null) {
      map['main_focus'] = Variable<String>(mainFocus);
    }
    if (!nullToAbsent || focusReason != null) {
      map['focus_reason'] = Variable<String>(focusReason);
    }
    if (!nullToAbsent || morningIntention != null) {
      map['morning_intention'] = Variable<String>(morningIntention);
    }
    if (!nullToAbsent || topTask1Id != null) {
      map['top_task_1_id'] = Variable<String>(topTask1Id);
    }
    if (!nullToAbsent || topTask2Id != null) {
      map['top_task_2_id'] = Variable<String>(topTask2Id);
    }
    if (!nullToAbsent || topTask3Id != null) {
      map['top_task_3_id'] = Variable<String>(topTask3Id);
    }
    if (!nullToAbsent || learningFocusId != null) {
      map['learning_focus_id'] = Variable<String>(learningFocusId);
    }
    if (!nullToAbsent || contentFocusId != null) {
      map['content_focus_id'] = Variable<String>(contentFocusId);
    }
    if (!nullToAbsent || businessFocusId != null) {
      map['business_focus_id'] = Variable<String>(businessFocusId);
    }
    if (!nullToAbsent || wellbeingCheckinId != null) {
      map['wellbeing_checkin_id'] = Variable<String>(wellbeingCheckinId);
    }
    if (!nullToAbsent || eveningReview != null) {
      map['evening_review'] = Variable<String>(eveningReview);
    }
    if (!nullToAbsent || whatMovedForward != null) {
      map['what_moved_forward'] = Variable<String>(whatMovedForward);
    }
    if (!nullToAbsent || whatWasCompleted != null) {
      map['what_was_completed'] = Variable<String>(whatWasCompleted);
    }
    if (!nullToAbsent || whatWasLearned != null) {
      map['what_was_learned'] = Variable<String>(whatWasLearned);
    }
    if (!nullToAbsent || blockers != null) {
      map['blockers'] = Variable<String>(blockers);
    }
    if (!nullToAbsent || carryForwardNotes != null) {
      map['carry_forward_notes'] = Variable<String>(carryForwardNotes);
    }
    if (!nullToAbsent || tomorrowFocus != null) {
      map['tomorrow_focus'] = Variable<String>(tomorrowFocus);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyPlansCompanion toCompanion(bool nullToAbsent) {
    return DailyPlansCompanion(
      dailyPlanId: Value(dailyPlanId),
      date: Value(date),
      mainFocus: mainFocus == null && nullToAbsent
          ? const Value.absent()
          : Value(mainFocus),
      focusReason: focusReason == null && nullToAbsent
          ? const Value.absent()
          : Value(focusReason),
      morningIntention: morningIntention == null && nullToAbsent
          ? const Value.absent()
          : Value(morningIntention),
      topTask1Id: topTask1Id == null && nullToAbsent
          ? const Value.absent()
          : Value(topTask1Id),
      topTask2Id: topTask2Id == null && nullToAbsent
          ? const Value.absent()
          : Value(topTask2Id),
      topTask3Id: topTask3Id == null && nullToAbsent
          ? const Value.absent()
          : Value(topTask3Id),
      learningFocusId: learningFocusId == null && nullToAbsent
          ? const Value.absent()
          : Value(learningFocusId),
      contentFocusId: contentFocusId == null && nullToAbsent
          ? const Value.absent()
          : Value(contentFocusId),
      businessFocusId: businessFocusId == null && nullToAbsent
          ? const Value.absent()
          : Value(businessFocusId),
      wellbeingCheckinId: wellbeingCheckinId == null && nullToAbsent
          ? const Value.absent()
          : Value(wellbeingCheckinId),
      eveningReview: eveningReview == null && nullToAbsent
          ? const Value.absent()
          : Value(eveningReview),
      whatMovedForward: whatMovedForward == null && nullToAbsent
          ? const Value.absent()
          : Value(whatMovedForward),
      whatWasCompleted: whatWasCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(whatWasCompleted),
      whatWasLearned: whatWasLearned == null && nullToAbsent
          ? const Value.absent()
          : Value(whatWasLearned),
      blockers: blockers == null && nullToAbsent
          ? const Value.absent()
          : Value(blockers),
      carryForwardNotes: carryForwardNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(carryForwardNotes),
      tomorrowFocus: tomorrowFocus == null && nullToAbsent
          ? const Value.absent()
          : Value(tomorrowFocus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyPlan(
      dailyPlanId: serializer.fromJson<String>(json['dailyPlanId']),
      date: serializer.fromJson<DateTime>(json['date']),
      mainFocus: serializer.fromJson<String?>(json['mainFocus']),
      focusReason: serializer.fromJson<String?>(json['focusReason']),
      morningIntention: serializer.fromJson<String?>(json['morningIntention']),
      topTask1Id: serializer.fromJson<String?>(json['topTask1Id']),
      topTask2Id: serializer.fromJson<String?>(json['topTask2Id']),
      topTask3Id: serializer.fromJson<String?>(json['topTask3Id']),
      learningFocusId: serializer.fromJson<String?>(json['learningFocusId']),
      contentFocusId: serializer.fromJson<String?>(json['contentFocusId']),
      businessFocusId: serializer.fromJson<String?>(json['businessFocusId']),
      wellbeingCheckinId: serializer.fromJson<String?>(
        json['wellbeingCheckinId'],
      ),
      eveningReview: serializer.fromJson<String?>(json['eveningReview']),
      whatMovedForward: serializer.fromJson<String?>(json['whatMovedForward']),
      whatWasCompleted: serializer.fromJson<String?>(json['whatWasCompleted']),
      whatWasLearned: serializer.fromJson<String?>(json['whatWasLearned']),
      blockers: serializer.fromJson<String?>(json['blockers']),
      carryForwardNotes: serializer.fromJson<String?>(
        json['carryForwardNotes'],
      ),
      tomorrowFocus: serializer.fromJson<String?>(json['tomorrowFocus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dailyPlanId': serializer.toJson<String>(dailyPlanId),
      'date': serializer.toJson<DateTime>(date),
      'mainFocus': serializer.toJson<String?>(mainFocus),
      'focusReason': serializer.toJson<String?>(focusReason),
      'morningIntention': serializer.toJson<String?>(morningIntention),
      'topTask1Id': serializer.toJson<String?>(topTask1Id),
      'topTask2Id': serializer.toJson<String?>(topTask2Id),
      'topTask3Id': serializer.toJson<String?>(topTask3Id),
      'learningFocusId': serializer.toJson<String?>(learningFocusId),
      'contentFocusId': serializer.toJson<String?>(contentFocusId),
      'businessFocusId': serializer.toJson<String?>(businessFocusId),
      'wellbeingCheckinId': serializer.toJson<String?>(wellbeingCheckinId),
      'eveningReview': serializer.toJson<String?>(eveningReview),
      'whatMovedForward': serializer.toJson<String?>(whatMovedForward),
      'whatWasCompleted': serializer.toJson<String?>(whatWasCompleted),
      'whatWasLearned': serializer.toJson<String?>(whatWasLearned),
      'blockers': serializer.toJson<String?>(blockers),
      'carryForwardNotes': serializer.toJson<String?>(carryForwardNotes),
      'tomorrowFocus': serializer.toJson<String?>(tomorrowFocus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyPlan copyWith({
    String? dailyPlanId,
    DateTime? date,
    Value<String?> mainFocus = const Value.absent(),
    Value<String?> focusReason = const Value.absent(),
    Value<String?> morningIntention = const Value.absent(),
    Value<String?> topTask1Id = const Value.absent(),
    Value<String?> topTask2Id = const Value.absent(),
    Value<String?> topTask3Id = const Value.absent(),
    Value<String?> learningFocusId = const Value.absent(),
    Value<String?> contentFocusId = const Value.absent(),
    Value<String?> businessFocusId = const Value.absent(),
    Value<String?> wellbeingCheckinId = const Value.absent(),
    Value<String?> eveningReview = const Value.absent(),
    Value<String?> whatMovedForward = const Value.absent(),
    Value<String?> whatWasCompleted = const Value.absent(),
    Value<String?> whatWasLearned = const Value.absent(),
    Value<String?> blockers = const Value.absent(),
    Value<String?> carryForwardNotes = const Value.absent(),
    Value<String?> tomorrowFocus = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyPlan(
    dailyPlanId: dailyPlanId ?? this.dailyPlanId,
    date: date ?? this.date,
    mainFocus: mainFocus.present ? mainFocus.value : this.mainFocus,
    focusReason: focusReason.present ? focusReason.value : this.focusReason,
    morningIntention: morningIntention.present
        ? morningIntention.value
        : this.morningIntention,
    topTask1Id: topTask1Id.present ? topTask1Id.value : this.topTask1Id,
    topTask2Id: topTask2Id.present ? topTask2Id.value : this.topTask2Id,
    topTask3Id: topTask3Id.present ? topTask3Id.value : this.topTask3Id,
    learningFocusId: learningFocusId.present
        ? learningFocusId.value
        : this.learningFocusId,
    contentFocusId: contentFocusId.present
        ? contentFocusId.value
        : this.contentFocusId,
    businessFocusId: businessFocusId.present
        ? businessFocusId.value
        : this.businessFocusId,
    wellbeingCheckinId: wellbeingCheckinId.present
        ? wellbeingCheckinId.value
        : this.wellbeingCheckinId,
    eveningReview: eveningReview.present
        ? eveningReview.value
        : this.eveningReview,
    whatMovedForward: whatMovedForward.present
        ? whatMovedForward.value
        : this.whatMovedForward,
    whatWasCompleted: whatWasCompleted.present
        ? whatWasCompleted.value
        : this.whatWasCompleted,
    whatWasLearned: whatWasLearned.present
        ? whatWasLearned.value
        : this.whatWasLearned,
    blockers: blockers.present ? blockers.value : this.blockers,
    carryForwardNotes: carryForwardNotes.present
        ? carryForwardNotes.value
        : this.carryForwardNotes,
    tomorrowFocus: tomorrowFocus.present
        ? tomorrowFocus.value
        : this.tomorrowFocus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyPlan copyWithCompanion(DailyPlansCompanion data) {
    return DailyPlan(
      dailyPlanId: data.dailyPlanId.present
          ? data.dailyPlanId.value
          : this.dailyPlanId,
      date: data.date.present ? data.date.value : this.date,
      mainFocus: data.mainFocus.present ? data.mainFocus.value : this.mainFocus,
      focusReason: data.focusReason.present
          ? data.focusReason.value
          : this.focusReason,
      morningIntention: data.morningIntention.present
          ? data.morningIntention.value
          : this.morningIntention,
      topTask1Id: data.topTask1Id.present
          ? data.topTask1Id.value
          : this.topTask1Id,
      topTask2Id: data.topTask2Id.present
          ? data.topTask2Id.value
          : this.topTask2Id,
      topTask3Id: data.topTask3Id.present
          ? data.topTask3Id.value
          : this.topTask3Id,
      learningFocusId: data.learningFocusId.present
          ? data.learningFocusId.value
          : this.learningFocusId,
      contentFocusId: data.contentFocusId.present
          ? data.contentFocusId.value
          : this.contentFocusId,
      businessFocusId: data.businessFocusId.present
          ? data.businessFocusId.value
          : this.businessFocusId,
      wellbeingCheckinId: data.wellbeingCheckinId.present
          ? data.wellbeingCheckinId.value
          : this.wellbeingCheckinId,
      eveningReview: data.eveningReview.present
          ? data.eveningReview.value
          : this.eveningReview,
      whatMovedForward: data.whatMovedForward.present
          ? data.whatMovedForward.value
          : this.whatMovedForward,
      whatWasCompleted: data.whatWasCompleted.present
          ? data.whatWasCompleted.value
          : this.whatWasCompleted,
      whatWasLearned: data.whatWasLearned.present
          ? data.whatWasLearned.value
          : this.whatWasLearned,
      blockers: data.blockers.present ? data.blockers.value : this.blockers,
      carryForwardNotes: data.carryForwardNotes.present
          ? data.carryForwardNotes.value
          : this.carryForwardNotes,
      tomorrowFocus: data.tomorrowFocus.present
          ? data.tomorrowFocus.value
          : this.tomorrowFocus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlan(')
          ..write('dailyPlanId: $dailyPlanId, ')
          ..write('date: $date, ')
          ..write('mainFocus: $mainFocus, ')
          ..write('focusReason: $focusReason, ')
          ..write('morningIntention: $morningIntention, ')
          ..write('topTask1Id: $topTask1Id, ')
          ..write('topTask2Id: $topTask2Id, ')
          ..write('topTask3Id: $topTask3Id, ')
          ..write('learningFocusId: $learningFocusId, ')
          ..write('contentFocusId: $contentFocusId, ')
          ..write('businessFocusId: $businessFocusId, ')
          ..write('wellbeingCheckinId: $wellbeingCheckinId, ')
          ..write('eveningReview: $eveningReview, ')
          ..write('whatMovedForward: $whatMovedForward, ')
          ..write('whatWasCompleted: $whatWasCompleted, ')
          ..write('whatWasLearned: $whatWasLearned, ')
          ..write('blockers: $blockers, ')
          ..write('carryForwardNotes: $carryForwardNotes, ')
          ..write('tomorrowFocus: $tomorrowFocus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    dailyPlanId,
    date,
    mainFocus,
    focusReason,
    morningIntention,
    topTask1Id,
    topTask2Id,
    topTask3Id,
    learningFocusId,
    contentFocusId,
    businessFocusId,
    wellbeingCheckinId,
    eveningReview,
    whatMovedForward,
    whatWasCompleted,
    whatWasLearned,
    blockers,
    carryForwardNotes,
    tomorrowFocus,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPlan &&
          other.dailyPlanId == this.dailyPlanId &&
          other.date == this.date &&
          other.mainFocus == this.mainFocus &&
          other.focusReason == this.focusReason &&
          other.morningIntention == this.morningIntention &&
          other.topTask1Id == this.topTask1Id &&
          other.topTask2Id == this.topTask2Id &&
          other.topTask3Id == this.topTask3Id &&
          other.learningFocusId == this.learningFocusId &&
          other.contentFocusId == this.contentFocusId &&
          other.businessFocusId == this.businessFocusId &&
          other.wellbeingCheckinId == this.wellbeingCheckinId &&
          other.eveningReview == this.eveningReview &&
          other.whatMovedForward == this.whatMovedForward &&
          other.whatWasCompleted == this.whatWasCompleted &&
          other.whatWasLearned == this.whatWasLearned &&
          other.blockers == this.blockers &&
          other.carryForwardNotes == this.carryForwardNotes &&
          other.tomorrowFocus == this.tomorrowFocus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyPlansCompanion extends UpdateCompanion<DailyPlan> {
  final Value<String> dailyPlanId;
  final Value<DateTime> date;
  final Value<String?> mainFocus;
  final Value<String?> focusReason;
  final Value<String?> morningIntention;
  final Value<String?> topTask1Id;
  final Value<String?> topTask2Id;
  final Value<String?> topTask3Id;
  final Value<String?> learningFocusId;
  final Value<String?> contentFocusId;
  final Value<String?> businessFocusId;
  final Value<String?> wellbeingCheckinId;
  final Value<String?> eveningReview;
  final Value<String?> whatMovedForward;
  final Value<String?> whatWasCompleted;
  final Value<String?> whatWasLearned;
  final Value<String?> blockers;
  final Value<String?> carryForwardNotes;
  final Value<String?> tomorrowFocus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailyPlansCompanion({
    this.dailyPlanId = const Value.absent(),
    this.date = const Value.absent(),
    this.mainFocus = const Value.absent(),
    this.focusReason = const Value.absent(),
    this.morningIntention = const Value.absent(),
    this.topTask1Id = const Value.absent(),
    this.topTask2Id = const Value.absent(),
    this.topTask3Id = const Value.absent(),
    this.learningFocusId = const Value.absent(),
    this.contentFocusId = const Value.absent(),
    this.businessFocusId = const Value.absent(),
    this.wellbeingCheckinId = const Value.absent(),
    this.eveningReview = const Value.absent(),
    this.whatMovedForward = const Value.absent(),
    this.whatWasCompleted = const Value.absent(),
    this.whatWasLearned = const Value.absent(),
    this.blockers = const Value.absent(),
    this.carryForwardNotes = const Value.absent(),
    this.tomorrowFocus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyPlansCompanion.insert({
    required String dailyPlanId,
    required DateTime date,
    this.mainFocus = const Value.absent(),
    this.focusReason = const Value.absent(),
    this.morningIntention = const Value.absent(),
    this.topTask1Id = const Value.absent(),
    this.topTask2Id = const Value.absent(),
    this.topTask3Id = const Value.absent(),
    this.learningFocusId = const Value.absent(),
    this.contentFocusId = const Value.absent(),
    this.businessFocusId = const Value.absent(),
    this.wellbeingCheckinId = const Value.absent(),
    this.eveningReview = const Value.absent(),
    this.whatMovedForward = const Value.absent(),
    this.whatWasCompleted = const Value.absent(),
    this.whatWasLearned = const Value.absent(),
    this.blockers = const Value.absent(),
    this.carryForwardNotes = const Value.absent(),
    this.tomorrowFocus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : dailyPlanId = Value(dailyPlanId),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DailyPlan> custom({
    Expression<String>? dailyPlanId,
    Expression<DateTime>? date,
    Expression<String>? mainFocus,
    Expression<String>? focusReason,
    Expression<String>? morningIntention,
    Expression<String>? topTask1Id,
    Expression<String>? topTask2Id,
    Expression<String>? topTask3Id,
    Expression<String>? learningFocusId,
    Expression<String>? contentFocusId,
    Expression<String>? businessFocusId,
    Expression<String>? wellbeingCheckinId,
    Expression<String>? eveningReview,
    Expression<String>? whatMovedForward,
    Expression<String>? whatWasCompleted,
    Expression<String>? whatWasLearned,
    Expression<String>? blockers,
    Expression<String>? carryForwardNotes,
    Expression<String>? tomorrowFocus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dailyPlanId != null) 'daily_plan_id': dailyPlanId,
      if (date != null) 'date': date,
      if (mainFocus != null) 'main_focus': mainFocus,
      if (focusReason != null) 'focus_reason': focusReason,
      if (morningIntention != null) 'morning_intention': morningIntention,
      if (topTask1Id != null) 'top_task_1_id': topTask1Id,
      if (topTask2Id != null) 'top_task_2_id': topTask2Id,
      if (topTask3Id != null) 'top_task_3_id': topTask3Id,
      if (learningFocusId != null) 'learning_focus_id': learningFocusId,
      if (contentFocusId != null) 'content_focus_id': contentFocusId,
      if (businessFocusId != null) 'business_focus_id': businessFocusId,
      if (wellbeingCheckinId != null)
        'wellbeing_checkin_id': wellbeingCheckinId,
      if (eveningReview != null) 'evening_review': eveningReview,
      if (whatMovedForward != null) 'what_moved_forward': whatMovedForward,
      if (whatWasCompleted != null) 'what_was_completed': whatWasCompleted,
      if (whatWasLearned != null) 'what_was_learned': whatWasLearned,
      if (blockers != null) 'blockers': blockers,
      if (carryForwardNotes != null) 'carry_forward_notes': carryForwardNotes,
      if (tomorrowFocus != null) 'tomorrow_focus': tomorrowFocus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyPlansCompanion copyWith({
    Value<String>? dailyPlanId,
    Value<DateTime>? date,
    Value<String?>? mainFocus,
    Value<String?>? focusReason,
    Value<String?>? morningIntention,
    Value<String?>? topTask1Id,
    Value<String?>? topTask2Id,
    Value<String?>? topTask3Id,
    Value<String?>? learningFocusId,
    Value<String?>? contentFocusId,
    Value<String?>? businessFocusId,
    Value<String?>? wellbeingCheckinId,
    Value<String?>? eveningReview,
    Value<String?>? whatMovedForward,
    Value<String?>? whatWasCompleted,
    Value<String?>? whatWasLearned,
    Value<String?>? blockers,
    Value<String?>? carryForwardNotes,
    Value<String?>? tomorrowFocus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailyPlansCompanion(
      dailyPlanId: dailyPlanId ?? this.dailyPlanId,
      date: date ?? this.date,
      mainFocus: mainFocus ?? this.mainFocus,
      focusReason: focusReason ?? this.focusReason,
      morningIntention: morningIntention ?? this.morningIntention,
      topTask1Id: topTask1Id ?? this.topTask1Id,
      topTask2Id: topTask2Id ?? this.topTask2Id,
      topTask3Id: topTask3Id ?? this.topTask3Id,
      learningFocusId: learningFocusId ?? this.learningFocusId,
      contentFocusId: contentFocusId ?? this.contentFocusId,
      businessFocusId: businessFocusId ?? this.businessFocusId,
      wellbeingCheckinId: wellbeingCheckinId ?? this.wellbeingCheckinId,
      eveningReview: eveningReview ?? this.eveningReview,
      whatMovedForward: whatMovedForward ?? this.whatMovedForward,
      whatWasCompleted: whatWasCompleted ?? this.whatWasCompleted,
      whatWasLearned: whatWasLearned ?? this.whatWasLearned,
      blockers: blockers ?? this.blockers,
      carryForwardNotes: carryForwardNotes ?? this.carryForwardNotes,
      tomorrowFocus: tomorrowFocus ?? this.tomorrowFocus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dailyPlanId.present) {
      map['daily_plan_id'] = Variable<String>(dailyPlanId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mainFocus.present) {
      map['main_focus'] = Variable<String>(mainFocus.value);
    }
    if (focusReason.present) {
      map['focus_reason'] = Variable<String>(focusReason.value);
    }
    if (morningIntention.present) {
      map['morning_intention'] = Variable<String>(morningIntention.value);
    }
    if (topTask1Id.present) {
      map['top_task_1_id'] = Variable<String>(topTask1Id.value);
    }
    if (topTask2Id.present) {
      map['top_task_2_id'] = Variable<String>(topTask2Id.value);
    }
    if (topTask3Id.present) {
      map['top_task_3_id'] = Variable<String>(topTask3Id.value);
    }
    if (learningFocusId.present) {
      map['learning_focus_id'] = Variable<String>(learningFocusId.value);
    }
    if (contentFocusId.present) {
      map['content_focus_id'] = Variable<String>(contentFocusId.value);
    }
    if (businessFocusId.present) {
      map['business_focus_id'] = Variable<String>(businessFocusId.value);
    }
    if (wellbeingCheckinId.present) {
      map['wellbeing_checkin_id'] = Variable<String>(wellbeingCheckinId.value);
    }
    if (eveningReview.present) {
      map['evening_review'] = Variable<String>(eveningReview.value);
    }
    if (whatMovedForward.present) {
      map['what_moved_forward'] = Variable<String>(whatMovedForward.value);
    }
    if (whatWasCompleted.present) {
      map['what_was_completed'] = Variable<String>(whatWasCompleted.value);
    }
    if (whatWasLearned.present) {
      map['what_was_learned'] = Variable<String>(whatWasLearned.value);
    }
    if (blockers.present) {
      map['blockers'] = Variable<String>(blockers.value);
    }
    if (carryForwardNotes.present) {
      map['carry_forward_notes'] = Variable<String>(carryForwardNotes.value);
    }
    if (tomorrowFocus.present) {
      map['tomorrow_focus'] = Variable<String>(tomorrowFocus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlansCompanion(')
          ..write('dailyPlanId: $dailyPlanId, ')
          ..write('date: $date, ')
          ..write('mainFocus: $mainFocus, ')
          ..write('focusReason: $focusReason, ')
          ..write('morningIntention: $morningIntention, ')
          ..write('topTask1Id: $topTask1Id, ')
          ..write('topTask2Id: $topTask2Id, ')
          ..write('topTask3Id: $topTask3Id, ')
          ..write('learningFocusId: $learningFocusId, ')
          ..write('contentFocusId: $contentFocusId, ')
          ..write('businessFocusId: $businessFocusId, ')
          ..write('wellbeingCheckinId: $wellbeingCheckinId, ')
          ..write('eveningReview: $eveningReview, ')
          ..write('whatMovedForward: $whatMovedForward, ')
          ..write('whatWasCompleted: $whatWasCompleted, ')
          ..write('whatWasLearned: $whatWasLearned, ')
          ..write('blockers: $blockers, ')
          ..write('carryForwardNotes: $carryForwardNotes, ')
          ..write('tomorrowFocus: $tomorrowFocus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatIWorkedOnMeta = const VerificationMeta(
    'whatIWorkedOn',
  );
  @override
  late final GeneratedColumn<String> whatIWorkedOn = GeneratedColumn<String>(
    'what_i_worked_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatIBuiltMeta = const VerificationMeta(
    'whatIBuilt',
  );
  @override
  late final GeneratedColumn<String> whatIBuilt = GeneratedColumn<String>(
    'what_i_built',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatILearnedMeta = const VerificationMeta(
    'whatILearned',
  );
  @override
  late final GeneratedColumn<String> whatILearned = GeneratedColumn<String>(
    'what_i_learned',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _problemsEncounteredMeta =
      const VerificationMeta('problemsEncountered');
  @override
  late final GeneratedColumn<String> problemsEncountered =
      GeneratedColumn<String>(
        'problems_encountered',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _decisionsMadeMeta = const VerificationMeta(
    'decisionsMade',
  );
  @override
  late final GeneratedColumn<String> decisionsMade = GeneratedColumn<String>(
    'decisions_made',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionsMeta = const VerificationMeta(
    'nextActions',
  );
  @override
  late final GeneratedColumn<String> nextActions = GeneratedColumn<String>(
    'next_actions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _possibleLinkedinPostMeta =
      const VerificationMeta('possibleLinkedinPost');
  @override
  late final GeneratedColumn<bool> possibleLinkedinPost = GeneratedColumn<bool>(
    'possible_linkedin_post',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("possible_linkedin_post" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _possibleWebsiteEntryMeta =
      const VerificationMeta('possibleWebsiteEntry');
  @override
  late final GeneratedColumn<bool> possibleWebsiteEntry = GeneratedColumn<bool>(
    'possible_website_entry',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("possible_website_entry" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    journalEntryId,
    projectId,
    taskId,
    date,
    title,
    category,
    whatIWorkedOn,
    whatIBuilt,
    whatILearned,
    problemsEncountered,
    decisionsMade,
    nextActions,
    possibleLinkedinPost,
    possibleWebsiteEntry,
    tags,
    createdAt,
    updatedAt,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalEntryIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('what_i_worked_on')) {
      context.handle(
        _whatIWorkedOnMeta,
        whatIWorkedOn.isAcceptableOrUnknown(
          data['what_i_worked_on']!,
          _whatIWorkedOnMeta,
        ),
      );
    }
    if (data.containsKey('what_i_built')) {
      context.handle(
        _whatIBuiltMeta,
        whatIBuilt.isAcceptableOrUnknown(
          data['what_i_built']!,
          _whatIBuiltMeta,
        ),
      );
    }
    if (data.containsKey('what_i_learned')) {
      context.handle(
        _whatILearnedMeta,
        whatILearned.isAcceptableOrUnknown(
          data['what_i_learned']!,
          _whatILearnedMeta,
        ),
      );
    }
    if (data.containsKey('problems_encountered')) {
      context.handle(
        _problemsEncounteredMeta,
        problemsEncountered.isAcceptableOrUnknown(
          data['problems_encountered']!,
          _problemsEncounteredMeta,
        ),
      );
    }
    if (data.containsKey('decisions_made')) {
      context.handle(
        _decisionsMadeMeta,
        decisionsMade.isAcceptableOrUnknown(
          data['decisions_made']!,
          _decisionsMadeMeta,
        ),
      );
    }
    if (data.containsKey('next_actions')) {
      context.handle(
        _nextActionsMeta,
        nextActions.isAcceptableOrUnknown(
          data['next_actions']!,
          _nextActionsMeta,
        ),
      );
    }
    if (data.containsKey('possible_linkedin_post')) {
      context.handle(
        _possibleLinkedinPostMeta,
        possibleLinkedinPost.isAcceptableOrUnknown(
          data['possible_linkedin_post']!,
          _possibleLinkedinPostMeta,
        ),
      );
    }
    if (data.containsKey('possible_website_entry')) {
      context.handle(
        _possibleWebsiteEntryMeta,
        possibleWebsiteEntry.isAcceptableOrUnknown(
          data['possible_website_entry']!,
          _possibleWebsiteEntryMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {journalEntryId};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      whatIWorkedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_i_worked_on'],
      ),
      whatIBuilt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_i_built'],
      ),
      whatILearned: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_i_learned'],
      ),
      problemsEncountered: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problems_encountered'],
      ),
      decisionsMade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decisions_made'],
      ),
      nextActions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_actions'],
      ),
      possibleLinkedinPost: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}possible_linkedin_post'],
      )!,
      possibleWebsiteEntry: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}possible_website_entry'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final String journalEntryId;
  final String? projectId;
  final String? taskId;
  final DateTime date;
  final String title;
  final String? category;
  final String? whatIWorkedOn;
  final String? whatIBuilt;
  final String? whatILearned;
  final String? problemsEncountered;
  final String? decisionsMade;
  final String? nextActions;
  final bool possibleLinkedinPost;
  final bool possibleWebsiteEntry;
  final String? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  const JournalEntry({
    required this.journalEntryId,
    this.projectId,
    this.taskId,
    required this.date,
    required this.title,
    this.category,
    this.whatIWorkedOn,
    this.whatIBuilt,
    this.whatILearned,
    this.problemsEncountered,
    this.decisionsMade,
    this.nextActions,
    required this.possibleLinkedinPost,
    required this.possibleWebsiteEntry,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['journal_entry_id'] = Variable<String>(journalEntryId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['date'] = Variable<DateTime>(date);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || whatIWorkedOn != null) {
      map['what_i_worked_on'] = Variable<String>(whatIWorkedOn);
    }
    if (!nullToAbsent || whatIBuilt != null) {
      map['what_i_built'] = Variable<String>(whatIBuilt);
    }
    if (!nullToAbsent || whatILearned != null) {
      map['what_i_learned'] = Variable<String>(whatILearned);
    }
    if (!nullToAbsent || problemsEncountered != null) {
      map['problems_encountered'] = Variable<String>(problemsEncountered);
    }
    if (!nullToAbsent || decisionsMade != null) {
      map['decisions_made'] = Variable<String>(decisionsMade);
    }
    if (!nullToAbsent || nextActions != null) {
      map['next_actions'] = Variable<String>(nextActions);
    }
    map['possible_linkedin_post'] = Variable<bool>(possibleLinkedinPost);
    map['possible_website_entry'] = Variable<bool>(possibleWebsiteEntry);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      journalEntryId: Value(journalEntryId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      date: Value(date),
      title: Value(title),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      whatIWorkedOn: whatIWorkedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(whatIWorkedOn),
      whatIBuilt: whatIBuilt == null && nullToAbsent
          ? const Value.absent()
          : Value(whatIBuilt),
      whatILearned: whatILearned == null && nullToAbsent
          ? const Value.absent()
          : Value(whatILearned),
      problemsEncountered: problemsEncountered == null && nullToAbsent
          ? const Value.absent()
          : Value(problemsEncountered),
      decisionsMade: decisionsMade == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionsMade),
      nextActions: nextActions == null && nullToAbsent
          ? const Value.absent()
          : Value(nextActions),
      possibleLinkedinPost: Value(possibleLinkedinPost),
      possibleWebsiteEntry: Value(possibleWebsiteEntry),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isArchived: Value(isArchived),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      journalEntryId: serializer.fromJson<String>(json['journalEntryId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      date: serializer.fromJson<DateTime>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String?>(json['category']),
      whatIWorkedOn: serializer.fromJson<String?>(json['whatIWorkedOn']),
      whatIBuilt: serializer.fromJson<String?>(json['whatIBuilt']),
      whatILearned: serializer.fromJson<String?>(json['whatILearned']),
      problemsEncountered: serializer.fromJson<String?>(
        json['problemsEncountered'],
      ),
      decisionsMade: serializer.fromJson<String?>(json['decisionsMade']),
      nextActions: serializer.fromJson<String?>(json['nextActions']),
      possibleLinkedinPost: serializer.fromJson<bool>(
        json['possibleLinkedinPost'],
      ),
      possibleWebsiteEntry: serializer.fromJson<bool>(
        json['possibleWebsiteEntry'],
      ),
      tags: serializer.fromJson<String?>(json['tags']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'journalEntryId': serializer.toJson<String>(journalEntryId),
      'projectId': serializer.toJson<String?>(projectId),
      'taskId': serializer.toJson<String?>(taskId),
      'date': serializer.toJson<DateTime>(date),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String?>(category),
      'whatIWorkedOn': serializer.toJson<String?>(whatIWorkedOn),
      'whatIBuilt': serializer.toJson<String?>(whatIBuilt),
      'whatILearned': serializer.toJson<String?>(whatILearned),
      'problemsEncountered': serializer.toJson<String?>(problemsEncountered),
      'decisionsMade': serializer.toJson<String?>(decisionsMade),
      'nextActions': serializer.toJson<String?>(nextActions),
      'possibleLinkedinPost': serializer.toJson<bool>(possibleLinkedinPost),
      'possibleWebsiteEntry': serializer.toJson<bool>(possibleWebsiteEntry),
      'tags': serializer.toJson<String?>(tags),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  JournalEntry copyWith({
    String? journalEntryId,
    Value<String?> projectId = const Value.absent(),
    Value<String?> taskId = const Value.absent(),
    DateTime? date,
    String? title,
    Value<String?> category = const Value.absent(),
    Value<String?> whatIWorkedOn = const Value.absent(),
    Value<String?> whatIBuilt = const Value.absent(),
    Value<String?> whatILearned = const Value.absent(),
    Value<String?> problemsEncountered = const Value.absent(),
    Value<String?> decisionsMade = const Value.absent(),
    Value<String?> nextActions = const Value.absent(),
    bool? possibleLinkedinPost,
    bool? possibleWebsiteEntry,
    Value<String?> tags = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) => JournalEntry(
    journalEntryId: journalEntryId ?? this.journalEntryId,
    projectId: projectId.present ? projectId.value : this.projectId,
    taskId: taskId.present ? taskId.value : this.taskId,
    date: date ?? this.date,
    title: title ?? this.title,
    category: category.present ? category.value : this.category,
    whatIWorkedOn: whatIWorkedOn.present
        ? whatIWorkedOn.value
        : this.whatIWorkedOn,
    whatIBuilt: whatIBuilt.present ? whatIBuilt.value : this.whatIBuilt,
    whatILearned: whatILearned.present ? whatILearned.value : this.whatILearned,
    problemsEncountered: problemsEncountered.present
        ? problemsEncountered.value
        : this.problemsEncountered,
    decisionsMade: decisionsMade.present
        ? decisionsMade.value
        : this.decisionsMade,
    nextActions: nextActions.present ? nextActions.value : this.nextActions,
    possibleLinkedinPost: possibleLinkedinPost ?? this.possibleLinkedinPost,
    possibleWebsiteEntry: possibleWebsiteEntry ?? this.possibleWebsiteEntry,
    tags: tags.present ? tags.value : this.tags,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isArchived: isArchived ?? this.isArchived,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      whatIWorkedOn: data.whatIWorkedOn.present
          ? data.whatIWorkedOn.value
          : this.whatIWorkedOn,
      whatIBuilt: data.whatIBuilt.present
          ? data.whatIBuilt.value
          : this.whatIBuilt,
      whatILearned: data.whatILearned.present
          ? data.whatILearned.value
          : this.whatILearned,
      problemsEncountered: data.problemsEncountered.present
          ? data.problemsEncountered.value
          : this.problemsEncountered,
      decisionsMade: data.decisionsMade.present
          ? data.decisionsMade.value
          : this.decisionsMade,
      nextActions: data.nextActions.present
          ? data.nextActions.value
          : this.nextActions,
      possibleLinkedinPost: data.possibleLinkedinPost.present
          ? data.possibleLinkedinPost.value
          : this.possibleLinkedinPost,
      possibleWebsiteEntry: data.possibleWebsiteEntry.present
          ? data.possibleWebsiteEntry.value
          : this.possibleWebsiteEntry,
      tags: data.tags.present ? data.tags.value : this.tags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('projectId: $projectId, ')
          ..write('taskId: $taskId, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('whatIWorkedOn: $whatIWorkedOn, ')
          ..write('whatIBuilt: $whatIBuilt, ')
          ..write('whatILearned: $whatILearned, ')
          ..write('problemsEncountered: $problemsEncountered, ')
          ..write('decisionsMade: $decisionsMade, ')
          ..write('nextActions: $nextActions, ')
          ..write('possibleLinkedinPost: $possibleLinkedinPost, ')
          ..write('possibleWebsiteEntry: $possibleWebsiteEntry, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    journalEntryId,
    projectId,
    taskId,
    date,
    title,
    category,
    whatIWorkedOn,
    whatIBuilt,
    whatILearned,
    problemsEncountered,
    decisionsMade,
    nextActions,
    possibleLinkedinPost,
    possibleWebsiteEntry,
    tags,
    createdAt,
    updatedAt,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.journalEntryId == this.journalEntryId &&
          other.projectId == this.projectId &&
          other.taskId == this.taskId &&
          other.date == this.date &&
          other.title == this.title &&
          other.category == this.category &&
          other.whatIWorkedOn == this.whatIWorkedOn &&
          other.whatIBuilt == this.whatIBuilt &&
          other.whatILearned == this.whatILearned &&
          other.problemsEncountered == this.problemsEncountered &&
          other.decisionsMade == this.decisionsMade &&
          other.nextActions == this.nextActions &&
          other.possibleLinkedinPost == this.possibleLinkedinPost &&
          other.possibleWebsiteEntry == this.possibleWebsiteEntry &&
          other.tags == this.tags &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isArchived == this.isArchived);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> journalEntryId;
  final Value<String?> projectId;
  final Value<String?> taskId;
  final Value<DateTime> date;
  final Value<String> title;
  final Value<String?> category;
  final Value<String?> whatIWorkedOn;
  final Value<String?> whatIBuilt;
  final Value<String?> whatILearned;
  final Value<String?> problemsEncountered;
  final Value<String?> decisionsMade;
  final Value<String?> nextActions;
  final Value<bool> possibleLinkedinPost;
  final Value<bool> possibleWebsiteEntry;
  final Value<String?> tags;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.journalEntryId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.whatIWorkedOn = const Value.absent(),
    this.whatIBuilt = const Value.absent(),
    this.whatILearned = const Value.absent(),
    this.problemsEncountered = const Value.absent(),
    this.decisionsMade = const Value.absent(),
    this.nextActions = const Value.absent(),
    this.possibleLinkedinPost = const Value.absent(),
    this.possibleWebsiteEntry = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String journalEntryId,
    this.projectId = const Value.absent(),
    this.taskId = const Value.absent(),
    required DateTime date,
    required String title,
    this.category = const Value.absent(),
    this.whatIWorkedOn = const Value.absent(),
    this.whatIBuilt = const Value.absent(),
    this.whatILearned = const Value.absent(),
    this.problemsEncountered = const Value.absent(),
    this.decisionsMade = const Value.absent(),
    this.nextActions = const Value.absent(),
    this.possibleLinkedinPost = const Value.absent(),
    this.possibleWebsiteEntry = const Value.absent(),
    this.tags = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : journalEntryId = Value(journalEntryId),
       date = Value(date),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JournalEntry> custom({
    Expression<String>? journalEntryId,
    Expression<String>? projectId,
    Expression<String>? taskId,
    Expression<DateTime>? date,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? whatIWorkedOn,
    Expression<String>? whatIBuilt,
    Expression<String>? whatILearned,
    Expression<String>? problemsEncountered,
    Expression<String>? decisionsMade,
    Expression<String>? nextActions,
    Expression<bool>? possibleLinkedinPost,
    Expression<bool>? possibleWebsiteEntry,
    Expression<String>? tags,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (projectId != null) 'project_id': projectId,
      if (taskId != null) 'task_id': taskId,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (whatIWorkedOn != null) 'what_i_worked_on': whatIWorkedOn,
      if (whatIBuilt != null) 'what_i_built': whatIBuilt,
      if (whatILearned != null) 'what_i_learned': whatILearned,
      if (problemsEncountered != null)
        'problems_encountered': problemsEncountered,
      if (decisionsMade != null) 'decisions_made': decisionsMade,
      if (nextActions != null) 'next_actions': nextActions,
      if (possibleLinkedinPost != null)
        'possible_linkedin_post': possibleLinkedinPost,
      if (possibleWebsiteEntry != null)
        'possible_website_entry': possibleWebsiteEntry,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? journalEntryId,
    Value<String?>? projectId,
    Value<String?>? taskId,
    Value<DateTime>? date,
    Value<String>? title,
    Value<String?>? category,
    Value<String?>? whatIWorkedOn,
    Value<String?>? whatIBuilt,
    Value<String?>? whatILearned,
    Value<String?>? problemsEncountered,
    Value<String?>? decisionsMade,
    Value<String?>? nextActions,
    Value<bool>? possibleLinkedinPost,
    Value<bool>? possibleWebsiteEntry,
    Value<String?>? tags,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      journalEntryId: journalEntryId ?? this.journalEntryId,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
      title: title ?? this.title,
      category: category ?? this.category,
      whatIWorkedOn: whatIWorkedOn ?? this.whatIWorkedOn,
      whatIBuilt: whatIBuilt ?? this.whatIBuilt,
      whatILearned: whatILearned ?? this.whatILearned,
      problemsEncountered: problemsEncountered ?? this.problemsEncountered,
      decisionsMade: decisionsMade ?? this.decisionsMade,
      nextActions: nextActions ?? this.nextActions,
      possibleLinkedinPost: possibleLinkedinPost ?? this.possibleLinkedinPost,
      possibleWebsiteEntry: possibleWebsiteEntry ?? this.possibleWebsiteEntry,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (whatIWorkedOn.present) {
      map['what_i_worked_on'] = Variable<String>(whatIWorkedOn.value);
    }
    if (whatIBuilt.present) {
      map['what_i_built'] = Variable<String>(whatIBuilt.value);
    }
    if (whatILearned.present) {
      map['what_i_learned'] = Variable<String>(whatILearned.value);
    }
    if (problemsEncountered.present) {
      map['problems_encountered'] = Variable<String>(problemsEncountered.value);
    }
    if (decisionsMade.present) {
      map['decisions_made'] = Variable<String>(decisionsMade.value);
    }
    if (nextActions.present) {
      map['next_actions'] = Variable<String>(nextActions.value);
    }
    if (possibleLinkedinPost.present) {
      map['possible_linkedin_post'] = Variable<bool>(
        possibleLinkedinPost.value,
      );
    }
    if (possibleWebsiteEntry.present) {
      map['possible_website_entry'] = Variable<bool>(
        possibleWebsiteEntry.value,
      );
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('projectId: $projectId, ')
          ..write('taskId: $taskId, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('whatIWorkedOn: $whatIWorkedOn, ')
          ..write('whatIBuilt: $whatIBuilt, ')
          ..write('whatILearned: $whatILearned, ')
          ..write('problemsEncountered: $problemsEncountered, ')
          ..write('decisionsMade: $decisionsMade, ')
          ..write('nextActions: $nextActions, ')
          ..write('possibleLinkedinPost: $possibleLinkedinPost, ')
          ..write('possibleWebsiteEntry: $possibleWebsiteEntry, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningItemsTable extends LearningItems
    with TableInfo<$LearningItemsTable, LearningItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _learningItemIdMeta = const VerificationMeta(
    'learningItemId',
  );
  @override
  late final GeneratedColumn<String> learningItemId = GeneratedColumn<String>(
    'learning_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonForLearningMeta = const VerificationMeta(
    'reasonForLearning',
  );
  @override
  late final GeneratedColumn<String> reasonForLearning =
      GeneratedColumn<String>(
        'reason_for_learning',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _resourceLinkMeta = const VerificationMeta(
    'resourceLink',
  );
  @override
  late final GeneratedColumn<String> resourceLink = GeneratedColumn<String>(
    'resource_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('To Learn'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _practiceTaskIdMeta = const VerificationMeta(
    'practiceTaskId',
  );
  @override
  late final GeneratedColumn<String> practiceTaskId = GeneratedColumn<String>(
    'practice_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextStepMeta = const VerificationMeta(
    'nextStep',
  );
  @override
  late final GeneratedColumn<String> nextStep = GeneratedColumn<String>(
    'next_step',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skillConfidenceMeta = const VerificationMeta(
    'skillConfidence',
  );
  @override
  late final GeneratedColumn<String> skillConfidence = GeneratedColumn<String>(
    'skill_confidence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateStartedMeta = const VerificationMeta(
    'dateStarted',
  );
  @override
  late final GeneratedColumn<DateTime> dateStarted = GeneratedColumn<DateTime>(
    'date_started',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateAppliedMeta = const VerificationMeta(
    'dateApplied',
  );
  @override
  late final GeneratedColumn<DateTime> dateApplied = GeneratedColumn<DateTime>(
    'date_applied',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    learningItemId,
    projectId,
    topic,
    reasonForLearning,
    resourceLink,
    status,
    notes,
    practiceTaskId,
    nextStep,
    skillConfidence,
    dateStarted,
    dateApplied,
    createdAt,
    updatedAt,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearningItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('learning_item_id')) {
      context.handle(
        _learningItemIdMeta,
        learningItemId.isAcceptableOrUnknown(
          data['learning_item_id']!,
          _learningItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningItemIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('reason_for_learning')) {
      context.handle(
        _reasonForLearningMeta,
        reasonForLearning.isAcceptableOrUnknown(
          data['reason_for_learning']!,
          _reasonForLearningMeta,
        ),
      );
    }
    if (data.containsKey('resource_link')) {
      context.handle(
        _resourceLinkMeta,
        resourceLink.isAcceptableOrUnknown(
          data['resource_link']!,
          _resourceLinkMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('practice_task_id')) {
      context.handle(
        _practiceTaskIdMeta,
        practiceTaskId.isAcceptableOrUnknown(
          data['practice_task_id']!,
          _practiceTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('next_step')) {
      context.handle(
        _nextStepMeta,
        nextStep.isAcceptableOrUnknown(data['next_step']!, _nextStepMeta),
      );
    }
    if (data.containsKey('skill_confidence')) {
      context.handle(
        _skillConfidenceMeta,
        skillConfidence.isAcceptableOrUnknown(
          data['skill_confidence']!,
          _skillConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('date_started')) {
      context.handle(
        _dateStartedMeta,
        dateStarted.isAcceptableOrUnknown(
          data['date_started']!,
          _dateStartedMeta,
        ),
      );
    }
    if (data.containsKey('date_applied')) {
      context.handle(
        _dateAppliedMeta,
        dateApplied.isAcceptableOrUnknown(
          data['date_applied']!,
          _dateAppliedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {learningItemId};
  @override
  LearningItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningItem(
      learningItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_item_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      reasonForLearning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_for_learning'],
      ),
      resourceLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_link'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      practiceTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}practice_task_id'],
      ),
      nextStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_step'],
      ),
      skillConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill_confidence'],
      ),
      dateStarted: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_started'],
      ),
      dateApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_applied'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $LearningItemsTable createAlias(String alias) {
    return $LearningItemsTable(attachedDatabase, alias);
  }
}

class LearningItem extends DataClass implements Insertable<LearningItem> {
  final String learningItemId;
  final String? projectId;
  final String topic;
  final String? reasonForLearning;
  final String? resourceLink;
  final String status;
  final String? notes;
  final String? practiceTaskId;
  final String? nextStep;
  final String? skillConfidence;
  final DateTime? dateStarted;
  final DateTime? dateApplied;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  const LearningItem({
    required this.learningItemId,
    this.projectId,
    required this.topic,
    this.reasonForLearning,
    this.resourceLink,
    required this.status,
    this.notes,
    this.practiceTaskId,
    this.nextStep,
    this.skillConfidence,
    this.dateStarted,
    this.dateApplied,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['learning_item_id'] = Variable<String>(learningItemId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['topic'] = Variable<String>(topic);
    if (!nullToAbsent || reasonForLearning != null) {
      map['reason_for_learning'] = Variable<String>(reasonForLearning);
    }
    if (!nullToAbsent || resourceLink != null) {
      map['resource_link'] = Variable<String>(resourceLink);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || practiceTaskId != null) {
      map['practice_task_id'] = Variable<String>(practiceTaskId);
    }
    if (!nullToAbsent || nextStep != null) {
      map['next_step'] = Variable<String>(nextStep);
    }
    if (!nullToAbsent || skillConfidence != null) {
      map['skill_confidence'] = Variable<String>(skillConfidence);
    }
    if (!nullToAbsent || dateStarted != null) {
      map['date_started'] = Variable<DateTime>(dateStarted);
    }
    if (!nullToAbsent || dateApplied != null) {
      map['date_applied'] = Variable<DateTime>(dateApplied);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  LearningItemsCompanion toCompanion(bool nullToAbsent) {
    return LearningItemsCompanion(
      learningItemId: Value(learningItemId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      topic: Value(topic),
      reasonForLearning: reasonForLearning == null && nullToAbsent
          ? const Value.absent()
          : Value(reasonForLearning),
      resourceLink: resourceLink == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceLink),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      practiceTaskId: practiceTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(practiceTaskId),
      nextStep: nextStep == null && nullToAbsent
          ? const Value.absent()
          : Value(nextStep),
      skillConfidence: skillConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(skillConfidence),
      dateStarted: dateStarted == null && nullToAbsent
          ? const Value.absent()
          : Value(dateStarted),
      dateApplied: dateApplied == null && nullToAbsent
          ? const Value.absent()
          : Value(dateApplied),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isArchived: Value(isArchived),
    );
  }

  factory LearningItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningItem(
      learningItemId: serializer.fromJson<String>(json['learningItemId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      topic: serializer.fromJson<String>(json['topic']),
      reasonForLearning: serializer.fromJson<String?>(
        json['reasonForLearning'],
      ),
      resourceLink: serializer.fromJson<String?>(json['resourceLink']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      practiceTaskId: serializer.fromJson<String?>(json['practiceTaskId']),
      nextStep: serializer.fromJson<String?>(json['nextStep']),
      skillConfidence: serializer.fromJson<String?>(json['skillConfidence']),
      dateStarted: serializer.fromJson<DateTime?>(json['dateStarted']),
      dateApplied: serializer.fromJson<DateTime?>(json['dateApplied']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'learningItemId': serializer.toJson<String>(learningItemId),
      'projectId': serializer.toJson<String?>(projectId),
      'topic': serializer.toJson<String>(topic),
      'reasonForLearning': serializer.toJson<String?>(reasonForLearning),
      'resourceLink': serializer.toJson<String?>(resourceLink),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'practiceTaskId': serializer.toJson<String?>(practiceTaskId),
      'nextStep': serializer.toJson<String?>(nextStep),
      'skillConfidence': serializer.toJson<String?>(skillConfidence),
      'dateStarted': serializer.toJson<DateTime?>(dateStarted),
      'dateApplied': serializer.toJson<DateTime?>(dateApplied),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  LearningItem copyWith({
    String? learningItemId,
    Value<String?> projectId = const Value.absent(),
    String? topic,
    Value<String?> reasonForLearning = const Value.absent(),
    Value<String?> resourceLink = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    Value<String?> practiceTaskId = const Value.absent(),
    Value<String?> nextStep = const Value.absent(),
    Value<String?> skillConfidence = const Value.absent(),
    Value<DateTime?> dateStarted = const Value.absent(),
    Value<DateTime?> dateApplied = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) => LearningItem(
    learningItemId: learningItemId ?? this.learningItemId,
    projectId: projectId.present ? projectId.value : this.projectId,
    topic: topic ?? this.topic,
    reasonForLearning: reasonForLearning.present
        ? reasonForLearning.value
        : this.reasonForLearning,
    resourceLink: resourceLink.present ? resourceLink.value : this.resourceLink,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    practiceTaskId: practiceTaskId.present
        ? practiceTaskId.value
        : this.practiceTaskId,
    nextStep: nextStep.present ? nextStep.value : this.nextStep,
    skillConfidence: skillConfidence.present
        ? skillConfidence.value
        : this.skillConfidence,
    dateStarted: dateStarted.present ? dateStarted.value : this.dateStarted,
    dateApplied: dateApplied.present ? dateApplied.value : this.dateApplied,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isArchived: isArchived ?? this.isArchived,
  );
  LearningItem copyWithCompanion(LearningItemsCompanion data) {
    return LearningItem(
      learningItemId: data.learningItemId.present
          ? data.learningItemId.value
          : this.learningItemId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      topic: data.topic.present ? data.topic.value : this.topic,
      reasonForLearning: data.reasonForLearning.present
          ? data.reasonForLearning.value
          : this.reasonForLearning,
      resourceLink: data.resourceLink.present
          ? data.resourceLink.value
          : this.resourceLink,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      practiceTaskId: data.practiceTaskId.present
          ? data.practiceTaskId.value
          : this.practiceTaskId,
      nextStep: data.nextStep.present ? data.nextStep.value : this.nextStep,
      skillConfidence: data.skillConfidence.present
          ? data.skillConfidence.value
          : this.skillConfidence,
      dateStarted: data.dateStarted.present
          ? data.dateStarted.value
          : this.dateStarted,
      dateApplied: data.dateApplied.present
          ? data.dateApplied.value
          : this.dateApplied,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningItem(')
          ..write('learningItemId: $learningItemId, ')
          ..write('projectId: $projectId, ')
          ..write('topic: $topic, ')
          ..write('reasonForLearning: $reasonForLearning, ')
          ..write('resourceLink: $resourceLink, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('practiceTaskId: $practiceTaskId, ')
          ..write('nextStep: $nextStep, ')
          ..write('skillConfidence: $skillConfidence, ')
          ..write('dateStarted: $dateStarted, ')
          ..write('dateApplied: $dateApplied, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    learningItemId,
    projectId,
    topic,
    reasonForLearning,
    resourceLink,
    status,
    notes,
    practiceTaskId,
    nextStep,
    skillConfidence,
    dateStarted,
    dateApplied,
    createdAt,
    updatedAt,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningItem &&
          other.learningItemId == this.learningItemId &&
          other.projectId == this.projectId &&
          other.topic == this.topic &&
          other.reasonForLearning == this.reasonForLearning &&
          other.resourceLink == this.resourceLink &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.practiceTaskId == this.practiceTaskId &&
          other.nextStep == this.nextStep &&
          other.skillConfidence == this.skillConfidence &&
          other.dateStarted == this.dateStarted &&
          other.dateApplied == this.dateApplied &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isArchived == this.isArchived);
}

class LearningItemsCompanion extends UpdateCompanion<LearningItem> {
  final Value<String> learningItemId;
  final Value<String?> projectId;
  final Value<String> topic;
  final Value<String?> reasonForLearning;
  final Value<String?> resourceLink;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> practiceTaskId;
  final Value<String?> nextStep;
  final Value<String?> skillConfidence;
  final Value<DateTime?> dateStarted;
  final Value<DateTime?> dateApplied;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const LearningItemsCompanion({
    this.learningItemId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.topic = const Value.absent(),
    this.reasonForLearning = const Value.absent(),
    this.resourceLink = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.practiceTaskId = const Value.absent(),
    this.nextStep = const Value.absent(),
    this.skillConfidence = const Value.absent(),
    this.dateStarted = const Value.absent(),
    this.dateApplied = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearningItemsCompanion.insert({
    required String learningItemId,
    this.projectId = const Value.absent(),
    required String topic,
    this.reasonForLearning = const Value.absent(),
    this.resourceLink = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.practiceTaskId = const Value.absent(),
    this.nextStep = const Value.absent(),
    this.skillConfidence = const Value.absent(),
    this.dateStarted = const Value.absent(),
    this.dateApplied = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : learningItemId = Value(learningItemId),
       topic = Value(topic),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LearningItem> custom({
    Expression<String>? learningItemId,
    Expression<String>? projectId,
    Expression<String>? topic,
    Expression<String>? reasonForLearning,
    Expression<String>? resourceLink,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? practiceTaskId,
    Expression<String>? nextStep,
    Expression<String>? skillConfidence,
    Expression<DateTime>? dateStarted,
    Expression<DateTime>? dateApplied,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (learningItemId != null) 'learning_item_id': learningItemId,
      if (projectId != null) 'project_id': projectId,
      if (topic != null) 'topic': topic,
      if (reasonForLearning != null) 'reason_for_learning': reasonForLearning,
      if (resourceLink != null) 'resource_link': resourceLink,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (practiceTaskId != null) 'practice_task_id': practiceTaskId,
      if (nextStep != null) 'next_step': nextStep,
      if (skillConfidence != null) 'skill_confidence': skillConfidence,
      if (dateStarted != null) 'date_started': dateStarted,
      if (dateApplied != null) 'date_applied': dateApplied,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearningItemsCompanion copyWith({
    Value<String>? learningItemId,
    Value<String?>? projectId,
    Value<String>? topic,
    Value<String?>? reasonForLearning,
    Value<String?>? resourceLink,
    Value<String>? status,
    Value<String?>? notes,
    Value<String?>? practiceTaskId,
    Value<String?>? nextStep,
    Value<String?>? skillConfidence,
    Value<DateTime?>? dateStarted,
    Value<DateTime?>? dateApplied,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return LearningItemsCompanion(
      learningItemId: learningItemId ?? this.learningItemId,
      projectId: projectId ?? this.projectId,
      topic: topic ?? this.topic,
      reasonForLearning: reasonForLearning ?? this.reasonForLearning,
      resourceLink: resourceLink ?? this.resourceLink,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      practiceTaskId: practiceTaskId ?? this.practiceTaskId,
      nextStep: nextStep ?? this.nextStep,
      skillConfidence: skillConfidence ?? this.skillConfidence,
      dateStarted: dateStarted ?? this.dateStarted,
      dateApplied: dateApplied ?? this.dateApplied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (learningItemId.present) {
      map['learning_item_id'] = Variable<String>(learningItemId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (reasonForLearning.present) {
      map['reason_for_learning'] = Variable<String>(reasonForLearning.value);
    }
    if (resourceLink.present) {
      map['resource_link'] = Variable<String>(resourceLink.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (practiceTaskId.present) {
      map['practice_task_id'] = Variable<String>(practiceTaskId.value);
    }
    if (nextStep.present) {
      map['next_step'] = Variable<String>(nextStep.value);
    }
    if (skillConfidence.present) {
      map['skill_confidence'] = Variable<String>(skillConfidence.value);
    }
    if (dateStarted.present) {
      map['date_started'] = Variable<DateTime>(dateStarted.value);
    }
    if (dateApplied.present) {
      map['date_applied'] = Variable<DateTime>(dateApplied.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningItemsCompanion(')
          ..write('learningItemId: $learningItemId, ')
          ..write('projectId: $projectId, ')
          ..write('topic: $topic, ')
          ..write('reasonForLearning: $reasonForLearning, ')
          ..write('resourceLink: $resourceLink, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('practiceTaskId: $practiceTaskId, ')
          ..write('nextStep: $nextStep, ')
          ..write('skillConfidence: $skillConfidence, ')
          ..write('dateStarted: $dateStarted, ')
          ..write('dateApplied: $dateApplied, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentItemsTable extends ContentItems
    with TableInfo<$ContentItemsTable, ContentItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contentItemIdMeta = const VerificationMeta(
    'contentItemId',
  );
  @override
  late final GeneratedColumn<String> contentItemId = GeneratedColumn<String>(
    'content_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<String> journalEntryId = GeneratedColumn<String>(
    'journal_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Idea'),
  );
  static const VerificationMeta _draftTextMeta = const VerificationMeta(
    'draftText',
  );
  @override
  late final GeneratedColumn<String> draftText = GeneratedColumn<String>(
    'draft_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageNeededMeta = const VerificationMeta(
    'imageNeeded',
  );
  @override
  late final GeneratedColumn<bool> imageNeeded = GeneratedColumn<bool>(
    'image_needed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("image_needed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _imagePromptMeta = const VerificationMeta(
    'imagePrompt',
  );
  @override
  late final GeneratedColumn<String> imagePrompt = GeneratedColumn<String>(
    'image_prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishDateMeta = const VerificationMeta(
    'publishDate',
  );
  @override
  late final GeneratedColumn<DateTime> publishDate = GeneratedColumn<DateTime>(
    'publish_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedLinkMeta = const VerificationMeta(
    'publishedLink',
  );
  @override
  late final GeneratedColumn<String> publishedLink = GeneratedColumn<String>(
    'published_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    contentItemId,
    projectId,
    journalEntryId,
    title,
    platform,
    contentType,
    status,
    draftText,
    imageNeeded,
    imagePrompt,
    publishDate,
    publishedLink,
    notes,
    createdAt,
    updatedAt,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('content_item_id')) {
      context.handle(
        _contentItemIdMeta,
        contentItemId.isAcceptableOrUnknown(
          data['content_item_id']!,
          _contentItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentItemIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('draft_text')) {
      context.handle(
        _draftTextMeta,
        draftText.isAcceptableOrUnknown(data['draft_text']!, _draftTextMeta),
      );
    }
    if (data.containsKey('image_needed')) {
      context.handle(
        _imageNeededMeta,
        imageNeeded.isAcceptableOrUnknown(
          data['image_needed']!,
          _imageNeededMeta,
        ),
      );
    }
    if (data.containsKey('image_prompt')) {
      context.handle(
        _imagePromptMeta,
        imagePrompt.isAcceptableOrUnknown(
          data['image_prompt']!,
          _imagePromptMeta,
        ),
      );
    }
    if (data.containsKey('publish_date')) {
      context.handle(
        _publishDateMeta,
        publishDate.isAcceptableOrUnknown(
          data['publish_date']!,
          _publishDateMeta,
        ),
      );
    }
    if (data.containsKey('published_link')) {
      context.handle(
        _publishedLinkMeta,
        publishedLink.isAcceptableOrUnknown(
          data['published_link']!,
          _publishedLinkMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contentItemId};
  @override
  ContentItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentItem(
      contentItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_item_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_entry_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      draftText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_text'],
      ),
      imageNeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}image_needed'],
      )!,
      imagePrompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_prompt'],
      ),
      publishDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}publish_date'],
      ),
      publishedLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_link'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $ContentItemsTable createAlias(String alias) {
    return $ContentItemsTable(attachedDatabase, alias);
  }
}

class ContentItem extends DataClass implements Insertable<ContentItem> {
  final String contentItemId;
  final String? projectId;
  final String? journalEntryId;
  final String title;
  final String? platform;
  final String? contentType;
  final String status;
  final String? draftText;
  final bool imageNeeded;
  final String? imagePrompt;
  final DateTime? publishDate;
  final String? publishedLink;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  const ContentItem({
    required this.contentItemId,
    this.projectId,
    this.journalEntryId,
    required this.title,
    this.platform,
    this.contentType,
    required this.status,
    this.draftText,
    required this.imageNeeded,
    this.imagePrompt,
    this.publishDate,
    this.publishedLink,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['content_item_id'] = Variable<String>(contentItemId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<String>(journalEntryId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || platform != null) {
      map['platform'] = Variable<String>(platform);
    }
    if (!nullToAbsent || contentType != null) {
      map['content_type'] = Variable<String>(contentType);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || draftText != null) {
      map['draft_text'] = Variable<String>(draftText);
    }
    map['image_needed'] = Variable<bool>(imageNeeded);
    if (!nullToAbsent || imagePrompt != null) {
      map['image_prompt'] = Variable<String>(imagePrompt);
    }
    if (!nullToAbsent || publishDate != null) {
      map['publish_date'] = Variable<DateTime>(publishDate);
    }
    if (!nullToAbsent || publishedLink != null) {
      map['published_link'] = Variable<String>(publishedLink);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  ContentItemsCompanion toCompanion(bool nullToAbsent) {
    return ContentItemsCompanion(
      contentItemId: Value(contentItemId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
      title: Value(title),
      platform: platform == null && nullToAbsent
          ? const Value.absent()
          : Value(platform),
      contentType: contentType == null && nullToAbsent
          ? const Value.absent()
          : Value(contentType),
      status: Value(status),
      draftText: draftText == null && nullToAbsent
          ? const Value.absent()
          : Value(draftText),
      imageNeeded: Value(imageNeeded),
      imagePrompt: imagePrompt == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePrompt),
      publishDate: publishDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publishDate),
      publishedLink: publishedLink == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedLink),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isArchived: Value(isArchived),
    );
  }

  factory ContentItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentItem(
      contentItemId: serializer.fromJson<String>(json['contentItemId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      journalEntryId: serializer.fromJson<String?>(json['journalEntryId']),
      title: serializer.fromJson<String>(json['title']),
      platform: serializer.fromJson<String?>(json['platform']),
      contentType: serializer.fromJson<String?>(json['contentType']),
      status: serializer.fromJson<String>(json['status']),
      draftText: serializer.fromJson<String?>(json['draftText']),
      imageNeeded: serializer.fromJson<bool>(json['imageNeeded']),
      imagePrompt: serializer.fromJson<String?>(json['imagePrompt']),
      publishDate: serializer.fromJson<DateTime?>(json['publishDate']),
      publishedLink: serializer.fromJson<String?>(json['publishedLink']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contentItemId': serializer.toJson<String>(contentItemId),
      'projectId': serializer.toJson<String?>(projectId),
      'journalEntryId': serializer.toJson<String?>(journalEntryId),
      'title': serializer.toJson<String>(title),
      'platform': serializer.toJson<String?>(platform),
      'contentType': serializer.toJson<String?>(contentType),
      'status': serializer.toJson<String>(status),
      'draftText': serializer.toJson<String?>(draftText),
      'imageNeeded': serializer.toJson<bool>(imageNeeded),
      'imagePrompt': serializer.toJson<String?>(imagePrompt),
      'publishDate': serializer.toJson<DateTime?>(publishDate),
      'publishedLink': serializer.toJson<String?>(publishedLink),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  ContentItem copyWith({
    String? contentItemId,
    Value<String?> projectId = const Value.absent(),
    Value<String?> journalEntryId = const Value.absent(),
    String? title,
    Value<String?> platform = const Value.absent(),
    Value<String?> contentType = const Value.absent(),
    String? status,
    Value<String?> draftText = const Value.absent(),
    bool? imageNeeded,
    Value<String?> imagePrompt = const Value.absent(),
    Value<DateTime?> publishDate = const Value.absent(),
    Value<String?> publishedLink = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) => ContentItem(
    contentItemId: contentItemId ?? this.contentItemId,
    projectId: projectId.present ? projectId.value : this.projectId,
    journalEntryId: journalEntryId.present
        ? journalEntryId.value
        : this.journalEntryId,
    title: title ?? this.title,
    platform: platform.present ? platform.value : this.platform,
    contentType: contentType.present ? contentType.value : this.contentType,
    status: status ?? this.status,
    draftText: draftText.present ? draftText.value : this.draftText,
    imageNeeded: imageNeeded ?? this.imageNeeded,
    imagePrompt: imagePrompt.present ? imagePrompt.value : this.imagePrompt,
    publishDate: publishDate.present ? publishDate.value : this.publishDate,
    publishedLink: publishedLink.present
        ? publishedLink.value
        : this.publishedLink,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isArchived: isArchived ?? this.isArchived,
  );
  ContentItem copyWithCompanion(ContentItemsCompanion data) {
    return ContentItem(
      contentItemId: data.contentItemId.present
          ? data.contentItemId.value
          : this.contentItemId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
      title: data.title.present ? data.title.value : this.title,
      platform: data.platform.present ? data.platform.value : this.platform,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      status: data.status.present ? data.status.value : this.status,
      draftText: data.draftText.present ? data.draftText.value : this.draftText,
      imageNeeded: data.imageNeeded.present
          ? data.imageNeeded.value
          : this.imageNeeded,
      imagePrompt: data.imagePrompt.present
          ? data.imagePrompt.value
          : this.imagePrompt,
      publishDate: data.publishDate.present
          ? data.publishDate.value
          : this.publishDate,
      publishedLink: data.publishedLink.present
          ? data.publishedLink.value
          : this.publishedLink,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentItem(')
          ..write('contentItemId: $contentItemId, ')
          ..write('projectId: $projectId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('title: $title, ')
          ..write('platform: $platform, ')
          ..write('contentType: $contentType, ')
          ..write('status: $status, ')
          ..write('draftText: $draftText, ')
          ..write('imageNeeded: $imageNeeded, ')
          ..write('imagePrompt: $imagePrompt, ')
          ..write('publishDate: $publishDate, ')
          ..write('publishedLink: $publishedLink, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    contentItemId,
    projectId,
    journalEntryId,
    title,
    platform,
    contentType,
    status,
    draftText,
    imageNeeded,
    imagePrompt,
    publishDate,
    publishedLink,
    notes,
    createdAt,
    updatedAt,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentItem &&
          other.contentItemId == this.contentItemId &&
          other.projectId == this.projectId &&
          other.journalEntryId == this.journalEntryId &&
          other.title == this.title &&
          other.platform == this.platform &&
          other.contentType == this.contentType &&
          other.status == this.status &&
          other.draftText == this.draftText &&
          other.imageNeeded == this.imageNeeded &&
          other.imagePrompt == this.imagePrompt &&
          other.publishDate == this.publishDate &&
          other.publishedLink == this.publishedLink &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isArchived == this.isArchived);
}

class ContentItemsCompanion extends UpdateCompanion<ContentItem> {
  final Value<String> contentItemId;
  final Value<String?> projectId;
  final Value<String?> journalEntryId;
  final Value<String> title;
  final Value<String?> platform;
  final Value<String?> contentType;
  final Value<String> status;
  final Value<String?> draftText;
  final Value<bool> imageNeeded;
  final Value<String?> imagePrompt;
  final Value<DateTime?> publishDate;
  final Value<String?> publishedLink;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const ContentItemsCompanion({
    this.contentItemId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    this.title = const Value.absent(),
    this.platform = const Value.absent(),
    this.contentType = const Value.absent(),
    this.status = const Value.absent(),
    this.draftText = const Value.absent(),
    this.imageNeeded = const Value.absent(),
    this.imagePrompt = const Value.absent(),
    this.publishDate = const Value.absent(),
    this.publishedLink = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentItemsCompanion.insert({
    required String contentItemId,
    this.projectId = const Value.absent(),
    this.journalEntryId = const Value.absent(),
    required String title,
    this.platform = const Value.absent(),
    this.contentType = const Value.absent(),
    this.status = const Value.absent(),
    this.draftText = const Value.absent(),
    this.imageNeeded = const Value.absent(),
    this.imagePrompt = const Value.absent(),
    this.publishDate = const Value.absent(),
    this.publishedLink = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contentItemId = Value(contentItemId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ContentItem> custom({
    Expression<String>? contentItemId,
    Expression<String>? projectId,
    Expression<String>? journalEntryId,
    Expression<String>? title,
    Expression<String>? platform,
    Expression<String>? contentType,
    Expression<String>? status,
    Expression<String>? draftText,
    Expression<bool>? imageNeeded,
    Expression<String>? imagePrompt,
    Expression<DateTime>? publishDate,
    Expression<String>? publishedLink,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contentItemId != null) 'content_item_id': contentItemId,
      if (projectId != null) 'project_id': projectId,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
      if (title != null) 'title': title,
      if (platform != null) 'platform': platform,
      if (contentType != null) 'content_type': contentType,
      if (status != null) 'status': status,
      if (draftText != null) 'draft_text': draftText,
      if (imageNeeded != null) 'image_needed': imageNeeded,
      if (imagePrompt != null) 'image_prompt': imagePrompt,
      if (publishDate != null) 'publish_date': publishDate,
      if (publishedLink != null) 'published_link': publishedLink,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentItemsCompanion copyWith({
    Value<String>? contentItemId,
    Value<String?>? projectId,
    Value<String?>? journalEntryId,
    Value<String>? title,
    Value<String?>? platform,
    Value<String?>? contentType,
    Value<String>? status,
    Value<String?>? draftText,
    Value<bool>? imageNeeded,
    Value<String?>? imagePrompt,
    Value<DateTime?>? publishDate,
    Value<String?>? publishedLink,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return ContentItemsCompanion(
      contentItemId: contentItemId ?? this.contentItemId,
      projectId: projectId ?? this.projectId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      contentType: contentType ?? this.contentType,
      status: status ?? this.status,
      draftText: draftText ?? this.draftText,
      imageNeeded: imageNeeded ?? this.imageNeeded,
      imagePrompt: imagePrompt ?? this.imagePrompt,
      publishDate: publishDate ?? this.publishDate,
      publishedLink: publishedLink ?? this.publishedLink,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contentItemId.present) {
      map['content_item_id'] = Variable<String>(contentItemId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<String>(journalEntryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (draftText.present) {
      map['draft_text'] = Variable<String>(draftText.value);
    }
    if (imageNeeded.present) {
      map['image_needed'] = Variable<bool>(imageNeeded.value);
    }
    if (imagePrompt.present) {
      map['image_prompt'] = Variable<String>(imagePrompt.value);
    }
    if (publishDate.present) {
      map['publish_date'] = Variable<DateTime>(publishDate.value);
    }
    if (publishedLink.present) {
      map['published_link'] = Variable<String>(publishedLink.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentItemsCompanion(')
          ..write('contentItemId: $contentItemId, ')
          ..write('projectId: $projectId, ')
          ..write('journalEntryId: $journalEntryId, ')
          ..write('title: $title, ')
          ..write('platform: $platform, ')
          ..write('contentType: $contentType, ')
          ..write('status: $status, ')
          ..write('draftText: $draftText, ')
          ..write('imageNeeded: $imageNeeded, ')
          ..write('imagePrompt: $imagePrompt, ')
          ..write('publishDate: $publishDate, ')
          ..write('publishedLink: $publishedLink, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BusinessOpportunitiesTable extends BusinessOpportunities
    with TableInfo<$BusinessOpportunitiesTable, BusinessOpportunity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessOpportunitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _businessOpportunityIdMeta =
      const VerificationMeta('businessOpportunityId');
  @override
  late final GeneratedColumn<String> businessOpportunityId =
      GeneratedColumn<String>(
        'business_opportunity_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyOrContactMeta = const VerificationMeta(
    'companyOrContact',
  );
  @override
  late final GeneratedColumn<String> companyOrContact = GeneratedColumn<String>(
    'company_or_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Researching'),
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followUpDateMeta = const VerificationMeta(
    'followUpDate',
  );
  @override
  late final GeneratedColumn<DateTime> followUpDate = GeneratedColumn<DateTime>(
    'follow_up_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedDocumentLinkMeta =
      const VerificationMeta('relatedDocumentLink');
  @override
  late final GeneratedColumn<String> relatedDocumentLink =
      GeneratedColumn<String>(
        'related_document_link',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    businessOpportunityId,
    projectId,
    name,
    type,
    companyOrContact,
    status,
    deadline,
    nextAction,
    followUpDate,
    relatedDocumentLink,
    notes,
    createdAt,
    updatedAt,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_opportunities';
  @override
  VerificationContext validateIntegrity(
    Insertable<BusinessOpportunity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('business_opportunity_id')) {
      context.handle(
        _businessOpportunityIdMeta,
        businessOpportunityId.isAcceptableOrUnknown(
          data['business_opportunity_id']!,
          _businessOpportunityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessOpportunityIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('company_or_contact')) {
      context.handle(
        _companyOrContactMeta,
        companyOrContact.isAcceptableOrUnknown(
          data['company_or_contact']!,
          _companyOrContactMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('follow_up_date')) {
      context.handle(
        _followUpDateMeta,
        followUpDate.isAcceptableOrUnknown(
          data['follow_up_date']!,
          _followUpDateMeta,
        ),
      );
    }
    if (data.containsKey('related_document_link')) {
      context.handle(
        _relatedDocumentLinkMeta,
        relatedDocumentLink.isAcceptableOrUnknown(
          data['related_document_link']!,
          _relatedDocumentLinkMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {businessOpportunityId};
  @override
  BusinessOpportunity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessOpportunity(
      businessOpportunityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_opportunity_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      companyOrContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_or_contact'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      ),
      followUpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}follow_up_date'],
      ),
      relatedDocumentLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_document_link'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $BusinessOpportunitiesTable createAlias(String alias) {
    return $BusinessOpportunitiesTable(attachedDatabase, alias);
  }
}

class BusinessOpportunity extends DataClass
    implements Insertable<BusinessOpportunity> {
  final String businessOpportunityId;
  final String? projectId;
  final String name;
  final String? type;
  final String? companyOrContact;
  final String status;
  final DateTime? deadline;
  final String? nextAction;
  final DateTime? followUpDate;
  final String? relatedDocumentLink;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  const BusinessOpportunity({
    required this.businessOpportunityId,
    this.projectId,
    required this.name,
    this.type,
    this.companyOrContact,
    required this.status,
    this.deadline,
    this.nextAction,
    this.followUpDate,
    this.relatedDocumentLink,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['business_opportunity_id'] = Variable<String>(businessOpportunityId);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || companyOrContact != null) {
      map['company_or_contact'] = Variable<String>(companyOrContact);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    if (!nullToAbsent || followUpDate != null) {
      map['follow_up_date'] = Variable<DateTime>(followUpDate);
    }
    if (!nullToAbsent || relatedDocumentLink != null) {
      map['related_document_link'] = Variable<String>(relatedDocumentLink);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  BusinessOpportunitiesCompanion toCompanion(bool nullToAbsent) {
    return BusinessOpportunitiesCompanion(
      businessOpportunityId: Value(businessOpportunityId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      name: Value(name),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      companyOrContact: companyOrContact == null && nullToAbsent
          ? const Value.absent()
          : Value(companyOrContact),
      status: Value(status),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      followUpDate: followUpDate == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpDate),
      relatedDocumentLink: relatedDocumentLink == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedDocumentLink),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isArchived: Value(isArchived),
    );
  }

  factory BusinessOpportunity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessOpportunity(
      businessOpportunityId: serializer.fromJson<String>(
        json['businessOpportunityId'],
      ),
      projectId: serializer.fromJson<String?>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String?>(json['type']),
      companyOrContact: serializer.fromJson<String?>(json['companyOrContact']),
      status: serializer.fromJson<String>(json['status']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      followUpDate: serializer.fromJson<DateTime?>(json['followUpDate']),
      relatedDocumentLink: serializer.fromJson<String?>(
        json['relatedDocumentLink'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'businessOpportunityId': serializer.toJson<String>(businessOpportunityId),
      'projectId': serializer.toJson<String?>(projectId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String?>(type),
      'companyOrContact': serializer.toJson<String?>(companyOrContact),
      'status': serializer.toJson<String>(status),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'nextAction': serializer.toJson<String?>(nextAction),
      'followUpDate': serializer.toJson<DateTime?>(followUpDate),
      'relatedDocumentLink': serializer.toJson<String?>(relatedDocumentLink),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  BusinessOpportunity copyWith({
    String? businessOpportunityId,
    Value<String?> projectId = const Value.absent(),
    String? name,
    Value<String?> type = const Value.absent(),
    Value<String?> companyOrContact = const Value.absent(),
    String? status,
    Value<DateTime?> deadline = const Value.absent(),
    Value<String?> nextAction = const Value.absent(),
    Value<DateTime?> followUpDate = const Value.absent(),
    Value<String?> relatedDocumentLink = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) => BusinessOpportunity(
    businessOpportunityId: businessOpportunityId ?? this.businessOpportunityId,
    projectId: projectId.present ? projectId.value : this.projectId,
    name: name ?? this.name,
    type: type.present ? type.value : this.type,
    companyOrContact: companyOrContact.present
        ? companyOrContact.value
        : this.companyOrContact,
    status: status ?? this.status,
    deadline: deadline.present ? deadline.value : this.deadline,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    followUpDate: followUpDate.present ? followUpDate.value : this.followUpDate,
    relatedDocumentLink: relatedDocumentLink.present
        ? relatedDocumentLink.value
        : this.relatedDocumentLink,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isArchived: isArchived ?? this.isArchived,
  );
  BusinessOpportunity copyWithCompanion(BusinessOpportunitiesCompanion data) {
    return BusinessOpportunity(
      businessOpportunityId: data.businessOpportunityId.present
          ? data.businessOpportunityId.value
          : this.businessOpportunityId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      companyOrContact: data.companyOrContact.present
          ? data.companyOrContact.value
          : this.companyOrContact,
      status: data.status.present ? data.status.value : this.status,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      followUpDate: data.followUpDate.present
          ? data.followUpDate.value
          : this.followUpDate,
      relatedDocumentLink: data.relatedDocumentLink.present
          ? data.relatedDocumentLink.value
          : this.relatedDocumentLink,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessOpportunity(')
          ..write('businessOpportunityId: $businessOpportunityId, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('companyOrContact: $companyOrContact, ')
          ..write('status: $status, ')
          ..write('deadline: $deadline, ')
          ..write('nextAction: $nextAction, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('relatedDocumentLink: $relatedDocumentLink, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    businessOpportunityId,
    projectId,
    name,
    type,
    companyOrContact,
    status,
    deadline,
    nextAction,
    followUpDate,
    relatedDocumentLink,
    notes,
    createdAt,
    updatedAt,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessOpportunity &&
          other.businessOpportunityId == this.businessOpportunityId &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.type == this.type &&
          other.companyOrContact == this.companyOrContact &&
          other.status == this.status &&
          other.deadline == this.deadline &&
          other.nextAction == this.nextAction &&
          other.followUpDate == this.followUpDate &&
          other.relatedDocumentLink == this.relatedDocumentLink &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isArchived == this.isArchived);
}

class BusinessOpportunitiesCompanion
    extends UpdateCompanion<BusinessOpportunity> {
  final Value<String> businessOpportunityId;
  final Value<String?> projectId;
  final Value<String> name;
  final Value<String?> type;
  final Value<String?> companyOrContact;
  final Value<String> status;
  final Value<DateTime?> deadline;
  final Value<String?> nextAction;
  final Value<DateTime?> followUpDate;
  final Value<String?> relatedDocumentLink;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const BusinessOpportunitiesCompanion({
    this.businessOpportunityId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.companyOrContact = const Value.absent(),
    this.status = const Value.absent(),
    this.deadline = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.relatedDocumentLink = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BusinessOpportunitiesCompanion.insert({
    required String businessOpportunityId,
    this.projectId = const Value.absent(),
    required String name,
    this.type = const Value.absent(),
    this.companyOrContact = const Value.absent(),
    this.status = const Value.absent(),
    this.deadline = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.relatedDocumentLink = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : businessOpportunityId = Value(businessOpportunityId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BusinessOpportunity> custom({
    Expression<String>? businessOpportunityId,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? companyOrContact,
    Expression<String>? status,
    Expression<DateTime>? deadline,
    Expression<String>? nextAction,
    Expression<DateTime>? followUpDate,
    Expression<String>? relatedDocumentLink,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (businessOpportunityId != null)
        'business_opportunity_id': businessOpportunityId,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (companyOrContact != null) 'company_or_contact': companyOrContact,
      if (status != null) 'status': status,
      if (deadline != null) 'deadline': deadline,
      if (nextAction != null) 'next_action': nextAction,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (relatedDocumentLink != null)
        'related_document_link': relatedDocumentLink,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BusinessOpportunitiesCompanion copyWith({
    Value<String>? businessOpportunityId,
    Value<String?>? projectId,
    Value<String>? name,
    Value<String?>? type,
    Value<String?>? companyOrContact,
    Value<String>? status,
    Value<DateTime?>? deadline,
    Value<String?>? nextAction,
    Value<DateTime?>? followUpDate,
    Value<String?>? relatedDocumentLink,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return BusinessOpportunitiesCompanion(
      businessOpportunityId:
          businessOpportunityId ?? this.businessOpportunityId,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      type: type ?? this.type,
      companyOrContact: companyOrContact ?? this.companyOrContact,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      nextAction: nextAction ?? this.nextAction,
      followUpDate: followUpDate ?? this.followUpDate,
      relatedDocumentLink: relatedDocumentLink ?? this.relatedDocumentLink,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (businessOpportunityId.present) {
      map['business_opportunity_id'] = Variable<String>(
        businessOpportunityId.value,
      );
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (companyOrContact.present) {
      map['company_or_contact'] = Variable<String>(companyOrContact.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (followUpDate.present) {
      map['follow_up_date'] = Variable<DateTime>(followUpDate.value);
    }
    if (relatedDocumentLink.present) {
      map['related_document_link'] = Variable<String>(
        relatedDocumentLink.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessOpportunitiesCompanion(')
          ..write('businessOpportunityId: $businessOpportunityId, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('companyOrContact: $companyOrContact, ')
          ..write('status: $status, ')
          ..write('deadline: $deadline, ')
          ..write('nextAction: $nextAction, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('relatedDocumentLink: $relatedDocumentLink, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WellbeingCheckinsTable extends WellbeingCheckins
    with TableInfo<$WellbeingCheckinsTable, WellbeingCheckin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WellbeingCheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wellbeingCheckinIdMeta =
      const VerificationMeta('wellbeingCheckinId');
  @override
  late final GeneratedColumn<String> wellbeingCheckinId =
      GeneratedColumn<String>(
        'wellbeing_checkin_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyLevelMeta = const VerificationMeta(
    'energyLevel',
  );
  @override
  late final GeneratedColumn<String> energyLevel = GeneratedColumn<String>(
    'energy_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<String> sleepQuality = GeneratedColumn<String>(
    'sleep_quality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stressLevelMeta = const VerificationMeta(
    'stressLevel',
  );
  @override
  late final GeneratedColumn<String> stressLevel = GeneratedColumn<String>(
    'stress_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _movementDoneMeta = const VerificationMeta(
    'movementDone',
  );
  @override
  late final GeneratedColumn<bool> movementDone = GeneratedColumn<bool>(
    'movement_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("movement_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _foodWaterOkMeta = const VerificationMeta(
    'foodWaterOk',
  );
  @override
  late final GeneratedColumn<bool> foodWaterOk = GeneratedColumn<bool>(
    'food_water_ok',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("food_water_ok" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _meditationReflectionDoneMeta =
      const VerificationMeta('meditationReflectionDone');
  @override
  late final GeneratedColumn<bool> meditationReflectionDone =
      GeneratedColumn<bool>(
        'meditation_reflection_done',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("meditation_reflection_done" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suggestedWorkloadMeta = const VerificationMeta(
    'suggestedWorkload',
  );
  @override
  late final GeneratedColumn<String> suggestedWorkload =
      GeneratedColumn<String>(
        'suggested_workload',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    wellbeingCheckinId,
    date,
    energyLevel,
    mood,
    sleepQuality,
    stressLevel,
    movementDone,
    foodWaterOk,
    meditationReflectionDone,
    notes,
    suggestedWorkload,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wellbeing_checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<WellbeingCheckin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wellbeing_checkin_id')) {
      context.handle(
        _wellbeingCheckinIdMeta,
        wellbeingCheckinId.isAcceptableOrUnknown(
          data['wellbeing_checkin_id']!,
          _wellbeingCheckinIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wellbeingCheckinIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('energy_level')) {
      context.handle(
        _energyLevelMeta,
        energyLevel.isAcceptableOrUnknown(
          data['energy_level']!,
          _energyLevelMeta,
        ),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    }
    if (data.containsKey('stress_level')) {
      context.handle(
        _stressLevelMeta,
        stressLevel.isAcceptableOrUnknown(
          data['stress_level']!,
          _stressLevelMeta,
        ),
      );
    }
    if (data.containsKey('movement_done')) {
      context.handle(
        _movementDoneMeta,
        movementDone.isAcceptableOrUnknown(
          data['movement_done']!,
          _movementDoneMeta,
        ),
      );
    }
    if (data.containsKey('food_water_ok')) {
      context.handle(
        _foodWaterOkMeta,
        foodWaterOk.isAcceptableOrUnknown(
          data['food_water_ok']!,
          _foodWaterOkMeta,
        ),
      );
    }
    if (data.containsKey('meditation_reflection_done')) {
      context.handle(
        _meditationReflectionDoneMeta,
        meditationReflectionDone.isAcceptableOrUnknown(
          data['meditation_reflection_done']!,
          _meditationReflectionDoneMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('suggested_workload')) {
      context.handle(
        _suggestedWorkloadMeta,
        suggestedWorkload.isAcceptableOrUnknown(
          data['suggested_workload']!,
          _suggestedWorkloadMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wellbeingCheckinId};
  @override
  WellbeingCheckin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WellbeingCheckin(
      wellbeingCheckinId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wellbeing_checkin_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      energyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}energy_level'],
      ),
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      sleepQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sleep_quality'],
      ),
      stressLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stress_level'],
      ),
      movementDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}movement_done'],
      )!,
      foodWaterOk: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}food_water_ok'],
      )!,
      meditationReflectionDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}meditation_reflection_done'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      suggestedWorkload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_workload'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WellbeingCheckinsTable createAlias(String alias) {
    return $WellbeingCheckinsTable(attachedDatabase, alias);
  }
}

class WellbeingCheckin extends DataClass
    implements Insertable<WellbeingCheckin> {
  final String wellbeingCheckinId;
  final DateTime date;
  final String? energyLevel;
  final String? mood;
  final String? sleepQuality;
  final String? stressLevel;
  final bool movementDone;
  final bool foodWaterOk;
  final bool meditationReflectionDone;
  final String? notes;
  final String? suggestedWorkload;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WellbeingCheckin({
    required this.wellbeingCheckinId,
    required this.date,
    this.energyLevel,
    this.mood,
    this.sleepQuality,
    this.stressLevel,
    required this.movementDone,
    required this.foodWaterOk,
    required this.meditationReflectionDone,
    this.notes,
    this.suggestedWorkload,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wellbeing_checkin_id'] = Variable<String>(wellbeingCheckinId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || energyLevel != null) {
      map['energy_level'] = Variable<String>(energyLevel);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || sleepQuality != null) {
      map['sleep_quality'] = Variable<String>(sleepQuality);
    }
    if (!nullToAbsent || stressLevel != null) {
      map['stress_level'] = Variable<String>(stressLevel);
    }
    map['movement_done'] = Variable<bool>(movementDone);
    map['food_water_ok'] = Variable<bool>(foodWaterOk);
    map['meditation_reflection_done'] = Variable<bool>(
      meditationReflectionDone,
    );
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || suggestedWorkload != null) {
      map['suggested_workload'] = Variable<String>(suggestedWorkload);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WellbeingCheckinsCompanion toCompanion(bool nullToAbsent) {
    return WellbeingCheckinsCompanion(
      wellbeingCheckinId: Value(wellbeingCheckinId),
      date: Value(date),
      energyLevel: energyLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(energyLevel),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      sleepQuality: sleepQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepQuality),
      stressLevel: stressLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(stressLevel),
      movementDone: Value(movementDone),
      foodWaterOk: Value(foodWaterOk),
      meditationReflectionDone: Value(meditationReflectionDone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      suggestedWorkload: suggestedWorkload == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedWorkload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WellbeingCheckin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WellbeingCheckin(
      wellbeingCheckinId: serializer.fromJson<String>(
        json['wellbeingCheckinId'],
      ),
      date: serializer.fromJson<DateTime>(json['date']),
      energyLevel: serializer.fromJson<String?>(json['energyLevel']),
      mood: serializer.fromJson<String?>(json['mood']),
      sleepQuality: serializer.fromJson<String?>(json['sleepQuality']),
      stressLevel: serializer.fromJson<String?>(json['stressLevel']),
      movementDone: serializer.fromJson<bool>(json['movementDone']),
      foodWaterOk: serializer.fromJson<bool>(json['foodWaterOk']),
      meditationReflectionDone: serializer.fromJson<bool>(
        json['meditationReflectionDone'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      suggestedWorkload: serializer.fromJson<String?>(
        json['suggestedWorkload'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wellbeingCheckinId': serializer.toJson<String>(wellbeingCheckinId),
      'date': serializer.toJson<DateTime>(date),
      'energyLevel': serializer.toJson<String?>(energyLevel),
      'mood': serializer.toJson<String?>(mood),
      'sleepQuality': serializer.toJson<String?>(sleepQuality),
      'stressLevel': serializer.toJson<String?>(stressLevel),
      'movementDone': serializer.toJson<bool>(movementDone),
      'foodWaterOk': serializer.toJson<bool>(foodWaterOk),
      'meditationReflectionDone': serializer.toJson<bool>(
        meditationReflectionDone,
      ),
      'notes': serializer.toJson<String?>(notes),
      'suggestedWorkload': serializer.toJson<String?>(suggestedWorkload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WellbeingCheckin copyWith({
    String? wellbeingCheckinId,
    DateTime? date,
    Value<String?> energyLevel = const Value.absent(),
    Value<String?> mood = const Value.absent(),
    Value<String?> sleepQuality = const Value.absent(),
    Value<String?> stressLevel = const Value.absent(),
    bool? movementDone,
    bool? foodWaterOk,
    bool? meditationReflectionDone,
    Value<String?> notes = const Value.absent(),
    Value<String?> suggestedWorkload = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WellbeingCheckin(
    wellbeingCheckinId: wellbeingCheckinId ?? this.wellbeingCheckinId,
    date: date ?? this.date,
    energyLevel: energyLevel.present ? energyLevel.value : this.energyLevel,
    mood: mood.present ? mood.value : this.mood,
    sleepQuality: sleepQuality.present ? sleepQuality.value : this.sleepQuality,
    stressLevel: stressLevel.present ? stressLevel.value : this.stressLevel,
    movementDone: movementDone ?? this.movementDone,
    foodWaterOk: foodWaterOk ?? this.foodWaterOk,
    meditationReflectionDone:
        meditationReflectionDone ?? this.meditationReflectionDone,
    notes: notes.present ? notes.value : this.notes,
    suggestedWorkload: suggestedWorkload.present
        ? suggestedWorkload.value
        : this.suggestedWorkload,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WellbeingCheckin copyWithCompanion(WellbeingCheckinsCompanion data) {
    return WellbeingCheckin(
      wellbeingCheckinId: data.wellbeingCheckinId.present
          ? data.wellbeingCheckinId.value
          : this.wellbeingCheckinId,
      date: data.date.present ? data.date.value : this.date,
      energyLevel: data.energyLevel.present
          ? data.energyLevel.value
          : this.energyLevel,
      mood: data.mood.present ? data.mood.value : this.mood,
      sleepQuality: data.sleepQuality.present
          ? data.sleepQuality.value
          : this.sleepQuality,
      stressLevel: data.stressLevel.present
          ? data.stressLevel.value
          : this.stressLevel,
      movementDone: data.movementDone.present
          ? data.movementDone.value
          : this.movementDone,
      foodWaterOk: data.foodWaterOk.present
          ? data.foodWaterOk.value
          : this.foodWaterOk,
      meditationReflectionDone: data.meditationReflectionDone.present
          ? data.meditationReflectionDone.value
          : this.meditationReflectionDone,
      notes: data.notes.present ? data.notes.value : this.notes,
      suggestedWorkload: data.suggestedWorkload.present
          ? data.suggestedWorkload.value
          : this.suggestedWorkload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WellbeingCheckin(')
          ..write('wellbeingCheckinId: $wellbeingCheckinId, ')
          ..write('date: $date, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('mood: $mood, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('stressLevel: $stressLevel, ')
          ..write('movementDone: $movementDone, ')
          ..write('foodWaterOk: $foodWaterOk, ')
          ..write('meditationReflectionDone: $meditationReflectionDone, ')
          ..write('notes: $notes, ')
          ..write('suggestedWorkload: $suggestedWorkload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    wellbeingCheckinId,
    date,
    energyLevel,
    mood,
    sleepQuality,
    stressLevel,
    movementDone,
    foodWaterOk,
    meditationReflectionDone,
    notes,
    suggestedWorkload,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WellbeingCheckin &&
          other.wellbeingCheckinId == this.wellbeingCheckinId &&
          other.date == this.date &&
          other.energyLevel == this.energyLevel &&
          other.mood == this.mood &&
          other.sleepQuality == this.sleepQuality &&
          other.stressLevel == this.stressLevel &&
          other.movementDone == this.movementDone &&
          other.foodWaterOk == this.foodWaterOk &&
          other.meditationReflectionDone == this.meditationReflectionDone &&
          other.notes == this.notes &&
          other.suggestedWorkload == this.suggestedWorkload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WellbeingCheckinsCompanion extends UpdateCompanion<WellbeingCheckin> {
  final Value<String> wellbeingCheckinId;
  final Value<DateTime> date;
  final Value<String?> energyLevel;
  final Value<String?> mood;
  final Value<String?> sleepQuality;
  final Value<String?> stressLevel;
  final Value<bool> movementDone;
  final Value<bool> foodWaterOk;
  final Value<bool> meditationReflectionDone;
  final Value<String?> notes;
  final Value<String?> suggestedWorkload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WellbeingCheckinsCompanion({
    this.wellbeingCheckinId = const Value.absent(),
    this.date = const Value.absent(),
    this.energyLevel = const Value.absent(),
    this.mood = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.stressLevel = const Value.absent(),
    this.movementDone = const Value.absent(),
    this.foodWaterOk = const Value.absent(),
    this.meditationReflectionDone = const Value.absent(),
    this.notes = const Value.absent(),
    this.suggestedWorkload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WellbeingCheckinsCompanion.insert({
    required String wellbeingCheckinId,
    required DateTime date,
    this.energyLevel = const Value.absent(),
    this.mood = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.stressLevel = const Value.absent(),
    this.movementDone = const Value.absent(),
    this.foodWaterOk = const Value.absent(),
    this.meditationReflectionDone = const Value.absent(),
    this.notes = const Value.absent(),
    this.suggestedWorkload = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : wellbeingCheckinId = Value(wellbeingCheckinId),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WellbeingCheckin> custom({
    Expression<String>? wellbeingCheckinId,
    Expression<DateTime>? date,
    Expression<String>? energyLevel,
    Expression<String>? mood,
    Expression<String>? sleepQuality,
    Expression<String>? stressLevel,
    Expression<bool>? movementDone,
    Expression<bool>? foodWaterOk,
    Expression<bool>? meditationReflectionDone,
    Expression<String>? notes,
    Expression<String>? suggestedWorkload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wellbeingCheckinId != null)
        'wellbeing_checkin_id': wellbeingCheckinId,
      if (date != null) 'date': date,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (mood != null) 'mood': mood,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (stressLevel != null) 'stress_level': stressLevel,
      if (movementDone != null) 'movement_done': movementDone,
      if (foodWaterOk != null) 'food_water_ok': foodWaterOk,
      if (meditationReflectionDone != null)
        'meditation_reflection_done': meditationReflectionDone,
      if (notes != null) 'notes': notes,
      if (suggestedWorkload != null) 'suggested_workload': suggestedWorkload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WellbeingCheckinsCompanion copyWith({
    Value<String>? wellbeingCheckinId,
    Value<DateTime>? date,
    Value<String?>? energyLevel,
    Value<String?>? mood,
    Value<String?>? sleepQuality,
    Value<String?>? stressLevel,
    Value<bool>? movementDone,
    Value<bool>? foodWaterOk,
    Value<bool>? meditationReflectionDone,
    Value<String?>? notes,
    Value<String?>? suggestedWorkload,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WellbeingCheckinsCompanion(
      wellbeingCheckinId: wellbeingCheckinId ?? this.wellbeingCheckinId,
      date: date ?? this.date,
      energyLevel: energyLevel ?? this.energyLevel,
      mood: mood ?? this.mood,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
      movementDone: movementDone ?? this.movementDone,
      foodWaterOk: foodWaterOk ?? this.foodWaterOk,
      meditationReflectionDone:
          meditationReflectionDone ?? this.meditationReflectionDone,
      notes: notes ?? this.notes,
      suggestedWorkload: suggestedWorkload ?? this.suggestedWorkload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wellbeingCheckinId.present) {
      map['wellbeing_checkin_id'] = Variable<String>(wellbeingCheckinId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (energyLevel.present) {
      map['energy_level'] = Variable<String>(energyLevel.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<String>(sleepQuality.value);
    }
    if (stressLevel.present) {
      map['stress_level'] = Variable<String>(stressLevel.value);
    }
    if (movementDone.present) {
      map['movement_done'] = Variable<bool>(movementDone.value);
    }
    if (foodWaterOk.present) {
      map['food_water_ok'] = Variable<bool>(foodWaterOk.value);
    }
    if (meditationReflectionDone.present) {
      map['meditation_reflection_done'] = Variable<bool>(
        meditationReflectionDone.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (suggestedWorkload.present) {
      map['suggested_workload'] = Variable<String>(suggestedWorkload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WellbeingCheckinsCompanion(')
          ..write('wellbeingCheckinId: $wellbeingCheckinId, ')
          ..write('date: $date, ')
          ..write('energyLevel: $energyLevel, ')
          ..write('mood: $mood, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('stressLevel: $stressLevel, ')
          ..write('movementDone: $movementDone, ')
          ..write('foodWaterOk: $foodWaterOk, ')
          ..write('meditationReflectionDone: $meditationReflectionDone, ')
          ..write('notes: $notes, ')
          ..write('suggestedWorkload: $suggestedWorkload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InboxItemsTable extends InboxItems
    with TableInfo<$InboxItemsTable, InboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _inboxItemIdMeta = const VerificationMeta(
    'inboxItemId',
  );
  @override
  late final GeneratedColumn<String> inboxItemId = GeneratedColumn<String>(
    'inbox_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('New'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _convertedToTypeMeta = const VerificationMeta(
    'convertedToType',
  );
  @override
  late final GeneratedColumn<String> convertedToType = GeneratedColumn<String>(
    'converted_to_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _convertedToIdMeta = const VerificationMeta(
    'convertedToId',
  );
  @override
  late final GeneratedColumn<String> convertedToId = GeneratedColumn<String>(
    'converted_to_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    inboxItemId,
    title,
    body,
    type,
    projectId,
    status,
    createdAt,
    processedAt,
    convertedToType,
    convertedToId,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('inbox_item_id')) {
      context.handle(
        _inboxItemIdMeta,
        inboxItemId.isAcceptableOrUnknown(
          data['inbox_item_id']!,
          _inboxItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inboxItemIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
      );
    }
    if (data.containsKey('converted_to_type')) {
      context.handle(
        _convertedToTypeMeta,
        convertedToType.isAcceptableOrUnknown(
          data['converted_to_type']!,
          _convertedToTypeMeta,
        ),
      );
    }
    if (data.containsKey('converted_to_id')) {
      context.handle(
        _convertedToIdMeta,
        convertedToId.isAcceptableOrUnknown(
          data['converted_to_id']!,
          _convertedToIdMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {inboxItemId};
  @override
  InboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxItem(
      inboxItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inbox_item_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      ),
      convertedToType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}converted_to_type'],
      ),
      convertedToId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}converted_to_id'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $InboxItemsTable createAlias(String alias) {
    return $InboxItemsTable(attachedDatabase, alias);
  }
}

class InboxItem extends DataClass implements Insertable<InboxItem> {
  final String inboxItemId;
  final String? title;
  final String? body;
  final String? type;
  final String? projectId;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? convertedToType;
  final String? convertedToId;
  final bool isArchived;
  const InboxItem({
    required this.inboxItemId,
    this.title,
    this.body,
    this.type,
    this.projectId,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.convertedToType,
    this.convertedToId,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['inbox_item_id'] = Variable<String>(inboxItemId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    if (!nullToAbsent || convertedToType != null) {
      map['converted_to_type'] = Variable<String>(convertedToType);
    }
    if (!nullToAbsent || convertedToId != null) {
      map['converted_to_id'] = Variable<String>(convertedToId);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  InboxItemsCompanion toCompanion(bool nullToAbsent) {
    return InboxItemsCompanion(
      inboxItemId: Value(inboxItemId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      status: Value(status),
      createdAt: Value(createdAt),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
      convertedToType: convertedToType == null && nullToAbsent
          ? const Value.absent()
          : Value(convertedToType),
      convertedToId: convertedToId == null && nullToAbsent
          ? const Value.absent()
          : Value(convertedToId),
      isArchived: Value(isArchived),
    );
  }

  factory InboxItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxItem(
      inboxItemId: serializer.fromJson<String>(json['inboxItemId']),
      title: serializer.fromJson<String?>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      type: serializer.fromJson<String?>(json['type']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
      convertedToType: serializer.fromJson<String?>(json['convertedToType']),
      convertedToId: serializer.fromJson<String?>(json['convertedToId']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'inboxItemId': serializer.toJson<String>(inboxItemId),
      'title': serializer.toJson<String?>(title),
      'body': serializer.toJson<String?>(body),
      'type': serializer.toJson<String?>(type),
      'projectId': serializer.toJson<String?>(projectId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
      'convertedToType': serializer.toJson<String?>(convertedToType),
      'convertedToId': serializer.toJson<String?>(convertedToId),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  InboxItem copyWith({
    String? inboxItemId,
    Value<String?> title = const Value.absent(),
    Value<String?> body = const Value.absent(),
    Value<String?> type = const Value.absent(),
    Value<String?> projectId = const Value.absent(),
    String? status,
    DateTime? createdAt,
    Value<DateTime?> processedAt = const Value.absent(),
    Value<String?> convertedToType = const Value.absent(),
    Value<String?> convertedToId = const Value.absent(),
    bool? isArchived,
  }) => InboxItem(
    inboxItemId: inboxItemId ?? this.inboxItemId,
    title: title.present ? title.value : this.title,
    body: body.present ? body.value : this.body,
    type: type.present ? type.value : this.type,
    projectId: projectId.present ? projectId.value : this.projectId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    processedAt: processedAt.present ? processedAt.value : this.processedAt,
    convertedToType: convertedToType.present
        ? convertedToType.value
        : this.convertedToType,
    convertedToId: convertedToId.present
        ? convertedToId.value
        : this.convertedToId,
    isArchived: isArchived ?? this.isArchived,
  );
  InboxItem copyWithCompanion(InboxItemsCompanion data) {
    return InboxItem(
      inboxItemId: data.inboxItemId.present
          ? data.inboxItemId.value
          : this.inboxItemId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      type: data.type.present ? data.type.value : this.type,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
      convertedToType: data.convertedToType.present
          ? data.convertedToType.value
          : this.convertedToType,
      convertedToId: data.convertedToId.present
          ? data.convertedToId.value
          : this.convertedToId,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxItem(')
          ..write('inboxItemId: $inboxItemId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('projectId: $projectId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('processedAt: $processedAt, ')
          ..write('convertedToType: $convertedToType, ')
          ..write('convertedToId: $convertedToId, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    inboxItemId,
    title,
    body,
    type,
    projectId,
    status,
    createdAt,
    processedAt,
    convertedToType,
    convertedToId,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxItem &&
          other.inboxItemId == this.inboxItemId &&
          other.title == this.title &&
          other.body == this.body &&
          other.type == this.type &&
          other.projectId == this.projectId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.processedAt == this.processedAt &&
          other.convertedToType == this.convertedToType &&
          other.convertedToId == this.convertedToId &&
          other.isArchived == this.isArchived);
}

class InboxItemsCompanion extends UpdateCompanion<InboxItem> {
  final Value<String> inboxItemId;
  final Value<String?> title;
  final Value<String?> body;
  final Value<String?> type;
  final Value<String?> projectId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> processedAt;
  final Value<String?> convertedToType;
  final Value<String?> convertedToId;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const InboxItemsCompanion({
    this.inboxItemId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.projectId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.convertedToType = const Value.absent(),
    this.convertedToId = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InboxItemsCompanion.insert({
    required String inboxItemId,
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.projectId = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.processedAt = const Value.absent(),
    this.convertedToType = const Value.absent(),
    this.convertedToId = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : inboxItemId = Value(inboxItemId),
       createdAt = Value(createdAt);
  static Insertable<InboxItem> custom({
    Expression<String>? inboxItemId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? type,
    Expression<String>? projectId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? processedAt,
    Expression<String>? convertedToType,
    Expression<String>? convertedToId,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (inboxItemId != null) 'inbox_item_id': inboxItemId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (type != null) 'type': type,
      if (projectId != null) 'project_id': projectId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (processedAt != null) 'processed_at': processedAt,
      if (convertedToType != null) 'converted_to_type': convertedToType,
      if (convertedToId != null) 'converted_to_id': convertedToId,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InboxItemsCompanion copyWith({
    Value<String>? inboxItemId,
    Value<String?>? title,
    Value<String?>? body,
    Value<String?>? type,
    Value<String?>? projectId,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? processedAt,
    Value<String?>? convertedToType,
    Value<String?>? convertedToId,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return InboxItemsCompanion(
      inboxItemId: inboxItemId ?? this.inboxItemId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      convertedToType: convertedToType ?? this.convertedToType,
      convertedToId: convertedToId ?? this.convertedToId,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (inboxItemId.present) {
      map['inbox_item_id'] = Variable<String>(inboxItemId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (convertedToType.present) {
      map['converted_to_type'] = Variable<String>(convertedToType.value);
    }
    if (convertedToId.present) {
      map['converted_to_id'] = Variable<String>(convertedToId.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxItemsCompanion(')
          ..write('inboxItemId: $inboxItemId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('projectId: $projectId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('processedAt: $processedAt, ')
          ..write('convertedToType: $convertedToType, ')
          ..write('convertedToId: $convertedToId, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingsIdMeta = const VerificationMeta(
    'settingsId',
  );
  @override
  late final GeneratedColumn<String> settingsId = GeneratedColumn<String>(
    'settings_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('System'),
  );
  static const VerificationMeta _defaultDashboardViewMeta =
      const VerificationMeta('defaultDashboardView');
  @override
  late final GeneratedColumn<String> defaultDashboardView =
      GeneratedColumn<String>(
        'default_dashboard_view',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _showWellbeingCardMeta = const VerificationMeta(
    'showWellbeingCard',
  );
  @override
  late final GeneratedColumn<bool> showWellbeingCard = GeneratedColumn<bool>(
    'show_wellbeing_card',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_wellbeing_card" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showBusinessCardMeta = const VerificationMeta(
    'showBusinessCard',
  );
  @override
  late final GeneratedColumn<bool> showBusinessCard = GeneratedColumn<bool>(
    'show_business_card',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_business_card" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showLearningCardMeta = const VerificationMeta(
    'showLearningCard',
  );
  @override
  late final GeneratedColumn<bool> showLearningCard = GeneratedColumn<bool>(
    'show_learning_card',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_learning_card" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showContentCardMeta = const VerificationMeta(
    'showContentCard',
  );
  @override
  late final GeneratedColumn<bool> showContentCard = GeneratedColumn<bool>(
    'show_content_card',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_content_card" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showProjectsWorkspaceSnapshotMeta =
      const VerificationMeta('showProjectsWorkspaceSnapshot');
  @override
  late final GeneratedColumn<bool> showProjectsWorkspaceSnapshot =
      GeneratedColumn<bool>(
        'show_projects_workspace_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_projects_workspace_snapshot" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _showDockOverlaysMeta = const VerificationMeta(
    'showDockOverlays',
  );
  @override
  late final GeneratedColumn<bool> showDockOverlays = GeneratedColumn<bool>(
    'show_dock_overlays',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_dock_overlays" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showBackupGuardianDockMeta =
      const VerificationMeta('showBackupGuardianDock');
  @override
  late final GeneratedColumn<bool> showBackupGuardianDock =
      GeneratedColumn<bool>(
        'show_backup_guardian_dock',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_backup_guardian_dock" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _showTreasuryDockMeta = const VerificationMeta(
    'showTreasuryDock',
  );
  @override
  late final GeneratedColumn<bool> showTreasuryDock = GeneratedColumn<bool>(
    'show_treasury_dock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_treasury_dock" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showKnowledgeLibraryDockMeta =
      const VerificationMeta('showKnowledgeLibraryDock');
  @override
  late final GeneratedColumn<bool> showKnowledgeLibraryDock =
      GeneratedColumn<bool>(
        'show_knowledge_library_dock',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_knowledge_library_dock" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _showVoiceConversationDockMeta =
      const VerificationMeta('showVoiceConversationDock');
  @override
  late final GeneratedColumn<bool> showVoiceConversationDock =
      GeneratedColumn<bool>(
        'show_voice_conversation_dock',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_voice_conversation_dock" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _showVoicePresenceChipMeta =
      const VerificationMeta('showVoicePresenceChip');
  @override
  late final GeneratedColumn<bool> showVoicePresenceChip =
      GeneratedColumn<bool>(
        'show_voice_presence_chip',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_voice_presence_chip" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _dailyTopTaskLimitMeta = const VerificationMeta(
    'dailyTopTaskLimit',
  );
  @override
  late final GeneratedColumn<int> dailyTopTaskLimit = GeneratedColumn<int>(
    'daily_top_task_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _voiceRepliesEnabledMeta =
      const VerificationMeta('voiceRepliesEnabled');
  @override
  late final GeneratedColumn<bool> voiceRepliesEnabled = GeneratedColumn<bool>(
    'voice_replies_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voice_replies_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _voiceAssistantEnabledMeta =
      const VerificationMeta('voiceAssistantEnabled');
  @override
  late final GeneratedColumn<bool> voiceAssistantEnabled =
      GeneratedColumn<bool>(
        'voice_assistant_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("voice_assistant_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _voiceStartupGateEnabledMeta =
      const VerificationMeta('voiceStartupGateEnabled');
  @override
  late final GeneratedColumn<bool> voiceStartupGateEnabled =
      GeneratedColumn<bool>(
        'voice_startup_gate_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("voice_startup_gate_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _preferredTtsVoiceNameMeta =
      const VerificationMeta('preferredTtsVoiceName');
  @override
  late final GeneratedColumn<String> preferredTtsVoiceName =
      GeneratedColumn<String>(
        'preferred_tts_voice_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _preferredTtsVoiceLocaleMeta =
      const VerificationMeta('preferredTtsVoiceLocale');
  @override
  late final GeneratedColumn<String> preferredTtsVoiceLocale =
      GeneratedColumn<String>(
        'preferred_tts_voice_locale',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _preferredTtsVoiceGenderMeta =
      const VerificationMeta('preferredTtsVoiceGender');
  @override
  late final GeneratedColumn<String> preferredTtsVoiceGender =
      GeneratedColumn<String>(
        'preferred_tts_voice_gender',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _preferredTtsVoiceIdentifierMeta =
      const VerificationMeta('preferredTtsVoiceIdentifier');
  @override
  late final GeneratedColumn<String> preferredTtsVoiceIdentifier =
      GeneratedColumn<String>(
        'preferred_tts_voice_identifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _preferredTtsVoiceRateMeta =
      const VerificationMeta('preferredTtsVoiceRate');
  @override
  late final GeneratedColumn<double> preferredTtsVoiceRate =
      GeneratedColumn<double>(
        'preferred_tts_voice_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.5),
      );
  static const VerificationMeta _preferredTtsVoicePitchMeta =
      const VerificationMeta('preferredTtsVoicePitch');
  @override
  late final GeneratedColumn<double> preferredTtsVoicePitch =
      GeneratedColumn<double>(
        'preferred_tts_voice_pitch',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    settingsId,
    themeMode,
    defaultDashboardView,
    showWellbeingCard,
    showBusinessCard,
    showLearningCard,
    showContentCard,
    showProjectsWorkspaceSnapshot,
    showDockOverlays,
    showBackupGuardianDock,
    showTreasuryDock,
    showKnowledgeLibraryDock,
    showVoiceConversationDock,
    showVoicePresenceChip,
    dailyTopTaskLimit,
    voiceRepliesEnabled,
    voiceAssistantEnabled,
    voiceStartupGateEnabled,
    preferredTtsVoiceName,
    preferredTtsVoiceLocale,
    preferredTtsVoiceGender,
    preferredTtsVoiceIdentifier,
    preferredTtsVoiceRate,
    preferredTtsVoicePitch,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('settings_id')) {
      context.handle(
        _settingsIdMeta,
        settingsId.isAcceptableOrUnknown(data['settings_id']!, _settingsIdMeta),
      );
    } else if (isInserting) {
      context.missing(_settingsIdMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('default_dashboard_view')) {
      context.handle(
        _defaultDashboardViewMeta,
        defaultDashboardView.isAcceptableOrUnknown(
          data['default_dashboard_view']!,
          _defaultDashboardViewMeta,
        ),
      );
    }
    if (data.containsKey('show_wellbeing_card')) {
      context.handle(
        _showWellbeingCardMeta,
        showWellbeingCard.isAcceptableOrUnknown(
          data['show_wellbeing_card']!,
          _showWellbeingCardMeta,
        ),
      );
    }
    if (data.containsKey('show_business_card')) {
      context.handle(
        _showBusinessCardMeta,
        showBusinessCard.isAcceptableOrUnknown(
          data['show_business_card']!,
          _showBusinessCardMeta,
        ),
      );
    }
    if (data.containsKey('show_learning_card')) {
      context.handle(
        _showLearningCardMeta,
        showLearningCard.isAcceptableOrUnknown(
          data['show_learning_card']!,
          _showLearningCardMeta,
        ),
      );
    }
    if (data.containsKey('show_content_card')) {
      context.handle(
        _showContentCardMeta,
        showContentCard.isAcceptableOrUnknown(
          data['show_content_card']!,
          _showContentCardMeta,
        ),
      );
    }
    if (data.containsKey('show_projects_workspace_snapshot')) {
      context.handle(
        _showProjectsWorkspaceSnapshotMeta,
        showProjectsWorkspaceSnapshot.isAcceptableOrUnknown(
          data['show_projects_workspace_snapshot']!,
          _showProjectsWorkspaceSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('show_dock_overlays')) {
      context.handle(
        _showDockOverlaysMeta,
        showDockOverlays.isAcceptableOrUnknown(
          data['show_dock_overlays']!,
          _showDockOverlaysMeta,
        ),
      );
    }
    if (data.containsKey('show_backup_guardian_dock')) {
      context.handle(
        _showBackupGuardianDockMeta,
        showBackupGuardianDock.isAcceptableOrUnknown(
          data['show_backup_guardian_dock']!,
          _showBackupGuardianDockMeta,
        ),
      );
    }
    if (data.containsKey('show_treasury_dock')) {
      context.handle(
        _showTreasuryDockMeta,
        showTreasuryDock.isAcceptableOrUnknown(
          data['show_treasury_dock']!,
          _showTreasuryDockMeta,
        ),
      );
    }
    if (data.containsKey('show_knowledge_library_dock')) {
      context.handle(
        _showKnowledgeLibraryDockMeta,
        showKnowledgeLibraryDock.isAcceptableOrUnknown(
          data['show_knowledge_library_dock']!,
          _showKnowledgeLibraryDockMeta,
        ),
      );
    }
    if (data.containsKey('show_voice_conversation_dock')) {
      context.handle(
        _showVoiceConversationDockMeta,
        showVoiceConversationDock.isAcceptableOrUnknown(
          data['show_voice_conversation_dock']!,
          _showVoiceConversationDockMeta,
        ),
      );
    }
    if (data.containsKey('show_voice_presence_chip')) {
      context.handle(
        _showVoicePresenceChipMeta,
        showVoicePresenceChip.isAcceptableOrUnknown(
          data['show_voice_presence_chip']!,
          _showVoicePresenceChipMeta,
        ),
      );
    }
    if (data.containsKey('daily_top_task_limit')) {
      context.handle(
        _dailyTopTaskLimitMeta,
        dailyTopTaskLimit.isAcceptableOrUnknown(
          data['daily_top_task_limit']!,
          _dailyTopTaskLimitMeta,
        ),
      );
    }
    if (data.containsKey('voice_replies_enabled')) {
      context.handle(
        _voiceRepliesEnabledMeta,
        voiceRepliesEnabled.isAcceptableOrUnknown(
          data['voice_replies_enabled']!,
          _voiceRepliesEnabledMeta,
        ),
      );
    }
    if (data.containsKey('voice_assistant_enabled')) {
      context.handle(
        _voiceAssistantEnabledMeta,
        voiceAssistantEnabled.isAcceptableOrUnknown(
          data['voice_assistant_enabled']!,
          _voiceAssistantEnabledMeta,
        ),
      );
    }
    if (data.containsKey('voice_startup_gate_enabled')) {
      context.handle(
        _voiceStartupGateEnabledMeta,
        voiceStartupGateEnabled.isAcceptableOrUnknown(
          data['voice_startup_gate_enabled']!,
          _voiceStartupGateEnabledMeta,
        ),
      );
    }
    if (data.containsKey('preferred_tts_voice_name')) {
      context.handle(
        _preferredTtsVoiceNameMeta,
        preferredTtsVoiceName.isAcceptableOrUnknown(
          data['preferred_tts_voice_name']!,
          _preferredTtsVoiceNameMeta,
        ),
      );
    }
    if (data.containsKey('preferred_tts_voice_locale')) {
      context.handle(
        _preferredTtsVoiceLocaleMeta,
        preferredTtsVoiceLocale.isAcceptableOrUnknown(
          data['preferred_tts_voice_locale']!,
          _preferredTtsVoiceLocaleMeta,
        ),
      );
    }
    if (data.containsKey('preferred_tts_voice_gender')) {
      context.handle(
        _preferredTtsVoiceGenderMeta,
        preferredTtsVoiceGender.isAcceptableOrUnknown(
          data['preferred_tts_voice_gender']!,
          _preferredTtsVoiceGenderMeta,
        ),
      );
    }
    if (data.containsKey('preferred_tts_voice_identifier')) {
      context.handle(
        _preferredTtsVoiceIdentifierMeta,
        preferredTtsVoiceIdentifier.isAcceptableOrUnknown(
          data['preferred_tts_voice_identifier']!,
          _preferredTtsVoiceIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('preferred_tts_voice_rate')) {
      context.handle(
        _preferredTtsVoiceRateMeta,
        preferredTtsVoiceRate.isAcceptableOrUnknown(
          data['preferred_tts_voice_rate']!,
          _preferredTtsVoiceRateMeta,
        ),
      );
    }
    if (data.containsKey('preferred_tts_voice_pitch')) {
      context.handle(
        _preferredTtsVoicePitchMeta,
        preferredTtsVoicePitch.isAcceptableOrUnknown(
          data['preferred_tts_voice_pitch']!,
          _preferredTtsVoicePitchMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingsId};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      settingsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      defaultDashboardView: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_dashboard_view'],
      ),
      showWellbeingCard: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_wellbeing_card'],
      )!,
      showBusinessCard: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_business_card'],
      )!,
      showLearningCard: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_learning_card'],
      )!,
      showContentCard: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_content_card'],
      )!,
      showProjectsWorkspaceSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_projects_workspace_snapshot'],
      )!,
      showDockOverlays: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_dock_overlays'],
      )!,
      showBackupGuardianDock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_backup_guardian_dock'],
      )!,
      showTreasuryDock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_treasury_dock'],
      )!,
      showKnowledgeLibraryDock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_knowledge_library_dock'],
      )!,
      showVoiceConversationDock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_voice_conversation_dock'],
      )!,
      showVoicePresenceChip: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_voice_presence_chip'],
      )!,
      dailyTopTaskLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_top_task_limit'],
      )!,
      voiceRepliesEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voice_replies_enabled'],
      )!,
      voiceAssistantEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voice_assistant_enabled'],
      )!,
      voiceStartupGateEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voice_startup_gate_enabled'],
      )!,
      preferredTtsVoiceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_tts_voice_name'],
      ),
      preferredTtsVoiceLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_tts_voice_locale'],
      ),
      preferredTtsVoiceGender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_tts_voice_gender'],
      ),
      preferredTtsVoiceIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_tts_voice_identifier'],
      ),
      preferredTtsVoiceRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}preferred_tts_voice_rate'],
      )!,
      preferredTtsVoicePitch: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}preferred_tts_voice_pitch'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String settingsId;
  final String themeMode;
  final String? defaultDashboardView;
  final bool showWellbeingCard;
  final bool showBusinessCard;
  final bool showLearningCard;
  final bool showContentCard;
  final bool showProjectsWorkspaceSnapshot;
  final bool showDockOverlays;
  final bool showBackupGuardianDock;
  final bool showTreasuryDock;
  final bool showKnowledgeLibraryDock;
  final bool showVoiceConversationDock;
  final bool showVoicePresenceChip;
  final int dailyTopTaskLimit;
  final bool voiceRepliesEnabled;
  final bool voiceAssistantEnabled;
  final bool voiceStartupGateEnabled;
  final String? preferredTtsVoiceName;
  final String? preferredTtsVoiceLocale;
  final String? preferredTtsVoiceGender;
  final String? preferredTtsVoiceIdentifier;
  final double preferredTtsVoiceRate;
  final double preferredTtsVoicePitch;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AppSetting({
    required this.settingsId,
    required this.themeMode,
    this.defaultDashboardView,
    required this.showWellbeingCard,
    required this.showBusinessCard,
    required this.showLearningCard,
    required this.showContentCard,
    required this.showProjectsWorkspaceSnapshot,
    required this.showDockOverlays,
    required this.showBackupGuardianDock,
    required this.showTreasuryDock,
    required this.showKnowledgeLibraryDock,
    required this.showVoiceConversationDock,
    required this.showVoicePresenceChip,
    required this.dailyTopTaskLimit,
    required this.voiceRepliesEnabled,
    required this.voiceAssistantEnabled,
    required this.voiceStartupGateEnabled,
    this.preferredTtsVoiceName,
    this.preferredTtsVoiceLocale,
    this.preferredTtsVoiceGender,
    this.preferredTtsVoiceIdentifier,
    required this.preferredTtsVoiceRate,
    required this.preferredTtsVoicePitch,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['settings_id'] = Variable<String>(settingsId);
    map['theme_mode'] = Variable<String>(themeMode);
    if (!nullToAbsent || defaultDashboardView != null) {
      map['default_dashboard_view'] = Variable<String>(defaultDashboardView);
    }
    map['show_wellbeing_card'] = Variable<bool>(showWellbeingCard);
    map['show_business_card'] = Variable<bool>(showBusinessCard);
    map['show_learning_card'] = Variable<bool>(showLearningCard);
    map['show_content_card'] = Variable<bool>(showContentCard);
    map['show_projects_workspace_snapshot'] = Variable<bool>(
      showProjectsWorkspaceSnapshot,
    );
    map['show_dock_overlays'] = Variable<bool>(showDockOverlays);
    map['show_backup_guardian_dock'] = Variable<bool>(showBackupGuardianDock);
    map['show_treasury_dock'] = Variable<bool>(showTreasuryDock);
    map['show_knowledge_library_dock'] = Variable<bool>(
      showKnowledgeLibraryDock,
    );
    map['show_voice_conversation_dock'] = Variable<bool>(
      showVoiceConversationDock,
    );
    map['show_voice_presence_chip'] = Variable<bool>(showVoicePresenceChip);
    map['daily_top_task_limit'] = Variable<int>(dailyTopTaskLimit);
    map['voice_replies_enabled'] = Variable<bool>(voiceRepliesEnabled);
    map['voice_assistant_enabled'] = Variable<bool>(voiceAssistantEnabled);
    map['voice_startup_gate_enabled'] = Variable<bool>(voiceStartupGateEnabled);
    if (!nullToAbsent || preferredTtsVoiceName != null) {
      map['preferred_tts_voice_name'] = Variable<String>(preferredTtsVoiceName);
    }
    if (!nullToAbsent || preferredTtsVoiceLocale != null) {
      map['preferred_tts_voice_locale'] = Variable<String>(
        preferredTtsVoiceLocale,
      );
    }
    if (!nullToAbsent || preferredTtsVoiceGender != null) {
      map['preferred_tts_voice_gender'] = Variable<String>(
        preferredTtsVoiceGender,
      );
    }
    if (!nullToAbsent || preferredTtsVoiceIdentifier != null) {
      map['preferred_tts_voice_identifier'] = Variable<String>(
        preferredTtsVoiceIdentifier,
      );
    }
    map['preferred_tts_voice_rate'] = Variable<double>(preferredTtsVoiceRate);
    map['preferred_tts_voice_pitch'] = Variable<double>(preferredTtsVoicePitch);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      settingsId: Value(settingsId),
      themeMode: Value(themeMode),
      defaultDashboardView: defaultDashboardView == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultDashboardView),
      showWellbeingCard: Value(showWellbeingCard),
      showBusinessCard: Value(showBusinessCard),
      showLearningCard: Value(showLearningCard),
      showContentCard: Value(showContentCard),
      showProjectsWorkspaceSnapshot: Value(showProjectsWorkspaceSnapshot),
      showDockOverlays: Value(showDockOverlays),
      showBackupGuardianDock: Value(showBackupGuardianDock),
      showTreasuryDock: Value(showTreasuryDock),
      showKnowledgeLibraryDock: Value(showKnowledgeLibraryDock),
      showVoiceConversationDock: Value(showVoiceConversationDock),
      showVoicePresenceChip: Value(showVoicePresenceChip),
      dailyTopTaskLimit: Value(dailyTopTaskLimit),
      voiceRepliesEnabled: Value(voiceRepliesEnabled),
      voiceAssistantEnabled: Value(voiceAssistantEnabled),
      voiceStartupGateEnabled: Value(voiceStartupGateEnabled),
      preferredTtsVoiceName: preferredTtsVoiceName == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredTtsVoiceName),
      preferredTtsVoiceLocale: preferredTtsVoiceLocale == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredTtsVoiceLocale),
      preferredTtsVoiceGender: preferredTtsVoiceGender == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredTtsVoiceGender),
      preferredTtsVoiceIdentifier:
          preferredTtsVoiceIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredTtsVoiceIdentifier),
      preferredTtsVoiceRate: Value(preferredTtsVoiceRate),
      preferredTtsVoicePitch: Value(preferredTtsVoicePitch),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      settingsId: serializer.fromJson<String>(json['settingsId']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      defaultDashboardView: serializer.fromJson<String?>(
        json['defaultDashboardView'],
      ),
      showWellbeingCard: serializer.fromJson<bool>(json['showWellbeingCard']),
      showBusinessCard: serializer.fromJson<bool>(json['showBusinessCard']),
      showLearningCard: serializer.fromJson<bool>(json['showLearningCard']),
      showContentCard: serializer.fromJson<bool>(json['showContentCard']),
      showProjectsWorkspaceSnapshot: serializer.fromJson<bool>(
        json['showProjectsWorkspaceSnapshot'],
      ),
      showDockOverlays: serializer.fromJson<bool>(json['showDockOverlays']),
      showBackupGuardianDock: serializer.fromJson<bool>(
        json['showBackupGuardianDock'],
      ),
      showTreasuryDock: serializer.fromJson<bool>(json['showTreasuryDock']),
      showKnowledgeLibraryDock: serializer.fromJson<bool>(
        json['showKnowledgeLibraryDock'],
      ),
      showVoiceConversationDock: serializer.fromJson<bool>(
        json['showVoiceConversationDock'],
      ),
      showVoicePresenceChip: serializer.fromJson<bool>(
        json['showVoicePresenceChip'],
      ),
      dailyTopTaskLimit: serializer.fromJson<int>(json['dailyTopTaskLimit']),
      voiceRepliesEnabled: serializer.fromJson<bool>(
        json['voiceRepliesEnabled'],
      ),
      voiceAssistantEnabled: serializer.fromJson<bool>(
        json['voiceAssistantEnabled'],
      ),
      voiceStartupGateEnabled: serializer.fromJson<bool>(
        json['voiceStartupGateEnabled'],
      ),
      preferredTtsVoiceName: serializer.fromJson<String?>(
        json['preferredTtsVoiceName'],
      ),
      preferredTtsVoiceLocale: serializer.fromJson<String?>(
        json['preferredTtsVoiceLocale'],
      ),
      preferredTtsVoiceGender: serializer.fromJson<String?>(
        json['preferredTtsVoiceGender'],
      ),
      preferredTtsVoiceIdentifier: serializer.fromJson<String?>(
        json['preferredTtsVoiceIdentifier'],
      ),
      preferredTtsVoiceRate: serializer.fromJson<double>(
        json['preferredTtsVoiceRate'],
      ),
      preferredTtsVoicePitch: serializer.fromJson<double>(
        json['preferredTtsVoicePitch'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingsId': serializer.toJson<String>(settingsId),
      'themeMode': serializer.toJson<String>(themeMode),
      'defaultDashboardView': serializer.toJson<String?>(defaultDashboardView),
      'showWellbeingCard': serializer.toJson<bool>(showWellbeingCard),
      'showBusinessCard': serializer.toJson<bool>(showBusinessCard),
      'showLearningCard': serializer.toJson<bool>(showLearningCard),
      'showContentCard': serializer.toJson<bool>(showContentCard),
      'showProjectsWorkspaceSnapshot': serializer.toJson<bool>(
        showProjectsWorkspaceSnapshot,
      ),
      'showDockOverlays': serializer.toJson<bool>(showDockOverlays),
      'showBackupGuardianDock': serializer.toJson<bool>(showBackupGuardianDock),
      'showTreasuryDock': serializer.toJson<bool>(showTreasuryDock),
      'showKnowledgeLibraryDock': serializer.toJson<bool>(
        showKnowledgeLibraryDock,
      ),
      'showVoiceConversationDock': serializer.toJson<bool>(
        showVoiceConversationDock,
      ),
      'showVoicePresenceChip': serializer.toJson<bool>(showVoicePresenceChip),
      'dailyTopTaskLimit': serializer.toJson<int>(dailyTopTaskLimit),
      'voiceRepliesEnabled': serializer.toJson<bool>(voiceRepliesEnabled),
      'voiceAssistantEnabled': serializer.toJson<bool>(voiceAssistantEnabled),
      'voiceStartupGateEnabled': serializer.toJson<bool>(
        voiceStartupGateEnabled,
      ),
      'preferredTtsVoiceName': serializer.toJson<String?>(
        preferredTtsVoiceName,
      ),
      'preferredTtsVoiceLocale': serializer.toJson<String?>(
        preferredTtsVoiceLocale,
      ),
      'preferredTtsVoiceGender': serializer.toJson<String?>(
        preferredTtsVoiceGender,
      ),
      'preferredTtsVoiceIdentifier': serializer.toJson<String?>(
        preferredTtsVoiceIdentifier,
      ),
      'preferredTtsVoiceRate': serializer.toJson<double>(preferredTtsVoiceRate),
      'preferredTtsVoicePitch': serializer.toJson<double>(
        preferredTtsVoicePitch,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    String? settingsId,
    String? themeMode,
    Value<String?> defaultDashboardView = const Value.absent(),
    bool? showWellbeingCard,
    bool? showBusinessCard,
    bool? showLearningCard,
    bool? showContentCard,
    bool? showProjectsWorkspaceSnapshot,
    bool? showDockOverlays,
    bool? showBackupGuardianDock,
    bool? showTreasuryDock,
    bool? showKnowledgeLibraryDock,
    bool? showVoiceConversationDock,
    bool? showVoicePresenceChip,
    int? dailyTopTaskLimit,
    bool? voiceRepliesEnabled,
    bool? voiceAssistantEnabled,
    bool? voiceStartupGateEnabled,
    Value<String?> preferredTtsVoiceName = const Value.absent(),
    Value<String?> preferredTtsVoiceLocale = const Value.absent(),
    Value<String?> preferredTtsVoiceGender = const Value.absent(),
    Value<String?> preferredTtsVoiceIdentifier = const Value.absent(),
    double? preferredTtsVoiceRate,
    double? preferredTtsVoicePitch,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AppSetting(
    settingsId: settingsId ?? this.settingsId,
    themeMode: themeMode ?? this.themeMode,
    defaultDashboardView: defaultDashboardView.present
        ? defaultDashboardView.value
        : this.defaultDashboardView,
    showWellbeingCard: showWellbeingCard ?? this.showWellbeingCard,
    showBusinessCard: showBusinessCard ?? this.showBusinessCard,
    showLearningCard: showLearningCard ?? this.showLearningCard,
    showContentCard: showContentCard ?? this.showContentCard,
    showProjectsWorkspaceSnapshot:
        showProjectsWorkspaceSnapshot ?? this.showProjectsWorkspaceSnapshot,
    showDockOverlays: showDockOverlays ?? this.showDockOverlays,
    showBackupGuardianDock:
        showBackupGuardianDock ?? this.showBackupGuardianDock,
    showTreasuryDock: showTreasuryDock ?? this.showTreasuryDock,
    showKnowledgeLibraryDock:
        showKnowledgeLibraryDock ?? this.showKnowledgeLibraryDock,
    showVoiceConversationDock:
        showVoiceConversationDock ?? this.showVoiceConversationDock,
    showVoicePresenceChip: showVoicePresenceChip ?? this.showVoicePresenceChip,
    dailyTopTaskLimit: dailyTopTaskLimit ?? this.dailyTopTaskLimit,
    voiceRepliesEnabled: voiceRepliesEnabled ?? this.voiceRepliesEnabled,
    voiceAssistantEnabled: voiceAssistantEnabled ?? this.voiceAssistantEnabled,
    voiceStartupGateEnabled:
        voiceStartupGateEnabled ?? this.voiceStartupGateEnabled,
    preferredTtsVoiceName: preferredTtsVoiceName.present
        ? preferredTtsVoiceName.value
        : this.preferredTtsVoiceName,
    preferredTtsVoiceLocale: preferredTtsVoiceLocale.present
        ? preferredTtsVoiceLocale.value
        : this.preferredTtsVoiceLocale,
    preferredTtsVoiceGender: preferredTtsVoiceGender.present
        ? preferredTtsVoiceGender.value
        : this.preferredTtsVoiceGender,
    preferredTtsVoiceIdentifier: preferredTtsVoiceIdentifier.present
        ? preferredTtsVoiceIdentifier.value
        : this.preferredTtsVoiceIdentifier,
    preferredTtsVoiceRate: preferredTtsVoiceRate ?? this.preferredTtsVoiceRate,
    preferredTtsVoicePitch:
        preferredTtsVoicePitch ?? this.preferredTtsVoicePitch,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      settingsId: data.settingsId.present
          ? data.settingsId.value
          : this.settingsId,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      defaultDashboardView: data.defaultDashboardView.present
          ? data.defaultDashboardView.value
          : this.defaultDashboardView,
      showWellbeingCard: data.showWellbeingCard.present
          ? data.showWellbeingCard.value
          : this.showWellbeingCard,
      showBusinessCard: data.showBusinessCard.present
          ? data.showBusinessCard.value
          : this.showBusinessCard,
      showLearningCard: data.showLearningCard.present
          ? data.showLearningCard.value
          : this.showLearningCard,
      showContentCard: data.showContentCard.present
          ? data.showContentCard.value
          : this.showContentCard,
      showProjectsWorkspaceSnapshot: data.showProjectsWorkspaceSnapshot.present
          ? data.showProjectsWorkspaceSnapshot.value
          : this.showProjectsWorkspaceSnapshot,
      showDockOverlays: data.showDockOverlays.present
          ? data.showDockOverlays.value
          : this.showDockOverlays,
      showBackupGuardianDock: data.showBackupGuardianDock.present
          ? data.showBackupGuardianDock.value
          : this.showBackupGuardianDock,
      showTreasuryDock: data.showTreasuryDock.present
          ? data.showTreasuryDock.value
          : this.showTreasuryDock,
      showKnowledgeLibraryDock: data.showKnowledgeLibraryDock.present
          ? data.showKnowledgeLibraryDock.value
          : this.showKnowledgeLibraryDock,
      showVoiceConversationDock: data.showVoiceConversationDock.present
          ? data.showVoiceConversationDock.value
          : this.showVoiceConversationDock,
      showVoicePresenceChip: data.showVoicePresenceChip.present
          ? data.showVoicePresenceChip.value
          : this.showVoicePresenceChip,
      dailyTopTaskLimit: data.dailyTopTaskLimit.present
          ? data.dailyTopTaskLimit.value
          : this.dailyTopTaskLimit,
      voiceRepliesEnabled: data.voiceRepliesEnabled.present
          ? data.voiceRepliesEnabled.value
          : this.voiceRepliesEnabled,
      voiceAssistantEnabled: data.voiceAssistantEnabled.present
          ? data.voiceAssistantEnabled.value
          : this.voiceAssistantEnabled,
      voiceStartupGateEnabled: data.voiceStartupGateEnabled.present
          ? data.voiceStartupGateEnabled.value
          : this.voiceStartupGateEnabled,
      preferredTtsVoiceName: data.preferredTtsVoiceName.present
          ? data.preferredTtsVoiceName.value
          : this.preferredTtsVoiceName,
      preferredTtsVoiceLocale: data.preferredTtsVoiceLocale.present
          ? data.preferredTtsVoiceLocale.value
          : this.preferredTtsVoiceLocale,
      preferredTtsVoiceGender: data.preferredTtsVoiceGender.present
          ? data.preferredTtsVoiceGender.value
          : this.preferredTtsVoiceGender,
      preferredTtsVoiceIdentifier: data.preferredTtsVoiceIdentifier.present
          ? data.preferredTtsVoiceIdentifier.value
          : this.preferredTtsVoiceIdentifier,
      preferredTtsVoiceRate: data.preferredTtsVoiceRate.present
          ? data.preferredTtsVoiceRate.value
          : this.preferredTtsVoiceRate,
      preferredTtsVoicePitch: data.preferredTtsVoicePitch.present
          ? data.preferredTtsVoicePitch.value
          : this.preferredTtsVoicePitch,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('settingsId: $settingsId, ')
          ..write('themeMode: $themeMode, ')
          ..write('defaultDashboardView: $defaultDashboardView, ')
          ..write('showWellbeingCard: $showWellbeingCard, ')
          ..write('showBusinessCard: $showBusinessCard, ')
          ..write('showLearningCard: $showLearningCard, ')
          ..write('showContentCard: $showContentCard, ')
          ..write(
            'showProjectsWorkspaceSnapshot: $showProjectsWorkspaceSnapshot, ',
          )
          ..write('showDockOverlays: $showDockOverlays, ')
          ..write('showBackupGuardianDock: $showBackupGuardianDock, ')
          ..write('showTreasuryDock: $showTreasuryDock, ')
          ..write('showKnowledgeLibraryDock: $showKnowledgeLibraryDock, ')
          ..write('showVoiceConversationDock: $showVoiceConversationDock, ')
          ..write('showVoicePresenceChip: $showVoicePresenceChip, ')
          ..write('dailyTopTaskLimit: $dailyTopTaskLimit, ')
          ..write('voiceRepliesEnabled: $voiceRepliesEnabled, ')
          ..write('voiceAssistantEnabled: $voiceAssistantEnabled, ')
          ..write('voiceStartupGateEnabled: $voiceStartupGateEnabled, ')
          ..write('preferredTtsVoiceName: $preferredTtsVoiceName, ')
          ..write('preferredTtsVoiceLocale: $preferredTtsVoiceLocale, ')
          ..write('preferredTtsVoiceGender: $preferredTtsVoiceGender, ')
          ..write('preferredTtsVoiceIdentifier: $preferredTtsVoiceIdentifier, ')
          ..write('preferredTtsVoiceRate: $preferredTtsVoiceRate, ')
          ..write('preferredTtsVoicePitch: $preferredTtsVoicePitch, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    settingsId,
    themeMode,
    defaultDashboardView,
    showWellbeingCard,
    showBusinessCard,
    showLearningCard,
    showContentCard,
    showProjectsWorkspaceSnapshot,
    showDockOverlays,
    showBackupGuardianDock,
    showTreasuryDock,
    showKnowledgeLibraryDock,
    showVoiceConversationDock,
    showVoicePresenceChip,
    dailyTopTaskLimit,
    voiceRepliesEnabled,
    voiceAssistantEnabled,
    voiceStartupGateEnabled,
    preferredTtsVoiceName,
    preferredTtsVoiceLocale,
    preferredTtsVoiceGender,
    preferredTtsVoiceIdentifier,
    preferredTtsVoiceRate,
    preferredTtsVoicePitch,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.settingsId == this.settingsId &&
          other.themeMode == this.themeMode &&
          other.defaultDashboardView == this.defaultDashboardView &&
          other.showWellbeingCard == this.showWellbeingCard &&
          other.showBusinessCard == this.showBusinessCard &&
          other.showLearningCard == this.showLearningCard &&
          other.showContentCard == this.showContentCard &&
          other.showProjectsWorkspaceSnapshot ==
              this.showProjectsWorkspaceSnapshot &&
          other.showDockOverlays == this.showDockOverlays &&
          other.showBackupGuardianDock == this.showBackupGuardianDock &&
          other.showTreasuryDock == this.showTreasuryDock &&
          other.showKnowledgeLibraryDock == this.showKnowledgeLibraryDock &&
          other.showVoiceConversationDock == this.showVoiceConversationDock &&
          other.showVoicePresenceChip == this.showVoicePresenceChip &&
          other.dailyTopTaskLimit == this.dailyTopTaskLimit &&
          other.voiceRepliesEnabled == this.voiceRepliesEnabled &&
          other.voiceAssistantEnabled == this.voiceAssistantEnabled &&
          other.voiceStartupGateEnabled == this.voiceStartupGateEnabled &&
          other.preferredTtsVoiceName == this.preferredTtsVoiceName &&
          other.preferredTtsVoiceLocale == this.preferredTtsVoiceLocale &&
          other.preferredTtsVoiceGender == this.preferredTtsVoiceGender &&
          other.preferredTtsVoiceIdentifier ==
              this.preferredTtsVoiceIdentifier &&
          other.preferredTtsVoiceRate == this.preferredTtsVoiceRate &&
          other.preferredTtsVoicePitch == this.preferredTtsVoicePitch &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> settingsId;
  final Value<String> themeMode;
  final Value<String?> defaultDashboardView;
  final Value<bool> showWellbeingCard;
  final Value<bool> showBusinessCard;
  final Value<bool> showLearningCard;
  final Value<bool> showContentCard;
  final Value<bool> showProjectsWorkspaceSnapshot;
  final Value<bool> showDockOverlays;
  final Value<bool> showBackupGuardianDock;
  final Value<bool> showTreasuryDock;
  final Value<bool> showKnowledgeLibraryDock;
  final Value<bool> showVoiceConversationDock;
  final Value<bool> showVoicePresenceChip;
  final Value<int> dailyTopTaskLimit;
  final Value<bool> voiceRepliesEnabled;
  final Value<bool> voiceAssistantEnabled;
  final Value<bool> voiceStartupGateEnabled;
  final Value<String?> preferredTtsVoiceName;
  final Value<String?> preferredTtsVoiceLocale;
  final Value<String?> preferredTtsVoiceGender;
  final Value<String?> preferredTtsVoiceIdentifier;
  final Value<double> preferredTtsVoiceRate;
  final Value<double> preferredTtsVoicePitch;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.settingsId = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.defaultDashboardView = const Value.absent(),
    this.showWellbeingCard = const Value.absent(),
    this.showBusinessCard = const Value.absent(),
    this.showLearningCard = const Value.absent(),
    this.showContentCard = const Value.absent(),
    this.showProjectsWorkspaceSnapshot = const Value.absent(),
    this.showDockOverlays = const Value.absent(),
    this.showBackupGuardianDock = const Value.absent(),
    this.showTreasuryDock = const Value.absent(),
    this.showKnowledgeLibraryDock = const Value.absent(),
    this.showVoiceConversationDock = const Value.absent(),
    this.showVoicePresenceChip = const Value.absent(),
    this.dailyTopTaskLimit = const Value.absent(),
    this.voiceRepliesEnabled = const Value.absent(),
    this.voiceAssistantEnabled = const Value.absent(),
    this.voiceStartupGateEnabled = const Value.absent(),
    this.preferredTtsVoiceName = const Value.absent(),
    this.preferredTtsVoiceLocale = const Value.absent(),
    this.preferredTtsVoiceGender = const Value.absent(),
    this.preferredTtsVoiceIdentifier = const Value.absent(),
    this.preferredTtsVoiceRate = const Value.absent(),
    this.preferredTtsVoicePitch = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String settingsId,
    this.themeMode = const Value.absent(),
    this.defaultDashboardView = const Value.absent(),
    this.showWellbeingCard = const Value.absent(),
    this.showBusinessCard = const Value.absent(),
    this.showLearningCard = const Value.absent(),
    this.showContentCard = const Value.absent(),
    this.showProjectsWorkspaceSnapshot = const Value.absent(),
    this.showDockOverlays = const Value.absent(),
    this.showBackupGuardianDock = const Value.absent(),
    this.showTreasuryDock = const Value.absent(),
    this.showKnowledgeLibraryDock = const Value.absent(),
    this.showVoiceConversationDock = const Value.absent(),
    this.showVoicePresenceChip = const Value.absent(),
    this.dailyTopTaskLimit = const Value.absent(),
    this.voiceRepliesEnabled = const Value.absent(),
    this.voiceAssistantEnabled = const Value.absent(),
    this.voiceStartupGateEnabled = const Value.absent(),
    this.preferredTtsVoiceName = const Value.absent(),
    this.preferredTtsVoiceLocale = const Value.absent(),
    this.preferredTtsVoiceGender = const Value.absent(),
    this.preferredTtsVoiceIdentifier = const Value.absent(),
    this.preferredTtsVoiceRate = const Value.absent(),
    this.preferredTtsVoicePitch = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : settingsId = Value(settingsId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? settingsId,
    Expression<String>? themeMode,
    Expression<String>? defaultDashboardView,
    Expression<bool>? showWellbeingCard,
    Expression<bool>? showBusinessCard,
    Expression<bool>? showLearningCard,
    Expression<bool>? showContentCard,
    Expression<bool>? showProjectsWorkspaceSnapshot,
    Expression<bool>? showDockOverlays,
    Expression<bool>? showBackupGuardianDock,
    Expression<bool>? showTreasuryDock,
    Expression<bool>? showKnowledgeLibraryDock,
    Expression<bool>? showVoiceConversationDock,
    Expression<bool>? showVoicePresenceChip,
    Expression<int>? dailyTopTaskLimit,
    Expression<bool>? voiceRepliesEnabled,
    Expression<bool>? voiceAssistantEnabled,
    Expression<bool>? voiceStartupGateEnabled,
    Expression<String>? preferredTtsVoiceName,
    Expression<String>? preferredTtsVoiceLocale,
    Expression<String>? preferredTtsVoiceGender,
    Expression<String>? preferredTtsVoiceIdentifier,
    Expression<double>? preferredTtsVoiceRate,
    Expression<double>? preferredTtsVoicePitch,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingsId != null) 'settings_id': settingsId,
      if (themeMode != null) 'theme_mode': themeMode,
      if (defaultDashboardView != null)
        'default_dashboard_view': defaultDashboardView,
      if (showWellbeingCard != null) 'show_wellbeing_card': showWellbeingCard,
      if (showBusinessCard != null) 'show_business_card': showBusinessCard,
      if (showLearningCard != null) 'show_learning_card': showLearningCard,
      if (showContentCard != null) 'show_content_card': showContentCard,
      if (showProjectsWorkspaceSnapshot != null)
        'show_projects_workspace_snapshot': showProjectsWorkspaceSnapshot,
      if (showDockOverlays != null) 'show_dock_overlays': showDockOverlays,
      if (showBackupGuardianDock != null)
        'show_backup_guardian_dock': showBackupGuardianDock,
      if (showTreasuryDock != null) 'show_treasury_dock': showTreasuryDock,
      if (showKnowledgeLibraryDock != null)
        'show_knowledge_library_dock': showKnowledgeLibraryDock,
      if (showVoiceConversationDock != null)
        'show_voice_conversation_dock': showVoiceConversationDock,
      if (showVoicePresenceChip != null)
        'show_voice_presence_chip': showVoicePresenceChip,
      if (dailyTopTaskLimit != null) 'daily_top_task_limit': dailyTopTaskLimit,
      if (voiceRepliesEnabled != null)
        'voice_replies_enabled': voiceRepliesEnabled,
      if (voiceAssistantEnabled != null)
        'voice_assistant_enabled': voiceAssistantEnabled,
      if (voiceStartupGateEnabled != null)
        'voice_startup_gate_enabled': voiceStartupGateEnabled,
      if (preferredTtsVoiceName != null)
        'preferred_tts_voice_name': preferredTtsVoiceName,
      if (preferredTtsVoiceLocale != null)
        'preferred_tts_voice_locale': preferredTtsVoiceLocale,
      if (preferredTtsVoiceGender != null)
        'preferred_tts_voice_gender': preferredTtsVoiceGender,
      if (preferredTtsVoiceIdentifier != null)
        'preferred_tts_voice_identifier': preferredTtsVoiceIdentifier,
      if (preferredTtsVoiceRate != null)
        'preferred_tts_voice_rate': preferredTtsVoiceRate,
      if (preferredTtsVoicePitch != null)
        'preferred_tts_voice_pitch': preferredTtsVoicePitch,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? settingsId,
    Value<String>? themeMode,
    Value<String?>? defaultDashboardView,
    Value<bool>? showWellbeingCard,
    Value<bool>? showBusinessCard,
    Value<bool>? showLearningCard,
    Value<bool>? showContentCard,
    Value<bool>? showProjectsWorkspaceSnapshot,
    Value<bool>? showDockOverlays,
    Value<bool>? showBackupGuardianDock,
    Value<bool>? showTreasuryDock,
    Value<bool>? showKnowledgeLibraryDock,
    Value<bool>? showVoiceConversationDock,
    Value<bool>? showVoicePresenceChip,
    Value<int>? dailyTopTaskLimit,
    Value<bool>? voiceRepliesEnabled,
    Value<bool>? voiceAssistantEnabled,
    Value<bool>? voiceStartupGateEnabled,
    Value<String?>? preferredTtsVoiceName,
    Value<String?>? preferredTtsVoiceLocale,
    Value<String?>? preferredTtsVoiceGender,
    Value<String?>? preferredTtsVoiceIdentifier,
    Value<double>? preferredTtsVoiceRate,
    Value<double>? preferredTtsVoicePitch,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      settingsId: settingsId ?? this.settingsId,
      themeMode: themeMode ?? this.themeMode,
      defaultDashboardView: defaultDashboardView ?? this.defaultDashboardView,
      showWellbeingCard: showWellbeingCard ?? this.showWellbeingCard,
      showBusinessCard: showBusinessCard ?? this.showBusinessCard,
      showLearningCard: showLearningCard ?? this.showLearningCard,
      showContentCard: showContentCard ?? this.showContentCard,
      showProjectsWorkspaceSnapshot:
          showProjectsWorkspaceSnapshot ?? this.showProjectsWorkspaceSnapshot,
      showDockOverlays: showDockOverlays ?? this.showDockOverlays,
      showBackupGuardianDock:
          showBackupGuardianDock ?? this.showBackupGuardianDock,
      showTreasuryDock: showTreasuryDock ?? this.showTreasuryDock,
      showKnowledgeLibraryDock:
          showKnowledgeLibraryDock ?? this.showKnowledgeLibraryDock,
      showVoiceConversationDock:
          showVoiceConversationDock ?? this.showVoiceConversationDock,
      showVoicePresenceChip:
          showVoicePresenceChip ?? this.showVoicePresenceChip,
      dailyTopTaskLimit: dailyTopTaskLimit ?? this.dailyTopTaskLimit,
      voiceRepliesEnabled: voiceRepliesEnabled ?? this.voiceRepliesEnabled,
      voiceAssistantEnabled:
          voiceAssistantEnabled ?? this.voiceAssistantEnabled,
      voiceStartupGateEnabled:
          voiceStartupGateEnabled ?? this.voiceStartupGateEnabled,
      preferredTtsVoiceName:
          preferredTtsVoiceName ?? this.preferredTtsVoiceName,
      preferredTtsVoiceLocale:
          preferredTtsVoiceLocale ?? this.preferredTtsVoiceLocale,
      preferredTtsVoiceGender:
          preferredTtsVoiceGender ?? this.preferredTtsVoiceGender,
      preferredTtsVoiceIdentifier:
          preferredTtsVoiceIdentifier ?? this.preferredTtsVoiceIdentifier,
      preferredTtsVoiceRate:
          preferredTtsVoiceRate ?? this.preferredTtsVoiceRate,
      preferredTtsVoicePitch:
          preferredTtsVoicePitch ?? this.preferredTtsVoicePitch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingsId.present) {
      map['settings_id'] = Variable<String>(settingsId.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (defaultDashboardView.present) {
      map['default_dashboard_view'] = Variable<String>(
        defaultDashboardView.value,
      );
    }
    if (showWellbeingCard.present) {
      map['show_wellbeing_card'] = Variable<bool>(showWellbeingCard.value);
    }
    if (showBusinessCard.present) {
      map['show_business_card'] = Variable<bool>(showBusinessCard.value);
    }
    if (showLearningCard.present) {
      map['show_learning_card'] = Variable<bool>(showLearningCard.value);
    }
    if (showContentCard.present) {
      map['show_content_card'] = Variable<bool>(showContentCard.value);
    }
    if (showProjectsWorkspaceSnapshot.present) {
      map['show_projects_workspace_snapshot'] = Variable<bool>(
        showProjectsWorkspaceSnapshot.value,
      );
    }
    if (showDockOverlays.present) {
      map['show_dock_overlays'] = Variable<bool>(showDockOverlays.value);
    }
    if (showBackupGuardianDock.present) {
      map['show_backup_guardian_dock'] = Variable<bool>(
        showBackupGuardianDock.value,
      );
    }
    if (showTreasuryDock.present) {
      map['show_treasury_dock'] = Variable<bool>(showTreasuryDock.value);
    }
    if (showKnowledgeLibraryDock.present) {
      map['show_knowledge_library_dock'] = Variable<bool>(
        showKnowledgeLibraryDock.value,
      );
    }
    if (showVoiceConversationDock.present) {
      map['show_voice_conversation_dock'] = Variable<bool>(
        showVoiceConversationDock.value,
      );
    }
    if (showVoicePresenceChip.present) {
      map['show_voice_presence_chip'] = Variable<bool>(
        showVoicePresenceChip.value,
      );
    }
    if (dailyTopTaskLimit.present) {
      map['daily_top_task_limit'] = Variable<int>(dailyTopTaskLimit.value);
    }
    if (voiceRepliesEnabled.present) {
      map['voice_replies_enabled'] = Variable<bool>(voiceRepliesEnabled.value);
    }
    if (voiceAssistantEnabled.present) {
      map['voice_assistant_enabled'] = Variable<bool>(
        voiceAssistantEnabled.value,
      );
    }
    if (voiceStartupGateEnabled.present) {
      map['voice_startup_gate_enabled'] = Variable<bool>(
        voiceStartupGateEnabled.value,
      );
    }
    if (preferredTtsVoiceName.present) {
      map['preferred_tts_voice_name'] = Variable<String>(
        preferredTtsVoiceName.value,
      );
    }
    if (preferredTtsVoiceLocale.present) {
      map['preferred_tts_voice_locale'] = Variable<String>(
        preferredTtsVoiceLocale.value,
      );
    }
    if (preferredTtsVoiceGender.present) {
      map['preferred_tts_voice_gender'] = Variable<String>(
        preferredTtsVoiceGender.value,
      );
    }
    if (preferredTtsVoiceIdentifier.present) {
      map['preferred_tts_voice_identifier'] = Variable<String>(
        preferredTtsVoiceIdentifier.value,
      );
    }
    if (preferredTtsVoiceRate.present) {
      map['preferred_tts_voice_rate'] = Variable<double>(
        preferredTtsVoiceRate.value,
      );
    }
    if (preferredTtsVoicePitch.present) {
      map['preferred_tts_voice_pitch'] = Variable<double>(
        preferredTtsVoicePitch.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('settingsId: $settingsId, ')
          ..write('themeMode: $themeMode, ')
          ..write('defaultDashboardView: $defaultDashboardView, ')
          ..write('showWellbeingCard: $showWellbeingCard, ')
          ..write('showBusinessCard: $showBusinessCard, ')
          ..write('showLearningCard: $showLearningCard, ')
          ..write('showContentCard: $showContentCard, ')
          ..write(
            'showProjectsWorkspaceSnapshot: $showProjectsWorkspaceSnapshot, ',
          )
          ..write('showDockOverlays: $showDockOverlays, ')
          ..write('showBackupGuardianDock: $showBackupGuardianDock, ')
          ..write('showTreasuryDock: $showTreasuryDock, ')
          ..write('showKnowledgeLibraryDock: $showKnowledgeLibraryDock, ')
          ..write('showVoiceConversationDock: $showVoiceConversationDock, ')
          ..write('showVoicePresenceChip: $showVoicePresenceChip, ')
          ..write('dailyTopTaskLimit: $dailyTopTaskLimit, ')
          ..write('voiceRepliesEnabled: $voiceRepliesEnabled, ')
          ..write('voiceAssistantEnabled: $voiceAssistantEnabled, ')
          ..write('voiceStartupGateEnabled: $voiceStartupGateEnabled, ')
          ..write('preferredTtsVoiceName: $preferredTtsVoiceName, ')
          ..write('preferredTtsVoiceLocale: $preferredTtsVoiceLocale, ')
          ..write('preferredTtsVoiceGender: $preferredTtsVoiceGender, ')
          ..write('preferredTtsVoiceIdentifier: $preferredTtsVoiceIdentifier, ')
          ..write('preferredTtsVoiceRate: $preferredTtsVoiceRate, ')
          ..write('preferredTtsVoicePitch: $preferredTtsVoicePitch, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersDevicesControlUsersTable extends UsersDevicesControlUsers
    with TableInfo<$UsersDevicesControlUsersTable, UsersDevicesControlUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDevicesControlUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_devices_control_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersDevicesControlUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UsersDevicesControlUser map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDevicesControlUser(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersDevicesControlUsersTable createAlias(String alias) {
    return $UsersDevicesControlUsersTable(attachedDatabase, alias);
  }
}

class UsersDevicesControlUser extends DataClass
    implements Insertable<UsersDevicesControlUser> {
  final String userId;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDevicesControlUser({
    required this.userId,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDevicesControlUsersCompanion toCompanion(bool nullToAbsent) {
    return UsersDevicesControlUsersCompanion(
      userId: Value(userId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDevicesControlUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDevicesControlUser(
      userId: serializer.fromJson<String>(json['userId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDevicesControlUser copyWith({
    String? userId,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UsersDevicesControlUser(
    userId: userId ?? this.userId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsersDevicesControlUser copyWithCompanion(
    UsersDevicesControlUsersCompanion data,
  ) {
    return UsersDevicesControlUser(
      userId: data.userId.present ? data.userId.value : this.userId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlUser(')
          ..write('userId: $userId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDevicesControlUser &&
          other.userId == this.userId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDevicesControlUsersCompanion
    extends UpdateCompanion<UsersDevicesControlUser> {
  final Value<String> userId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersDevicesControlUsersCompanion({
    this.userId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersDevicesControlUsersCompanion.insert({
    required String userId,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsersDevicesControlUser> custom({
    Expression<String>? userId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersDevicesControlUsersCompanion copyWith({
    Value<String>? userId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersDevicesControlUsersCompanion(
      userId: userId ?? this.userId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlUsersCompanion(')
          ..write('userId: $userId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersDevicesControlDevicesTable extends UsersDevicesControlDevices
    with
        TableInfo<$UsersDevicesControlDevicesTable, UsersDevicesControlDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDevicesControlDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_devices_control_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersDevicesControlDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  UsersDevicesControlDevice map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDevicesControlDevice(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersDevicesControlDevicesTable createAlias(String alias) {
    return $UsersDevicesControlDevicesTable(attachedDatabase, alias);
  }
}

class UsersDevicesControlDevice extends DataClass
    implements Insertable<UsersDevicesControlDevice> {
  final String deviceId;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDevicesControlDevice({
    required this.deviceId,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDevicesControlDevicesCompanion toCompanion(bool nullToAbsent) {
    return UsersDevicesControlDevicesCompanion(
      deviceId: Value(deviceId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDevicesControlDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDevicesControlDevice(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDevicesControlDevice copyWith({
    String? deviceId,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UsersDevicesControlDevice(
    deviceId: deviceId ?? this.deviceId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsersDevicesControlDevice copyWithCompanion(
    UsersDevicesControlDevicesCompanion data,
  ) {
    return UsersDevicesControlDevice(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlDevice(')
          ..write('deviceId: $deviceId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDevicesControlDevice &&
          other.deviceId == this.deviceId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDevicesControlDevicesCompanion
    extends UpdateCompanion<UsersDevicesControlDevice> {
  final Value<String> deviceId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersDevicesControlDevicesCompanion({
    this.deviceId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersDevicesControlDevicesCompanion.insert({
    required String deviceId,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsersDevicesControlDevice> custom({
    Expression<String>? deviceId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersDevicesControlDevicesCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersDevicesControlDevicesCompanion(
      deviceId: deviceId ?? this.deviceId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlDevicesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersDevicesControlApprovalRequestsTable
    extends UsersDevicesControlApprovalRequests
    with
        TableInfo<
          $UsersDevicesControlApprovalRequestsTable,
          UsersDevicesControlApprovalRequest
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDevicesControlApprovalRequestsTable(
    this.attachedDatabase, [
    this._alias,
  ]);
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    requestId,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_devices_control_approval_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersDevicesControlApprovalRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {requestId};
  @override
  UsersDevicesControlApprovalRequest map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDevicesControlApprovalRequest(
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersDevicesControlApprovalRequestsTable createAlias(String alias) {
    return $UsersDevicesControlApprovalRequestsTable(attachedDatabase, alias);
  }
}

class UsersDevicesControlApprovalRequest extends DataClass
    implements Insertable<UsersDevicesControlApprovalRequest> {
  final String requestId;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDevicesControlApprovalRequest({
    required this.requestId,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['request_id'] = Variable<String>(requestId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDevicesControlApprovalRequestsCompanion toCompanion(bool nullToAbsent) {
    return UsersDevicesControlApprovalRequestsCompanion(
      requestId: Value(requestId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDevicesControlApprovalRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDevicesControlApprovalRequest(
      requestId: serializer.fromJson<String>(json['requestId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'requestId': serializer.toJson<String>(requestId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDevicesControlApprovalRequest copyWith({
    String? requestId,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UsersDevicesControlApprovalRequest(
    requestId: requestId ?? this.requestId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsersDevicesControlApprovalRequest copyWithCompanion(
    UsersDevicesControlApprovalRequestsCompanion data,
  ) {
    return UsersDevicesControlApprovalRequest(
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlApprovalRequest(')
          ..write('requestId: $requestId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(requestId, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDevicesControlApprovalRequest &&
          other.requestId == this.requestId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDevicesControlApprovalRequestsCompanion
    extends UpdateCompanion<UsersDevicesControlApprovalRequest> {
  final Value<String> requestId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersDevicesControlApprovalRequestsCompanion({
    this.requestId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersDevicesControlApprovalRequestsCompanion.insert({
    required String requestId,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : requestId = Value(requestId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsersDevicesControlApprovalRequest> custom({
    Expression<String>? requestId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (requestId != null) 'request_id': requestId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersDevicesControlApprovalRequestsCompanion copyWith({
    Value<String>? requestId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersDevicesControlApprovalRequestsCompanion(
      requestId: requestId ?? this.requestId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlApprovalRequestsCompanion(')
          ..write('requestId: $requestId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersDevicesControlAuditEventsTable
    extends UsersDevicesControlAuditEvents
    with
        TableInfo<
          $UsersDevicesControlAuditEventsTable,
          UsersDevicesControlAuditEvent
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDevicesControlAuditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_devices_control_audit_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersDevicesControlAuditEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  UsersDevicesControlAuditEvent map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDevicesControlAuditEvent(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersDevicesControlAuditEventsTable createAlias(String alias) {
    return $UsersDevicesControlAuditEventsTable(attachedDatabase, alias);
  }
}

class UsersDevicesControlAuditEvent extends DataClass
    implements Insertable<UsersDevicesControlAuditEvent> {
  final String eventId;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDevicesControlAuditEvent({
    required this.eventId,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDevicesControlAuditEventsCompanion toCompanion(bool nullToAbsent) {
    return UsersDevicesControlAuditEventsCompanion(
      eventId: Value(eventId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDevicesControlAuditEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDevicesControlAuditEvent(
      eventId: serializer.fromJson<String>(json['eventId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDevicesControlAuditEvent copyWith({
    String? eventId,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UsersDevicesControlAuditEvent(
    eventId: eventId ?? this.eventId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsersDevicesControlAuditEvent copyWithCompanion(
    UsersDevicesControlAuditEventsCompanion data,
  ) {
    return UsersDevicesControlAuditEvent(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlAuditEvent(')
          ..write('eventId: $eventId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDevicesControlAuditEvent &&
          other.eventId == this.eventId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDevicesControlAuditEventsCompanion
    extends UpdateCompanion<UsersDevicesControlAuditEvent> {
  final Value<String> eventId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersDevicesControlAuditEventsCompanion({
    this.eventId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersDevicesControlAuditEventsCompanion.insert({
    required String eventId,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsersDevicesControlAuditEvent> custom({
    Expression<String>? eventId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersDevicesControlAuditEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersDevicesControlAuditEventsCompanion(
      eventId: eventId ?? this.eventId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlAuditEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersDevicesControlRolesTable extends UsersDevicesControlRoles
    with TableInfo<$UsersDevicesControlRolesTable, UsersDevicesControlRole> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDevicesControlRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roleNameMeta = const VerificationMeta(
    'roleName',
  );
  @override
  late final GeneratedColumn<String> roleName = GeneratedColumn<String>(
    'role_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionsJsonMeta = const VerificationMeta(
    'permissionsJson',
  );
  @override
  late final GeneratedColumn<String> permissionsJson = GeneratedColumn<String>(
    'permissions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    roleName,
    permissionsJson,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_devices_control_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersDevicesControlRole> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('role_name')) {
      context.handle(
        _roleNameMeta,
        roleName.isAcceptableOrUnknown(data['role_name']!, _roleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_roleNameMeta);
    }
    if (data.containsKey('permissions_json')) {
      context.handle(
        _permissionsJsonMeta,
        permissionsJson.isAcceptableOrUnknown(
          data['permissions_json']!,
          _permissionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roleName};
  @override
  UsersDevicesControlRole map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDevicesControlRole(
      roleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_name'],
      )!,
      permissionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions_json'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersDevicesControlRolesTable createAlias(String alias) {
    return $UsersDevicesControlRolesTable(attachedDatabase, alias);
  }
}

class UsersDevicesControlRole extends DataClass
    implements Insertable<UsersDevicesControlRole> {
  final String roleName;
  final String permissionsJson;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDevicesControlRole({
    required this.roleName,
    required this.permissionsJson,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['role_name'] = Variable<String>(roleName);
    map['permissions_json'] = Variable<String>(permissionsJson);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDevicesControlRolesCompanion toCompanion(bool nullToAbsent) {
    return UsersDevicesControlRolesCompanion(
      roleName: Value(roleName),
      permissionsJson: Value(permissionsJson),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDevicesControlRole.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDevicesControlRole(
      roleName: serializer.fromJson<String>(json['roleName']),
      permissionsJson: serializer.fromJson<String>(json['permissionsJson']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roleName': serializer.toJson<String>(roleName),
      'permissionsJson': serializer.toJson<String>(permissionsJson),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDevicesControlRole copyWith({
    String? roleName,
    String? permissionsJson,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UsersDevicesControlRole(
    roleName: roleName ?? this.roleName,
    permissionsJson: permissionsJson ?? this.permissionsJson,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsersDevicesControlRole copyWithCompanion(
    UsersDevicesControlRolesCompanion data,
  ) {
    return UsersDevicesControlRole(
      roleName: data.roleName.present ? data.roleName.value : this.roleName,
      permissionsJson: data.permissionsJson.present
          ? data.permissionsJson.value
          : this.permissionsJson,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlRole(')
          ..write('roleName: $roleName, ')
          ..write('permissionsJson: $permissionsJson, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(roleName, permissionsJson, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDevicesControlRole &&
          other.roleName == this.roleName &&
          other.permissionsJson == this.permissionsJson &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDevicesControlRolesCompanion
    extends UpdateCompanion<UsersDevicesControlRole> {
  final Value<String> roleName;
  final Value<String> permissionsJson;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersDevicesControlRolesCompanion({
    this.roleName = const Value.absent(),
    this.permissionsJson = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersDevicesControlRolesCompanion.insert({
    required String roleName,
    this.permissionsJson = const Value.absent(),
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : roleName = Value(roleName),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsersDevicesControlRole> custom({
    Expression<String>? roleName,
    Expression<String>? permissionsJson,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roleName != null) 'role_name': roleName,
      if (permissionsJson != null) 'permissions_json': permissionsJson,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersDevicesControlRolesCompanion copyWith({
    Value<String>? roleName,
    Value<String>? permissionsJson,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersDevicesControlRolesCompanion(
      roleName: roleName ?? this.roleName,
      permissionsJson: permissionsJson ?? this.permissionsJson,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roleName.present) {
      map['role_name'] = Variable<String>(roleName.value);
    }
    if (permissionsJson.present) {
      map['permissions_json'] = Variable<String>(permissionsJson.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlRolesCompanion(')
          ..write('roleName: $roleName, ')
          ..write('permissionsJson: $permissionsJson, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersDevicesControlPermissionsTable
    extends UsersDevicesControlPermissions
    with
        TableInfo<
          $UsersDevicesControlPermissionsTable,
          UsersDevicesControlPermission
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDevicesControlPermissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _permissionNameMeta = const VerificationMeta(
    'permissionName',
  );
  @override
  late final GeneratedColumn<String> permissionName = GeneratedColumn<String>(
    'permission_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    permissionName,
    description,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_devices_control_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersDevicesControlPermission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('permission_name')) {
      context.handle(
        _permissionNameMeta,
        permissionName.isAcceptableOrUnknown(
          data['permission_name']!,
          _permissionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {permissionName};
  @override
  UsersDevicesControlPermission map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDevicesControlPermission(
      permissionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersDevicesControlPermissionsTable createAlias(String alias) {
    return $UsersDevicesControlPermissionsTable(attachedDatabase, alias);
  }
}

class UsersDevicesControlPermission extends DataClass
    implements Insertable<UsersDevicesControlPermission> {
  final String permissionName;
  final String description;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDevicesControlPermission({
    required this.permissionName,
    required this.description,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['permission_name'] = Variable<String>(permissionName);
    map['description'] = Variable<String>(description);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDevicesControlPermissionsCompanion toCompanion(bool nullToAbsent) {
    return UsersDevicesControlPermissionsCompanion(
      permissionName: Value(permissionName),
      description: Value(description),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDevicesControlPermission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDevicesControlPermission(
      permissionName: serializer.fromJson<String>(json['permissionName']),
      description: serializer.fromJson<String>(json['description']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'permissionName': serializer.toJson<String>(permissionName),
      'description': serializer.toJson<String>(description),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDevicesControlPermission copyWith({
    String? permissionName,
    String? description,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UsersDevicesControlPermission(
    permissionName: permissionName ?? this.permissionName,
    description: description ?? this.description,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsersDevicesControlPermission copyWithCompanion(
    UsersDevicesControlPermissionsCompanion data,
  ) {
    return UsersDevicesControlPermission(
      permissionName: data.permissionName.present
          ? data.permissionName.value
          : this.permissionName,
      description: data.description.present
          ? data.description.value
          : this.description,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlPermission(')
          ..write('permissionName: $permissionName, ')
          ..write('description: $description, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    permissionName,
    description,
    payloadJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDevicesControlPermission &&
          other.permissionName == this.permissionName &&
          other.description == this.description &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDevicesControlPermissionsCompanion
    extends UpdateCompanion<UsersDevicesControlPermission> {
  final Value<String> permissionName;
  final Value<String> description;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersDevicesControlPermissionsCompanion({
    this.permissionName = const Value.absent(),
    this.description = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersDevicesControlPermissionsCompanion.insert({
    required String permissionName,
    this.description = const Value.absent(),
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : permissionName = Value(permissionName),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsersDevicesControlPermission> custom({
    Expression<String>? permissionName,
    Expression<String>? description,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (permissionName != null) 'permission_name': permissionName,
      if (description != null) 'description': description,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersDevicesControlPermissionsCompanion copyWith({
    Value<String>? permissionName,
    Value<String>? description,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersDevicesControlPermissionsCompanion(
      permissionName: permissionName ?? this.permissionName,
      description: description ?? this.description,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (permissionName.present) {
      map['permission_name'] = Variable<String>(permissionName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlPermissionsCompanion(')
          ..write('permissionName: $permissionName, ')
          ..write('description: $description, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersDevicesControlTrustLevelsTable
    extends UsersDevicesControlTrustLevels
    with
        TableInfo<
          $UsersDevicesControlTrustLevelsTable,
          UsersDevicesControlTrustLevel
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDevicesControlTrustLevelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trustLevelMeta = const VerificationMeta(
    'trustLevel',
  );
  @override
  late final GeneratedColumn<int> trustLevel = GeneratedColumn<int>(
    'trust_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trustLevel,
    name,
    description,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_devices_control_trust_levels';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersDevicesControlTrustLevel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('trust_level')) {
      context.handle(
        _trustLevelMeta,
        trustLevel.isAcceptableOrUnknown(data['trust_level']!, _trustLevelMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trustLevel};
  @override
  UsersDevicesControlTrustLevel map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDevicesControlTrustLevel(
      trustLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trust_level'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersDevicesControlTrustLevelsTable createAlias(String alias) {
    return $UsersDevicesControlTrustLevelsTable(attachedDatabase, alias);
  }
}

class UsersDevicesControlTrustLevel extends DataClass
    implements Insertable<UsersDevicesControlTrustLevel> {
  final int trustLevel;
  final String name;
  final String description;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDevicesControlTrustLevel({
    required this.trustLevel,
    required this.name,
    required this.description,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trust_level'] = Variable<int>(trustLevel);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDevicesControlTrustLevelsCompanion toCompanion(bool nullToAbsent) {
    return UsersDevicesControlTrustLevelsCompanion(
      trustLevel: Value(trustLevel),
      name: Value(name),
      description: Value(description),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDevicesControlTrustLevel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDevicesControlTrustLevel(
      trustLevel: serializer.fromJson<int>(json['trustLevel']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trustLevel': serializer.toJson<int>(trustLevel),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDevicesControlTrustLevel copyWith({
    int? trustLevel,
    String? name,
    String? description,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UsersDevicesControlTrustLevel(
    trustLevel: trustLevel ?? this.trustLevel,
    name: name ?? this.name,
    description: description ?? this.description,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsersDevicesControlTrustLevel copyWithCompanion(
    UsersDevicesControlTrustLevelsCompanion data,
  ) {
    return UsersDevicesControlTrustLevel(
      trustLevel: data.trustLevel.present
          ? data.trustLevel.value
          : this.trustLevel,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlTrustLevel(')
          ..write('trustLevel: $trustLevel, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trustLevel,
    name,
    description,
    payloadJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDevicesControlTrustLevel &&
          other.trustLevel == this.trustLevel &&
          other.name == this.name &&
          other.description == this.description &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDevicesControlTrustLevelsCompanion
    extends UpdateCompanion<UsersDevicesControlTrustLevel> {
  final Value<int> trustLevel;
  final Value<String> name;
  final Value<String> description;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UsersDevicesControlTrustLevelsCompanion({
    this.trustLevel = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UsersDevicesControlTrustLevelsCompanion.insert({
    this.trustLevel = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsersDevicesControlTrustLevel> custom({
    Expression<int>? trustLevel,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (trustLevel != null) 'trust_level': trustLevel,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UsersDevicesControlTrustLevelsCompanion copyWith({
    Value<int>? trustLevel,
    Value<String>? name,
    Value<String>? description,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UsersDevicesControlTrustLevelsCompanion(
      trustLevel: trustLevel ?? this.trustLevel,
      name: name ?? this.name,
      description: description ?? this.description,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trustLevel.present) {
      map['trust_level'] = Variable<int>(trustLevel.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlTrustLevelsCompanion(')
          ..write('trustLevel: $trustLevel, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UsersDevicesControlAccessRulesTable
    extends UsersDevicesControlAccessRules
    with
        TableInfo<
          $UsersDevicesControlAccessRulesTable,
          UsersDevicesControlAccessRule
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersDevicesControlAccessRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewPermissionMeta = const VerificationMeta(
    'viewPermission',
  );
  @override
  late final GeneratedColumn<String> viewPermission = GeneratedColumn<String>(
    'view_permission',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _editPermissionMeta = const VerificationMeta(
    'editPermission',
  );
  @override
  late final GeneratedColumn<String> editPermission = GeneratedColumn<String>(
    'edit_permission',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _adminPermissionMeta = const VerificationMeta(
    'adminPermission',
  );
  @override
  late final GeneratedColumn<String> adminPermission = GeneratedColumn<String>(
    'admin_permission',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _requestPermissionMeta = const VerificationMeta(
    'requestPermission',
  );
  @override
  late final GeneratedColumn<String> requestPermission =
      GeneratedColumn<String>(
        'request_permission',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _executePermissionMeta = const VerificationMeta(
    'executePermission',
  );
  @override
  late final GeneratedColumn<String> executePermission =
      GeneratedColumn<String>(
        'execute_permission',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _controlPermissionMeta = const VerificationMeta(
    'controlPermission',
  );
  @override
  late final GeneratedColumn<String> controlPermission =
      GeneratedColumn<String>(
        'control_permission',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _requiresTrustLevelMeta =
      const VerificationMeta('requiresTrustLevel');
  @override
  late final GeneratedColumn<int> requiresTrustLevel = GeneratedColumn<int>(
    'requires_trust_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _requiresApprovalForJsonMeta =
      const VerificationMeta('requiresApprovalForJson');
  @override
  late final GeneratedColumn<String> requiresApprovalForJson =
      GeneratedColumn<String>(
        'requires_approval_for_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    moduleId,
    viewPermission,
    editPermission,
    adminPermission,
    requestPermission,
    executePermission,
    controlPermission,
    requiresTrustLevel,
    requiresApprovalForJson,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_devices_control_access_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersDevicesControlAccessRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('view_permission')) {
      context.handle(
        _viewPermissionMeta,
        viewPermission.isAcceptableOrUnknown(
          data['view_permission']!,
          _viewPermissionMeta,
        ),
      );
    }
    if (data.containsKey('edit_permission')) {
      context.handle(
        _editPermissionMeta,
        editPermission.isAcceptableOrUnknown(
          data['edit_permission']!,
          _editPermissionMeta,
        ),
      );
    }
    if (data.containsKey('admin_permission')) {
      context.handle(
        _adminPermissionMeta,
        adminPermission.isAcceptableOrUnknown(
          data['admin_permission']!,
          _adminPermissionMeta,
        ),
      );
    }
    if (data.containsKey('request_permission')) {
      context.handle(
        _requestPermissionMeta,
        requestPermission.isAcceptableOrUnknown(
          data['request_permission']!,
          _requestPermissionMeta,
        ),
      );
    }
    if (data.containsKey('execute_permission')) {
      context.handle(
        _executePermissionMeta,
        executePermission.isAcceptableOrUnknown(
          data['execute_permission']!,
          _executePermissionMeta,
        ),
      );
    }
    if (data.containsKey('control_permission')) {
      context.handle(
        _controlPermissionMeta,
        controlPermission.isAcceptableOrUnknown(
          data['control_permission']!,
          _controlPermissionMeta,
        ),
      );
    }
    if (data.containsKey('requires_trust_level')) {
      context.handle(
        _requiresTrustLevelMeta,
        requiresTrustLevel.isAcceptableOrUnknown(
          data['requires_trust_level']!,
          _requiresTrustLevelMeta,
        ),
      );
    }
    if (data.containsKey('requires_approval_for_json')) {
      context.handle(
        _requiresApprovalForJsonMeta,
        requiresApprovalForJson.isAcceptableOrUnknown(
          data['requires_approval_for_json']!,
          _requiresApprovalForJsonMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {moduleId};
  @override
  UsersDevicesControlAccessRule map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersDevicesControlAccessRule(
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      viewPermission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_permission'],
      )!,
      editPermission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edit_permission'],
      )!,
      adminPermission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admin_permission'],
      )!,
      requestPermission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_permission'],
      )!,
      executePermission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}execute_permission'],
      )!,
      controlPermission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}control_permission'],
      )!,
      requiresTrustLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requires_trust_level'],
      )!,
      requiresApprovalForJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requires_approval_for_json'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersDevicesControlAccessRulesTable createAlias(String alias) {
    return $UsersDevicesControlAccessRulesTable(attachedDatabase, alias);
  }
}

class UsersDevicesControlAccessRule extends DataClass
    implements Insertable<UsersDevicesControlAccessRule> {
  final String moduleId;
  final String viewPermission;
  final String editPermission;
  final String adminPermission;
  final String requestPermission;
  final String executePermission;
  final String controlPermission;
  final int requiresTrustLevel;
  final String requiresApprovalForJson;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UsersDevicesControlAccessRule({
    required this.moduleId,
    required this.viewPermission,
    required this.editPermission,
    required this.adminPermission,
    required this.requestPermission,
    required this.executePermission,
    required this.controlPermission,
    required this.requiresTrustLevel,
    required this.requiresApprovalForJson,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['module_id'] = Variable<String>(moduleId);
    map['view_permission'] = Variable<String>(viewPermission);
    map['edit_permission'] = Variable<String>(editPermission);
    map['admin_permission'] = Variable<String>(adminPermission);
    map['request_permission'] = Variable<String>(requestPermission);
    map['execute_permission'] = Variable<String>(executePermission);
    map['control_permission'] = Variable<String>(controlPermission);
    map['requires_trust_level'] = Variable<int>(requiresTrustLevel);
    map['requires_approval_for_json'] = Variable<String>(
      requiresApprovalForJson,
    );
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersDevicesControlAccessRulesCompanion toCompanion(bool nullToAbsent) {
    return UsersDevicesControlAccessRulesCompanion(
      moduleId: Value(moduleId),
      viewPermission: Value(viewPermission),
      editPermission: Value(editPermission),
      adminPermission: Value(adminPermission),
      requestPermission: Value(requestPermission),
      executePermission: Value(executePermission),
      controlPermission: Value(controlPermission),
      requiresTrustLevel: Value(requiresTrustLevel),
      requiresApprovalForJson: Value(requiresApprovalForJson),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UsersDevicesControlAccessRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersDevicesControlAccessRule(
      moduleId: serializer.fromJson<String>(json['moduleId']),
      viewPermission: serializer.fromJson<String>(json['viewPermission']),
      editPermission: serializer.fromJson<String>(json['editPermission']),
      adminPermission: serializer.fromJson<String>(json['adminPermission']),
      requestPermission: serializer.fromJson<String>(json['requestPermission']),
      executePermission: serializer.fromJson<String>(json['executePermission']),
      controlPermission: serializer.fromJson<String>(json['controlPermission']),
      requiresTrustLevel: serializer.fromJson<int>(json['requiresTrustLevel']),
      requiresApprovalForJson: serializer.fromJson<String>(
        json['requiresApprovalForJson'],
      ),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'moduleId': serializer.toJson<String>(moduleId),
      'viewPermission': serializer.toJson<String>(viewPermission),
      'editPermission': serializer.toJson<String>(editPermission),
      'adminPermission': serializer.toJson<String>(adminPermission),
      'requestPermission': serializer.toJson<String>(requestPermission),
      'executePermission': serializer.toJson<String>(executePermission),
      'controlPermission': serializer.toJson<String>(controlPermission),
      'requiresTrustLevel': serializer.toJson<int>(requiresTrustLevel),
      'requiresApprovalForJson': serializer.toJson<String>(
        requiresApprovalForJson,
      ),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UsersDevicesControlAccessRule copyWith({
    String? moduleId,
    String? viewPermission,
    String? editPermission,
    String? adminPermission,
    String? requestPermission,
    String? executePermission,
    String? controlPermission,
    int? requiresTrustLevel,
    String? requiresApprovalForJson,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UsersDevicesControlAccessRule(
    moduleId: moduleId ?? this.moduleId,
    viewPermission: viewPermission ?? this.viewPermission,
    editPermission: editPermission ?? this.editPermission,
    adminPermission: adminPermission ?? this.adminPermission,
    requestPermission: requestPermission ?? this.requestPermission,
    executePermission: executePermission ?? this.executePermission,
    controlPermission: controlPermission ?? this.controlPermission,
    requiresTrustLevel: requiresTrustLevel ?? this.requiresTrustLevel,
    requiresApprovalForJson:
        requiresApprovalForJson ?? this.requiresApprovalForJson,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UsersDevicesControlAccessRule copyWithCompanion(
    UsersDevicesControlAccessRulesCompanion data,
  ) {
    return UsersDevicesControlAccessRule(
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      viewPermission: data.viewPermission.present
          ? data.viewPermission.value
          : this.viewPermission,
      editPermission: data.editPermission.present
          ? data.editPermission.value
          : this.editPermission,
      adminPermission: data.adminPermission.present
          ? data.adminPermission.value
          : this.adminPermission,
      requestPermission: data.requestPermission.present
          ? data.requestPermission.value
          : this.requestPermission,
      executePermission: data.executePermission.present
          ? data.executePermission.value
          : this.executePermission,
      controlPermission: data.controlPermission.present
          ? data.controlPermission.value
          : this.controlPermission,
      requiresTrustLevel: data.requiresTrustLevel.present
          ? data.requiresTrustLevel.value
          : this.requiresTrustLevel,
      requiresApprovalForJson: data.requiresApprovalForJson.present
          ? data.requiresApprovalForJson.value
          : this.requiresApprovalForJson,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlAccessRule(')
          ..write('moduleId: $moduleId, ')
          ..write('viewPermission: $viewPermission, ')
          ..write('editPermission: $editPermission, ')
          ..write('adminPermission: $adminPermission, ')
          ..write('requestPermission: $requestPermission, ')
          ..write('executePermission: $executePermission, ')
          ..write('controlPermission: $controlPermission, ')
          ..write('requiresTrustLevel: $requiresTrustLevel, ')
          ..write('requiresApprovalForJson: $requiresApprovalForJson, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    moduleId,
    viewPermission,
    editPermission,
    adminPermission,
    requestPermission,
    executePermission,
    controlPermission,
    requiresTrustLevel,
    requiresApprovalForJson,
    payloadJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersDevicesControlAccessRule &&
          other.moduleId == this.moduleId &&
          other.viewPermission == this.viewPermission &&
          other.editPermission == this.editPermission &&
          other.adminPermission == this.adminPermission &&
          other.requestPermission == this.requestPermission &&
          other.executePermission == this.executePermission &&
          other.controlPermission == this.controlPermission &&
          other.requiresTrustLevel == this.requiresTrustLevel &&
          other.requiresApprovalForJson == this.requiresApprovalForJson &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersDevicesControlAccessRulesCompanion
    extends UpdateCompanion<UsersDevicesControlAccessRule> {
  final Value<String> moduleId;
  final Value<String> viewPermission;
  final Value<String> editPermission;
  final Value<String> adminPermission;
  final Value<String> requestPermission;
  final Value<String> executePermission;
  final Value<String> controlPermission;
  final Value<int> requiresTrustLevel;
  final Value<String> requiresApprovalForJson;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersDevicesControlAccessRulesCompanion({
    this.moduleId = const Value.absent(),
    this.viewPermission = const Value.absent(),
    this.editPermission = const Value.absent(),
    this.adminPermission = const Value.absent(),
    this.requestPermission = const Value.absent(),
    this.executePermission = const Value.absent(),
    this.controlPermission = const Value.absent(),
    this.requiresTrustLevel = const Value.absent(),
    this.requiresApprovalForJson = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersDevicesControlAccessRulesCompanion.insert({
    required String moduleId,
    this.viewPermission = const Value.absent(),
    this.editPermission = const Value.absent(),
    this.adminPermission = const Value.absent(),
    this.requestPermission = const Value.absent(),
    this.executePermission = const Value.absent(),
    this.controlPermission = const Value.absent(),
    this.requiresTrustLevel = const Value.absent(),
    this.requiresApprovalForJson = const Value.absent(),
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : moduleId = Value(moduleId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UsersDevicesControlAccessRule> custom({
    Expression<String>? moduleId,
    Expression<String>? viewPermission,
    Expression<String>? editPermission,
    Expression<String>? adminPermission,
    Expression<String>? requestPermission,
    Expression<String>? executePermission,
    Expression<String>? controlPermission,
    Expression<int>? requiresTrustLevel,
    Expression<String>? requiresApprovalForJson,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (moduleId != null) 'module_id': moduleId,
      if (viewPermission != null) 'view_permission': viewPermission,
      if (editPermission != null) 'edit_permission': editPermission,
      if (adminPermission != null) 'admin_permission': adminPermission,
      if (requestPermission != null) 'request_permission': requestPermission,
      if (executePermission != null) 'execute_permission': executePermission,
      if (controlPermission != null) 'control_permission': controlPermission,
      if (requiresTrustLevel != null)
        'requires_trust_level': requiresTrustLevel,
      if (requiresApprovalForJson != null)
        'requires_approval_for_json': requiresApprovalForJson,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersDevicesControlAccessRulesCompanion copyWith({
    Value<String>? moduleId,
    Value<String>? viewPermission,
    Value<String>? editPermission,
    Value<String>? adminPermission,
    Value<String>? requestPermission,
    Value<String>? executePermission,
    Value<String>? controlPermission,
    Value<int>? requiresTrustLevel,
    Value<String>? requiresApprovalForJson,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersDevicesControlAccessRulesCompanion(
      moduleId: moduleId ?? this.moduleId,
      viewPermission: viewPermission ?? this.viewPermission,
      editPermission: editPermission ?? this.editPermission,
      adminPermission: adminPermission ?? this.adminPermission,
      requestPermission: requestPermission ?? this.requestPermission,
      executePermission: executePermission ?? this.executePermission,
      controlPermission: controlPermission ?? this.controlPermission,
      requiresTrustLevel: requiresTrustLevel ?? this.requiresTrustLevel,
      requiresApprovalForJson:
          requiresApprovalForJson ?? this.requiresApprovalForJson,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (viewPermission.present) {
      map['view_permission'] = Variable<String>(viewPermission.value);
    }
    if (editPermission.present) {
      map['edit_permission'] = Variable<String>(editPermission.value);
    }
    if (adminPermission.present) {
      map['admin_permission'] = Variable<String>(adminPermission.value);
    }
    if (requestPermission.present) {
      map['request_permission'] = Variable<String>(requestPermission.value);
    }
    if (executePermission.present) {
      map['execute_permission'] = Variable<String>(executePermission.value);
    }
    if (controlPermission.present) {
      map['control_permission'] = Variable<String>(controlPermission.value);
    }
    if (requiresTrustLevel.present) {
      map['requires_trust_level'] = Variable<int>(requiresTrustLevel.value);
    }
    if (requiresApprovalForJson.present) {
      map['requires_approval_for_json'] = Variable<String>(
        requiresApprovalForJson.value,
      );
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersDevicesControlAccessRulesCompanion(')
          ..write('moduleId: $moduleId, ')
          ..write('viewPermission: $viewPermission, ')
          ..write('editPermission: $editPermission, ')
          ..write('adminPermission: $adminPermission, ')
          ..write('requestPermission: $requestPermission, ')
          ..write('executePermission: $executePermission, ')
          ..write('controlPermission: $controlPermission, ')
          ..write('requiresTrustLevel: $requiresTrustLevel, ')
          ..write('requiresApprovalForJson: $requiresApprovalForJson, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VoiceAuditLogsTable extends VoiceAuditLogs
    with TableInfo<$VoiceAuditLogsTable, VoiceAuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceAuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    logId,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceAuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {logId};
  @override
  VoiceAuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceAuditLog(
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VoiceAuditLogsTable createAlias(String alias) {
    return $VoiceAuditLogsTable(attachedDatabase, alias);
  }
}

class VoiceAuditLog extends DataClass implements Insertable<VoiceAuditLog> {
  final String logId;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VoiceAuditLog({
    required this.logId,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['log_id'] = Variable<String>(logId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VoiceAuditLogsCompanion toCompanion(bool nullToAbsent) {
    return VoiceAuditLogsCompanion(
      logId: Value(logId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VoiceAuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceAuditLog(
      logId: serializer.fromJson<String>(json['logId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'logId': serializer.toJson<String>(logId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VoiceAuditLog copyWith({
    String? logId,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VoiceAuditLog(
    logId: logId ?? this.logId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VoiceAuditLog copyWithCompanion(VoiceAuditLogsCompanion data) {
    return VoiceAuditLog(
      logId: data.logId.present ? data.logId.value : this.logId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceAuditLog(')
          ..write('logId: $logId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(logId, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceAuditLog &&
          other.logId == this.logId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VoiceAuditLogsCompanion extends UpdateCompanion<VoiceAuditLog> {
  final Value<String> logId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VoiceAuditLogsCompanion({
    this.logId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceAuditLogsCompanion.insert({
    required String logId,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : logId = Value(logId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VoiceAuditLog> custom({
    Expression<String>? logId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (logId != null) 'log_id': logId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceAuditLogsCompanion copyWith({
    Value<String>? logId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VoiceAuditLogsCompanion(
      logId: logId ?? this.logId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceAuditLogsCompanion(')
          ..write('logId: $logId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VoiceConversationThreadsTable extends VoiceConversationThreads
    with TableInfo<$VoiceConversationThreadsTable, VoiceConversationThread> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceConversationThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    threadId,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_conversation_threads';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceConversationThread> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {threadId};
  @override
  VoiceConversationThread map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceConversationThread(
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VoiceConversationThreadsTable createAlias(String alias) {
    return $VoiceConversationThreadsTable(attachedDatabase, alias);
  }
}

class VoiceConversationThread extends DataClass
    implements Insertable<VoiceConversationThread> {
  final String threadId;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VoiceConversationThread({
    required this.threadId,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['thread_id'] = Variable<String>(threadId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VoiceConversationThreadsCompanion toCompanion(bool nullToAbsent) {
    return VoiceConversationThreadsCompanion(
      threadId: Value(threadId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VoiceConversationThread.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceConversationThread(
      threadId: serializer.fromJson<String>(json['threadId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'threadId': serializer.toJson<String>(threadId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VoiceConversationThread copyWith({
    String? threadId,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VoiceConversationThread(
    threadId: threadId ?? this.threadId,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VoiceConversationThread copyWithCompanion(
    VoiceConversationThreadsCompanion data,
  ) {
    return VoiceConversationThread(
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceConversationThread(')
          ..write('threadId: $threadId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(threadId, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceConversationThread &&
          other.threadId == this.threadId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VoiceConversationThreadsCompanion
    extends UpdateCompanion<VoiceConversationThread> {
  final Value<String> threadId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VoiceConversationThreadsCompanion({
    this.threadId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceConversationThreadsCompanion.insert({
    required String threadId,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : threadId = Value(threadId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VoiceConversationThread> custom({
    Expression<String>? threadId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (threadId != null) 'thread_id': threadId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceConversationThreadsCompanion copyWith({
    Value<String>? threadId,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VoiceConversationThreadsCompanion(
      threadId: threadId ?? this.threadId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceConversationThreadsCompanion(')
          ..write('threadId: $threadId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VoiceModulePreferencesTable extends VoiceModulePreferences
    with TableInfo<$VoiceModulePreferencesTable, VoiceModulePreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceModulePreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _preferenceIdMeta = const VerificationMeta(
    'preferenceId',
  );
  @override
  late final GeneratedColumn<String> preferenceId = GeneratedColumn<String>(
    'preference_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerModeMeta = const VerificationMeta(
    'providerMode',
  );
  @override
  late final GeneratedColumn<String> providerMode = GeneratedColumn<String>(
    'provider_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _featureFlagsJsonMeta = const VerificationMeta(
    'featureFlagsJson',
  );
  @override
  late final GeneratedColumn<String> featureFlagsJson = GeneratedColumn<String>(
    'feature_flags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    preferenceId,
    providerMode,
    featureFlagsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_module_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceModulePreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('preference_id')) {
      context.handle(
        _preferenceIdMeta,
        preferenceId.isAcceptableOrUnknown(
          data['preference_id']!,
          _preferenceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferenceIdMeta);
    }
    if (data.containsKey('provider_mode')) {
      context.handle(
        _providerModeMeta,
        providerMode.isAcceptableOrUnknown(
          data['provider_mode']!,
          _providerModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerModeMeta);
    }
    if (data.containsKey('feature_flags_json')) {
      context.handle(
        _featureFlagsJsonMeta,
        featureFlagsJson.isAcceptableOrUnknown(
          data['feature_flags_json']!,
          _featureFlagsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_featureFlagsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {preferenceId};
  @override
  VoiceModulePreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceModulePreference(
      preferenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preference_id'],
      )!,
      providerMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_mode'],
      )!,
      featureFlagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature_flags_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VoiceModulePreferencesTable createAlias(String alias) {
    return $VoiceModulePreferencesTable(attachedDatabase, alias);
  }
}

class VoiceModulePreference extends DataClass
    implements Insertable<VoiceModulePreference> {
  final String preferenceId;
  final String providerMode;
  final String featureFlagsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VoiceModulePreference({
    required this.preferenceId,
    required this.providerMode,
    required this.featureFlagsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['preference_id'] = Variable<String>(preferenceId);
    map['provider_mode'] = Variable<String>(providerMode);
    map['feature_flags_json'] = Variable<String>(featureFlagsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VoiceModulePreferencesCompanion toCompanion(bool nullToAbsent) {
    return VoiceModulePreferencesCompanion(
      preferenceId: Value(preferenceId),
      providerMode: Value(providerMode),
      featureFlagsJson: Value(featureFlagsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VoiceModulePreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceModulePreference(
      preferenceId: serializer.fromJson<String>(json['preferenceId']),
      providerMode: serializer.fromJson<String>(json['providerMode']),
      featureFlagsJson: serializer.fromJson<String>(json['featureFlagsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'preferenceId': serializer.toJson<String>(preferenceId),
      'providerMode': serializer.toJson<String>(providerMode),
      'featureFlagsJson': serializer.toJson<String>(featureFlagsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VoiceModulePreference copyWith({
    String? preferenceId,
    String? providerMode,
    String? featureFlagsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VoiceModulePreference(
    preferenceId: preferenceId ?? this.preferenceId,
    providerMode: providerMode ?? this.providerMode,
    featureFlagsJson: featureFlagsJson ?? this.featureFlagsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VoiceModulePreference copyWithCompanion(
    VoiceModulePreferencesCompanion data,
  ) {
    return VoiceModulePreference(
      preferenceId: data.preferenceId.present
          ? data.preferenceId.value
          : this.preferenceId,
      providerMode: data.providerMode.present
          ? data.providerMode.value
          : this.providerMode,
      featureFlagsJson: data.featureFlagsJson.present
          ? data.featureFlagsJson.value
          : this.featureFlagsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceModulePreference(')
          ..write('preferenceId: $preferenceId, ')
          ..write('providerMode: $providerMode, ')
          ..write('featureFlagsJson: $featureFlagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    preferenceId,
    providerMode,
    featureFlagsJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceModulePreference &&
          other.preferenceId == this.preferenceId &&
          other.providerMode == this.providerMode &&
          other.featureFlagsJson == this.featureFlagsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VoiceModulePreferencesCompanion
    extends UpdateCompanion<VoiceModulePreference> {
  final Value<String> preferenceId;
  final Value<String> providerMode;
  final Value<String> featureFlagsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VoiceModulePreferencesCompanion({
    this.preferenceId = const Value.absent(),
    this.providerMode = const Value.absent(),
    this.featureFlagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceModulePreferencesCompanion.insert({
    required String preferenceId,
    required String providerMode,
    required String featureFlagsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : preferenceId = Value(preferenceId),
       providerMode = Value(providerMode),
       featureFlagsJson = Value(featureFlagsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VoiceModulePreference> custom({
    Expression<String>? preferenceId,
    Expression<String>? providerMode,
    Expression<String>? featureFlagsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (preferenceId != null) 'preference_id': preferenceId,
      if (providerMode != null) 'provider_mode': providerMode,
      if (featureFlagsJson != null) 'feature_flags_json': featureFlagsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceModulePreferencesCompanion copyWith({
    Value<String>? preferenceId,
    Value<String>? providerMode,
    Value<String>? featureFlagsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VoiceModulePreferencesCompanion(
      preferenceId: preferenceId ?? this.preferenceId,
      providerMode: providerMode ?? this.providerMode,
      featureFlagsJson: featureFlagsJson ?? this.featureFlagsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (preferenceId.present) {
      map['preference_id'] = Variable<String>(preferenceId.value);
    }
    if (providerMode.present) {
      map['provider_mode'] = Variable<String>(providerMode.value);
    }
    if (featureFlagsJson.present) {
      map['feature_flags_json'] = Variable<String>(featureFlagsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceModulePreferencesCompanion(')
          ..write('preferenceId: $preferenceId, ')
          ..write('providerMode: $providerMode, ')
          ..write('featureFlagsJson: $featureFlagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $DailyPlansTable dailyPlans = $DailyPlansTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $LearningItemsTable learningItems = $LearningItemsTable(this);
  late final $ContentItemsTable contentItems = $ContentItemsTable(this);
  late final $BusinessOpportunitiesTable businessOpportunities =
      $BusinessOpportunitiesTable(this);
  late final $WellbeingCheckinsTable wellbeingCheckins =
      $WellbeingCheckinsTable(this);
  late final $InboxItemsTable inboxItems = $InboxItemsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $UsersDevicesControlUsersTable usersDevicesControlUsers =
      $UsersDevicesControlUsersTable(this);
  late final $UsersDevicesControlDevicesTable usersDevicesControlDevices =
      $UsersDevicesControlDevicesTable(this);
  late final $UsersDevicesControlApprovalRequestsTable
  usersDevicesControlApprovalRequests =
      $UsersDevicesControlApprovalRequestsTable(this);
  late final $UsersDevicesControlAuditEventsTable
  usersDevicesControlAuditEvents = $UsersDevicesControlAuditEventsTable(this);
  late final $UsersDevicesControlRolesTable usersDevicesControlRoles =
      $UsersDevicesControlRolesTable(this);
  late final $UsersDevicesControlPermissionsTable
  usersDevicesControlPermissions = $UsersDevicesControlPermissionsTable(this);
  late final $UsersDevicesControlTrustLevelsTable
  usersDevicesControlTrustLevels = $UsersDevicesControlTrustLevelsTable(this);
  late final $UsersDevicesControlAccessRulesTable
  usersDevicesControlAccessRules = $UsersDevicesControlAccessRulesTable(this);
  late final $VoiceAuditLogsTable voiceAuditLogs = $VoiceAuditLogsTable(this);
  late final $VoiceConversationThreadsTable voiceConversationThreads =
      $VoiceConversationThreadsTable(this);
  late final $VoiceModulePreferencesTable voiceModulePreferences =
      $VoiceModulePreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    tasks,
    dailyPlans,
    journalEntries,
    learningItems,
    contentItems,
    businessOpportunities,
    wellbeingCheckins,
    inboxItems,
    appSettings,
    usersDevicesControlUsers,
    usersDevicesControlDevices,
    usersDevicesControlApprovalRequests,
    usersDevicesControlAuditEvents,
    usersDevicesControlRoles,
    usersDevicesControlPermissions,
    usersDevicesControlTrustLevels,
    usersDevicesControlAccessRules,
    voiceAuditLogs,
    voiceConversationThreads,
    voiceModulePreferences,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String projectId,
      required String name,
      Value<String?> shortDescription,
      Value<String?> longDescription,
      Value<String?> vision,
      Value<String> status,
      Value<String> priority,
      Value<int> progressPercentage,
      Value<String?> currentMilestone,
      Value<String?> nextAction,
      Value<DateTime?> startDate,
      Value<DateTime?> targetDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> notes,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> projectId,
      Value<String> name,
      Value<String?> shortDescription,
      Value<String?> longDescription,
      Value<String?> vision,
      Value<String> status,
      Value<String> priority,
      Value<int> progressPercentage,
      Value<String?> currentMilestone,
      Value<String?> nextAction,
      Value<DateTime?> startDate,
      Value<DateTime?> targetDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> notes,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortDescription => $composableBuilder(
    column: $table.shortDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longDescription => $composableBuilder(
    column: $table.longDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vision => $composableBuilder(
    column: $table.vision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressPercentage => $composableBuilder(
    column: $table.progressPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentMilestone => $composableBuilder(
    column: $table.currentMilestone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortDescription => $composableBuilder(
    column: $table.shortDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longDescription => $composableBuilder(
    column: $table.longDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vision => $composableBuilder(
    column: $table.vision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressPercentage => $composableBuilder(
    column: $table.progressPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentMilestone => $composableBuilder(
    column: $table.currentMilestone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortDescription => $composableBuilder(
    column: $table.shortDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get longDescription => $composableBuilder(
    column: $table.longDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vision =>
      $composableBuilder(column: $table.vision, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get progressPercentage => $composableBuilder(
    column: $table.progressPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentMilestone => $composableBuilder(
    column: $table.currentMilestone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> shortDescription = const Value.absent(),
                Value<String?> longDescription = const Value.absent(),
                Value<String?> vision = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<int> progressPercentage = const Value.absent(),
                Value<String?> currentMilestone = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                projectId: projectId,
                name: name,
                shortDescription: shortDescription,
                longDescription: longDescription,
                vision: vision,
                status: status,
                priority: priority,
                progressPercentage: progressPercentage,
                currentMilestone: currentMilestone,
                nextAction: nextAction,
                startDate: startDate,
                targetDate: targetDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String projectId,
                required String name,
                Value<String?> shortDescription = const Value.absent(),
                Value<String?> longDescription = const Value.absent(),
                Value<String?> vision = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<int> progressPercentage = const Value.absent(),
                Value<String?> currentMilestone = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                projectId: projectId,
                name: name,
                shortDescription: shortDescription,
                longDescription: longDescription,
                vision: vision,
                status: status,
                priority: priority,
                progressPercentage: progressPercentage,
                currentMilestone: currentMilestone,
                nextAction: nextAction,
                startDate: startDate,
                targetDate: targetDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                notes: notes,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String taskId,
      Value<String?> projectId,
      required String title,
      Value<String?> description,
      Value<String?> category,
      Value<String> priority,
      Value<String> status,
      Value<DateTime?> dueDate,
      Value<String?> energyLevel,
      Value<int?> estimatedMinutes,
      Value<int?> actualMinutes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<bool> isTopThree,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> taskId,
      Value<String?> projectId,
      Value<String> title,
      Value<String?> description,
      Value<String?> category,
      Value<String> priority,
      Value<String> status,
      Value<DateTime?> dueDate,
      Value<String?> energyLevel,
      Value<int?> estimatedMinutes,
      Value<int?> actualMinutes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<bool> isTopThree,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTopThree => $composableBuilder(
    column: $table.isTopThree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTopThree => $composableBuilder(
    column: $table.isTopThree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isTopThree => $composableBuilder(
    column: $table.isTopThree,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> energyLevel = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<int?> actualMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isTopThree = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                taskId: taskId,
                projectId: projectId,
                title: title,
                description: description,
                category: category,
                priority: priority,
                status: status,
                dueDate: dueDate,
                energyLevel: energyLevel,
                estimatedMinutes: estimatedMinutes,
                actualMinutes: actualMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                notes: notes,
                isTopThree: isTopThree,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                Value<String?> projectId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> energyLevel = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<int?> actualMinutes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isTopThree = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                taskId: taskId,
                projectId: projectId,
                title: title,
                description: description,
                category: category,
                priority: priority,
                status: status,
                dueDate: dueDate,
                energyLevel: energyLevel,
                estimatedMinutes: estimatedMinutes,
                actualMinutes: actualMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                notes: notes,
                isTopThree: isTopThree,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$DailyPlansTableCreateCompanionBuilder =
    DailyPlansCompanion Function({
      required String dailyPlanId,
      required DateTime date,
      Value<String?> mainFocus,
      Value<String?> focusReason,
      Value<String?> morningIntention,
      Value<String?> topTask1Id,
      Value<String?> topTask2Id,
      Value<String?> topTask3Id,
      Value<String?> learningFocusId,
      Value<String?> contentFocusId,
      Value<String?> businessFocusId,
      Value<String?> wellbeingCheckinId,
      Value<String?> eveningReview,
      Value<String?> whatMovedForward,
      Value<String?> whatWasCompleted,
      Value<String?> whatWasLearned,
      Value<String?> blockers,
      Value<String?> carryForwardNotes,
      Value<String?> tomorrowFocus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DailyPlansTableUpdateCompanionBuilder =
    DailyPlansCompanion Function({
      Value<String> dailyPlanId,
      Value<DateTime> date,
      Value<String?> mainFocus,
      Value<String?> focusReason,
      Value<String?> morningIntention,
      Value<String?> topTask1Id,
      Value<String?> topTask2Id,
      Value<String?> topTask3Id,
      Value<String?> learningFocusId,
      Value<String?> contentFocusId,
      Value<String?> businessFocusId,
      Value<String?> wellbeingCheckinId,
      Value<String?> eveningReview,
      Value<String?> whatMovedForward,
      Value<String?> whatWasCompleted,
      Value<String?> whatWasLearned,
      Value<String?> blockers,
      Value<String?> carryForwardNotes,
      Value<String?> tomorrowFocus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DailyPlansTableFilterComposer
    extends Composer<_$AppDatabase, $DailyPlansTable> {
  $$DailyPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dailyPlanId => $composableBuilder(
    column: $table.dailyPlanId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mainFocus => $composableBuilder(
    column: $table.mainFocus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focusReason => $composableBuilder(
    column: $table.focusReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get morningIntention => $composableBuilder(
    column: $table.morningIntention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topTask1Id => $composableBuilder(
    column: $table.topTask1Id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topTask2Id => $composableBuilder(
    column: $table.topTask2Id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topTask3Id => $composableBuilder(
    column: $table.topTask3Id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningFocusId => $composableBuilder(
    column: $table.learningFocusId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentFocusId => $composableBuilder(
    column: $table.contentFocusId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessFocusId => $composableBuilder(
    column: $table.businessFocusId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wellbeingCheckinId => $composableBuilder(
    column: $table.wellbeingCheckinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eveningReview => $composableBuilder(
    column: $table.eveningReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatMovedForward => $composableBuilder(
    column: $table.whatMovedForward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatWasCompleted => $composableBuilder(
    column: $table.whatWasCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatWasLearned => $composableBuilder(
    column: $table.whatWasLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockers => $composableBuilder(
    column: $table.blockers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carryForwardNotes => $composableBuilder(
    column: $table.carryForwardNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tomorrowFocus => $composableBuilder(
    column: $table.tomorrowFocus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyPlansTable> {
  $$DailyPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dailyPlanId => $composableBuilder(
    column: $table.dailyPlanId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mainFocus => $composableBuilder(
    column: $table.mainFocus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focusReason => $composableBuilder(
    column: $table.focusReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get morningIntention => $composableBuilder(
    column: $table.morningIntention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topTask1Id => $composableBuilder(
    column: $table.topTask1Id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topTask2Id => $composableBuilder(
    column: $table.topTask2Id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topTask3Id => $composableBuilder(
    column: $table.topTask3Id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningFocusId => $composableBuilder(
    column: $table.learningFocusId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentFocusId => $composableBuilder(
    column: $table.contentFocusId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessFocusId => $composableBuilder(
    column: $table.businessFocusId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wellbeingCheckinId => $composableBuilder(
    column: $table.wellbeingCheckinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eveningReview => $composableBuilder(
    column: $table.eveningReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatMovedForward => $composableBuilder(
    column: $table.whatMovedForward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatWasCompleted => $composableBuilder(
    column: $table.whatWasCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatWasLearned => $composableBuilder(
    column: $table.whatWasLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockers => $composableBuilder(
    column: $table.blockers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carryForwardNotes => $composableBuilder(
    column: $table.carryForwardNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tomorrowFocus => $composableBuilder(
    column: $table.tomorrowFocus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyPlansTable> {
  $$DailyPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dailyPlanId => $composableBuilder(
    column: $table.dailyPlanId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get mainFocus =>
      $composableBuilder(column: $table.mainFocus, builder: (column) => column);

  GeneratedColumn<String> get focusReason => $composableBuilder(
    column: $table.focusReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get morningIntention => $composableBuilder(
    column: $table.morningIntention,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topTask1Id => $composableBuilder(
    column: $table.topTask1Id,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topTask2Id => $composableBuilder(
    column: $table.topTask2Id,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topTask3Id => $composableBuilder(
    column: $table.topTask3Id,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningFocusId => $composableBuilder(
    column: $table.learningFocusId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentFocusId => $composableBuilder(
    column: $table.contentFocusId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessFocusId => $composableBuilder(
    column: $table.businessFocusId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wellbeingCheckinId => $composableBuilder(
    column: $table.wellbeingCheckinId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eveningReview => $composableBuilder(
    column: $table.eveningReview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatMovedForward => $composableBuilder(
    column: $table.whatMovedForward,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatWasCompleted => $composableBuilder(
    column: $table.whatWasCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatWasLearned => $composableBuilder(
    column: $table.whatWasLearned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get blockers =>
      $composableBuilder(column: $table.blockers, builder: (column) => column);

  GeneratedColumn<String> get carryForwardNotes => $composableBuilder(
    column: $table.carryForwardNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tomorrowFocus => $composableBuilder(
    column: $table.tomorrowFocus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyPlansTable,
          DailyPlan,
          $$DailyPlansTableFilterComposer,
          $$DailyPlansTableOrderingComposer,
          $$DailyPlansTableAnnotationComposer,
          $$DailyPlansTableCreateCompanionBuilder,
          $$DailyPlansTableUpdateCompanionBuilder,
          (
            DailyPlan,
            BaseReferences<_$AppDatabase, $DailyPlansTable, DailyPlan>,
          ),
          DailyPlan,
          PrefetchHooks Function()
        > {
  $$DailyPlansTableTableManager(_$AppDatabase db, $DailyPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dailyPlanId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> mainFocus = const Value.absent(),
                Value<String?> focusReason = const Value.absent(),
                Value<String?> morningIntention = const Value.absent(),
                Value<String?> topTask1Id = const Value.absent(),
                Value<String?> topTask2Id = const Value.absent(),
                Value<String?> topTask3Id = const Value.absent(),
                Value<String?> learningFocusId = const Value.absent(),
                Value<String?> contentFocusId = const Value.absent(),
                Value<String?> businessFocusId = const Value.absent(),
                Value<String?> wellbeingCheckinId = const Value.absent(),
                Value<String?> eveningReview = const Value.absent(),
                Value<String?> whatMovedForward = const Value.absent(),
                Value<String?> whatWasCompleted = const Value.absent(),
                Value<String?> whatWasLearned = const Value.absent(),
                Value<String?> blockers = const Value.absent(),
                Value<String?> carryForwardNotes = const Value.absent(),
                Value<String?> tomorrowFocus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyPlansCompanion(
                dailyPlanId: dailyPlanId,
                date: date,
                mainFocus: mainFocus,
                focusReason: focusReason,
                morningIntention: morningIntention,
                topTask1Id: topTask1Id,
                topTask2Id: topTask2Id,
                topTask3Id: topTask3Id,
                learningFocusId: learningFocusId,
                contentFocusId: contentFocusId,
                businessFocusId: businessFocusId,
                wellbeingCheckinId: wellbeingCheckinId,
                eveningReview: eveningReview,
                whatMovedForward: whatMovedForward,
                whatWasCompleted: whatWasCompleted,
                whatWasLearned: whatWasLearned,
                blockers: blockers,
                carryForwardNotes: carryForwardNotes,
                tomorrowFocus: tomorrowFocus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dailyPlanId,
                required DateTime date,
                Value<String?> mainFocus = const Value.absent(),
                Value<String?> focusReason = const Value.absent(),
                Value<String?> morningIntention = const Value.absent(),
                Value<String?> topTask1Id = const Value.absent(),
                Value<String?> topTask2Id = const Value.absent(),
                Value<String?> topTask3Id = const Value.absent(),
                Value<String?> learningFocusId = const Value.absent(),
                Value<String?> contentFocusId = const Value.absent(),
                Value<String?> businessFocusId = const Value.absent(),
                Value<String?> wellbeingCheckinId = const Value.absent(),
                Value<String?> eveningReview = const Value.absent(),
                Value<String?> whatMovedForward = const Value.absent(),
                Value<String?> whatWasCompleted = const Value.absent(),
                Value<String?> whatWasLearned = const Value.absent(),
                Value<String?> blockers = const Value.absent(),
                Value<String?> carryForwardNotes = const Value.absent(),
                Value<String?> tomorrowFocus = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyPlansCompanion.insert(
                dailyPlanId: dailyPlanId,
                date: date,
                mainFocus: mainFocus,
                focusReason: focusReason,
                morningIntention: morningIntention,
                topTask1Id: topTask1Id,
                topTask2Id: topTask2Id,
                topTask3Id: topTask3Id,
                learningFocusId: learningFocusId,
                contentFocusId: contentFocusId,
                businessFocusId: businessFocusId,
                wellbeingCheckinId: wellbeingCheckinId,
                eveningReview: eveningReview,
                whatMovedForward: whatMovedForward,
                whatWasCompleted: whatWasCompleted,
                whatWasLearned: whatWasLearned,
                blockers: blockers,
                carryForwardNotes: carryForwardNotes,
                tomorrowFocus: tomorrowFocus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyPlansTable,
      DailyPlan,
      $$DailyPlansTableFilterComposer,
      $$DailyPlansTableOrderingComposer,
      $$DailyPlansTableAnnotationComposer,
      $$DailyPlansTableCreateCompanionBuilder,
      $$DailyPlansTableUpdateCompanionBuilder,
      (DailyPlan, BaseReferences<_$AppDatabase, $DailyPlansTable, DailyPlan>),
      DailyPlan,
      PrefetchHooks Function()
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String journalEntryId,
      Value<String?> projectId,
      Value<String?> taskId,
      required DateTime date,
      required String title,
      Value<String?> category,
      Value<String?> whatIWorkedOn,
      Value<String?> whatIBuilt,
      Value<String?> whatILearned,
      Value<String?> problemsEncountered,
      Value<String?> decisionsMade,
      Value<String?> nextActions,
      Value<bool> possibleLinkedinPost,
      Value<bool> possibleWebsiteEntry,
      Value<String?> tags,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> journalEntryId,
      Value<String?> projectId,
      Value<String?> taskId,
      Value<DateTime> date,
      Value<String> title,
      Value<String?> category,
      Value<String?> whatIWorkedOn,
      Value<String?> whatIBuilt,
      Value<String?> whatILearned,
      Value<String?> problemsEncountered,
      Value<String?> decisionsMade,
      Value<String?> nextActions,
      Value<bool> possibleLinkedinPost,
      Value<bool> possibleWebsiteEntry,
      Value<String?> tags,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatIWorkedOn => $composableBuilder(
    column: $table.whatIWorkedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatIBuilt => $composableBuilder(
    column: $table.whatIBuilt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatILearned => $composableBuilder(
    column: $table.whatILearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get problemsEncountered => $composableBuilder(
    column: $table.problemsEncountered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionsMade => $composableBuilder(
    column: $table.decisionsMade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextActions => $composableBuilder(
    column: $table.nextActions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get possibleLinkedinPost => $composableBuilder(
    column: $table.possibleLinkedinPost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get possibleWebsiteEntry => $composableBuilder(
    column: $table.possibleWebsiteEntry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatIWorkedOn => $composableBuilder(
    column: $table.whatIWorkedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatIBuilt => $composableBuilder(
    column: $table.whatIBuilt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatILearned => $composableBuilder(
    column: $table.whatILearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get problemsEncountered => $composableBuilder(
    column: $table.problemsEncountered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionsMade => $composableBuilder(
    column: $table.decisionsMade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextActions => $composableBuilder(
    column: $table.nextActions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get possibleLinkedinPost => $composableBuilder(
    column: $table.possibleLinkedinPost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get possibleWebsiteEntry => $composableBuilder(
    column: $table.possibleWebsiteEntry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get whatIWorkedOn => $composableBuilder(
    column: $table.whatIWorkedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatIBuilt => $composableBuilder(
    column: $table.whatIBuilt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatILearned => $composableBuilder(
    column: $table.whatILearned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get problemsEncountered => $composableBuilder(
    column: $table.problemsEncountered,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decisionsMade => $composableBuilder(
    column: $table.decisionsMade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextActions => $composableBuilder(
    column: $table.nextActions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get possibleLinkedinPost => $composableBuilder(
    column: $table.possibleLinkedinPost,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get possibleWebsiteEntry => $composableBuilder(
    column: $table.possibleWebsiteEntry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> journalEntryId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> whatIWorkedOn = const Value.absent(),
                Value<String?> whatIBuilt = const Value.absent(),
                Value<String?> whatILearned = const Value.absent(),
                Value<String?> problemsEncountered = const Value.absent(),
                Value<String?> decisionsMade = const Value.absent(),
                Value<String?> nextActions = const Value.absent(),
                Value<bool> possibleLinkedinPost = const Value.absent(),
                Value<bool> possibleWebsiteEntry = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                journalEntryId: journalEntryId,
                projectId: projectId,
                taskId: taskId,
                date: date,
                title: title,
                category: category,
                whatIWorkedOn: whatIWorkedOn,
                whatIBuilt: whatIBuilt,
                whatILearned: whatILearned,
                problemsEncountered: problemsEncountered,
                decisionsMade: decisionsMade,
                nextActions: nextActions,
                possibleLinkedinPost: possibleLinkedinPost,
                possibleWebsiteEntry: possibleWebsiteEntry,
                tags: tags,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String journalEntryId,
                Value<String?> projectId = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                required DateTime date,
                required String title,
                Value<String?> category = const Value.absent(),
                Value<String?> whatIWorkedOn = const Value.absent(),
                Value<String?> whatIBuilt = const Value.absent(),
                Value<String?> whatILearned = const Value.absent(),
                Value<String?> problemsEncountered = const Value.absent(),
                Value<String?> decisionsMade = const Value.absent(),
                Value<String?> nextActions = const Value.absent(),
                Value<bool> possibleLinkedinPost = const Value.absent(),
                Value<bool> possibleWebsiteEntry = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                journalEntryId: journalEntryId,
                projectId: projectId,
                taskId: taskId,
                date: date,
                title: title,
                category: category,
                whatIWorkedOn: whatIWorkedOn,
                whatIBuilt: whatIBuilt,
                whatILearned: whatILearned,
                problemsEncountered: problemsEncountered,
                decisionsMade: decisionsMade,
                nextActions: nextActions,
                possibleLinkedinPost: possibleLinkedinPost,
                possibleWebsiteEntry: possibleWebsiteEntry,
                tags: tags,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$LearningItemsTableCreateCompanionBuilder =
    LearningItemsCompanion Function({
      required String learningItemId,
      Value<String?> projectId,
      required String topic,
      Value<String?> reasonForLearning,
      Value<String?> resourceLink,
      Value<String> status,
      Value<String?> notes,
      Value<String?> practiceTaskId,
      Value<String?> nextStep,
      Value<String?> skillConfidence,
      Value<DateTime?> dateStarted,
      Value<DateTime?> dateApplied,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$LearningItemsTableUpdateCompanionBuilder =
    LearningItemsCompanion Function({
      Value<String> learningItemId,
      Value<String?> projectId,
      Value<String> topic,
      Value<String?> reasonForLearning,
      Value<String?> resourceLink,
      Value<String> status,
      Value<String?> notes,
      Value<String?> practiceTaskId,
      Value<String?> nextStep,
      Value<String?> skillConfidence,
      Value<DateTime?> dateStarted,
      Value<DateTime?> dateApplied,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$LearningItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LearningItemsTable> {
  $$LearningItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get learningItemId => $composableBuilder(
    column: $table.learningItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonForLearning => $composableBuilder(
    column: $table.reasonForLearning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceLink => $composableBuilder(
    column: $table.resourceLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get practiceTaskId => $composableBuilder(
    column: $table.practiceTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextStep => $composableBuilder(
    column: $table.nextStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skillConfidence => $composableBuilder(
    column: $table.skillConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateStarted => $composableBuilder(
    column: $table.dateStarted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateApplied => $composableBuilder(
    column: $table.dateApplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LearningItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningItemsTable> {
  $$LearningItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get learningItemId => $composableBuilder(
    column: $table.learningItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonForLearning => $composableBuilder(
    column: $table.reasonForLearning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceLink => $composableBuilder(
    column: $table.resourceLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get practiceTaskId => $composableBuilder(
    column: $table.practiceTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextStep => $composableBuilder(
    column: $table.nextStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skillConfidence => $composableBuilder(
    column: $table.skillConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateStarted => $composableBuilder(
    column: $table.dateStarted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateApplied => $composableBuilder(
    column: $table.dateApplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearningItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningItemsTable> {
  $$LearningItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get learningItemId => $composableBuilder(
    column: $table.learningItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get reasonForLearning => $composableBuilder(
    column: $table.reasonForLearning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceLink => $composableBuilder(
    column: $table.resourceLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get practiceTaskId => $composableBuilder(
    column: $table.practiceTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextStep =>
      $composableBuilder(column: $table.nextStep, builder: (column) => column);

  GeneratedColumn<String> get skillConfidence => $composableBuilder(
    column: $table.skillConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateStarted => $composableBuilder(
    column: $table.dateStarted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateApplied => $composableBuilder(
    column: $table.dateApplied,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$LearningItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearningItemsTable,
          LearningItem,
          $$LearningItemsTableFilterComposer,
          $$LearningItemsTableOrderingComposer,
          $$LearningItemsTableAnnotationComposer,
          $$LearningItemsTableCreateCompanionBuilder,
          $$LearningItemsTableUpdateCompanionBuilder,
          (
            LearningItem,
            BaseReferences<_$AppDatabase, $LearningItemsTable, LearningItem>,
          ),
          LearningItem,
          PrefetchHooks Function()
        > {
  $$LearningItemsTableTableManager(_$AppDatabase db, $LearningItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearningItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearningItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> learningItemId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<String?> reasonForLearning = const Value.absent(),
                Value<String?> resourceLink = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> practiceTaskId = const Value.absent(),
                Value<String?> nextStep = const Value.absent(),
                Value<String?> skillConfidence = const Value.absent(),
                Value<DateTime?> dateStarted = const Value.absent(),
                Value<DateTime?> dateApplied = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LearningItemsCompanion(
                learningItemId: learningItemId,
                projectId: projectId,
                topic: topic,
                reasonForLearning: reasonForLearning,
                resourceLink: resourceLink,
                status: status,
                notes: notes,
                practiceTaskId: practiceTaskId,
                nextStep: nextStep,
                skillConfidence: skillConfidence,
                dateStarted: dateStarted,
                dateApplied: dateApplied,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String learningItemId,
                Value<String?> projectId = const Value.absent(),
                required String topic,
                Value<String?> reasonForLearning = const Value.absent(),
                Value<String?> resourceLink = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> practiceTaskId = const Value.absent(),
                Value<String?> nextStep = const Value.absent(),
                Value<String?> skillConfidence = const Value.absent(),
                Value<DateTime?> dateStarted = const Value.absent(),
                Value<DateTime?> dateApplied = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LearningItemsCompanion.insert(
                learningItemId: learningItemId,
                projectId: projectId,
                topic: topic,
                reasonForLearning: reasonForLearning,
                resourceLink: resourceLink,
                status: status,
                notes: notes,
                practiceTaskId: practiceTaskId,
                nextStep: nextStep,
                skillConfidence: skillConfidence,
                dateStarted: dateStarted,
                dateApplied: dateApplied,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LearningItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearningItemsTable,
      LearningItem,
      $$LearningItemsTableFilterComposer,
      $$LearningItemsTableOrderingComposer,
      $$LearningItemsTableAnnotationComposer,
      $$LearningItemsTableCreateCompanionBuilder,
      $$LearningItemsTableUpdateCompanionBuilder,
      (
        LearningItem,
        BaseReferences<_$AppDatabase, $LearningItemsTable, LearningItem>,
      ),
      LearningItem,
      PrefetchHooks Function()
    >;
typedef $$ContentItemsTableCreateCompanionBuilder =
    ContentItemsCompanion Function({
      required String contentItemId,
      Value<String?> projectId,
      Value<String?> journalEntryId,
      required String title,
      Value<String?> platform,
      Value<String?> contentType,
      Value<String> status,
      Value<String?> draftText,
      Value<bool> imageNeeded,
      Value<String?> imagePrompt,
      Value<DateTime?> publishDate,
      Value<String?> publishedLink,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$ContentItemsTableUpdateCompanionBuilder =
    ContentItemsCompanion Function({
      Value<String> contentItemId,
      Value<String?> projectId,
      Value<String?> journalEntryId,
      Value<String> title,
      Value<String?> platform,
      Value<String?> contentType,
      Value<String> status,
      Value<String?> draftText,
      Value<bool> imageNeeded,
      Value<String?> imagePrompt,
      Value<DateTime?> publishDate,
      Value<String?> publishedLink,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$ContentItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contentItemId => $composableBuilder(
    column: $table.contentItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draftText => $composableBuilder(
    column: $table.draftText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get imageNeeded => $composableBuilder(
    column: $table.imageNeeded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePrompt => $composableBuilder(
    column: $table.imagePrompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishDate => $composableBuilder(
    column: $table.publishDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publishedLink => $composableBuilder(
    column: $table.publishedLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contentItemId => $composableBuilder(
    column: $table.contentItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draftText => $composableBuilder(
    column: $table.draftText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get imageNeeded => $composableBuilder(
    column: $table.imageNeeded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePrompt => $composableBuilder(
    column: $table.imagePrompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishDate => $composableBuilder(
    column: $table.publishDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publishedLink => $composableBuilder(
    column: $table.publishedLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentItemsTable> {
  $$ContentItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contentItemId => $composableBuilder(
    column: $table.contentItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get draftText =>
      $composableBuilder(column: $table.draftText, builder: (column) => column);

  GeneratedColumn<bool> get imageNeeded => $composableBuilder(
    column: $table.imageNeeded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePrompt => $composableBuilder(
    column: $table.imagePrompt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishDate => $composableBuilder(
    column: $table.publishDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publishedLink => $composableBuilder(
    column: $table.publishedLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$ContentItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentItemsTable,
          ContentItem,
          $$ContentItemsTableFilterComposer,
          $$ContentItemsTableOrderingComposer,
          $$ContentItemsTableAnnotationComposer,
          $$ContentItemsTableCreateCompanionBuilder,
          $$ContentItemsTableUpdateCompanionBuilder,
          (
            ContentItem,
            BaseReferences<_$AppDatabase, $ContentItemsTable, ContentItem>,
          ),
          ContentItem,
          PrefetchHooks Function()
        > {
  $$ContentItemsTableTableManager(_$AppDatabase db, $ContentItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> contentItemId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> platform = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> draftText = const Value.absent(),
                Value<bool> imageNeeded = const Value.absent(),
                Value<String?> imagePrompt = const Value.absent(),
                Value<DateTime?> publishDate = const Value.absent(),
                Value<String?> publishedLink = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentItemsCompanion(
                contentItemId: contentItemId,
                projectId: projectId,
                journalEntryId: journalEntryId,
                title: title,
                platform: platform,
                contentType: contentType,
                status: status,
                draftText: draftText,
                imageNeeded: imageNeeded,
                imagePrompt: imagePrompt,
                publishDate: publishDate,
                publishedLink: publishedLink,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String contentItemId,
                Value<String?> projectId = const Value.absent(),
                Value<String?> journalEntryId = const Value.absent(),
                required String title,
                Value<String?> platform = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> draftText = const Value.absent(),
                Value<bool> imageNeeded = const Value.absent(),
                Value<String?> imagePrompt = const Value.absent(),
                Value<DateTime?> publishDate = const Value.absent(),
                Value<String?> publishedLink = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentItemsCompanion.insert(
                contentItemId: contentItemId,
                projectId: projectId,
                journalEntryId: journalEntryId,
                title: title,
                platform: platform,
                contentType: contentType,
                status: status,
                draftText: draftText,
                imageNeeded: imageNeeded,
                imagePrompt: imagePrompt,
                publishDate: publishDate,
                publishedLink: publishedLink,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentItemsTable,
      ContentItem,
      $$ContentItemsTableFilterComposer,
      $$ContentItemsTableOrderingComposer,
      $$ContentItemsTableAnnotationComposer,
      $$ContentItemsTableCreateCompanionBuilder,
      $$ContentItemsTableUpdateCompanionBuilder,
      (
        ContentItem,
        BaseReferences<_$AppDatabase, $ContentItemsTable, ContentItem>,
      ),
      ContentItem,
      PrefetchHooks Function()
    >;
typedef $$BusinessOpportunitiesTableCreateCompanionBuilder =
    BusinessOpportunitiesCompanion Function({
      required String businessOpportunityId,
      Value<String?> projectId,
      required String name,
      Value<String?> type,
      Value<String?> companyOrContact,
      Value<String> status,
      Value<DateTime?> deadline,
      Value<String?> nextAction,
      Value<DateTime?> followUpDate,
      Value<String?> relatedDocumentLink,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$BusinessOpportunitiesTableUpdateCompanionBuilder =
    BusinessOpportunitiesCompanion Function({
      Value<String> businessOpportunityId,
      Value<String?> projectId,
      Value<String> name,
      Value<String?> type,
      Value<String?> companyOrContact,
      Value<String> status,
      Value<DateTime?> deadline,
      Value<String?> nextAction,
      Value<DateTime?> followUpDate,
      Value<String?> relatedDocumentLink,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$BusinessOpportunitiesTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessOpportunitiesTable> {
  $$BusinessOpportunitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get businessOpportunityId => $composableBuilder(
    column: $table.businessOpportunityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyOrContact => $composableBuilder(
    column: $table.companyOrContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedDocumentLink => $composableBuilder(
    column: $table.relatedDocumentLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BusinessOpportunitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessOpportunitiesTable> {
  $$BusinessOpportunitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get businessOpportunityId => $composableBuilder(
    column: $table.businessOpportunityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyOrContact => $composableBuilder(
    column: $table.companyOrContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedDocumentLink => $composableBuilder(
    column: $table.relatedDocumentLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BusinessOpportunitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessOpportunitiesTable> {
  $$BusinessOpportunitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get businessOpportunityId => $composableBuilder(
    column: $table.businessOpportunityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get companyOrContact => $composableBuilder(
    column: $table.companyOrContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedDocumentLink => $composableBuilder(
    column: $table.relatedDocumentLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$BusinessOpportunitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessOpportunitiesTable,
          BusinessOpportunity,
          $$BusinessOpportunitiesTableFilterComposer,
          $$BusinessOpportunitiesTableOrderingComposer,
          $$BusinessOpportunitiesTableAnnotationComposer,
          $$BusinessOpportunitiesTableCreateCompanionBuilder,
          $$BusinessOpportunitiesTableUpdateCompanionBuilder,
          (
            BusinessOpportunity,
            BaseReferences<
              _$AppDatabase,
              $BusinessOpportunitiesTable,
              BusinessOpportunity
            >,
          ),
          BusinessOpportunity,
          PrefetchHooks Function()
        > {
  $$BusinessOpportunitiesTableTableManager(
    _$AppDatabase db,
    $BusinessOpportunitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessOpportunitiesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BusinessOpportunitiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BusinessOpportunitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> businessOpportunityId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> companyOrContact = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<DateTime?> followUpDate = const Value.absent(),
                Value<String?> relatedDocumentLink = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessOpportunitiesCompanion(
                businessOpportunityId: businessOpportunityId,
                projectId: projectId,
                name: name,
                type: type,
                companyOrContact: companyOrContact,
                status: status,
                deadline: deadline,
                nextAction: nextAction,
                followUpDate: followUpDate,
                relatedDocumentLink: relatedDocumentLink,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String businessOpportunityId,
                Value<String?> projectId = const Value.absent(),
                required String name,
                Value<String?> type = const Value.absent(),
                Value<String?> companyOrContact = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<DateTime?> followUpDate = const Value.absent(),
                Value<String?> relatedDocumentLink = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BusinessOpportunitiesCompanion.insert(
                businessOpportunityId: businessOpportunityId,
                projectId: projectId,
                name: name,
                type: type,
                companyOrContact: companyOrContact,
                status: status,
                deadline: deadline,
                nextAction: nextAction,
                followUpDate: followUpDate,
                relatedDocumentLink: relatedDocumentLink,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BusinessOpportunitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessOpportunitiesTable,
      BusinessOpportunity,
      $$BusinessOpportunitiesTableFilterComposer,
      $$BusinessOpportunitiesTableOrderingComposer,
      $$BusinessOpportunitiesTableAnnotationComposer,
      $$BusinessOpportunitiesTableCreateCompanionBuilder,
      $$BusinessOpportunitiesTableUpdateCompanionBuilder,
      (
        BusinessOpportunity,
        BaseReferences<
          _$AppDatabase,
          $BusinessOpportunitiesTable,
          BusinessOpportunity
        >,
      ),
      BusinessOpportunity,
      PrefetchHooks Function()
    >;
typedef $$WellbeingCheckinsTableCreateCompanionBuilder =
    WellbeingCheckinsCompanion Function({
      required String wellbeingCheckinId,
      required DateTime date,
      Value<String?> energyLevel,
      Value<String?> mood,
      Value<String?> sleepQuality,
      Value<String?> stressLevel,
      Value<bool> movementDone,
      Value<bool> foodWaterOk,
      Value<bool> meditationReflectionDone,
      Value<String?> notes,
      Value<String?> suggestedWorkload,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WellbeingCheckinsTableUpdateCompanionBuilder =
    WellbeingCheckinsCompanion Function({
      Value<String> wellbeingCheckinId,
      Value<DateTime> date,
      Value<String?> energyLevel,
      Value<String?> mood,
      Value<String?> sleepQuality,
      Value<String?> stressLevel,
      Value<bool> movementDone,
      Value<bool> foodWaterOk,
      Value<bool> meditationReflectionDone,
      Value<String?> notes,
      Value<String?> suggestedWorkload,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WellbeingCheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $WellbeingCheckinsTable> {
  $$WellbeingCheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get wellbeingCheckinId => $composableBuilder(
    column: $table.wellbeingCheckinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stressLevel => $composableBuilder(
    column: $table.stressLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get movementDone => $composableBuilder(
    column: $table.movementDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get foodWaterOk => $composableBuilder(
    column: $table.foodWaterOk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get meditationReflectionDone => $composableBuilder(
    column: $table.meditationReflectionDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedWorkload => $composableBuilder(
    column: $table.suggestedWorkload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WellbeingCheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $WellbeingCheckinsTable> {
  $$WellbeingCheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get wellbeingCheckinId => $composableBuilder(
    column: $table.wellbeingCheckinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stressLevel => $composableBuilder(
    column: $table.stressLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get movementDone => $composableBuilder(
    column: $table.movementDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get foodWaterOk => $composableBuilder(
    column: $table.foodWaterOk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get meditationReflectionDone => $composableBuilder(
    column: $table.meditationReflectionDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedWorkload => $composableBuilder(
    column: $table.suggestedWorkload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WellbeingCheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WellbeingCheckinsTable> {
  $$WellbeingCheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get wellbeingCheckinId => $composableBuilder(
    column: $table.wellbeingCheckinId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get energyLevel => $composableBuilder(
    column: $table.energyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stressLevel => $composableBuilder(
    column: $table.stressLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get movementDone => $composableBuilder(
    column: $table.movementDone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get foodWaterOk => $composableBuilder(
    column: $table.foodWaterOk,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get meditationReflectionDone => $composableBuilder(
    column: $table.meditationReflectionDone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get suggestedWorkload => $composableBuilder(
    column: $table.suggestedWorkload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WellbeingCheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WellbeingCheckinsTable,
          WellbeingCheckin,
          $$WellbeingCheckinsTableFilterComposer,
          $$WellbeingCheckinsTableOrderingComposer,
          $$WellbeingCheckinsTableAnnotationComposer,
          $$WellbeingCheckinsTableCreateCompanionBuilder,
          $$WellbeingCheckinsTableUpdateCompanionBuilder,
          (
            WellbeingCheckin,
            BaseReferences<
              _$AppDatabase,
              $WellbeingCheckinsTable,
              WellbeingCheckin
            >,
          ),
          WellbeingCheckin,
          PrefetchHooks Function()
        > {
  $$WellbeingCheckinsTableTableManager(
    _$AppDatabase db,
    $WellbeingCheckinsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WellbeingCheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WellbeingCheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WellbeingCheckinsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> wellbeingCheckinId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> energyLevel = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<String?> sleepQuality = const Value.absent(),
                Value<String?> stressLevel = const Value.absent(),
                Value<bool> movementDone = const Value.absent(),
                Value<bool> foodWaterOk = const Value.absent(),
                Value<bool> meditationReflectionDone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> suggestedWorkload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellbeingCheckinsCompanion(
                wellbeingCheckinId: wellbeingCheckinId,
                date: date,
                energyLevel: energyLevel,
                mood: mood,
                sleepQuality: sleepQuality,
                stressLevel: stressLevel,
                movementDone: movementDone,
                foodWaterOk: foodWaterOk,
                meditationReflectionDone: meditationReflectionDone,
                notes: notes,
                suggestedWorkload: suggestedWorkload,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String wellbeingCheckinId,
                required DateTime date,
                Value<String?> energyLevel = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<String?> sleepQuality = const Value.absent(),
                Value<String?> stressLevel = const Value.absent(),
                Value<bool> movementDone = const Value.absent(),
                Value<bool> foodWaterOk = const Value.absent(),
                Value<bool> meditationReflectionDone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> suggestedWorkload = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WellbeingCheckinsCompanion.insert(
                wellbeingCheckinId: wellbeingCheckinId,
                date: date,
                energyLevel: energyLevel,
                mood: mood,
                sleepQuality: sleepQuality,
                stressLevel: stressLevel,
                movementDone: movementDone,
                foodWaterOk: foodWaterOk,
                meditationReflectionDone: meditationReflectionDone,
                notes: notes,
                suggestedWorkload: suggestedWorkload,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WellbeingCheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WellbeingCheckinsTable,
      WellbeingCheckin,
      $$WellbeingCheckinsTableFilterComposer,
      $$WellbeingCheckinsTableOrderingComposer,
      $$WellbeingCheckinsTableAnnotationComposer,
      $$WellbeingCheckinsTableCreateCompanionBuilder,
      $$WellbeingCheckinsTableUpdateCompanionBuilder,
      (
        WellbeingCheckin,
        BaseReferences<
          _$AppDatabase,
          $WellbeingCheckinsTable,
          WellbeingCheckin
        >,
      ),
      WellbeingCheckin,
      PrefetchHooks Function()
    >;
typedef $$InboxItemsTableCreateCompanionBuilder =
    InboxItemsCompanion Function({
      required String inboxItemId,
      Value<String?> title,
      Value<String?> body,
      Value<String?> type,
      Value<String?> projectId,
      Value<String> status,
      required DateTime createdAt,
      Value<DateTime?> processedAt,
      Value<String?> convertedToType,
      Value<String?> convertedToId,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$InboxItemsTableUpdateCompanionBuilder =
    InboxItemsCompanion Function({
      Value<String> inboxItemId,
      Value<String?> title,
      Value<String?> body,
      Value<String?> type,
      Value<String?> projectId,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> processedAt,
      Value<String?> convertedToType,
      Value<String?> convertedToId,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$InboxItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get inboxItemId => $composableBuilder(
    column: $table.inboxItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get convertedToType => $composableBuilder(
    column: $table.convertedToType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get convertedToId => $composableBuilder(
    column: $table.convertedToId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InboxItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get inboxItemId => $composableBuilder(
    column: $table.inboxItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get convertedToType => $composableBuilder(
    column: $table.convertedToType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get convertedToId => $composableBuilder(
    column: $table.convertedToId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InboxItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get inboxItemId => $composableBuilder(
    column: $table.inboxItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get convertedToType => $composableBuilder(
    column: $table.convertedToType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get convertedToId => $composableBuilder(
    column: $table.convertedToId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$InboxItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InboxItemsTable,
          InboxItem,
          $$InboxItemsTableFilterComposer,
          $$InboxItemsTableOrderingComposer,
          $$InboxItemsTableAnnotationComposer,
          $$InboxItemsTableCreateCompanionBuilder,
          $$InboxItemsTableUpdateCompanionBuilder,
          (
            InboxItem,
            BaseReferences<_$AppDatabase, $InboxItemsTable, InboxItem>,
          ),
          InboxItem,
          PrefetchHooks Function()
        > {
  $$InboxItemsTableTableManager(_$AppDatabase db, $InboxItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> inboxItemId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<String?> convertedToType = const Value.absent(),
                Value<String?> convertedToId = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InboxItemsCompanion(
                inboxItemId: inboxItemId,
                title: title,
                body: body,
                type: type,
                projectId: projectId,
                status: status,
                createdAt: createdAt,
                processedAt: processedAt,
                convertedToType: convertedToType,
                convertedToId: convertedToId,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String inboxItemId,
                Value<String?> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> processedAt = const Value.absent(),
                Value<String?> convertedToType = const Value.absent(),
                Value<String?> convertedToId = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InboxItemsCompanion.insert(
                inboxItemId: inboxItemId,
                title: title,
                body: body,
                type: type,
                projectId: projectId,
                status: status,
                createdAt: createdAt,
                processedAt: processedAt,
                convertedToType: convertedToType,
                convertedToId: convertedToId,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InboxItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InboxItemsTable,
      InboxItem,
      $$InboxItemsTableFilterComposer,
      $$InboxItemsTableOrderingComposer,
      $$InboxItemsTableAnnotationComposer,
      $$InboxItemsTableCreateCompanionBuilder,
      $$InboxItemsTableUpdateCompanionBuilder,
      (InboxItem, BaseReferences<_$AppDatabase, $InboxItemsTable, InboxItem>),
      InboxItem,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String settingsId,
      Value<String> themeMode,
      Value<String?> defaultDashboardView,
      Value<bool> showWellbeingCard,
      Value<bool> showBusinessCard,
      Value<bool> showLearningCard,
      Value<bool> showContentCard,
      Value<bool> showProjectsWorkspaceSnapshot,
      Value<bool> showDockOverlays,
      Value<bool> showBackupGuardianDock,
      Value<bool> showTreasuryDock,
      Value<bool> showKnowledgeLibraryDock,
      Value<bool> showVoiceConversationDock,
      Value<bool> showVoicePresenceChip,
      Value<int> dailyTopTaskLimit,
      Value<bool> voiceRepliesEnabled,
      Value<bool> voiceAssistantEnabled,
      Value<bool> voiceStartupGateEnabled,
      Value<String?> preferredTtsVoiceName,
      Value<String?> preferredTtsVoiceLocale,
      Value<String?> preferredTtsVoiceGender,
      Value<String?> preferredTtsVoiceIdentifier,
      Value<double> preferredTtsVoiceRate,
      Value<double> preferredTtsVoicePitch,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> settingsId,
      Value<String> themeMode,
      Value<String?> defaultDashboardView,
      Value<bool> showWellbeingCard,
      Value<bool> showBusinessCard,
      Value<bool> showLearningCard,
      Value<bool> showContentCard,
      Value<bool> showProjectsWorkspaceSnapshot,
      Value<bool> showDockOverlays,
      Value<bool> showBackupGuardianDock,
      Value<bool> showTreasuryDock,
      Value<bool> showKnowledgeLibraryDock,
      Value<bool> showVoiceConversationDock,
      Value<bool> showVoicePresenceChip,
      Value<int> dailyTopTaskLimit,
      Value<bool> voiceRepliesEnabled,
      Value<bool> voiceAssistantEnabled,
      Value<bool> voiceStartupGateEnabled,
      Value<String?> preferredTtsVoiceName,
      Value<String?> preferredTtsVoiceLocale,
      Value<String?> preferredTtsVoiceGender,
      Value<String?> preferredTtsVoiceIdentifier,
      Value<double> preferredTtsVoiceRate,
      Value<double> preferredTtsVoicePitch,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingsId => $composableBuilder(
    column: $table.settingsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultDashboardView => $composableBuilder(
    column: $table.defaultDashboardView,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showWellbeingCard => $composableBuilder(
    column: $table.showWellbeingCard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showBusinessCard => $composableBuilder(
    column: $table.showBusinessCard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showLearningCard => $composableBuilder(
    column: $table.showLearningCard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showContentCard => $composableBuilder(
    column: $table.showContentCard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showProjectsWorkspaceSnapshot => $composableBuilder(
    column: $table.showProjectsWorkspaceSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showDockOverlays => $composableBuilder(
    column: $table.showDockOverlays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showBackupGuardianDock => $composableBuilder(
    column: $table.showBackupGuardianDock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showTreasuryDock => $composableBuilder(
    column: $table.showTreasuryDock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showKnowledgeLibraryDock => $composableBuilder(
    column: $table.showKnowledgeLibraryDock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showVoiceConversationDock => $composableBuilder(
    column: $table.showVoiceConversationDock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showVoicePresenceChip => $composableBuilder(
    column: $table.showVoicePresenceChip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyTopTaskLimit => $composableBuilder(
    column: $table.dailyTopTaskLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voiceRepliesEnabled => $composableBuilder(
    column: $table.voiceRepliesEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voiceAssistantEnabled => $composableBuilder(
    column: $table.voiceAssistantEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voiceStartupGateEnabled => $composableBuilder(
    column: $table.voiceStartupGateEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredTtsVoiceName => $composableBuilder(
    column: $table.preferredTtsVoiceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredTtsVoiceLocale => $composableBuilder(
    column: $table.preferredTtsVoiceLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredTtsVoiceGender => $composableBuilder(
    column: $table.preferredTtsVoiceGender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredTtsVoiceIdentifier => $composableBuilder(
    column: $table.preferredTtsVoiceIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get preferredTtsVoiceRate => $composableBuilder(
    column: $table.preferredTtsVoiceRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get preferredTtsVoicePitch => $composableBuilder(
    column: $table.preferredTtsVoicePitch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingsId => $composableBuilder(
    column: $table.settingsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultDashboardView => $composableBuilder(
    column: $table.defaultDashboardView,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showWellbeingCard => $composableBuilder(
    column: $table.showWellbeingCard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showBusinessCard => $composableBuilder(
    column: $table.showBusinessCard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showLearningCard => $composableBuilder(
    column: $table.showLearningCard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showContentCard => $composableBuilder(
    column: $table.showContentCard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showProjectsWorkspaceSnapshot => $composableBuilder(
    column: $table.showProjectsWorkspaceSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showDockOverlays => $composableBuilder(
    column: $table.showDockOverlays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showBackupGuardianDock => $composableBuilder(
    column: $table.showBackupGuardianDock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showTreasuryDock => $composableBuilder(
    column: $table.showTreasuryDock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showKnowledgeLibraryDock => $composableBuilder(
    column: $table.showKnowledgeLibraryDock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showVoiceConversationDock => $composableBuilder(
    column: $table.showVoiceConversationDock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showVoicePresenceChip => $composableBuilder(
    column: $table.showVoicePresenceChip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTopTaskLimit => $composableBuilder(
    column: $table.dailyTopTaskLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voiceRepliesEnabled => $composableBuilder(
    column: $table.voiceRepliesEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voiceAssistantEnabled => $composableBuilder(
    column: $table.voiceAssistantEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voiceStartupGateEnabled => $composableBuilder(
    column: $table.voiceStartupGateEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredTtsVoiceName => $composableBuilder(
    column: $table.preferredTtsVoiceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredTtsVoiceLocale => $composableBuilder(
    column: $table.preferredTtsVoiceLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredTtsVoiceGender => $composableBuilder(
    column: $table.preferredTtsVoiceGender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredTtsVoiceIdentifier => $composableBuilder(
    column: $table.preferredTtsVoiceIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get preferredTtsVoiceRate => $composableBuilder(
    column: $table.preferredTtsVoiceRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get preferredTtsVoicePitch => $composableBuilder(
    column: $table.preferredTtsVoicePitch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingsId => $composableBuilder(
    column: $table.settingsId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get defaultDashboardView => $composableBuilder(
    column: $table.defaultDashboardView,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showWellbeingCard => $composableBuilder(
    column: $table.showWellbeingCard,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showBusinessCard => $composableBuilder(
    column: $table.showBusinessCard,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showLearningCard => $composableBuilder(
    column: $table.showLearningCard,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showContentCard => $composableBuilder(
    column: $table.showContentCard,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showProjectsWorkspaceSnapshot => $composableBuilder(
    column: $table.showProjectsWorkspaceSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showDockOverlays => $composableBuilder(
    column: $table.showDockOverlays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showBackupGuardianDock => $composableBuilder(
    column: $table.showBackupGuardianDock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showTreasuryDock => $composableBuilder(
    column: $table.showTreasuryDock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showKnowledgeLibraryDock => $composableBuilder(
    column: $table.showKnowledgeLibraryDock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showVoiceConversationDock => $composableBuilder(
    column: $table.showVoiceConversationDock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showVoicePresenceChip => $composableBuilder(
    column: $table.showVoicePresenceChip,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyTopTaskLimit => $composableBuilder(
    column: $table.dailyTopTaskLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voiceRepliesEnabled => $composableBuilder(
    column: $table.voiceRepliesEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voiceAssistantEnabled => $composableBuilder(
    column: $table.voiceAssistantEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voiceStartupGateEnabled => $composableBuilder(
    column: $table.voiceStartupGateEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredTtsVoiceName => $composableBuilder(
    column: $table.preferredTtsVoiceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredTtsVoiceLocale => $composableBuilder(
    column: $table.preferredTtsVoiceLocale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredTtsVoiceGender => $composableBuilder(
    column: $table.preferredTtsVoiceGender,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredTtsVoiceIdentifier => $composableBuilder(
    column: $table.preferredTtsVoiceIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<double> get preferredTtsVoiceRate => $composableBuilder(
    column: $table.preferredTtsVoiceRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get preferredTtsVoicePitch => $composableBuilder(
    column: $table.preferredTtsVoicePitch,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingsId = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String?> defaultDashboardView = const Value.absent(),
                Value<bool> showWellbeingCard = const Value.absent(),
                Value<bool> showBusinessCard = const Value.absent(),
                Value<bool> showLearningCard = const Value.absent(),
                Value<bool> showContentCard = const Value.absent(),
                Value<bool> showProjectsWorkspaceSnapshot =
                    const Value.absent(),
                Value<bool> showDockOverlays = const Value.absent(),
                Value<bool> showBackupGuardianDock = const Value.absent(),
                Value<bool> showTreasuryDock = const Value.absent(),
                Value<bool> showKnowledgeLibraryDock = const Value.absent(),
                Value<bool> showVoiceConversationDock = const Value.absent(),
                Value<bool> showVoicePresenceChip = const Value.absent(),
                Value<int> dailyTopTaskLimit = const Value.absent(),
                Value<bool> voiceRepliesEnabled = const Value.absent(),
                Value<bool> voiceAssistantEnabled = const Value.absent(),
                Value<bool> voiceStartupGateEnabled = const Value.absent(),
                Value<String?> preferredTtsVoiceName = const Value.absent(),
                Value<String?> preferredTtsVoiceLocale = const Value.absent(),
                Value<String?> preferredTtsVoiceGender = const Value.absent(),
                Value<String?> preferredTtsVoiceIdentifier =
                    const Value.absent(),
                Value<double> preferredTtsVoiceRate = const Value.absent(),
                Value<double> preferredTtsVoicePitch = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                settingsId: settingsId,
                themeMode: themeMode,
                defaultDashboardView: defaultDashboardView,
                showWellbeingCard: showWellbeingCard,
                showBusinessCard: showBusinessCard,
                showLearningCard: showLearningCard,
                showContentCard: showContentCard,
                showProjectsWorkspaceSnapshot: showProjectsWorkspaceSnapshot,
                showDockOverlays: showDockOverlays,
                showBackupGuardianDock: showBackupGuardianDock,
                showTreasuryDock: showTreasuryDock,
                showKnowledgeLibraryDock: showKnowledgeLibraryDock,
                showVoiceConversationDock: showVoiceConversationDock,
                showVoicePresenceChip: showVoicePresenceChip,
                dailyTopTaskLimit: dailyTopTaskLimit,
                voiceRepliesEnabled: voiceRepliesEnabled,
                voiceAssistantEnabled: voiceAssistantEnabled,
                voiceStartupGateEnabled: voiceStartupGateEnabled,
                preferredTtsVoiceName: preferredTtsVoiceName,
                preferredTtsVoiceLocale: preferredTtsVoiceLocale,
                preferredTtsVoiceGender: preferredTtsVoiceGender,
                preferredTtsVoiceIdentifier: preferredTtsVoiceIdentifier,
                preferredTtsVoiceRate: preferredTtsVoiceRate,
                preferredTtsVoicePitch: preferredTtsVoicePitch,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingsId,
                Value<String> themeMode = const Value.absent(),
                Value<String?> defaultDashboardView = const Value.absent(),
                Value<bool> showWellbeingCard = const Value.absent(),
                Value<bool> showBusinessCard = const Value.absent(),
                Value<bool> showLearningCard = const Value.absent(),
                Value<bool> showContentCard = const Value.absent(),
                Value<bool> showProjectsWorkspaceSnapshot =
                    const Value.absent(),
                Value<bool> showDockOverlays = const Value.absent(),
                Value<bool> showBackupGuardianDock = const Value.absent(),
                Value<bool> showTreasuryDock = const Value.absent(),
                Value<bool> showKnowledgeLibraryDock = const Value.absent(),
                Value<bool> showVoiceConversationDock = const Value.absent(),
                Value<bool> showVoicePresenceChip = const Value.absent(),
                Value<int> dailyTopTaskLimit = const Value.absent(),
                Value<bool> voiceRepliesEnabled = const Value.absent(),
                Value<bool> voiceAssistantEnabled = const Value.absent(),
                Value<bool> voiceStartupGateEnabled = const Value.absent(),
                Value<String?> preferredTtsVoiceName = const Value.absent(),
                Value<String?> preferredTtsVoiceLocale = const Value.absent(),
                Value<String?> preferredTtsVoiceGender = const Value.absent(),
                Value<String?> preferredTtsVoiceIdentifier =
                    const Value.absent(),
                Value<double> preferredTtsVoiceRate = const Value.absent(),
                Value<double> preferredTtsVoicePitch = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                settingsId: settingsId,
                themeMode: themeMode,
                defaultDashboardView: defaultDashboardView,
                showWellbeingCard: showWellbeingCard,
                showBusinessCard: showBusinessCard,
                showLearningCard: showLearningCard,
                showContentCard: showContentCard,
                showProjectsWorkspaceSnapshot: showProjectsWorkspaceSnapshot,
                showDockOverlays: showDockOverlays,
                showBackupGuardianDock: showBackupGuardianDock,
                showTreasuryDock: showTreasuryDock,
                showKnowledgeLibraryDock: showKnowledgeLibraryDock,
                showVoiceConversationDock: showVoiceConversationDock,
                showVoicePresenceChip: showVoicePresenceChip,
                dailyTopTaskLimit: dailyTopTaskLimit,
                voiceRepliesEnabled: voiceRepliesEnabled,
                voiceAssistantEnabled: voiceAssistantEnabled,
                voiceStartupGateEnabled: voiceStartupGateEnabled,
                preferredTtsVoiceName: preferredTtsVoiceName,
                preferredTtsVoiceLocale: preferredTtsVoiceLocale,
                preferredTtsVoiceGender: preferredTtsVoiceGender,
                preferredTtsVoiceIdentifier: preferredTtsVoiceIdentifier,
                preferredTtsVoiceRate: preferredTtsVoiceRate,
                preferredTtsVoicePitch: preferredTtsVoicePitch,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$UsersDevicesControlUsersTableCreateCompanionBuilder =
    UsersDevicesControlUsersCompanion Function({
      required String userId,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersDevicesControlUsersTableUpdateCompanionBuilder =
    UsersDevicesControlUsersCompanion Function({
      Value<String> userId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersDevicesControlUsersTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlUsersTable> {
  $$UsersDevicesControlUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersDevicesControlUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlUsersTable> {
  $$UsersDevicesControlUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersDevicesControlUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlUsersTable> {
  $$UsersDevicesControlUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersDevicesControlUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersDevicesControlUsersTable,
          UsersDevicesControlUser,
          $$UsersDevicesControlUsersTableFilterComposer,
          $$UsersDevicesControlUsersTableOrderingComposer,
          $$UsersDevicesControlUsersTableAnnotationComposer,
          $$UsersDevicesControlUsersTableCreateCompanionBuilder,
          $$UsersDevicesControlUsersTableUpdateCompanionBuilder,
          (
            UsersDevicesControlUser,
            BaseReferences<
              _$AppDatabase,
              $UsersDevicesControlUsersTable,
              UsersDevicesControlUser
            >,
          ),
          UsersDevicesControlUser,
          PrefetchHooks Function()
        > {
  $$UsersDevicesControlUsersTableTableManager(
    _$AppDatabase db,
    $UsersDevicesControlUsersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDevicesControlUsersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsersDevicesControlUsersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsersDevicesControlUsersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlUsersCompanion(
                userId: userId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlUsersCompanion.insert(
                userId: userId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersDevicesControlUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersDevicesControlUsersTable,
      UsersDevicesControlUser,
      $$UsersDevicesControlUsersTableFilterComposer,
      $$UsersDevicesControlUsersTableOrderingComposer,
      $$UsersDevicesControlUsersTableAnnotationComposer,
      $$UsersDevicesControlUsersTableCreateCompanionBuilder,
      $$UsersDevicesControlUsersTableUpdateCompanionBuilder,
      (
        UsersDevicesControlUser,
        BaseReferences<
          _$AppDatabase,
          $UsersDevicesControlUsersTable,
          UsersDevicesControlUser
        >,
      ),
      UsersDevicesControlUser,
      PrefetchHooks Function()
    >;
typedef $$UsersDevicesControlDevicesTableCreateCompanionBuilder =
    UsersDevicesControlDevicesCompanion Function({
      required String deviceId,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersDevicesControlDevicesTableUpdateCompanionBuilder =
    UsersDevicesControlDevicesCompanion Function({
      Value<String> deviceId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersDevicesControlDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlDevicesTable> {
  $$UsersDevicesControlDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersDevicesControlDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlDevicesTable> {
  $$UsersDevicesControlDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersDevicesControlDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlDevicesTable> {
  $$UsersDevicesControlDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersDevicesControlDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersDevicesControlDevicesTable,
          UsersDevicesControlDevice,
          $$UsersDevicesControlDevicesTableFilterComposer,
          $$UsersDevicesControlDevicesTableOrderingComposer,
          $$UsersDevicesControlDevicesTableAnnotationComposer,
          $$UsersDevicesControlDevicesTableCreateCompanionBuilder,
          $$UsersDevicesControlDevicesTableUpdateCompanionBuilder,
          (
            UsersDevicesControlDevice,
            BaseReferences<
              _$AppDatabase,
              $UsersDevicesControlDevicesTable,
              UsersDevicesControlDevice
            >,
          ),
          UsersDevicesControlDevice,
          PrefetchHooks Function()
        > {
  $$UsersDevicesControlDevicesTableTableManager(
    _$AppDatabase db,
    $UsersDevicesControlDevicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDevicesControlDevicesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsersDevicesControlDevicesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsersDevicesControlDevicesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlDevicesCompanion(
                deviceId: deviceId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlDevicesCompanion.insert(
                deviceId: deviceId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersDevicesControlDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersDevicesControlDevicesTable,
      UsersDevicesControlDevice,
      $$UsersDevicesControlDevicesTableFilterComposer,
      $$UsersDevicesControlDevicesTableOrderingComposer,
      $$UsersDevicesControlDevicesTableAnnotationComposer,
      $$UsersDevicesControlDevicesTableCreateCompanionBuilder,
      $$UsersDevicesControlDevicesTableUpdateCompanionBuilder,
      (
        UsersDevicesControlDevice,
        BaseReferences<
          _$AppDatabase,
          $UsersDevicesControlDevicesTable,
          UsersDevicesControlDevice
        >,
      ),
      UsersDevicesControlDevice,
      PrefetchHooks Function()
    >;
typedef $$UsersDevicesControlApprovalRequestsTableCreateCompanionBuilder =
    UsersDevicesControlApprovalRequestsCompanion Function({
      required String requestId,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersDevicesControlApprovalRequestsTableUpdateCompanionBuilder =
    UsersDevicesControlApprovalRequestsCompanion Function({
      Value<String> requestId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersDevicesControlApprovalRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlApprovalRequestsTable> {
  $$UsersDevicesControlApprovalRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersDevicesControlApprovalRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlApprovalRequestsTable> {
  $$UsersDevicesControlApprovalRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersDevicesControlApprovalRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlApprovalRequestsTable> {
  $$UsersDevicesControlApprovalRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersDevicesControlApprovalRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersDevicesControlApprovalRequestsTable,
          UsersDevicesControlApprovalRequest,
          $$UsersDevicesControlApprovalRequestsTableFilterComposer,
          $$UsersDevicesControlApprovalRequestsTableOrderingComposer,
          $$UsersDevicesControlApprovalRequestsTableAnnotationComposer,
          $$UsersDevicesControlApprovalRequestsTableCreateCompanionBuilder,
          $$UsersDevicesControlApprovalRequestsTableUpdateCompanionBuilder,
          (
            UsersDevicesControlApprovalRequest,
            BaseReferences<
              _$AppDatabase,
              $UsersDevicesControlApprovalRequestsTable,
              UsersDevicesControlApprovalRequest
            >,
          ),
          UsersDevicesControlApprovalRequest,
          PrefetchHooks Function()
        > {
  $$UsersDevicesControlApprovalRequestsTableTableManager(
    _$AppDatabase db,
    $UsersDevicesControlApprovalRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDevicesControlApprovalRequestsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsersDevicesControlApprovalRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsersDevicesControlApprovalRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> requestId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlApprovalRequestsCompanion(
                requestId: requestId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String requestId,
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlApprovalRequestsCompanion.insert(
                requestId: requestId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersDevicesControlApprovalRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersDevicesControlApprovalRequestsTable,
      UsersDevicesControlApprovalRequest,
      $$UsersDevicesControlApprovalRequestsTableFilterComposer,
      $$UsersDevicesControlApprovalRequestsTableOrderingComposer,
      $$UsersDevicesControlApprovalRequestsTableAnnotationComposer,
      $$UsersDevicesControlApprovalRequestsTableCreateCompanionBuilder,
      $$UsersDevicesControlApprovalRequestsTableUpdateCompanionBuilder,
      (
        UsersDevicesControlApprovalRequest,
        BaseReferences<
          _$AppDatabase,
          $UsersDevicesControlApprovalRequestsTable,
          UsersDevicesControlApprovalRequest
        >,
      ),
      UsersDevicesControlApprovalRequest,
      PrefetchHooks Function()
    >;
typedef $$UsersDevicesControlAuditEventsTableCreateCompanionBuilder =
    UsersDevicesControlAuditEventsCompanion Function({
      required String eventId,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersDevicesControlAuditEventsTableUpdateCompanionBuilder =
    UsersDevicesControlAuditEventsCompanion Function({
      Value<String> eventId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersDevicesControlAuditEventsTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlAuditEventsTable> {
  $$UsersDevicesControlAuditEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersDevicesControlAuditEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlAuditEventsTable> {
  $$UsersDevicesControlAuditEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersDevicesControlAuditEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlAuditEventsTable> {
  $$UsersDevicesControlAuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersDevicesControlAuditEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersDevicesControlAuditEventsTable,
          UsersDevicesControlAuditEvent,
          $$UsersDevicesControlAuditEventsTableFilterComposer,
          $$UsersDevicesControlAuditEventsTableOrderingComposer,
          $$UsersDevicesControlAuditEventsTableAnnotationComposer,
          $$UsersDevicesControlAuditEventsTableCreateCompanionBuilder,
          $$UsersDevicesControlAuditEventsTableUpdateCompanionBuilder,
          (
            UsersDevicesControlAuditEvent,
            BaseReferences<
              _$AppDatabase,
              $UsersDevicesControlAuditEventsTable,
              UsersDevicesControlAuditEvent
            >,
          ),
          UsersDevicesControlAuditEvent,
          PrefetchHooks Function()
        > {
  $$UsersDevicesControlAuditEventsTableTableManager(
    _$AppDatabase db,
    $UsersDevicesControlAuditEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDevicesControlAuditEventsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsersDevicesControlAuditEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsersDevicesControlAuditEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlAuditEventsCompanion(
                eventId: eventId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlAuditEventsCompanion.insert(
                eventId: eventId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersDevicesControlAuditEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersDevicesControlAuditEventsTable,
      UsersDevicesControlAuditEvent,
      $$UsersDevicesControlAuditEventsTableFilterComposer,
      $$UsersDevicesControlAuditEventsTableOrderingComposer,
      $$UsersDevicesControlAuditEventsTableAnnotationComposer,
      $$UsersDevicesControlAuditEventsTableCreateCompanionBuilder,
      $$UsersDevicesControlAuditEventsTableUpdateCompanionBuilder,
      (
        UsersDevicesControlAuditEvent,
        BaseReferences<
          _$AppDatabase,
          $UsersDevicesControlAuditEventsTable,
          UsersDevicesControlAuditEvent
        >,
      ),
      UsersDevicesControlAuditEvent,
      PrefetchHooks Function()
    >;
typedef $$UsersDevicesControlRolesTableCreateCompanionBuilder =
    UsersDevicesControlRolesCompanion Function({
      required String roleName,
      Value<String> permissionsJson,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersDevicesControlRolesTableUpdateCompanionBuilder =
    UsersDevicesControlRolesCompanion Function({
      Value<String> roleName,
      Value<String> permissionsJson,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersDevicesControlRolesTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlRolesTable> {
  $$UsersDevicesControlRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get roleName => $composableBuilder(
    column: $table.roleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersDevicesControlRolesTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlRolesTable> {
  $$UsersDevicesControlRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get roleName => $composableBuilder(
    column: $table.roleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersDevicesControlRolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlRolesTable> {
  $$UsersDevicesControlRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get roleName =>
      $composableBuilder(column: $table.roleName, builder: (column) => column);

  GeneratedColumn<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersDevicesControlRolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersDevicesControlRolesTable,
          UsersDevicesControlRole,
          $$UsersDevicesControlRolesTableFilterComposer,
          $$UsersDevicesControlRolesTableOrderingComposer,
          $$UsersDevicesControlRolesTableAnnotationComposer,
          $$UsersDevicesControlRolesTableCreateCompanionBuilder,
          $$UsersDevicesControlRolesTableUpdateCompanionBuilder,
          (
            UsersDevicesControlRole,
            BaseReferences<
              _$AppDatabase,
              $UsersDevicesControlRolesTable,
              UsersDevicesControlRole
            >,
          ),
          UsersDevicesControlRole,
          PrefetchHooks Function()
        > {
  $$UsersDevicesControlRolesTableTableManager(
    _$AppDatabase db,
    $UsersDevicesControlRolesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDevicesControlRolesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsersDevicesControlRolesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsersDevicesControlRolesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> roleName = const Value.absent(),
                Value<String> permissionsJson = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlRolesCompanion(
                roleName: roleName,
                permissionsJson: permissionsJson,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String roleName,
                Value<String> permissionsJson = const Value.absent(),
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlRolesCompanion.insert(
                roleName: roleName,
                permissionsJson: permissionsJson,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersDevicesControlRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersDevicesControlRolesTable,
      UsersDevicesControlRole,
      $$UsersDevicesControlRolesTableFilterComposer,
      $$UsersDevicesControlRolesTableOrderingComposer,
      $$UsersDevicesControlRolesTableAnnotationComposer,
      $$UsersDevicesControlRolesTableCreateCompanionBuilder,
      $$UsersDevicesControlRolesTableUpdateCompanionBuilder,
      (
        UsersDevicesControlRole,
        BaseReferences<
          _$AppDatabase,
          $UsersDevicesControlRolesTable,
          UsersDevicesControlRole
        >,
      ),
      UsersDevicesControlRole,
      PrefetchHooks Function()
    >;
typedef $$UsersDevicesControlPermissionsTableCreateCompanionBuilder =
    UsersDevicesControlPermissionsCompanion Function({
      required String permissionName,
      Value<String> description,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersDevicesControlPermissionsTableUpdateCompanionBuilder =
    UsersDevicesControlPermissionsCompanion Function({
      Value<String> permissionName,
      Value<String> description,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersDevicesControlPermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlPermissionsTable> {
  $$UsersDevicesControlPermissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get permissionName => $composableBuilder(
    column: $table.permissionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersDevicesControlPermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlPermissionsTable> {
  $$UsersDevicesControlPermissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get permissionName => $composableBuilder(
    column: $table.permissionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersDevicesControlPermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlPermissionsTable> {
  $$UsersDevicesControlPermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get permissionName => $composableBuilder(
    column: $table.permissionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersDevicesControlPermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersDevicesControlPermissionsTable,
          UsersDevicesControlPermission,
          $$UsersDevicesControlPermissionsTableFilterComposer,
          $$UsersDevicesControlPermissionsTableOrderingComposer,
          $$UsersDevicesControlPermissionsTableAnnotationComposer,
          $$UsersDevicesControlPermissionsTableCreateCompanionBuilder,
          $$UsersDevicesControlPermissionsTableUpdateCompanionBuilder,
          (
            UsersDevicesControlPermission,
            BaseReferences<
              _$AppDatabase,
              $UsersDevicesControlPermissionsTable,
              UsersDevicesControlPermission
            >,
          ),
          UsersDevicesControlPermission,
          PrefetchHooks Function()
        > {
  $$UsersDevicesControlPermissionsTableTableManager(
    _$AppDatabase db,
    $UsersDevicesControlPermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDevicesControlPermissionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsersDevicesControlPermissionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsersDevicesControlPermissionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> permissionName = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlPermissionsCompanion(
                permissionName: permissionName,
                description: description,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String permissionName,
                Value<String> description = const Value.absent(),
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlPermissionsCompanion.insert(
                permissionName: permissionName,
                description: description,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersDevicesControlPermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersDevicesControlPermissionsTable,
      UsersDevicesControlPermission,
      $$UsersDevicesControlPermissionsTableFilterComposer,
      $$UsersDevicesControlPermissionsTableOrderingComposer,
      $$UsersDevicesControlPermissionsTableAnnotationComposer,
      $$UsersDevicesControlPermissionsTableCreateCompanionBuilder,
      $$UsersDevicesControlPermissionsTableUpdateCompanionBuilder,
      (
        UsersDevicesControlPermission,
        BaseReferences<
          _$AppDatabase,
          $UsersDevicesControlPermissionsTable,
          UsersDevicesControlPermission
        >,
      ),
      UsersDevicesControlPermission,
      PrefetchHooks Function()
    >;
typedef $$UsersDevicesControlTrustLevelsTableCreateCompanionBuilder =
    UsersDevicesControlTrustLevelsCompanion Function({
      Value<int> trustLevel,
      Value<String> name,
      Value<String> description,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$UsersDevicesControlTrustLevelsTableUpdateCompanionBuilder =
    UsersDevicesControlTrustLevelsCompanion Function({
      Value<int> trustLevel,
      Value<String> name,
      Value<String> description,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UsersDevicesControlTrustLevelsTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlTrustLevelsTable> {
  $$UsersDevicesControlTrustLevelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersDevicesControlTrustLevelsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlTrustLevelsTable> {
  $$UsersDevicesControlTrustLevelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersDevicesControlTrustLevelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlTrustLevelsTable> {
  $$UsersDevicesControlTrustLevelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get trustLevel => $composableBuilder(
    column: $table.trustLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersDevicesControlTrustLevelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersDevicesControlTrustLevelsTable,
          UsersDevicesControlTrustLevel,
          $$UsersDevicesControlTrustLevelsTableFilterComposer,
          $$UsersDevicesControlTrustLevelsTableOrderingComposer,
          $$UsersDevicesControlTrustLevelsTableAnnotationComposer,
          $$UsersDevicesControlTrustLevelsTableCreateCompanionBuilder,
          $$UsersDevicesControlTrustLevelsTableUpdateCompanionBuilder,
          (
            UsersDevicesControlTrustLevel,
            BaseReferences<
              _$AppDatabase,
              $UsersDevicesControlTrustLevelsTable,
              UsersDevicesControlTrustLevel
            >,
          ),
          UsersDevicesControlTrustLevel,
          PrefetchHooks Function()
        > {
  $$UsersDevicesControlTrustLevelsTableTableManager(
    _$AppDatabase db,
    $UsersDevicesControlTrustLevelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDevicesControlTrustLevelsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsersDevicesControlTrustLevelsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsersDevicesControlTrustLevelsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> trustLevel = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UsersDevicesControlTrustLevelsCompanion(
                trustLevel: trustLevel,
                name: name,
                description: description,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> trustLevel = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => UsersDevicesControlTrustLevelsCompanion.insert(
                trustLevel: trustLevel,
                name: name,
                description: description,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersDevicesControlTrustLevelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersDevicesControlTrustLevelsTable,
      UsersDevicesControlTrustLevel,
      $$UsersDevicesControlTrustLevelsTableFilterComposer,
      $$UsersDevicesControlTrustLevelsTableOrderingComposer,
      $$UsersDevicesControlTrustLevelsTableAnnotationComposer,
      $$UsersDevicesControlTrustLevelsTableCreateCompanionBuilder,
      $$UsersDevicesControlTrustLevelsTableUpdateCompanionBuilder,
      (
        UsersDevicesControlTrustLevel,
        BaseReferences<
          _$AppDatabase,
          $UsersDevicesControlTrustLevelsTable,
          UsersDevicesControlTrustLevel
        >,
      ),
      UsersDevicesControlTrustLevel,
      PrefetchHooks Function()
    >;
typedef $$UsersDevicesControlAccessRulesTableCreateCompanionBuilder =
    UsersDevicesControlAccessRulesCompanion Function({
      required String moduleId,
      Value<String> viewPermission,
      Value<String> editPermission,
      Value<String> adminPermission,
      Value<String> requestPermission,
      Value<String> executePermission,
      Value<String> controlPermission,
      Value<int> requiresTrustLevel,
      Value<String> requiresApprovalForJson,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersDevicesControlAccessRulesTableUpdateCompanionBuilder =
    UsersDevicesControlAccessRulesCompanion Function({
      Value<String> moduleId,
      Value<String> viewPermission,
      Value<String> editPermission,
      Value<String> adminPermission,
      Value<String> requestPermission,
      Value<String> executePermission,
      Value<String> controlPermission,
      Value<int> requiresTrustLevel,
      Value<String> requiresApprovalForJson,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersDevicesControlAccessRulesTableFilterComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlAccessRulesTable> {
  $$UsersDevicesControlAccessRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewPermission => $composableBuilder(
    column: $table.viewPermission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editPermission => $composableBuilder(
    column: $table.editPermission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adminPermission => $composableBuilder(
    column: $table.adminPermission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestPermission => $composableBuilder(
    column: $table.requestPermission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get executePermission => $composableBuilder(
    column: $table.executePermission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get controlPermission => $composableBuilder(
    column: $table.controlPermission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requiresTrustLevel => $composableBuilder(
    column: $table.requiresTrustLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requiresApprovalForJson => $composableBuilder(
    column: $table.requiresApprovalForJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersDevicesControlAccessRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlAccessRulesTable> {
  $$UsersDevicesControlAccessRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewPermission => $composableBuilder(
    column: $table.viewPermission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editPermission => $composableBuilder(
    column: $table.editPermission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adminPermission => $composableBuilder(
    column: $table.adminPermission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestPermission => $composableBuilder(
    column: $table.requestPermission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get executePermission => $composableBuilder(
    column: $table.executePermission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controlPermission => $composableBuilder(
    column: $table.controlPermission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requiresTrustLevel => $composableBuilder(
    column: $table.requiresTrustLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requiresApprovalForJson => $composableBuilder(
    column: $table.requiresApprovalForJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersDevicesControlAccessRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersDevicesControlAccessRulesTable> {
  $$UsersDevicesControlAccessRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get viewPermission => $composableBuilder(
    column: $table.viewPermission,
    builder: (column) => column,
  );

  GeneratedColumn<String> get editPermission => $composableBuilder(
    column: $table.editPermission,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adminPermission => $composableBuilder(
    column: $table.adminPermission,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestPermission => $composableBuilder(
    column: $table.requestPermission,
    builder: (column) => column,
  );

  GeneratedColumn<String> get executePermission => $composableBuilder(
    column: $table.executePermission,
    builder: (column) => column,
  );

  GeneratedColumn<String> get controlPermission => $composableBuilder(
    column: $table.controlPermission,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requiresTrustLevel => $composableBuilder(
    column: $table.requiresTrustLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requiresApprovalForJson => $composableBuilder(
    column: $table.requiresApprovalForJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersDevicesControlAccessRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersDevicesControlAccessRulesTable,
          UsersDevicesControlAccessRule,
          $$UsersDevicesControlAccessRulesTableFilterComposer,
          $$UsersDevicesControlAccessRulesTableOrderingComposer,
          $$UsersDevicesControlAccessRulesTableAnnotationComposer,
          $$UsersDevicesControlAccessRulesTableCreateCompanionBuilder,
          $$UsersDevicesControlAccessRulesTableUpdateCompanionBuilder,
          (
            UsersDevicesControlAccessRule,
            BaseReferences<
              _$AppDatabase,
              $UsersDevicesControlAccessRulesTable,
              UsersDevicesControlAccessRule
            >,
          ),
          UsersDevicesControlAccessRule,
          PrefetchHooks Function()
        > {
  $$UsersDevicesControlAccessRulesTableTableManager(
    _$AppDatabase db,
    $UsersDevicesControlAccessRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersDevicesControlAccessRulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsersDevicesControlAccessRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsersDevicesControlAccessRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> moduleId = const Value.absent(),
                Value<String> viewPermission = const Value.absent(),
                Value<String> editPermission = const Value.absent(),
                Value<String> adminPermission = const Value.absent(),
                Value<String> requestPermission = const Value.absent(),
                Value<String> executePermission = const Value.absent(),
                Value<String> controlPermission = const Value.absent(),
                Value<int> requiresTrustLevel = const Value.absent(),
                Value<String> requiresApprovalForJson = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlAccessRulesCompanion(
                moduleId: moduleId,
                viewPermission: viewPermission,
                editPermission: editPermission,
                adminPermission: adminPermission,
                requestPermission: requestPermission,
                executePermission: executePermission,
                controlPermission: controlPermission,
                requiresTrustLevel: requiresTrustLevel,
                requiresApprovalForJson: requiresApprovalForJson,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String moduleId,
                Value<String> viewPermission = const Value.absent(),
                Value<String> editPermission = const Value.absent(),
                Value<String> adminPermission = const Value.absent(),
                Value<String> requestPermission = const Value.absent(),
                Value<String> executePermission = const Value.absent(),
                Value<String> controlPermission = const Value.absent(),
                Value<int> requiresTrustLevel = const Value.absent(),
                Value<String> requiresApprovalForJson = const Value.absent(),
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersDevicesControlAccessRulesCompanion.insert(
                moduleId: moduleId,
                viewPermission: viewPermission,
                editPermission: editPermission,
                adminPermission: adminPermission,
                requestPermission: requestPermission,
                executePermission: executePermission,
                controlPermission: controlPermission,
                requiresTrustLevel: requiresTrustLevel,
                requiresApprovalForJson: requiresApprovalForJson,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersDevicesControlAccessRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersDevicesControlAccessRulesTable,
      UsersDevicesControlAccessRule,
      $$UsersDevicesControlAccessRulesTableFilterComposer,
      $$UsersDevicesControlAccessRulesTableOrderingComposer,
      $$UsersDevicesControlAccessRulesTableAnnotationComposer,
      $$UsersDevicesControlAccessRulesTableCreateCompanionBuilder,
      $$UsersDevicesControlAccessRulesTableUpdateCompanionBuilder,
      (
        UsersDevicesControlAccessRule,
        BaseReferences<
          _$AppDatabase,
          $UsersDevicesControlAccessRulesTable,
          UsersDevicesControlAccessRule
        >,
      ),
      UsersDevicesControlAccessRule,
      PrefetchHooks Function()
    >;
typedef $$VoiceAuditLogsTableCreateCompanionBuilder =
    VoiceAuditLogsCompanion Function({
      required String logId,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VoiceAuditLogsTableUpdateCompanionBuilder =
    VoiceAuditLogsCompanion Function({
      Value<String> logId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$VoiceAuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceAuditLogsTable> {
  $$VoiceAuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VoiceAuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceAuditLogsTable> {
  $$VoiceAuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VoiceAuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceAuditLogsTable> {
  $$VoiceAuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get logId =>
      $composableBuilder(column: $table.logId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VoiceAuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoiceAuditLogsTable,
          VoiceAuditLog,
          $$VoiceAuditLogsTableFilterComposer,
          $$VoiceAuditLogsTableOrderingComposer,
          $$VoiceAuditLogsTableAnnotationComposer,
          $$VoiceAuditLogsTableCreateCompanionBuilder,
          $$VoiceAuditLogsTableUpdateCompanionBuilder,
          (
            VoiceAuditLog,
            BaseReferences<_$AppDatabase, $VoiceAuditLogsTable, VoiceAuditLog>,
          ),
          VoiceAuditLog,
          PrefetchHooks Function()
        > {
  $$VoiceAuditLogsTableTableManager(
    _$AppDatabase db,
    $VoiceAuditLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceAuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoiceAuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoiceAuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> logId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VoiceAuditLogsCompanion(
                logId: logId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String logId,
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VoiceAuditLogsCompanion.insert(
                logId: logId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VoiceAuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoiceAuditLogsTable,
      VoiceAuditLog,
      $$VoiceAuditLogsTableFilterComposer,
      $$VoiceAuditLogsTableOrderingComposer,
      $$VoiceAuditLogsTableAnnotationComposer,
      $$VoiceAuditLogsTableCreateCompanionBuilder,
      $$VoiceAuditLogsTableUpdateCompanionBuilder,
      (
        VoiceAuditLog,
        BaseReferences<_$AppDatabase, $VoiceAuditLogsTable, VoiceAuditLog>,
      ),
      VoiceAuditLog,
      PrefetchHooks Function()
    >;
typedef $$VoiceConversationThreadsTableCreateCompanionBuilder =
    VoiceConversationThreadsCompanion Function({
      required String threadId,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VoiceConversationThreadsTableUpdateCompanionBuilder =
    VoiceConversationThreadsCompanion Function({
      Value<String> threadId,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$VoiceConversationThreadsTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceConversationThreadsTable> {
  $$VoiceConversationThreadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VoiceConversationThreadsTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceConversationThreadsTable> {
  $$VoiceConversationThreadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VoiceConversationThreadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceConversationThreadsTable> {
  $$VoiceConversationThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VoiceConversationThreadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoiceConversationThreadsTable,
          VoiceConversationThread,
          $$VoiceConversationThreadsTableFilterComposer,
          $$VoiceConversationThreadsTableOrderingComposer,
          $$VoiceConversationThreadsTableAnnotationComposer,
          $$VoiceConversationThreadsTableCreateCompanionBuilder,
          $$VoiceConversationThreadsTableUpdateCompanionBuilder,
          (
            VoiceConversationThread,
            BaseReferences<
              _$AppDatabase,
              $VoiceConversationThreadsTable,
              VoiceConversationThread
            >,
          ),
          VoiceConversationThread,
          PrefetchHooks Function()
        > {
  $$VoiceConversationThreadsTableTableManager(
    _$AppDatabase db,
    $VoiceConversationThreadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceConversationThreadsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$VoiceConversationThreadsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VoiceConversationThreadsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> threadId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VoiceConversationThreadsCompanion(
                threadId: threadId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String threadId,
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VoiceConversationThreadsCompanion.insert(
                threadId: threadId,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VoiceConversationThreadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoiceConversationThreadsTable,
      VoiceConversationThread,
      $$VoiceConversationThreadsTableFilterComposer,
      $$VoiceConversationThreadsTableOrderingComposer,
      $$VoiceConversationThreadsTableAnnotationComposer,
      $$VoiceConversationThreadsTableCreateCompanionBuilder,
      $$VoiceConversationThreadsTableUpdateCompanionBuilder,
      (
        VoiceConversationThread,
        BaseReferences<
          _$AppDatabase,
          $VoiceConversationThreadsTable,
          VoiceConversationThread
        >,
      ),
      VoiceConversationThread,
      PrefetchHooks Function()
    >;
typedef $$VoiceModulePreferencesTableCreateCompanionBuilder =
    VoiceModulePreferencesCompanion Function({
      required String preferenceId,
      required String providerMode,
      required String featureFlagsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VoiceModulePreferencesTableUpdateCompanionBuilder =
    VoiceModulePreferencesCompanion Function({
      Value<String> preferenceId,
      Value<String> providerMode,
      Value<String> featureFlagsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$VoiceModulePreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceModulePreferencesTable> {
  $$VoiceModulePreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get preferenceId => $composableBuilder(
    column: $table.preferenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerMode => $composableBuilder(
    column: $table.providerMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get featureFlagsJson => $composableBuilder(
    column: $table.featureFlagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VoiceModulePreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceModulePreferencesTable> {
  $$VoiceModulePreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get preferenceId => $composableBuilder(
    column: $table.preferenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerMode => $composableBuilder(
    column: $table.providerMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get featureFlagsJson => $composableBuilder(
    column: $table.featureFlagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VoiceModulePreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceModulePreferencesTable> {
  $$VoiceModulePreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get preferenceId => $composableBuilder(
    column: $table.preferenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerMode => $composableBuilder(
    column: $table.providerMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get featureFlagsJson => $composableBuilder(
    column: $table.featureFlagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VoiceModulePreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoiceModulePreferencesTable,
          VoiceModulePreference,
          $$VoiceModulePreferencesTableFilterComposer,
          $$VoiceModulePreferencesTableOrderingComposer,
          $$VoiceModulePreferencesTableAnnotationComposer,
          $$VoiceModulePreferencesTableCreateCompanionBuilder,
          $$VoiceModulePreferencesTableUpdateCompanionBuilder,
          (
            VoiceModulePreference,
            BaseReferences<
              _$AppDatabase,
              $VoiceModulePreferencesTable,
              VoiceModulePreference
            >,
          ),
          VoiceModulePreference,
          PrefetchHooks Function()
        > {
  $$VoiceModulePreferencesTableTableManager(
    _$AppDatabase db,
    $VoiceModulePreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceModulePreferencesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$VoiceModulePreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VoiceModulePreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> preferenceId = const Value.absent(),
                Value<String> providerMode = const Value.absent(),
                Value<String> featureFlagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VoiceModulePreferencesCompanion(
                preferenceId: preferenceId,
                providerMode: providerMode,
                featureFlagsJson: featureFlagsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String preferenceId,
                required String providerMode,
                required String featureFlagsJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VoiceModulePreferencesCompanion.insert(
                preferenceId: preferenceId,
                providerMode: providerMode,
                featureFlagsJson: featureFlagsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VoiceModulePreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoiceModulePreferencesTable,
      VoiceModulePreference,
      $$VoiceModulePreferencesTableFilterComposer,
      $$VoiceModulePreferencesTableOrderingComposer,
      $$VoiceModulePreferencesTableAnnotationComposer,
      $$VoiceModulePreferencesTableCreateCompanionBuilder,
      $$VoiceModulePreferencesTableUpdateCompanionBuilder,
      (
        VoiceModulePreference,
        BaseReferences<
          _$AppDatabase,
          $VoiceModulePreferencesTable,
          VoiceModulePreference
        >,
      ),
      VoiceModulePreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$DailyPlansTableTableManager get dailyPlans =>
      $$DailyPlansTableTableManager(_db, _db.dailyPlans);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$LearningItemsTableTableManager get learningItems =>
      $$LearningItemsTableTableManager(_db, _db.learningItems);
  $$ContentItemsTableTableManager get contentItems =>
      $$ContentItemsTableTableManager(_db, _db.contentItems);
  $$BusinessOpportunitiesTableTableManager get businessOpportunities =>
      $$BusinessOpportunitiesTableTableManager(_db, _db.businessOpportunities);
  $$WellbeingCheckinsTableTableManager get wellbeingCheckins =>
      $$WellbeingCheckinsTableTableManager(_db, _db.wellbeingCheckins);
  $$InboxItemsTableTableManager get inboxItems =>
      $$InboxItemsTableTableManager(_db, _db.inboxItems);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$UsersDevicesControlUsersTableTableManager get usersDevicesControlUsers =>
      $$UsersDevicesControlUsersTableTableManager(
        _db,
        _db.usersDevicesControlUsers,
      );
  $$UsersDevicesControlDevicesTableTableManager
  get usersDevicesControlDevices =>
      $$UsersDevicesControlDevicesTableTableManager(
        _db,
        _db.usersDevicesControlDevices,
      );
  $$UsersDevicesControlApprovalRequestsTableTableManager
  get usersDevicesControlApprovalRequests =>
      $$UsersDevicesControlApprovalRequestsTableTableManager(
        _db,
        _db.usersDevicesControlApprovalRequests,
      );
  $$UsersDevicesControlAuditEventsTableTableManager
  get usersDevicesControlAuditEvents =>
      $$UsersDevicesControlAuditEventsTableTableManager(
        _db,
        _db.usersDevicesControlAuditEvents,
      );
  $$UsersDevicesControlRolesTableTableManager get usersDevicesControlRoles =>
      $$UsersDevicesControlRolesTableTableManager(
        _db,
        _db.usersDevicesControlRoles,
      );
  $$UsersDevicesControlPermissionsTableTableManager
  get usersDevicesControlPermissions =>
      $$UsersDevicesControlPermissionsTableTableManager(
        _db,
        _db.usersDevicesControlPermissions,
      );
  $$UsersDevicesControlTrustLevelsTableTableManager
  get usersDevicesControlTrustLevels =>
      $$UsersDevicesControlTrustLevelsTableTableManager(
        _db,
        _db.usersDevicesControlTrustLevels,
      );
  $$UsersDevicesControlAccessRulesTableTableManager
  get usersDevicesControlAccessRules =>
      $$UsersDevicesControlAccessRulesTableTableManager(
        _db,
        _db.usersDevicesControlAccessRules,
      );
  $$VoiceAuditLogsTableTableManager get voiceAuditLogs =>
      $$VoiceAuditLogsTableTableManager(_db, _db.voiceAuditLogs);
  $$VoiceConversationThreadsTableTableManager get voiceConversationThreads =>
      $$VoiceConversationThreadsTableTableManager(
        _db,
        _db.voiceConversationThreads,
      );
  $$VoiceModulePreferencesTableTableManager get voiceModulePreferences =>
      $$VoiceModulePreferencesTableTableManager(
        _db,
        _db.voiceModulePreferences,
      );
}
