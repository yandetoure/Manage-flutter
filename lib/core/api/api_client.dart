import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000/api',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
}

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
