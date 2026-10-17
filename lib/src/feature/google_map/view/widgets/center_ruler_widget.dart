import 'package:flutter/material.dart';

class CenterRulerWidget extends StatelessWidget {
  final bool isDrawingMode;
  
  const CenterRulerWidget({
    super.key,
    required this.isDrawingMode,
  });

  @override
  Widget build(BuildContext context) {
    // Линейка всегда видна с постоянной прозрачностью
    return Center(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.6),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.black.withValues(alpha: 0.6),
            size: 16,
          ),
        ),
      ),
    );
  }
}
