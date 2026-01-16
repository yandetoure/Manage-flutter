import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.read(apiClientProvider), ref));

class AuthRepository {
  final ApiClient _apiClient;
  final Ref _ref; // Keep ref if needed for other providers
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._apiClient, this._ref);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.client.post('/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      final user = response.data['user'];

      await _storage.write(key: 'auth_token', value: token);
      // Save user info if needed
      
      return response.data;
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.client.post('/logout');
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}
