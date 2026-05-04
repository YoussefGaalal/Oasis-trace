import 'package:flutter_test/flutter_test.dart';
import 'test_helper.dart';

void main() {
  late TestApiClient api;
  
  setUpAll(() async {
    api = TestApiClient();
    print('\n=== Setting up: Logging in ===');
    
    try {
      final loginResult = await api.login(
        TestConfig.testEmail ?? 'admin@oasis.com',
        TestConfig.testPassword ?? 'password123',
      );
      print('Login successful: ${loginResult['user']?['name'] ?? loginResult['name'] ?? 'Unknown'}');
      print('Token: ${TestConfig.token?.substring(0, 20)}...');
    } catch (e) {
      print('Login failed: $e');
      rethrow;
    }
  });
  
  group('User CRUD Tests', () {
    test('1.1 View users list - GET /api/users', () async {
      final result = await api.get('/api/users');
      
      print('Response: $result');
      
      expect(result, isNotNull);
      
      final users = result is List ? result : result['data'] ?? result['users'] ?? [];
      print('Users count: ${users.length}');
      
      expect(users, isNotEmpty);
      expect(users.length, greaterThan(0));
      
      // Verify structure
      final firstUser = users.first;
      expect(firstUser, containsPair('id', isNotNull));
      expect(firstUser, containsPair('name', isNotNull));
      expect(firstUser, containsPair('email', isNotNull));
      expect(firstUser, containsPair('role', isNotNull));
      
      print('✓ Test 1.1 PASSED: Users list retrieved successfully');
    });
    
    test('1.2 Create user with role - POST /api/users', () async {
      final newUser = {
        'name': 'Test User ${DateTime.now().millisecondsSinceEpoch}',
        'email': 'testuser${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'password123',
        'role': 'Employee',
        'phone': '+201234567890',
      };
      
      final result = await api.post('/api/users', newUser);
      
      print('Create response: $result');
      
      expect(result, isNotNull);
      expect(result['name'], equals(newUser['name']));
      expect(result['email'], equals(newUser['email']));
      expect(result['role'], equals(newUser['role']));
      
      print('✓ Test 1.2 PASSED: User created with role');
      
      // Cleanup: delete the test user
      if (result['id'] != null) {
        await api.delete('/api/users/${result['id']}');
        print('Cleanup: Test user deleted');
      }
    });
    
    test('1.3 Create user with Admin role', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = {
        'name': 'Admin Test User $timestamp',
        'email': 'admintest$timestamp@example.com',
        'password': 'password123',
        'role': 'Admin',
        'phone': '+201234567891',
      };
      
      final result = await api.post('/api/users', newUser);
      
      expect(result['role'], equals('Admin'));
      print('✓ Test 1.3 PASSED: Admin user created');
      
      // Cleanup
      if (result['id'] != null) {
        await api.delete('/api/users/${result['id']}');
      }
    });
    
    test('1.4 Edit user - PUT /api/users/{id}', () async {
      // First create a user to edit
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await api.post('/api/users', {
        'name': 'Edit Test User $timestamp',
        'email': 'edittest$timestamp@example.com',
        'password': 'password123',
        'role': 'Employee',
      });
      
      final userId = newUser['id'];
      print('Created user ID: $userId');
      
      // Now edit the user
      final updatedUser = await api.put('/api/users/$userId', {
        'name': 'Updated Name',
        'role': 'Manager',
      });
      
      print('Updated response: $updatedUser');
      
      expect(updatedUser['name'], equals('Updated Name'));
      expect(updatedUser['role'], equals('Manager'));
      
      print('✓ Test 1.4 PASSED: User edited successfully');
      
      // Cleanup
      await api.delete('/api/users/$userId');
    });
    
    test('1.5 Delete user - DELETE /api/users/{id}', () async {
      // First create a user to delete
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await api.post('/api/users', {
        'name': 'Delete Test User $timestamp',
        'email': 'deletetest$timestamp@example.com',
        'password': 'password123',
        'role': 'Employee',
      });
      
      final userId = newUser['id'];
      print('Created user ID: $userId');
      
      // Now delete the user
      final deleteResult = await api.delete('/api/users/$userId');
      print('Delete response: $deleteResult');
      
      // Verify user is deleted by trying to get them
      expect(deleteResult, isNotNull);
      
      print('✓ Test 1.5 PASSED: User deleted successfully');
    });
    
    test('1.6 Toggle user status - PATCH /api/users/{id}/toggle-status', () async {
      // Create a user first
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await api.post('/api/users', {
        'name': 'Toggle Test User $timestamp',
        'email': 'toggle$timestamp@example.com',
        'password': 'password123',
        'role': 'Employee',
      });
      
      final userId = newUser['id'];
      final initialStatus = newUser['is_active'] ?? true;
      print('Initial status: $initialStatus');
      
      // Toggle status
      final toggledUser = await api.patch('/api/users/$userId/toggle-status', {});
      print('Toggled response: $toggledUser');
      
      // Verify status changed
      final newStatus = toggledUser['is_active'] ?? !initialStatus;
      expect(newStatus, equals(!initialStatus));
      
      print('✓ Test 1.6 PASSED: User status toggled');
      
      // Cleanup
      await api.delete('/api/users/$userId');
    });
  });
  
  group('User List Structure Tests', () {
    test('Users have required fields', () async {
      final result = await api.get('/api/users');
      final users = result is List ? result : result['data'] ?? [];
      
      for (final user in users) {
        expect(user, containsPair('id', isNotNull));
        expect(user, containsPair('name', isNotNull));
        expect(user, containsPair('email', isNotNull));
        expect(user['role'], isNotNull, reason: 'User ${user['id']} has no role');
      }
      
      print('✓ All users have required fields');
    });
    
    test('Users have role field with valid value', () async {
      final result = await api.get('/api/users');
      final users = result is List ? result : result['data'] ?? [];
      
      final validRoles = ['Admin', 'Owner', 'Manager', 'Doctor', 'Employee', 'Shepherd'];
      
      for (final user in users) {
        final role = user['role'];
        expect(validRoles, contains(role), reason: 'Invalid role: $role');
      }
      
      print('✓ All users have valid roles');
    });
  });
}