import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../models/models.dart' as domain;
import '../database.dart' as db;
import '../../core/api_client.dart';
import '../mappers/incident_mapper.dart';
import '../../services/p2p_service.dart';

class IncidentRepository {
  final db.AppDatabase _db;
  final ApiClient _apiClient;
  final P2PService _p2pService;

  IncidentRepository(this._db, this._apiClient, this._p2pService) {
    _p2pService.incomingIncidents.listen((dto) {
      _handleIncomingP2PIncident(dto);
    });
  }

  Stream<List<domain.Incident>> watchIncidents() {
    return (_db.select(_db.incidents)..where((t) => t.deleted_flag.equals(false)))
        .watch()
        .map((rows) => rows.map((r) => incidentFromDb(r)).toList());
  }

  Future<domain.Incident> getIncident(String id) async {
    final row = await (_db.select(_db.incidents)..where((t) => t.id.equals(id))).getSingle();
    return incidentFromDb(row);
  }

  Future<void> createIncident(domain.IncidentCreateDto dto) async {
    final localDocId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    
    // Broadcast immediately to peers
    final incidentToBroadcast = domain.Incident(
      id: localDocId,
      reporter_id: 'local_user', // This might be pulled from auth/context
      type: dto.type,
      lat: dto.lat,
      lon: dto.lon,
      priority: dto.priority,
      status: dto.status,
      client_id: dto.client_id,
      sequence_num: dto.sequence_num,
      updated_at: DateTime.now(),
    );
    _p2pService.broadcastIncident(incidentToBroadcast);

    await _db.transaction(() async {
      await _db.into(_db.incidents).insert(
        db.IncidentsCompanion.insert(
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
        db.SyncQueueCompanion.insert(
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

    final changes = pendingChanges.map((q) => domain.LocalChange(
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
              .write(const db.SyncQueueCompanion(status: Value('sent')));
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

  Future<void> _upsertIncidentFromServer(domain.Incident serverIncident) async {
    await _db.into(_db.incidents).insertOnConflictUpdate(
      incidentToDbCompanion(serverIncident),
    );
  }

  /// Handles an incoming P2P incident from the network.
  ///
  /// Uses the incident_id from the envelope payload as the DB primary key
  /// to enable DB-level deduplication. If an incident with the same ID already
  /// exists, the insert is skipped.
  Future<void> _handleIncomingP2PIncident(domain.IncidentCreateDto dto) async {
    // Extract incident_id from envelope metadata (passed through dto.data)
    final String incidentId = dto.data?['incident_id'] as String? ??
        'p2p_${DateTime.now().millisecondsSinceEpoch}';

    // DB-level dedup: check if this incident already exists
    final existing = await (_db.select(_db.incidents)
          ..where((t) => t.id.equals(incidentId)))
        .get();

    if (existing.isNotEmpty) {
      debugPrint(
          '[IncidentRepo] Duplicate incident skipped: $incidentId (already in DB)');
      return;
    }

    // Insert the new incident
    await _db.into(_db.incidents).insert(
      db.IncidentsCompanion.insert(
        id: incidentId,
        reporter_id: dto.client_id,
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

    debugPrint(
        '[IncidentRepo] P2P incident inserted: $incidentId');
  }
}
