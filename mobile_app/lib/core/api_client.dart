import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';

import '../models/models.dart';
import 'auth_service.dart';

class ApiClient {
  late final Dio _dio;
  final AuthService _authService;
  final String _baseUrl;

  ApiClient({required String baseUrl, required AuthService authService})
      : _baseUrl = baseUrl,
        _authService = authService {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
    
    // Add Retry Interceptor
    _dio.interceptors.add(_retryInterceptor());
  }

  @visibleForTesting
  Dio get dio => _dio;

  Interceptor _retryInterceptor() {
    return InterceptorsWrapper(
      onError: (err, handler) async {
        if (_shouldRetry(err)) {
          final retries = err.requestOptions.extra['retries'] ?? 0;
          if (retries < 3) {
            final delay = Duration(milliseconds: (pow(2, retries) * 1000).toInt());
            debugPrint('API Error: ${err.message}. Retrying in ${delay.inSeconds}s (attempt ${retries + 1})...');
            await Future.delayed(delay);
            
            err.requestOptions.extra['retries'] = retries + 1;
            try {
              final response = await _dio.fetch(err.requestOptions);
              return handler.resolve(response);
            } catch (retryErr) {
              if (retryErr is DioException) {
                return handler.next(retryErr);
              }
            }
          }
        }
        return handler.next(err);
      },
    );
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  Future<Health> health() async {
    final response = await _dio.get('/health');
    return Health.fromJson(response.data);
  }

  Future<AuthResponse> login(String email, String password) async {
    // Standard OAuth2 password flow format expected by FastAPI
    final formData = FormData.fromMap({
      'username': email,
      'password': password,
    });
    
    final response = await _dio.post(
      '/auth/login', // Use standard auth path, or configure below if it differs
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<List<Incident>> listIncidents({Map<String, dynamic>? filters}) async {
    final response = await _dio.get('/incidents', queryParameters: filters);
    final List data = response.data;
    return data.map((e) => Incident.fromJson(e)).toList();
  }

  Future<Incident> createIncident(IncidentCreateDto dto) async {
    final response = await _dio.post('/incidents', data: dto.toJson());
    return Incident.fromJson(response.data);
  }

  Future<SyncResult> syncIncidents(List<LocalChange> changes) async {
    final data = {
      'changes': changes.map((c) => c.toJson()).toList(),
    };
    final response = await _dio.post('/sync/incidents', data: data);
    return SyncResult.fromJson(response.data);
  }
}
