import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

class CustomDriver extends StatelessWidget {
  const CustomDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return DottedLine(
      dashColor: context.colors.border,
      lineThickness: 1.0,
      dashLength: 4.0,
      dashGapLength: 3.0,
    );
  }
}
