import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_employee_public/firebase_options.dart';
import '../../data/model/fruits/fruit_model.dart';
import '../storage/app_storage.dart';
import '../../data/repository/app_repository_impl.dart';
import '../../../localization/app_strings.dart' show AppLocalizedMaps;

String? accessToken;
bool isBloc = false;
int districtId = 1;
int userId = 0;
String? username;
List<FruitModel> fruitList = [];

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();

  // google_fonts по умолчанию скачивает .ttf с fonts.gstatic.com в
  // рантайме при первом использовании стиля — без сети/DNS это кидает
  // необрабатываемое исключение прямо из TextStyle-геттера, крашило
  // приложение (Failed host lookup: 'fonts.gstatic.com'). Отключаем
  // сетевую загрузку: без сети используется системный fallback-шрифт
  // вместо краша, при наличии сети первая загрузка кэшируется как обычно
  // при последующих запусках — эта настройка не блокирует кэш, только
  // сетевой fetch при промахе кэша.
  GoogleFonts.config.allowRuntimeFetching = false;

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    log("Firebase initialized successfully");
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseAnalytics.instance
          .logEvent(name: 'app_open_test', parameters: {'src': 'setup'});
      log("Analytics: collection enabled + test event sent");
    } catch (e) {
      log("Analytics enable/log failed: $e");
    }
    try {
      // App-start trace, screen rendering (slow/frozen frames) собираются
      // автоматически. Сетевые запросы через Dio отдельно замеряются
      // через PerformanceInterceptor (api.dart) — встроенный network
      // monitoring этого SDK видит только dart:io HttpClient напрямую,
      // не Dio.
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      log("Performance Monitoring: collection enabled");
    } catch (e) {
      log("Performance Monitoring enable failed: $e");
    }
  } catch (e) {
    log("Firebase initialization failed: $e");
    // Continue without Firebase if it fails
  }

  try {
    // Initialize storage and migrate tokens if needed
    await AppStorage.initialize();

    accessToken = await AppStorage.$read(key: StorageKey.accessToken);
    isBloc = await AppStorage.$readBool(key: StorageKey.isBlocked) ?? false;
    username = await AppStorage.$read(key: StorageKey.username);
    final storedDistrict =
        await AppStorage.$readInt(key: StorageKey.districtId);
    if (storedDistrict != null && storedDistrict > 0) {
      districtId = storedDistrict;
      log("Loaded districtId from storage: $districtId");
    }
    final storedUserId = await AppStorage.$readInt(key: StorageKey.userId);
    if (storedUserId != null && storedUserId > 0) {
      userId = storedUserId;
      log("Loaded userId from storage: $userId");
    }
    // Always refresh user info from API on cold start when authenticated —
    // not just when userId/username are missing. isSpecialUser and
    // limit_km can be changed by an admin at any time; gating this behind
    // "cache is empty" meant those flags only ever refreshed on first
    // login, so revoking gallery access (or changing limit_km) had no
    // effect until the user explicitly logged out and back in.
    if (accessToken != null) {
      try {
        final repo = AppRepositoryImpl();
        final userInfo = await repo.getUserInfo();
        if (userInfo != null) {
          final decoded = jsonDecode(userInfo);
          if (decoded is Map<String, dynamic>) {
            final apiUserId = decoded['id'];
            final apiUsername = decoded['username'];
            final apiDistrictId = decoded['district_id'];
            if (apiUserId is int && apiUserId > 0) {
              userId = apiUserId;
              await AppStorage.$writeInt(
                  key: StorageKey.userId, value: apiUserId);
              log('Refreshed userId from API: $userId');
            }
            if (apiUsername is String && apiUsername.isNotEmpty) {
              username = apiUsername;
              await AppStorage.$write(
                  key: StorageKey.username, value: apiUsername);
              log('Refreshed username from API: $username');
            }
            if (apiDistrictId is int && apiDistrictId > 0) {
              districtId = apiDistrictId;
              await AppStorage.$writeInt(
                  key: StorageKey.districtId, value: apiDistrictId);
              log('Refreshed districtId from API: $districtId');
            }

            // Load is_specialuser and limit_km from API response
            final apiIsSpecialUser = decoded['is_specialuser'] ?? false;
            await AppStorage.$writeBool(
                key: StorageKey.isSpecialUser, value: apiIsSpecialUser);
            log('Refreshed isSpecialUser from API: $apiIsSpecialUser');

            final apiLimitKm = decoded['limit_km']?.toDouble();
            if (apiLimitKm != null) {
              await AppStorage.$writeDouble(
                  key: StorageKey.limitKm, value: apiLimitKm);
              log('Refreshed limitKm from API: $apiLimitKm km');
            } else {
              await AppStorage.$delete(key: StorageKey.limitKm);
              log('limitKm is null, using default 1 km');
            }
          }
        }
      } catch (e) {
        log('Failed to refresh user info at setup: $e');
      }
    }
    // Привязывает все Firebase Analytics события этой сессии (включая
    // автоматические — first_open, session_start) к userId, не только
    // сразу после явного логина, но и на холодном старте с уже
    // сохранённым токеном — иначе аналитика по вернувшимся юзерам
    // оставалась бы без привязки к user_id до следующего logout/login.
    if (userId > 0) {
      try {
        await FirebaseAnalytics.instance.setUserId(id: userId.toString());
      } catch (e) {
        log('Failed to set analytics userId at setup: $e');
      }
      // То же для Crashlytics — краши/non-fatal ошибки этой сессии
      // будут видны в консоли с привязкой к userId.
      try {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId.toString());
      } catch (e) {
        log('Failed to set crashlytics userIdentifier at setup: $e');
      }
    }
    log("Storage initialized successfully");
  } catch (e) {
    log("Storage initialization failed: $e");
    // Set default values if storage fails
    accessToken = null;
    isBloc = false;
  }

  // FCM init (запрашивает системный permission на уведомления) больше не
  // вызывается здесь — раньше это спрашивало доступ на самом старте
  // приложения, до логина. Теперь инициализация вызывается из
  // home_page.dart после успешной аутентификации.
}

// Legacy constants - now using AppLocalizedMaps
// Keeping for backward compatibility during migration
// Note: Using getter methods instead of const to maintain compatibility
@Deprecated('Use AppLocalizedMaps.plantationTypes instead')
Map<int, String> get plantatiopnType => AppLocalizedMaps.plantationTypes;

@Deprecated('Use AppLocalizedMaps.issiqxonaTypes instead')
Map<int, String> get issiqxonaType => AppLocalizedMaps.issiqxonaTypes;

@Deprecated('Use AppLocalizedMaps.uzumTypes instead')
Map<int, String> get uzumType => AppLocalizedMaps.uzumTypes;

@Deprecated('Use AppLocalizedMaps.bogTypes instead')
Map<int, String> get bogType => AppLocalizedMaps.bogTypes;

@Deprecated('Use AppLocalizedMaps.bogSubtypes instead')
Map<int, String> get bogSubtype => AppLocalizedMaps.bogSubtypes;

@Deprecated('Use AppLocalizedMaps.yerTuri instead')
Map<int, String> get yerTuri => AppLocalizedMaps.yerTuri;

@Deprecated('Use AppLocalizedMaps.subsidyTypes instead')
Map<int, String> get subsidyType => AppLocalizedMaps.subsidyTypes;

@Deprecated('Use AppLocalizedMaps.regions instead')
Map<int, String> get region => AppLocalizedMaps.regions;
