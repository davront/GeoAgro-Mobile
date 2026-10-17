import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../design_system/tokens/colors.dart' as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import 'package:agro_employee_public/design_system/tokens/motion.dart';

/// A search bar widget with debounce functionality
///
/// Shows a search icon that expands to a search input when clicked.
/// Implements debounce to avoid too many API calls while typing.
class SearchBarWidget extends StatefulWidget {
  /// Callback when search query changes (after debounce)
  final Function(String) onSearchChanged;

  /// Callback when search form is expanded or collapsed
  final Function(bool isExpanded)? onExpansionChanged;

  /// Debounce duration in milliseconds (default: 500ms)
  final int debounceDuration;

  /// Placeholder text for the search input
  final String placeholder;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    this.onExpansionChanged,
    this.debounceDuration = 500,
    this.placeholder = "Qidiruv...",
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.normal,
    );
    _widthAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _controller.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    // Cancel previous timer if exists
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Create new timer for debounce
    _debounce = Timer(Duration(milliseconds: widget.debounceDuration), () {
      widget.onSearchChanged(_controller.text);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _controller.clear();
        // Immediately call onSearchChanged when closing to clear search
        widget.onSearchChanged('');
      }
      // Notify parent about expansion state change
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isExpanded)
              Container(
                width: 200.w * _widthAnimation.value,
                height: 40.h,
                margin: REdgeInsets.only(right: 8),
                child: Opacity(
                  opacity: _widthAnimation.value,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: context.colors.textTertiary,
                      ),
                      filled: true,
                      fillColor: context.colors.surfaceVariant,
                      contentPadding:
                          REdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: context.colors.isDark
                              ? context.colors.border
                              : context.colors.border.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: context.colors.isDark
                              ? context.colors.border
                              : context.colors.border.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: design_colors.AppColors.accentGreen,
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 18.sp),
                              onPressed: () {
                                _controller.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            IconButton(
              onPressed: _toggleSearch,
              icon: _isExpanded
                  ? Icon(Icons.close, size: 24.sp)
                  : SvgPicture.asset(
                      'assets/svg/global_search.svg',
                      width: 24.w,
                      height: 24.h,
                    ),
            ),
          ],
        );
      },
    );
  }
}
