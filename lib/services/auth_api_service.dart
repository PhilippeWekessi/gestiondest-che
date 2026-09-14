import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import 'auth_session.dart';

class AuthApiService {
  static const baseUrl = 'http://10.0.2.2:8000/api';

  final AuthSession session;

  const AuthApiService(this.session);

  Future<void> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );
    _ensureSuccess(response);
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );
    _ensureSuccess(response);
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    await session.save(
      data['token'] as String,
      UserProfile.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: _authHeaders,
      body: jsonEncode(profile.toJson()),
    );
    _ensureSuccess(response);
    final updated = UserProfile.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
    await session.updateUser(updated);
    return updated;
  }

  Future<void> logout() async {
    if (session.token != null) {
      await http.post(Uri.parse('$baseUrl/auth/logout'), headers: _authHeaders);
    }
    await session.clear();
  }

  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Map<String, String> get _authHeaders => {
    ..._jsonHeaders,
    'Authorization': 'Bearer ${session.token}',
  };

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    try {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final errors = data['errors'] as Map<String, dynamic>?;
      final firstError = errors?.values.first;
      throw Exception(
        firstError is List
            ? firstError.first
            : data['message'] ?? 'Erreur API.',
      );
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('Erreur API (${response.statusCode}).');
    }
  }
}
