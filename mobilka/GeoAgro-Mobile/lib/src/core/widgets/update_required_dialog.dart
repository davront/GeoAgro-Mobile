import 'package:android_intent_plus/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';

import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;

class UpdateRequiredDialog extends StatefulWidget {
  final String currentVersion;
  final String requiredVersion;
  final String downloadUrl;

  const UpdateRequiredDialog({
    super.key,
    required this.currentVersion,
    required this.requiredVersion,
    required this.downloadUrl,
  });

  @override
  State<UpdateRequiredDialog> createState() => _UpdateRequiredDialogState();
}

class _UpdateRequiredDialogState extends State<UpdateRequiredDialog> {
  bool _isDownloading = false;
  double _progress = 0;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Запрещаем закрытие диалога
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: Colors.orange,
              size: 28.sp,
            ),
            12.horizontalSpace,
            Expanded(
              child: Text(
                "Dastur eski",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Yangilang",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            16.verticalSpace,
            Text(
              "Ilovangizning yangi versiyasi mavjud. Eng so'nggi funksiyalar va xavfsizlik yangilanishlaridan foydalanish uchun ilovani yangilang.",
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.textTertiary,
                height: 1.4,
              ),
            ),
            16.verticalSpace,
            Container(
              padding: REdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Joriy versiya:",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colors.textTertiary,
                        ),
                      ),
                      Text(
                        "v${widget.currentVersion}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kerakli versiya:",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colors.textTertiary,
                        ),
                      ),
                      Text(
                        "v${widget.requiredVersion}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: design_colors.AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isDownloading) ...[
              16.verticalSpace,
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 6.h,
                  backgroundColor: context.colors.surface,
                  color: design_colors.AppColors.accentGreen,
                ),
              ),
              6.verticalSpace,
              Text(
                "${(_progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
            if (_error != null) ...[
              12.verticalSpace,
              Text(
                _error!,
                style: TextStyle(fontSize: 12.sp, color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          if (!_isDownloading)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Keyinroq",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.colors.textTertiary,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: _isDownloading ? null : _downloadAndInstall,
            style: ElevatedButton.styleFrom(
              backgroundColor: design_colors.AppColors.accentGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: REdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              _isDownloading ? "Yuklanmoqda..." : "Yangilash",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall() async {
    if (widget.downloadUrl.isEmpty) {
      setState(() => _error = "Yuklab olish havolasi topilmadi");
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
      _error = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final savePath = "${dir.path}/geoagro_update.apk";

      await Dio().download(
        widget.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total <= 0 || !mounted) return;
          setState(() => _progress = received / total);
        },
      );

      if (!mounted) return;

      final result = await OpenFilex.open(savePath);
      if (result.type == ResultType.permissionDenied) {
        // "Install unknown apps" не разрешён для этого приложения —
        // системный APK-installer отказывает ещё до показа своего
        // диалога подтверждения. Разрешение per-app и не запрашивается
        // диалогом в рантайме (в отличие от camera/location) — единственный
        // путь юзера дать его — открыть системный экран настроек именно
        // для этого приложения-источника.
        await _openUnknownSourcesSettings();
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _error =
                "Noma'lum manbalardan o'rnatishga ruxsat bering va qayta urinib ko'ring";
          });
        }
      } else if (result.type != ResultType.done && mounted) {
        setState(() {
          _isDownloading = false;
          _error = "O'rnatishni ochib bo'lmadi: ${result.message}";
        });
      }
    } on DioException {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _error = "Yuklab olishda xatolik yuz berdi";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _error = "Xatolik: $e";
        });
      }
    }
  }

  Future<void> _openUnknownSourcesSettings() async {
    try {
      const packageName = "uz.geoagro.mobile";
      final intent = AndroidIntent(
        action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
        data: 'package:$packageName',
      );
      await intent.launch();
    } on PlatformException {
      // Некоторые OEM-прошивки (или Android < 8, где разрешение вообще
      // не per-app) не поддерживают этот action — открываем общий экран
      // настроек приложения как fallback, юзер сам найдёт нужный пункт.
      const packageName = "uz.geoagro.mobile";
      final intent = AndroidIntent(
        action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
        data: 'package:$packageName',
      );
      await intent.launch();
    }
  }
}
