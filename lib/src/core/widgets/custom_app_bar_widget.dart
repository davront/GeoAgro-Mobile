import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../../../design_system/tokens/typography.dart';

/// Modern app bar that adapts to light/dark theme.
class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool canPop;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const CustomAppBarWidget({
    super.key,
    required this.title,
    required this.canPop,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppBar(
      toolbarHeight: 68.h,
      centerTitle: true,
      backgroundColor: colors.background,
      elevation: 0,
      leading: canPop
          ? IconButton(
              onPressed: onBackPressed ?? () => context.pop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colors.textPrimary,
                size: 18.sp,
              ),
            )
          : null,
      title: Text(
        title,
        style: AppTypography.headline3(context).copyWith(
          color: colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      scrolledUnderElevation: 0,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: colors.isDark
              ? colors.border
              : colors.border.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  // preferredSize резервирует место под AppBar в Scaffold layout — раньше
  // была захардкожена в 69 (const), не масштабируясь вместе с
  // toolbarHeight: 68.h. На широком экране (планшет, scale > 1)
  // реальная высота тулбара превышала зарезервированное пространство,
  // из-за чего содержимое AppBar (заголовок, кнопки в actions вроде
  // "Chiqish" на странице профиля) визуально сжималось/обрезалось —
  // AppBar был самым используемым виджетом в проекте, баг проявлялся
  // почти на каждом экране.
  @override
  Size get preferredSize => Size.fromHeight(68.h + 0.5);
}
