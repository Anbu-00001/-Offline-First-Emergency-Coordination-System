import 'package:drift/drift.dart';
import 'dart:convert';
import '../../models/models.dart' as models;
import '../database.dart';
import '../../core/api_client.dart';

class IncidentRepository {
  final AppDatabase _db;
  final ApiClient _apiClient;

  IncidentRepository(this._db, this._apiClient);

  Stream<List<Incident>> watchIncidents() {
    return (_db.select(_db.incidents)..where((t) => t.deleted_flag.equals(false)))
        .watch();
  }

  Future<Incident> getIncident(String id) async {
    return await (_db.select(_db.incidents)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> createIncident(models.IncidentCreateDto dto) async {
    final localDocId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    
    await _db.transaction(() async {
      await _db.into(_db.incidents).insert(
        IncidentsCompanion.insert(
          id: localDocId,
          reporter_id: 'local_user', // This might be pulled from auth/context
          type: dto.type,
          lat: dto.lat,
          lon: dto.lon,
          priority: dto.priority,
          status_enum: dto.status,
          client_id: dto.client_id,
          sequence_num: dto.sequence_num,
          updated_at: DateTime.now(),
        ),
      );

      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          entity_type: 'Incident',
          entity_id: localDocId,
          operation: 'CREATE',
          data: jsonEncode(dto.toJson()),
          sequence_num: dto.sequence_num,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> pushLocalChanges() async {
    final pendingChanges = await (_db.select(_db.syncQueue)..where((t) => t.status.equals('queued'))).get();
    if (pendingChanges.isEmpty) return;

    final changes = pendingChanges.map((q) => models.LocalChange(
      entity_type: q.entity_type,
      entity_id: q.entity_id,
      operation: q.operation,
      data: jsonDecode(q.data),
      sequence_num: q.sequence_num,
      timestamp: q.timestamp,
    )).toList();

    try {
      final syncResult = await _apiClient.syncIncidents(changes);
      
      await _db.transaction(() async {
        // Mark as sent
        for (var q in pendingChanges) {
          await (_db.update(_db.syncQueue)..where((t) => t.id.equals(q.id)))
              .write(const SyncQueueCompanion(status: Value('sent')));
        }
        
        // Update local DB with server definitive source of truth
        for (var i in syncResult.accepted) {
          await _upsertIncidentFromServer(i);
        }
        for (var i in syncResult.conflicts) {
          await _upsertIncidentFromServer(i); // Last-writer-wins dictates using server's version here
        }
      });
    } catch (e) {
      // Failed to push (e.g. offline), keeps 'queued'
      print('Sync failed, will retry later: $e');
    }
  }

  Future<void> _upsertIncidentFromServer(models.Incident serverIncident) async {
    await _db.into(_db.incidents).insertOnConflictUpdate(
      IncidentsCompanion.insert(
        id: serverIncident.id,
        reporter_id: serverIncident.reporter_id,
        type: serverIncident.type,
        lat: serverIncident.lat,
        lon: serverIncident.lon,
        assigned_responder_id: Value(serverIncident.assigned_responder_id),
        priority: serverIncident.priority,
        status_enum: serverIncident.status,
        client_id: serverIncident.client_id,
        sequence_num: serverIncident.sequence_num,
        deleted_flag: Value(serverIncident.deleted),
        updated_at: serverIncident.updated_at,
      ),
    );
  }
}
