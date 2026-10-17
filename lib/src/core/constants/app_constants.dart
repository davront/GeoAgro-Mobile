// App Constants
class AppConstants {
  // API Constants
  static const int apiTimeoutSeconds = 30;
  static const int apiRetryAttempts = 3;
  
  // Map Constants
  static const double defaultMapZoom = 10.0;
  static const double minPolygonPoints = 3.0;
  static const double maxDistanceMeters = 1000.0;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double borderRadius = 8.0;
  
  // Validation Constants
  static const int minContractLength = 3;
  static const int maxContractLength = 50;
  
  // Animation Constants
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

// Error Messages
class ErrorMessages {
  static const String networkError = "Интернет алокасида хатолик юз берди";
  static const String serverError = "Серверда хатолик юз берди";
  static const String invalidToken = "Токен нотўғри";
  static const String locationError = "Жойлашув аниқланмади";
  static const String permissionDenied = "Рухсат берилмади";
}

// Success Messages
class SuccessMessages {
  static const String dataSaved = "Маълумотлар сақланди";
  static const String dataUpdated = "Маълумотлар янгиланди";
  static const String dataDeleted = "Маълумотлар ўчирилди";
} 