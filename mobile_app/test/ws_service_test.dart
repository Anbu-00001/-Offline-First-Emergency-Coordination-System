import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/ws_service.dart';
import 'package:mobile_app/core/auth_service.dart';
import 'package:mobile_app/data/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:async';

void main() {
  test('ws_service connects and receives messages', () async {
    FlutterSecureStorage.setMockInitialValues({});
    
    // Start local WS server
    final server = await HttpServer.bind('127.0.0.1', 0);
    server.listen((HttpRequest request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        final ws = await WebSocketTransformer.upgrade(request);
        ws.listen((data) {
          // Echo back
          ws.add(data);
        });
        ws.add('{"test": "ok"}');
      }
    });
    
    final db = AppDatabase.memory();
    final auth = AuthService();
    await auth.saveToken('test_token');
    
    final wsService = WsService('http://127.0.0.1:${server.port}', auth, db);
    
    // Listen for messages
    final completer = Completer<Map<String, dynamic>>();
    wsService.messages.listen((msg) {
      if (!completer.isCompleted) completer.complete(msg);
    });
    
    await wsService.connect();
    
    final msg = await completer.future.timeout(const Duration(seconds: 2));
    expect(msg['test'], 'ok');
    
    wsService.disconnect();
    await server.close(force: true);
    await db.close();
  });
}
