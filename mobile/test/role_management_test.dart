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
  
  group('Role Management Tests', () {
    test('2.1 Load roles from API - GET /api/admin/roles', () async {
      final result = await api.get('/api/admin/roles');
      
      print('Roles response: $result');
      
      expect(result, isNotNull);
      
      // Roles can be in 'roles', 'data', or as a list
      final roles = result['roles'] ?? result['data'] ?? result;
      
      expect(roles, isA<List>());
      expect(roles, isNotEmpty);
      
      print('Roles count: ${roles.length}');
      
      // Verify role structure
      final firstRole = roles.first;
      expect(firstRole['name'], isNotNull);
      
      print('Roles: ${roles.map((r) => r['name']).join(', ')}');
      print('✓ Test 2.1 PASSED: Roles loaded from API');
    });
    
    test('2.2 Role dropdown populated dynamically', () async {
      final result = await api.get('/api/admin/roles');
      final roles = result['roles'] ?? result['data'] ?? result;
      
      // Get role names for dropdown
      final roleNames = roles.map((r) => r['name'] as String).toList();
      
      print('Available roles for dropdown: $roleNames');
      
      // Should match expected roles
      expect(roleNames, isNotEmpty);
      expect(roleNames, contains('Admin'));
      expect(roleNames, contains('Owner'));
      
      print('✓ Test 2.2 PASSED: Role dropdown can be populated');
    });
    
    test('2.3 Role-based user filtering', () async {
      final allUsers = await api.get('/api/users');
      final users = allUsers is List ? allUsers : allUsers['data'] ?? allUsers['users'] ?? [];
      
      print('Total users: ${users.length}');
      
      // Group users by role
      final roleGroups = <String, List>{};
      for (final user in users) {
        final role = user['role'] as String? ?? 'Unknown';
        roleGroups.putIfAbsent(role, () => []).add(user);
      }
      
      print('Users by role:');
      roleGroups.forEach((role, userList) {
        print('  $role: ${userList.length}');
      });
      
      expect(roleGroups, isNotEmpty);
      print('✓ Test 2.3 PASSED: Users can be filtered by role');
    });
  });
  
  group('Role Assignment Tests', () {
    test('2.4 Create user with different roles', () async {
      final roles = ['Admin', 'Owner', 'Manager', 'Doctor', 'Employee'];
      
      for (final role in roles) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newUser = await api.post('/api/users', {
          'name': 'Role Test $role $timestamp',
          'email': 'roletest${role.toLowerCase()}$timestamp@example.com',
          'password': 'password123',
          'role': role,
        });
        
        print('Created user with role $role: ${newUser['role']}');
        expect(newUser['role'], equals(role));
        
        // Cleanup
        if (newUser['id'] != null) {
          await api.delete('/api/users/${newUser['id']}');
        }
      }
      
      print('✓ Test 2.4 PASSED: Can create users with all role types');
    });
    
    test('2.5 Change user role via update', () async {
      // Create a user
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newUser = await api.post('/api/users', {
        'name': 'Role Change Test $timestamp',
        'email': 'rolechange$timestamp@example.com',
        'password': 'password123',
        'role': 'Employee',
      });
      
      final userId = newUser['id'];
      print('Created user with initial role: ${newUser['role']}');
      
      // Change role to Manager
      final updatedUser = await api.put('/api/users/$userId', {
        'role': 'Manager',
      });
      
      print('Updated user role: ${updatedUser['role']}');
      expect(updatedUser['role'], equals('Manager'));
      
      // Change role to Doctor
      final updatedUser2 = await api.put('/api/users/$userId', {
        'role': 'Doctor',
      });
      
      print('Changed user to role: ${updatedUser2['role']}');
      expect(updatedUser2['role'], equals('Doctor'));
      
      // Cleanup
      await api.delete('/api/users/$userId');
      
      print('✓ Test 2.5 PASSED: Can change user role');
    });
  });
}