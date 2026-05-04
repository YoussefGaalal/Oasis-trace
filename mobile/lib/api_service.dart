import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

class ApiException implements Exception {
  final String message;
  final String? errorCode;

  ApiException(this.message, {this.errorCode});

  factory ApiException.fromResponse(http.Response res) {
    String message = 'An error occurred';
    String? errorCode;

    try {
      if (res.body.isNotEmpty) {
        final body = jsonDecode(res.body);
        message = body['message'] ?? message;
        errorCode = body['error'];
      }
    } catch (_) {}

    if (message == 'An error occurred') {
      message = _getDefaultMessage(res.statusCode);
    }

    return ApiException(message, errorCode: errorCode);
  }

  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied';
      case 404:
        return 'Resource not found';
      case 422:
        return 'Validation error';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred';
    }
  }

  @override
  String toString() => message;
}

class ApiService {
  static String get baseUrl => '${AppConfig.baseUrl}';

  static String? _token;
  static int? _userId;
  static String? _userRole;
  static String _locale = 'en';

  static String? get token => _token;
  static int? get userId => _userId;
  static String? get userRole => _userRole;

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> setUserInfo(int userId, String role) async {
    _userId = userId;
    _userRole = role;
  }

  static Future<void> setLocale(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
  }

  static String getLocale() => _locale;

  static Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString('locale') ?? 'en';
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> clearToken() async {
    _token = null;
    _userId = null;
    _userRole = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept-Language': _locale,
    if (_token != null) 'Authorization': 'Bearer $_token',
    if (_userId != null) 'X-User-Id': _userId.toString(),
    if (_userRole != null) 'X-User-Role': _userRole!,
  };

  static Map<String, String> get headers => _headers;

  static Map<String, dynamic> _handleResponse(http.Response res, {String? customError}) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data['token'] != null) {
        await setToken(data['token']);
        if (data['user'] != null) {
          await setUserInfo(data['user']['id'], data['user']['role']);
        }
      }
      return data;
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> logout() async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: _headers,
    );
    await clearToken();
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<Map<String, dynamic>> fetchCurrentUser() async {
    final res = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['data'] != null) {
        return data['data'];
      }
      return data;
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data['token'] != null) {
        await setToken(data['token']);
      }
      return data;
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    log('getDashboard: calling API with headers: $_headers');
    final res = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: _headers,
    );
    log('getDashboard: statusCode=${res.statusCode}, body=${res.body}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      log('getDashboard: parsed data = $data');
      return data;
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getAnimals({int page = 1}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/animals?page=$page&per_page=50'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map) {
        if (data['data'] != null) {
          return List<dynamic>.from(data['data']);
        }
        return [data];
      }
      return List<dynamic>.from(data);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> getAnimal(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/animals/$id'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createAnimal(
    Map<String, dynamic> animalData, [
    dynamic pickedImage,
  ]) async {
    if (pickedImage != null) {
      final uri = Uri.parse('$baseUrl/animals');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers.addAll({
        'Accept': 'application/json',
        ..._headers,
      });
      
      for (var entry in animalData.entries) {
        if (entry.value != null) {
          request.fields[entry.key] = entry.value.toString();
        }
      }
      
      final bytes = await pickedImage.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'identification_photo',
        bytes,
        filename: 'animal_photo.png',
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body)['data'] ?? jsonDecode(response.body);
      }
      throw ApiException.fromResponse(response);
    }
    
    final res = await http.post(
      Uri.parse('$baseUrl/animals'),
      headers: _headers,
      body: jsonEncode(animalData),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> updateAnimal(
    int id,
    Map<String, dynamic> animalData, [
    dynamic pickedImage,
  ]) async {
    if (pickedImage != null) {
      final uri = Uri.parse('$baseUrl/animals/$id');
      final request = http.MultipartRequest('POST', uri);
      request.headers['X-HTTP-Method-Override'] = 'PUT';
      request.headers['Authorization'] = 'Bearer ${_token}';
      request.headers['X-User-Id'] = _userId?.toString() ?? '';
      request.headers['X-User-Role'] = _userRole ?? '';
      
      request.headers.addAll({
        'Accept': 'application/json',
        ..._headers,
      });
      
      for (var entry in animalData.entries) {
        if (entry.value != null) {
          request.fields[entry.key] = entry.value.toString();
        }
      }
      
      final bytes = await pickedImage.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'identification_photo',
        bytes,
        filename: 'animal_photo.png',
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] ?? jsonDecode(response.body);
      }
      throw ApiException.fromResponse(response);
    }
    
    final res = await http.put(
      Uri.parse('$baseUrl/animals/$id'),
      headers: _headers,
      body: jsonEncode(animalData),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> deleteAnimal(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/animals/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<Map<String, dynamic>> getMapData() async {
    final res = await http.get(Uri.parse('$baseUrl/map'), headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>?> getLocationHistory(String deviceId, int hours) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/animals/$deviceId/location-history?hours=$hours'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<List<dynamic>> getGeofences() async {
    final res = await http.get(
      Uri.parse('$baseUrl/geofences'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getGeofenceAlerts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/geofence-alerts'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> acknowledgeAlert(int alertId) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/geofence-alerts/$alertId/acknowledge'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> deleteAlert(int alertId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/geofence-alerts/$alertId'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> deactivateAllAlerts() async {
    final res = await http.post(
      Uri.parse('$baseUrl/geofence-alerts/deactivate-all'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> sendNotificationAlert(int alertId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/geofence-alerts/$alertId/send-notification'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<Map<String, dynamic>> createGeofence({
    required String name,
    required String coordinates,
    String? color,
    String? alertType,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/geofences'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'coordinates': coordinates,
        'color': color ?? '#06402B',
        'alert_type': alertType ?? 'both',
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> updateGeofence(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/geofences/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> deleteGeofence(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/geofences/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<List<dynamic>> getGeofenceAnimals(int geofenceId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/geofences/$geofenceId/animals'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> assignAnimalsToGeofence(
    int geofenceId,
    List<int> animalIds,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/geofences/$geofenceId/animals'),
      headers: _headers,
      body: jsonEncode({'animal_ids': animalIds}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> removeAnimalsFromGeofence(
    int geofenceId,
    List<int> animalIds,
  ) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/geofences/$geofenceId/animals'),
      headers: _headers,
      body: jsonEncode({'animal_ids': animalIds}),
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<List<dynamic>> getGeofenceAvailableAnimals(int geofenceId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/geofences/$geofenceId/available-animals'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> mapExportGeofences() async {
    final res = await http.get(
      Uri.parse('$baseUrl/export/geofences'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> getMapFilters() async {
    final res = await http.get(
      Uri.parse('$baseUrl/map/filters'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getAnimalGroups() async {
    final res = await http.get(
      Uri.parse('$baseUrl/animal-groups'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> getReports() async {
    final res = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  // Device endpoints
  static Future<List<dynamic>> getDevices() async {
    final res = await http.get(
      Uri.parse('$baseUrl/devices'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createDevice(
    Map<String, dynamic> deviceData,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/devices'),
      headers: _headers,
      body: jsonEncode(deviceData),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> updateDevice(
    int id,
    Map<String, dynamic> deviceData,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/devices/$id'),
      headers: _headers,
      body: jsonEncode(deviceData),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> deleteDevice(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/devices/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  // User/Team endpoints
  static Future<Map<String, dynamic>> getUsers({int page = 1, int perPage = 15}) async {
    final res = await http.get(Uri.parse('$baseUrl/users?page=$page&per_page=$perPage'), headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> userData,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _headers,
      body: jsonEncode(userData),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> userData,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers,
      body: jsonEncode(userData),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> deleteUser(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<Map<String, dynamic>> toggleUserStatus(int id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/users/$id/toggle-status'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  // Task endpoints
  static Future<List<dynamic>> getTasks() async {
    final res = await http.get(Uri.parse('$baseUrl/tasks'), headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getMyTasks() async {
    final res = await http.get(
      Uri.parse('$baseUrl/tasks/my'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: _headers,
      body: jsonEncode(taskData),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> updateTask(
    int id,
    Map<String, dynamic> taskData,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: _headers,
      body: jsonEncode(taskData),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> completeTask(int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tasks/$id/complete'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> deleteTask(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<Map<String, dynamic>> getTaskStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/tasks/stats'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getPredefinedTasks() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/predefined-tasks'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getTaskLogs(int taskId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/tasks/$taskId/logs'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> submitTaskLog(
    int taskId,
    Map<String, dynamic> logData,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/task-logs'),
      headers: _headers,
      body: jsonEncode({'task_id': taskId, ...logData}),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getTaskLogsArchive() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/task-logs/archive'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getShepherds() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/users?role=shepherd'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  // Auction endpoints
  static Future<List<dynamic>> getAuctions() async {
    final res = await http.get(
      Uri.parse('$baseUrl/auctions'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getMyAuctions() async {
    final res = await http.get(
      Uri.parse('$baseUrl/auctions/my'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getMyBids() async {
    final res = await http.get(
      Uri.parse('$baseUrl/auctions/my-bids'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> getAuction(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/auctions/$id'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createAuction(
    Map<String, dynamic> auctionData,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auctions'),
      headers: _headers,
      body: jsonEncode(auctionData),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> placeBid(
    int auctionId,
    double amount,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auctions/$auctionId/bid'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> cancelAuction(int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auctions/$id/cancel'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<Map<String, dynamic>> updateAuction(
    int id,
    Map<String, dynamic> auctionData,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/auctions/$id'),
      headers: _headers,
      body: jsonEncode(auctionData),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> endAuctionEarly(int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auctions/$id/end'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> deleteAuction(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/auctions/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> disqualifyBid(int auctionId, int bidId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/auctions/$auctionId/bids/$bidId/disqualify'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<Map<String, dynamic>> uploadPaymentProof(
    int auctionId,
    String filePath,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auctions/$auctionId/payment-proof'),
    );
    request.headers.addAll(_headers);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamedRes = await request.send();
    final res = await http.Response.fromStream(streamedRes);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> verifyPayment(int auctionId, String status) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auctions/$auctionId/verify-payment/$status'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<List<dynamic>> getWonAuctions() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/auctions/won'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getAuctionBids(int auctionId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/auctions/$auctionId/bids'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> getAuctionStats() async {
    final res = await http.get(
      Uri.parse('$baseUrl/auctions/stats'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createAnimalGroup(
    Map<String, dynamic> groupData,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/animal-groups'),
      headers: _headers,
      body: jsonEncode(groupData),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  // Subscription endpoints
  static Future<List<dynamic>> getSubscriptionTiers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/subscription/tiers'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> getCurrentSubscription() async {
    final res = await http.get(
      Uri.parse('$baseUrl/subscription/current'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> subscribeToTier(String tierId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/subscription/subscribe/$tierId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> cancelSubscription() async {
    final res = await http.post(
      Uri.parse('$baseUrl/subscription/cancel'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> reactivateSubscription() async {
    final res = await http.post(
      Uri.parse('$baseUrl/subscription/reactivate'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getSubscriptionHistory() async {
    final res = await http.get(
      Uri.parse('$baseUrl/subscription/history'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createSubscriptionTier(
    Map<String, dynamic> tierData,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/subscription/admin/tiers'),
      headers: _headers,
      body: jsonEncode(tierData),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> updateSubscriptionTier(
    int tierId,
    Map<String, dynamic> tierData,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/subscription/admin/tiers/$tierId'),
      headers: _headers,
      body: jsonEncode(tierData),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> deleteSubscriptionTier(int tierId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/subscription/admin/tiers/$tierId'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<Map<String, dynamic>> upgradeSubscription(String tierId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/subscription/upgrade/$tierId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> downgradeSubscription(String tierId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/subscription/downgrade/$tierId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> setUserSubscriptionTier(int userId, int tierId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/subscription/admin/set-tier/$userId/$tierId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getAllSubscriptions() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/subscription/admin/subscriptions'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  // Vaccination endpoints
  static Future<List<dynamic>> getVaccinations() async {
    final res = await http.get(
      Uri.parse('$baseUrl/vaccinations'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createVaccination(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/vaccinations'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> updateVaccination(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/vaccinations/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> markVaccinationAdministered(int id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/vaccinations/$id/administer'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  // Medical Records endpoints
  static Future<List<dynamic>> getMedicalRecords() async {
    final res = await http.get(
      Uri.parse('$baseUrl/medical-records'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<Map<String, dynamic>> createMedicalRecord(
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/medical-records'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  // Language Management endpoints
  static Future<List<dynamic>> getLanguages() async {
    final res = await http.get(
      Uri.parse('$baseUrl/languages'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getRoles() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/roles'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['roles'] ?? data['data'] ?? data;
    }
    throw ApiException.fromResponse(res);
  }

  static Future<List<dynamic>> getTranslations({String? group, String? lang}) async {
    var url = '$baseUrl/translations';
    final params = <String>[];
    if (group != null) params.add('group=$group');
    if (lang != null) params.add('lang=$lang');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    
    log('Fetching: $url');
    
    // Public endpoint - no auth required
    final res = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    log('Response status: ${res.statusCode}');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) ?? jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

/// Get all translations for Flutter (UI strings + model data) - uses Spatie JSON columns
  static Future<Map<String, String>> getAllTranslations({String? lang}) async {
    try {
      final locale = lang ?? 'en';
      final url = '$baseUrl/translations-all?lang=$locale';
      log('Fetching all translations for $locale');
      
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        // Convert dynamic values to strings
        return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
      }
      throw ApiException.fromResponse(res);
    } catch (e) {
      log('Error getting all translations: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> createLanguage(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/languages'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw ApiException.fromResponse(res);
  }

  static Future<void> updateLanguage(String code, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/languages/$code'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> deleteLanguage(String code) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/languages/$code'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> setDefaultLanguage(String code) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/languages/$code/set-default'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }

  static Future<void> updateTranslation(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/translations/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) {
      throw ApiException.fromResponse(res);
    }
  }
}
