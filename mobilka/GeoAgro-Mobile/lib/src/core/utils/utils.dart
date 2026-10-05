import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

sealed class Utils {
  /// Проверить, является ли файл изображением формата JPEG/JPG
  static bool isValidImageFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return extension == 'jpg' || extension == 'jpeg';
  }
  // // FireSnackBar
  // static void fireSnackBar(String msg, Color bgColor, BuildContext context) {
  //   final scaffoldMessenger = ScaffoldMessenger.of(context);
  //   scaffoldMessenger.showSnackBar(
  //     SnackBar(
  //       backgroundColor: bgColor,
  //       content: Text(msg,
  //           style: TextStyle(color: Colors.white, fontSize: 16.sp),
  //           textAlign: TextAlign.center),
  //       duration: const Duration(milliseconds: 2500),
  //       padding: REdgeInsets.symmetric(vertical: 20),
  //       margin: REdgeInsets.only(
  //           left: 16,
  //           right: 16,
  //           bottom: MediaQuery.of(context).size.height * 0.82),
  //       elevation: 0,
  //       behavior: SnackBarBehavior.floating,
  //       shape: const StadiumBorder(),
  //     ),
  //   );
  // }

  static void fireTopSnackBar(
    String msg,
    Color bgColor,
    BuildContext context, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: REdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                msg,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    // Xabarni avtomatik olib tashlash — mounted tekshiruvisiz ikkinchi
    // remove() (masalan navigatsiya overlay'ni allaqachon tozalagan
    // bo'lsa) assertion xatosiga olib keladi.
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
