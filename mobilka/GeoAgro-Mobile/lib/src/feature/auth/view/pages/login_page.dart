import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/motion.dart';

import '../../vm/login_vm.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/tools/assets.dart';
import '../../../../core/setting/setup.dart' as app_setup;
import '../../../../core/services/pin_service.dart';
import '../../../home/view/pages/home_page.dart' show homePageVM;
import '../../../fermers/view/pages/fermers_page.dart' show fermerPageVM;
import '../../../home/view/pages/natification_page.dart' show notificationsVM;
import '../widgets/modern_login_input_widget.dart';
import '../widgets/modern_login_button.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../../design_system/tokens/colors.dart' as design_colors;
import '../../../../../design_system/tokens/spacing.dart';
import '../../../../../design_system/tokens/typography.dart';

final loginPageVM = ChangeNotifierProvider<LoginVm>((ref) {
  return LoginVm();
});

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late FocusNode _usernameFocus;
  late FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _usernameFocus = FocusNode();
    _passwordFocus = FocusNode();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: AppMotion.entrance,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _openTelegramBot() async {
    final telegramUrls = [
      'tg://resolve?domain=geoagro_bot',
      'https://t.me/geoagro_bot',
      'intent://t.me/geoagro_bot#Intent;scheme=tg;package=org.telegram.messenger;end',
      'intent://t.me/geoagro_bot#Intent;scheme=tg;package=org.telegram.plus;end',
    ];

    bool success = false;

    for (final url in telegramUrls) {
      try {
        final uri = Uri.parse(url);
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
        continue;
      }
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Telegram botni ochishda xatolik yuz berdi"),
          backgroundColor: design_colors.AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    LoginVm vm = ref.watch(loginPageVM);
    final loginVmNotifier = ref.read(loginPageVM.notifier);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.background,
                    context.colors.surface,
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.xxl,
                        ),
                        child: Form(
                          key: vm.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 20.h),
                              _buildLogoSection(),
                              SizedBox(height: 48.h),
                              _buildTitleSection(),
                              SizedBox(height: 48.h),
                              _buildFormFields(vm, loginVmNotifier),
                              SizedBox(height: 32.h),
                              _buildLoginButton(vm, loginVmNotifier),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildHelpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              Assets.gerbImg,
              semanticLabel: "GeoAgro gerbi",
              height: 120.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          "Qishloq xo'jaligi vazirligi\nhuzuridagi",
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall(context).copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: context.colors.textSecondary,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Agrosanoatni rivojlantirish agentligi",
          textAlign: TextAlign.center,
          style: AppTypography.title(context).copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Tizimga Kirish",
          textAlign: TextAlign.center,
          style: AppTypography.headline2(context).copyWith(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Davom etish uchun ma'lumotlaringizni kiriting",
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall(context).copyWith(
            fontSize: 15.sp,
            color: context.colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(LoginVm vm, LoginVm loginVmNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModernLoginInputWidget(
          label: "Foydalanuvchi nomi",
          hintText: "Username",
          controller: vm.userNameC,
          focusNode: _usernameFocus,
          textInputAction: TextInputAction.next,
          onSubmitted: () {
            _usernameFocus.unfocus();
            FocusScope.of(context).requestFocus(_passwordFocus);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Foydalanuvchi nomi kiritilishi shart";
            }
            return null;
          },
        ),
        SizedBox(height: 24.h),
        ModernLoginInputWidget(
          label: "Parol",
          hintText: "Password",
          controller: vm.passwordC,
          focusNode: _passwordFocus,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: () {
            _passwordFocus.unfocus();
            _handleLogin(vm, loginVmNotifier);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Parol kiritilishi shart";
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Единая точка входа для сабмита логина — вызывается и с Enter на
  /// клавиатуре, и с кнопки "Kirish". Раньше onSubmitted поля пароля
  /// звал только login() без обработки результата — юзер вводил
  /// правильный пароль, вход реально проходил, но экран оставался на
  /// логине без навигации, пока юзер не жал кнопку второй раз.
  Future<void> _handleLogin(LoginVm vm, LoginVm loginVmNotifier) async {
    if (vm.isLoading) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!vm.formKey.currentState!.validate()) {
      Utils.fireTopSnackBar(
        "Iltimos, ma'lumotlarni to'g'ri kiriting.",
        design_colors.AppColors.error,
        context,
      );
      return;
    }
    final isSuccess = await loginVmNotifier.login();
    if (!mounted) return;
    if (isSuccess) {
      Utils.fireTopSnackBar(
        "Muvoffaqiyatli Tizimga Kirildi",
        design_colors.AppColors.success,
        context,
      );
      // Даём snackbar отобразиться перед навигацией
      await Future.delayed(AppMotion.normal);
      if (!mounted || !context.mounted) return;
      // Проверяем, установлен ли PIN
      final hasPinSet = await PinService.instance.isPinSet();
      if (!mounted || !context.mounted) return;
      if (hasPinSet) {
        // PIN уже есть — идём домой
        app_setup.appPinSet = true;
        final authMethod = await PinService.instance.getAuthMethod();
        if (!mounted || !context.mounted) return;
        app_setup.authMethod = authMethod;
        ref.invalidate(homePageVM);
        ref.invalidate(fermerPageVM);
        ref.invalidate(notificationsVM);
        context.go(AppRouteNames.home);
      } else {
        // PIN не установлен — обязательная установка
        context.go(AppRouteNames.pinSetup);
      }
    } else {
      Utils.fireTopSnackBar(
        vm.errorMessage ?? "Xatolik yuz berdi",
        design_colors.AppColors.error,
        context,
      );
    }
  }

  Widget _buildLoginButton(LoginVm vm, LoginVm loginVmNotifier) {
    return ModernLoginButton(
      text: "Kirish",
      isLoading: vm.isLoading,
      isEnabled: !vm.isLoading,
      onPressed: () => _handleLogin(vm, loginVmNotifier),
    );
  }

  Widget _buildHelpButton() {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openTelegramBot,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 22.sp,
                  color: design_colors.AppColors.accentGreen,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
