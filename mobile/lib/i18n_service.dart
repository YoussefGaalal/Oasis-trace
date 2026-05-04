import 'dart:convert';
import 'package:http/http.dart' as http;

// Flutter i18n service - aligned with React/Laravel Spatie
// Supports both local fallbacks and API sync

class I18nService {
  static String _locale = 'en';
  static bool _isLoaded = false;
  static bool _apiLoaded = false;
  static Map<String, dynamic> _translations = {};
  static Map<String, Map<String, dynamic>> _translationsMap = {};
  static List<Map<String, dynamic>> _languages = [];
  static String _apiBaseUrl = 'http://localhost:8050/api';

  static String get locale => _locale;
  static bool get isRTL => _locale == 'ar' || _locale == 'ur';
  static List<Map<String, dynamic>> get languages => _languages;

  static void setLocale(String newLocale) {
    _locale = newLocale;
    _isLoaded = false;
    _apiLoaded = false;
    _translations = {};
    _loadTranslations();
  }

  static Future<void> loadLanguagesFromApi() async {
    try {
      final res = await http.get(
        Uri.parse('$_apiBaseUrl/languages'),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          _languages = List<Map<String, dynamic>>.from(data);
        } else if (data['data'] != null) {
          _languages = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      // API not available - keep fallback languages
    }
  }

  static Future<void> loadTranslationsFromApi() async {
    if (_apiLoaded) return;
    
    try {
      final res = await http.get(
        Uri.parse('$_apiBaseUrl/translations?lang=$_locale'),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          // Transform API response to nested map
          final Map<String, dynamic> nested = {};
          for (final item in data) {
            final key = item['key'] as String?;
            final value = item['value'] as String?;
            final group = item['group'] as String?;
            if (key != null && value != null) {
              final fullKey = group != null && group.isNotEmpty 
                  ? '$group.$key' 
                  : key;
              nested[fullKey] = value;
              // Also store short key
              if (!nested.containsKey(key)) {
                nested[key] = value;
              }
            }
          }
          // Merge with local translations
          final local = _localTranslations[_locale] ?? {};
          _translationsMap[_locale] = {...local, ...nested};
          _apiLoaded = true;
        }
      }
    } catch (e) {
      // API not available - use fallbacks
    }
  }

  static void _loadTranslations() {
    if (_isLoaded) return;
    
    // Try local translations first, then API if available
    final local = _localTranslations[_locale] ?? _localTranslations['en'];
    if (local != null) {
      _translations = Map<String, dynamic>.from(local);
      _isLoaded = true;
    }
    
    // Try to load from API in background
    loadTranslationsFromApi();
  }

  static void loadTranslations() {
    _loadTranslations();
    loadLanguagesFromApi();
  }

  static String tr(String key) {
    _loadTranslations();
    
    // First try nested key (e.g., "auth.login")
    final keys = key.split('.');
    dynamic value = _translations;
    
    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        // Try API translations if local failed
        if (_translationsMap.containsKey(_locale)) {
          final apiTrans = _translationsMap[_locale]!;
          if (apiTrans.containsKey(key)) {
            return apiTrans[key] as String;
          }
        }
        return key;
      }
    }
    
    return value is String ? value : key;
  }

  static String getDirection() {
    return isRTL ? 'rtl' : 'ltr';
  }

  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url;
  }
}

// Local fallback translations (always available)
final Map<String, Map<String, dynamic>> _localTranslations = {
  'en': {
    'common': {'dashboard': 'Dashboard', 'animals': 'Animals', 'devices': 'Devices', 'map': 'Map View', 'geofences': 'Geofences', 'auctions': 'Auctions', 'alerts': 'Alerts', 'tasks': 'Tasks', 'subscription': 'Subscription', 'team': 'Team', 'reports': 'Reports', 'users': 'Users', 'settings': 'Settings', 'logout': 'Logout', 'save': 'Save', 'cancel': 'Cancel', 'delete': 'Delete', 'edit': 'Edit', 'add': 'Add', 'view': 'View', 'search': 'Search', 'filter': 'Filter', 'loading': 'Loading...', 'noData': 'No data available', 'success': 'Success', 'error': 'Error', 'confirm': 'Confirm', 'back': 'Back', 'next': 'Next', 'yes': 'Yes', 'no': 'No', 'actions': 'Actions', 'status': 'Status', 'type': 'Type', 'date': 'Date', 'time': 'Time', 'all': 'All'},
    'nav': {'dashboard': 'Dashboard', 'animals': 'Animals', 'devices': 'Devices', 'mapView': 'Map View', 'geofences': 'Geofences', 'auctions': 'Auctions', 'alerts': 'Alerts', 'tasks': 'Tasks', 'subscription': 'Subscription', 'team': 'Team', 'reports': 'Reports', 'users': 'Users'},
    'auth': {'login': 'Sign In', 'logout': 'Logout', 'register': 'Sign Up', 'email': 'Email', 'password': 'Password', 'confirmPassword': 'Confirm Password', 'rememberMe': 'Remember me', 'forgotPassword': 'Forgot Password?', 'noAccount': "Don't have an account?", 'haveAccount': 'Already have an account?', 'welcomeBack': 'Welcome Back'},
    'animals': {'title': 'Animals', 'addAnimal': 'Add Animal', 'editAnimal': 'Edit Animal', 'name': 'Name', 'species': 'Species', 'breed': 'Breed', 'gender': 'Gender', 'status': 'Status', 'noAnimals': 'No animals found'},
    'devices': {'title': 'Devices', 'addDevice': 'Add Device', 'deviceId': 'Device ID', 'status': 'Status', 'battery': 'Battery', 'online': 'Online', 'offline': 'Offline'},
    'geofences': {'title': 'Geofences', 'addGeofence': 'Add Geofence', 'name': 'Name'},
    'tasks': {'title': 'Tasks', 'createTask': 'Create Task', 'pending': 'Pending', 'completed': 'Completed'},
    'alerts': {'title': 'Alerts', 'acknowledge': 'Acknowledge'},
    'team': {'title': 'Team Management'},
    'users': {'title': 'Users', 'addUser': 'Add User', 'name': 'Name', 'email': 'Email'},
    'settings': {'title': 'Platform Settings'},
    'dashboard': {'title': 'Dashboard', 'totalAnimals': 'Total Animals', 'activeDevices': 'Devices Assigned', 'alerts': 'Alerts'},
  },
  'ar': {
    'common': {'dashboard': 'لوحة التحكم', 'animals': 'الحيوانات', 'devices': 'الأجهزة', 'map': 'عرض الخريطة', 'geofences': 'السياج الجغرافي', 'auctions': 'المزادات', 'alerts': 'التنبيهات', 'tasks': 'المهام', 'settings': 'الإعدادات', 'save': 'حفظ', 'cancel': 'إلغاء', 'delete': 'حذف', 'edit': 'تعديل', 'add': 'إضافة', 'search': 'بحث', 'success': 'نجاح', 'error': 'خطأ'},
    'nav': {'dashboard': 'لوحة التحكم', 'animals': 'الحيوانات', 'devices': 'الأجهزة'},
    'auth': {'login': 'تسجيل الدخول', 'register': 'إنشاء حساب', 'email': 'البريد الإلكتروني', 'password': 'كلمة المرور', 'welcomeBack': 'مرحباً بعودتك'},
    'animals': {'title': 'الحيوانات', 'addAnimal': 'إضافة حيوان'},
    'devices': {'title': 'الأجهزة', 'addDevice': 'إضافة جهاز', 'online': 'متصل', 'offline': 'غير متصل'},
    'dashboard': {'title': 'لوحة التحكم', 'totalAnimals': 'إجمالي الحيوانات'},
  },
  'ur': {
    'common': {'dashboard': 'ڈیش بورڈ', 'animals': 'جانور', 'devices': 'ڈیوائس', 'map': 'نقشہ کا نظارہ', 'geofences': 'جیوفينس', 'auctions': 'مزید', 'alerts': 'انتباہات', 'tasks': 'ٹاسک', 'settings': 'ترتیبات', 'save': 'محفوظ کریں', 'cancel': 'منسوخ', 'delete': 'حذف کریں', 'edit': 'ترمیم', 'add': 'شامل کریں', 'search': 'تلاش', 'success': 'کامیاب', 'error': 'خرابی'},
    'nav': {'dashboard': 'ڈیش بورڈ', 'animals': 'جانور', 'devices': 'ڈیوائس'},
    'auth': {'login': 'لاگ ان', 'register': 'اندراج', 'email': 'ای میل', 'password': 'پاس ورڈ', 'welcomeBack': 'واپس خوش آمدید'},
    'animals': {'title': 'جانور', 'addAnimal': 'جانور شامل کریں'},
    'devices': {'title': 'ڈیوائس', 'addDevice': 'ڈیوایس شامل کریں'},
    'dashboard': {'title': 'ڈیش بورڈ', 'totalAnimals': 'جانوروں کی کل'},
  },
  'eu': {
    'common': {'dashboard': 'Azpikoetapa', 'animals': 'Animaliak', 'devices': 'Gailuak', 'map': 'Ikusi map', 'geofences': 'Geofenceak', 'auctions': 'Mokeleak', 'alerts': 'Abisuak', 'tasks': 'Zereginak', 'settings': 'Ezarpenak', 'save': 'Gorde', 'cancel': 'Utzi', 'delete': 'Ezabatu', 'edit': 'Aldatu', 'add': 'Gehitu', 'search': 'Bilatu', 'success': 'Arrakastoa', 'error': 'Akatsa'},
    'nav': {'dashboard': 'Azpikoetapa', 'animals': 'Animaliak', 'devices': 'Gailuak'},
    'auth': {'login': 'Saioa hasi', 'register': 'Izena eman', 'email': 'E-posta', 'password': 'Pasahitza', 'welcomeBack': 'Ongi etorri berriz'},
    'animals': {'title': 'Animaliak', 'addAnimal': 'Animalia gehitu'},
    'devices': {'title': 'Gailuak', 'addDevice': 'Gailua gehitu'},
    'dashboard': {'title': 'Azpikoetapa', 'totalAnimals': 'Animalia kopuru'},
  },
};