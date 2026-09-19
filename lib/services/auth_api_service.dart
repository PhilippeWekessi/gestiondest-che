import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'auth_session.dart';

class AuthApiService {
  final AuthSession session;
  AuthApiService(this.session);

  static const String baseUrl = 'http://localhost:8000/api/auth';

  Future<void> register({
    required String nom,
    required String prenom,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': '$prenom $nom',
        'phone': phone,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await session.save(
        token: data['token'],
        user: UserProfile.fromJson(data['user']),
      );
      return;
    }
    throw Exception(_extractError(response));
  }

  Future<void> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await session.save(
        token: data['token'],
        user: UserProfile.fromJson(data['user']),
      );
      return;
    }
    throw Exception(_extractError(response));
  }

  Future<void> logout() async {
    if (session.token != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.token}',
        },
      );
    }
    await session.clear();
  }

  Future<void> updateProfile(UserProfile profile) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.token}',
      },
      body: jsonEncode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      await session.updateUser(UserProfile.fromJson(data));
      return;
    }
    throw Exception(_extractError(response));
  }

  String _extractError(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['message'] != null) return data['message'];
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        return errors.values.first[0];
      }
    } catch (_) {}
    return 'Une erreur est survenue (${response.statusCode})';
  }
}