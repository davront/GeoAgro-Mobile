import "dart:async";
import "dart:developer";
import "dart:io";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:http/http.dart" show ClientException;

import "setup.dart";
import "app.dart";
import "../setting/remote_controller.dart";

/// Пойманные сетевые/плагинные ошибки, которые не являются багами
/// приложения — соединение оборвалось при стриминге картинки,
/// google_maps_flutter гоняется за уже удалённым маркером и т.п. Их
/// репортим в Crashlytics как non-fatal, чтобы не терять сигнал, но не
/// портить crash-free rate тем, что нельзя починить на нашей стороне.
bool _isBenignError(Object error) {
  // HttpException при загрузке картинки — соединение оборвалось
  // посреди стрима байтов (плохое покрытие/переключение сети во время
  // просмотра фото). Точный текст сообщения варьируется в зависимости
  // от того, где именно сокет оборвался ("Connection closed while
  // receiving data", "Software caused connection abort" и т.п.) —
  // класс исключения уже однозначно указывает на сетевую причину.
  if (error is HttpException) return true;

  // SocketException при загрузке картинки — тот же сетевой обрыв
  // соединения (например "Software caused connection abort"), просто
  // другой подтип исключения долетает до FlutterError.onError в
  // зависимости от того, на каком этапе HTTP-стрима порвалось.
  if (error is SocketException) return true;

  // ClientException (package:http) — тот же оборванный стрим картинки,
  // но прилетает через http-based image loader (не dart:io напрямую),
  // например "Connection closed while receiving data".
  if (error is ClientException) return true;

  // google_maps_flutter иногда зовёт hideInfoWindow на markerId,
  // который уже удалён из Set<Marker> (гонка между пересборкой
  // маркеров и открытым InfoWindow) — баг самого плагина, не нашего
  // кода, апстрим-фикса нет.
  if (error is PlatformException &&
      error.code == 'Invalid markerId' &&
      (error.message?.contains('hideInfoWindow') ?? false)) {
    return true;
  }

  // updateMarkers падает в нативном BitmapFactory.decodeByteArray на
  // некоторых Android OEM (замечено на vivo) — PNG-байты из
  // MarkerIconUtils валидны и успешно кодируются на Dart-стороне, но
  // decode ломается уже в самом Google Maps SDK на устройстве. Ошибка
  // прилетает из platform channel (updateMarkers), Dart-side try/catch
  // вокруг генерации иконки её не перехватывает.
  if (error is PlatformException &&
      error.code == 'IllegalArgumentException' &&
      (error.message?.contains('valid image') ?? false)) {
    return true;
  }

  return false;
}

void run() {
  runZonedGuarded<void>(
    () async {
      await setup();
      await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      );

      FlutterError.onError = (details) {
        log(
          "flutter_error: ${details.exception}",
          error: details.exception,
          stackTrace: details.stack,
        );
        if (_isBenignError(details.exception)) {
          FirebaseCrashlytics.instance.recordError(
            details.exception,
            details.stack,
            fatal: false,
          );
        } else {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: !_isBenignError(error),
        );
        return true;
      };

      try {
        final RemoteController remoteController = RemoteController();
        await remoteController.initialize();
        App.run(remoteController);
      } catch (e) {
        log("Error initializing app: $e");
        App.run(RemoteController());
      }
    },
    (final error, final stackTrace) {
      log(
        "io_top_level_error: $error",
        error: error,
        stackTrace: stackTrace,
      );
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    },
  );
}
