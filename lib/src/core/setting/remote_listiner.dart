import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'remote_controller.dart';
import '../tools/assets.dart';
import 'package:agro_employee_public/design_system/tokens/colors.dart'
    as design_colors;

final remoteControllerVM =
    ChangeNotifierProvider.autoDispose<RemoteController>((ref) {
  return RemoteController();
});

class RemoteListiner extends ConsumerWidget {
  final Widget child;

  // ignore: use_super_parameters
  const RemoteListiner({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionController = ref.watch(remoteControllerVM);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (connectionController.isBlocked && !connectionDialogIsOpen) {
        showDialogIfNotConnected(context);
      } else if (!connectionController.isBlocked && connectionDialogIsOpen) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        connectionDialogIsOpen = false;
      }
    });

    return child;
  }

  void showDialogIfNotConnected(BuildContext context) {
    connectionDialogIsOpen = true;
    showDialog(
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.62),
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: design_colors.AppColors.error,
          title: SvgPicture.asset(
            Assets.warningSvg,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          content: Text(
            "Ilova Yaratuvchilari Tomonidan Block Holatiga Tushdi",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

bool connectionDialogIsOpen = false;
