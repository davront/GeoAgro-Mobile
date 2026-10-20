import 'package:flutter/material.dart';

import 'package:agro_employee_public/design_system/theme/colors.dart'
    as design_colors;

/// Прицел в центре карты. При прилипании к соседней границе становится
/// синим (цвет рисуемого контура), чтобы было видно, что точка встанет
/// не точно в центр, а на чужую границу.
class CenterRulerWidget extends StatelessWidget {
  final bool snapped;

  const CenterRulerWidget({super.key, this.snapped = false});

  @override
  Widget build(BuildContext context) {
    final ink = snapped
        ? design_colors.AppColors.info
        : Colors.black.withValues(alpha: 0.75);
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: snapped ? 0.9 : 0.7),
            border: Border.all(color: ink, width: snapped ? 2.5 : 1.5),
          ),
          child: Icon(Icons.add, color: ink, size: 20),
        ),
      ),
    );
  }
}
