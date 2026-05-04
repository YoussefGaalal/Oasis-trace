import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestConfig {
  static String? get testEmail => const String.fromEnvironment('TEST_EMAIL', defaultValue: 'admin@oasis.com');
  static String? get testPassword => const String.fromEnvironment('TEST_PASSWORD', defaultValue: 'password123');
  static String get baseUrl => const String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8050');
  
  static String? token;
  static int? userId;
}

class TestApiClient {
  final String baseUrl;
  
  TestApiClient({String? baseUrl}) : baseUrl = baseUrl ?? TestConfig.baseUrl;
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      TestConfig.token = data['token'] ?? data['data']?['token'];
      TestConfig.userId = data['user']?['id'] ?? data['data']?['user']?['id'];
      return data;
    }
    throw Exception('Login failed: ${response.statusCode} - ${response.body}');
  }
  
  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (TestConfig.token != null) 'Authorization': 'Bearer ${TestConfig.token}',
  };
  
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('GET $endpoint failed: ${response.statusCode}');
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: authHeaders,
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('POST $endpoint failed: ${response.statusCode} - ${response.body}');
  }
  
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: authHeaders,
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('PUT $endpoint failed: ${response.statusCode}');
  }
  
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('DELETE $endpoint failed: ${response.statusCode}');
  }
  
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: authHeaders,
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('PATCH $endpoint failed: ${response.statusCode}');
  }
}

void main() {
  print('Test Configuration:');
  print('  BASE_URL: ${TestConfig.baseUrl}');
  print('  TEST_EMAIL: ${TestConfig.testEmail}');
  print('');
  print('Run tests with:');
  print('  flutter test --watch');
  print('Or with custom credentials:');
  print('  flutter test --watch --define TEST_EMAIL=user@test.com --define TEST_PASSWORD=secret');
}