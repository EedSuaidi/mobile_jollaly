import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';
  static const _userIdKey = 'auth_user_id';

  // Determine a sensible base URL across platforms
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static String get apiBase => '$baseUrl/api';

  Future<({String token, String email, String userId})> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$apiBase/auth/login');
    final resp = await http.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;

    if (resp.statusCode == 200 && decoded['success'] == true) {
      final data = decoded['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userId = data['userId'] as String;
      final emailResp = data['email'] as String;
      await _saveSession(token: token, email: emailResp, userId: userId);
      return (token: token, email: emailResp, userId: userId);
    }

    throw Exception(decoded['message'] ?? 'Login failed');
  }

  Future<({String userId, String name, String email})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$apiBase/auth/register');
    final resp = await http.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;

    if (resp.statusCode == 200 && decoded['success'] == true) {
      final data = decoded['data'] as Map<String, dynamic>;
      return (
        userId: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
      );
    }

    throw Exception(decoded['message'] ?? 'Registration failed');
  }

  Future<void> logout() async {
    try {
      // Call backend logout (optional per docs)
      final url = Uri.parse('$apiBase/auth/logout');
      await http.post(url);
    } catch (_) {}
    await clearSession();
  }

  Future<void> _saveSession({
    required String token,
    required String email,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_userIdKey, userId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userIdKey);
  }

  Future<({String? token, String? email, String? userId})> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      token: prefs.getString(_tokenKey),
      email: prefs.getString(_emailKey),
      userId: prefs.getString(_userIdKey),
    );
  }
}
