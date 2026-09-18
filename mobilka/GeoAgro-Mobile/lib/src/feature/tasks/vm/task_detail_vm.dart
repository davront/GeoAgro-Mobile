import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../localization/app_strings.dart';
import '../../../core/setting/setup.dart';
import '../../../core/utils/dio_error_utils.dart';
import '../../../data/model/task/task_models.dart';
import '../../../data/model/task/task_status.dart';
import '../../../data/repository/app_repository_impl.dart';

/// Карточка задачи и смена её статуса исполнителем.
class TaskDetailVm extends ChangeNotifier {
  final AppRepositoryImpl _repo;
  final int taskId;

  TaskDetailVm(this._repo, this.taskId);

  TaskDetail? task;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  /// Кнопки действий рисуем только исполнителю. Бэкенд всё равно перепроверит.
  List<TaskAction> get availableActions {
    final current = task;
    if (current == null || !current.isExecutor(userId)) return const [];
    return executorActionsFor(current.status);
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _repo.getTaskDetail(id: taskId);
      if (data == null) {
        errorMessage =
            AppRepositoryImpl.lastErrorMessage ?? AppStrings.taskLoadFailed;
      } else {
        task = TaskDetail.fromJson(jsonDecode(data) as Map<String, dynamic>);
      }
    } catch (e) {
      errorMessage = DioErrorUtils.messageFromAny(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Возвращает `null` при успехе либо текст ошибки для показа пользователю.
  /// Текст валидации приходит с бэкенда на русском и показывается как есть.
  Future<String?> apply(TaskAction action, {String? comment}) async {
    if (isSubmitting) return null;
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await _repo.changeTaskStatus(
        id: taskId,
        status: action.target.apiValue,
        comment: comment,
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        task = TaskDetail.fromJson(data);
        return null;
      }
      return _messageFrom(data) ?? _fallbackFor(response.statusCode);
    } catch (e) {
      return DioErrorUtils.messageFromAny(e);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}

/// Тело ошибки задач — либо `{"detail": "..."}`, либо ошибки по полям
/// `{"status": ["..."], "comment": ["..."]}`. Имя поля пользователю не
/// показываем: бэкенд присылает уже готовую фразу.
String? _messageFrom(dynamic data) {
  if (data is String && data.trim().isNotEmpty) return data.trim();
  if (data is! Map) return null;

  for (final key in const ['detail', 'message', 'error']) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }

  for (final value in data.values) {
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is String && first.trim().isNotEmpty) return first.trim();
    } else if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String _fallbackFor(int statusCode) {
  if (statusCode == 403) return AppStrings.taskNoPermission;
  if (statusCode == 404) return AppStrings.taskNotFound;
  if (statusCode >= 500) return AppStrings.serverError;
  return AppStrings.taskStatusChangeFailed;
}
