/// Standardized network envelope for P2P message exchange.
///
/// This format is shared between the Go daemon and Flutter P2PService.
/// Designed for forward compatibility — unknown fields in [payload] are preserved.
class NetworkEnvelope {
  final String msgId;
  final String msgType;
  final String originPeer;
  final int timestamp;
  final Map<String, dynamic> payload;

  NetworkEnvelope({
    required this.msgId,
    required this.msgType,
    required this.originPeer,
    required this.timestamp,
    required this.payload,
  });

  factory NetworkEnvelope.fromJson(Map<String, dynamic> json) {
    return NetworkEnvelope(
      msgId: json['msg_id'] as String? ?? '',
      msgType: json['msg_type'] as String? ?? 'unknown',
      originPeer: json['origin_peer'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      payload: json['payload'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg_id': msgId,
      'msg_type': msgType,
      'origin_peer': originPeer,
      'timestamp': timestamp,
      'payload': payload,
    };
  }

  @override
  String toString() =>
      'NetworkEnvelope(msgId: $msgId, msgType: $msgType, originPeer: $originPeer)';
}
