import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/repository/app_repository_impl.dart';
import '../routes/app_route_names.dart';
import '../routes/router_config.dart';
import '../storage/app_storage.dart';
import '../setting/setup.dart' as app_setup;

/// Сервис для работы с Firebase Cloud Messaging
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final AppRepositoryImpl _repository = AppRepositoryImpl();

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  Timer? _tokenRetryTimer;
  int _tokenRetryAttempt = 0;
  static const int _maxTokenRetryAttempts = 10;

  bool _initialized = false;
  int? _pendingPlantationId;
  Future<void> Function()? _onUnreadRefreshRequested;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // initialize() (через _getFcmToken) и syncTokenWithBackend() (после login)
  // могут вызвать _sendTokenToServer() почти одновременно с тем же токеном —
  // приводило к дублирующим POST /api/device-tokens/ и intermittent 500 на
  // бэкенде (подтверждено логами: 201/500 пары с одного IP в одну секунду).
  // Лок гарантирует, что второй одновременный вызов ждёт первый вместо
  // отправки дубликата.
  Future<void>? _inFlightSend;
  String? _lastSentToken;

  /// Коллбэк обновления unread badge (подключается из UI).
  void setUnreadRefreshCallback(Future<void> Function()? callback) {
    _onUnreadRefreshRequested = callback;
  }

  /// Инициализация FCM
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        log('User declined notification permission');
        return;
      }

      await _getFcmToken();
      _setupMessageHandlers();

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotification(initialMessage, openedFromTap: true);
      }

      _initialized = true;
      log('FCM initialized successfully');
      debugPrint('FCM: initialized');
    } catch (e) {
      log('FCM initialization failed: $e');
      debugPrint('FCM: initialization failed: $e');
      _scheduleTokenRetry();
    }
  }

  /// Явная синхронизация токена с backend (например, сразу после login).
  Future<void> syncTokenWithBackend() async {
    try {
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        await _getFcmToken();
      }
      await _saveTokenToStorage();
      await _sendTokenToServer();
    } catch (e) {
      log('FCM syncTokenWithBackend failed: $e');
      debugPrint('FCM: syncTokenWithBackend failed: $e');
      _scheduleTokenRetry();
    }
  }

  /// Получить FCM token
  Future<void> _getFcmToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        debugPrint('FCM: getToken returned null/empty');
        _scheduleTokenRetry();
        return;
      }

      debugPrint('FCM: token acquired');
      _tokenRetryAttempt = 0;
      _tokenRetryTimer?.cancel();
      await _saveTokenToStorage();
      await _sendTokenToServer();

      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM: token refreshed');
        _fcmToken = newToken;
        await _saveTokenToStorage();
        await _sendTokenToServer();
      });
    } catch (e) {
      log('Error getting FCM token: $e');
      debugPrint('FCM: error getting token: $e');
      _scheduleTokenRetry();
    }
  }

  /// Сохранить token в локальное хранилище
  Future<void> _saveTokenToStorage() async {
    if (_fcmToken == null || _fcmToken!.isEmpty) return;
    await AppStorage.$write(key: StorageKey.fcmToken, value: _fcmToken!);
  }

  /// Отправить token на сервер
  Future<void> _sendTokenToServer() {
    if (_inFlightSend != null) return _inFlightSend!;
    final future = _doSendTokenToServer();
    _inFlightSend = future;
    return future.whenComplete(() => _inFlightSend = null);
  }

  Future<void> _doSendTokenToServer() async {
    if (_fcmToken == null || _fcmToken!.isEmpty) return;
    if (_fcmToken == _lastSentToken) {
      debugPrint('FCM: token already sent, skip duplicate');
      return;
    }

    final jwt = app_setup.accessToken ??
        await AppStorage.$read(key: StorageKey.accessToken);
    if (jwt == null || jwt.isEmpty) {
      log('Skip device-token sync: user is not authenticated yet');
      debugPrint('FCM: skip backend sync (no jwt yet)');
      return;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final platform = defaultTargetPlatform == TargetPlatform.android
          ? 'android'
          : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');

      final response = await _repository.registerDeviceToken(
        token: _fcmToken!,
        platform: platform,
        appVersion: packageInfo.version,
      );
      if (response == null) {
        debugPrint('FCM: backend token registration failed (null response)');
        _scheduleTokenRetry();
        return;
      }
      _lastSentToken = _fcmToken;
      log('FCM token sent to backend');
      debugPrint('FCM: token sent to backend');
    } catch (e) {
      log('Error sending FCM token to server: $e');
      debugPrint('FCM: error sending token to backend: $e');
      _scheduleTokenRetry();
    }
  }

  void _scheduleTokenRetry() {
    if (_tokenRetryAttempt >= _maxTokenRetryAttempts) {
      debugPrint('FCM: max retry attempts reached');
      return;
    }
    _tokenRetryAttempt++;
    _tokenRetryTimer?.cancel();

    // 5, 10, 15 ... 50 секунд (ограниченный линейный backoff)
    final seconds = (_tokenRetryAttempt * 5).clamp(5, 50);
    debugPrint(
        'FCM: scheduling token retry #$_tokenRetryAttempt in ${seconds}s');
    _tokenRetryTimer = Timer(Duration(seconds: seconds), () async {
      await _getFcmToken();
      await _sendTokenToServer();
    });
  }

  /// Настроить обработчики сообщений
  void _setupMessageHandlers() {
    _onMessageSub?.cancel();
    _onMessageOpenedSub?.cancel();

    _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
      log('Received foreground message: ${message.messageId}');
      _handleNotification(message, openedFromTap: false);
    });

    _onMessageOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('Notification opened app: ${message.messageId}');
      _handleNotification(message, openedFromTap: true);
    });
  }

  /// Обработать уведомление
  void _handleNotification(RemoteMessage message,
      {required bool openedFromTap}) {
    log('Handling notification: ${message.messageId}');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');

    // Обновляем badge при входящем push
    _refreshUnreadBadge();

    if (!openedFromTap) return;

    final plantationIdRaw = message.data['plantation_id'];
    final plantationId = int.tryParse(plantationIdRaw?.toString() ?? '');
    if (plantationId == null || plantationId <= 0) return;

    _navigateToPlantation(plantationId);
  }

  Future<void> _refreshUnreadBadge() async {
    try {
      await _onUnreadRefreshRequested?.call();
    } catch (e) {
      log('Failed to refresh unread badge: $e');
    }
  }

  void _navigateToPlantation(int plantationId) {
    final navContext = parentNavigatorKey.currentContext;
    if (navContext == null) {
      _pendingPlantationId = plantationId;
      return;
    }

    navContext.go(
      "${AppRouteNames.home}${AppRouteNames.plantationView}",
      extra: plantationId,
    );
    _pendingPlantationId = null;
  }

  /// Вызывайте после появления UI, чтобы обработать отложенный deep-link из push.
  void flushPendingNavigation() {
    final pendingId = _pendingPlantationId;
    if (pendingId == null) return;
    _navigateToPlantation(pendingId);
  }

  /// Подписаться на топик
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  /// Отписаться от топика
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Удалить token (при выходе из аккаунта)
  Future<void> deleteToken() async {
    try {
      final localToken = _fcmToken ??
          await AppStorage.$read(key: StorageKey.fcmToken) ??
          await _messaging.getToken();

      if (localToken != null && localToken.isNotEmpty) {
        await _repository.removeDeviceToken(token: localToken);
      }

      await _messaging.deleteToken();
      _fcmToken = null;
      _lastSentToken = null;
      await AppStorage.$delete(key: StorageKey.fcmToken);
      log('FCM token deleted');
      debugPrint('FCM: token deleted locally and on backend');
    } catch (e) {
      log('Error deleting FCM token: $e');
      debugPrint('FCM: error deleting token: $e');
    }
  }
}
