import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/utils/dio_error_utils.dart';
import '../../../data/repository/app_repository_impl.dart';

import '../../../data/model/notification/notification_models.dart';

class NotificationsVm extends ChangeNotifier {
  final AppRepositoryImpl _repo;

  NotificationsVm(this._repo);

  final List<NotificationItem> notifications = [];
  bool isLoading = false;
  bool isFetchingMore = false;
  String? errorMessage;
  int limit = 20;
  int offset = 0;
  bool hasMore = true;
  int unreadCount = 0;
  Timer? _pollTimer;

  Future<void> refresh({bool unreadOnly = false}) async {
    errorMessage = null;
    isLoading = true;
    notifications.clear();
    offset = 0;
    hasMore = true;
    notifyListeners();

    try {
      final data = await _repo.getNotifications(
          limit: limit, offset: offset, unreadOnly: unreadOnly);
      if (data == null) {
        errorMessage = AppRepositoryImpl.lastErrorMessage ??
            "Server bilan bog'liq xatolik yuzaga keldi.";
      } else {
        final jsonData = jsonDecode(data) as Map<String, dynamic>;
        final resp = NotificationsResponse.fromJson(jsonData);
        notifications.addAll(resp.notifications);
        unreadCount = resp.unreadCount;
        hasMore = resp.hasMore;
        offset += resp.notifications.length;
      }
    } catch (e) {
      errorMessage = DioErrorUtils.messageFromAny(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    if (!hasMore || isFetchingMore) return;
    isFetchingMore = true;
    notifyListeners();
    try {
      final data = await _repo.getNotifications(limit: limit, offset: offset);
      if (data != null) {
        final jsonData = jsonDecode(data) as Map<String, dynamic>;
        final resp = NotificationsResponse.fromJson(jsonData);
        notifications.addAll(resp.notifications);
        hasMore = resp.hasMore;
        offset += resp.notifications.length;
      }
    } finally {
      isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final data = await _repo.markNotificationsAsRead(markAll: true);
    if (data != null) {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = NotificationItem(
          id: notifications[i].id,
          type: notifications[i].type,
          typeDisplay: notifications[i].typeDisplay,
          title: notifications[i].title,
          message: notifications[i].message,
          priority: notifications[i].priority,
          isRead: true,
          createdAt: notifications[i].createdAt,
          readAt: notifications[i].readAt ?? DateTime.now(),
          plantationId: notifications[i].plantationId,
          extraData: notifications[i].extraData,
          timeAgo: notifications[i].timeAgo,
        );
      }
      unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    final data = await _repo.markNotificationAsRead(id: id);
    if (data != null) {
      final idx = notifications.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final item = notifications[idx];
        notifications[idx] = NotificationItem(
          id: item.id,
          type: item.type,
          typeDisplay: item.typeDisplay,
          title: item.title,
          message: item.message,
          priority: item.priority,
          isRead: true,
          createdAt: item.createdAt,
          readAt: item.readAt ?? DateTime.now(),
          plantationId: item.plantationId,
          extraData: item.extraData,
          timeAgo: item.timeAgo,
        );
        unreadCount = (unreadCount - 1).clamp(0, 1 << 31);
        notifyListeners();
      }
    }
  }

  Future<void> delete(int id) async {
    final data = await _repo.deleteNotification(id: id);
    if (data != null) {
      notifications.removeWhere((e) => e.id == id);
      notifyListeners();
    }
  }

  /// Загрузить счетчик непрочитанных уведомлений
  Future<void> loadUnreadCount() async {
    try {
      final data = await _repo.getUnreadNotificationsCount();
      if (data != null) {
        final jsonData = jsonDecode(data) as Map<String, dynamic>;
        unreadCount = jsonData['unread_count'] as int? ?? 0;
        notifyListeners();
      }
    } catch (e) {
      // Игнорируем ошибки при загрузке счетчика
    }
  }

  /// Polling-режим уведомлений без FCM.
  /// Каждые 30 секунд:
  /// 1) Проверка /unread-count/
  /// 2) Если > 0 — загрузка unread уведомлений
  /// 3) mark_all_as_read
  void startPolling() {
    _pollTimer?.cancel();
    _pollUnreadNotifications(); // Сразу при старте
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _pollUnreadNotifications(),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollUnreadNotifications() async {
    try {
      final data = await _repo.getUnreadNotificationsCount();
      if (data == null) return;
      final jsonData = jsonDecode(data) as Map<String, dynamic>;
      final unread = jsonData['unread_count'] as int? ?? 0;
      unreadCount = unread;
      notifyListeners();

      if (unread <= 0) return;

      // Подтягиваем непрочитанные
      final unreadListData = await _repo.getNotifications(
        limit: 50,
        offset: 0,
        unreadOnly: true,
      );
      if (unreadListData == null) return;

      final unreadJson = jsonDecode(unreadListData) as Map<String, dynamic>;
      final unreadResp = NotificationsResponse.fromJson(unreadJson);
      if (unreadResp.notifications.isNotEmpty) {
        notifications
          ..clear()
          ..addAll(unreadResp.notifications);
        unreadCount = unreadResp.unreadCount;
        hasMore = unreadResp.hasMore;
        offset = unreadResp.notifications.length;
        notifyListeners();
      }

      // После подтягивания помечаем как прочитанные
      await markAllAsRead();
    } catch (_) {
      // Тихо падаем и пробуем на следующем тике
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
