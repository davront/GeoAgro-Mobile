import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';

class BorderWidget extends StatelessWidget {
  final List<Widget> children;

  const BorderWidget({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: Radius.circular(12.r),
        padding: REdgeInsets.all(10),
        strokeWidth: 1,
        color: Colors.grey,
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
