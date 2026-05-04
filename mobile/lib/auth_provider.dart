import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);
      _token = data['token'] ?? data['data']?['token'];
      _user = data['user'] ?? data['data']?['user'];
      if (_user != null && _user!['id'] != null) {
        await ApiService.setUserInfo(
          _user!['id'] as int,
          _user!['role'] as String? ?? 'Owner',
        );
      }
      notifyListeners();
      _isLoading = false;
      return _token != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchCurrentUser() async {
    if (_token == null) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/me'),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        _user = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<bool> tryAutoLogin() async {
    await ApiService.loadToken();
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('auth_token');
    if (t != null) {
      _token = t;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await ApiService.clearToken();
    notifyListeners();
  }

  void setDemoMode() {
    _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
    _user = {
      'id': 1,
      'name': 'Abdullah',
      'email': 'demo@oasis.com',
      'role': 'Owner',
    };
    notifyListeners();
  }
}
