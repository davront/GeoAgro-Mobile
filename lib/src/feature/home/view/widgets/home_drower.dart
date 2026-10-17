import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agro_employee_public/src/core/routes/app_route_names.dart';
import 'package:agro_employee_public/src/core/setting/setup.dart';
import 'package:agro_employee_public/src/core/storage/app_storage.dart';
import 'package:agro_employee_public/src/core/version/version_check_service.dart';
import 'package:agro_employee_public/src/data/model/user/user_info_model.dart';
import 'package:agro_employee_public/src/data/repository/app_repository_impl.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/radii.dart';
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';

class HomeDrawer extends ConsumerStatefulWidget {
  const HomeDrawer({super.key});

  @override
  ConsumerState<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends ConsumerState<HomeDrawer> {
  UserInfoModel? userInfo;
  bool isLoading = true;
  String? currentAppVersion;
  final AppRepositoryImpl _appRepositoryImpl = AppRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final version = await VersionCheckService.getCurrentVersionForDisplay();
    if (!mounted) return;
    setState(() {
      currentAppVersion = version;
    });
  }

  Future<void> _loadUserInfo() async {
    try {
      final data = await _appRepositoryImpl.getUserInfo();
      // Виджет (drawer) может быть закрыт/unmounted, пока await ещё
      // в полёте — setState() на unmounted State кидает null check
      // на внутреннем _element, необрабатываемо снаружи.
      if (!mounted) return;
      if (data != null) {
        final jsonData = jsonDecode(data);
        setState(() {
          userInfo = UserInfoModel.fromJson(jsonData);
          isLoading = false;
        });
        // Проверка версии теперь в HomePage.initState() — срабатывает
        // сразу на главном экране, не только при открытии этой панели.
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.background,
      child: SafeArea(
        child: Column(
          children: [
            _ModernDrawerHeader(userInfo: userInfo, isLoading: isLoading),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                children: [
                  _DrawerActionButton(
                    icon: Icons.refresh,
                    label: "Qayta ko'rishga",
                    onTap: () => context.go(
                      "${AppRouteNames.home}${AppRouteNames.recheckPage}",
                    ),
                  ),
                  _DrawerActionButton(
                    icon: Icons.timelapse_outlined,
                    label: "Ko'rib chiqilmoqda",
                    onTap: () => context.go(
                      "${AppRouteNames.home}${AppRouteNames.pendingPage}",
                    ),
                  ),
                  _DrawerActionButton(
                    icon: Icons.verified_outlined,
                    label: "Tasdiqlangan",
                    onTap: () => context.go(
                      "${AppRouteNames.home}${AppRouteNames.approvedPage}",
                    ),
                  ),
                  _DrawerActionButton(
                    icon: Icons.analytics_outlined,
                    label: "Fermerlar statistikasi",
                    onTap: () => context.go(
                      "${AppRouteNames.home}${AppRouteNames.farmers}/${AppRouteNames.farmersStatistics}",
                    ),
                  ),
                  _DrawerActionButton(
                    icon: Icons.support_agent,
                    label: "Qo'llab-quvvatlash",
                    onTap: _openTelegramBot,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'geoAgro v${currentAppVersion ?? "3.0.1"}',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(context).copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  _DrawerActionButton(
                    icon: Icons.logout,
                    label: "Chiqish",
                    isAccent: true,
                    onTap: () async {
                      await AppStorage.clearAllData();
                      accessToken = null;
                      if (context.mounted) {
                        context.go(AppRouteNames.login);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTelegramBot() async {
    // Различные способы открытия Telegram бота для Android
    final telegramUrls = [
      'tg://resolve?domain=geoagro_bot', // Прямое открытие в Telegram приложении
      'https://t.me/geoagro_bot', // Веб-версия Telegram
      'intent://t.me/geoagro_bot#Intent;scheme=tg;package=org.telegram.messenger;end', // Android Intent для Telegram
      'intent://t.me/geoagro_bot#Intent;scheme=tg;package=org.telegram.plus;end', // Android Intent для Telegram Plus
    ];

    bool success = false;

    for (final url in telegramUrls) {
      try {
        final uri = Uri.parse(url);

        // Проверяем, можем ли мы открыть этот URL
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: false,
              enableDomStorage: false,
            ),
          );
          success = true;
          break;
        }
      } catch (e) {
        // Продолжаем пробовать следующий URL
        continue;
      }
    }

    // Если ни один способ не сработал, показываем ошибку
    if (!success) {
      _showTelegramError();
    }
  }

  void _showTelegramError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Telegram botiga kirishda xatolik yuz berdi'),
              SizedBox(height: 4),
              Text('Telegram ilovasini o\'rnating va qo\'lda kiriting:',
                  style: TextStyle(fontSize: 12)),
              SizedBox(height: 2),
              Text('@geoagro_bot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Kopiya qilish',
            textColor: Colors.white,
            onPressed: () {
              // Копируем имя бота в буфер обмена
              Clipboard.setData(ClipboardData(text: '@geoagro_bot'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('@geoagro_bot nusxa olindi!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      );
    }
  }
}

class _ModernDrawerHeader extends StatelessWidget {
  final UserInfoModel? userInfo;
  final bool isLoading;

  const _ModernDrawerHeader({
    required this.userInfo,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _userInitials(userInfo);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            design_colors.AppColors.accentGreen,
            design_colors.AppColors.accentGreenDark.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadii.xl),
          bottomRight: Radius.circular(AppRadii.xl),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.colors.background.withValues(alpha: 0.2),
            child: Text(
              initials,
              style: AppTypography.headline3(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading
                      ? "Ma'lumotlar yuklanmoqda..."
                      : (userInfo?.displayName.isNotEmpty == true
                          ? userInfo!.displayName
                          : "Foydalanuvchi"),
                  style: AppTypography.title(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                if ((userInfo?.districtName ?? "").isNotEmpty) ...[
                  Text(
                    userInfo!.districtName,
                    style: AppTypography.bodySmall(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                ],
                if ((userInfo?.phoneNumber ?? "").isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          userInfo!.phoneNumber,
                          style: AppTypography.bodySmall(context).copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _userInitials(UserInfoModel? info) {
    final source = info?.displayName.trim();
    if (source == null || source.isEmpty) {
      return "GA";
    }
    final parts = source.split(" ").where((e) => e.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    final first = parts.first.substring(0, 1).toUpperCase();
    final last = parts.last.substring(0, 1).toUpperCase();
    return "$first$last";
  }
}

class _DrawerActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isAccent;

  const _DrawerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isAccent
        ? design_colors.AppColors.accentGreen
        : context.colors.surfaceVariant;
    final foregroundColor =
        isAccent ? Colors.white : context.colors.textSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: Border.all(
              color: isAccent
                  ? design_colors.AppColors.accentGreenDark
                  : context.colors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: foregroundColor),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body(context).copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: foregroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
