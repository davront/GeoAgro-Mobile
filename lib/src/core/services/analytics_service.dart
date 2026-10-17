import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logLogin() => _analytics.logLogin(loginMethod: 'phone');

  static Future<void> logSearch(String query) =>
      _analytics.logSearch(searchTerm: query);

  static Future<void> logEvent(String name, [Map<String, Object>? params]) =>
      _analytics.logEvent(name: name, parameters: params);

  static Future<void> logPlantationCreated(int plantationId) =>
      logEvent('plantation_created', {'plantation_id': plantationId});

  static Future<void> logPlantationDeleted(int plantationId) =>
      logEvent('plantation_deleted', {'plantation_id': plantationId});

  static Future<void> logFarmerCreated(int farmerId) =>
      logEvent('farmer_created', {'farmer_id': farmerId});

  static Future<void> logPageView(String pageName) =>
      logEvent('page_view', {'page_name': pageName});

  static Future<void> setUserId(int userId) =>
      _analytics.setUserId(id: userId.toString());
}
