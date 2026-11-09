import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agro_employee_public/src/core/server/interceptors/token_interceptor.dart';
import 'package:agro_employee_public/src/core/setting/setup.dart' as setup;
import 'package:agro_employee_public/src/core/storage/app_storage.dart';

/// Бэк: access "old" истёк (401), /api/refresh/ отвечает [onRefresh].
class _FakeBackend implements HttpClientAdapter {
  _FakeBackend(this.onRefresh);

  final Future<ResponseBody> Function() onRefresh;
  int refreshCalls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path == '/api/refresh/') {
      refreshCalls++;
      // Задержка — чтобы второй 401 пришёл, пока первый refresh в пути.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return onRefresh();
    }
    final ok = options.headers['Authorization'] == 'Bearer new';
    return _json(ok ? {'ok': true} : {'code': 'token_not_valid'},
        ok ? 200 : 401);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );

Dio _client(_FakeBackend backend) {
  TokenInterceptor.instance.refreshDio.httpClientAdapter = backend;
  return Dio(BaseOptions(
    baseUrl: 'https://api.test',
    headers: {'Authorization': 'Bearer old'},
    // как в ApiService: 401 должен стать ошибкой и попасть в onError
    validateStatus: (s) => s != null && s < 500 && s != 401,
  ))
    ..httpClientAdapter = backend
    ..interceptors.add(TokenInterceptor.instance);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues(
        {'access_token': 'old', 'refresh_token': 'r1'});
    setup.accessToken = 'old';
  });

  test('401 → один refresh на параллельные запросы, повтор с новым access',
      () async {
    final backend =
        _FakeBackend(() async => _json({'access': 'new', 'refresh': 'r1'}, 200));
    final dio = _client(backend);

    final results = await Future.wait([dio.get('/a'), dio.get('/b')]);

    expect(results.map((r) => r.statusCode), [200, 200]);
    expect(backend.refreshCalls, 1);
    expect(await AppStorage.$read(key: StorageKey.accessToken), 'new');
    expect(setup.accessToken, 'new');
  });

  test('refresh отвергнут (400) → 401 наружу, сессия стёрта', () async {
    final dio = _client(_FakeBackend(
        () async => _json({'detail': 'Token is invalid or expired'}, 400)));

    await expectLater(dio.get('/a'), throwsA(isA<DioException>()));
    expect(await AppStorage.$read(key: StorageKey.refreshToken), isNull);
    expect(setup.accessToken, isNull);
  });

  test('нет сети на refresh → 401 наружу, сессия не тронута', () async {
    final dio = _client(_FakeBackend(() async => throw DioException
        .connectionError(
            requestOptions: RequestOptions(path: '/api/refresh/'),
            reason: 'offline')));

    await expectLater(dio.get('/a'), throwsA(isA<DioException>()));
    expect(await AppStorage.$read(key: StorageKey.refreshToken), 'r1');
    expect(setup.accessToken, 'old');
  });
}
