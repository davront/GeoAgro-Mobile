import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repository/app_repository_impl.dart';
import 'upload_queue_service.dart';

/// App-scoped (не autoDispose) провайдер очереди офлайн-загрузок — живёт
/// весь запуск приложения, тот же паттерн что и `themeProvider`
/// (app_material_context.dart). Инициализируется рано, до первого build
/// (см. `App.run` в app.dart — отдельный ProviderContainer читает его
/// перед runApp), чтобы слушать connectivity ещё до первого захода на
/// экран формы/очереди.
final uploadQueueServiceProvider = ChangeNotifierProvider<UploadQueueService>(
  (ref) {
    final service = UploadQueueService(
      connectivity: Connectivity(),
      repo: AppRepositoryImpl(),
    );
    service.init();
    ref.onDispose(service.dispose);
    return service;
  },
);
