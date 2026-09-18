import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../localization/app_strings.dart';
import '../../../core/setting/setup.dart';
import '../../../core/utils/dio_error_utils.dart';
import '../../../data/model/task/task_models.dart';
import '../../../data/model/task/task_status.dart';
import '../../../data/repository/app_repository_impl.dart';

/// Список «моих задач»: всегда с фильтром по исполнителю, поэтому экран
/// одинаково ведёт себя для любой роли и не тащит чужие задачи региона.
/// Создание и приёмка задач живут в веб-кабинете, здесь их нет.
class TasksVm extends ChangeNotifier {
  final AppRepositoryImpl _repo;

  TasksVm(this._repo);

  final List<TaskListItem> tasks = [];
  final Set<TaskStatus> statusFilter = {};

  /// Счётчики по всем моим задачам, без фильтров экрана: бейдж на вкладке и
  /// число просроченных не должны прыгать от того, что выбрано на экране.
  TaskStats? overallStats;

  /// Счётчики для чипов статусов: учитывают фильтр просрочки, но не сам
  /// фильтр статусов — иначе после выбора «Yangi» остальные чипы показали бы
  /// нули и фильтр стало бы нечем пользоваться.
  TaskStats? statusStats;

  bool isLoading = false;
  bool isFetchingMore = false;
  bool overdueOnly = false;
  String? errorMessage;
  bool canLoadNext = false;

  int _page = 1;

  bool get hasFilters => statusFilter.isNotEmpty || overdueOnly;

  int get activeCount => overallStats?.activeCount ?? 0;

  int get overdueCount => overallStats?.overdue ?? 0;

  List<String>? get _statusParam => statusFilter.isEmpty
      ? null
      : statusFilter.map((s) => s.apiValue).toList();

  bool? get _overdueParam => overdueOnly ? true : null;

  /// [withStats] выключают там, где счётчики заведомо не изменились —
  /// фильтр по статусу на них не влияет.
  Future<void> load({bool isLoadMore = false, bool withStats = true}) async {
    if (isLoadMore && (!canLoadNext || isFetchingMore || isLoading)) return;

    if (isLoadMore) {
      isFetchingMore = true;
    } else {
      _page = 1;
      isLoading = true;
      errorMessage = null;
    }
    notifyListeners();

    try {
      final data = await _repo.getTasks(
        page: _page,
        statuses: _statusParam,
        overdue: _overdueParam,
        executor: userId,
      );
      if (data == null) {
        errorMessage =
            AppRepositoryImpl.lastErrorMessage ?? AppStrings.networkError;
      } else {
        final response = TasksListResponse.fromJson(
            jsonDecode(data) as Map<String, dynamic>);
        if (!isLoadMore) tasks.clear();
        tasks.addAll(response.results);
        canLoadNext = response.hasNext;
        _page++;
      }
    } catch (e) {
      errorMessage = DioErrorUtils.messageFromAny(e);
    } finally {
      isLoading = false;
      isFetchingMore = false;
      notifyListeners();
    }

    if (!isLoadMore && withStats) await loadStats();
  }

  Future<void> refresh() => load();

  /// Ошибку счётчиков не показываем — список уже сообщит о проблеме со связью.
  Future<void> loadStats() async {
    final overall = await _fetchStats();
    if (overall != null) overallStats = overall;

    // Без фильтра просрочки распределение по статусам совпадает с общим,
    // второй запрос не нужен.
    statusStats =
        overdueOnly ? (await _fetchStats(overdue: true) ?? overall) : overall;

    notifyListeners();
  }

  Future<TaskStats?> _fetchStats({bool? overdue}) async {
    try {
      final data =
          await _repo.getTasksStats(overdue: overdue, executor: userId);
      if (data == null) return null;
      return TaskStats.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleStatus(TaskStatus status) {
    if (!statusFilter.remove(status)) statusFilter.add(status);
    return load(withStats: false);
  }

  Future<void> toggleOverdue() {
    overdueOnly = !overdueOnly;
    return load();
  }

  Future<void> clearFilters() {
    statusFilter.clear();
    overdueOnly = false;
    return load();
  }

  /// После смены статуса на карточке — обновить строку в списке, не
  /// перезапрашивая всю страницу; счётчики пересчитываем.
  void applyUpdated(TaskDetail task) {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) tasks[index] = task;
    notifyListeners();
    loadStats();
  }
}
