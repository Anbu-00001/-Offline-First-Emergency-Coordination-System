// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $IncidentsTable extends Incidents
    with TableInfo<$IncidentsTable, Incident> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncidentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reporter_idMeta = const VerificationMeta(
    'reporter_id',
  );
  @override
  late final GeneratedColumn<String> reporter_id = GeneratedColumn<String>(
    'reporter_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assigned_responder_idMeta =
      const VerificationMeta('assigned_responder_id');
  @override
  late final GeneratedColumn<String> assigned_responder_id =
      GeneratedColumn<String>(
        'assigned_responder_id',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _status_enumMeta = const VerificationMeta(
    'status_enum',
  );
  @override
  late final GeneratedColumn<String> status_enum = GeneratedColumn<String>(
    'status_enum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _client_idMeta = const VerificationMeta(
    'client_id',
  );
  @override
  late final GeneratedColumn<String> client_id = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequence_numMeta = const VerificationMeta(
    'sequence_num',
  );
  @override
  late final GeneratedColumn<int> sequence_num = GeneratedColumn<int>(
    'sequence_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deleted_flagMeta = const VerificationMeta(
    'deleted_flag',
  );
  @override
  late final GeneratedColumn<bool> deleted_flag = GeneratedColumn<bool>(
    'deleted_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted_flag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updated_atMeta = const VerificationMeta(
    'updated_at',
  );
  @override
  late final GeneratedColumn<DateTime> updated_at = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reporter_id,
    type,
    lat,
    lon,
    assigned_responder_id,
    priority,
    status_enum,
    client_id,
    sequence_num,
    deleted_flag,
    updated_at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incidents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Incident> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reporter_id')) {
      context.handle(
        _reporter_idMeta,
        reporter_id.isAcceptableOrUnknown(
          data['reporter_id']!,
          _reporter_idMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reporter_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('assigned_responder_id')) {
      context.handle(
        _assigned_responder_idMeta,
        assigned_responder_id.isAcceptableOrUnknown(
          data['assigned_responder_id']!,
          _assigned_responder_idMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('status_enum')) {
      context.handle(
        _status_enumMeta,
        status_enum.isAcceptableOrUnknown(
          data['status_enum']!,
          _status_enumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_status_enumMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _client_idMeta,
        client_id.isAcceptableOrUnknown(data['client_id']!, _client_idMeta),
      );
    } else if (isInserting) {
      context.missing(_client_idMeta);
    }
    if (data.containsKey('sequence_num')) {
      context.handle(
        _sequence_numMeta,
        sequence_num.isAcceptableOrUnknown(
          data['sequence_num']!,
          _sequence_numMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequence_numMeta);
    }
    if (data.containsKey('deleted_flag')) {
      context.handle(
        _deleted_flagMeta,
        deleted_flag.isAcceptableOrUnknown(
          data['deleted_flag']!,
          _deleted_flagMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updated_atMeta,
        updated_at.isAcceptableOrUnknown(data['updated_at']!, _updated_atMeta),
      );
    } else if (isInserting) {
      context.missing(_updated_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Incident map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Incident(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reporter_id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reporter_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      assigned_responder_id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_responder_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      status_enum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_enum'],
      )!,
      client_id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      sequence_num: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_num'],
      )!,
      deleted_flag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted_flag'],
      )!,
      updated_at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $IncidentsTable createAlias(String alias) {
    return $IncidentsTable(attachedDatabase, alias);
  }
}

class Incident extends DataClass implements Insertable<Incident> {
  final String id;
  final String reporter_id;
  final String type;
  final double lat;
  final double lon;
  final String? assigned_responder_id;
  final String priority;
  final String status_enum;
  final String client_id;
  final int sequence_num;
  final bool deleted_flag;
  final DateTime updated_at;
  const Incident({
    required this.id,
    required this.reporter_id,
    required this.type,
    required this.lat,
    required this.lon,
    this.assigned_responder_id,
    required this.priority,
    required this.status_enum,
    required this.client_id,
    required this.sequence_num,
    required this.deleted_flag,
    required this.updated_at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reporter_id'] = Variable<String>(reporter_id);
    map['type'] = Variable<String>(type);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    if (!nullToAbsent || assigned_responder_id != null) {
      map['assigned_responder_id'] = Variable<String>(assigned_responder_id);
    }
    map['priority'] = Variable<String>(priority);
    map['status_enum'] = Variable<String>(status_enum);
    map['client_id'] = Variable<String>(client_id);
    map['sequence_num'] = Variable<int>(sequence_num);
    map['deleted_flag'] = Variable<bool>(deleted_flag);
    map['updated_at'] = Variable<DateTime>(updated_at);
    return map;
  }

  IncidentsCompanion toCompanion(bool nullToAbsent) {
    return IncidentsCompanion(
      id: Value(id),
      reporter_id: Value(reporter_id),
      type: Value(type),
      lat: Value(lat),
      lon: Value(lon),
      assigned_responder_id: assigned_responder_id == null && nullToAbsent
          ? const Value.absent()
          : Value(assigned_responder_id),
      priority: Value(priority),
      status_enum: Value(status_enum),
      client_id: Value(client_id),
      sequence_num: Value(sequence_num),
      deleted_flag: Value(deleted_flag),
      updated_at: Value(updated_at),
    );
  }

  factory Incident.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Incident(
      id: serializer.fromJson<String>(json['id']),
      reporter_id: serializer.fromJson<String>(json['reporter_id']),
      type: serializer.fromJson<String>(json['type']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      assigned_responder_id: serializer.fromJson<String?>(
        json['assigned_responder_id'],
      ),
      priority: serializer.fromJson<String>(json['priority']),
      status_enum: serializer.fromJson<String>(json['status_enum']),
      client_id: serializer.fromJson<String>(json['client_id']),
      sequence_num: serializer.fromJson<int>(json['sequence_num']),
      deleted_flag: serializer.fromJson<bool>(json['deleted_flag']),
      updated_at: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reporter_id': serializer.toJson<String>(reporter_id),
      'type': serializer.toJson<String>(type),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'assigned_responder_id': serializer.toJson<String?>(
        assigned_responder_id,
      ),
      'priority': serializer.toJson<String>(priority),
      'status_enum': serializer.toJson<String>(status_enum),
      'client_id': serializer.toJson<String>(client_id),
      'sequence_num': serializer.toJson<int>(sequence_num),
      'deleted_flag': serializer.toJson<bool>(deleted_flag),
      'updated_at': serializer.toJson<DateTime>(updated_at),
    };
  }

  Incident copyWith({
    String? id,
    String? reporter_id,
    String? type,
    double? lat,
    double? lon,
    Value<String?> assigned_responder_id = const Value.absent(),
    String? priority,
    String? status_enum,
    String? client_id,
    int? sequence_num,
    bool? deleted_flag,
    DateTime? updated_at,
  }) => Incident(
    id: id ?? this.id,
    reporter_id: reporter_id ?? this.reporter_id,
    type: type ?? this.type,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    assigned_responder_id: assigned_responder_id.present
        ? assigned_responder_id.value
        : this.assigned_responder_id,
    priority: priority ?? this.priority,
    status_enum: status_enum ?? this.status_enum,
    client_id: client_id ?? this.client_id,
    sequence_num: sequence_num ?? this.sequence_num,
    deleted_flag: deleted_flag ?? this.deleted_flag,
    updated_at: updated_at ?? this.updated_at,
  );
  Incident copyWithCompanion(IncidentsCompanion data) {
    return Incident(
      id: data.id.present ? data.id.value : this.id,
      reporter_id: data.reporter_id.present
          ? data.reporter_id.value
          : this.reporter_id,
      type: data.type.present ? data.type.value : this.type,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      assigned_responder_id: data.assigned_responder_id.present
          ? data.assigned_responder_id.value
          : this.assigned_responder_id,
      priority: data.priority.present ? data.priority.value : this.priority,
      status_enum: data.status_enum.present
          ? data.status_enum.value
          : this.status_enum,
      client_id: data.client_id.present ? data.client_id.value : this.client_id,
      sequence_num: data.sequence_num.present
          ? data.sequence_num.value
          : this.sequence_num,
      deleted_flag: data.deleted_flag.present
          ? data.deleted_flag.value
          : this.deleted_flag,
      updated_at: data.updated_at.present
          ? data.updated_at.value
          : this.updated_at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Incident(')
          ..write('id: $id, ')
          ..write('reporter_id: $reporter_id, ')
          ..write('type: $type, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('assigned_responder_id: $assigned_responder_id, ')
          ..write('priority: $priority, ')
          ..write('status_enum: $status_enum, ')
          ..write('client_id: $client_id, ')
          ..write('sequence_num: $sequence_num, ')
          ..write('deleted_flag: $deleted_flag, ')
          ..write('updated_at: $updated_at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reporter_id,
    type,
    lat,
    lon,
    assigned_responder_id,
    priority,
    status_enum,
    client_id,
    sequence_num,
    deleted_flag,
    updated_at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Incident &&
          other.id == this.id &&
          other.reporter_id == this.reporter_id &&
          other.type == this.type &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.assigned_responder_id == this.assigned_responder_id &&
          other.priority == this.priority &&
          other.status_enum == this.status_enum &&
          other.client_id == this.client_id &&
          other.sequence_num == this.sequence_num &&
          other.deleted_flag == this.deleted_flag &&
          other.updated_at == this.updated_at);
}

class IncidentsCompanion extends UpdateCompanion<Incident> {
  final Value<String> id;
  final Value<String> reporter_id;
  final Value<String> type;
  final Value<double> lat;
  final Value<double> lon;
  final Value<String?> assigned_responder_id;
  final Value<String> priority;
  final Value<String> status_enum;
  final Value<String> client_id;
  final Value<int> sequence_num;
  final Value<bool> deleted_flag;
  final Value<DateTime> updated_at;
  final Value<int> rowid;
  const IncidentsCompanion({
    this.id = const Value.absent(),
    this.reporter_id = const Value.absent(),
    this.type = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.assigned_responder_id = const Value.absent(),
    this.priority = const Value.absent(),
    this.status_enum = const Value.absent(),
    this.client_id = const Value.absent(),
    this.sequence_num = const Value.absent(),
    this.deleted_flag = const Value.absent(),
    this.updated_at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncidentsCompanion.insert({
    required String id,
    required String reporter_id,
    required String type,
    required double lat,
    required double lon,
    this.assigned_responder_id = const Value.absent(),
    required String priority,
    required String status_enum,
    required String client_id,
    required int sequence_num,
    this.deleted_flag = const Value.absent(),
    required DateTime updated_at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reporter_id = Value(reporter_id),
       type = Value(type),
       lat = Value(lat),
       lon = Value(lon),
       priority = Value(priority),
       status_enum = Value(status_enum),
       client_id = Value(client_id),
       sequence_num = Value(sequence_num),
       updated_at = Value(updated_at);
  static Insertable<Incident> custom({
    Expression<String>? id,
    Expression<String>? reporter_id,
    Expression<String>? type,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? assigned_responder_id,
    Expression<String>? priority,
    Expression<String>? status_enum,
    Expression<String>? client_id,
    Expression<int>? sequence_num,
    Expression<bool>? deleted_flag,
    Expression<DateTime>? updated_at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reporter_id != null) 'reporter_id': reporter_id,
      if (type != null) 'type': type,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (assigned_responder_id != null)
        'assigned_responder_id': assigned_responder_id,
      if (priority != null) 'priority': priority,
      if (status_enum != null) 'status_enum': status_enum,
      if (client_id != null) 'client_id': client_id,
      if (sequence_num != null) 'sequence_num': sequence_num,
      if (deleted_flag != null) 'deleted_flag': deleted_flag,
      if (updated_at != null) 'updated_at': updated_at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncidentsCompanion copyWith({
    Value<String>? id,
    Value<String>? reporter_id,
    Value<String>? type,
    Value<double>? lat,
    Value<double>? lon,
    Value<String?>? assigned_responder_id,
    Value<String>? priority,
    Value<String>? status_enum,
    Value<String>? client_id,
    Value<int>? sequence_num,
    Value<bool>? deleted_flag,
    Value<DateTime>? updated_at,
    Value<int>? rowid,
  }) {
    return IncidentsCompanion(
      id: id ?? this.id,
      reporter_id: reporter_id ?? this.reporter_id,
      type: type ?? this.type,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      assigned_responder_id:
          assigned_responder_id ?? this.assigned_responder_id,
      priority: priority ?? this.priority,
      status_enum: status_enum ?? this.status_enum,
      client_id: client_id ?? this.client_id,
      sequence_num: sequence_num ?? this.sequence_num,
      deleted_flag: deleted_flag ?? this.deleted_flag,
      updated_at: updated_at ?? this.updated_at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reporter_id.present) {
      map['reporter_id'] = Variable<String>(reporter_id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (assigned_responder_id.present) {
      map['assigned_responder_id'] = Variable<String>(
        assigned_responder_id.value,
      );
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status_enum.present) {
      map['status_enum'] = Variable<String>(status_enum.value);
    }
    if (client_id.present) {
      map['client_id'] = Variable<String>(client_id.value);
    }
    if (sequence_num.present) {
      map['sequence_num'] = Variable<int>(sequence_num.value);
    }
    if (deleted_flag.present) {
      map['deleted_flag'] = Variable<bool>(deleted_flag.value);
    }
    if (updated_at.present) {
      map['updated_at'] = Variable<DateTime>(updated_at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentsCompanion(')
          ..write('id: $id, ')
          ..write('reporter_id: $reporter_id, ')
          ..write('type: $type, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('assigned_responder_id: $assigned_responder_id, ')
          ..write('priority: $priority, ')
          ..write('status_enum: $status_enum, ')
          ..write('client_id: $client_id, ')
          ..write('sequence_num: $sequence_num, ')
          ..write('deleted_flag: $deleted_flag, ')
          ..write('updated_at: $updated_at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entity_typeMeta = const VerificationMeta(
    'entity_type',
  );
  @override
  late final GeneratedColumn<String> entity_type = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entity_idMeta = const VerificationMeta(
    'entity_id',
  );
  @override
  late final GeneratedColumn<String> entity_id = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequence_numMeta = const VerificationMeta(
    'sequence_num',
  );
  @override
  late final GeneratedColumn<int> sequence_num = GeneratedColumn<int>(
    'sequence_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity_type,
    entity_id,
    operation,
    data,
    sequence_num,
    timestamp,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entity_typeMeta,
        entity_type.isAcceptableOrUnknown(
          data['entity_type']!,
          _entity_typeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entity_typeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entity_idMeta,
        entity_id.isAcceptableOrUnknown(data['entity_id']!, _entity_idMeta),
      );
    } else if (isInserting) {
      context.missing(_entity_idMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('sequence_num')) {
      context.handle(
        _sequence_numMeta,
        sequence_num.isAcceptableOrUnknown(
          data['sequence_num']!,
          _sequence_numMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequence_numMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entity_type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entity_id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      sequence_num: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_num'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entity_type;
  final String entity_id;
  final String operation;
  final String data;
  final int sequence_num;
  final DateTime timestamp;
  final String status;
  const SyncQueueData({
    required this.id,
    required this.entity_type,
    required this.entity_id,
    required this.operation,
    required this.data,
    required this.sequence_num,
    required this.timestamp,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entity_type);
    map['entity_id'] = Variable<String>(entity_id);
    map['operation'] = Variable<String>(operation);
    map['data'] = Variable<String>(data);
    map['sequence_num'] = Variable<int>(sequence_num);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entity_type: Value(entity_type),
      entity_id: Value(entity_id),
      operation: Value(operation),
      data: Value(data),
      sequence_num: Value(sequence_num),
      timestamp: Value(timestamp),
      status: Value(status),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entity_type: serializer.fromJson<String>(json['entity_type']),
      entity_id: serializer.fromJson<String>(json['entity_id']),
      operation: serializer.fromJson<String>(json['operation']),
      data: serializer.fromJson<String>(json['data']),
      sequence_num: serializer.fromJson<int>(json['sequence_num']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity_type': serializer.toJson<String>(entity_type),
      'entity_id': serializer.toJson<String>(entity_id),
      'operation': serializer.toJson<String>(operation),
      'data': serializer.toJson<String>(data),
      'sequence_num': serializer.toJson<int>(sequence_num),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entity_type,
    String? entity_id,
    String? operation,
    String? data,
    int? sequence_num,
    DateTime? timestamp,
    String? status,
  }) => SyncQueueData(
    id: id ?? this.id,
    entity_type: entity_type ?? this.entity_type,
    entity_id: entity_id ?? this.entity_id,
    operation: operation ?? this.operation,
    data: data ?? this.data,
    sequence_num: sequence_num ?? this.sequence_num,
    timestamp: timestamp ?? this.timestamp,
    status: status ?? this.status,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entity_type: data.entity_type.present
          ? data.entity_type.value
          : this.entity_type,
      entity_id: data.entity_id.present ? data.entity_id.value : this.entity_id,
      operation: data.operation.present ? data.operation.value : this.operation,
      data: data.data.present ? data.data.value : this.data,
      sequence_num: data.sequence_num.present
          ? data.sequence_num.value
          : this.sequence_num,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entity_type: $entity_type, ')
          ..write('entity_id: $entity_id, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('sequence_num: $sequence_num, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entity_type,
    entity_id,
    operation,
    data,
    sequence_num,
    timestamp,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entity_type == this.entity_type &&
          other.entity_id == this.entity_id &&
          other.operation == this.operation &&
          other.data == this.data &&
          other.sequence_num == this.sequence_num &&
          other.timestamp == this.timestamp &&
          other.status == this.status);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entity_type;
  final Value<String> entity_id;
  final Value<String> operation;
  final Value<String> data;
  final Value<int> sequence_num;
  final Value<DateTime> timestamp;
  final Value<String> status;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entity_type = const Value.absent(),
    this.entity_id = const Value.absent(),
    this.operation = const Value.absent(),
    this.data = const Value.absent(),
    this.sequence_num = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.status = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entity_type,
    required String entity_id,
    required String operation,
    required String data,
    required int sequence_num,
    required DateTime timestamp,
    this.status = const Value.absent(),
  }) : entity_type = Value(entity_type),
       entity_id = Value(entity_id),
       operation = Value(operation),
       data = Value(data),
       sequence_num = Value(sequence_num),
       timestamp = Value(timestamp);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entity_type,
    Expression<String>? entity_id,
    Expression<String>? operation,
    Expression<String>? data,
    Expression<int>? sequence_num,
    Expression<DateTime>? timestamp,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity_type != null) 'entity_type': entity_type,
      if (entity_id != null) 'entity_id': entity_id,
      if (operation != null) 'operation': operation,
      if (data != null) 'data': data,
      if (sequence_num != null) 'sequence_num': sequence_num,
      if (timestamp != null) 'timestamp': timestamp,
      if (status != null) 'status': status,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entity_type,
    Value<String>? entity_id,
    Value<String>? operation,
    Value<String>? data,
    Value<int>? sequence_num,
    Value<DateTime>? timestamp,
    Value<String>? status,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entity_type: entity_type ?? this.entity_type,
      entity_id: entity_id ?? this.entity_id,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      sequence_num: sequence_num ?? this.sequence_num,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity_type.present) {
      map['entity_type'] = Variable<String>(entity_type.value);
    }
    if (entity_id.present) {
      map['entity_id'] = Variable<String>(entity_id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (sequence_num.present) {
      map['sequence_num'] = Variable<int>(sequence_num.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entity_type: $entity_type, ')
          ..write('entity_id: $entity_id, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('sequence_num: $sequence_num, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IncidentsTable incidents = $IncidentsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [incidents, syncQueue];
}

typedef $$IncidentsTableCreateCompanionBuilder =
    IncidentsCompanion Function({
      required String id,
      required String reporter_id,
      required String type,
      required double lat,
      required double lon,
      Value<String?> assigned_responder_id,
      required String priority,
      required String status_enum,
      required String client_id,
      required int sequence_num,
      Value<bool> deleted_flag,
      required DateTime updated_at,
      Value<int> rowid,
    });
typedef $$IncidentsTableUpdateCompanionBuilder =
    IncidentsCompanion Function({
      Value<String> id,
      Value<String> reporter_id,
      Value<String> type,
      Value<double> lat,
      Value<double> lon,
      Value<String?> assigned_responder_id,
      Value<String> priority,
      Value<String> status_enum,
      Value<String> client_id,
      Value<int> sequence_num,
      Value<bool> deleted_flag,
      Value<DateTime> updated_at,
      Value<int> rowid,
    });

class $$IncidentsTableFilterComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reporter_id => $composableBuilder(
    column: $table.reporter_id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assigned_responder_id => $composableBuilder(
    column: $table.assigned_responder_id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status_enum => $composableBuilder(
    column: $table.status_enum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get client_id => $composableBuilder(
    column: $table.client_id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence_num => $composableBuilder(
    column: $table.sequence_num,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted_flag => $composableBuilder(
    column: $table.deleted_flag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updated_at => $composableBuilder(
    column: $table.updated_at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IncidentsTableOrderingComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reporter_id => $composableBuilder(
    column: $table.reporter_id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assigned_responder_id => $composableBuilder(
    column: $table.assigned_responder_id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status_enum => $composableBuilder(
    column: $table.status_enum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get client_id => $composableBuilder(
    column: $table.client_id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence_num => $composableBuilder(
    column: $table.sequence_num,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted_flag => $composableBuilder(
    column: $table.deleted_flag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated_at => $composableBuilder(
    column: $table.updated_at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncidentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncidentsTable> {
  $$IncidentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reporter_id => $composableBuilder(
    column: $table.reporter_id,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get assigned_responder_id => $composableBuilder(
    column: $table.assigned_responder_id,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status_enum => $composableBuilder(
    column: $table.status_enum,
    builder: (column) => column,
  );

  GeneratedColumn<String> get client_id =>
      $composableBuilder(column: $table.client_id, builder: (column) => column);

  GeneratedColumn<int> get sequence_num => $composableBuilder(
    column: $table.sequence_num,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted_flag => $composableBuilder(
    column: $table.deleted_flag,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updated_at => $composableBuilder(
    column: $table.updated_at,
    builder: (column) => column,
  );
}

class $$IncidentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncidentsTable,
          Incident,
          $$IncidentsTableFilterComposer,
          $$IncidentsTableOrderingComposer,
          $$IncidentsTableAnnotationComposer,
          $$IncidentsTableCreateCompanionBuilder,
          $$IncidentsTableUpdateCompanionBuilder,
          (Incident, BaseReferences<_$AppDatabase, $IncidentsTable, Incident>),
          Incident,
          PrefetchHooks Function()
        > {
  $$IncidentsTableTableManager(_$AppDatabase db, $IncidentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncidentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncidentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncidentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reporter_id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<String?> assigned_responder_id = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status_enum = const Value.absent(),
                Value<String> client_id = const Value.absent(),
                Value<int> sequence_num = const Value.absent(),
                Value<bool> deleted_flag = const Value.absent(),
                Value<DateTime> updated_at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncidentsCompanion(
                id: id,
                reporter_id: reporter_id,
                type: type,
                lat: lat,
                lon: lon,
                assigned_responder_id: assigned_responder_id,
                priority: priority,
                status_enum: status_enum,
                client_id: client_id,
                sequence_num: sequence_num,
                deleted_flag: deleted_flag,
                updated_at: updated_at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String reporter_id,
                required String type,
                required double lat,
                required double lon,
                Value<String?> assigned_responder_id = const Value.absent(),
                required String priority,
                required String status_enum,
                required String client_id,
                required int sequence_num,
                Value<bool> deleted_flag = const Value.absent(),
                required DateTime updated_at,
                Value<int> rowid = const Value.absent(),
              }) => IncidentsCompanion.insert(
                id: id,
                reporter_id: reporter_id,
                type: type,
                lat: lat,
                lon: lon,
                assigned_responder_id: assigned_responder_id,
                priority: priority,
                status_enum: status_enum,
                client_id: client_id,
                sequence_num: sequence_num,
                deleted_flag: deleted_flag,
                updated_at: updated_at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IncidentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncidentsTable,
      Incident,
      $$IncidentsTableFilterComposer,
      $$IncidentsTableOrderingComposer,
      $$IncidentsTableAnnotationComposer,
      $$IncidentsTableCreateCompanionBuilder,
      $$IncidentsTableUpdateCompanionBuilder,
      (Incident, BaseReferences<_$AppDatabase, $IncidentsTable, Incident>),
      Incident,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entity_type,
      required String entity_id,
      required String operation,
      required String data,
      required int sequence_num,
      required DateTime timestamp,
      Value<String> status,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entity_type,
      Value<String> entity_id,
      Value<String> operation,
      Value<String> data,
      Value<int> sequence_num,
      Value<DateTime> timestamp,
      Value<String> status,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity_type => $composableBuilder(
    column: $table.entity_type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity_id => $composableBuilder(
    column: $table.entity_id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence_num => $composableBuilder(
    column: $table.sequence_num,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity_type => $composableBuilder(
    column: $table.entity_type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity_id => $composableBuilder(
    column: $table.entity_id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence_num => $composableBuilder(
    column: $table.sequence_num,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity_type => $composableBuilder(
    column: $table.entity_type,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entity_id =>
      $composableBuilder(column: $table.entity_id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get sequence_num => $composableBuilder(
    column: $table.sequence_num,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entity_type = const Value.absent(),
                Value<String> entity_id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> sequence_num = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entity_type: entity_type,
                entity_id: entity_id,
                operation: operation,
                data: data,
                sequence_num: sequence_num,
                timestamp: timestamp,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entity_type,
                required String entity_id,
                required String operation,
                required String data,
                required int sequence_num,
                required DateTime timestamp,
                Value<String> status = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entity_type: entity_type,
                entity_id: entity_id,
                operation: operation,
                data: data,
                sequence_num: sequence_num,
                timestamp: timestamp,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IncidentsTableTableManager get incidents =>
      $$IncidentsTableTableManager(_db, _db.incidents);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
