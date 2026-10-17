import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../design_system/tokens/colors.dart' as design_colors;
import '../../../../../design_system/tokens/radii.dart';
import '../../../../../design_system/tokens/spacing.dart';
import '../../../../../design_system/tokens/typography.dart';
import '../../../../core/queue/upload_queue_provider.dart';
import '../../../../core/queue/upload_queue_service.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/custom_app_bar_widget.dart';
import '../../../../data/model/queue/queue_item_model.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(uploadQueueServiceProvider);
    final items = queue.items;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBarWidget(title: "Navbat", canPop: true),
      body: items.isEmpty
          ? Center(
              child: Text(
                "Navbat bo'sh",
                style: AppTypography.body(context)
                    .copyWith(color: colors.textSecondary),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = items[index];
                return _QueueItemCard(
                  item: item,
                  onRetry: () => _retry(context, queue, item),
                  onDelete: () => _confirmDelete(context, queue, item),
                  onOpen: item.status == QueueItemStatus.done &&
                          item.plantationId != null
                      ? () => context.push(
                            "${AppRouteNames.home}${AppRouteNames.plantationView}",
                            extra: item.plantationId,
                          )
                      : null,
                );
              },
            ),
    );
  }

  Future<void> _retry(
    BuildContext context,
    UploadQueueService queue,
    QueueItem item,
  ) async {
    await queue.retryNow(item.id);
    if (context.mounted) {
      Utils.fireTopSnackBar(
        "Qayta yuborish boshlandi",
        design_colors.AppColors.accentGreen,
        context,
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UploadQueueService queue,
    QueueItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirish"),
        content: const Text(
            "Bu yozuv navbatdan butunlay o'chiriladi, ma'lumotlar qayta tiklanmaydi. Davom etasizmi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Bekor qilish"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("O'chirish",
                style: TextStyle(color: design_colors.AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await queue.deleteItem(item.id);
      if (context.mounted) {
        Utils.fireTopSnackBar(
          "O'chirildi",
          design_colors.AppColors.error,
          context,
        );
      }
    }
  }
}

class _QueueItemCard extends StatelessWidget {
  final QueueItem item;
  final VoidCallback onRetry;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;

  const _QueueItemCard({
    required this.item,
    required this.onRetry,
    required this.onDelete,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // После успешной отправки id уже известен (для create — только
    // после ответа сервера) — показываем его вместо статичного лейбла.
    final label = item.plantationId != null
        ? "Plantatsiya #${item.plantationId}"
        : item.displayLabel ?? "Yangi plantatsiya";
    final dateStr =
        DateFormat('dd.MM.yyyy HH:mm').format(item.collectedAt.toLocal());

    final card = Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: colors.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              _StatusChip(status: item.status),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            dateStr,
            style: AppTypography.caption(context)
                .copyWith(color: colors.textSecondary),
          ),
          if (item.images.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              "${item.images.length} ta rasm",
              style: AppTypography.caption(context)
                  .copyWith(color: colors.textSecondary),
            ),
          ],
          if (item.status == QueueItemStatus.failed &&
              item.lastError != null) ...[
            SizedBox(height: 6.h),
            Text(
              item.lastError!,
              style: AppTypography.caption(context)
                  .copyWith(color: design_colors.AppColors.error),
            ),
          ],
          if (item.status == QueueItemStatus.failed) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                TextButton(
                  onPressed: onRetry,
                  child: const Text("Qayta yuborish"),
                ),
                TextButton(
                  onPressed: onDelete,
                  child: Text("O'chirish",
                      style: TextStyle(color: design_colors.AppColors.error)),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (onOpen == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onOpen,
        child: card,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final QueueItemStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      QueueItemStatus.queued => ("Navbatda", design_colors.AppColors.warning),
      QueueItemStatus.uploading => (
          "Yuborilmoqda",
          design_colors.AppColors.accentGreen
        ),
      QueueItemStatus.failed => ("Xatolik", design_colors.AppColors.error),
      QueueItemStatus.done => (
          "Yuborildi",
          design_colors.AppColors.accentGreen
        ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label,
        style: AppTypography.caption(context).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
