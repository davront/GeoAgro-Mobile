import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:flutter_riverpod/legacy.dart';

import "../routes/router_config.dart";
import "package:flutter/material.dart";

import "../setting/remote_controller.dart";
import "../setting/interited_remote_notifair.dart";
import '../../../design_system/theme/theme_provider.dart';

// Provider for theme
final themeProvider = ChangeNotifierProvider<AppThemeProvider>((ref) {
  return AppThemeProvider();
});

class AppMaterialContext extends ConsumerWidget {
  final RemoteController remoteController;

  const AppMaterialContext({super.key, required this.remoteController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);

    return InheritedRemoteNotifier(
      remoteController: remoteController,
      child: Builder(
        builder: (context) {
          final isBlocked = InheritedRemoteNotifier.of(context).isBlocked;

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: isBlocked
                ? RouterConfigService.blocRouter
                : RouterConfigService.router,
            theme: themeNotifier.getTheme(Brightness.light),
            darkTheme: themeNotifier.getTheme(Brightness.dark),
            themeMode: themeNotifier.themeMode,
          );
        },
      ),
    );
  }
}
