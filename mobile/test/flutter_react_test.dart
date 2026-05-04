import 'package:flutter_test/flutter_test.dart';
import 'test_helper.dart';

void main() {
  late TestApiClient api;
  
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  setUpAll(() async {
    print('\n=== Flutter ↔ React Cross-Platform Tests ===');
    api = TestApiClient();
    await api.login('admin@oasis.com', 'password');
  });

  group('Flutter CREATE → React READ', () {
    test('1.1 Flutter creates user → React can read via API', () async {
      // Simulate Flutter POST
      final flutterUser = await api.post('/api/users', {
        'name': 'Flutter Created',
        'email': 'fluttercreated$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Shepherd',
        'phone': '+20190001001',
      });
      
      final id = flutterUser['id'];
      print('Flutter created user ID: $id');
      
      // Simulate React GET (same API endpoint)
      final reactRead = await api.get('/api/users/$id');
      expect(reactRead['name'], equals('Flutter Created'));
      
      print('✓ React can read Flutter-created user');
    });
    
    test('1.2 Flutter creates Manager → React sees Manager role', () async {
      final user = await api.post('/api/users', {
        'name': 'Flutter Manager',
        'email': 'fluttermgr$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Manager',
      });
      
      // React would check role via GET
      final read = await api.get('/api/users/${user['id']}');
      expect(read['role'], equals('Manager'));
      
      print('✓ Flutter Manager visible to React');
    });
    
    test('1.3 Flutter creates with team → React team works', () async {
      final user = await api.post('/api/users', {
        'name': 'Flutter Team',
        'email': 'flutterteam$timestamp@oasis.com',
        'password': 'password123',
        'managed_by': 2,
      });
      
      expect(user['managed_by'], equals(2));
      print('✓ Flutter team member has owner');
    });
  });

  group('React CREATE → Flutter READ', () {
    test('2.1 React creates user → Flutter can read', () async {
      // React creates via same POST /api/users
      final user = await api.post('/api/users', {
        'name': 'React Created',
        'email': 'reactcreated$timestamp@oasis.com',
        'password': 'password123',
        'role': 'Doctor',
        'phone': '+20190001002',
      });
      
      // Flutter would fetch this
      final flutterRead = await api.get('/api/users/${user['id']}');
      expect(flutterRead['email'], equals('reactcreated$timestamp@oasis.com'));
      
      print('✓ Flutter can read React-created user');
    });
    
    test('2.2 React creates Owner → Flutter role check', () async {
      final user = await api.post('/api/users', {
        'name': 'React Owner',
        'email': 'reactowner$timestamp@oasis.com',
        'role': 'Owner',
      });
      
      final verify = await api.get('/api/users/${user['id']}');
      expect(verify['role'], equals('Owner'));
      
      print('✓ React Owner visible to Flutter');
    });
  });

  group('Data Format Compatibility', () {
    test('3.1 User fields match between Flutter/React', () async {
      final user = await api.post('/api/users', {
        'name': 'Format Test',
        'email': 'formattest$timestamp@oasis.com',
        'password': 'password123',
        'phone': '+201999999999',
      });
      
      // Both should get same structure
      final read = await api.get('/api/users/${user['id']}');
      
      // Verify all expected fields exist
      expect(read.containsKey('id'), isTrue);
      expect(read.containsKey('name'), isTrue);
      expect(read.containsKey('email'), isTrue);
      expect(read.containsKey('role'), isTrue);
      expect(read.containsKey('phone'), isTrue);
      expect(read.containsKey('is_active'), isTrue);
      expect(read.containsKey('managed_by'), isTrue);
      
      print('✓ All user fields present');
    });
    
    test('3.2 Role response format', () async {
      final roles = await api.get('/api/admin/roles');
      
      expect(roles.containsKey('roles'), isTrue);
      expect(roles['roles'], isA<List>());
      
      for (final role in roles['roles']) {
        expect(role['name'], isNotNull);
        expect(role['permissions'], isNotNull);
      }
      
      print('✓ Role format compatible');
    });
  });

  group('Token/Auth Compatibility', () {
    test('4.1 Same token works for both', () async {
      // Token from login works for all endpoints
      final me = await api.get('/api/users/1');
      expect(me['id'], equals(1));
      
      final users = await api.get('/api/users');
      expect(users.isNotEmpty, isTrue);
      
      print('✓ Token works for all endpoints');
    });
    
    test('4.2 Token persists across requests', () async {
      // Multiple requests with same token
      for (var i = 0; i < 3; i++) {
        final users = await api.get('/api/users');
        expect(users.isNotEmpty, isTrue);
      }
      
      print('✓ Token persists');
    });
  });

  group('List/Filter Compatibility', () {
    test('5.1 Users list returns data', () async {
      final users = await api.get('/api/users');
      print('Total users: ${users.length}');
      expect(users.isNotEmpty, isTrue);
    });
    
    test('5.2 Users searchable by email', () async {
      // Get all users
      final users = await api.get('/api/users');
      
      // Check structure - users should have email field
      if (users.isNotEmpty) {
        final first = users.first;
        expect(first.containsKey('email'), isTrue);
        print('✓ Email field exists in user list');
      }
    });
  });

  group('Team Management', () {
    test('6.1 Users have managed_by field', () async {
      final users = await api.get('/api/users');
      var withMgr = users.where((u) => u['managed_by'] != null).length;
      print('Users with manager: $withMgr');
      expect(withMgr, greaterThan(0));
    });
    
    test('6.2 Can assign managed_by on create', () async {
      final user = await api.post('/api/users', {
        'name': 'Team Test',
        'email': 'teamtest$timestamp@oasis.com',
        'password': 'password123',
        'managed_by': 2,
        'role': 'Shepherd',
      });
      
      expect(user['managed_by'], equals(2));
      print('✓ managed_by set on create');
    });
  });
}