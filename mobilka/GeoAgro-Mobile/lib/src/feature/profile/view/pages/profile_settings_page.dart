import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/radii.dart';
import 'package:agro_employee_public/design_system/tokens/spacing.dart';
import 'package:agro_employee_public/design_system/tokens/typography.dart';
import 'package:agro_employee_public/design_system/utils/responsive.dart';
import 'package:agro_employee_public/src/core/routes/app_route_names.dart';
import 'package:agro_employee_public/src/core/storage/app_storage.dart';
import 'package:agro_employee_public/src/core/widgets/custom_app_bar_widget.dart';
import 'package:agro_employee_public/src/core/services/permissions_service.dart';
import 'package:agro_employee_public/src/data/model/user/user_info_model.dart';
import 'package:agro_employee_public/src/data/repository/app_repository_impl.dart';
import 'package:agro_employee_public/src/core/widgets/app_material_context.dart'
    show themeProvider;
import 'package:agro_employee_public/src/core/services/fcm_service.dart';
import 'package:agro_employee_public/src/core/services/pin_service.dart';
import 'package:agro_employee_public/src/core/setting/setup.dart' as app_setup;
import 'package:agro_employee_public/src/feature/fermers/view/pages/fermers_page.dart'
    show fermerPageVM;
import 'package:agro_employee_public/src/feature/home/view/pages/home_page.dart'
    show homePageVM;
import 'package:agro_employee_public/src/feature/home/view/pages/natification_page.dart'
    show notificationsVM;

class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() =>
      _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  UserInfoModel? _userInfo;
  bool _isLoading = true;

  bool _cameraPermission = false;
  bool _galleryPermission = false;
  bool _locationPermission = false;
  bool _notificationPermission = false;
  bool _isLoadingPermissions = false;

  final _permissionsService = PermissionsService();
  final _repository = AppRepositoryImpl();
  bool _hasLoaded = false;

  static const _telegramBotUri = 'https://t.me/geoagro_bot';

  static const Map<int, String> _regionNames = {
    1: 'Toshkent',
    2: 'Andijon',
    3: 'Buxoro',
    4: 'Farg\u02BBona',
    5: 'Jizzax',
    6: 'Qashqadaryo',
    7: 'Navoiy',
    8: 'Namangan',
    9: 'Samarqand',
    10: 'Sirdaryo',
    11: 'Surxondaryo',
    12: 'Qoraqalpog\u02BBiston',
    13: 'Xorazm',
  };

  @override
  void initState() {
    super.initState();
  }

  void _ensureDataLoaded() {
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadUserInfo();
      _loadPermissionsStatus();
    }
  }

  Future<void> _loadPermissionsStatus() async {
    setState(() => _isLoadingPermissions = true);
    try {
      final statuses = await _permissionsService.getAllPermissionsStatus();
      setState(() {
        _cameraPermission = statuses['camera'] ?? false;
        _galleryPermission = statuses['gallery'] ?? false;
        _locationPermission = statuses['location'] ?? false;
        _notificationPermission = statuses['notifications'] ?? false;
        _isLoadingPermissions = false;
      });
    } catch (e) {
      setState(() => _isLoadingPermissions = false);
    }
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    try {
      final response = await _repository.getUserInfo();
      if (!mounted) return;
      if (response != null) {
        final decoded = jsonDecode(response);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _userInfo = UserInfoModel.fromJson(decoded);
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _userInfo = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userInfo = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _openTelegramBot() async {
    final uriCandidates = [
      Uri.parse('tg://resolve?domain=geoagro_bot'),
      Uri.parse(_telegramBotUri),
    ];
    for (final uri in uriCandidates) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Telegram bot ochilmadi. Ilovani o'rnatib, @geoagro_bot manzilini kiriting.",
          style: AppTypography.caption(context).copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        backgroundColor: design_colors.AppColors.error,
      ),
    );
  }

  Future<void> _requestPermission({
    required bool currentStatus,
    required Future<bool> Function() requestFn,
    required void Function(bool) onResult,
    required String permissionName,
  }) async {
    if (currentStatus) return;
    final granted = await requestFn();
    if (!mounted) return;
    onResult(granted);
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$permissionName ruxsati berilmadi"),
          backgroundColor: design_colors.AppColors.error,
        ),
      );
    } else {
      await _loadPermissionsStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureDataLoaded();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBarWidget(
        title: "Profil",
        canPop: false,
        actions: [
          TextButton(
            onPressed: () async {
              await AppStorage.clearAllData();
              app_setup.accessToken = null;
              app_setup.userId = 0;
              app_setup.districtId = 1;
              app_setup.username = null;
              app_setup.appPinSet = false;
              app_setup.authMethod = AuthMethod.none;
              app_setup.biometricEnabled = false;
              try {
                await FcmService().deleteToken();
              } catch (_) {}
              // deleteToken() ждёт сеть — юзер может успеть уйти с экрана
              // (виджет unmount) за это время. ref становится небезопасным
              // после unmount, invalidate() до context.mounted-проверки
              // кидал "Bad state: Using ref when widget has been unmounted".
              if (!context.mounted) return;
              ref.invalidate(homePageVM);
              ref.invalidate(fermerPageVM);
              ref.invalidate(notificationsVM);
              context.go(AppRouteNames.login);
            },
            child: Text(
              "Chiqish",
              style: AppTypography.body(context).copyWith(
                color: design_colors.AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? RefreshIndicator(
              onRefresh: _loadUserInfo,
              color: design_colors.AppColors.accentGreen,
              backgroundColor: colors.surface,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: design_colors.AppColors.accentGreen,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserInfo,
              color: design_colors.AppColors.accentGreen,
              backgroundColor: colors.surface,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.getMaxContentWidth(context),
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(colors),
                        SizedBox(height: AppSpacing.xl.h),
                        _buildSectionTitle("Shaxsiy ma'lumotlar", colors),
                        SizedBox(height: AppSpacing.sm.h),
                        _buildPersonalInfoCard(colors),
                        SizedBox(height: AppSpacing.xl.h),
                        _buildSectionTitle("Mavzu", colors),
                        SizedBox(height: AppSpacing.sm.h),
                        _buildThemeCard(colors),
                        SizedBox(height: AppSpacing.xl.h),
                        _buildSectionTitle("Ruxsatlar", colors),
                        SizedBox(height: AppSpacing.sm.h),
                        _buildPermissionsCard(colors),
                        SizedBox(height: AppSpacing.xl.h),
                        _buildSectionTitle("Qurilmalar", colors),
                        SizedBox(height: AppSpacing.sm.h),
                        _buildDevicesCard(colors),
                        SizedBox(height: AppSpacing.xl.h),
                        _buildSectionTitle("Qo'llab-quvvatlash", colors),
                        SizedBox(height: AppSpacing.sm.h),
                        _buildSupportCard(colors),
                        SizedBox(height: AppSpacing.xl.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // THEME TOGGLE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildThemeCard(AdaptiveColors colors) {
    final themeNotifier = ref.watch(themeProvider);
    final currentMode = themeNotifier.themeMode;

    return _buildCard(
      colors,
      child: Column(
        children: [
          _buildThemeOption(
            colors: colors,
            icon: Icons.dark_mode_outlined,
            title: "Tungi",
            isSelected: currentMode == ThemeMode.dark,
            onTap: () =>
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
          _buildDivider(colors),
          _buildThemeOption(
            colors: colors,
            icon: Icons.light_mode_outlined,
            title: "Kunduzgi",
            isSelected: currentMode == ThemeMode.light,
            onTap: () =>
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          _buildDivider(colors),
          _buildThemeOption(
            colors: colors,
            icon: Icons.settings_brightness_outlined,
            title: "Tizim",
            isSelected: currentMode == ThemeMode.system,
            onTap: () =>
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required AdaptiveColors colors,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected
                  ? design_colors.AppColors.accentGreen
                  : colors.textSecondary,
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Text(
                title,
                style: AppTypography.body(context).copyWith(
                  color: colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: design_colors.AppColors.accentGreen,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PROFILE HEADER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildProfileHeader(AdaptiveColors colors) {
    if (_userInfo == null) {
      return _buildCard(
        colors,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48.sp,
                  color: colors.textSecondary,
                ),
                SizedBox(height: AppSpacing.md.h),
                Text(
                  "Ma'lumot topilmadi",
                  style: AppTypography.title(context).copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  "Profil ma'lumotlari yuklanmadi. Qayta urinib ko'ring.",
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(context).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final initials = _initialsFromName(_userInfo!.displayName);
    return _buildCard(
      colors,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    design_colors.AppColors.accentGreen,
                    design_colors.AppColors.accentGreenDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: design_colors.AppColors.accentGreen
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.lg.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userInfo!.displayName.isNotEmpty
                        ? _userInfo!.displayName
                        : _userInfo!.username,
                    style: AppTypography.title(context).copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_userInfo!.districtName.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      _userInfo!.districtName,
                      style: AppTypography.caption(context).copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  if (_userInfo!.phoneNumber.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      _userInfo!.phoneNumber,
                      style: AppTypography.body(context).copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PERSONAL INFO
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildPersonalInfoCard(AdaptiveColors colors) {
    final rows = [
      (
        Icons.person_outline,
        "F.I.Sh",
        _userInfo?.displayName ?? "Ko'rsatilmagan"
      ),
      (
        Icons.place_outlined,
        "Viloyat",
        _userInfo != null
            ? (_regionNames[_userInfo!.regionId] ?? "Ko'rsatilmagan")
            : "Ko'rsatilmagan"
      ),
      (
        Icons.map_outlined,
        "Tuman",
        _userInfo?.districtName ?? "Ko'rsatilmagan"
      ),
      (
        Icons.phone_outlined,
        "Telefon",
        _userInfo?.phoneNumber ?? "Ko'rsatilmagan"
      ),
    ];

    // На телефоне — привычный вертикальный список строк. На планшете
    // те же строки в один столбец растягивались на всю ширину почти
    // без текста внутри — сетка 2×2 использует простор и сокращает
    // высоту карточки вдвое.
    if (Responsive.isCompact(context)) {
      return _buildCard(
        colors,
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) _buildDivider(colors),
              _buildInfoRow(colors, rows[i].$1, rows[i].$2, rows[i].$3),
            ],
          ],
        ),
      );
    }

    return _buildCard(
      colors,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 4,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.md,
        children: [
          for (final row in rows) _buildInfoRow(colors, row.$1, row.$2, row.$3),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PERMISSIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildPermissionsCard(AdaptiveColors colors) {
    return _buildCard(
      colors,
      child: Column(
        children: [
          _buildPermissionRow(
            colors: colors,
            icon: Icons.camera_alt_outlined,
            title: "Kamera",
            isEnabled: _cameraPermission,
            onTap: () => _requestPermission(
              currentStatus: _cameraPermission,
              requestFn: _permissionsService.requestCameraPermission,
              onResult: (v) => setState(() => _cameraPermission = v),
              permissionName: "Kamera",
            ),
          ),
          _buildDivider(colors),
          _buildPermissionRow(
            colors: colors,
            icon: Icons.photo_library_outlined,
            title: "Galereya",
            isEnabled: _galleryPermission,
            onTap: () => _requestPermission(
              currentStatus: _galleryPermission,
              requestFn: _permissionsService.requestGalleryPermission,
              onResult: (v) => setState(() => _galleryPermission = v),
              permissionName: "Galereya",
            ),
          ),
          _buildDivider(colors),
          _buildPermissionRow(
            colors: colors,
            icon: Icons.location_on_outlined,
            title: "Geolokatsiya",
            isEnabled: _locationPermission,
            onTap: () => _requestPermission(
              currentStatus: _locationPermission,
              requestFn: _permissionsService.requestLocationPermission,
              onResult: (v) => setState(() => _locationPermission = v),
              permissionName: "Geolokatsiya",
            ),
          ),
          _buildDivider(colors),
          _buildPermissionRow(
            colors: colors,
            icon: Icons.notifications_outlined,
            title: "Bildirishnomalar",
            isEnabled: _notificationPermission,
            onTap: () => _requestPermission(
              currentStatus: _notificationPermission,
              requestFn: _permissionsService.requestNotificationPermission,
              onResult: (v) => setState(() => _notificationPermission = v),
              permissionName: "Bildirishnomalar",
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DEVICES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildDevicesCard(AdaptiveColors colors) {
    return _buildCard(
      colors,
      onTap: () => context.push('/${AppRouteNames.devices}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              Icons.devices_other_outlined,
              color: design_colors.AppColors.accentGreen,
              size: 24.sp,
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ulangan qurilmalar",
                    style: AppTypography.body(context).copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Akkauntga kirgan qurilmalarni ko'rish va o'chirish",
                    style: AppTypography.caption(context).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SUPPORT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSupportCard(AdaptiveColors colors) {
    return _buildCard(
      colors,
      onTap: _openTelegramBot,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              Icons.support_agent_outlined,
              color: design_colors.AppColors.accentGreen,
              size: 24.sp,
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Telegram bot",
                    style: AppTypography.body(context).copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Taklif va shikoyatlar uchun @geoagro_bot",
                    style: AppTypography.caption(context).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.north_east,
              color: colors.textSecondary,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // REUSABLE BUILDERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSectionTitle(String title, AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption(context).copyWith(
          color: colors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  Widget _buildCard(AdaptiveColors colors,
      {required Widget child, VoidCallback? onTap}) {
    final container = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: colors.cardBorder,
        boxShadow: colors.cardShadow,
      ),
      child: child,
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: container,
        ),
      );
    }
    return container;
  }

  Widget _buildDivider(AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 52.0),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: colors.cardDivider,
      ),
    );
  }

  Widget _buildInfoRow(
      AdaptiveColors colors, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: design_colors.AppColors.accentGreen),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTypography.caption(context).copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.body(context).copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow({
    required AdaptiveColors colors,
    required IconData icon,
    required String title,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: design_colors.AppColors.accentGreen),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Text(
                title,
                style: AppTypography.body(context).copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (_isLoadingPermissions)
              SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: design_colors.AppColors.accentGreen,
                ),
              )
            else
              Icon(
                isEnabled ? Icons.check_circle : Icons.circle_outlined,
                color: isEnabled
                    ? design_colors.AppColors.accentGreen
                    : colors.textSecondary,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  String _initialsFromName(String name) {
    if (name.trim().isEmpty) return "UZ";
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
