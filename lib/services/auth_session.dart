import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class AuthSession {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  String? token;
  UserProfile? user;

  bool get isAuthenticated => token != null && user != null;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    token = preferences.getString(_tokenKey);
    final rawUser = preferences.getString(_userKey);
    if (rawUser != null) {
      user = UserProfile.fromJson(jsonDecode(rawUser));
    }
  }

  Future<void> save(String newToken, UserProfile profile) async {
    token = newToken;
    user = profile;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, newToken);
    await preferences.setString(_userKey, jsonEncode(profile.toJson()));
  }

  Future<void> updateUser(UserProfile profile) async {
    user = profile;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userKey, jsonEncode(profile.toJson()));
  }

  Future<void> clear() async {
    token = null;
    user = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_userKey);
  }
}
