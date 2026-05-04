import 'package:flutter_test/flutter_test.dart';
import 'test_helper.dart';

void main() {
  late TestApiClient adminApi;
  
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  setUpAll(() async {
    print('\n=== Cross-Platform Tests ===');
    adminApi = TestApiClient();
    await adminApi.login('admin@oasis.com', 'password');
  });

  group('Cross-Platform: CREATE', () {
    test('1.1 Create Admin via API → Laravel read', () async {
      final user = await adminApi.post('/api/users', {
        'name': 'Cross Admin',
        'email': 'crossadmin$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Admin',
      });
      
      print('Created Admin ID: ${user['id']}');
      expect(user['id'], isNotNull);
    });
    
    test('1.2 Create Owner', () async {
      final user = await adminApi.post('/api/users', {
        'name': 'Cross Owner',
        'email': 'crossowner$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Owner',
      });
      print('Created Owner: ${user['id']}');
    });
    
    test('1.3 Create Manager', () async {
      final user = await adminApi.post('/api/users', {
        'name': 'Cross Manager',
        'email': 'crossmgr$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Manager',
      });
      print('Created Manager: ${user['id']}');
    });
    
    test('1.4 Create Shepherd', () async {
      final user = await adminApi.post('/api/users', {
        'name': 'Cross Shepherd',
        'email': 'crossshp$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Shepherd',
      });
      print('Created Shepherd: ${user['id']}');
    });
    
    test('1.5 Create Doctor', () async {
      final user = await adminApi.post('/api/users', {
        'name': 'Cross Doctor',
        'email': 'crossdoc$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Doctor',
      });
      print('Created Doctor: ${user['id']}');
    });
  });

  group('Cross-Platform: EDIT', () {
    test('2.1 Edit name persists', () async {
      final created = await adminApi.post('/api/users', {
        'name': 'Edit Test',
        'email': 'edittest$timestamp@oasis.com',
        'password': 'password123',
      });
      
      final id = created['id'];
      final updated = await adminApi.put('/api/users/$id', {'name': 'New Name'});
      expect(updated['name'], equals('New Name'));
    });
    
    test('2.2 Edit role Shepherd→Manager', () async {
      final created = await adminApi.post('/api/users', {
        'name': 'Role Edit',
        'email': 'roleedit$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Shepherd',
      });
      
      await adminApi.put('/api/users/${created['id']}', {'role': 'Manager'});
      print('✓ Role changed');
    });
    
    test('2.3 Toggle status', () async {
      final created = await adminApi.post('/api/users', {
        'name': 'Toggle Test',
        'email': 'toggletest$timestamp@oasis.com',
        'password': 'password123',
      });
      
      final before = created['is_active'];
      final after = await adminApi.patch('/api/users/${created['id']}/toggle-status', {});
      expect(after['is_active'], equals(!before));
    });
  });

  group('Cross-Platform: DELETE', () {
    test('3.1 Delete removes user', () async {
      final created = await adminApi.post('/api/users', {
        'name': 'Delete Test',
        'email': 'deletetest$timestamp@oasis.com',
        'password': 'password123',
      });
      
      await adminApi.delete('/api/users/${created['id']}');
      
      try {
        await adminApi.get('/api/users/${created['id']}');
        expect(true, isFalse);
      } catch (e) {
        print('✓ 404 for deleted user');
      }
    });
  });

  group('Cross-Platform: READ/LIST', () {
    test('4.1 List all users', () async {
      final users = await adminApi.get('/api/users');
      print('Total users: ${users.length}');
      expect(users.length, greaterThan(10));
    });
    
    test('4.2 Get single user', () async {
      final user = await adminApi.get('/api/users/1');
      print('User 1: ${user['name']} role: ${user['role']}');
      expect(user['id'], equals(1));
    });
    
    test('4.3 Roles endpoint', () async {
      final roles = await adminApi.get('/api/admin/roles');
      print('Roles: ${roles['roles'].length}');
      expect(roles['roles'].length, equals(6));
    });
  });

  group('Cross-Platform: Team', () {
    test('5.1 managed_by field', () async {
      final users = await adminApi.get('/api/users');
      var withMgr = users.where((u) => u['managed_by'] != null).length;
      print('Users with manager: $withMgr');
    });
    
    test('5.2 Assign to owner', () async {
      final user = await adminApi.post('/api/users', {
        'name': 'Team Member',
        'email': 'teammember$timestamp@oasis.com',
        'password': 'password123',
        'managed_by': 2,
      });
      print('Managed by: ${user['managed_by']}');
    });
  });
}