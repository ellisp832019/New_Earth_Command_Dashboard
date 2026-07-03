// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engineering_database.dart';

// ignore_for_file: type=lint
class $EngineeringSnapshotRecordsTable extends EngineeringSnapshotRecords
    with
        TableInfo<$EngineeringSnapshotRecordsTable, EngineeringSnapshotRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EngineeringSnapshotRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _snapshotIdMeta = const VerificationMeta(
    'snapshotId',
  );
  @override
  late final GeneratedColumn<String> snapshotId = GeneratedColumn<String>(
    'snapshot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  List<GeneratedColumn> get $columns => [snapshotId, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'engineering_snapshot_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<EngineeringSnapshotRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('snapshot_id')) {
      context.handle(
        _snapshotIdMeta,
        snapshotId.isAcceptableOrUnknown(data['snapshot_id']!, _snapshotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
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
  Set<GeneratedColumn> get $primaryKey => {snapshotId};
  @override
  EngineeringSnapshotRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EngineeringSnapshotRecord(
      snapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EngineeringSnapshotRecordsTable createAlias(String alias) {
    return $EngineeringSnapshotRecordsTable(attachedDatabase, alias);
  }
}

class EngineeringSnapshotRecord extends DataClass
    implements Insertable<EngineeringSnapshotRecord> {
  final String snapshotId;
  final String payload;
  final DateTime updatedAt;
  const EngineeringSnapshotRecord({
    required this.snapshotId,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['snapshot_id'] = Variable<String>(snapshotId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EngineeringSnapshotRecordsCompanion toCompanion(bool nullToAbsent) {
    return EngineeringSnapshotRecordsCompanion(
      snapshotId: Value(snapshotId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory EngineeringSnapshotRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EngineeringSnapshotRecord(
      snapshotId: serializer.fromJson<String>(json['snapshotId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'snapshotId': serializer.toJson<String>(snapshotId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EngineeringSnapshotRecord copyWith({
    String? snapshotId,
    String? payload,
    DateTime? updatedAt,
  }) => EngineeringSnapshotRecord(
    snapshotId: snapshotId ?? this.snapshotId,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EngineeringSnapshotRecord copyWithCompanion(
    EngineeringSnapshotRecordsCompanion data,
  ) {
    return EngineeringSnapshotRecord(
      snapshotId: data.snapshotId.present
          ? data.snapshotId.value
          : this.snapshotId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EngineeringSnapshotRecord(')
          ..write('snapshotId: $snapshotId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(snapshotId, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EngineeringSnapshotRecord &&
          other.snapshotId == this.snapshotId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class EngineeringSnapshotRecordsCompanion
    extends UpdateCompanion<EngineeringSnapshotRecord> {
  final Value<String> snapshotId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EngineeringSnapshotRecordsCompanion({
    this.snapshotId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EngineeringSnapshotRecordsCompanion.insert({
    required String snapshotId,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : snapshotId = Value(snapshotId),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<EngineeringSnapshotRecord> custom({
    Expression<String>? snapshotId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (snapshotId != null) 'snapshot_id': snapshotId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EngineeringSnapshotRecordsCompanion copyWith({
    Value<String>? snapshotId,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EngineeringSnapshotRecordsCompanion(
      snapshotId: snapshotId ?? this.snapshotId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (snapshotId.present) {
      map['snapshot_id'] = Variable<String>(snapshotId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
    return (StringBuffer('EngineeringSnapshotRecordsCompanion(')
          ..write('snapshotId: $snapshotId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$EngineeringLocalDatabase extends GeneratedDatabase {
  _$EngineeringLocalDatabase(QueryExecutor e) : super(e);
  $EngineeringLocalDatabaseManager get managers =>
      $EngineeringLocalDatabaseManager(this);
  late final $EngineeringSnapshotRecordsTable engineeringSnapshotRecords =
      $EngineeringSnapshotRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    engineeringSnapshotRecords,
  ];
}

typedef $$EngineeringSnapshotRecordsTableCreateCompanionBuilder =
    EngineeringSnapshotRecordsCompanion Function({
      required String snapshotId,
      required String payload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EngineeringSnapshotRecordsTableUpdateCompanionBuilder =
    EngineeringSnapshotRecordsCompanion Function({
      Value<String> snapshotId,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$EngineeringSnapshotRecordsTableFilterComposer
    extends
        Composer<_$EngineeringLocalDatabase, $EngineeringSnapshotRecordsTable> {
  $$EngineeringSnapshotRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EngineeringSnapshotRecordsTableOrderingComposer
    extends
        Composer<_$EngineeringLocalDatabase, $EngineeringSnapshotRecordsTable> {
  $$EngineeringSnapshotRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EngineeringSnapshotRecordsTableAnnotationComposer
    extends
        Composer<_$EngineeringLocalDatabase, $EngineeringSnapshotRecordsTable> {
  $$EngineeringSnapshotRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EngineeringSnapshotRecordsTableTableManager
    extends
        RootTableManager<
          _$EngineeringLocalDatabase,
          $EngineeringSnapshotRecordsTable,
          EngineeringSnapshotRecord,
          $$EngineeringSnapshotRecordsTableFilterComposer,
          $$EngineeringSnapshotRecordsTableOrderingComposer,
          $$EngineeringSnapshotRecordsTableAnnotationComposer,
          $$EngineeringSnapshotRecordsTableCreateCompanionBuilder,
          $$EngineeringSnapshotRecordsTableUpdateCompanionBuilder,
          (
            EngineeringSnapshotRecord,
            BaseReferences<
              _$EngineeringLocalDatabase,
              $EngineeringSnapshotRecordsTable,
              EngineeringSnapshotRecord
            >,
          ),
          EngineeringSnapshotRecord,
          PrefetchHooks Function()
        > {
  $$EngineeringSnapshotRecordsTableTableManager(
    _$EngineeringLocalDatabase db,
    $EngineeringSnapshotRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EngineeringSnapshotRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EngineeringSnapshotRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EngineeringSnapshotRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> snapshotId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EngineeringSnapshotRecordsCompanion(
                snapshotId: snapshotId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String snapshotId,
                required String payload,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EngineeringSnapshotRecordsCompanion.insert(
                snapshotId: snapshotId,
                payload: payload,
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

typedef $$EngineeringSnapshotRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$EngineeringLocalDatabase,
      $EngineeringSnapshotRecordsTable,
      EngineeringSnapshotRecord,
      $$EngineeringSnapshotRecordsTableFilterComposer,
      $$EngineeringSnapshotRecordsTableOrderingComposer,
      $$EngineeringSnapshotRecordsTableAnnotationComposer,
      $$EngineeringSnapshotRecordsTableCreateCompanionBuilder,
      $$EngineeringSnapshotRecordsTableUpdateCompanionBuilder,
      (
        EngineeringSnapshotRecord,
        BaseReferences<
          _$EngineeringLocalDatabase,
          $EngineeringSnapshotRecordsTable,
          EngineeringSnapshotRecord
        >,
      ),
      EngineeringSnapshotRecord,
      PrefetchHooks Function()
    >;

class $EngineeringLocalDatabaseManager {
  final _$EngineeringLocalDatabase _db;
  $EngineeringLocalDatabaseManager(this._db);
  $$EngineeringSnapshotRecordsTableTableManager
  get engineeringSnapshotRecords =>
      $$EngineeringSnapshotRecordsTableTableManager(
        _db,
        _db.engineeringSnapshotRecords,
      );
}
