import "package:dio/dio.dart";
import "package:firebase_performance/firebase_performance.dart";

/// Firebase Performance Monitoring не видит Dio-запросы автоматически
/// (его встроенный network-мониторинг перехватывает на уровне
/// dart:io HttpClient/OkHttp, а Dio оборачивает это по-своему) — этот
/// interceptor вручную создаёт HttpMetric на каждый запрос к
/// api.geoagro.uz, чтобы latency/response size реально появлялись в
/// консоли Performance, а не только автоматический app-start трейс.
class PerformanceInterceptor extends Interceptor {
  PerformanceInterceptor();

  static const String _metricKey = 'perf_metric';

  HttpMethod _toHttpMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HttpMethod.Get;
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'PATCH':
        return HttpMethod.Patch;
      case 'DELETE':
        return HttpMethod.Delete;
      default:
        return HttpMethod.Get;
    }
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final metric = FirebasePerformance.instance.newHttpMetric(
        options.uri.toString(),
        _toHttpMethod(options.method),
      );
      await metric.start();
      options.extra[_metricKey] = metric;
    } catch (_) {
      // Best-effort: сбой замера метрики никогда не должен блокировать
      // сам запрос.
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    final metric = response.requestOptions.extra[_metricKey] as HttpMetric?;
    if (metric != null) {
      try {
        metric.httpResponseCode = response.statusCode;
        final contentLength = response.headers.value('content-length');
        if (contentLength != null) {
          metric.responsePayloadSize = int.tryParse(contentLength);
        }
        await metric.stop();
      } catch (_) {}
    }
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final metric = err.requestOptions.extra[_metricKey] as HttpMetric?;
    if (metric != null) {
      try {
        metric.httpResponseCode = err.response?.statusCode;
        await metric.stop();
      } catch (_) {}
    }
    super.onError(err, handler);
  }
}
