import 'task_status.dart';

/// Модели задач (`/api/tasks/`).
///
/// В списке `plantation` приходит числом, в карточке — объектом; поэтому
/// [TaskListItem] хранит только id плантации, а [TaskDetail] — весь объект.

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

DateTime? _asDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _asText(dynamic value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1';
  }
  return false;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<TaskListItem> _itemsFrom(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(_asMap)
      .whereType<Map<String, dynamic>>()
      .map(TaskListItem.fromJson)
      .toList();
}

class TaskUserRef {
  final int id;
  final String username;
  final String firstName;
  final String lastName;

  const TaskUserRef({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory TaskUserRef.fromJson(Map<String, dynamic> json) => TaskUserRef(
        id: _asInt(json['id']) ?? 0,
        username: json['username'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
      );

  String get displayName {
    final name = '${firstName.trim()} ${lastName.trim()}'.trim();
    return name.isEmpty ? username : name;
  }
}

class TaskDistrictRef {
  final int id;
  final String name;
  final int? region;
  final String? regionName;

  const TaskDistrictRef({
    required this.id,
    required this.name,
    this.region,
    this.regionName,
  });

  factory TaskDistrictRef.fromJson(Map<String, dynamic> json) =>
      TaskDistrictRef(
        id: _asInt(json['id']) ?? 0,
        name: json['name'] as String? ?? '',
        region: _asInt(json['region']),
        regionName: _asText(json['region_name']),
      );
}

class TaskPlantationRef {
  final int id;
  final String? districtName;
  final String? moderationStatus;
  final bool isRejected;
  final double? totalArea;

  const TaskPlantationRef({
    required this.id,
    this.districtName,
    this.moderationStatus,
    this.isRejected = false,
    this.totalArea,
  });

  factory TaskPlantationRef.fromJson(Map<String, dynamic> json) =>
      TaskPlantationRef(
        id: _asInt(json['id']) ?? 0,
        districtName: _asText(json['district_name']),
        moderationStatus: _asText(json['moderation_status']),
        isRejected: _asBool(json['is_rejected']),
        totalArea: _asDouble(json['total_area']),
      );
}

class TaskListItem {
  final int id;
  final String title;
  final TaskStatus status;
  final DateTime? deadline;
  final bool isOverdue;
  final DateTime? createdAt;
  final TaskUserRef? assigner;
  final TaskUserRef? executor;
  final TaskDistrictRef? district;
  final int? plantationId;

  const TaskListItem({
    required this.id,
    required this.title,
    required this.status,
    required this.isOverdue,
    this.deadline,
    this.createdAt,
    this.assigner,
    this.executor,
    this.district,
    this.plantationId,
  });

  factory TaskListItem.fromJson(Map<String, dynamic> json) => TaskListItem(
        id: _asInt(json['id']) ?? 0,
        title: _asText(json['title']) ?? '',
        status:
            TaskStatus.fromApi(json['status']?.toString()) ?? TaskStatus.newTask,
        deadline: _asDate(json['deadline']),
        isOverdue: _asBool(json['is_overdue']),
        createdAt: _asDate(json['created_at']),
        assigner: _userOrNull(json['assigner']),
        executor: _userOrNull(json['executor']),
        district: _districtOrNull(json['district']),
        plantationId: plantationIdFrom(json['plantation']),
      );

  bool get hasPlantation => plantationId != null;

  /// Исполнитель этой задачи — текущий пользователь.
  bool isExecutor(int userId) => userId > 0 && executor?.id == userId;
}

class TaskDetail extends TaskListItem {
  final TaskPlantationRef? plantation;
  final String? description;
  final String? file;
  final String? resultComment;
  final String? reviewComment;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? reviewedAt;
  final DateTime? updatedAt;

  const TaskDetail({
    required super.id,
    required super.title,
    required super.status,
    required super.isOverdue,
    super.deadline,
    super.createdAt,
    super.assigner,
    super.executor,
    super.district,
    super.plantationId,
    this.plantation,
    this.description,
    this.file,
    this.resultComment,
    this.reviewComment,
    this.startedAt,
    this.completedAt,
    this.reviewedAt,
    this.updatedAt,
  });

  factory TaskDetail.fromJson(Map<String, dynamic> json) {
    final plantationRaw = json['plantation'];
    return TaskDetail(
      id: _asInt(json['id']) ?? 0,
      title: _asText(json['title']) ?? '',
      status:
          TaskStatus.fromApi(json['status']?.toString()) ?? TaskStatus.newTask,
      deadline: _asDate(json['deadline']),
      isOverdue: _asBool(json['is_overdue']),
      createdAt: _asDate(json['created_at']),
      assigner: _userOrNull(json['assigner']),
      executor: _userOrNull(json['executor']),
      district: _districtOrNull(json['district']),
      plantationId: plantationIdFrom(plantationRaw),
      plantation: () {
        final map = _asMap(plantationRaw);
        return map == null ? null : TaskPlantationRef.fromJson(map);
      }(),
      description: _asText(json['description']),
      file: _asText(json['file']),
      resultComment: _asText(json['result_comment']),
      reviewComment: _asText(json['review_comment']),
      startedAt: _asDate(json['started_at']),
      completedAt: _asDate(json['completed_at']),
      reviewedAt: _asDate(json['reviewed_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }

  bool get hasFile => file != null;
}

class TasksListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<TaskListItem> results;

  const TasksListResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory TasksListResponse.fromJson(Map<String, dynamic> json) {
    final results = _itemsFrom(json['results']);
    return TasksListResponse(
      count: _asInt(json['count']) ?? results.length,
      next: _asText(json['next']),
      previous: _asText(json['previous']),
      results: results,
    );
  }

  /// Список может прийти DRF-конвертом `{count, results}` или голым массивом.
  /// Любой другой тип (null, строка, число) — пустой список, без TypeError:
  /// иначе экран рисует «неожиданную ошибку» при фактически пустых задачах.
  factory TasksListResponse.fromDecoded(dynamic decoded) {
    if (decoded is List) {
      final results = _itemsFrom(decoded);
      return TasksListResponse(count: results.length, results: results);
    }
    final json = _asMap(decoded);
    if (json == null) {
      return const TasksListResponse(count: 0, results: []);
    }
    return TasksListResponse.fromJson(json);
  }

  bool get hasNext => next != null;
}

class TaskStats {
  final int total;
  final int overdue;
  final Map<TaskStatus, int> byStatus;

  const TaskStats({
    required this.total,
    required this.overdue,
    required this.byStatus,
  });

  factory TaskStats.fromDecoded(dynamic decoded) {
    final json = _asMap(decoded);
    if (json == null) {
      return TaskStats(
        total: 0,
        overdue: 0,
        byStatus: {for (final status in TaskStatus.values) status: 0},
      );
    }
    return TaskStats.fromJson(json);
  }

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    final raw = json['by_status'];
    final counts = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      counts[status] = raw is Map ? (_asInt(raw[status.apiValue]) ?? 0) : 0;
    }
    return TaskStats(
      total: _asInt(json['total']) ?? 0,
      overdue: _asInt(json['overdue']) ?? 0,
      byStatus: counts,
    );
  }

  int countOf(TaskStatus status) => byStatus[status] ?? 0;

  /// Сколько задач висит на исполнителе — цифра для бейджа на вкладке.
  int get activeCount => TaskStatus.values
      .where((s) => s.isActive)
      .fold(0, (sum, s) => sum + countOf(s));
}

/// В списке приходит id плантации числом, в карточке — объектом.
int? plantationIdFrom(dynamic value) {
  if (value is Map) return _asInt(value['id']);
  return _asInt(value);
}

TaskUserRef? _userOrNull(dynamic value) {
  final json = _asMap(value);
  return json == null ? null : TaskUserRef.fromJson(json);
}

TaskDistrictRef? _districtOrNull(dynamic value) {
  final json = _asMap(value);
  return json == null ? null : TaskDistrictRef.fromJson(json);
}
