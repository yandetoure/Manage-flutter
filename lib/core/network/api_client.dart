import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider((ref) => ApiClient(ref));

class ApiClient {
  final Dio _dio;
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  // Assuming local development for now
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  ApiClient(this._ref)
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Accept': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors like 401 Unauthorized
        if (e.response?.statusCode == 401) {
            // Trigger logout logic via provider if needed
        }
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
}
