import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/routes/app_route_names.dart';
import '../../../../core/setting/setup.dart';
import '../../../../core/utils/date_utils.dart' as app_date;
import '../../../../core/widgets/custom_card_widget.dart';
import '../../../../data/model/plantation/plantations_list_model.dart';
import '../../../../../design_system/tokens/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../../../design_system/tokens/radii.dart';
import '../../../../../design_system/tokens/spacing.dart';
import '../../../../../design_system/tokens/typography.dart';
import '../../vm/home_page_vm.dart';
import '../pages/home_page.dart';
import 'delete_confirmation_dialog.dart';

class HomePageCardWidget extends StatelessWidget {
  final Result plantation;
  final bool showEditButton;
  final ChangeNotifierProvider<HomePageVm>? customProvider;
  final VoidCallback? onDeleteSuccess; // Callback for successful deletion

  const HomePageCardWidget({
    super.key,
    required this.plantation,
    this.showEditButton = false,
    this.customProvider, // Optional custom provider
    this.onDeleteSuccess, // Optional callback
  });

  // void onDeleteButtonTap(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: AppColors.white,
  //         title: Icon(Icons.info_sharp, color: AppColors.accentGreen, size: 20.sp),
  //         content: Text(
  //           "Haqiqatdan o'chirib tashlamoqchimisiz",
  //           style: TextStyle(color: AppColors.c1E1E1E70, fontSize: 14.sp),
  //           textAlign: TextAlign.center,
  //         ),
  //         actionsAlignment: MainAxisAlignment.spaceEvenly,
  //         actions: [
  //           MaterialButton(
  //             minWidth: MediaQuery.of(context).size.width * 0.3,
  //             onPressed: () async {
  //               final result =
  //                   await vm.deletePlantation(id: plantation.id ?? 0);
  //               if (result && context.mounted) {
  //                 Utils.fireTopSnackBar(
  //                     vm.deletMessage ??
  //                         "Malumotlar o'chirish uchun yuborildi.",
  //                     AppColors.accentGreen,
  //                     context);
  //                 context.pop();
  //               } else {
  //                 if (context.mounted) {
  //                   Utils.fireTopSnackBar(
  //                       vm.deletMessage ?? "Xatolik yuz berdi",
  //                       AppColors.error,
  //                       context);
  //                   context.pop();
  //                 }
  //               }
  //             },
  //             color: AppColors.accentGreen,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8.r)),
  //             elevation: 0,
  //             highlightElevation: 0,
  //             child: Text(
  //               "Ha",
  //               style: TextStyle(color: AppColors.white, fontSize: 16.sp),
  //             ),
  //           ),
  //           MaterialButton(
  //             minWidth: MediaQuery.of(context).size.width * 0.3,
  //             onPressed: () {
  //               context.pop();
  //             },
  //             color: AppColors.error,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8.r)),
  //             elevation: 0,
  //             highlightElevation: 0,
  //             child: Text(
  //               "Yoq",
  //               style: TextStyle(color: AppColors.white, fontSize: 16.sp),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // Determine if current user is creator
    final matchesById =
        plantation.createdById != null && userId == plantation.createdById;
    final matchesByUsername = plantation.createdByUsername != null &&
        username != null &&
        plantation.createdByUsername == username;
    final isChecked = plantation.isChecked ?? false;
    final canEdit =
        showEditButton && (matchesById || matchesByUsername) && !isChecked;
    // return InkWell(
    //   onTap: onPressed,
    //   child: CustomCardWidget(
    final farmerName = plantation.farmerName ?? "Noma'lum fermer";
    final farmerInn = plantation.farmerInn?.toString();
    final plantationId = plantation.id?.toString() ?? "N/A";
    final areaText = "${_formatNumber(plantation.totalArea)} ga";
    final chegaraAreaText =
        (plantation.chegaraArea != null && plantation.chegaraArea! > 0)
            ? "${plantation.chegaraArea!.toStringAsFixed(2)} ga"
            : null;
    final createdAt = plantation.createdAt != null
        ? _formatCreatedAt(plantation.createdAt!)
        : null;

    return CustomCardWidget(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.lg,
      variant: CardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmerName,
                      style: AppTypography.title(context).copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (farmerInn != null) ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        "ИНН: $farmerInn",
                        style: AppTypography.bodySmall(context).copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                    SizedBox(height: AppSpacing.xs),
                    if (createdAt != null)
                      Text(
                        "Qo'shilgan: $createdAt",
                        style: AppTypography.bodySmall(context).copyWith(
                          color: context.colors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _idBadge(context: context, id: plantationId),
                  SizedBox(height: AppSpacing.xs),
                  _statusBadge(context: context, plantation: plantation),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _infoChip(
                context: context,
                icon: Icons.square_foot_outlined,
                label: "Maydon",
                value: areaText,
              ),
              if (chegaraAreaText != null)
                _infoChip(
                  context: context,
                  icon: Icons.border_color_outlined,
                  label: "Chegara maydon",
                  value: chegaraAreaText,
                ),
            ],
          ),
          if ((plantation.moderationComments?.isNotEmpty ?? false)) ...[
            SizedBox(height: AppSpacing.lg),
            _moderationNote(
              context: context,
              messages: plantation.moderationComments!
                  .map((comment) => comment.text ?? '')
                  .where((text) => text.isNotEmpty)
                  .toList(),
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: plantation.id == null
                      ? null
                      : () => context.go(
                            "${AppRouteNames.home}${AppRouteNames.plantationView}",
                            extra: plantation.id,
                          ),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: const Text("Ko'rish"),
                ),
              ),
              if (canEdit) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (plantation.id != null) {
                        context.go(
                          "${AppRouteNames.home}${AppRouteNames.editPage}",
                          extra: plantation.id,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: design_colors.AppColors.accentGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Tahrirlash"),
                  ),
                ),
                // Показываем кнопку удаления только для неподтвержденных плантаций
                if (!isChecked) ...[
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: plantation.id == null
                          ? null
                          : () => _handleDelete(
                                context,
                                plantation.id!,
                                plantation.isChecked ?? false,
                              ),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: design_colors.AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("O'chirish"),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _idBadge({required BuildContext context, required String id}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.isDark
            ? context.colors.surfaceElevated
            : context.colors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: context.colors.isDark
            ? Border.all(color: context.colors.border)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "ID",
            style: AppTypography.caption(context).copyWith(
              color: context.colors.textTertiary,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            id,
            style: AppTypography.bodySmall(context).copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(
      {required BuildContext context, required Result plantation}) {
    Color statusColor;

    // Проверяем сначала isRejected, потом isChecked
    if (plantation.isRejected == true) {
      statusColor = design_colors.AppColors.error;
    } else if (plantation.isChecked == true) {
      statusColor = design_colors.AppColors.success;
    } else {
      statusColor = design_colors.AppColors.warning;
    }

    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.border,
          width: 1,
        ),
      ),
    );
  }

  Widget _infoChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.isDark
            ? context.colors.surfaceElevated
            : context.colors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: context.colors.isDark
            ? Border.all(color: context.colors.border)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: design_colors.AppColors.accentGreen,
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.caption(context).copyWith(
                  color: context.colors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: AppSpacing.xs / 2),
              Text(
                value,
                style: AppTypography.bodySmall(context).copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moderationNote({
    required BuildContext context,
    required List<String> messages,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: design_colors.AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: design_colors.AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18.sp,
            color: design_colors.AppColors.warning,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tafsilot",
                  style: AppTypography.bodySmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                ...messages.map((message) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• ",
                          style: AppTypography.bodySmall(context).copyWith(
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            message,
                            style: AppTypography.bodySmall(context).copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt(String raw) {
    try {
      final dt = DateTime.parse(raw);
      if (raw.contains('+05:00')) {
        final localTime = dt.add(const Duration(hours: 5));
        return app_date.DateUtils.formatDateTime(localTime);
      } else if (raw.contains('+')) {
        final timezoneMatch = RegExp(r'\+(\d{2}):(\d{2})').firstMatch(raw);
        if (timezoneMatch != null) {
          final hours = int.parse(timezoneMatch.group(1)!);
          final minutes = int.parse(timezoneMatch.group(2)!);
          final offset = Duration(hours: hours, minutes: minutes);
          final localTime = dt.add(offset);
          return app_date.DateUtils.formatDateTime(localTime);
        }
      }
      return app_date.DateUtils.formatDateTime(dt);
    } catch (_) {
      return raw;
    }
  }

  // Вспомогательная функция для форматирования чисел без .0
  String _formatNumber(dynamic value) {
    if (value == null) return "0.00";
    if (value is double) {
      return value.toStringAsFixed(2);
    }
    if (value is int) {
      return value.toDouble().toStringAsFixed(2);
    }
    // Попытка преобразовать в число
    try {
      final numValue = double.parse(value.toString());
      return numValue.toStringAsFixed(2);
    } catch (e) {
      return value.toString();
    }
  }

  void _handleDelete(BuildContext context, int plantationId, bool isChecked) {
    if (isChecked) {
      // Подтверждённую плантацию удалить нельзя — модальное окно
      _showCannotDeleteDialog(context);
      return;
    }

    // Не подтверждённая — показываем диалог с комментарием
    _showDeleteWithReasonDialog(context, plantationId);
  }

  /// Модальное окно: удалить нельзя (is_checked == true)
  void _showCannotDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.block, size: 48),
        iconColor: Theme.of(context).colorScheme.error,
        title: const Text("O'chirib bo'lmaydi"),
        content: const Text(
          "Tasdiqlangan plantatsiyani o'chirib bo'lmaydi. "
          "Iltimos, administrator bilan bog'laning.",
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Tushunarli"),
          ),
        ],
      ),
    );
  }

  /// Диалог удаления с комментарием (is_checked == false)
  void _showDeleteWithReasonDialog(BuildContext context, int plantationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return DeleteConfirmationDialog(
          onConfirm: (reason) async {
            Navigator.of(dialogContext).pop();
            if (!context.mounted) return;
            _deletePlantationWithReason(context, plantationId, reason);
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  Future<void> _deletePlantationWithReason(
    BuildContext context,
    int plantationId,
    String reason,
  ) async {
    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Сохраняем Navigator до async-вызова, чтобы гарантированно закрыть диалог
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final provider = customProvider ?? homePageVM;
      final container = ProviderScope.containerOf(context);
      final vm = container.read(provider.notifier);

      final result = await vm.deletePlantationPermanently(
        id: plantationId,
        reason: reason,
      );

      navigator.pop(); // Закрываем индикатор загрузки

      if (result) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                vm.deletMessage ?? "O'chirish so'rovi moderatsiyaga yuborildi"),
            backgroundColor: design_colors.AppColors.accentGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        onDeleteSuccess?.call();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(vm.deletMessage ?? "O'chirishda xatolik yuz berdi"),
            backgroundColor: design_colors.AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      try {
        navigator.pop(); // Закрываем индикатор загрузки
      } catch (_) {
        // Навигатор мог быть уже удалён
      }
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Kutilmagan xatolik: ${e.toString()}"),
            backgroundColor: design_colors.AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
