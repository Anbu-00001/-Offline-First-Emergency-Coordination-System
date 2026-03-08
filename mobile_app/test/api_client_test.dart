import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/auth_service.dart';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;
  
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    lastOptions = options;
    return ResponseBody.fromString('[]', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
  
  @override
  void close({bool force = false}) {}
}

void main() {
  test('listIncidents calls correct path', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final adapter = MockAdapter();
    final client = ApiClient(baseUrl: 'http://test', authService: AuthService());
    client.dio.httpClientAdapter = adapter;
    
    await client.listIncidents();
    
    expect(adapter.lastOptions?.path, '/incidents');
  });
}
