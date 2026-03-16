import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../models/network_envelope.dart';
import 'message_cache.dart';

/// Service responsible for communicating with the local Go P2P Daemon.
///
/// Features:
/// - Envelope-based messaging (NetworkEnvelope)
/// - Deduplication via MessageCache
/// - Outgoing message queue for offline resilience
/// - Automatic reconnection with queued message flush
class P2PService {
  final String hostUrl;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  final StreamController<NetworkEnvelope> _envelopeStreamController =
      StreamController<NetworkEnvelope>.broadcast();

  /// Legacy stream for backward compatibility with IncidentRepository
  final StreamController<IncidentCreateDto> _incidentStreamController =
      StreamController<IncidentCreateDto>.broadcast();

  /// Message deduplication cache (LRU, 1000 entries)
  final MessageCache _messageCache = MessageCache(maxSize: 1000);

  /// Outgoing message queue for when the connection is unavailable
  final List<NetworkEnvelope> _outgoingQueue = [];

  P2PService({required this.hostUrl});

  /// The stream of incidents received from the P2P network
  Stream<IncidentCreateDto> get incomingIncidents =>
      _incidentStreamController.stream;

  /// The stream of raw envelopes received from the P2P network
  Stream<NetworkEnvelope> get incomingEnvelopes =>
      _envelopeStreamController.stream;

  /// Whether the WebSocket connection is currently active
  bool get isConnected => _isConnected;

  /// Number of messages waiting in the outgoing queue
  int get outgoingQueueLength => _outgoingQueue.length;

  /// Connects to the local daemon's WebSocket endpoint for receiving messages
  void connect() {
    final wsBase = hostUrl.replaceFirst('http', 'ws');
    final wsUrl = Uri.parse('$wsBase:7000/events');

    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;
      debugPrint('[P2P] Connected to WebSocket at $wsUrl');

      // Flush any queued outgoing messages
      _flushOutgoingQueue();

      _channel!.stream.listen(
        (message) {
          _handleIncomingMessage(message);
        },
        onError: (error) {
          debugPrint('[P2P] WebSocket error: $error');
          _isConnected = false;
          _reconnect();
        },
        onDone: () {
          debugPrint('[P2P] WebSocket closed');
          _isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      debugPrint('[P2P] Connection failed: $e');
      _isConnected = false;
      _reconnect();
    }
  }

  /// Handles an incoming WebSocket message, parsing it as a NetworkEnvelope
  void _handleIncomingMessage(dynamic message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final envelope = NetworkEnvelope.fromJson(data);

      // Deduplication check
      if (_messageCache.isDuplicate(envelope.msgId)) {
        debugPrint(
            '[P2P] Duplicate ignored: msg_id=${envelope.msgId} from ${envelope.originPeer}');
        return;
      }

      debugPrint(
          '[P2P] Received: msg_id=${envelope.msgId} msg_type=${envelope.msgType} from ${envelope.originPeer}');

      // Forward the raw envelope
      _envelopeStreamController.add(envelope);

      // Convert to IncidentCreateDto for backward-compatible repository integration
      if (envelope.msgType == 'incident_create') {
        final payload = envelope.payload;
        final dto = IncidentCreateDto(
          type: payload['type'] as String? ?? 'incident_create',
          lat: (payload['lat'] as num?)?.toDouble() ?? 0.0,
          lon: (payload['lon'] as num?)?.toDouble() ?? 0.0,
          priority: payload['priority'] as String? ?? 'medium',
          status: 'new',
          client_id: payload['device_id'] as String? ?? envelope.originPeer,
          sequence_num: 1,
          data: {
            'msg_id': envelope.msgId,
            'origin_peer': envelope.originPeer,
            'incident_id': payload['incident_id'] as String? ?? envelope.msgId,
          },
        );
        _incidentStreamController.add(dto);
      }
    } catch (e) {
      debugPrint('[P2P] Failed to parse incoming message: $e');
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_channel != null && _channel!.closeCode == null) return;
      debugPrint('[P2P] Attempting to reconnect...');
      connect();
    });
  }

  /// Flushes queued outgoing messages in order
  Future<void> _flushOutgoingQueue() async {
    if (_outgoingQueue.isEmpty) return;

    debugPrint('[P2P] Flushing ${_outgoingQueue.length} queued messages');
    final toFlush = List<NetworkEnvelope>.from(_outgoingQueue);
    _outgoingQueue.clear();

    for (final envelope in toFlush) {
      await _sendEnvelopeHttp(envelope);
    }
  }

  /// Sends a NetworkEnvelope via HTTP POST to the daemon
  Future<bool> _sendEnvelopeHttp(NetworkEnvelope envelope) async {
    final uri = Uri.parse('$hostUrl:7000/broadcast');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(envelope.toJson()),
      );

      if (response.statusCode == 202) {
        debugPrint(
            '[P2P] Broadcasted: msg_id=${envelope.msgId} msg_type=${envelope.msgType}');
        return true;
      } else {
        debugPrint(
            '[P2P] Broadcast failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('[P2P] Failed to broadcast: $e');
      return false;
    }
  }

  /// Broadcasts an incident to the P2P network using the local daemon.
  ///
  /// Wraps the incident in a NetworkEnvelope. If the connection is unavailable,
  /// the message is queued and will be sent when reconnected.
  Future<void> broadcastIncident(Incident incident) async {
    final envelope = NetworkEnvelope(
      msgId: 'msg_${DateTime.now().millisecondsSinceEpoch}_${incident.id.hashCode.abs()}',
      msgType: 'incident_create',
      originPeer: '', // Will be stamped by the Go daemon
      timestamp: incident.updated_at.millisecondsSinceEpoch ~/ 1000,
      payload: {
        'type': incident.type,
        'incident_id': incident.id,
        'lat': incident.lat,
        'lon': incident.lon,
        'priority': incident.priority,
        'timestamp': incident.updated_at.millisecondsSinceEpoch ~/ 1000,
        'device_id': incident.reporter_id,
      },
    );

    // Add to our own dedup cache to prevent self-echo
    _messageCache.isDuplicate(envelope.msgId);

    final success = await _sendEnvelopeHttp(envelope);
    if (!success) {
      debugPrint('[P2P] Queuing message for later delivery: msg_id=${envelope.msgId}');
      _outgoingQueue.add(envelope);
    }
  }

  void dispose() {
    _channel?.sink.close();
    _envelopeStreamController.close();
    _incidentStreamController.close();
  }
}
