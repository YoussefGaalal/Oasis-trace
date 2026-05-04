class AppConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8050/api',
  );

  static String get baseUrl => apiUrl;

  static String get imageBaseUrl => apiUrl.replaceAll('/api', '');
}