import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/motion.dart';
import '../../../../../design_system/tokens/colors.dart' as design_colors;
import '../../../../../design_system/tokens/typography.dart';

/// Современный input widget с анимациями в стиле Apple
class ModernLoginInputWidget extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;

  const ModernLoginInputWidget({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  State<ModernLoginInputWidget> createState() => _ModernLoginInputWidgetState();
}

class _ModernLoginInputWidgetState extends State<ModernLoginInputWidget>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    final isFloatingLabel = _isFocused || hasText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label с анимацией
        AnimatedDefaultTextStyle(
          duration: AppMotion.fast,
          curve: Curves.easeInOut,
          style: TextStyle(
            fontSize: isFloatingLabel ? 12.sp : 14.sp,
            fontWeight: isFloatingLabel ? FontWeight.w600 : FontWeight.w500,
            color: _isFocused
                ? design_colors.AppColors.accentGreen
                : context.colors.textSecondary,
            letterSpacing: isFloatingLabel ? 0.5 : 0,
            height: 1.4,
          ),
          child: Text(widget.label),
        ),
        SizedBox(height: 8.h),
        // Input field с анимациями
        ScaleTransition(
          scale: _scaleAnimation,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText && _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            onFieldSubmitted: (_) {
              widget.onSubmitted?.call();
            },
            validator: widget.validator,
            style: AppTypography.body(context).copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
            cursorColor: design_colors.AppColors.accentGreen,
            inputFormatters: widget.keyboardType == TextInputType.emailAddress
                ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
                : null,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: context.colors.textTertiary,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              filled: true,
              fillColor: _isFocused
                  ? context.colors.surface
                  : context.colors.surfaceVariant,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _isFocused
                      ? design_colors.AppColors.accentGreen
                      : context.colors.border,
                  width: _isFocused ? 2.0 : 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: design_colors.AppColors.accentGreen,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: design_colors.AppColors.error,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: design_colors.AppColors.error,
                  width: 2.0,
                ),
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: context.colors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
