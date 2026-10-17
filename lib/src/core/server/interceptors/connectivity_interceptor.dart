import "package:dio/dio.dart";

/// Раньше пытался in-memory ретраить запрос при восстановлении сети
/// (через `Connection.scheduleRequestRetry`) — но условие `_shouldRetry`
/// требовало `err.error` быть одновременно `SocketException` и
/// `TimeoutException`, что логически невозможно, поэтому retry никогда
/// не срабатывал на практике. Персистентный retry-with-backoff теперь
/// живёт в `UploadQueueService` (переживает kill процесса, чего этот
/// in-memory путь никогда не умел) — этот interceptor оставлен чистым
/// passthrough, специальная обработка сетевых ошибок здесь больше не
/// нужна.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor();

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);
  }
}
