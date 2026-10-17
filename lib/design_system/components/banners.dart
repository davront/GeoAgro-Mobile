import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';
import 'buttons.dart';

/// Design System Banner Components
/// 
/// Inline notifications for feedback:
/// - AppBanner - Base banner
/// - AppErrorBanner - Error message with retry
/// - AppWarningBanner - Warning message
/// - AppInfoBanner - Info message
/// - AppSuccessBanner - Success message

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASE BANNER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

enum AppBannerType {
  error,
  warning,
  info,
  success,
}

class AppBanner extends StatelessWidget {
  final AppBannerType type;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;
  final IconData? icon;

  const AppBanner({
    super.key,
    required this.type,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.margin,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getBannerConfig(type);

    return Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Icon(
            icon ?? config.icon,
            size: 24,
            color: config.iconColor,
          ),
          const SizedBox(width: AppSpacing.md),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: config.textColor,
                  ),
                ),
                
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppButtonText(
                    text: actionLabel!,
                    onPressed: onAction,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
          
          // Dismiss button
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 20,
                color: config.iconColor,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BannerConfig _getBannerConfig(AppBannerType type) {
    switch (type) {
      case AppBannerType.error:
        return _BannerConfig(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          borderColor: AppColors.error.withValues(alpha: 0.3),
          textColor: AppColors.errorDark,
          iconColor: AppColors.error,
          icon: Icons.error_outline,
        );
      case AppBannerType.warning:
        return _BannerConfig(
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          textColor: AppColors.warningDark,
          iconColor: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case AppBannerType.info:
        return _BannerConfig(
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          borderColor: AppColors.info.withValues(alpha: 0.3),
          textColor: AppColors.infoDark,
          iconColor: AppColors.info,
          icon: Icons.info_outline,
        );
      case AppBannerType.success:
        return _BannerConfig(
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          borderColor: AppColors.success.withValues(alpha: 0.3),
          textColor: AppColors.successDark,
          iconColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
    }
  }
}

class _BannerConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  _BannerConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SPECIALIZED BANNERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppErrorBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;

  const AppErrorBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onRetry,
    this.onDismiss,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppBanner(
      type: AppBannerType.error,
      message: message,
      actionLabel: actionLabel ?? (onRetry != null ? "Qayta urinish" : null),
      onAction: onRetry,
      onDismiss: onDismiss,
      margin: margin,
    );
  }
}

class AppWarningBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;

  const AppWarningBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppBanner(
      type: AppBannerType.warning,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
      margin: margin,
    );
  }
}

class AppInfoBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;

  const AppInfoBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppBanner(
      type: AppBannerType.info,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
      margin: margin,
    );
  }
}

class AppSuccessBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry? margin;

  const AppSuccessBanner({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppBanner(
      type: AppBannerType.success,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
      margin: margin,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SNACKBAR HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppBannerType type = AppBannerType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final config = _getSnackBarConfig(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: config.iconColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.white,
                onPressed: onAction,
              )
            : null,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: AppBannerType.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void success(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      type: AppBannerType.success,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      type: AppBannerType.warning,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      type: AppBannerType.info,
    );
  }

  static _SnackBarConfig _getSnackBarConfig(AppBannerType type) {
    switch (type) {
      case AppBannerType.error:
        return _SnackBarConfig(
          backgroundColor: AppColors.error,
          iconColor: AppColors.white,
          icon: Icons.error_outline,
        );
      case AppBannerType.warning:
        return _SnackBarConfig(
          backgroundColor: AppColors.warning,
          iconColor: AppColors.white,
          icon: Icons.warning_amber_outlined,
        );
      case AppBannerType.info:
        return _SnackBarConfig(
          backgroundColor: AppColors.info,
          iconColor: AppColors.white,
          icon: Icons.info_outline,
        );
      case AppBannerType.success:
        return _SnackBarConfig(
          backgroundColor: AppColors.success,
          iconColor: AppColors.white,
          icon: Icons.check_circle_outline,
        );
    }
  }
}

class _SnackBarConfig {
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;

  _SnackBarConfig({
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
  });
}

