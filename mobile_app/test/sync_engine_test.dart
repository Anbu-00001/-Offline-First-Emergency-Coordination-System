import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/services/p2p_service.dart';
import 'package:mobile_app/models/network_envelope.dart';

void main() {
  group('Sync Engine Tests (Day 20)', () {
    late P2PService serviceA;
    late HttpServer mockDaemon;
    WebSocket? activeWs;
    late List<NetworkEnvelope> broadcastCaptured;

    setUp(() async {
      broadcastCaptured = [];
      activeWs = null;

      mockDaemon = await HttpServer.bind('127.0.0.1', 0);
      
      mockDaemon.listen((req) async {
        if (req.uri.path == '/broadcast') {
          final body = await utf8.decoder.bind(req).join();
          final json = jsonDecode(body);
          broadcastCaptured.add(NetworkEnvelope.fromJson(json));
          req.response.statusCode = 202;
          req.response.close();
        } else if (req.uri.path == '/events' && WebSocketTransformer.isUpgradeRequest(req)) {
          activeWs = await WebSocketTransformer.upgrade(req);
        } else {
          req.response.statusCode = 404;
          req.response.close();
        }
      });

      serviceA = P2PService(hostUrl: 'http://127.0.0.1', port: mockDaemon.port);
      serviceA.connect();
      // Give WS time to connect
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() async {
      serviceA.dispose();
      await activeWs?.close();
      await mockDaemon.close(force: true);
    });

    void injectFromB(Map<String, dynamic> msg) {
      if (msg['origin_peer'] == null) msg['origin_peer'] = 'peer_B';
      activeWs?.add(jsonEncode(msg));
    }

    test('Two-device sync: ensure no repeated requests', () async {
      injectFromB({
        'msg_id': 'h1',
        'msg_type': 'head_exchange',
        'origin_peer': 'peer_B',
        'timestamp': 1000,
        'payload': { 'heads': ['m1'] }
      });
      await Future.delayed(const Duration(milliseconds: 50));

      expect(broadcastCaptured.length, 1);
      expect(broadcastCaptured.last.msgType, 'message_request');
      expect(broadcastCaptured.last.payload['requested_ids'], ['m1']);
      
      broadcastCaptured.clear();

      injectFromB({
        'msg_id': 'h2',
        'msg_type': 'head_exchange',
        'origin_peer': 'peer_B',
        'timestamp': 1001,
        'payload': { 'heads': ['m1'] }
      });
      await Future.delayed(const Duration(milliseconds: 50));

      // Should skip requesting duplicate m1
      expect(broadcastCaptured.length, 0);
    });

    test('Three-device cascade: A -> B -> C convergence ensuring deduplication', () async {
      // B sends m1 to A
      injectFromB({
        'msg_id': 'm1',
        'msg_type': 'incident_create',
        'origin_peer': 'peer_B',
        'clock': 1,
        'payload': {}
      });
      await Future.delayed(const Duration(milliseconds: 50));
      broadcastCaptured.clear();

      // C asks A for m1
      injectFromB({
        'msg_id': 'req1',
        'msg_type': 'message_request',
        'origin_peer': 'peer_C',
        'timestamp': 1000,
        'payload': {
           'requested_ids': ['m1']
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));

      expect(broadcastCaptured.length, 1);
      expect(broadcastCaptured.last.msgType, 'message_response');
      
      broadcastCaptured.clear();

      // C asks A for m1 AGAIN. A should deduplicate and send nothing.
      injectFromB({
        'msg_id': 'req2',
        'msg_type': 'message_request',
        'origin_peer': 'peer_C',
        'timestamp': 1001,
        'payload': {
           'requested_ids': ['m1']
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(broadcastCaptured.length, 0);
    });

    test('Large DAG: batch requests work', () async {
      injectFromB({
        'msg_id': 'hx1',
        'msg_type': 'head_exchange',
        'origin_peer': 'peer_B',
        'timestamp': 1000,
        'payload': { 'heads': ['m100'] }
      });
      await Future.delayed(const Duration(milliseconds: 50));
      expect(broadcastCaptured.length, 1);
      expect(broadcastCaptured.last.msgType, 'message_request');
      broadcastCaptured.clear();

      // Peer B responds with m100, which has two missing dependencies
      injectFromB({
        'msg_id': 'resp1',
        'msg_type': 'message_response',
        'origin_peer': 'peer_B',
        'timestamp': 1000,
        'payload': {
           'messages': [
             {
               'msg_id': 'm100',
               'msg_type': 'incident_create',
               'origin_peer': 'peer_B',
               'clock': 100,
               'prev_msg_ids': ['m98', 'm99'],
               'payload': {}
             }
           ]
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));

      // Should request m98 and m99 in a single batched message request
      expect(broadcastCaptured.length, 1);
      expect(broadcastCaptured.last.msgType, 'message_request');
      final requestedIds = broadcastCaptured.last.payload['requested_ids'] as List;
      expect(requestedIds.length, 2);
      expect(requestedIds.contains('m98'), true);
      expect(requestedIds.contains('m99'), true);
    });

    test('Partial network delay: limit iterations and terminatation', () async {
      // To trigger a cascade of missing dependency resolutions up to limits:
      // m15 depends on m14...
      // We start by injecting m15 which is missing m14.
      injectFromB({
        'msg_id': 'resp_init',
        'msg_type': 'message_response',
        'origin_peer': 'peer_B',
        'timestamp': 1000,
        'payload': {
          'messages': [
            {
              'msg_id': 'm_15',
              'msg_type': 'incident_create',
              'origin_peer': 'peer_B',
              'clock': 15,
              'prev_msg_ids': ['m_14'],
              'payload': {}
            }
          ]
        }
      });
      await Future.delayed(const Duration(milliseconds: 20));

      for (int i=14; i>=0; i--) {
        injectFromB({
          'msg_id': 'resp_$i',
          'msg_type': 'message_response',
          'origin_peer': 'peer_B',
          'timestamp': 1000,
          'payload': {
            'messages': [
              {
                'msg_id': 'm_$i',
                'msg_type': 'incident_create',
                'origin_peer': 'peer_B',
                'clock': i,
                'prev_msg_ids': ['m_${i-1}'],
                'payload': {}
              }
            ]
          }
        });
        await Future.delayed(const Duration(milliseconds: 20)); 
      }
      
      // Each injected message generates a missing dependency if it's the tip.
      // E.g., receiving m14 triggers request for m13.
      // But P2PService iterates and checks session.iterationCount >= 10.
      int requests = broadcastCaptured.where((e) => e.msgType == 'message_request').length;
      expect(requests, lessThanOrEqualTo(10)); // sync bounded at 10 iterations!
    });
  });
}
