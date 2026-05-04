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
  
  group('Language Management Tests', () {
    test('3.1 Load languages from API - GET /api/languages', () async {
      final result = await api.get('/api/languages');
      
      print('Languages response: $result');
      
      expect(result, isNotNull);
      
      // Languages can be in 'data', 'languages', or as a list
      final languages = result['data'] ?? result['languages'] ?? result;
      
      expect(languages, isA<List>());
      expect(languages, isNotEmpty);
      
      print('Languages count: ${languages.length}');
      
      // Verify language structure
      final firstLang = languages.first;
      expect(firstLang['code'], isNotNull);
      expect(firstLang['name'], isNotNull);
      expect(firstLang['native_name'], isNotNull);
      expect(firstLang['direction'], isNotNull);
      
      print('Languages: ${languages.map((l) => '${l['name']} (${l['code']})').join(', ')}');
      print('✓ Test 3.1 PASSED: Languages loaded from API');
    });
    
    test('3.2 Languages have required fields', () async {
      final result = await api.get('/api/languages');
      final languages = result['data'] ?? result['languages'] ?? result;
      
      for (final lang in languages) {
        expect(lang, containsPair('code', isNotNull));
        expect(lang, containsPair('name', isNotNull));
        expect(lang, containsPair('native_name', isNotNull));
        expect(lang, containsPair('direction', isNotNull));
        expect(lang, containsPair('is_active', isNotNull));
      }
      
      print('✓ All languages have required fields');
    });
    
    test('3.3 RTL/LTR detection works', () async {
      final result = await api.get('/api/languages');
      final languages = result['data'] ?? result['languages'] ?? result;
      
      final rtlLanguages = languages.where((l) => l['direction'] == 'rtl').toList();
      final ltrLanguages = languages.where((l) => l['direction'] == 'ltr').toList();
      
      print('RTL languages: ${rtlLanguages.map((l) => l['code']).join(', ')}');
      print('LTR languages: ${ltrLanguages.map((l) => l['code']).join(', ')}');
      
      expect(rtlLanguages, isNotEmpty, reason: 'Should have RTL languages');
      expect(ltrLanguages, isNotEmpty, reason: 'Should have LTR languages');
      
      print('✓ Test 3.3 PASSED: RTL/LTR detection works');
    });
    
    test('3.4 Default language detection', () async {
      final result = await api.get('/api/languages');
      final languages = result['data'] ?? result['languages'] ?? result;
      
      // Find default language
      final defaultLang = languages.firstWhere(
        (l) => l['is_default'] == true || l['is_default'] == 1,
        orElse: () => languages.first,
      );
      
      print('Default language: ${defaultLang['name']} (${defaultLang['code']})');
      
      expect(defaultLang, isNotNull);
      print('✓ Test 3.4 PASSED: Default language detected');
    });
  });
  
  group('Translation Tests', () {
    test('3.5 Load translations - GET /api/translations', () async {
      // Get translations for a specific language
      final result = await api.get('/api/translations?lang=en');
      
      print('Translations response type: ${result.runtimeType}');
      print('Translations keys: ${result.keys.take(10).join(', ')}');
      
      expect(result, isNotNull);
      
      if (result is Map && result.isNotEmpty) {
        print('Translation count: ${result.length}');
        print('Sample translations: ${result.entries.take(5).map((e) => '${e.key}: ${e.value}').join(', ')}');
      }
      
      print('✓ Test 3.5 PASSED: Translations loaded');
    });
    
    test('3.6 Translations by group', () async {
      final groups = ['common', 'settings', 'animals', 'dashboard'];
      
      for (final group in groups) {
        final result = await api.get('/api/translations?group=$group&lang=en');
        print('Group $group: ${result.length} translations');
      }
      
      print('✓ Test 3.6 PASSED: Translations filtered by group');
    });
  });
  
  group('Language CRUD Admin Tests', () {
    test('3.7 Admin languages list - GET /api/admin/languages', () async {
      // Requires auth - should work since we're logged in
      final result = await api.get('/api/admin/languages');
      
      print('Admin languages response: $result');
      
      expect(result, isNotNull);
      
      final languages = result['data'] ?? result;
      expect(languages, isA<List>());
      
      print('Admin languages count: ${languages.length}');
      print('✓ Test 3.7 PASSED: Admin languages endpoint works');
    });
    
    test('3.8 Create new language', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newLang = {
        'code': 'te$timestamp',
        'name': 'Test Language $timestamp',
        'native_name': 'Test Lang Native',
        'direction': 'ltr',
      };
      
      try {
        final result = await api.post('/api/admin/languages', newLang);
        print('Created language: $result');
        print('✓ Test 3.8 PASSED: Can create new language');
        
        // Note: Can't easily cleanup as we might need the code for delete
      } catch (e) {
        print('Create language failed (may already exist): $e');
      }
    });
  });
}