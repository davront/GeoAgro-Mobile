import '../../../../localization/app_strings.dart';

/// Статусы задачи и переходы, доступные исполнителю.
///
/// Бэкенд присылает `status_display` на русском, приложение узбекоязычное —
/// поэтому подписи берём из [AppStrings], а `status_display` не используем.
/// Приёмка задачи (`accepted`/`rejected`) делается в веб-кабинете, в мобилке
/// её нет: см. [executorActionsFor].
enum TaskStatus {
  newTask('new', AppStrings.taskStatusNew),
  inProgress('in_progress', AppStrings.taskStatusInProgress),
  done('done', AppStrings.taskStatusDone),
  accepted('accepted', AppStrings.taskStatusAccepted),
  rejected('rejected', AppStrings.taskStatusRejected);

  const TaskStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TaskStatus? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final status in TaskStatus.values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }

  /// Задача ещё на исполнителе: не сдана и не закрыта.
  bool get isActive =>
      this == TaskStatus.newTask ||
      this == TaskStatus.inProgress ||
      this == TaskStatus.rejected;
}

/// Действие исполнителя над задачей: целевой статус + требования к комментарию.
enum TaskAction {
  start(TaskStatus.inProgress, AppStrings.taskActionStart,
      commentRequired: false),
  submit(TaskStatus.done, AppStrings.taskActionSubmit, commentRequired: true),
  resume(TaskStatus.inProgress, AppStrings.taskActionResume,
      commentRequired: false);

  const TaskAction(this.target, this.label, {required this.commentRequired});

  final TaskStatus target;
  final String label;
  final bool commentRequired;
}

/// Кнопки, которые исполнитель видит при данном статусе задачи.
List<TaskAction> executorActionsFor(TaskStatus status) {
  switch (status) {
    case TaskStatus.newTask:
      return const [TaskAction.start, TaskAction.submit];
    case TaskStatus.inProgress:
      return const [TaskAction.submit];
    case TaskStatus.rejected:
      return const [TaskAction.resume, TaskAction.submit];
    case TaskStatus.done:
    case TaskStatus.accepted:
      return const [];
  }
}
