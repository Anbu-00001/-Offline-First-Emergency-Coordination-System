// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Health _$HealthFromJson(Map<String, dynamic> json) => Health(
  status: json['status'] as String,
  service: json['service'] as String,
);

Map<String, dynamic> _$HealthToJson(Health instance) => <String, dynamic>{
  'status': instance.status,
  'service': instance.service,
};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  access_token: json['access_token'] as String,
  token_type: json['token_type'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.access_token,
      'token_type': instance.token_type,
    };

Incident _$IncidentFromJson(Map<String, dynamic> json) => Incident(
  id: json['id'] as String,
  reporter_id: json['reporter_id'] as String,
  type: json['type'] as String,
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
  assigned_responder_id: json['assigned_responder_id'] as String?,
  priority: json['priority'] as String,
  status: json['status'] as String,
  client_id: json['client_id'] as String,
  sequence_num: (json['sequence_num'] as num).toInt(),
  deleted: json['deleted'] as bool? ?? false,
  updated_at: DateTime.parse(json['updated_at'] as String),
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$IncidentToJson(Incident instance) => <String, dynamic>{
  'id': instance.id,
  'reporter_id': instance.reporter_id,
  'type': instance.type,
  'lat': instance.lat,
  'lon': instance.lon,
  'assigned_responder_id': instance.assigned_responder_id,
  'priority': instance.priority,
  'status': instance.status,
  'client_id': instance.client_id,
  'sequence_num': instance.sequence_num,
  'deleted': instance.deleted,
  'updated_at': instance.updated_at.toIso8601String(),
  'data': instance.data,
};

IncidentCreateDto _$IncidentCreateDtoFromJson(Map<String, dynamic> json) =>
    IncidentCreateDto(
      type: json['type'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      priority: json['priority'] as String,
      status: json['status'] as String,
      client_id: json['client_id'] as String,
      sequence_num: (json['sequence_num'] as num).toInt(),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$IncidentCreateDtoToJson(IncidentCreateDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'lat': instance.lat,
      'lon': instance.lon,
      'priority': instance.priority,
      'status': instance.status,
      'client_id': instance.client_id,
      'sequence_num': instance.sequence_num,
      'data': instance.data,
    };

LocalChange _$LocalChangeFromJson(Map<String, dynamic> json) => LocalChange(
  entity_type: json['entity_type'] as String,
  entity_id: json['entity_id'] as String,
  operation: json['operation'] as String,
  data: json['data'] as Map<String, dynamic>,
  sequence_num: (json['sequence_num'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$LocalChangeToJson(LocalChange instance) =>
    <String, dynamic>{
      'entity_type': instance.entity_type,
      'entity_id': instance.entity_id,
      'operation': instance.operation,
      'data': instance.data,
      'sequence_num': instance.sequence_num,
      'timestamp': instance.timestamp.toIso8601String(),
    };

SyncResult _$SyncResultFromJson(Map<String, dynamic> json) => SyncResult(
  accepted: (json['accepted'] as List<dynamic>)
      .map((e) => Incident.fromJson(e as Map<String, dynamic>))
      .toList(),
  conflicts: (json['conflicts'] as List<dynamic>)
      .map((e) => Incident.fromJson(e as Map<String, dynamic>))
      .toList(),
  errors: (json['errors'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  current_server_sequence: (json['current_server_sequence'] as num).toInt(),
);

Map<String, dynamic> _$SyncResultToJson(SyncResult instance) =>
    <String, dynamic>{
      'accepted': instance.accepted.map((e) => e.toJson()).toList(),
      'conflicts': instance.conflicts.map((e) => e.toJson()).toList(),
      'errors': instance.errors,
      'current_server_sequence': instance.current_server_sequence,
    };
