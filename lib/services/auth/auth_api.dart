// lib/services/auth_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_learning_app/services/core/base_url.dart';

class AuthApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<bool> healthz() async {
    final r = await _dio.get('/healthz');
    return r.statusCode == 200 && r.data['ok'] == true;
  }

  Future<String?> login({required String account, required String password}) async {
    final r = await _dio.post('/v1/auth/login', data: {'account': account, 'password': password});
    return r.statusCode == 200 ? r.data['token'] as String? : null;
  }

  Future<String?> register({
    required String account,
    required String password,
    required String name,
    required String gender, // 'male' | 'female' | 'other'
    required String birthday, // 'YYYY-MM-DD'
  }) async {
    final r = await _dio.post(
      '/v1/auth/register',
      data: {'account': account, 'password': password, 'name': name, 'gender': gender, 'birthday': birthday},
    );
    return r.statusCode == 200 ? r.data['token'] as String? : null;
  }
}
