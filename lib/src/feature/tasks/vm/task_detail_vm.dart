import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../localization/app_strings.dart';
import '../../../core/setting/setup.dart';
import '../../../core/utils/dio_error_utils.dart';
import '../../../core/utils/plantation_location_guard.dart';
import '../../../data/model/plantation/edit_plantation.dart';
import '../../../data/model/task/task_models.dart';
import '../../../data/model/task/task_status.dart';
import '../../../data/repository/app_repository_impl.dart';

/// Результат смены статуса: успех, ошибка или игнор повторного tap.
class TaskApplyResult {
  const TaskApplyResult._({this.errorMessage, this.ignored = false});
  const TaskApplyResult.ok() : this._();
  const TaskApplyResult.ignored() : this._(ignored: true);
  const TaskApplyResult.error(String message) : this._(errorMessage: message);

  final String? errorMessage;
  final bool ignored;

  bool get isOk => errorMessage == null && !ignored;
}

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
        task = TaskDetail.fromJson(
            Map<String, dynamic>.from(jsonDecode(data) as Map));
      }
    } catch (e) {
      errorMessage = DioErrorUtils.messageFromAny(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Смена статуса. Повторный tap во время submit → [TaskApplyResult.ignored]
  /// (не успех). Для [TaskAction.submit] с плантацией: fail-closed GPS +
  /// `is_rejected`; в body уходит `user_location`.
  Future<TaskApplyResult> apply(TaskAction action, {String? comment}) async {
    if (isSubmitting) return const TaskApplyResult.ignored();
    isSubmitting = true;
    notifyListeners();

    try {
      Map<String, double>? userLocation;

      if (action == TaskAction.submit) {
        final gateError = await _prepareSubmit();
        if (gateError != null) return TaskApplyResult.error(gateError);
        userLocation = _pendingUserLocation;
        _pendingUserLocation = null;
      }

      final response = await _repo.changeTaskStatus(
        id: taskId,
        status: action.target.apiValue,
        comment: comment,
        userLocation: userLocation,
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map) {
        task = TaskDetail.fromJson(Map<String, dynamic>.from(data));
        return const TaskApplyResult.ok();
      }
      return TaskApplyResult.error(
          _messageFrom(data) ?? _fallbackFor(response.statusCode));
    } catch (e) {
      return TaskApplyResult.error(DioErrorUtils.messageFromAny(e));
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Map<String, double>? _pendingUserLocation;

  /// Обновляет карточку, проверяет is_rejected по plantation detail, GPS.
  Future<String?> _prepareSubmit() async {
    final data = await _repo.getTaskDetail(id: taskId);
    if (data == null) {
      return AppRepositoryImpl.lastErrorMessage ?? AppStrings.taskLoadFailed;
    }
    task =
        TaskDetail.fromJson(Map<String, dynamic>.from(jsonDecode(data) as Map));
    notifyListeners();

    final plantationId = task?.plantationId;
    if (plantationId == null) {
      // Задача без плантации — GPS не нужен.
      return null;
    }

    // Карточка явно говорит rejected — можно не ждать detail.
    if (task?.plantation?.isRejected == true) {
      return AppStrings.taskMustResubmitPlantation;
    }

    final detailJson = await _repo.getPlantationDetail(id: plantationId);
    if (detailJson == null) {
      return AppRepositoryImpl.lastErrorMessage ??
          AppStrings.taskPlantationNoCoords;
    }

    final map =
        Map<String, dynamic>.from(jsonDecode(detailJson) as Map);
    final plantation = EditPlantationModel.fromJson(map);

    // Fail-closed: без ключа is_rejected статус неизвестен → блок.
    final bool? rejectedFlag = map.containsKey('is_rejected')
        ? plantation.isRejected == true
        : null;
    final rejectedError = TaskSubmitGate.rejectIfPlantationStillRejected(
      isRejected: rejectedFlag,
    );
    if (rejectedError != null) return rejectedError;

    final raw = plantation.coordinates;
    if (raw == null || raw.length < 3) {
      return AppStrings.taskPlantationNoCoords;
    }

    final polygon = TaskSubmitGate.polygonFromNullablePairs(
      raw.map((c) => (c.latitude, c.longitude)),
    );
    if (polygon.length < 3) return AppStrings.taskPlantationNoCoords;

    final loc = await PlantationLocationGuard.currentUserLocation();
    final nearError =
        await PlantationLocationGuard.checkNearPolygon(loc, polygon);
    if (nearError != null) return nearError;

    _pendingUserLocation = loc;
    return null;
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
