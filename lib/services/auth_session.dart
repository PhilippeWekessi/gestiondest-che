import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthSession {
  String? token;
  UserProfile? user;

  bool get isAuthenticated => token != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');
    if (userJson != null) {
      user = UserProfile.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> save({required String token, required UserProfile user}) async {
    this.token = token;
    this.user = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_user', jsonEncode(user.toJson()));
  }

  Future<void> updateUser(UserProfile user) async {
    this.user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    token = null;
    user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
  }
}