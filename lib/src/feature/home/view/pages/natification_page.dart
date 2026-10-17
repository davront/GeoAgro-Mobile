import 'package:agro_employee_public/src/core/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_route_names.dart';
import '../../../../data/model/notification/notification_models.dart';
import '../../../home/vm/notifications_vm.dart';
import '../../../../data/repository/app_repository_impl.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';

final notificationsVM = ChangeNotifierProvider<NotificationsVm>((ref) {
  return NotificationsVm(AppRepositoryImpl());
});

class NatificationPage extends ConsumerStatefulWidget {
  const NatificationPage({super.key});

  @override
  ConsumerState<NatificationPage> createState() => _NatificationPageState();
}

class _NatificationPageState extends ConsumerState<NatificationPage> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsVM).refresh();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(notificationsVM);
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: "Bildirishnomalar",
        canPop: true,
        actions: [
          if (vm.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsVM).markAllAsRead(),
              child: Text("Barchasini o'qilgan qilish",
                  style: TextStyle(fontSize: 12.sp)),
            ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(notificationsVM).refresh(),
              child: vm.notifications.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 200.h),
                        Center(
                            child: Text(
                                "Hozircha hech qanday bildirishnoma yo'q",
                                style: TextStyle(fontSize: 16.sp))),
                      ],
                    )
                  // На широком экране список уведомлений (ListTile во всю
                  // ширину) выглядел растянутой тонкой строкой — тот же
                  // паттерн ограничения ширины, что у форм (Task 5), не
                  // grid: уведомления по природе — вертикальный лог
                  // событий, не набор самостоятельных карточек.
                  : Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: Responsive.getMaxContentWidth(context),
                        ),
                        child: ListView.separated(
                          controller: _controller,
                          padding: REdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          itemBuilder: (context, index) {
                            if (index == vm.notifications.length) {
                              return Padding(
                                padding: REdgeInsets.symmetric(vertical: 16),
                                child: ElevatedButton(
                                  onPressed: vm.isFetchingMore
                                      ? null
                                      : () =>
                                          ref.read(notificationsVM).fetchMore(),
                                  child: vm.isFetchingMore
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Text("Yana yuklash"),
                                ),
                              );
                            }
                            final item = vm.notifications[index];
                            return _NotificationTile(
                              item: item,
                              onRead: () =>
                                  ref.read(notificationsVM).markAsRead(item.id),
                              onDelete: () =>
                                  ref.read(notificationsVM).delete(item.id),
                              onOpenPlantation: item.hasDeepLink
                                  ? () => context.go(
                                        "${AppRouteNames.home}${AppRouteNames.plantationView}",
                                        extra: item.plantationId,
                                      )
                                  : null,
                            );
                          },
                          separatorBuilder: (_, __) => 12.verticalSpace,
                          itemCount:
                              vm.notifications.length + (vm.hasMore ? 1 : 0),
                        ),
                      ),
                    ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onRead;
  final VoidCallback onDelete;
  final VoidCallback? onOpenPlantation;

  const _NotificationTile({
    required this.item,
    required this.onRead,
    required this.onDelete,
    this.onOpenPlantation,
  });

  IconData _iconForType() {
    switch (item.type) {
      case 'plantation_created':
        return Icons.add_circle_outline;
      case 'plantation_updated':
        return Icons.edit_note;
      case 'plantation_rejected':
        return Icons.cancel_outlined;
      case 'plantation_approved':
        return Icons.check_circle_outline;
      case 'plantation_deleted':
        return Icons.delete_outline;
      default:
        return item.isRead
            ? Icons.notifications_none
            : Icons.notifications_active;
    }
  }

  Color _colorForPriority() {
    switch (item.priority) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'low':
        return Colors.blueGrey;
      default:
        return item.isRead ? Colors.grey : Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _colorForPriority();
    return Dismissible(
      key: ValueKey("notif_${item.id}"),
      background: Container(color: Colors.redAccent),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onOpenPlantation,
        leading: Icon(_iconForType(), color: accent),
        title: Text(item.title,
            style: TextStyle(
                fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.message),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (item.typeDisplay.isNotEmpty)
                  _Chip(text: item.typeDisplay, color: accent),
                if (item.priority.isNotEmpty && item.priority != 'normal')
                  _Chip(text: item.priority, color: accent),
                if (item.timeAgo.isNotEmpty)
                  Text(
                    item.timeAgo,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
              ],
            ),
            if (item.type == 'plantation_rejected' &&
                (item.moderationComment ?? '').isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  "Moderator izohi: ${item.moderationComment}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: !item.isRead
            ? IconButton(
                icon: const Icon(Icons.mark_email_read_outlined),
                onPressed: onRead)
            : null,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
