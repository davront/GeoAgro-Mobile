import 'package:flutter/material.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;

class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: design_colors.AppColors.error,
      body: Center(
        child: Text(
          "The application has been blocked",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
