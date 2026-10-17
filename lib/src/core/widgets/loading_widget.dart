import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/motion.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool isFullScreen;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const LoadingWidget({
    super.key,
    this.message,
    this.isFullScreen = false,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      color: backgroundColor ?? Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            SizedBox(
              width: 100.w,
              height: 100.h,
              child: Lottie.asset(
                'assets/lotties/search.json',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16.h),
            // Message
            if (message != null)
              Padding(
                padding: REdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: widget,
      );
    }

    return widget;
  }
}

// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          LoadingWidget(
            message: message,
            isFullScreen: true,
          ),
      ],
    );
  }
}

// Shimmer loading widget
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppMotion.shimmer,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Error widget
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: REdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: design_colors.AppColors.error,
            ),
            SizedBox(height: 16.h),
            // Error message
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            // Retry button
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: design_colors.AppColors.error,
                  foregroundColor: Colors.white,
                  padding: REdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  retryText ?? 'Қайта уриниш',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: REdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG Illustration
            SvgPicture.asset(
              'assets/svg/last_transaction.svg',
              width: 200.w,
              height: 200.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.textPrimary,
                  foregroundColor: Colors.white,
                  padding: REdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  actionText ?? 'Қўшиш',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
