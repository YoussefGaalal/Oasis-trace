import 'dart:developer';
import 'package:flutter/material.dart';
import 'api_service.dart';

class DataProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  String _locale = 'en';
  String get locale => _locale;
  
  List<Map<String, dynamic>> _languages = [
    {'code': 'en', 'name': 'English', 'direction': 'ltr'},
    {'code': 'ar', 'name': 'العربية', 'direction': 'rtl'},
    {'code': 'ur', 'name': 'اردو', 'direction': 'rtl'},
    {'code': 'eu', 'name': 'Euskara', 'direction': 'ltr'},
  ];
  List<Map<String, dynamic>> get languages => _languages;
  
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> get roles => _roles;
  
  bool get isRTL {
    final lang = _languages.firstWhere(
      (l) => l['code'] == _locale,
      orElse: () => {'direction': 'ltr'},
    );
    return lang['direction'] == 'rtl';
  }

  bool hasRole(String roleName) {
    return _roles.any((r) => r['name'] == roleName);
  }

  bool hasPermission(String permission) {
    return _roles.any((r) {
      final perms = r['permissions'] as List? ?? [];
      return perms.contains(permission);
    });
  }

  static const List<String> _fallbackRoles = ['Admin', 'Owner', 'Manager', 'Doctor', 'Employee'];

  List<String> get roleNames {
    if (_roles.isEmpty) {
      return _fallbackRoles;
    }
    return _roles.map((r) => r['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList();
  }

  List<String> getAssignableRoles(String currentUserRole) {
    final roles = roleNames;
    if (currentUserRole == 'Admin') {
      return roles;
    } else if (currentUserRole == 'Owner') {
      return roles.where((r) => r != 'Admin' && r != 'Owner').toList();
    }
    return roles.isEmpty ? ['Employee'] : [];
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    try {
      await ApiService.setLocale(locale);
    } catch (e) {
      log('setLocale: API not available (user not logged in)');
    }
    try {
      await loadTranslations();
    } catch (e) {
      log('setLocale: API translations failed, using fallback');
    }
    if (_translations.isEmpty) {
      log('setLocale: Using static fallback translations');
      _translations.addAll(_fallbackTranslations);
    }
    log('setLocale: Loaded ${_translations.length} translations');
    notifyListeners();
  }

  Future<void> loadLocale() async {
    try {
      _locale = await ApiService.getLocale();
    } catch (e) {
      log('loadLocale: getLocale failed, keeping default');
    }
    try {
      await _loadLanguages();
    } catch (e) {
      log('loadLocale: _loadLanguages failed');
    }
    try {
      await _loadRoles();
    } catch (e) {
      log('loadLocale: roles failed');
    }
    try {
      await loadTranslations();
    } catch (e) {
      log('loadLocale: translations failed');
    }
    notifyListeners();
  }
  
  Future<void> _loadLanguages() async {
    try {
      final result = await ApiService.getLanguages();
      _languages = List<Map<String, dynamic>>.from(result);
      log('Loaded ${_languages.length} languages');
    } catch (e) {
      log('Error loading languages: $e');
      _languages = [];
    }
  }

  Future<void> _loadRoles() async {
    try {
      await ApiService.loadToken();
      if (ApiService.token == null || ApiService.token!.isEmpty) {
        log('No auth token - using fallback roles');
        return;
      }
      final result = await ApiService.getRoles();
      _roles = List<Map<String, dynamic>>.from(result);
      log('Loaded ${_roles.length} roles');
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
        log('Not authenticated - using fallback roles');
      } else {
        log('Error loading roles: $e');
      }
      _roles = [];
    }
  }

  Future<void> loadRoles() async {
    await _loadRoles();
    notifyListeners();
  }

  final Map<String, String> _translations = {};
  
  String tr(String key) {
    final result = _translations[key] ?? _fallbackTranslations[key] ?? key;
    if (key == 'settings.title') {
      log('tr($key) = $result');
      log('API translations length: ${_translations.length}');
      log('Has settings.title: ${_translations.containsKey('settings.title')}');
    }
    return result;
  }

  Future<void> loadTranslations() async {
    try {
      _translations.clear();
      _translations.addAll(await ApiService.getAllTranslations(lang: _locale));
      log('Loaded ${_translations.length} translations for $_locale');
    } catch (e) {
      log('Error loading translations: $e');
    }
  }
  
  static const Map<String, String> _fallbackTranslations = {
    'common.appName': 'The Oasis',
    'common.quickActions': 'Quick Actions',
    'common.success': 'Success',
    'common.error': 'Error',
    'auth.login': 'Sign In',
    'auth.register': 'Sign Up',
    'auth.welcomeBack': 'Welcome Back',
    'auth.loginSubtitle': 'Sign in to continue monitoring your livestock',
    'auth.email': 'Email',
    'auth.password': 'Password',
    'auth.rememberMe': 'Remember me',
    'auth.forgotPassword': 'Forgot Password?',
    'auth.noAccount': "Don't have an account?",
    'auth.enterEmail': 'Enter your email',
    'auth.enterPassword': 'Enter your password',
    'auth.emailRequired': 'Email is required',
    'auth.invalidEmail': 'Enter a valid email',
    'auth.passwordRequired': 'Password is required',
    'auth.passwordMinLength': 'Password must be at least 4 characters',
    'nav.dashboard': 'Dashboard',
    'nav.animals': 'Animals',
    'nav.devices': 'Devices',
    'nav.geofences': 'Geofences',
    'nav.alerts': 'Alerts',
    'nav.tasks': 'Tasks',
    'nav.reports': 'Reports',
    'nav.settings': 'Settings',
    'nav.profile': 'Profile',
    'nav.users': 'Users',
    'nav.mapView': 'Map View',
    'nav.auctions': 'Auctions',
    'nav.medicalRecords': 'Medical Records',
    'nav.vaccinations': 'Vaccinations',
    'nav.team': 'Team',
    'nav.addNewEntry': 'Add New',
    'dashboard.title': 'Dashboard',
    'dashboard.totalAnimals': 'Total Animals',
    'dashboard.activeAlerts': 'Active Alerts',
    'dashboard.grazingZones': 'Grazing Zones',
    'dashboard.pendingTasks': 'Pending Tasks',
    'animals.title': 'Animals',
    'animals.addAnimal': 'Add Animal',
'devices.title': 'Devices',
    'geofences.title': 'Geofences',
    'alerts.title': 'Alerts',
    'tasks.title': 'Tasks',
    'reports.title': 'Reports',
    'settings.title': 'Settings',
    'settings.account': 'Account',
    'settings.notifications': 'Notifications',
    'settings.appSettings': 'App Settings',
    'settings.about': 'About',
    'settings.pushNotifications': 'Push Notifications',
    'settings.pushNotificationsSubtitle': 'Receive alerts on your device',
    'settings.emailNotifications': 'Email Notifications',
    'settings.emailNotificationsSubtitle': 'Receive updates via email',
    'settings.darkMode': 'Dark Mode',
    'settings.darkModeSubtitle': 'Use dark theme',
    'settings.locationTracking': 'Location Tracking',
    'settings.locationTrackingSubtitle': 'Track animal locations',
    'settings.temperatureUnit': 'Temperature Unit',
    'settings.language': 'Language',
    'settings.appVersion': 'App Version',
    'settings.privacyPolicy': 'Privacy Policy',
    'settings.termsOfService': 'Terms of Service',
    'settings.signOut': 'Sign Out',
    'users.title': 'Users',
    'users.addUser': 'Add User',
    'users.role': 'Role',
    'team.title': 'Team',
    'team.teamMembers': 'Team Members',
    'common.search': 'Search',
    'common.searchHint': 'Search animals, devices, alerts...',
    'common.noResults': 'No results found',
    'common.loading': 'Loading...',
    'common.save': 'Save',
    'common.cancel': 'Cancel',
    'common.delete': 'Delete',
    'common.edit': 'Edit',
    'common.view': 'View',
    'common.viewAll': 'View All',
    'common.details': 'Details',
    'common.name': 'Name',
    'common.status': 'Status',
    'common.recentAlerts': 'Recent Alerts',
    'common.recentAnimals': 'Recent Animals',
    'common.tracked': 'Tracked',
'common.unknown': 'Unknown',
  };
  
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? get dashboardData => _dashboardData;

  List<dynamic> _animals = [];
  List<dynamic> get animals => _animals;

  List<dynamic> _mapData = [];
  List<dynamic> get mapData => _mapData;

  List<dynamic> _alerts = [];
  List<dynamic> get alerts => _alerts;

  List<dynamic> _geofences = [];
  List<dynamic> get geofences => _geofences;

  List<dynamic> _devices = [];
  List<dynamic> get devices => _devices;

  List<dynamic> _tasks = [];
  List<dynamic> get tasks => _tasks;

  List<dynamic> _users = [];
  List<dynamic> get users => _users;
  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  List<dynamic> _auctions = [];
  List<dynamic> get auctions => _auctions;

  List<dynamic> _groups = [];
  List<dynamic> get groups => _groups;

  List<dynamic> _owners = [];
  List<dynamic> get owners => _owners;

  Map<String, dynamic>? _currentSubscription;
  Map<String, dynamic>? get currentSubscription => _currentSubscription;

  List<dynamic> _subscriptionTiers = [];
  List<dynamic> get subscriptionTiers => _subscriptionTiers;

  List<dynamic> _vaccinations = [];
  List<dynamic> get vaccinations => _vaccinations;

  List<dynamic> _medicalRecords = [];
  List<dynamic> get medicalRecords => _medicalRecords;

  List<String> _speciesOptions = ['Camel', 'Goat', 'Sheep'];
  List<String> get speciesOptions => _speciesOptions;

  List<String> _breedOptions = ['Wadhah', 'Majaheem', 'Suhail', 'Boer', 'Awassi'];
  List<String> get breedOptions => _breedOptions;

  List<String> _genderOptions = ['Male', 'Female'];
  List<String> get genderOptions => _genderOptions;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dashboardData = await ApiService.getDashboard();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      _loadDemoData();
    }
  }

  int _animalPage = 1;
  bool _hasMoreAnimals = true;

  Future<void> loadAnimals() async {
    _isLoading = true;
    _error = null;
    _animalPage = 1;
    _hasMoreAnimals = true;
    notifyListeners();
    try {
      final result = await ApiService.getAnimals();
      _animals = result.isEmpty ? _demoAnimals : result;
      _hasMoreAnimals = _animals.length >= 20;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _animals = _demoAnimals;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreAnimals() async {
    if (!_hasMoreAnimals || _isLoading) return;
    try {
      _animalPage++;
      final more = await ApiService.getAnimals(page: _animalPage);
      if (more.isEmpty) {
        _hasMoreAnimals = false;
      } else {
        _animals.addAll(more);
        _hasMoreAnimals = more.length >= 20;
      }
      notifyListeners();
    } catch (e) {
      _animalPage--;
    }
  }

  Future<void> loadMapData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.getMapData();
      final markers = data['markers'] as List? ?? [];
      _mapData = markers.map((d) {
        final dev = d as Map;
        final animal = dev['animal'] as Map?;
        return {
          'id': dev['id'],
          'device_id': dev['device_id'],
          'name': dev['name'] ?? dev['device_id'],
          'status': dev['status'] ?? 'online',
          'battery_level': dev['battery_level'] ?? 0,
          'latitude': dev['latitude'] ?? dev['gps_lat'],
          'longitude': dev['longitude'] ?? dev['gps_lng'],
          'animal_id': animal?['id'],
          'animal_name': animal?['name'],
        };
      }).toList();
      if (_mapData.isEmpty) _loadDemoMapData();
      _geofences = (await ApiService.getGeofences()) as List;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _loadDemoMapData();
      notifyListeners();
    }
  }

  Future<void> loadGeofences() async {
    try {
      _geofences = await ApiService.getGeofences();
      notifyListeners();
    } catch (e) {
      _geofences = _demoGeofences;
      notifyListeners();
    }
  }

  Future<void> loadGroups() async {
    try {
      _groups = await ApiService.getAnimalGroups();
      notifyListeners();
    } catch (e) {
      _groups = [];
      notifyListeners();
    }
  }

  Future<void> loadOwners() async {
    try {
      dynamic u = await ApiService.getUsers();
      _owners = (u is List) ? u : <dynamic>[];
      _owners = _owners.where((x) => (x is Map) && x['role'] == 'Owner').toList();
      notifyListeners();
    } catch (e) {
      _owners = <dynamic>[];
      notifyListeners();
    }
  }

  Future<void> updateGeofence(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.updateGeofence(id, data);
      await loadGeofences();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGeofence(int id) async {
    try {
      await ApiService.deleteGeofence(id);
      _geofences.removeWhere((g) => g['id'] == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAlerts() async {
    try {
      _alerts = await ApiService.getGeofenceAlerts();
      log('loadAlerts: got ${_alerts.length} alerts');
      notifyListeners();
    } catch (e) {
      log('loadAlerts: error = $e');
      _alerts = _demoAlerts;
      notifyListeners();
    }
  }

  Future<void> acknowledgeAlert(int alertId) async {
    try {
      await ApiService.acknowledgeAlert(alertId);
      _alerts.removeWhere((a) => a['id'] == alertId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    _isLoading = true;
    notifyListeners();
    try {
      log('Loading users from API...');
      dynamic result = await ApiService.getUsers();
      log('Users API response: $result');
      if (result is List) {
        _users = result;
        log('Users loaded as List: ${_users.length}');
      } else if (result is Map && result.containsKey('data')) {
        _users = (result['data'] as List?) ?? [];
        log('Users loaded from data key: ${_users.length}');
      } else if (result is Map && result.containsKey('users')) {
        _users = (result['users'] as List?) ?? [];
        log('Users loaded from users key: ${_users.length}');
      } else {
        log('Unexpected result type: ${result.runtimeType}');
        _users = [];
      }
      notifyListeners();
    } catch (e) {
      log('Error loading users: $e');
      _error = e.toString();
      notifyListeners();
    }
    _isLoadingUsers = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreUsers() async {
    try {
      dynamic more = await ApiService.getUsers();
      if (more is List) _users.addAll(more);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    try {
      await ApiService.updateUser(userData['id'], userData);
      await loadUsers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    try {
      _tasks = await ApiService.getTasks();
      notifyListeners();
    } catch (e) {
      _tasks = _demoTasks;
      notifyListeners();
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      await ApiService.createTask(taskData);
      await loadTasks();
    } catch (e) {
      _tasks.insert(0, {'id': DateTime.now().millisecondsSinceEpoch, 'title': taskData['title'], 'priority': 'medium', 'status': 'pending', 'assignee_name': 'Me'});
      notifyListeners();
    }
  }

  Future<void> updateTask(int taskId, Map<String, dynamic> taskData) async {
    try {
      await ApiService.updateTask(taskId, taskData);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> completeTask(int taskId) async {
    try {
      await ApiService.completeTask(taskId);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await ApiService.deleteTask(taskId);
      _tasks.removeWhere((t) => t['id'] == taskId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> submitTaskLog(int taskId, Map<String, dynamic> logData) async {
    try {
      await ApiService.submitTaskLog(taskId, logData);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAuctions() async {
    try {
      _auctions = await ApiService.getAuctions();
      notifyListeners();
    } catch (e) {
      _auctions = _demoAuctions;
      notifyListeners();
    }
  }

  Future<void> createAuction(Map<String, dynamic> data) async {
    try {
      await ApiService.createAuction(data);
      await loadAuctions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateAuction(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.updateAuction(id, data);
      await loadAuctions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteAuction(int id) async {
    try {
      await ApiService.deleteAuction(id);
      _auctions.removeWhere((a) => a['id'] == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> placeBid(int auctionId, double amount) async {
    try {
      await ApiService.placeBid(auctionId, amount);
      await loadAuctions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> endAuctionEarly(int id) async {
    try {
      await ApiService.endAuctionEarly(id);
      await loadAuctions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadDevices() async {
    try {
      _devices = await ApiService.getDevices();
      log('loadDevices: got ${_devices.length} devices: ${_devices.take(2).toList()}');
      notifyListeners();
    } catch (e) {
      log('loadDevices: error = $e');
      _devices = [];
      notifyListeners();
    }
  }

  Future<void> createDevice(Map<String, dynamic> data) async {
    try {
      await ApiService.createDevice(data);
      await loadDevices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDevice(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.updateDevice(id, data);
      await loadDevices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDevice(int id) async {
    try {
      await ApiService.deleteDevice(id);
      _devices.removeWhere((d) => d['id'] == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCurrentSubscription() async {
    try {
      _currentSubscription = await ApiService.getCurrentSubscription();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadSubscriptionTiers() async {
    try {
      _subscriptionTiers = await ApiService.getSubscriptionTiers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> subscribeToTier(String tierId) async {
    try {
      await ApiService.subscribeToTier(tierId);
      await loadCurrentSubscription();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> cancelSubscription() async {
    try {
      await ApiService.cancelSubscription();
      await loadCurrentSubscription();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadVaccinations() async {
    try {
      _vaccinations = await ApiService.getVaccinations();
      notifyListeners();
    } catch (e) {
      _vaccinations = _demoVaccinations;
      notifyListeners();
    }
  }

  Future<void> createVaccination(Map<String, dynamic> data) async {
    try {
      await ApiService.createVaccination(data);
      await loadVaccinations();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMedicalRecords() async {
    try {
      _medicalRecords = await ApiService.getMedicalRecords();
      notifyListeners();
    } catch (e) {
      _medicalRecords = _demoMedicalRecords;
      notifyListeners();
    }
  }

  Future<void> createMedicalRecord(Map<String, dynamic> data) async {
    try {
      await ApiService.createMedicalRecord(data);
      await loadMedicalRecords();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createAnimal(Map<String, dynamic> data) async {
    try {
      final newAnimal = await ApiService.createAnimal(data);
      _animals.add(newAnimal);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateAnimal(int id, Map<String, dynamic> data) async {
    try {
      final updated = await ApiService.updateAnimal(id, data);
      final idx = _animals.indexWhere((a) => a['id'] == id);
      if (idx != -1) {
        _animals[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteAnimal(int id) async {
    try {
      await ApiService.deleteAnimal(id);
      _animals.removeWhere((a) => a['id'] == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _loadDemoData() {
    _dashboardData = {'total_animals': 142, 'active_alerts': 3, 'healthy_count': 138};
    _animals = _demoAnimals;
    notifyListeners();
  }

  void _loadDemoMapData() {
    _mapData = _demoAnimals;
    notifyListeners();
  }

  List<dynamic> get demoAnimals => _demoAnimals;
  List<dynamic> get demoAlerts => _demoAlerts;
  List<dynamic> get demoGeofences => _demoGeofences;
  List<dynamic> get demoTasks => _demoTasks;
  List<dynamic> get demoVaccinations => _demoVaccinations;
  List<dynamic> get demoAuctions => _demoAuctions;
  List<dynamic> get demoMedicalRecords => _demoMedicalRecords;

  static final List<dynamic> _demoAnimals = [
    {'id': 1, 'name': 'Al-Sahra', 'species': 'Camel', 'status': 'Active'},
    {'id': 2, 'name': 'Desert Rose', 'species': 'Camel', 'status': 'Grazing'},
  ];
  static final List<dynamic> _demoAlerts = [
    {'id': 1, 'type': 'out_of_range', 'animal_name': 'Al-Sahra'},
  ];
  static final List<dynamic> _demoGeofences = [
    {'id': 1, 'name': 'Zone A'},
  ];
  static final List<dynamic> _demoTasks = [
    {'id': 1, 'title': 'Morning Feeding', 'priority': 'high', 'status': 'pending'},
  ];
  static final List<dynamic> _demoVaccinations = [
    {'id': 1, 'vaccine_name': 'FMD'},
  ];
  static final List<dynamic> _demoAuctions = [
    {'id': 1, 'title': 'Camel Auction', 'status': 'active'},
  ];
  static final List<dynamic> _demoMedicalRecords = [
    {'id': 1, 'record_type': 'Checkup'},
  ];
}