class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  static const String apiTimeout = '10'; // seconds

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUserData = 'user_data';

  // App Name
  static const String appName = 'SJ Order App';
  static const String appVersion = '1.0.0';

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // UI Configuration
  static const int animationDuration = 300; // milliseconds
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
}

