import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:agro_employee_public/src/core/version/version_check_service.dart';
import 'package:agro_employee_public/src/core/widgets/update_required_dialog.dart';

void main() {
  testWidgets('окно обновления: одно, без Keyinroq, после разлогина снова',
      (tester) async {
    PackageInfo.setMockInitialValues(
        appName: '',
        packageName: '',
        version: '4.2.3',
        buildNumber: '423',
        buildSignature: '');
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // Тестовый шрифт Ahem шире настоящего — строки версий в диалоге
    // «переполняются» только в тесте.
    final onError = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) onError?.call(d);
    };
    final nav = GlobalKey<NavigatorState>();
    late BuildContext ctx;
    await tester.pumpWidget(ScreenUtilInit(
      builder: (_, __) => MaterialApp(
        navigatorKey: nav,
        home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      ),
    ));

    Future<void> check() =>
        VersionCheckService.checkVersionAndShowUpdateDialog(ctx, '4.2.4');

    await check();
    await check(); // повторное уведомление Remote Config
    await tester.pumpAndSettle();
    expect(find.byType(UpdateRequiredDialog), findsOneWidget);
    expect(find.text('Keyinroq'), findsNothing);

    // Разлогин: go(login) убирает диалог вместе со страницей под ним.
    nav.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
        (_) => false);
    await tester.pumpAndSettle();
    expect(find.byType(UpdateRequiredDialog), findsNothing);

    await check(); // главная после входа
    await tester.pumpAndSettle();
    expect(find.byType(UpdateRequiredDialog), findsOneWidget);
    FlutterError.onError = onError;
  });
}
