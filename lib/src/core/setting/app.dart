import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../queue/upload_queue_provider.dart";
import "../widgets/app_material_context.dart";
import "../widgets/custom_screen_util.dart";
import "remote_controller.dart";

class App extends StatelessWidget {
  final RemoteController remoteController;

  const App({super.key, required this.remoteController});

  static void run(RemoteController remoteController) {
    // Отдельный ProviderContainer только для ранней (до первого build)
    // инициализации app-scoped сервисов вроде очереди офлайн-загрузок —
    // она должна начать слушать connectivity сразу, не дожидаясь первого
    // виджета, который её прочитает. UncontrolledProviderScope передаёт
    // этот же container дереву, так что состояние не дублируется.
    final container = ProviderContainer();
    container.read(uploadQueueServiceProvider);
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: App(remoteController: remoteController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CustomScreenUtil(
        enabledPreview: false,
        child: AppMaterialContext(remoteController: remoteController),
      );
}
