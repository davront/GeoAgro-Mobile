class NotificationItem {
  final int id;
  final String type;
  final String typeDisplay;
  final String title;
  final String message;
  final String priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final int? plantationId;
  final Map<String, dynamic> extraData;
  final String timeAgo;

  NotificationItem({
    required this.id,
    required this.type,
    required this.typeDisplay,
    required this.title,
    required this.message,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.plantationId,
    required this.extraData,
    required this.timeAgo,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as int,
        type: (json['notification_type'] ?? json['type']) as String? ?? '',
        typeDisplay: json['notification_type_display'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        priority: json['priority'] as String? ?? 'normal',
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        readAt: (json['read_at'] as String?) != null ? DateTime.tryParse(json['read_at'] as String) : null,
        plantationId: json['plantation_id'] as int?,
        extraData: json['extra_data'] is Map<String, dynamic>
            ? (json['extra_data'] as Map<String, dynamic>)
            : <String, dynamic>{},
        timeAgo: json['time_ago'] as String? ?? '',
      );

  String? get moderationComment => extraData['moderation_comment'] as String?;
  bool get hasDeepLink => plantationId != null;
}

class NotificationsResponse {
  final List<NotificationItem> notifications;
  final int unreadCount;
  final bool hasMore;
  final int totalCount;

  NotificationsResponse({
    required this.notifications,
    required this.unreadCount,
    required this.hasMore,
    required this.totalCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) => NotificationsResponse(
        notifications: (json['notifications'] as List<dynamic>? ?? [])
            .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        unreadCount: json['unread_count'] as int? ?? 0,
        hasMore: json['has_more'] as bool? ?? false,
        totalCount: json['total_count'] as int? ?? 0,
      );
}

