import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/motion.dart';
import '../../../design_system/tokens/colors.dart' as design_colors;
import '../../../design_system/tokens/radii.dart';
import '../../../design_system/tokens/typography.dart';

/// Modern primary button - matches login page style
class MainButton extends StatefulWidget {
  final String text;
  final bool? isLoading;
  final VoidCallback onTap;
  final bool isEnabled;

  const MainButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading,
    this.isEnabled = true,
  });

  @override
  State<MainButton> createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled && widget.isLoading != true) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDisabled = !widget.isEnabled || widget.isLoading == true;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 16),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: isDisabled ? null : widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: Curves.easeInOut,
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        design_colors.AppColors.accentGreen,
                        design_colors.AppColors.accentGreenDark,
                      ],
                    ),
              color: isDisabled ? context.colors.surfaceVariant : null,
              borderRadius: BorderRadius.circular(AppRadii.button),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: design_colors.AppColors.accentGreen
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading == true
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDisabled
                              ? context.colors.textSecondary
                              : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      widget.text,
                      style: AppTypography.body(context).copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: isDisabled
                            ? context.colors.textSecondary
                            : Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button variant
class MainButton2 extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool enableFeedback;

  const MainButton2({
    super.key,
    required this.enableFeedback,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDisabled = onPressed == null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          enableFeedback: enableFeedback,
          borderRadius: BorderRadius.circular(AppRadii.button),
          child: Container(
            height: 52.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDisabled
                  ? context.colors.surface
                  : design_colors.AppColors.accentGreen,
              borderRadius: BorderRadius.circular(AppRadii.button),
              border: Border.all(
                color: isDisabled
                    ? context.colors.border
                    : design_colors.AppColors.accentGreen,
                width: 1.5,
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
