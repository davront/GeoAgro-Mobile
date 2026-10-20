import 'package:flutter/material.dart';

import 'package:agro_employee_public/design_system/theme/colors.dart'
    as design_colors;
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

import '../../drawing/polygon_validator.dart';
import '../../vm/create_map_page_vm.dart';

/// Плашка над картой: площадь контура в гектарах и под ней — причина, по
/// которой «Keyingi» сейчас неактивна.
class DrawingMetricsBar extends StatelessWidget {
  final CreateMapPageVm vm;

  const DrawingMetricsBar({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final issue = vm.blockingIssue;
    final hasArea = vm.drawingPoints.length >= 3;
    if (!hasArea && issue == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasArea)
            Text(
              "${vm.getPolygonArea().toStringAsFixed(2)} ga",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          if (issue != null) ...[
            if (hasArea) const SizedBox(height: 4),
            Text(
              issue.message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: issue.kind == PolygonIssueKind.tooFewPoints
                    ? colors.textSecondary
                    : design_colors.AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
