import 'package:flutter_test/flutter_test.dart';
import 'test_helper.dart';

void main() {
  late TestApiClient adminApi;
  
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  setUpAll(() async {
    print('\n=== Phase 0: Setup - Login ===');
    
    adminApi = TestApiClient();
    await adminApi.login('admin@oasis.com', 'password');
    print('Admin logged in');
  });

  group('CREATE Tests - All Roles via API', () {
    test('1.1 Create Admin via API → Laravel check', () async {
      final newUser = {
        'name': 'Test Admin $timestamp',
        'email': 'testadmin$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Admin',
        'phone': '+201100000001',
      };
      
      final result = await adminApi.post('/api/users', newUser);
      print('Created Admin: ${result['id']}');
      
      expect(result['id'], isNotNull);
      expect(result['name'], equals(newUser['name']));
    });
    
    test('1.2 Create Owner via API', () async {
      final newUser = {
        'name': 'Test Owner $timestamp',
        'email': 'testowner$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Owner',
        'phone': '+201100000002',
      };
      
      final result = await adminApi.post('/api/users', newUser);
      print('Created Owner: ${result['id']}');
      
      expect(result['id'], isNotNull);
    });
    
    test('1.3 Create Manager via API', () async {
      final newUser = {
        'name': 'Test Manager $timestamp',
        'email': 'testmgr$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Manager',
        'phone': '+201100000003',
      };
      
      final result = await adminApi.post('/api/users', newUser);
      expect(result['id'], isNotNull);
    });
    
    test('1.4 Create Shepherd via API', () async {
      final newUser = {
        'name': 'Test Shepherd $timestamp',
        'email': 'testshp$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Shepherd',
        'phone': '+201100000004',
      };
      
      final result = await adminApi.post('/api/users', newUser);
      expect(result['id'], isNotNull);
    });
    
    test('1.5 Create Doctor via API', () async {
      final newUser = {
        'name': 'Test Doctor $timestamp',
        'email': 'testdoc$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Doctor',
        'phone': '+201100000005',
      };
      
      final result = await adminApi.post('/api/users', newUser);
      expect(result['id'], isNotNull);
    });
  });

  group('EDIT Tests', () {
    test('2.1 Edit name via PUT', () async {
      final newUser = await adminApi.post('/api/users', {
        'name': 'Edit Test $timestamp',
        'email': 'edittest$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Shepherd',
      });
      
      final updated = await adminApi.put('/api/users/${newUser['id']}', {
        'name': 'Updated Name',
      });
      
      expect(updated['name'], equals('Updated Name'));
    });
    
    test('2.2 Edit phone', () async {
      final newUser = await adminApi.post('/api/users', {
        'name': 'Phone Test $timestamp',
        'email': 'phonetest$timestamp@oasis.com',
        'password': 'password123',
      });
      
      final updated = await adminApi.put('/api/users/${newUser['id']}', {
        'phone': '+209999999999',
      });
      
      expect(updated['phone'], equals('+209999999999'));
    });
    
    test('2.3 Toggle status', () async {
      final newUser = await adminApi.post('/api/users', {
        'name': 'Toggle Test $timestamp',
        'email': 'toggletest$timestamp@oasis.com',
        'password': 'password123',
      });
      
      final toggled = await adminApi.patch('/api/users/${newUser['id']}/toggle-status', {});
      print('Status: ${toggled['is_active']}');
    });
  });

  group('DELETE Tests', () {
    test('3.1 Delete user', () async {
      final newUser = await adminApi.post('/api/users', {
        'name': 'Delete Test $timestamp',
        'email': 'deletetest$timestamp@oasis.com',
        'password': 'password123',
      });
      
      final result = await adminApi.delete('/api/users/${newUser['id']}');
      print('Deleted: $result');
    });
  });

  group('ROLE Tests', () {
    test('4.1 Change to Shepherd', () async {
      final newUser = await adminApi.post('/api/users', {
        'name': 'Role Test $timestamp',
        'email': 'roletest$timestamp@oasis.com',
        'password': 'password123',
      });
      
      final updated = await adminApi.put('/api/users/${newUser['id']}', {
        'role': 'Shepherd',
      });
      
      expect(updated['name'], isNotNull);
    });
    
    test('4.2 Change to Manager', () async {
      final newUser = await adminApi.post('/api/users', {
        'name': 'Role Mgr Test $timestamp',
        'email': 'rolemgrtest$timestamp@oasis.com',
        'password': 'password123',
      });
      
      final updated = await adminApi.put('/api/users/${newUser['id']}', {
        'role': 'Manager',
      });
      
      expect(updated['name'], isNotNull);
    });
    
    test('4.3 Get roles from API', () async {
      final roles = await adminApi.get('/api/admin/roles');
      print('Roles: ${roles['roles']?.length ?? 0}');
    });
  });

  group('TEAM Tests', () {
    test('5.1 List all users (Admin)', () async {
      final users = await adminApi.get('/api/users');
      print('Total users: ${users.length}');
    });
  });
}